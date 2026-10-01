# Blackbody Spectrum · Project Discovery

> 取证范围：KARTOSLAB Flutter 工程 + PhET 源码
> 引用约定：`[来源: <路径>:<行号>]`

---

## 一、KARTOSLAB 工程现状

### 1.1 工程定位

- **包名**：`kratos`（`pubspec.yaml:2`）
- **Dart SDK**：`^3.11.1`（`pubspec.yaml:24`）
- **入口**：`lib/main.dart` → `KratosApp`（`MaterialApp`）→ `HomeScreen`（`lib/main.dart:7-48`）
- **强制横屏**：`landscapeLeft` / `landscapeRight`（`lib/main.dart:9-12`）

### 1.2 已接入 sim（`lib/screens/home_screen.dart:87-333`）

当前 HomeScreen 已接入 **27 个 sim**，分物理 / 化学两大学科。本任务将新增第 28 个。

### 1.3 与本任务最相关的参考 sim

| sim | 相关点 | 参考价值 |
|---|---|---|
| `lib/curve_fitting/` | 图表 + 坐标轴 + 自定义 Painter + 控制面板 | **同构参考**——布局与渲染模式最接近 |
| `lib/color_vision/` | RGB 颜色合成 + 动态圆 | RGB 圆 + 颜色映射逻辑参考 |
| `lib/normal_modes/` | 波形 + 拖拽点 + 数值显示 | 可拖动数值点参考 |

### 1.4 L0 通用组件（`lib/common/`，必须复用）

> 执法依据：`.codebuddy/rules/80-kratos-sim-checklist.mdc` §三 G1

| L0 组件 | 路径 | 本 sim 是否使用 | 说明 |
|---|---|---|---|
| `NineGridLayout` | `lib/common/widgets/nine_grid_layout.dart` | ✅ 强制 | 主屏幕布局（§七 L0-4 阻塞级） |
| `KratosSlider` | `lib/common/controls/kratos_slider.dart` | ❌ 不用 | 本 sim 用温度计拖拽（自定义 thumb），不是水平 slider |
| `KratosComboBox` | `lib/common/controls/kratos_combo_box.dart` | ❌ 不用 | 无下拉框 |
| `KratosRadioGroup` | `lib/common/controls/kratos_radio_group.dart` | ❌ 不用 | 无单选组 |
| `KratosNumberField` | `lib/common/controls/kratos_number_field.dart` | ❌ 不用 | 无数字输入框 |
| `PropertyControlPanel` | `lib/common/widgets/property_control_panel.dart` | ❌ 不用 | 本 sim 控制面板是固定 3 复选框 + 2 按钮，非 scenario 驱动 |
| `TimeControlBar` | `lib/common/widgets/time_control_bar.dart` | ❌ 不用 | 无时间步进 |
| `SimulationClock` | `lib/common/simulation_clock.dart` | ❌ 不用 | 无连续 tick（温度由拖拽离散改变，无动画） |
| `Chart` | `lib/common/chart/` | ⚠️ 待评估 | 本 sim 图表是高度定制的（对数轴 + 电磁波谱标签 + 缩放），可能需要自绘 |

**G1 自检结论**：本 sim 用 `NineGridLayout`（强制）；其余 L0 控件因 sim 特性不适用，已逐项说明不用理由。

### 1.5 屏幕适配硬约束（§七 L0-1~L0-4）

| 条款 | 要求 | 本 sim 落地 |
|---|---|---|
| L0-1 主图水平居中 | `Center` 包裹主图 | 图表作为 center 格内容，由 NineGridLayout 天然居中 |
| L0-2 响应式无溢出 | `flutter analyze` 无 layout warning | 用 `LayoutBuilder` 读取格子尺寸 |
| L0-3 主图随视口缩放 | `LayoutBuilder` / `MediaQuery` | 图表 Painter 读取格子实际尺寸自适应 |
| L0-4 九宫格强制 | `NineGridLayout` | 主屏基于 NineGridLayout |

