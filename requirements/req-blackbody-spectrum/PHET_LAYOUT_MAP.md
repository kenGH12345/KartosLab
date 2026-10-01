# PhET Layout Map — Blackbody Spectrum

> 从 PhET 源码直接提取的坐标体系，用于 Flutter 视觉重建。

---

## 一、PhET 坐标系基础

### 1.1 ScreenView layoutBounds

PhET `ScreenView` 默认 `layoutBounds = Bounds2(0, 0, 1024, 768)`。

Blackbody Spectrum 未覆盖 `layoutBounds`，使用默认值。

**结论**：PhET 逻辑坐标系 = 1024×768 固定 viewport。

### 1.2 坐标方向

- PhET Scenery：`x` 向右，`y` 向下（canvas 风格）
- Flutter：`x` 向右，`y` 向下（相同）
- PhET 图表内部：y 轴向上 = 负 y 方向

---

## 二、ScreenView 级布局（BlackbodySpectrumScreenView.js:102-116）

```
const INSET = 10;
const TEMPERATURE_LABEL_SPACING = 5;
```

| Component | 定位规则 | 逻辑坐标（1024×768） |
|---|---|---|
| **graphDrawingNode** | `left = INSET` | x = 10 |
| | `bottom = layoutBounds.maxY - INSET` | y = 768 - 10 = 758 |
| **resetAllButton** | `right = layoutBounds.maxX - INSET` | x = 1024 - 10 = 1014 |
| | `bottom = layoutBounds.maxY - INSET` | y = 758 |
| **thermometerNode** | `right = layoutBounds.maxX - INSET` | x = 1014 |
| **thermometerText** | `centerX = thermometerNode.right + thermometerNode.thermometerCenterXFromRight` | 见 3.2 |
| | `top = INSET + TEMPERATURE_LABEL_SPACING` | y = 10 + 5 = 15 |
| **temperatureText** | `centerX = thermometerText.centerX` | 同上 |
| | `top = thermometerText.bottom + TEMPERATURE_LABEL_SPACING` | y = 15 + textHeight + 5 |
| **thermometerNode** | `top = temperatureText.bottom + TEMPERATURE_LABEL_SPACING` | y = 15 + textHeight + 5 + textHeight + 5 |
| **controlPanel** | `right = thermometerNode.left - 20` | x = thermometerNode.left - 20 |
| | `top = thermometerText.centerY` | y = thermometerText.centerY |
| **savedGraphsPanel** | `centerX = controlPanel.centerX` | 同 controlPanel.centerX |
| | `top = controlPanel.bottom + 55` | y = controlPanel.bottom + 55 |
| **bgrAndStarDisplay** | `left = 225` | x = 225 |

---

## 三、Thermometer 尺寸（BlackbodySpectrumThermometer.js:49-67）

```
bulbDiameter: 35
tubeWidth: 20
tubeHeight: 400
glassThickness: 5
lineWidth: 3
thumbSize: 25
```

### 3.1 ThermometerNode 基类坐标

`ThermometerNode` 将 tube 放在原点上方（y 为负）：
- tube 范围：y ∈ [-tubeHeight, 0] = [-400, 0]
- bulb 中心：y = bulbDiameter/2 = 17.5（在 tube 下方）
- 整个 thermometer 高度：tubeHeight + bulbDiameter = 435

### 3.2 thermometerCenterXFromRight

```
this._thermometerCenterXFromRight = -this.triangleNode.width - options.tubeWidth / 2;
```

triangleNode 旋转 -90° 后：
- 原始 size = Dimension2(25, 25)
- 旋转后 width = 25, height = 25
- triangleNode.left = tubeWidth/2 = 10
- `_thermometerCenterXFromRight` = -25 - 10 = **-35**

即：温度计中心在 node 右边界左侧 35px 处。

### 3.3 Thumb 位置

```
this.triangleNode.rotation = -Math.PI / 2;
this.triangleNode.left = options.tubeWidth / 2;  // = 10
this.triangleNode.centerY = -this.temperatureToYPos(TICK_MARKS[1].temperature);
```

