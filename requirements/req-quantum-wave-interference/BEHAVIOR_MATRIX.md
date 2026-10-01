# BEHAVIOR_MATRIX — Numerical & Interaction Tests（计划）

PHASE 0：设计 only。Tests Added = 0。

---

## A. Configuration × Particle matrix

For each particle ∈ {photon, electron, neutron, helium}:

| Config | Experiment | HI | SP |
|---|---|---|---|
| empty / bothOpen default | ✓ | ✓ | ✓ |
| single slit leftCovered | ✓ | ✓ | ✓ |
| single slit rightCovered | ✓ | ✓ | ✓ |
| double slit bothOpen | ✓ | ✓ | ✓ |
| noBarrier | n/a | ✓ | ✓ |
| leftDetector | ✓ | ✓ | ✓ |
| rightDetector | ✓ | ✓ | ✓ |
| bothDetectors | ✓ | ✓ | ✓ |

Assertions（有源码依据）：

- bothOpen → interference fringes（或 PDF 振荡）
- one covered → no fine cos² fringes；envelope only
- which-path → no coherent double-slit fringes
- noBarrier → free propagation / flat-ish Experiment n/a

---

## B. Parameter sweeps

| Param | Points | Expect |
|---|---|---|
| wavelength | min / default / max | fringe spacing ∝ λ |
| intensity (Exp) | 0 / 0.5 / 1 | hit rate ∝；0 → no hits |
| slit separation | min / default / max | fringe spacing ∝ 1/d |
| screen distance (Exp) | 0.4 / 0.6 / 0.8 | pattern stretch |
| brightness | 0 / 50 / 100 | visual only；PDF unchanged |

---

## C. Numerical invariants（仅源码/公式依据）

| Invariant | Scope |
|---|---|
| intensity ≥ 0 | all patterns |
| Experiment bothOpen symmetric about center | slit symmetric |
| PDF renormalized max or integral per API contract | HI/SP getDetectorProbabilityDistribution |
| Probe p ∈ [0,1] | SP |
| After failed probe，总概率重整化 | WaveMeasurementProjection |
| same seed + same dt → same hits | test harness |

**不要**强加 PhET 未实现的物理约束。

---

## D. Accumulation

SP / Exp hits：N ∈ {1, 10, 100, 1000} — 图案应逐步显现，而非第 1 帧完整答案。

Long-run：大 N 直方图 vs expected PDF（χ² / KS；阈值待 Phase 1 标定）。

---

## E. Time

| Case | Expect |
|---|---|
| Pause | no advancement |
| Step × N | equals N/60 model s（HI/SP） |
| Speed factors | match tables |
| FPS 30 vs 60 harness | same results with accumulated fixed substeps |

---

## F. User paths

见用户 Prompt §79–84：Experiment / HI / SP / Probe / Snapshot / Ruler。

---

## G. Resize / input

Viewports: 768×464, 1024×618, 834×504, narrow。  
Mouse + touch on source, barrier, detector, probe, ruler/tape, graph。  
Hitbox ≠ visual bounds 时单独验收。