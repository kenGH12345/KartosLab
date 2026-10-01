# Blackbody Spectrum · Source Analysis

> 取证对象：`phet sourses/blackbody-spectrum-main/blackbody-spectrum-main/js/`
> 引用约定：`[来源: phet/<相对路径>:<行号>]`

---

## 一、Model 层

### 1.1 BlackbodySpectrumModel（主 Model）

`[来源: phet/js/blackbody-spectrum/model/BlackbodySpectrumModel.js:16-87]`

**职责**：持有 3 个 BlackbodyBodyModel + 3 个可见性布尔 + 最大波长。

**状态字段**：

| 字段 | 类型 | 初始值 | 说明 |
|---|---|---|---|
| `graphValuesVisibleProperty` | `BooleanProperty` | `false` | 数值点是否可见 |
| `intensityVisibleProperty` | `BooleanProperty` | `false` | 强度面积是否可见 |
| `labelsVisibleProperty` | `BooleanProperty` | `false` | EM 谱标签是否可见 |
| `mainBody` | `BlackbodyBodyModel` | 温度=`sunTemperature=5800` | 主曲线 |
| `savedBodyOne` | `BlackbodyBodyModel` | 温度=`null` | 第一个保存曲线（null=未保存） |
| `savedBodyTwo` | `BlackbodyBodyModel` | 温度=`null` | 第二个保存曲线 |
| `wavelengthMax` | `number` | `3000` | 最大显示波长（nm），随水平缩放变化 |

**方法**：

| 方法 | 源码行 | 行为 |
|---|---|---|
| `reset()` | `62-68` | 重置 3 个 bool + mainBody 温度 + 清空保存图 |
| `saveMainBody()` | `74-77` | savedTwo←savedOne, savedOne←main（FIFO 队列，最多 2 条） |
| `clearSavedGraphs()` | `83-86` | savedOne + savedTwo 都 reset（温度→null） |

**关键设计**：保存图用 FIFO 队列（非数组），源码注释说明"for simplicity with phet-io"（`BlackbodySpectrumModel.js:47-48`）。

### 1.2 BlackbodyBodyModel（单 Blackbody 物理模型）

`[来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:27-234]`

**状态**：
- `temperatureProperty: Property<number|null>`（null 表示该 body 不存在）

**温度校验**：`assert` 模式，温度非 null 时必须在 `[minTemperature=200, maxTemperature=11000]` 范围内（`BlackbodyBodyModel.js:46-52`）。

**物理计算（纯函数，基于当前温度）**：

#### Planck 光谱功率密度
`[来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:75-85]`

```
getSpectralPowerDensityAt(wavelength):
  if wavelength == 0: return 0
  A = 3.74192e-16   // 2πhc²，单位 W·m²
  B = 1.438770e7    // hc/k，单位 nm·K
  return A / (wavelength^5 * (e^(B/(wavelength*T)) - 1))
```

- 输入：波长（nm）
- 输出：光谱功率密度（MW/m²/µm）
- 边界：`wavelength=0` 返回 0（避免除零）

#### Wien 位移定律（峰值波长）
`[来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:144-148]`

```
getPeakWavelength():
  WIEN_CONSTANT = 2.897773e-3   // b，单位 m·K
  return 1e9 * WIEN_CONSTANT / T   // 输出 nm
```

- 前置：`assert T > 0`
- 输出：峰值波长（nm）

#### Stefan-Boltzmann 总强度
`[来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:130-133]`

```
getTotalIntensity():
  σ = 5.670373e-8   // W/(m²·K⁴)
  return σ * T^4
```

- 输出：总辐射强度（W/m²）

#### 归一化温度（星尺寸缩放）
`[来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:94-103]`

```
getRenormalizedTemperature():
  powerExponent = 0.5
  draperPoint = 798          // K，低于此温度星几乎不发光
  normalizationScaling = 0.02
  relativeTemp = max(T, draperPoint) - draperPoint
  return 0.02 * relativeTemp^0.5
```

- 用途：驱动星形光晕半径与 alpha
- 设计权衡：`powerExponent=0.5` 用于"minimize scaling of halo at high temperatures"（源码注释）

#### RGB 通道强度（0-255）
`[来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:113-121]`

```
getRenormalizedColorIntensity(wavelength):
  red = getSpectralPowerDensityAt(650)    // 红光波长
  green = getSpectralPowerDensityAt(550)  // 绿光波长
  blue = getSpectralPowerDensityAt(450)   // 蓝光波长
  largest = max(red, green, blue)
  current = getSpectralPowerDensityAt(wavelength)
  boundedT = min(renormalizedTemperature, 1)
  return floor(255 * boundedT * current / largest)
```

