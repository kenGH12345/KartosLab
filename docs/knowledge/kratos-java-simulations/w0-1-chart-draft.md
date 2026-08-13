# W0-1 · Chart 图表控件蓝本草案

> 分析日期：2026-07-22 · Java 蓝本：`<PHET_JAVA_ROOT>/simulations-java/common/motion/src/.../graphs/` + `common/jfreechart-kartos/`
> 目标：将 Java `ControlGraph` + `ControlGraphSeries` + `GraphSuite` 的核心概念翻译为 Flutter/Dart 最小可用 API
> 原则：Q4=B（借概念不照抄）——去掉 JFreeChart/Swing/Piccolo 三层依赖，统一用 Flutter CustomPainter

## 一、Java 蓝本架构

```
GraphSetModel (M)
  └── GraphSuite (多个 MinimizableControlGraph 的命名集合)
        └── MinimizableControlGraph (可折叠壳)
              └── ControlGraph (PNode · 核心图表组件)
                    ├── DynamicJFreeChartNode (JFreeChart → Piccolo 桥接)
                    │     └── SeriesData[] (数据系列)
                    ├── JFreeChartSliderNode (时间滑动条)
                    ├── GraphTimeControlNode (播放控制)
                    ├── ZoomSuiteNode (横/纵缩放)
                    └── TitleLayer (系列读数)

ControlGraphSeries (数据描述)
  ├── title / color / abbr / units / stroke / visible / editable
  └── ITemporalVariable (时间序列数据源)
        └── TimeData[] = (time, value) 对
```

**关键设计思想**（应保留）：
1. **图表 = 轴 + 数据系列 + 交互层**——不是"一个固定配置的图"，而是可组装
2. **GraphSuite 槽位切换**——同一位置可切换不同图表集（如 "Position+Velocity" ↔ "Velocity+Acceleration"）
3. **时间轴是核心 x 轴**——所有 PhET 图表都是 x=time 的时间序列图
4. **可拖拽竖线**（slider）——在图表上拖动竖线改变当前观察时刻
5. **横/纵缩放**——用户可以 zoom in/out 观察细节

**JFreeChart / Swing / Piccolo 特有（应丢弃）**：
- `JFreeChart` / `XYPlot` / `NumberAxis` / `XYSeries` / `XYItemRenderer` → Flutter `CustomPainter`
- `DynamicJFreeChartNode` + `JFreeChartNode` → Flutter `CustomPainter`（Piccolo 桥接层不需要）
- `PNode` / `PhetPCanvas` / `PSwing` → Flutter `StatelessWidget`
- `java.awt.Color` / `Stroke` → Dart `Color` / `PaintStyle`

## 二、Dart API 草案

### 2.1 数据描述：`ChartSeries`

```dart
/// 图表上的一条数据线（如 "位置 x" 或 "速度 v"）。
class ChartSeries {
  final String title;       // 如 "Position"
  final String abbr;        // 缩写，如 "x"（用于图例）
  final String unit;        // 单位，如 "m"
  final Color color;        // 线条颜色
  final double strokeWidth; // 线宽（默认 2.0）
  final bool visible;       // 是否可见
  final bool editable;      // 用户是否可输入值
  final String? character;  // 角色名（如 "Mom"·用于 moving-man 多角色场景）

  const ChartSeries({
    required this.title,
    required this.color,
    this.abbr = '',
    this.unit = '',
    this.strokeWidth = 2.0,
    this.visible = true,
    this.editable = false,
    this.character,
  });
}
```

### 2.2 数据源：`TimeDataPoint` + `SeriesDataProvider`

```dart
/// 时间序列上的一个数据点。
class TimeDataPoint {
  final double time;
  final double value;
  const TimeDataPoint(this.time, this.value);
}

/// 为 Chart 提供数据。由 Model 层实现。
abstract class SeriesDataProvider {
  /// 获取该系列的全部数据点（从 t=0 到当前时刻）。
  List<TimeDataPoint> getAllPoints();
  /// 获取最近 N 个数据点。
  List<TimeDataPoint> getRecentPoints(int count);
  /// 清除全部数据。
  void clear();
}
```

