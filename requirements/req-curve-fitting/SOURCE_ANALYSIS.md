# SOURCE_ANALYSIS — Curve Fitting

> 本地源码唯一事实来源：`1.1.0-dev.0`  
> 标记约定：`[已确认]` / `[推测]` / `[待确认]`

---

## 1. Screen

| 功能 | 文件 | 结论 |
|---|---|---|
| 单屏 | `js/curve-fitting-main.js` L27-28 | [已确认：单 Screen] |
| Model factory | `CurveFittingScreen.js` | `() => new CurveFittingModel()` |
| View | `CurveFittingScreenView.js` | 拥有 view-only Properties |
| Reset | ScreenView ResetAllButton | model.reset + view props reset + ControlPanels.reset |

---

## 2. DataPoint

| 字段 | 类型 | 默认 | 证据 |
|---|---|---|---|
| position (x,y) | Vector2Property | (0,0) 或创建时 | `Point.js` |
| dragging | BooleanProperty | false | |
| delta (uncertainty) | NumberProperty | **0.8** | L40 |
| isInsideGraph | Derived | `GRAPH_BACKGROUND_MODEL_BOUNDS.contains` | [-10,10]² |
| animation | Animation\|null | null | 拖出图外回 bucket |

**Relevant points**（参与拟合）[已确认]：
`isInsideGraph && animation === null` — `createPoints.js`

**数量**：无硬编码最大点数；bucket 装饰点 29 个可拖出无限次新增。  
**初始图上点**：无（空 ObservableArray）。[已确认]  
**snapToGrid**：query param 默认 **false**。[已确认]

**Delta 拖拽** [已确认]：`MIN_DELTA=1e-3`, `MAX_DELTA=10`（`PointNode.js`）

---

## 3. Curve Types / Parameterization

| Order | UI 标签 | 方程 |
|---|---|---|
| 1 | Linear | \(y = a_0 + a_1 x\) |
| 2 | Quadratic | \(y = a_0 + a_1 x + a_2 x^2\) |
| 3 | Cubic | \(y = a_0 + a_1 x + a_2 x^2 + a_3 x^3\) |

系数数组升序 `[a0,a1,a2,a3]`。[已确认] `Curve.getYValueAt`

UI 符号映射（升序）：`d→a0, c→a1, b→a2, a→a3`。[已确认] FitPanel

**滑块范围** [已确认] Constants：
- d: [-10,10] default **2.7**
- c: [-2,2] default 0
- b: [-1,1] default 0
- a: [-1,1] default 0

---

## 4. Best Fit

文件：`Curve.getBestFitCoefficients`  
方法：**加权多项式最小二乘**（非普通无权重 polyfit）

\[
X_{ij} = \sum_k \frac{x_k^{i+j}}{\delta_k^2},\quad
Y_i = \sum_k \frac{x_k^i\, y_k}{\delta_k^2},\quad
A = X^{-1} Y
\]

- `matrixRank = min(order+1, uniqueXCount)`
- `|det| ≤ 1e-30` → 全零系数
- 否则 `squareMatrix.solve(columnMatrix)`

参考注释：http://mathworld.wolfram.com/LeastSquaresFittingPolynomial.html

---

## 5. Adjustable Fit

`getAdjustableFitCoefficients`：直接取 `sliderPropertyArray[0..order]`。  
**不会**在 Adjustable 下重跑 Best Fit。[已确认]

模式切换：`fitProperty.link(updateCurveFit)` — Best 时从点重算；Adjustable 时从滑块取值。

---

## 6. Residuals

`ResidualsNode`：对每个 relevant point：
```
moveTo(point.position)
verticalLineTo(curve.getYValueAt(x))
```
即竖线连接 **观测点 → 曲线拟合 y**。[已确认]  
颜色：`GRAY_COLOR`，lineWidth 2；clip 到 graph background。  
可见性：`residualsVisible && isCurvePresent()`。

---

## 7. r² / χ²

见 `STATISTICS_VALIDATION.md`。要点：

- `chiSquaredProperty` 实际存的是 **reduced χ²** = `|RSS / max(n−order−1, 1)|`
- r² 可对 Adjustable 坏拟合钳到 0；方差≈0 → NaN
- n&lt;2 → 两者为 0

---

## 8. Curve Display / Sampling

- `curveVisible` 默认 **false**；关掉时 Residuals 强制关并记住状态（ViewOptionsPanel）
- `CurveShape`：`NUMBER_STEPS = 220`，x ∈ GRAPH_NODE_MODEL_BOUNDS [-12,12]
- Curve stroke black, lineWidth 2；clip CURVE_CLIP_BOUNDS [-10,10]²

---

## 9. Graph / MVT

```
ModelViewTransform2.createSinglePointScaleInvertedYMapping(
  (0,0), layoutBounds.center, 25.5)
```
[已确认] Y 向上为模型正方向。

| Bounds | 值 |
|---|---|
| GRAPH_NODE_MODEL_BOUNDS | [-12,12]² |
| GRAPH_AXES_BOUNDS | [-10.75,10.75]² |
| GRAPH_BACKGROUND_MODEL_BOUNDS | [-10,10]² |
| CURVE_CLIP_BOUNDS | [-10,10]² |

Major ticks: ±5, ±10；minor every 1.

---

## 10. Controls

| 控件 | 默认 |
|---|---|
| Curve / Residuals / Values | false |
| Linear / Quadratic / Cubic | Linear (1) |
| Best / Adjustable | Best |
| Coefficient sliders | 仅 Adjustable 可见；按 order 显示 |
| Order/Fit panels | 仅 curveVisible 时可见 |
| Deviations accordion | expanded true |
| Equation on graph | expanded true；curve 不可见时隐藏内容逻辑见 EquationAccordionBox |
| Reset All | 全重置 |

---

## 11. Drag / Bucket

- Bucket 左下角模型坐标附近；29 个装饰圆可 `start` 时 `new Point` + `points.add`
- 点拖动：`viewToModelPosition`；结束若不在图内 → animate 回 initial → remove
- z-order：拖动 `moveToFront`
- Error bars 独立拖 delta

---

## 12. Assets

| 类型 | 处理 |
|---|---|
| Bucket | scenery-phet BucketFront/Hole → Flutter 几何绘制 |
| Arrows / InfoButton | 几何 / 简单图标 |
| KaTeX | 方程用 Text/RichText |
| 无大量 PNG/SVG 资源包 | [已确认] |

---

## Migration conclusions

1. 单屏；数学全部在 `Curve.js` — Dart 必须逐行语义移植。  
2. χ² UI 标签是 X²，值为 reduced χ²。  
3. 禁止无权重 `PolynomialFit`。  
4. 不抽跨 sim framework。
