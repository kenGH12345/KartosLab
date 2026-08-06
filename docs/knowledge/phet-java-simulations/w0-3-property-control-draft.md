# W0-3 · PropertyControl 控件蓝本草案

> 分析日期：2026-07-22 · Java 蓝本：`<PHET_JAVA_ROOT>/simulations-java/common/piccolo-phet/src/.../nodes/slider/` + `nodes/radiobuttonstrip/`
> 目标：将 Java `SliderNode` + `RadioButtonStrip` + `ComboBoxNode` 的核心概念翻译为 Flutter/Dart 统一控件族
> 原则：Q4=B（借概念不照抄）——去掉 Piccolo PNode/SettableProperty 层，统一用 Flutter Widget + callback

## 一、Java 蓝本架构

```
VSliderNode / HSliderNode (水平/垂直滑动条)
  ├── trackNode (矩形轨道 + 渐变色)
  ├── knobNode (可拖拽旋钮 · KnobNode 带颜色方案)
  ├── addLabel(value, PNode) → 添加刻度标签 + 刻度线
  └── 拖拽事件: startDrag → dragged → dragEnded
      
SliderNode (抽象基类)
  ├── min / max / value (SettableProperty<Double>)
  ├── dragStarted() / dragged() / dragEnded() (simsharing 消息)
  └── setTrackFillPaint(Paint)

RadioButtonStripControlPanelNode (单选组)
  ├── ToggleButtonNode[] (多个互斥按钮)
  └── 选中枚举值切换

ComboBoxNode (下拉选择)
  ├── PhetPComboBox (Swing JComboBox 的 Piccolo 包装)
  └── items + selectedItem

PhetPComboBox / PhetJComboBox (下拉)
  └── JComboBox → PSwing 桥接
```

**关键设计思想**（应保留）：
1. **min / max / value 三元组**——所有 PhET 滑块都基于 `[min, max]` 区间内取 `value`
2. **可打标签**——滑块可以在特定值位置加文字标签（如 "None" / "Lots"）
3. **双态 toggle**——同类控件可用 `ToggleButtonNode` 实现开/关
4. **刻度标签+刻度线**——`addLabel` 会在该值位置画刻度线（延伸到轨道）

**Piccolo/Swing 特有（应丢弃）**：
- `PNode` / `PhetPPath` / `PSwing` → Flutter Widget
- `SettableProperty<Double>` → Dart `ValueChanged<double>` callback
- `IUserComponent` simsharing 消息 → Flutter 不需要（或用 analytics callback）
- `KnobNode.ColorScheme` → Flutter `Theme` / 硬编码颜色

## 二、Dart API 草案

### 2.1 核心控件：`PhetSlider`

```dart
/// PhET 风格滑动条——min/max 区间内拖拽取 value。
///
/// 用法（在 Screen 的 build 中）：
/// ```dart
/// PhetSlider(
///   label: '焦距',
///   unit: 'cm',
///   min: 5,
///   max: 50,
///   step: 1,
///   value: lens.focalLength,
///   onChanged: (v) => setState(() => lens = lens.copyWith(focalLength: v)),
///   enabled: isEditable,
/// )
/// ```
class PhetSlider extends StatelessWidget {
  // ── 必需参数 ──
  final String label;                     // 标签文字（如 "焦距"）
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;   // 拖拽结束时回调

  // ── 可选参数 ──
  final String? unit;                     // 单位（如 "cm"、"°"）
  final double step;                      // 步进（默认连续）
  final bool enabled;                     // 是否可交互（默认 true）
  final Map<double, String>? tickLabels;  // 刻度标签（如 {0: "None", 100: "Lots"}）
  final Axis direction;                   // Axis.vertical 或 Axis.horizontal（默认 horizontal）