### 2.3 核心图表：`KratosChart`

```dart
/// PhET 通用时间序列图表。
///
/// 用法（在 Screen 的 build 中）：
/// ```dart
/// KratosChart(
///   series: [
///     ChartSeries(title: 'Position', abbr: 'x', unit: 'm', color: Colors.blue),
///     ChartSeries(title: 'Velocity', abbr: 'v', unit: 'm/s', color: Colors.red),
///   ],
///   dataProviders: [positionData, velocityData],
///   domainLabel: 'Time (s)',
///   domainRange: const Range(0, 20),
///   rangeRange: const Range(-10, 10),
///   currentTime: state.time,
///   onTimeChanged: (t) => setState(() => state = state.copyWith(time: t)),
///   zoomFraction: 1.1,
/// )
/// ```
class KratosChart extends StatelessWidget {
  // ── 必需参数 ──
  final List<ChartSeries> series;           // 数据线描述（1-N 条）
  final List<SeriesDataProvider> dataProviders; // 数据源（与 series 一一对应）
  final Range domainRange;                   // x 轴范围（时间）
  final Range rangeRange;                    // y 轴范围（值）
  final double currentTime;                  // 当前观察时刻（竖线位置）
  final ValueChanged<double> onTimeChanged;  // 用户拖动竖线时回调

  // ── 可选参数 ──
  final String? domainLabel;                 // x 轴标签（如 "Time (s)"）
  final String? rangeLabel;                  // y 轴标签
  final double zoomFraction;                 // 每次缩放倍率（默认 1.1）
  final bool showZoomControls;               // 是否显示纵横缩放按钮
  final bool showGrid;                       // 是否显示网格
  final bool showSlider;                     // 是否显示时间竖线
  final bool showLegend;                     // 是否显示图例（颜色+系列名）
  final List<Widget>? extraControls;         // 额外控件（插到底部）

  // ── ChartPainter (内部 CustomPainter) ──
  // 绘制顺序：
  // 1. 背景 + 网格线
  // 2. 轴标签 + 刻度
  // 3. 每条数据线（按 series[i].color）
  // 4. 当前时间竖线（currentTime · 红色虚线）
  // 5. 图例（右上角）
}
```

### 2.4 图表组切换：`GraphSuite` + `GraphSuiteSelector`

```dart
/// 一组图表的命名集合（如 "Motion：Position+Velocity+Acceleration"）。
class GraphSuite {
  final String label;                // 显示标签（如 "v,a"）
  final List<ChartSeries> series;    // 这一组包含的系列
  const GraphSuite({required this.label, required this.series});
}

