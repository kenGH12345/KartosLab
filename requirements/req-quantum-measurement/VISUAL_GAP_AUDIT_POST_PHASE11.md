# VISUAL_GAP_AUDIT_POST_PHASE11

对照用户截图与 PhET 原版；本文件跟踪 Phase 11 后视觉补齐。

| Screen | 主要缺口 | 严重度 | 状态 |
|---|---|---|---|
| Coins | Orientation / Bias / multi box | P1 | **已修**（前轮） |
| Photons | 探测器 / Average Polarization / 时间控件 | P0/P1 | **已修**（前轮） |
| Spin | 完整 SGz、粒子穿箱、改道突兀、Source/MD 布局 | P0/P1 | **已修**（本轮） |
| Bloch | 方程+Basis、Atom 舱、T 直方图、橡皮、Aqua 控件 | P0/P1 | **已修**（本轮） |

## 本轮落地（2026-09-30 19:07）

### Spin
- 恢复 SGz 蓝色分叉装饰（完整装置）
- 粒子箱内隐藏、沿二次曲线隐式穿越、出口平滑飞出（`sgTransitSpeed=0.38`）
- Source 标签上移；MD 垂直居中；MVT origin Y=360

### Bloch
- 移除错误「Measurement」标题
- `BlochMeasureEquationPanel`（数值方程 + Basis X/Y/Z）
- `BlochSystemUnderTest` Atom/Atoms 舱 + B 场线
- T 形直方图 + 黄橡皮 + Aqua ×1/×10 / 测量轴
- Magnetic Field 勾选置于 Atom 下方

## 报告

- `POST_PHASE11_VISUAL_REMEDIATION_REPORT.md`

## 仍待（非阻塞）

- Bloch/Spin Golden PNG 择机重录
- Photons 像素级 Fine-tune（若有）