- 常量：`RED_WAVELENGTH=650`, `GREEN_WAVELENGTH=550`, `BLUE_WAVELENGTH=450`（`BlackbodyBodyModel.js:21-23`）
- 归一化：以三通道中最大值为基准，保证至少一通道接近 255

#### 颜色获取
`[来源: phet/js/blackbody-spectrum/model/BlackbodyBodyModel.js:157-232]`

| 方法 | 返回 | 公式 |
|---|---|---|
| `getRedColor()` | `Color(intensity, 0, 0, 1)` | intensity = `getRenormalizedColorIntensity(650)` |
| `getGreenColor()` | `Color(0, intensity, 0, 1)` | intensity = `getRenormalizedColorIntensity(550)` |
| `getBlueColor()` | `Color(0, 0, intensity, 1)` | intensity = `getRenormalizedColorIntensity(450)` |
| `getStarColor()` | `Color(r, g, b, 1)` | 三通道合成 |
| `getGlowingStarHaloColor()` | `starColor.withAlpha(linear(0,1,0,0.3, renormT))` | 透明度随温度升 |
| `getGlowingStarHaloRadius()` | `linear(0,2,5,100, renormT)` | 半径 5-100 px |

---

## 二、View 层

### 2.1 BlackbodySpectrumScreenView（主视图布局）

`[来源: phet/js/blackbody-spectrum/view/BlackbodySpectrumScreenView.js:37-127]`

**子节点**（按 addChild 顺序）：
1. `graphDrawingNode` — 图表
2. `controlPanel` — 复选框 + 按钮 + 强度显示
3. `savedGraphsPanel` — 保存图温度列表
4. `thermometerNode` — 温度计 + thumb
5. `thermometerText` — "Blackbody Temperature" 标题
6. `temperatureText` — 当前温度数值
7. `bgrAndStarDisplay` — RGB 圆 + 星
8. `resetAllButton` — Reset 按钮

**布局锚点**（`ScreenView.js:102-116`，layoutBounds 坐标系，原点左上）：

| 元素 | 锚点 |
|---|---|
| 图表 | `left=10`, `bottom=maxY-10` |
| Reset | `right=maxX-10`, `bottom=maxY-10` |
| 温度计 | `right=maxX-10`, `top=温度文本下方` |
| 标题 | `centerX=温度计中心`, `top=15` |
| 温度文本 | `centerX=温度计中心`, `top=标题下方+5` |
| 温度计顶 | `top=温度文本下方+5` |
| 控制面板 | `right=温度计左-20`, `top=标题中心Y` |
| 保存图面板 | `centerX=控制面板centerX`, `top=控制面板底+55` |
| RGB+星 | `left=225` |

**温度文本联动**（`ScreenView.js:75-78`）：温度变化 → `temperatureText.string = "${toFixed(T,0)} K"` → 重新居中。

### 2.2 BlackbodySpectrumThermometer（温度计 + 拖拽 thumb）

`[来源: phet/js/blackbody-spectrum/view/BlackbodySpectrumThermometer.js:40-186]`

**继承**：`ThermometerNode`（scenery-phet 内置）

**配置**（`Thermometer.js:49-69`）：
- `bulbDiameter=35`, `tubeWidth=20`, `tubeHeight=400`
- `majorTickLength=10`, `minorTickLength=5`, `glassThickness=5`, `lineWidth=3`
- `tickSpacingTemperature=500`, `snapInterval=50`
- `zeroLevel='bulbTop'`, `thumbSize=25`

**刻度标签**（`Thermometer.js:33-38`）：

| 标签 | 温度 |
|---|---|
| Sirius A | 9950 K |
| Sun | 5800 K |
| Light Bulb | 3000 K |
| Earth | 250 K |

**拖拽逻辑**（`Thermometer.js:91-108`）：
```
start: 记录 clickYOffset = pointer.y - thumb.y
drag:
  y = pointer.y - clickYOffset
  T = yPosToTemperature(-y)        // y 反转（屏幕 y 向下，温度向上）
  T = roundToInterval(T, 50)       // snap to 50K
  T = clamp(T, 200, 11000)
  temperatureProperty.value = T
  updateThumb()
```

**thumb 初始位置**：`centerY = -temperatureToYPos(TICK_MARKS[1].temperature)` = Sun 温度位置（`Thermometer.js:112`）。

**thumb 旋转**：`-π/2`（三角形原本水平指向，旋转后指向左，对准温度计管）。