TICK_MARKS[1] = Sun (5800K)，即初始位置在 Sun 温度处。

温度→Y 的映射（ThermometerNode 基类）：
- yPos = -((T - minT) / (maxT - minT)) * tubeHeight
- 5800K: yPos = -((5800-200)/(11000-200)) * 400 ≈ -207

所以 thumb 初始 centerY ≈ 207（在 node 局部坐标中）。

---

## 四、Graph 尺寸（ZoomableAxesView.js:71-73）

```
axesWidth: 550
axesHeight: 400
```

### 4.1 Axes 路径

```
moveTo(horizontalAxisLength, -5)
lineTo(horizontalAxisLength, 0)
lineTo(0, 0)
lineTo(0, -verticalAxisLength)
lineTo(5, -verticalAxisLength)
```

即：L 形 + 两端小 hook。
- 原点 (0, 0)
- x 轴终点 (550, 0)
- y 轴终点 (0, -400)

### 4.2 Clip Shape

```
Shape.rectangle(0, 1, horizontalAxisLength, -verticalAxisLength - 1)
```

即：Rect(0, 1, 550, -401)，y 向下为负。

### 4.3 坐标变换

```javascript
// wavelength → viewX
wavelengthToViewX(wavelength) = linear(0, wavelengthMax, 0, 550, wavelength)

// spd → viewY  
spectralPowerDensityToViewY(spd) = -1e33 * linear(0, verticalZoom, 0, 400, spd)
```

### 4.4 Zoom Buttons（GraphDrawingNode.js:121-152）

```
ZOOM_BUTTON_ICON_RADIUS = 8
ZOOM_BUTTON_SPACING = 10
ZOOM_BUTTON_AXES_MARGIN = 35
```

水平 zoom buttons：
```
horizontalZoomButtonGroup.centerX = axesPath.right + ZOOM_BUTTON_ICON_RADIUS  // = 550 + 8 = 558
horizontalZoomButtonGroup.top = axesPath.bottom + ZOOM_BUTTON_AXES_MARGIN     // = 0 + 35 = 35
```

垂直 zoom buttons：
```
verticalZoomButtonGroup.centerX = axesPath.left - ZOOM_BUTTON_ICON_RADIUS * 2  // = 0 - 16 = -16
verticalZoomButtonGroup.bottom = axesPath.top - ZOOM_BUTTON_AXES_MARGIN        // = -400 - 35 = -435
```

### 4.5 Wavelength Spectrum Node

```
wavelengthSpectrumNode.centerY = axesPath.centerY  // = -200
wavelengthSpectrumNode.left = ultravioletPosition   // = wavelengthToViewX(380)
```

Size = Dimension2(spectrumWidth, verticalAxisLength) = (infraredPosition - ultravioletPosition, 400)

---

## 五、BGR + Star 尺寸（BGRAndStarDisplay.js:27-34）

```
CIRCLE_RADIUS = 15
STAR_INNER_RADIUS = 20
STAR_OUTER_RADIUS = 35
STAR_NUMBER_POINTS = 9
STAR_SPACING = 50
```

### 5.1 布局

```
circleBlue.centerY = STAR_SPACING                    // = 50
circleGreen.centerX = circleBlue.centerX + STAR_SPACING  // = 50 + 50 = 100
circleRed.centerX = circleGreen.centerX + STAR_SPACING   // = 100 + 50 = 150

starPath.left = circleRed.right + STAR_SPACING       // = 150 + 15 + 50 = 215
starPath.centerY = circleBlue.centerY                // = 50

// Labels
circleBlueLabel.centerY = circleBlue.top + STAR_SPACING  // = 50 - 15 + 50 = 85
```

### 5.2 整体尺寸

- 宽度：starPath.right = 215 + 2*35 = 285（粗略）
- 高度：约 100（从 top 到 label bottom）

---

## 六、Control Panel（BlackbodySpectrumControlPanel.js）

