# STATISTICS_VALIDATION — Curve Fitting

源码：`js/curve-fitting/model/Curve.js` → `updateRAndChiSquared` / `getBestFitCoefficients`

---

## 1. 权重

\[
w_i = \frac{1}{\delta_i^2}
\]

Dart：`weight = 1.0 / (delta * delta)`

---

## 2. 加权累计量（源码变量名）

| 符号 | 定义 |
|---|---|
| weightSum | \(\sum w\) |
| ySum | \(\sum w y\) |
| yySum | \(\sum w y^2\) |
| yAtSum | \(\sum w \hat{y}\) |
| yAtySum | \(\sum w \hat{y} y\) |
| yAtyAtSum | \(\sum w \hat{y}^2\) |

\(\hat{y} = getYValueAt(x)\)

---

## 3. Residual sum of squares

\[
RSS = yySum - 2\cdot yAtySum + yAtyAtSum
\]

等价于 \(\sum w (y-\hat{y})^2\)。[已确认]

---

## 4. Reduced χ²（属性名 chiSquared）

\[
\mathrm{dof} = n - \mathrm{order} - 1
\]
\[
\chi^2_{\mathrm{red}} = \left| \frac{RSS}{\max(\mathrm{dof}, 1)} \right|
\]

**不是**裸 \(\sum (y-\hat{y})^2\)。[已确认]

显示：`formatNumber`；>1000 显示为 1000 且标签用 `>`。

---

## 5. r²

\[
\mathrm{denom} = \bar{w}\, n,\quad
\bar{y} = ySum/\mathrm{denom},\quad
\overline{yy} = yySum/\mathrm{denom}
\]
\[
\overline{res^2} = RSS/\mathrm{denom},\quad
\overline{sq} = \overline{yy} - \bar{y}^2
\]

| 条件 | r² |
|---|---|
| n &lt; 2 | 0 |
| \|avgSquares\| &lt; 1e-10 | **NaN**（显示空） |
| \|avgResidualSquares\| &lt; 1e-10 | 1 |
| avgResidual/avgSquares &gt; 1 | **0**（坏 Adjustable） |
| else | `1 - avgResidual/avgSquares` |

---

## 6. Best Fit 矩阵

见 SOURCE_ANALYSIS §4。Dart 等价：`RegressionSolver.getBestFitCoefficients`。

---

## 7. 测试案例（expected 来自源码公式）

| ID | 输入 | 期望 |
|---|---|---|
| A | 完美线性，等 δ | 系数匹配；r²≈1；χ²≈0 |
| B | 完美二次 | 同上 order=2 |
| C | 完美三次 | 同上 order=3 |
| D | Adjustable 极差拟合 | r²→0 |
| E | 所有 y 相同且完美水平拟合 | r² NaN 或 1（视 residual） |
| F | 重复 x | rank 受 uniqueX 限制 |
| G | 1 点 | chi=0,r=0；Best 曲线不 present（除非 Adjustable） |
| H | order=3 且仅 2 点 | 可算但 dof 用 max(dof,1) |
| I | 负坐标 | 正常 |
| J | \|det\|≈0 | 系数全 0 |

残差符号测试：竖线端点为 `(x,yObs)` 与 `(x,yFit)`，不单独断言 obs−fit 的 UI 符号。

---

## 8. χ 气压计颜色 / 比例

`BarometerX2Node.js`：

- ratio：`value≤1 → value/(1+ln(100))`；else `min(1.023, (1+ln(value))/(1+ln(100)))`
- 颜色：Flash 移植的 LOWER/UPPER_LIMIT_ARRAY；**保留源码 `||` 分支语义**

r² 气压计：线性 0–1；NaN→0 填充。
