# FUNCTIONAL_GAP_CLOSURE — Gases Intro

**状态**：`view_reconstruction`（物理冻结；View / Layout / Asset 重建）

| 功能 | 状态 | 分类 |
|---|---|---|
| IdealGasLaw Model | 冻结未改 | — |
| RIGHT OVERFLOW 11px | **已修**（panel width/constraints） | 曾 [迁移布局 bug] |
| GaugeNode 表盘 | GaugePainter | 残余像素 → [迁移组件缺失] |
| ThermometerNode | ThermometerPainter（非 slider） | 残余 → [迁移组件缺失] |
| ShadedSphere 粒子 | shaded_sphere | 残余 → [迁移组件缺失] |
| BicyclePump | BicyclePumpPainter + pump binding | 残余 → [迁移组件缺失] |
| Heater flame/ice PNG | assets 已接 | 残余 chrome → [迁移组件缺失] |
| Eraser / Reset | svg/png 已接 | OK |
| 左墙 Handle（无活塞） | drag → width/volume | 文档纠正「活塞」误称 [行为差异] |
| Control panel 结构 | ListView + Hold/Width/SW/CC/Particles | 残余对齐 → [迁移组件缺失] |
| Particles Fine/Coarse ±1/±50 | spinner row | OK 交互模式 |
| Collision Counter 可拖工具 | [待实现] | [迁移组件缺失] |
| Stopwatch 完整 UI | 仅时间读数 | [迁移组件缺失] |
| Runtime Visual QA P3 | [待截图] | — |
| Interaction QA P4 | 需真机验证 | — |

**禁止**用 [视觉近似] 描述缺组件 / 布局 bug / 行为差。
