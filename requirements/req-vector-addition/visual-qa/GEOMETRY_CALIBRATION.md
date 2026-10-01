# Geometry Calibration · Vector Addition

> 对照源码 `1.3.0-dev.0` · 更新于 Phase 10

## Arrow（RootVector / Vector / Base / Component）

| 参数 | 值 | 备注 |
|---|---|---|
| headWidth | 12 | |
| headHeight | 14 | |
| tailWidth | 3.5 | component tailWidth=3 |
| fractionalHeadHeight | 0.5 | dynamic head |
| component dash | [6, 3] | |
| base lineWidth | 1.5 | stroke on white fill |
| shadow offset | (3.2, 2.1) α0.28 | off-graph only |
| coefficient | −5…5 default 1 | EquationsVector |

短向量：`headHeight > 0.5 * viewLength` → 等比缩小 head。

## Angle arc

| 参数 | 值 |
|---|---|
| max radius | 25 view px |
| scale | 0.79 × viewMagnitude |
| Flutter sweep | **−modelAngleRadians** |
| Model angle | atan2(y,x) CCW from +x |

**钉死**：注释 “clockwise” 错误；以实现 + 单测为准。

## Component anchors

| Style | x | y |
|---|---|---|
| triangle | 共尾 | 共 tip |
| parallelogram | 共尾 | 共尾 |
| projection | 轴上 + offsets | |
| invisible | 不绘制 | |

## Base Vector（Equations）

| Scene | Vector | base tail | base |
|---|---|---|---|
| Cartesian | a | (35, 15) | (0, 5) |
| Cartesian | b | (35, 5) | (5, 5) |
| Polar | d | (35, 15) | mag 5 ∠0° |
| Polar | e | (35, 5) | mag 8 ∠45° |

## Phase 10 layout anchors（Equations · 1024×618）

| 控件 | 锚点 |
|---|---|
| Graph | (30,163)–(755,598) · 725×435 |
| Vector Values | centerX=graph.centerX · top=16 · content≈500×45 |
| Equation bar | centerX=graph.centerX · top=values.bottom+10 · width≈688 |
| GraphControlPanel | right=layout−20 · top=16 · width=175 |
| Base Vectors | right=panel · top=panel.bottom+8 |
| Cartesian/Polar | left=panel.left · bottom≈reset.bottom |
| ResetAll | right=layout−20 · bottom=layout−16 · 自定义橙盘 |

详见 `PHASE_10.md` · 判定 **[视觉待修正]**。
