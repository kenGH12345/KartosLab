# Visual Baseline — Curve Fitting

## 状态

**[待确认：缺少原版运行截图]**

本环境未启动本地 PhET `grunt`/浏览器 runtime，也未保存官方最新 HTML 截图像素基线。  
不得伪造截图。视觉对齐以源码常量 + 几何规则为准；像素级 overlay 留待有 runtime 后补。

## Visual QA round (2026-09-05)

| 项 | 分类 | 结果 |
|---|---|---|
| Control default (Order/Fit hidden) | [已确认源码：curveVisible=false] | fixed |
| 3-column layout / graph not squeezed | [迁移布局问题] | fixed |
| Deviations full barometer | [迁移 UI 缺口] | fixed |
| Bucket Hole/Front geometry | [资源/视觉迁移缺口] | fixed |

详见 `DEFAULT_SCREEN_CALIBRATION.md`。

## 计划覆盖状态（逻辑基线，非像素）

| 场景 | 源码默认/行为 | 基线状态 |
|---|---|---|
| Default | 无图上点；Curve/Residuals/Values off；Order/Fit **hidden** | [源码一致] 逻辑 + widget test |
| Curve enabled | curveVisible=true；Order/Fit appear | [源码一致] widget test |
| Residuals enabled | 需 Curve on；灰竖线 | [待确认] 像素 |
| Values enabled | 坐标与 Δy 标签 | [待确认] |
| Quadratic / Cubic | order 2/3 | [待确认] |
| Adjustable Fit | 滑块 d,c,b,a | [待确认] |
| Moved points / poor / good fit | χ 气压计色带 | [待确认] |

## 视觉常量（源码）

| 项 | 值 |
|---|---|
| Screen bg | `rgb(187, 230, 246)` |
| Panel | `rgb(254, 235, 214)` |
| Point fill | `rgb(252, 151, 64)` |
| Residual | `rgb(107, 107, 107)` lw 2 |
| Curve | black lw 2 |
| MVT scale (PhET layout) | 25.5；Flutter GraphColumn: `min(w,h)/20` |
| Point radius | 8 (view) |
| Bucket base | `rgb(65, 63, 117)` |

## 后续

有原版 runtime 后补：`visual-qa/screenshots/` + `GEOMETRY_CALIBRATION.md` overlay。
