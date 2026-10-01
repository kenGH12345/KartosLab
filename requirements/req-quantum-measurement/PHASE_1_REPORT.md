# PHASE 1 REPORT — Numerical / Model Mapping

**Req:** req-quantum-measurement  
**Date:** 2026-09-30  
**Status:** READY CANDIDATE (phase gate) · overall sim still **NOT READY**

---

## Deliverables

| Artifact | Status |
|---|---|
| NUMERICAL_MODEL.md | PASS |
| FUNCTION_MAP.md | PASS |
| RESET_SEMANTICS.md | PASS |
| RNG_SPEC.md | PASS |
| QUANTUM_COIN_COMPONENT_MAP.md | PASS (updated) |
| Pure Dart models under `lib/quantum_measurement/` | PASS |
| Unit tests `test/quantum_measurement/` | **47 PASS** |
| Existing QCT code | Untouched (compat PASS) |

---

## Model code map

```
lib/quantum_measurement/
  common/qm_random.dart
  common/system_type.dart
  common/experiment_measurement_state.dart
  coins/model/{coin_states,coin_set,coins_model}.dart
  photons/model/photons_model.dart
  spin/model/spin_model.dart
  bloch_sphere/model/bloch_sphere_model.dart
```

---

## Answers to Phase-1 gate questions

| Question | Answer |
|---|---|
| Observe does what? | Quantum: if `readyToBeMeasured`, sample via seeded RNG then `revealed`; classical reveal shows already sampled hidden values |
| Why this probability? | Coins: bias; Photons: Malus sin²/cos²; Spin/Bloch: (1+n̂·r̂)/2 |
| Reprepare vs Reset? | Reprepare = prepare path only; Reset All restores defaults / both scenes |
| Spin Exp 3 vs 5? | 3: SGz then SGx/SGx; 5: SGx then SGz/SGz |
| Bloch vector change? | θ,φ update unit vector + Z-basis amplitudes; measurement collapses to ± axis |
| 10000 coins stats? | Array of length ≤10000; sample first N; view uses pixels later |
| Where RNG enters? | CoinSet seed; Photon PBS; Spin measureParticle; Bloch measure — all via `QmRandom` |

---

## P2 notes

1. Flutter RNG not bit-identical to PhET `dot.Random` (documented).
2. Photons spatial photon stepping abstracted to emit→detect for model tests; full kinematics in later UI phase.
3. Spin continuous emission clock not fully simulated (Single fire path covered; continuous flagged for view/clock phase).
4. QCT RNG adapter deferred (no QCT rewrite this phase).

---

## Next

**PHASE 2 — Layout Archaeology** (1024×618, root regions, LAYOUT_SPEC). No formal Screen UI yet beyond what's needed for layout docs.
