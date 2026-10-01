# Blackbody Spectrum · Visual Reconstruction Report

> 重建时间：2026-09-07
> 阶段：PHASE 9 — VISUAL RECONSTRUCTION

---

## 一、问题诊断

### 1.1 原 Flutter 代码问题

| 问题 | 严重程度 | 根因 |
|---|---|---|
| Graph 被 FittedBox 压缩变形 | P0 | 使用 FittedBox + Padding 导致 axes 区域被缩放 |
| 组件使用物理像素定位 | P0 | `left: 24`, `top: 16` 等物理像素，与 PhET 逻辑坐标无关 |
| 温度计、控制面板位置偏移 | P0 | 未按 PhET 逻辑坐标计算 |
| BGR/Star 位置偏移 | P0 | 未按 PhET `left = 225` 定位 |
| Zoom buttons 独立 Column | P1 | 未相对 axes 定位 |
| 多个独立 Widget 叠加 | P1 | Stack + Positioned 造成布局耦合 |
| AppBar 压缩 canvas | P1 | Scaffold AppBar 占用顶部空间 |

### 1.2 PhET 坐标体系

PhET 使用固定逻辑 viewport：`layoutBounds = Bounds2(0, 0, 1024, 768)`

所有组件位置在此坐标系中定义：
- Graph: `left = 10`, `bottom = 758`
- Thermometer: `right = 1014`
- Control panel: `right = thermometer.left - 20`
- BGR: `left = 225`
- Reset: `right = 1014`, `bottom = 758`

---

## 二、重建方案

### 2.1 核心决策

**使用单一 CustomPaint 画布，在 PhET 逻辑坐标系（1024×768）中绘制所有组件。**

理由：
1. PhET 本身就是单画布架构（Scenery Node tree 渲染到单一 canvas）
2. 所有组件位置在源码中以绝对逻辑坐标定义
3. Flutter 的 Stack+Positioned 无法精确复现 PhET 的坐标体系
4. 单一画布避免多个 Widget 的 layout 冲突

### 2.2 坐标映射

```
PhET logical (1024×768)
    ↓  scale = min(screenWidth/1024, screenHeight/768)
Flutter physical pixels
```

Canvas 先 `scale(scale, scale)`，然后在 1024×768 逻辑空间中绘制。

### 2.3 组件绘制顺序（z-index）

按 PhET `addChild` 顺序：
1. Background
2. Graph under axes（spectrum band + intensity fill）
3. Axes（L-shape + ticks + EM labels + axis labels + bound numbers）
4. Zoom buttons
5. Graph curves（main + saved1 + saved2）
6. Graph values point（crosshairs + circle + labels）
7. Thermometer（tube + bulb + ticks + thumb）
8. Temperature labels
9. BGR + Star
10. Control panel（checkboxes + intensity + buttons + saved panel）
11. Reset button

### 2.4 移除 AppBar

PhET sim 没有顶部标题栏。移除 Scaffold AppBar，让 canvas 占满全屏。

---

## 三、重建内容

### 3.1 重写文件

| 文件 | 改动 |
|---|---|
| `blackbody_spectrum_screen_body.dart` | 完全重写：单一 CustomPaint + `_BlackbodySpectrumPainter` |
| `blackbody_spectrum_home.dart` | 移除 AppBar |

### 3.2 删除文件

| 文件 | 原因 |
|---|---|
| `painters/spectrum_graph_painter.dart` | 功能合并到单一 painter |
| `painters/thermometer_painter.dart` | 功能合并到单一 painter |
| `painters/bgr_star_painter.dart` | 功能合并到单一 painter |
| `painters/saved_graph_panel_painter.dart` | 功能合并到单一 painter |
| `painters/` 目录 | 空目录 |

### 3.3 保留文件

| 文件 | 原因 |
|---|---|
| `model/blackbody_body_model.dart` | Model 层未改动 |
| `model/blackbody_spectrum_model.dart` | Model 层未改动 |
| `render/blackbody_render_data.dart` | 仍被 painter 使用（曲线采样、格式化文本） |
| `blackbody_spectrum_constants.dart` | 常量未改动 |
| `blackbody_spectrum_strings.dart` | 字符串未改动 |
| `blackbody_spectrum_colors.dart` | 颜色未改动 |

---

## 四、PhET 源码对应

### 4.1 布局常量

