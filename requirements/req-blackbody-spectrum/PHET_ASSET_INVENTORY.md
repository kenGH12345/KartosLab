# Blackbody Spectrum · PhET Asset Inventory

> 取证对象：`phet sourses/blackbody-spectrum-main/blackbody-spectrum-main`
> 取证方式：完整扫描源码 `js/`、`assets/`、`images/` 目录
> 引用约定：`[来源: phet/<相对路径>:<行号>]`

---

## 一、资源扫描结果

### 1. 静态图片资源

| 路径 | 类型 | 用途 | 复用判定 |
|---|---|---|---|
| `assets/blackbody-spectrum-screenshot.png` | PNG | 官方截图（仓库元数据） | **不复用** · 仅仓库展示，非运行时资源 |
| `assets/blackbody-spectrum-screenshot-screen1.png` | PNG | 官方截图（screen1） | **不复用** · 同上 |
| `assets/blackbody-spectrum-screenshot-alt1.png` | PNG | 官方截图（alt1） | **不复用** · 同上 |
| `assets/blackbody-spectrum-screenshot-alt2.png` | PNG | 官方截图（alt2） | **不复用** · 同上 |
| `images/license.json` | JSON | PhET 资源 license 元数据 | **不复用** · 仅 license 元数据 |

**结论**：本 PhET sim **无任何运行时静态图形资源**（无 SVG / PNG / JPG / 纹理 / sprite）。所有视觉元素**完全由 Scenery 代码动态绘制**。

### 2. 程序化绘制的视觉元素（Dynamic Nodes / Shapes）

按 PhET Scenery 命名逐项登记，并给出 Flutter 等价实现方式：