  // ── 视觉选项 ──
  final Color? trackColor;                // 轨道颜色
  final Color? knobColor;                 // 旋钮颜色
  final double trackThickness;            // 轨道粗细（默认 6）
  final double trackLength;               // 轨道长度（默认 200 · 可 override）

  // ── 内部结构 ──
  // [label] [━━━●━━━━━━━━━━] [value unit]
  //          ↑ 刻度标签
}
```

### 2.2 滑动条替代控件：`PhetNumberField`

```dart
/// PhET 风格数值输入框——对应 Java 版 GraphControlTextBox。
///
/// 用于"精确输入数值"场景（如 moving-man 的位置输入）。
class PhetNumberField extends StatelessWidget {
  final String label;
  final String? unit;
  final double value;
  final double min;
  final double max;
  final String format;                    // 数值格式（如 "0.00"）
  final ValueChanged<double> onChanged;
  final bool enabled;
}
```

### 2.3 单选组：`PhetRadioGroup<T>`

```dart
/// PhET 风格单选按钮组——对应 Java RadioButtonStripControlPanelNode。
///
/// 用法：
/// ```dart
/// PhetRadioGroup<String>(
///   label: '显示',
///   items: const ['位置', '速度', '加速度'],
///   value: selectedGraph,
///   onChanged: (v) => setState(() => selectedGraph = v),
/// )
/// ```
class PhetRadioGroup<T> extends StatelessWidget {
  final String? label;                    // 组标签（可选）
  final List<T> items;                    // 选项列表
  final List<String>? itemLabels;         // 显示标签（默认 items.toString()）
  final T value;                          // 当前选中
  final ValueChanged<T> onChanged;
  final Axis direction;                   // 排列方向（默认 Axis.vertical）
  final bool enabled;
}
```

### 2.4 下拉选择：`PhetComboBox<T>`

```dart
/// PhET 风格下拉选择——对应 Java ComboBoxNode / PhetPComboBox。
///
/// 用于选项较多时替代 RadioGroup。
class PhetComboBox<T> extends StatelessWidget {
  final String? label;
  final List<T> items;
  final List<String>? itemLabels;
  final T value;
  final ValueChanged<T> onChanged;
  final bool enabled;
}
```

### 2.5 聚合容器：`PropertyControlPanel`

```dart
/// 将多个属性控件垂直排列——对应 Java 版右侧 `ControlPanel`。
///
/// 用法：
/// ```dart
/// PropertyControlPanel(
///   children: [
///     PhetSlider(label: '焦距', unit: 'cm', min: 5, max: 50, value: f, onChanged: ...),
///     PhetSlider(label: '折射率', min: 1.0, max: 2.5, value: n, onChanged: ...),
///     PhetRadioGroup<String>(label: '类型', items: ['凸透镜', '凹透镜'], value: type, onChanged: ...),
///   ],
/// )
/// ```
class PropertyControlPanel extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double spacing;                   // 子控件间距（默认 16）
  final bool showDivider;                 // 是否显示分隔线
}
```

### 2.6 与 scenario JSON 的集成（§C2 合规）

Flutter phet 的 `§C2 元件规格来源` 硬约束要求控件参数从 scenario JSON 读取。`PropertyControlPanel` 提供工厂方法直接接入：

```dart
/// 从 scenario JSON 的 `params` 段自动生成控件列表。
///
/// JSON 格式（optics_scenario.schema.json）：
/// ```json
/// {
///   "params": [
///     { "key": "focalLength", "label": "焦距", "unit": "cm", 
///       "min": 5, "max": 50, "step": 1, "type": "slider" },
///     { "key": "lensType", "label": "透镜类型", 
///       "options": ["convex", "concave"], "type": "radio" }
///   ]
/// }
/// ```
static PropertyControlPanel fromScenarioParams(
  List<dynamic> params,
  Map<String, double> currentValues,      // 从 Model 读取当前值
  void Function(String key, dynamic value) onParamChanged,
) {
  // 遍历 params，根据 type 创建对应控件
  // "slider" → PhetSlider
  // "radio" → PhetRadioGroup
  // "combo" → PhetComboBox
  // "number" → PhetNumberField
}
```

## 三、Java ↔ Dart 概念映射表

| Java (`SliderNode` / `VSliderNode` / `HSliderNode`) | Dart (`PhetSlider`) | 说明 |
|---|---|---|
| `SliderNode.min / max / value` | `min / max / value` | 三元组直接对应 |
| `SettableProperty<Double>` | `ValueChanged<double> onChanged` | Java 可变属性 → Dart callback |
| `VSliderNode` (垂直) | `PhetSlider(direction: Axis.vertical)` | |
| `HSliderNode` (水平) | `PhetSlider(direction: Axis.horizontal)`（默认） | |
| `trackNode` (矩形轨道 + 渐变色) | `Container` + `LinearGradient` | |
| `knobNode` (KnobNode 菱形旋钮) | `Container` (圆形/菱形) + `GestureDetector` | |
| `addLabel(value, PNode)` | `tickLabels: {0: "None", 100: "Lots"}` | 刻度标签 Map |
| `dragStarted/dragged/dragEnded` | `onChangeStart` / `onChanged` / `onChangeEnd` | 三阶段回调 |
| `setTrackFillPaint(Paint)` | `trackColor` 参数 | |
| `KnobNode.ColorScheme` | `knobColor` 参数 | |
| `DEFAULT_TRACK_THICKNESS = 6` | `trackThickness`（默认 6） | |
| `DEFAULT_TRACK_LENGTH = 200` | `trackLength`（默认 200） | |

| Java (`RadioButtonStrip` / `ComboBoxNode`) | Dart (`PhetRadioGroup` / `PhetComboBox`) | 说明 |
|---|---|---|
| `RadioButtonStripControlPanelNode` | `PhetRadioGroup<T>` | 单选组 |
| `ToggleButtonNode` (单选) | `ChoiceChip` / `SegmentedButton` | Flutter 原生替代 |
| `ComboBoxNode` / `PhetPComboBox` | `PhetComboBox<T>` | 下拉选择 |
| `JComboBox` → `PSwing` 桥接 | `DropdownButton` / `PopupMenuButton` | Flutter 原生替代 |

## 四、MVP 最小集

| 控件 | MVP | 理由 |
|---|---|---|
| `PhetSlider` (水平) | ✅ | 最常用——几乎所有 sim 都会用 |
| `PhetSlider.vertical` (垂直) | ✅ | 温度/水位等竖直场景 |
| `PhetRadioGroup<T>` | ✅ | 模式切换（透镜类型、图表选择等） |
| `PhetComboBox<T>` | ✅ | 选项多时替代 RadioGroup |
| `PropertyControlPanel` | ✅ | 聚合容器——当前 Screen 的 `_RightPanel` 可替换 |
| `fromScenarioParams` 工厂 | ✅ | §C2 合规——所有参数从 JSON 来 |
| `PhetNumberField` | ❌ 可延后 | moving-man 精确输入才需要 |
| 垂直滑动条 `Axis.vertical` | ❌ 可延后 | 少数 sim 用 |
| 刻度标签 `tickLabels` | ❌ 可延后 | 视觉优化 |

## 五、与现有 Flutter phet 代码的对齐

Flutter phet 现状：每个 Screen 的 `_RightPanel` 手写 `Slider` + `TextField`（如 `optics_screen.dart` 光学模块右侧控制面板）。

**迁移路径**（最小改动）：

```dart
// BEFORE（现状 · optics_screen.dart 右侧面板 · 手写 Flutter Slider）
Slider(
  value: lens.focalLength,
  min: 5, max: 50,
  onChanged: (v) => setState(() => lens = lens.copyWith(focalLength: v)),
)