### 1.6 架构分层（`docs/knowledge/kratos/architecture/overview.md`）

工程遵循 MVC + 不可变状态 + copyWith + 纯函数 Solver：

```
Screen（StatefulWidget 持 Model）
  ↓ ListenableBuilder
Model（ChangeNotifier / ValueNotifier）
  ↓ 调用
Solver（纯静态方法，无副作用）
  ↓ 返回
RenderData（不可变值对象）
  ↓ 传入
Painter（CustomPainter，只读 RenderData）
```

**Painter 不改业务状态**（`docs/knowledge/kratos/conventions/add-custom-painter.md`）。

### 1.7 配置化要求（§二 原则 4）

本 sim 的 Intrinsic 参数（温度范围、预设温度点、波长常量、Planck 常量等）将写入 `blackbody_constants.dart` 静态常量类。由于本 sim 是**单屏固定场景**（无 scenario 切换、无 JSON 配置需求），不创建 scenario JSON / schema / prompt。

---

## 二、PhET Blackbody Spectrum 源码结构

### 2.1 源码根目录

```
phet sourses/blackbody-spectrum-main/blackbody-spectrum-main/
├── js/
│   ├── BlackbodyConstants.js          ← 全局常量
│   ├── BlackbodySpectrumStrings.ts    ← 字符串键
│   ├── blackbodySpectrum.js           ← sim 注册入口
│   ├── blackbody-spectrum-main.js     ← 主入口
│   ├── blackbody-spectrum/
│   │   ├── BlackbodySpectrumScreen.js ← Screen（Model + View 工厂）
│   │   ├── model/
│   │   │   ├── BlackbodySpectrumModel.js  ← 主 Model（3 个 Body + 3 个 bool）
│   │   │   └── BlackbodyBodyModel.js      ← 单 Blackbody（温度 + 物理计算）
│   │   └── view/
│   │       ├── BlackbodySpectrumScreenView.js  ← 主 View（布局）
│   │       ├── BlackbodySpectrumThermometer.js  ← 温度计 + 拖拽 thumb
│   │       ├── TriangleSliderThumb.js            ← 三角 thumb + cueing arrows
│   │       ├── GraphDrawingNode.js               ← 图表容器（曲线 + 轴 + 缩放）
│   │       ├── ZoomableAxesView.js               ← 坐标轴 + 刻度 + EM 谱标签
│   │       ├── GraphValuesPointNode.js           ← 可拖动数值点
│   │       ├── BGRAndStarDisplay.js              ← RGB 圆 + 星形 + 光晕
│   │       ├── BlackbodySpectrumControlPanel.js  ← 复选框 + 保存/擦除按钮 + 强度显示
│   │       ├── SavedGraphInformationPanel.js      ← 保存图温度列表面板
│   │       ├── GenericCurveShape.js               ← 示意曲线 Shape
│   │       └── BlackbodyColors.js                ← 配色（default/projector）
├── assets/                            ← 仅截图（非运行时）
├── images/license.json                ← license 元数据
├── blackbody-spectrum_en.html
├── blackbody-spectrum-strings_en.json ← 英文字符串
├── package.json
└── README.md
```

### 2.2 核心 Model 结构

**`BlackbodySpectrumModel`**（`model/BlackbodySpectrumModel.js:16-87`）：
- `mainBody: BlackbodyBodyModel`（温度初始 = `sunTemperature = 5800K`）
- `savedBodyOne: BlackbodyBodyModel`（温度初始 = `null`，表示未保存）
- `savedBodyTwo: BlackbodyBodyModel`（温度初始 = `null`）
- `graphValuesVisibleProperty: BooleanProperty`（初始 `false`）
- `intensityVisibleProperty: BooleanProperty`（初始 `false`）
- `labelsVisibleProperty: BooleanProperty`（初始 `false`）
- `wavelengthMax: number = 3000`（nm，最大显示波长，随水平缩放变化）
- 方法：`reset()` / `saveMainBody()` / `clearSavedGraphs()`