| PhET 元素 | 源码位置 | 类型 | Flutter 实现 | 判定 |
|---|---|---|---|---|
| 玻璃温度计管 + 灯泡 | `ThermometerNode`（scenery-phet 引用）`view/BlackbodySpectrumThermometer.js:40-71` | Scenery 内置组件 | `CustomPainter` 绘制圆角矩形管 + 圆形灯泡 | **重新实现** |
| 三角形滑动 thumb | `view/TriangleSliderThumb.js:21-99`（引用 `TriangleNode`/`ArrowNode`） | Shape + 旋转 | `CustomPainter` 绘制三角形 + 旋转 -π/2 | **重新实现** |
| 虚线锚定线（thumb 到温度计） | `view/TriangleSliderThumb.js:49-53` | `kite.Shape` 折线 + dash | `Paint..style=stroke..strokeJoin` + `dashPathEffect` 或手工 dash | **重新实现** |
| cueing arrows（thumb 两侧绿箭头） | `view/TriangleSliderThumb.js:62-65` | `ArrowNode` × 2 | `CustomPainter` 绘制箭头 + 首次点击后隐藏 | **重新实现** |
| 黑体光谱曲线 Path | `view/GraphDrawingNode.js:206-226`（`shapeOfBody`） | `kite.Shape` 折线 300 点 | `Path` + `canvas.drawPath` | **重新实现**（动态计算） |
| 主曲线 / 保存曲线 1 / 保存曲线 2 | `view/GraphDrawingNode.js:73-81` | `scenery.Path` 不同 stroke | `Paint` 不同 color/width/dash | **重新实现** |
| 强度填充区（曲线下面积） | `view/GraphDrawingNode.js:84` + `updateGraphPaths:238-242` | `Path` fill | `Path..close()` + `Paint..style=fill` | **重新实现** |
| 坐标轴（L 形 + 端点小钩） | `view/ZoomableAxesView.js:120-128` | `kite.Shape` 折线 | `canvas.drawLine` 或 `Path` | **重新实现** |
| 水平/垂直刻度 | `view/ZoomableAxesView.js:270-285`（`redrawHorizontalTicks`） | `kite.Shape` 折线 | `canvas.drawLine` 多条 | **重新实现** |
| 电磁波谱分隔轴 + 标签 | `view/ZoomableAxesView.js:138-149` | `Path` + `Text` | `canvas.drawLine` + `TextPainter` | **重新实现** |
| 坐标轴边界数字（0 / max） | `view/ZoomableAxesView.js:217-229` | `Text` | `TextPainter` | **重新实现** |
| 坐标轴标签（Spectral Power Density / Wavelength） | `view/ZoomableAxesView.js:159-180` | `Text` + 旋转 -π/2 | `TextPainter` + `canvas.translate/rotate` | **重新实现** |
| 可见光彩虹条（WavelengthSpectrumNode） | `view/GraphDrawingNode.js:108-112`（引用 `scenery-phet/WavelengthSpectrumNode`） | 渐变矩形 | `LinearGradient` + `canvas.drawRect` | **重新实现** |
| 可拖动数值点 + 虚线十字 | `view/GraphValuesPointNode.js:29-262` | `Circle` + `Path` + `Text` | `CustomPainter` + `GestureDetector` | **重新实现** |
| 数值标签（波长 / 光谱功率密度） | `view/GraphValuesPointNode.js:184-202` | `Text` / `RichText` | `TextPainter`（含科学计数法） | **重新实现** |
| cueing arrows（数值点两侧） | `view/GraphValuesPointNode.js:87-95` | `ArrowNode` × 2 | `CustomPainter` | **重新实现** |
| RGB 三个圆 + 标签 | `view/BGRAndStarDisplay.js:50-59` | `Circle` + `Text` | `canvas.drawCircle` + `TextPainter` | **重新实现** |
| 星形 Path | `view/BGRAndStarDisplay.js:62-72`（引用 `StarShape`） | `kite.Shape`（9 角星） | `Path` 绘制 9 角星顶点 | **重新实现** |
| 星形光晕 Circle | `view/BGRAndStarDisplay.js:61,104-106` | `Circle` 渐变 alpha | `RadialGradient` + `canvas.drawCircle` | **重新实现** |
| Reset All 按钮 | `view/BlackbodySpectrumScreenView.js:84-92`（引用 `ResetAllButton`） | Scenery 内置按钮 | `ElevatedButton` / `FilledButton` | **替换**（L0 规范允许用 Material 按钮） |
| 保存按钮（相机图标） | `view/BlackbodySpectrumControlPanel.js:84-94`（引用 `RectangularPushButton` + `cameraSolidShape`） | Scenery 按钮 + FontAwesome 图标 | `IconButton`（`Icons.camera_alt`） | **替换** |
| 擦除按钮 | `view/BlackbodySpectrumControlPanel.js:97-106`（引用 `EraserButton`） | Scenery 按钮 | `IconButton`（`Icons.delete`） | **替换** |
| 复选框 × 3 | `view/BlackbodySpectrumControlPanel.js:119-125` | `sun/Checkbox` | `Checkbox`（Material） | **替换** |
| 强度数值显示框 | `view/BlackbodySpectrumControlPanel.js:127-157` | `Rectangle` + `RichText` | `Container` + `Text`（含科学计数法） | **重新实现** |
| 保存图信息面板 | `view/SavedGraphInformationPanel.js:54-95` | `Panel` + `Path`（GenericCurveShape）+ `Text` | `Container` + `CustomPainter`（绘制示意曲线）+ `Text` | **重新实现** |
| GenericCurveShape（示意曲线） | `view/GenericCurveShape.js:12-23` | `kite.Shape` 三次贝塞尔 | `Path` + `cubicTo` | **转换复用** |

### 3. 动态计算逻辑（必须迁移原始计算，禁止静态化）