### 2.3 TriangleSliderThumb（三角 thumb + cueing arrows）

`[来源: phet/js/blackbody-spectrum/view/TriangleSliderThumb.js:21-99]`

**子节点**：
1. `cueingArrows` — 两个绿色 `ArrowNode`（左右各一），首次点击后隐藏
2. `dashedLinesPath` — 虚线锚定线（thumb 到温度计管）
3. `triangle` — `TriangleNode`（宽=options.size.width, 高=options.size.height）

**默认尺寸**：`Dimension2(30, 15)`（`TriangleSliderThumb.js:31`）。

**颜色**：
- `fill: rgb(50, 145, 184)`（默认蓝）
- `fillHighlighted: rgb(71, 207, 255)`（悬停亮蓝）
- `stroke: BlackbodyColors.triangleStrokeProperty`（default=white）

**交互**：
- `over`（悬停）→ `triangle.fill = fillHighlighted`
- `up`（离开）→ `triangle.fill = fill`
- `down`（点击）→ `cueingArrows.visible = false`

### 2.4 GraphDrawingNode（图表容器）

`[来源: phet/js/blackbody-spectrum/view/GraphDrawingNode.js:35-307]`

**子节点层级**（渲染顺序，后加在上层）：
1. `innerGraphUnderAxes`（被裁剪）
   - `wavelengthSpectrumNode` — 可见光彩虹条
   - `intensityPath` — 强度填充
2. `axes`（`ZoomableAxesView`）
3. `horizontalZoomButtonGroup` — 水平缩放按钮
4. `verticalZoomButtonGroup` — 垂直缩放按钮
5. `innerGraphOverAxes`（被裁剪）
   - `mainGraph` — 主曲线（red colorblind）
   - `primarySavedGraph` — 保存曲线 1（gray 实线）
   - `secondarySavedGraph` — 保存曲线 2（gray 虚线）
6. `draggablePointNode` — 可拖动数值点

**曲线绘制**（`shapeOfBody`, `GraphDrawingNode.js:206-226`）：
```
GRAPH_NUMBER_POINTS = 300
deltaWavelength = wavelengthMax / 299
pointsXOffset = horizontalAxisLength / 299
yCutoff = verticalAxisLength + lineWidth

shape.moveTo(0, 0)
for i = 1 to 299:
  if deltaWavelength*i > peakWavelength && findingPeak:
    yMax = spectralPowerDensityToViewY(spd(peakWavelength))
    shape.lineTo(wavelengthToViewX(peakWavelength), min(yMax, -yCutoff))
    findingPeak = false
  y = spectralPowerDensityToViewY(spd(deltaWavelength*i))
  shape.lineTo(pointsXOffset*i, min(y, -yCutoff))
```

**关键设计**：峰值波长点**强制插入**，保证曲线峰值不被采样漏掉。

**保存曲线**（`updateSavedGraphPaths`, `GraphDrawingNode.js:262-272`）：
- savedBodyOne 温度非 null → `primarySavedGraph.shape = shapeOfBody(savedBodyOne)`
- savedBodyTwo 温度非 null → `secondarySavedGraph.shape = shapeOfBody(savedBodyTwo)`

**强度面积**（`updateGraphPaths`, `GraphDrawingNode.js:237-242`）：
- 复制主曲线 shape → 添加终点回到 x 轴 → fill

**可见光彩虹条**（`GraphDrawingNode.js:103-112, 289-295`）：
- 宽度 = `wavelengthToViewX(780) - wavelengthToViewX(380)`（可见光 380-780nm）
- 高度 = `verticalAxisLength`
- 位置：`left = wavelengthToViewX(380)`, `centerY = axesPath.centerY`

**缩放按钮**（`GraphDrawingNode.js:121-152`）：
- 水平：`applyZoomIn: zoom / horizontalZoomScale(2)`, `applyZoomOut: zoom * 2`
- 垂直：`applyZoomIn: zoom / verticalZoomScale(5)`, `applyZoomOut: zoom * 5`
- 按钮图标半径 8px，间距 10px

### 2.5 ZoomableAxesView（坐标轴 + EM 谱标签）

`[来源: phet/js/blackbody-spectrum/view/ZoomableAxesView.js:61-452]`

**尺寸**：`axesWidth=550`, `axesHeight=400`（`ZoomableAxesView.js:72-73`）。