// AFTER（迁移后 · 用 PhetSlider + 自动生成标签）
PhetSlider(
  label: '焦距', unit: 'cm',
  min: 5, max: 50, step: 1,
  value: lens.focalLength,
  onChanged: (v) => setState(() => lens = lens.copyWith(focalLength: v)),
)
```

**更激进的迁移**（用 scenario JSON 驱动整个右侧面板）：

```dart
// AFTER（§C2 全合规 · scenario JSON 驱动）
PropertyControlPanel.fromScenarioParams(
  scenario.params,
  currentValues: {'focalLength': lens.focalLength, 'refractiveIndex': lens.n},
  onParamChanged: (key, value) => setState(() => lens = lens.copyWithField(key, value)),
)
```

## 六、文件落地位置（Q2=A · `lib/common/`）

```
C:\workspace\phet\lib\common\
├── simulation_clock.dart              # W0-2 · SimulationClock
├── widgets/
│   ├── time_control_bar.dart          # W0-2 · TimeControlBar UI
│   └── property_control_panel.dart    # W0-3 · PropertyControlPanel + 工厂方法
├── controls/
│   ├── phet_slider.dart               # PhetSlider (水平/垂直)
│   ├── phet_radio_group.dart          # PhetRadioGroup<T>
│   ├── phet_combo_box.dart            # PhetComboBox<T>
│   └── phet_number_field.dart         # PhetNumberField (可延后)
└── chart/
    ├── chart_series.dart              # W0-1
    ├── chart_data.dart
    ├── phet_chart.dart
    ├── graph_suite.dart
    └── chart_painter.dart