```
xMargin: 10
yMargin: 15
lineWidth: 1
fill: 'rgba(0,0,0,0)'
stroke: panelStrokeProperty
maxWidth: 140
```

### 6.1 内部结构

- 3 个 Checkbox（VBox, spacing=15, align=left）
- Intensity text box（条件显示）
- HSeparator
- 2 个 buttons（HBox, spacing=15）

### 6.2 Save/Erase Buttons

```
BUTTON_ICON_WIDTH = 50
baseColor: PhetColorScheme.BUTTON_YELLOW（save）
EraserButton（erase）
```

---

## 七、Saved Graph Panel（SavedGraphInformationPanel.js:34-41）

```
panelFill: 'rgba(0,0,0,0)'
panelStroke: panelStrokeProperty
minWidth: 140
maxWidth: 140
spacing: 10
curveWidth: 50
curveLineWidth: 5
savedCurveStroke: 'gray'
```

---

## 八、Graph Values Point（GraphValuesPointNode.js:41-66）

```
circleOptions: { radius: 5, fill: graphValuesPoint }
dashedLineOptions: { stroke: graphValuesDashedLine, lineDash: [4, 4] }
valueTextOptions: { fill: graphValuesLabels, font: PhetFont(18), maxWidth: 50 }
arrowSpacing: 30
arrowLength: 20
arrowOptions: { fill: '#64dc64', headHeight: 13, headWidth: 12, tailWidth: 6 }
labelOffset: 5
```

---

## 九、Flutter 映射策略

### 9.1 坐标缩放

PhET 1024×768 → Flutter 可用区域

策略：保持 aspect ratio 4:3，按比例缩放。

scale = min(screenWidth/1024, screenHeight/768)

所有 PhET 逻辑坐标 × scale = Flutter 像素坐标。

### 9.2 Anchor 定义

```dart
// PhET 逻辑坐标（1024×768）
const double PHET_WIDTH = 1024;
const double PHET_HEIGHT = 768;
const double INSET = 10;

// Graph
const double GRAPH_LEFT = INSET;                    // 10
const double GRAPH_BOTTOM = PHET_HEIGHT - INSET;    // 758

// Thermometer
const double THERMOMETER_RIGHT = PHET_WIDTH - INSET;  // 1014

// Control Panel
const double CONTROL_PANEL_RIGHT_MARGIN = 20;  // from thermometer left

// BGR
const double BGR_LEFT = 225;

// Reset
const double RESET_RIGHT = PHET_WIDTH - INSET;   // 1014
const double RESET_BOTTOM = PHET_HEIGHT - INSET; // 758
```

### 9.3 渲染顺序（z-index）

PhET 子节点添加顺序（`addChild` 顺序 = 渲染顺序，后添加的在上面）：

```
1. innerGraphUnderAxes（spectrum + intensity）
2. axes（坐标轴 + 刻度 + 标签）
3. horizontalZoomButtonGroup
4. verticalZoomButtonGroup
5. innerGraphOverAxes（main + saved curves）
6. draggablePointNode
```

---

## 十、当前 Flutter 代码问题诊断

| 问题 | PhET 源码 | 当前 Flutter | 修复方向 |
|---|---|---|---|
| Graph 被 FittedBox 压缩 | 固定 550×400 axes | FittedBox + Padding 导致缩放 | 移除 FittedBox，使用固定比例 |
| Graph 位置不对 | left=10, bottom=758 | 复杂 Stack 定位 | 使用 CustomPaint 覆盖整个 body，内部按 PhET 坐标绘制 |
| 温度计位置 | right=1014 | top=16, right=24（像素） | 按 PhET 逻辑坐标定位 |
| Control panel | right=thermometer.left-20 | 固定 right=24 | 按 PhET 逻辑坐标定位 |
| BGR | left=225 | left=24 | 按 PhET 逻辑坐标定位 |
| Zoom buttons | 相对 axes 定位 | 独立 Column | 相对 axes 定位 |
| 整体比例 | 4:3 固定 | 被 SafeArea/AppBar 压缩 | 使用全屏 body，无 AppBar 或透明 AppBar |
