# RISK_REGISTER — PHASE 0

| ID | Risk | Severity | Evidence | Mitigation | Test |
|---|---|---|---|---|---|
| R01 | Numerical mismatch Experiment vs HI/SP backends | **Critical** | Exp=Fraunhofer；HI/SP=Fresnel kernel | 分屏独立 solver；禁止混用公式 | matrix A/B |
| R02 | Wave packet mismatch | **Critical** | Gaussian+chirp+spread constants | 逐常量移植；对照 evaluateSample | packet traversal + PDF |
| R03 | Probability / intensity definition drift | High | HI time-average vs SP instantaneous vs Exp closed-form | 文档化三种 PDF；分别测 | NUMERICAL_MODEL §6–9 |
| R04 | Detector pattern wrong under which-path | High | decoherence layers + envelope-only Exp | 对照 WaveDecoherence + getExactDetectorIntensity | detector configs |
| R05 | Hit sampling mismatch | High | Exp rejection vs HI/SP roulette；y 范围不同 | 分实现；注明 y∈[-1,1] vs [0,1] | seeded hit histograms |
| R06 | Graph mismatch | Med | 100 bins；zoom defaults differ | 共享 binning 工具 + per-screen zoom defaults | golden graphs |
| R07 | Snapshot mismatch | Med | Exp intensity 重算；HI 存 PDF；SP hits-only | 按 Snapshot schema 分支渲染 | snap take/view/delete |
| R08 | Probe mismatch | **Critical** | Bernoulli(p) + measurement projection | 禁止 random bool；测 renorm | probe paths |
| R09 | Ruler/tape treated as physics | Med | display-only comments in source | 工具层隔离 | unit tests no solver coupling |
| R10 | Time-step / TimeSpeed mixup | High | 三套因子；stepOnce 不乘 speed | SimulationClock 显式 API | pause/step/speed tests |
| R11 | Performance wave 120² | High | full evaluate per cell | dirty flags；quality tiers | FPS stress |
| R12 | Memory 25k hits × scenes | High | MAX_HITS；snapshots copy | typed buffers；render cap 10k | stress 10k/25k |
| R13 | Responsive layout break | Med | complex Exp 3-row + HI columns | design coords transform | resize matrix |
| R14 | Accessibility incomplete | Med | huge a11y YAML | 分阶段接入 strings | a11y checklist late |
| R15 | Audio shared hooks missing | Low | only snapshot mp3 local；tambo MISSING | 原 mp3 + 项目 shared policy | snapshot sound |
| R16 | model.md numeric drift | Med | HI slit ranges outdated vs TS | **源码优先**；已在 CONTROL_MAP 标注 | code review |
| R17 | Wrong scenery-phet local SHA | Med | 2020 scenery-phet vs lock d9ee906 | 不引用本地过期 scenery-phet；需时按 SHA 检出 | DEPENDENCY_LOCK |
| R18 | Non-determinism from dotRandom | High | no seed in sim | Flutter inject Random | golden harness |
| R19 | Three-screen state pollution | High | easy singleton mistake | independent screen models | cross-tab lifecycle |
| R20 | Fast×16 SP instability | Med | FAST_TIME_SPEED_FACTOR=16 | dt clamp；substep | long auto-fire |
| R21 | Visual tuning alters physics | High | colorPower / brightness tempt | 显示增益隔离 | PDF unchanged asserts |
| R22 | Doc Analytical* rename confusion | Low | implementation-notes 旧名 | 以 Wave*.ts 为准 | SOURCE_MAP |

---

## Top risks for Phase 1

1. 正确移植 `WaveKernel` + `FresnelApertureTransfer` + decoherence  
2. Experiment Fraunhofer 独立正确  
3. Seedable hit + probe RNG  
4. SimulationClock / TimeSpeed 三套因子  
5. SP packet timing + re-emission