/// 图表组选择器（RadioButton 风格 · 切换不同 GraphSuite）。
///
/// 对应 Java `GraphSuiteSet` + `GraphSelectionControl`。
class GraphSuiteSelector extends StatelessWidget {
  final List<GraphSuite> suites;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
}
```

### 2.5 与 Flutter kartosos 现有 CustomPainter 规范的融合

Flutter kratos 已有成熟规范（[conventions/add-custom-painter.md](../kratos/conventions/add-custom-painter.md)）：

| 规范 | 在 KratosChart 中的落地 |
|---|---|
| **构造注入不可变数据** | `KratosChart` 的 `series` / `dataProviders` / `domainRange` / `rangeRange` / `currentTime` 全部外部传入 |
| **`paint(Canvas, Size)` 命令式绘制** | `ChartPainter.paint()` 按顺序画网格→轴→线→竖线→图例 |
| **`shouldRepaint` 引用比较** | 比较 `series` / `currentTime` / `domainRange` 引用 |
| **绘制与交互分离** | 竖线拖拽用 `GestureDetector.onHorizontalDragUpdate` 在 Widget 层处理，不在 Painter 内 |

## 三、Java ↔ Dart 概念映射表

| Java (`ControlGraph` 体系) | Dart (`KratosChart` 体系) | 说明 |
|---|---|---|
| `ControlGraphSeries` | `ChartSeries` | 数据线元信息（title/color/stroke/visible/editable） |
| `ITemporalVariable` + `TimeData[]` | `SeriesDataProvider` + `TimeDataPoint` | 数据源抽象 |
| `ControlGraph` (PNode) | `KratosChart` (StatelessWidget) | 核心图表组件 |
| `DynamicJFreeChartNode` | `CustomPaint(child: ChartPainter(...))` | JFreeChart 渲染层 → Flutter Canvas |
| `JFreeChartSliderNode` | `GestureDetector` 拖拽竖线（由 `KratosChart` 内部处理） | 时间竖线 + 拖拽 |
| `GraphTimeControlNode` | `TimeControlBar`（W0-2 产物） | 播放/暂停/步进 |
| `ZoomSuiteNode` | 纵横缩放按钮（`KratosChart.showZoomControls`） | zoom in/out |
| `TitleLayer` + `ReadoutTitleNode` | 图例区域（`KratosChart.showLegend`） | 系列名 + 颜色 + 当前值 |
| `GraphSuite` | `GraphSuite` | 图表组（几组可选图表） |
| `GraphSetModel` | `State` 中持 `List<GraphSuite>` + `selectedIndex` | 图表组切换状态 |
| `GraphSelectionControl` | `GraphSuiteSelector` (RadioButton 风格) | 图表组切换 UI |
| `MinimizableControlGraph` | ❌ 不提供（Flutter 用 `ExpansionTile` 替代） | 折叠/展开 |
| `ControlGraph.Listener` (controlFocusGrabbed/zoomChanged/valueChanged) | 回调参数（`onTimeChanged` · `onZoomChanged`） | Java Listener → Dart callback |
| `JFreeChart` / `XYPlot` / `NumberAxis` / `XYSeries` | ❌ 全部去掉 · 用 Canvas API 原生画 | 第三方图表库依赖 → Flutter 原语 |

### 绘图 API 关键差异

| Java JFreeChart | Flutter Canvas 等价 |
|---|---|
| `XYPlot.setDomainAxis().setRange(min, max)` | `domainRange` → 用 `canvas.translate` + `canvas.scale` 映射坐标 |
| `XYItemRenderer.drawItem()` | `canvas.drawLine()` 逐点画折线 |
| `XYSeries.add(time, value)` | `dataProviders[i].getAllPoints()` → ChartPainter 遍历画 |
| `NumberAxis.setTickUnit()` | `canvas.drawLine()` 画刻度 + `TextPainter` 画标签 |
| `PlotOrientation.VERTICAL` | 始终 VERTICAL（time 在 x，value 在 y） |
| `chart.setBackgroundPaint(null)` | `canvas.drawRect(bgRect, bgPaint)`（背景色） |

## 四、最终 API 最小集（MVP 阶段）

按 `10-vibecoding-protocol.mdc` "最小化方案优于过度设计"（`00-engineering-principles.mdc` §4），首版只做：

| 功能 | 是否 MVP | 理由 |
|---|---|---|
| 单系列折线图 | ✅ | moving-man 的 x-t 图 |
| 多系列叠加 | ✅ | moving-man 的 x/v/a 三线图 |
| 时间竖线（slider）拖拽 | ✅ | PhET 核心交互 |
| 横轴缩放 | ✅ | 看不同时间范围 |
| 图例（颜色+系列名+当前值） | ✅ | 用户需要知道哪条线是什么 |
| GraphSuite 切换 | ✅ | moving-man 的 v,a ↔ v,a,t 等切换 |
| 纵轴缩放 | ❌ MVP 不必须 | 可以常量 y 轴范围，之后加 |
| editable 系列（用户输入值） | ❌ MVP 不必须 | 只有少数 sim 需要 |
| 栅格线 | ❌ MVP 不必须 | 纯视觉优化 |
| MinimizableControlGraph | ❌ 不需要（Flutter 用 ExpansionTile） | |

## 五、文件落地位置（Q2=A · `lib/common/`）

```
C:\workspace\kartososLab\lib\common\
├── simulation_clock.dart              # W0-2 · SimulationClock
├── chart/
│   ├── chart_series.dart              # ChartSeries 数据描述
│   ├── chart_data.dart                # TimeDataPoint + SeriesDataProvider
│   ├── kratos_chart.dart              # KratosChart Widget
│   ├── graph_suite.dart               # GraphSuite + GraphSuiteSelector
│   └── chart_painter.dart             # ChartPainter (CustomPainter)
└── widgets/
    └── time_control_bar.dart           # W0-2 · TimeControlBar UI