| 计算项 | 源码位置 | 公式/方法 | Flutter 等价 |
|---|---|---|---|
| Planck 光谱功率密度 | `model/BlackbodyBodyModel.js:75-85` | `A / (λ^5 * (e^(B/(λT)) - 1))` · `A=3.74192e-16`, `B=1.438770e7` | 纯函数 `double spectralPowerDensity(double λ, double T)` |
| Wien 位移定律（峰值波长） | `model/BlackbodyBodyModel.js:144-148` | `1e9 * 2.897773e-3 / T` | 纯函数 `double peakWavelength(double T)` |
| Stefan-Boltzmann 总强度 | `model/BlackbodyBodyModel.js:130-133` | `5.670373e-8 * T^4` | 纯函数 `double totalIntensity(double T)` |
| 归一化温度（星尺寸缩放） | `model/BlackbodyBodyModel.js:94-103` | `0.02 * (max(T,798) - 798)^0.5` | 纯函数 |
| RGB 通道强度（255 归一） | `model/BlackbodyBodyModel.js:113-121` | `255 * min(renormT,1) * I(λ)/max(R,G,B)` | 纯函数 |
| 星形光晕半径 | `model/BlackbodyBodyModel.js:194-202` | `linear(0,2,5,100, renormT)` | `lerpDouble` |
| 星形光晕 alpha | `model/BlackbodyBodyModel.js:212-215` | `linear(0,1,0,0.3, renormT)` | `lerpDouble` |
| 温度计 thumb y → 温度 | `view/BlackbodySpectrumThermometer.js:99` | 线性反推 + `roundToInterval(50)` + clamp | 纯函数 |
| 坐标变换 λ→viewX | `view/ZoomableAxesView.js:333-335` | `linear(0, λmax, 0, axisW, λ)` | `lerpDouble` |
| 坐标变换 SPD→viewY | `view/ZoomableAxesView.js:353-356` | `-1e33 * linear(0, vZoom, 0, axisH, spd)` | `lerpDouble` |
| 曲线 300 点采样 | `view/GraphDrawingNode.js:28,208-224` | 均匀采样 + 峰值点强制插入 | 循环采样 |
| 科学计数法格式化 | `scenery-phet/ScientificNotationNode`（间接） | mantissa × 10^exp | `e.toStringAsFixed` + 自定义格式化 |

---

## 二、复用判定汇总

### REUSE（直接复用）
- 无（本 sim 无任何静态图片资源可直接复用）

### CONVERT（转换复用）
- `GenericCurveShape` 的三次贝塞尔曲线 → Flutter `Path.cubicTo`（保存图信息面板的示意曲线）

### REIMPLEMENT（重新实现，但逻辑来自源码）
- 所有 Scenery Node / Shape / Path → Flutter `CustomPainter`
- 所有 `Text` / `RichText` → `TextPainter`
- 所有 `Circle` → `canvas.drawCircle`
- `ArrowNode` → 自绘箭头
- `ThermometerNode` → 自绘温度计
- `StarShape` → 自绘 9 角星 `Path`
- `WavelengthSpectrumNode` → `LinearGradient` 可见光彩虹条

### REPLACE（Material 替换，符合 L0 规范）
- `ResetAllButton` → `FilledButton.tonal` / `ElevatedButton`
- `RectangularPushButton`（保存） → `IconButton(Icons.camera_alt)`
- `EraserButton` → `IconButton(Icons.delete)`
- `Checkbox` → Material `Checkbox`

### 未迁移项
- 无（所有运行时元素均已登记实现方式）

---

## 三、关键结论

1. **本 sim 是"纯代码绘制"型**——零静态图片资源，全部视觉由 Scenery 代码 + 数学计算生成。这与 curve_fitting sim 同构。
2. **物理公式必须严格按源码常量迁移**：Planck / Wien / Stefan-Boltzmann 三大定律的常量（`A=3.74192e-16`、`B=1.438770e7`、`WIEN=2.897773e-3`、`σ=5.670373e-8`）不可凭物理记忆改写。
3. **颜色体系**：`BlackbodyColors.js` 定义 default（黑底白字）/ projector（白底黑字）两套配色。Flutter 端先实现 default 配色；projector 模式作为 `[待确认]` 后续按需加。
4. **布局锚点**（来自 `BlackbodySpectrumScreenView.js:102-116`）：
   - 图表靠左下（`left=INSET(10), bottom=maxY-INSET`）
   - 温度计靠右上（`right=maxX-INSET`）
   - 控制面板在温度计左侧
   - 保存图信息面板在控制面板下方
   - RGB+星 显示在 `left=225`（经验值）
   - Reset 按钮靠右下

---

*取证完成时间：2026-09-07 · 取证人：主会话（Blackbody Spectrum 迁移）*
