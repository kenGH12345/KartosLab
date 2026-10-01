# GEOMETRY_CALIBRATION — Waves Intro

## Model ↔ View（物理，未改）

| 量 | 规则 | 标记 |
|---|---|---|
| Lattice / source / water side / intensity / tape | 同前 lock 表 | [已确认] |

## Shell layout（本轮校准）

| Region | Value | 标记 |
|---|---|---|
| Design canvas | 960×560 | [迁移架构/视图问题] 已加大主区 |
| Wave area | 420×420 | 主视觉中心 |
| Control column | width 168；分段 Panel | 对齐原版层级 |
| Bottom bar | height 56 | Play/Viewpoint 不进右卡 |
| Disturbance toggle | 主区左侧图标 | Continuous/Pulse |
| Light screen column | wave 右侧 +6 | Screen checkbox → 出现 |
| Spectrum track | Frequency 下滑条下 | Light only |

## Binding

所有可见性经 `WaveRenderVisibility` 派生 — 见 `VIEW_ARCHITECTURE_RECONCILIATION.md`。

## 禁止

- screenshot tracing / 硬编码对齐原版像素
- Widget 双写 showWaves
- 为 UI 改 FDTD / Lattice
