# FINAL_REPORT · Plinko Probability

> **结项报告** · req-plinko-probability · 2026-09-17

## Final Status: **READY · DONE**

| 项 | 值 |
|---|---|
| 源码蓝本 | PhET `plinko-probability` **1.2.0-dev.6**（行为） |
| 视觉参考 | published latest |
| 工程路径 | `lib/plinko_probability/` |
| Home | `物理 → 数学与概率 → Plinko Probability` |
| phase / status | `3.close` / `done` |

---

## 一句话结论

已将 PhET Plinko Probability（Intro + Lab）完整复刻为 Flutter 原生 sim，模型/行为与 1.2.0-dev.6 对齐，视觉 B-P1 清零，Browser QA 通过，并已接入 KARTOSLAB Home。

---

## Gate 总表

| Gate | Status |
|---|---|
| Analyze | **CLEAN** |
| Tests | **33 PASS** |
| Model（Ball / Bernoulli / pathHops / Stats / Probability） | **PASS** |
| Statistical Validation | **PASS** |
| Audio（PegSoundGeneration） | **PASS** |
| Reset / Lifecycle | **PASS** |
| Assets Substituted | **0** |
| Visual QA | **PASS** |
| Visual B-P1 | **0**（残差 = P2 AA） |
| Browser QA | **PASS** |
| P0 / P1 | **0 / 0** |
| Home | **INTEGRATED** |
| **Final Status** | **READY** |

---

## 交付范围

### Screens
- **Intro**：Play ×1 / ×10 / ×100、counter↔cylinder、Erase、Reset、音效
- **Lab**：rows / p、One / Continuous、Ball / Path / None、Statistics、Ideal、Erase、Reset

### 关键实现约定（与源码一致）
- 球路径 = 构造时 Bernoulli(p) 预采样 → `pathHops`；动画为抛物线插值（无刚体碰撞）
- `P(right) = p`
- Path / None **不**重跑随机，复用同一 `pathHops`
- Ideal = 理论二项分布，与实验样本独立
- Layout baseline = PhET `ScreenView.DEFAULT` **1024×618**

### 代码入口
- `lib/plinko_probability/`（model / controller / painters / screens / audio）
- `PlinkoProbabilityHome` → `home_screen.dart`「数学与概率」

---

## 视觉收口摘要

| 阶段 | Content-crop overall | 备注 |
|---|---|---|
| 早期全帧 | ~29.5 | 含错误 768×504 基线 |
| 校正 1024×618 后 | **~8.2** | Hist / Peg / Cylinder PASS |
| Lab 右侧三块 | 局部 PASS（P2） | Play / PegControls / Statistics |

| 视觉项 | 判定 |
|---|---|
| Histogram | PASS |
| Peg bake | PASS |
| Cylinder | PASS |
| Board geometry | PASS |
| NumberControl | PASS |
| Lab Right Panel | PASS（P2 residual） |

P2 仅保留：亚像素 AA、微阴影、Equation 排版残差——**不再微调**。

---

## Browser QA 摘要

证据：`BROWSER_QA.md` · `visual-qa/BROWSER_QA/`

| 区域 | 结果 |
|---|---|
| Intro ×1/×10/×100/mode/erase/reset | PASS |
| Lab rows / p / one / continuous | PASS |
| Ball / Path / None | PASS |
| Statistics（活数据） / Ideal | PASS |
| Audio gating | PASS |
| Home open → reset → reopen | PASS |

---

## 产物清单

| 文档 | 用途 |
|---|---|
| `PHASE_0_SOURCE_RECON.md` | 源码取证 |
| `PHASE_1_FEATURE_SPEC.md` | 需求/AC |
| `PHASE_2_COMPONENT_MAP.md` | 组件映射 |
| `PHASE_3_MODEL_REPORT.md` | 模型报告 |
| `ASSET_MAP.md` | 原版资源映射（Substituted=0） |
| `VISUAL_LAYOUT_BASELINE.md` | 布局基线 |
| `HistogramLayoutBaseline.md` | Histogram |
| `LAB_RIGHT_PANEL_BASELINE.md` | 右侧面板 |
| `STATISTICAL_VALIDATION.md` | 统计校验 |
| `PHASE_5_VISUAL_QA.md` | 视觉 QA |
| `BROWSER_QA.md` | 行为 QA |
| `FINAL_REPORT.md` | 本结项报告 |
| `visual-qa/` | ORIGINAL / FLUTTER / DIFF / BROWSER_QA 证据 |

---

## 已知非阻塞项（P2）

- 右侧面板 / Equation 微对齐与抗锯齿残差
- published UI 字符串 `×All` vs 本地/Flutter `×100`（行为均为 `maxBallsIntro=100`）
- KARTOSLAB shell / navbar 属 A 类，不计入 B-P1

---

## 结项判定

```text
P0 = 0
P1 = 0
Model = PASS
Behavior = PASS
Statistics = PASS
Audio = PASS
Visual = PASS
Browser QA = PASS
Tests = 33 PASS
Analyze = CLEAN
Home = INTEGRATED
Final Status: READY
status: done
```

**Plinko Probability 项目正式结项。**