**坐标轴 Path**（`ZoomableAxesView.js:120-128`）：
```
moveTo(horizontalAxisLength, -5)
lineTo(horizontalAxisLength, 0)
lineTo(0, 0)
lineTo(0, -verticalAxisLength)
lineTo(5, -verticalAxisLength)
```
（L 形 + 两端小钩）

**裁剪 Shape**（`ZoomableAxesView.js:132`）：
```
rectangle(0, 1, horizontalAxisLength, -verticalAxisLength-1)
```

**水平刻度**（`redrawHorizontalTicks`, `ZoomableAxesView.js:270-285`）：
- 间距：`wavelengthPerTick=100` nm
- 小刻度长度 10，大刻度长度 20，每 5 个小刻度 1 个大刻度
- 当 `wavelengthMax > 12000` 时小刻度高度变 0（性能优化）

**EM 谱标签**（`redrawElectromagneticSpectrumLabel`, `ZoomableAxesView.js:291-325`）：

| 区域 | maxWavelength（nm） |
|---|---|
| X-Ray | 10 |
| Ultraviolet | 380 |
| Visible | 780 |
| Infrared | 100000 |

- 只显示 `maxWavelength <= wavelengthMax` 的区域
- 区域宽度 < 20px 时不显示标签（`ELECTROMAGNETIC_SPECTRUM_LABEL_CUTOFF=20`）

**坐标变换**：

| 方法 | 公式 |
|---|---|
| `wavelengthToViewX(λ)` | `linear(0, wavelengthMax, 0, axisW, λ)` |
| `viewXToWavelength(x)` | `linear(0, axisW, 0, wavelengthMax, x)` |
| `spectralPowerDensityToViewY(spd)` | `-1e33 * linear(0, verticalZoom, 0, axisH, spd)` |
| `viewYToSpectralPowerDensity(y)` | `linear(0, axisH, 0, verticalZoom, y) / -1e33` |

**缩放范围**（`ZoomableAxesView.js:183-196`）：
- 水平：`[750, 48000]`，默认 `wavelengthMax=3000`
- 垂直：`[0.00001024, 2500]`，默认 `100.0`

**垂直轴标签格式化**（`update`, `ZoomableAxesView.js:417-435`）：
- `verticalZoom < 0.01` → 科学计数法（mantissa × 10^exp）
- `verticalZoom >= 0.01` → `truncateNum(value, 2, 2)`

### 2.6 GraphValuesPointNode（可拖动数值点）

`[来源: phet/js/blackbody-spectrum/view/GraphValuesPointNode.js:29-262]`

**状态**：
- `wavelengthProperty: NumberProperty`（初始 = `body.peakWavelength`）
- `arrowsVisible: bool`（初始 true，拖拽后 false）

**拖拽**（`GraphValuesPointNode.js:117-139`）：
```
start: 记录 clickXOffset
drag:
  x = pointer.x - clickXOffset
  λ = viewXToWavelength(x)
  λ = clamp(λ, 0, viewXToWavelength(horizontalAxisLength))
  wavelengthProperty.value = λ
  update()
end: arrowsVisible = false
```

**更新逻辑**（`update`, `GraphValuesPointNode.js:168-259`）：
- 圆点位置：`(wavelengthToViewX(λ), spectralPowerDensityToViewY(spd(λ)))`
- 可见性：圆点在轴范围内才可见
- 波长文本：`toFixed(λ/1000, 3)`（nm → µm）
- SPD 文本：
  - `spd * 1e33 < 0.01 && != 0` → 科学计数法
  - 否则 `toPrecision(4)`
- 虚线十字：垂直 + 水平，跟随圆点
- 标签位置 clamp：不超出轴边界

**温度联动**（`GraphValuesPointNode.js:108-113`）：温度变化 → `wavelengthProperty.value = body.peakWavelength`（数值点回到峰值）。

### 2.7 BGRAndStarDisplay（RGB 圆 + 星形 + 光晕）

`[来源: phet/js/blackbody-spectrum/view/BGRAndStarDisplay.js:35-109]`

**子节点**：
1. `starPath` — 9 角星（`StarShape`, outer=35, inner=20）
2. `glowingStarHalo` — 圆形光晕（半径动态）
3. `circleBlue/Green/Red` — 3 个圆（半径 15）
4. `circleBlueLabel/GreenLabel/RedLabel` — "B"/"G"/"R" 标签

**布局**（`BGRAndStarDisplay.js:74-88`）：
- 蓝圆 `centerY = 50`
- 绿圆 `centerX = 蓝圆.centerX + 50`
- 红圆 `centerX = 绿圆.centerX + 50`
- 星 `left = 红圆.right + 50`, `centerY = 蓝圆.centerY`
- 光晕 `center = 星.center`