**`BlackbodyBodyModel`**（`model/BlackbodyBodyModel.js:27-234`）：
- `temperatureProperty: Property<number|null>`
- 物理计算（纯函数，基于温度）：
  - `getSpectralPowerDensityAt(λ)` — Planck 定律
  - `getPeakWavelength()` — Wien 位移定律
  - `getTotalIntensity()` — Stefan-Boltzmann 定律
  - `getRenormalizedTemperature()` — 星尺寸归一化
  - `getRenormalizedColorIntensity(λ)` — RGB 通道 0-255
  - `getRedColor()` / `getGreenColor()` / `getBlueColor()` — 单通道颜色
  - `getStarColor()` — 三通道合成星色
  - `getGlowingStarHaloRadius()` / `getGlowingStarHaloColor()` — 光晕

### 2.3 核心 View 结构

**`BlackbodySpectrumScreenView`**（`view/BlackbodySpectrumScreenView.js:37-127`）布局锚点：

| 元素 | 锚点（layoutBounds 坐标） |
|---|---|
| 图表（GraphDrawingNode） | `left=10, bottom=maxY-10` |
| Reset 按钮 | `right=maxX-10, bottom=maxY-10` |
| 温度计 | `right=maxX-10, top=温度标签下方` |
| 温度文本 | `centerX=温度计中心, top=标签下方` |
| 温度标题 | `centerX=温度计中心, top=15` |
| 控制面板 | `right=温度计左侧-20, top=标题中心` |
| 保存图面板 | `centerX=控制面板中心, top=控制面板底部+55` |
| RGB+星 显示 | `left=225`（经验值） |

### 2.4 字符串清单（`blackbody-spectrum-strings_en.json`）

| key | 值 |
|---|---|
| `blackbody-spectrum.title` | Blackbody Spectrum |
| `spectralPowerDensityLabel` | Spectral Power Density (MW/m²/µm) |
| `wavelengthLabel` | Wavelength (µm) |
| `subtitleLabel` | 1 µm = 1000 nm |
| `b` / `g` / `r` | B / G / R |
| `siriusA` / `sun` / `lightBulb` / `earth` | Sirius A / Sun / Light Bulb / Earth |
| `blackbodyTemperature` | Blackbody Temperature |
| `kelvinUnits` | K |
| `graphValues` / `intensity` / `labels` | Graph Values / Intensity / Labels |
| `intensityUnitsLabel` | {{intensity}} W/m² |
| `xRay` / `ultraviolet` / `visible` / `infrared` | X-Ray / Ultraviolet / Visible / Infrared |

---

## 三、迁移架构设计

### 3.1 目录结构（遵循 curve_fitting 同构模式）

```
lib/blackbody_spectrum/
├── blackbody_spectrum_constants.dart      ← BlackbodyConstants.js 等价
├── blackbody_spectrum_strings.dart        ← 字符串
├── blackbody_spectrum_colors.dart         ← BlackbodyColors.js 等价
├── model/
│   ├── blackbody_body_model.dart          ← BlackbodyBodyModel.js 等价（纯物理计算）
│   └── blackbody_spectrum_model.dart      ← BlackbodySpectrumModel.js 等价（ChangeNotifier）
├── render/
│   └── blackbody_render_data.dart         ← 不可变渲染数据（曲线点 + 颜色 + 文本）
├── painters/
│   ├── spectrum_graph_painter.dart        ← GraphDrawingNode 等价（曲线 + 轴 + EM 谱）
│   ├── thermometer_painter.dart           ← ThermometerNode + TriangleSliderThumb 等价
│   ├── bgr_star_painter.dart              ← BGRAndStarDisplay 等价
│   └── saved_graph_panel_painter.dart     ← GenericCurveShape 等价（示意曲线）
└── screens/
    ├── blackbody_spectrum_home.dart       ← StatefulWidget 入口（同 CurveFittingHome）
    └── blackbody_spectrum_screen_body.dart ← 九宫格 body 布局
```

### 3.2 数据流

