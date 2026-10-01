# SPEC — Quantum Wave Interference（PHASE 0）

## Goal

将 PhET **Quantum Wave Interference**（本地 `1.0.0-dev.5`，锁 SHA `d9ee906…`）成品级迁移为 KartosLab Flutter 原生 sim。

验收不是「看起来像干涉」，而是：

```text
真实 Model → Solver → Probability → Detection → Hits → Graph → Tools → Visual → Lifecycle → Home
```

## Screens（顺序同入口）

1. **Experiment** — 实验装置 + 闭式 Fraunhofer 探测器图案（Intensity / Hits）
2. **High Intensity** — 连续平面波 + 解析 Fresnel 传播 + 时间平均 Intensity
3. **Single Particles** — 高斯波包 + 单次探测 + Auto-fire + Detector Probe

## Non-goals（PHASE 0）

- 不写 Flutter UI / Painter / Home
- 不写演示版波纹
- 不自行设计另一套量子模型

## Architecture gate

```text
PhET Source
  → Domain Model（per-screen, per-source-scene）
  → Numerical Solver / Closed-form Pattern
  → Simulation State + Clock
  → Render Data
  → Flutter Renderer
  → Interaction / Controls
```

禁止 View 内计算概率、生成 hits、推进仿真时间。

## Phase pipeline

| Phase | Scope |
|---|---|
| **0** | Source / Numerical Audit ← **本阶段** |
| 1 | Core Domain + Numerical Solver + unit tests |
| 2 | Experiment Screen |
| 3 | High Intensity Screen |
| 4 | Single Particles Screen |
| 5 | Global Visual / Asset / Rendering Convergence |
| 6 | Final Behavioral Acceptance |
| 7 | Cross-Screen / Lifecycle / Performance / Regression |
| 8 | Home Integration |
| 9 | Final QA / Android Release Gate |

## Acceptance posture

- PHASE 0 结束状态：**NOT READY**
- 即使后续数值测试 PASS，在 Visual / Behavior / Lifecycle / Home / Android / Final QA 全部完成前，不得宣布 READY

## Key evidence docs

| Doc | Purpose |
|---|---|
| `SOURCE_MAP.md` | 类职责 → Flutter 映射 |
| `NUMERICAL_MODEL.md` | 波 / 干涉 / 探测答案 |
| `SCREEN_MAP.md` | 三屏差异 |
| `SINGLE_PARTICLES_MAP.md` | 最高风险屏专项 |
| `RISK_REGISTER.md` | 风险与缓解 |
| `GOLDEN_MATRIX.md` / `BEHAVIOR_MATRIX.md` | 测试规划 |