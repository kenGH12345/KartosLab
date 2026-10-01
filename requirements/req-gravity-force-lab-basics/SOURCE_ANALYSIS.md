# SOURCE_ANALYSIS — Gravity Force Lab: Basics

本地 basics `1.2.0-dev.0` + ISLC/Mass（GitHub raw，算法对齐）。

## 1. Physics [已确认]

\[
F = G \frac{m_1 m_2}{r^2},\quad G = 6.67430\times 10^{-11}
\]

- `r` = 中心距 `|x2−x1|`（米）
- `forceProperty` 标量；方向由球相对位置决定（吸引）
- \(F_{12}=-F_{21}\)（等大反向）

## 2. Mass / Radius [已确认]

\[
r(m)=\left(\frac{3m}{4\pi\rho}\right)^{1/3},\ \rho=1.5
\]

- Constant Size ON：`radius = CONSTANT_RADIUS = r(1e9)`
- OFF：随质量变；半径增大时可推开另一球（step 语义）

## 3. Track / Drag [已确认]

| 项 | 值 |
|---|---|
| 运动 | 一维水平 track，y 固定 |
| 边界 | ±5000 m |
| snap | 100 m |
| minSeparation | 200 m（表面间隙，加半径） |
| 拖一个球 | 另一个不动 |

## 4. Mass controls [已确认]

- NumberPicker，步进 **1 billion kg**
- 范围 1…10 billion kg
- 显示 `value/1e9` 整数 + “billion kg”

## 5. Force arrows [已确认]

双段线性映射（ISLCForceArrowNode + GFLBMassNode）：

- minArrowWidth 0.1，thresholdArrowWidth 1，maxArrowWidth **400**
- forceThresholdPercent **7e-4**
- tip length factor **ARROW_LENGTH=8**
- forceArrowHeight m1=125 / m2=175
- 标签：`toFixed(F,1)` + `N`，无科学计数法 UI

## 6. Distance [已确认]

- 中心距 / 1000 → km
- pattern `{{distance}} km`
- 默认显示

## 7. Robots / Pullers [已确认]

- PNG：`figurePull_1…31.png`（ISLC）
- scale 0.45；ropeLength 40；力→帧线性映射
- 右球水平翻转

## 8. MVT [已确认]

```
layoutBounds 768×464
createSinglePointScaleInvertedYMapping(0, center, 0.05)
```

## 9. Checkboxes 默认

| Force Values | Distance | Constant Size |
|---|---|---|
| true | true | false |

## Migration conclusion

在 Flutter 内自包含移植 ISLC 核心语义；不引入跨 sim framework。