```
BlackbodySpectrumHome（StatefulWidget）
  ├─ BlackbodySpectrumModel（ChangeNotifier）
  │   ├─ mainBody: BlackbodyBodyModel（温度 ValueNotifier<double?>）
  │   ├─ savedBodyOne / savedBodyTwo（同上）
  │   ├─ graphValuesVisible / intensityVisible / labelsVisible（ValueNotifier<bool>）
  │   └─ wavelengthMax（ValueNotifier<double>）
  │
  ↓ 模型变化 → 构建 RenderData
  │
  ├─ BlackbodyRenderData（不可变）
  │   ├─ mainCurvePoints: List<Offset>
  │   ├─ savedCurveOnePoints / savedCurveTwoPoints
  │   ├─ intensityPathPoints
  │   ├─ starColor / redColor / greenColor / blueColor
  │   ├─ haloRadius / haloColor
  │   ├─ temperatureText / intensityText / wavelengthText / spdText
  │   └─ axisLabels / emSpectrumLabels
  │
  ↓ RenderData 传入 Painter（只读）
  │
  └─ Painters（CustomPainter）
      ├─ SpectrumGraphPainter（图表主区）
      ├─ ThermometerPainter（温度计 + thumb）
      ├─ BGRStarPainter（RGB + 星）
      └─ SavedGraphPanelPainter（示意曲线）
```

### 3.3 交互映射

| PhET 交互 | 源码 | Flutter 实现 |
|---|---|---|
| 温度计 thumb 拖拽 | `BlackbodySpectrumThermometer.js:91-108` | `GestureDetector.onVerticalDragUpdate` → 计算 y → 温度 |
| 数值点水平拖拽 | `GraphValuesPointNode.js:117-139` | `GestureDetector.onHorizontalDragUpdate` → x → 波长 |
| 保存按钮 | `ControlPanel.js:90-92` | `IconButton(onTap: model.saveMainBody)` |
| 擦除按钮 | `ControlPanel.js:102-104` | `IconButton(onTap: model.clearSavedGraphs)` |
| 3 个复选框 | `ControlPanel.js:119-121` | `Checkbox(value:..., onChanged:...)` |
| 缩放按钮 × 4 | `GraphDrawingNode.js:121-152` | `IconButton` × 4（水平 ± / 垂直 ±） |
| Reset All | `ScreenView.js:84-92` | `FilledButton(onPressed: model.reset)` |

### 3.4 九宫格布局映射

| 九宫格位 | PhET 对应元素 | 说明 |
|---|---|---|
| `center` | 图表（GraphDrawingNode） | 主画面，面积 ≥ 70% |
| `topRight` | 温度计 + 温度文本 + 标题 | 贴右上 |
| `midRight` | 控制面板 + 保存图面板 | 贴右中 |
| `bottomRight` | Reset 按钮 | 贴右下 |
| `topLeft` | RGB + 星 显示 | 原始 `left=225` 映射到左上 |
| `bottomCenter` / `bottomLeft` | 空 | 由 NineGridLayout 自动均分 |

---

## 四、开工自检表通过记录

> `.codebuddy/rules/80-kratos-sim-checklist.mdc` 逐条

- ✅ §一 开工必读：已读 overview / shared-abstraction-plan / edd-template（本次为简迁移，复用 curve_fitting 同构模式，不另出 EDD）
- ✅ §二 原则 1 MVC：model / painters / screens 三层目录已规划
- ✅ §二 原则 2 组件化：一元件一 Painter（图表 / 温度计 / RGB星 / 保存图面板 各自独立）
- ✅ §二 原则 3 通用化 G1：NineGridLayout 复用；其余 L0 不适用已说明
- ✅ §二 原则 4 配置化：常量入 `blackbody_spectrum_constants.dart`；无 scenario JSON（单屏固定场景）
- ✅ §四 EDD 版本：本次为 PhET 直接迁移（非新设计），复用 curve_fitting 同构模式，不另出 EDD
- ✅ §七 L0-1~L0-4：见 §1.5 落地表

---

*Discovery 完成时间：2026-09-07*