**温度联动**（`BGRAndStarDisplay.js:100-107`）：
- 圆填充 = `body.blueColor/greenColor/redColor`
- 光晕填充 = `body.glowingStarHaloColor`
- 光晕半径 = `body.glowingStarHaloRadius`
- 星填充 = `body.starColor`

### 2.8 BlackbodySpectrumControlPanel（控制面板）

`[来源: phet/js/blackbody-spectrum/view/BlackbodySpectrumControlPanel.js:56-205]`

**子节点**：
1. `checkboxPanel`（VBox）
   - `valuesCheckbox` — "Graph Values"
   - `labelsCheckbox` — "Labels"
   - `intensityCheckbox` — "Intensity"
2. `intensityDisplay` — 强度数值显示框（可见性跟 intensityCheckbox）
3. `HSeparator`
4. `buttons`（HBox）
   - `saveButton` — 相机图标按钮
   - `eraseButton` — 擦除按钮

**擦除按钮可用性**（`ControlPanel.js:110-112`）：`savedBodyOne.temperature !== null` 时才可用。

**强度文本**（`ControlPanel.js:140-157`）：温度变化 → `totalIntensity` → 科学计数法 → `${intensity} W/m²`。

### 2.9 SavedGraphInformationPanel（保存图信息面板）

`[来源: phet/js/blackbody-spectrum/view/SavedGraphInformationPanel.js:25-132]`

**3 行**（每行 HBox = 示意曲线 + 温度文本）：
1. 主曲线示意（红色）+ 主温度
2. 保存 1 示意（灰色实线）+ 保存 1 温度
3. 保存 2 示意（灰色虚线）+ 保存 2 温度

**示意曲线**：`GenericCurveShape`（三次贝塞尔，`GenericCurveShape.js:12-23`）。

**可见性**：
- 面板整体可见 = `savedBodyOne.temperature !== null`
- 第 3 行可见 = `savedBodyTwo.temperature !== null`

---

## 三、关键交互状态机

### 3.1 温度计拖拽

```
idle → pointer down on thumb
  → record clickYOffset
  → drag: y → T(round 50) → clamp(200,11000) → set temperatureProperty
  → pointer up → idle
```

### 3.2 数值点拖拽

```
hidden (graphValuesVisible=false)
  → checkbox on → visible at peakWavelength
  → pointer down on point/cueingArrows/dashedLine
  → record clickXOffset
  → drag: x → λ → clamp(0, axisMax) → set wavelengthProperty
  → pointer up → arrowsVisible=false
```

### 3.3 保存/擦除

```
saveButton press → saveMainBody()
  → savedTwo ← savedOne.temperature
  → savedOne ← mainBody.temperature
  → (FIFO 队列，最多 2 条)

eraseButton press (enabled when savedOne != null)
  → clearSavedGraphs()
  → savedOne.reset() + savedTwo.reset()
```

### 3.4 缩放

```
horizontalZoomIn → zoom /= 2 → clamp(750, 48000)
horizontalZoomOut → zoom *= 2 → clamp(750, 48000)
verticalZoomIn → zoom /= 5 → clamp(0.00001024, 2500)
verticalZoomOut → zoom *= 5 → clamp(0.00001024, 2500)
```

---

## 四、动画 / 时序

**本 sim 无连续动画 / 无 clock / 无 ticker**。

所有视觉更新由**离散事件触发**：
- 温度计拖拽 → 温度变化 → 曲线重算 + 颜色更新 + 文本更新
- 数值点拖拽 → 波长变化 → 数值文本更新
- 复选框切换 → 可见性切换
- 缩放按钮 → zoom 变化 → 全图重算
- 保存/擦除 → 保存曲线增删

**唯一"动画"元素**：cueing arrows 的显隐（首次交互后消失），无渐变。

---

## 五、边界 / 异常处理

| 场景 | 源码处理 |
|---|---|
| 温度超范围 | `assert` 模式（开发期），运行期由 `clamp` 保证 |
| `wavelength=0` | Planck 公式返回 0（避免除零） |
| 温度=null（保存图未保存） | 不绘制曲线，面板行隐藏 |
| 数值点超出轴范围 | 圆点不可见，虚线 clamp 到轴边界 |
| EM 谱区域宽度 < 20px | 标签不显示 |
| `wavelengthMax > 12000` | 小刻度高度变 0（性能） |
| 温度低于 draperPoint(798K) | 归一化温度按 draperPoint 起算（星不发光） |

---

*分析完成时间：2026-09-07*
