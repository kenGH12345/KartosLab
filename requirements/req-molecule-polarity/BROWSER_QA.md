# Browser QA — Molecule Polarity (Final)

**Updated:** 2026-09-15  
**Verdict: PASS**

对照：本地源码 `molecule-polarity 2.1.0-dev.0` + 最新 ORIGINAL 捕获（published HTML）。

| 操作 | 原版 | Flutter | 一致 |
|---|---|---|---|
| Two Atoms 初始 | A/B、偶极、hints | 同 | YES |
| 调 EN | δEN / 偶极长度变 | Model 绑定 | YES |
| Dipole checkbox + icon | createIcon | MpDipoleIcon | YES |
| E-field on/off | ToggleSwitch → 对齐场 | MpToggleSwitch → eFieldEnabled | YES |
| 拖拽旋转 | angle；hints 隐藏 | 同 | YES |
| Reset | 默认态 + hints 恢复 | resetTwoAtoms | YES |
| Real 选 HF | initialRotation | Customization quat | YES |
| Real ESP / Density | SurfaceMesh | Canvas dual-pass | YES |
| Real 拖转 / dipole / Reset | quaternion | 同绑定 | YES |

**注：** 未伪造内部 state；控件与 Model 路径与源码一致。
