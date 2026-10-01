# RISK_REGISTER — Quantum Measurement

> PHASE 0 · 2026-09-30 · Living document

| ID | Risk | Severity | Phase | Mitigation |
|---|---|---|---|---|
| R01 | Treat existing `quantum_coin_toss` as done Coins Screen without QM source re-audit | **P0 process** | 0–3 | Mandatory QUANTUM_COIN_COMPONENT_MAP + source-first diffs; no Navigator.push embedding |
| R02 | Quantum Coin embedding breaks standalone QCT Home / tests | P1 | 3, 10 | Keep QCT public API; share modules carefully; regression suite |
| R03 | Classical bias model conflated with quantum α/β | P0 science | 1, 3 | Separate SystemType scenes; distinct state enums |
| R04 | Observe and Reprepare share same handler | P0 science | 1, 3 | Map to `reveal`/`hide` vs `prepare`/`prepare(true)` per source |
| R05 | 10000 coins as 10000 Widgets → jank / OOM | P1 perf | 3 | Canvas/pixel aggregate like `CoinSetPixelRepresentation` |
| R06 | Non-seeded `Random()` in measurement core | P1 determinism | 1+ | Injectable seeded RNG; CoinSet seedProperty parity |
| R07 | Photons Classical/Quantum is UI-only toggle | P0 science | 1, 4 | Implement path split vs definite path from scene model |
| R08 | Spin presets incomplete (only Experiment 1) | P1 | 1, 5 | Port all 7 SpinExperiment enum values |
| R09 | Bloch sphere static image / no precession | P0 science | 1, 6 | ComplexBlochSphere + magnetic field time evolution |
| R10 | Cross-screen state leak | P1 | 8 | Independent screen models; isolation tests |
| R11 | Material Icons / emoji replacing original coin / photon / SG visuals | P0 visual | 2+ | VISUAL_ASSET_AUDIT; Substituted=0 |
| R12 | Reset All not using `KratosResetAllButton` | P1 visual | 3+ | Rule 86 |
| R13 | Missing tambo `collect_mp3` binary in workspace | P2 / P1 if silent UX gap | 0, 7 | Locate shared sound or document BLOCKED audio |
| R14 | Nested duplicate source tree causes edit confusion | P2 process | 0 | Use top-level `quantum-measurement-main` only |
| R15 | Equation / ket typography degraded to plain ASCII | P1 visual | 3–6 | Match constants (KET, symbols) + RichText |
| R16 | Early Home registration before 4 screens ready | P1 product | 10 | Home only after PHASE 9–10 gate |
| R17 | Declaring READY after single screen | P0 process | all | Status rules: NOT READY until all gates |
| R18 | Layout via Column/Expanded instead of design-space composer | P1 layout | 2 | LAYOUT_SPEC + per-screen composers |
| R19 | PhotonSprites depend on greenPhoton.png not copied | P1 | 4, 7 | Copy assets in VISUAL_ASSET_AUDIT checklist |
| R20 | QCT RNG not matching PhET seed semantics → golden flake | P1 | 1, 3 | Align seed→Random mapping; document any intentional non-bit-identical policy |

---

## Open blockers for PHASE 0 closeout

None blocking archaeology inventory.  
**Watch items:** R13 (audio binary location), R01 (process discipline into PHASE 1).
