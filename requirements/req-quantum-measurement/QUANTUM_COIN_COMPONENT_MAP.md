# QUANTUM_COIN_COMPONENT_MAP

> Updated PHASE 1 · 2026-09-30

## Verdict summary

| Dimension | Result |
|---|---|
| State representation | **MATCH** (bias + heads/tails vs up/down/superposition) |
| Probability | **MATCH** (`upProbability`, down=1−up) |
| Observe / Reveal | **MATCH** (sample on reveal if quantum ready) |
| Reprepare / Flip | **MATCH** (`prepare` / `prepareNow`) |
| Reprepare and Observe | **MATCH** (`prepare(revealWhenPrepared:true)`) |
| Measurement state machine | **MATCH** (same four states) |
| Multiple coins 10/100/10000 | **MATCH** (QCT has constants; verify view managers later) |
| Randomness | **ADAPTER NEEDED** |
| Reset | **MATCH** (scene-level) |
| Layout / page chrome | **SOURCE-SPECIFIC DIFFERENCE** |
| Lifecycle / Home | **SOURCE-SPECIFIC DIFFERENCE** |
| Embedding | **NOT STARTED** (PHASE 3) |

---

## Existing QCT vs QM Coins Quantum

### MATCH

- Dual scene architecture (`CoinsModel` + two `CoinsExperimentSceneModel`)
- Classical vs Quantum button label mapping (Flip↔Reprepare, Reveal↔Observe)
- Bias ↔ superposition coupling for quantum
- `Coin` extends / specializes single-coin set pattern
- Asset SVGs for classical heads/tails reusable

### ADAPTER NEEDED

| Gap | Existing QCT | QM PHASE 1 model | Action |
|---|---|---|---|
| RNG | `math.Random()` / `Random((seed*1e9).toInt())` inside `coin_set.dart` | Injectable `QmRandom` / `SeededQmRandom` | Do **not** rewrite QCT this phase; QM uses `lib/quantum_measurement/...`. Later: adapter or optional RNG injection into QCT without breaking Home |
| Package ownership | `lib/quantum_coin_toss` standalone Home | Must live under QM Coins screen | Embedding plan PHASE 3: wrap QM models or adapt QCT behind QM CoinsModel |

### SOURCE-SPECIFIC DIFFERENCE

- QCT Home route / title / nav chrome ≠ QM 4-tab shell
- QCT may lack tambo `collect_mp3` wiring
- 10000 pixel renderer completeness TBD at layout/visual phases

### UNSAFE TO REUSE

- `QuantumCoinTossHome` as navigation target from QM Coins (**forbidden**)
- Assuming QCT visual golden equals QM Coins layout

---

## Embedding plan (unchanged intent)

```
QuantumMeasurement → CoinsScreen
  ├── Classical scene (QM model)
  └── Quantum scene (QM model; may later share view widgets with QCT)
```

PHASE 1 delivered **QM-owned** `lib/quantum_measurement/coins/model/*` as source-of-truth for QM semantics.  
Existing `lib/quantum_coin_toss/` left intact → **Existing QCT Regression: not modified this phase → PASS (no code change).**

---

## Compatibility test stance

- QM coins tests: `test/quantum_measurement/coins_model_test.dart` **PASS**
- QCT package: untouched; no breaking API change this phase
