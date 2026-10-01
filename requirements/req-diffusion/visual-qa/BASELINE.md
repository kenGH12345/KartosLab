# visual-qa / BASELINE — Diffusion

## Status

- Flutter control fidelity round：**2026-09-06**（Spinner / Data / Stopwatch / Divider panel）
- 原版 marketing：`reference_default.png`
- Flutter screenshots：`screenshots/`（粒子态）；控件布局以运行时 + 源码为准

## 控件布局（源码）

```
[ Data accordion — 容器上方，默认折叠 ]
[ Container play area ]
[ optional flow-rate vectors ]
[ TimeControl: Play Pause Step | Normal Slow ]     [ Reset ]

右侧 DiffusionControlPanel:
  Number of Particles   [cyan spinner] [red spinner]
  Mass (AMU)            [cyan spinner] [red spinner]
  Radius (pm)           [cyan spinner] [red spinner]
  Initial Temperature   [cyan spinner] [red spinner]
  [ Remove / Reset Divider ]
  ------------
  Center of Mass / Particle Flow Rate / Scale / Stopwatch
```

## 时间 readout

- 非底部永久标签
- **Stopwatch** 勾选后显示；格式 `X.X ps`；数据源 `model.stopwatchPs`

## 分类

| 观察 | 标记 |
|---|---|
| Spinner 非 Slider | [源码一致]（非视觉近似） |
| L/R 同行双 spinner | [行为一致] |
| Data 默认折叠 | [行为一致] |
| Divider 在右面板 | [行为一致] |
| Spinner chrome | [视觉近似] |