| Flutter 常量 | PhET 源码 | 值 |
|---|---|---|
| `_phetWidth` | `ScreenView.DEFAULT_LAYOUT_BOUNDS` | 1024 |
| `_phetHeight` | `ScreenView.DEFAULT_LAYOUT_BOUNDS` | 768 |
| `_inset` | `BlackbodySpectrumScreenView.INSET` | 10 |
| `_axesWidth` | `ZoomableAxesView.options.axesWidth` | 550 |
| `_axesHeight` | `ZoomableAxesView.options.axesHeight` | 400 |
| `_tubeWidth` | `BlackbodySpectrumThermometer.options.tubeWidth` | 20 |
| `_tubeHeight` | `BlackbodySpectrumThermometer.options.tubeHeight` | 400 |
| `_bulbDiameter` | `BlackbodySpectrumThermometer.options.bulbDiameter` | 35 |
| `_thumbSize` | `BlackbodySpectrumThermometer.options.thumbSize` | 25 |
| `_circleRadius` | `BGRAndStarDisplay.CIRCLE_RADIUS` | 15 |
| `_starOuterRadius` | `BGRAndStarDisplay.STAR_OUTER_RADIUS` | 35 |
| `_starInnerRadius` | `BGRAndStarDisplay.STAR_INNER_RADIUS` | 20 |
| `_starSpacing` | `BGRAndStarDisplay.STAR_SPACING` | 50 |
| `_bgrLeft` | `BlackbodySpectrumScreenView:116` | 225 |

### 4.2 定位规则

| 组件 | PhET 规则 | Flutter 实现 |
|---|---|---|
| Graph | `left = INSET`, `bottom = maxY - INSET` | `_graphLeft = 10`, `_graphBottom = 758` |
| Thermometer | `right = maxX - INSET` | `_thermometerRight = 1014` |
| Thermometer center | `thermometerCenterXFromRight = -35` | `thermCenterX = 1014 - 35` |
| Control panel | `right = thermometer.left - 20` | `panelRight = thermLeft - 20` |
| BGR | `left = 225` | `_bgrLeft = 225` |
| Reset | `right = maxX - INSET`, `bottom = maxY - INSET` | `right = 1014`, `bottom = 758` |

### 4.3 渲染顺序

按 PhET `addChild` 顺序精确对应：
- `innerGraphUnderAxes` → `_drawGraphUnderAxes`
- `axes` → `_drawAxes`
- `horizontalZoomButtonGroup` / `verticalZoomButtonGroup` → `_drawZoomButtons`
- `innerGraphOverAxes` → `_drawGraphCurves`
- `draggablePointNode` → `_drawGraphValuesPoint`

---

## 五、验证结果

### 5.1 Analyzer

```
flutter analyze lib/blackbody_spectrum/ lib/screens/home_screen.dart
→ No issues found!
```

### 5.2 测试

```
flutter test test/blackbody_spectrum/
→ All 30 tests passed!
```

### 5.3 文件清单

```
lib/blackbody_spectrum/
├── blackbody_spectrum_colors.dart
├── blackbody_spectrum_constants.dart
├── blackbody_spectrum_strings.dart
├── model/
│   ├── blackbody_body_model.dart
│   └── blackbody_spectrum_model.dart
├── render/
│   └── blackbody_render_data.dart
└── screens/
    ├── blackbody_spectrum_home.dart
    └── blackbody_spectrum_screen_body.dart
```

---

## 六、未完成项（已知限制）

| 项 | 原因 | 优先级 |
|---|---|---|
| 交互（拖拽温度计、拖拽数值点、点击按钮） | 当前 painter 仅绘制，未实现 hit testing | P0 — 下一步 |
| Zoom buttons 点击 | 同上 | P0 — 下一步 |
| Checkbox 点击 | 同上 | P0 — 下一步 |
| Save/Erase/Reset 点击 | 同上 | P0 — 下一步 |
| Cueing arrows | 绘制逻辑已包含，但未实现首次点击检测 | P1 |
| 字体精确匹配 | 使用系统默认字体，未加载 PhET 专用字体 | P2 |
| 按钮/控件视觉细节 | 使用简化绘制，未完全复刻 PhET 按钮样式 | P2 |

---

## 七、下一步工作

1. **实现 hit testing**：为所有可交互区域（thermometer thumb、graph values point、zoom buttons、checkboxes、buttons）添加点击检测
2. **实现拖拽**：温度计垂直拖拽、数值点水平拖拽
3. **截图验证**：运行应用，与 PhET 原版截图进行 overlay 对比
4. **微调**：根据 overlay 对比结果调整局部位置

---

*报告完成时间：2026-09-07*