```

## 六、接入点分析

| Flutter kartosos 模块 | 需要 Chart 吗 | 典型用法 |
|---|---|---|
| **forces** | ⭐ 最需要 | moving-man 模式：x-t / v-t / a-t 三张图 · 用 `GraphSuiteSelector` 切换 |
| **circuit** | 暂无 | CCK 不需要曲线图（纯拓扑） |
| **optics** | 暂无 | 几何光学不需要曲线图 |

**首个 Chart 交付建议**：`forces` 模块加 "Moving Man" 子屏（x-t 单图 → 验证 Chart 可用性 → 再加 v-t / a-t）。

## 七、与 W0-2 SimulationClock 的联动

```
┌──────────────────┐     onTick(dt, time)     ┌──────────────────┐
│ SimulationClock  │ ───────────────────────→ │ ForcesSimulation │
│ (统一心跳)        │                          │ (step → addData) │
└──────────────────┘                          └────────┬─────────┘
                                                       │
                                              addData(time, x, v, a)
                                                       │
                                                       ▼
                                              ┌──────────────────┐
                                              │ SeriesDataProvider│
                                              │ (时间序列缓存)     │
                                              └────────┬─────────┘
                                                       │
                                              paint() 时读全部数据
                                                       │
                                                       ▼
                                              ┌──────────────────┐
                                              │ KratosChart        │
                                              │ (CustomPainter)  │
                                              └──────────────────┘
```

**关键**：`SimulationClock`（W0-2）每 tick 产生 dt → `ForcesSimulation.step(dt)` 更新状态 → 把 x/v/a 写入 `SeriesDataProvider` → `ChartPainter.paint()` 读全量数据画线。三个组件形成完整的 **Time → Model → Chart** 数据流。

## 八、参考源

| Java 蓝本 | 行数 | 关键信息 |
|---|---|---|
| `ControlGraph.java` | 785 行 | 核心图表组件：多系列 + slider + zoom + layout · `addSeries()` / `addValue()` / `setDomain()` |
| `ControlGraphSeries.java` | 157 行 | 系列元信息：title/color/abbr/units/visible/editable · `Listener` 模式 |
| `GraphSuite.java` | 38 行 | 图表组：`MinimizableControlGraph[]` + label |
| `GraphSetModel.java` | 45 行 | 图表组切换状态：`setGraphSuite()` + listener |
| `DynamicJFreeChartNode.java` | jfreechart-kartos 目录下 | JFreeChart → Piccolo 桥接层 |
| Flutter 侧 CustomPainter 规范 | `conventions/add-custom-painter.md` | 构造注入 / toScreen / shouldRepaint |
| Flutter 侧 UI 框架 | `frontend/ui-framework.md` | 渲染分层模型 (Stack + CustomPaint) |

---

> **下一步**：
> 1. 如批准本草案 → 在 `c:\workspace\kratos\lib\common\chart\` 创建 5 个文件
> 2. forces 模块加 "Moving Man" 子屏作为首个 Chart 消费者
> 3. 与 W0-2 `SimulationClock` 联调：Clock tick → addData → chart repaint