```

## 七、W0 P0 三项完整进度

| P0 项 | 草案状态 | Java 蓝本 | Dart 产出 |
|---|---|---|---|
| **W0-2 SimulationClock** | ✅ | `IClock.java`(133行) + `ConstantDtClock.java`(230行) + `TimeControlPanel.java`(391行) | `lib/common/simulation_clock.dart` + `widgets/time_control_bar.dart` |
| **W0-1 Chart** | ✅ | `ControlGraph.java`(785行) + `ControlGraphSeries.java`(157行) + `GraphSuite.java`(38行) | `lib/common/chart/` 5 文件 |
| **W0-3 PropertyControl** | ✅ | `VSliderNode.java`(211行) + `HSliderNode.java`(152行) + `RadioButtonStripControlPanelNode.java` | `lib/common/controls/` 4 文件 + `widgets/property_control_panel.dart` |

## 八、参考源

| Java 蓝本 | 行数 | 关键信息 |
|---|---|---|
| `SliderNode.java` | 71 行 | 基类：min/max/value(SettableProperty) + dragStarted/dragged/dragEnded |
| `VSliderNode.java` | 211 行 | 垂直滑块：trackNode + knobNode(KnobNode) + 拖拽事件(PDragSequenceEventHandler) + 滚动支持 |
| `HSliderNode.java` | 152 行 | 水平滑块：组合 VSliderNode 旋转 90° + addLabel(value, PNode) 加刻度标签 |
| `RadioButtonStripControlPanelNode.java` | piccolo-phet 下 | 单选组：ToggleButtonNode[] 互斥 |
| `ComboBoxNode.java` | piccolo-phet 下 | 下拉选择：PhetPComboBox(JComboBox 包装) |
| Flutter phet 侧 §C2 | `architecture/design-patterns.md` | 元件规格来源硬约束（defaultParams/valueMin/valueMax/valueStep 从 JSON 来） |

---

> **下一步**：
> 1. 如批准本草案 → 在 `c:\workspace\phet\lib\common\controls\` 创建 4 个文件 + `widgets/property_control_panel.dart`
> 2. optics 模块作为首个迁移目标——用 `PhetSlider` 替代 `_RightPanel` 里的原装 `Slider`
> 3. 对齐 §C2：让 `PropertyControlPanel.fromScenarioParams` 直接从 JSON `params` 段生成控件
