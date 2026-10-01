# Build an Atom — Regression Matrix (Phase 7)

| Area | Baseline | Current | Result |
| --- | ---: | ---: | --- |
| Build an Atom | 186 → 211 (P7) → 221 (P8 Home) | **221** | PASS |
| Atom lifecycle / isolation | — | phase7_lifecycle_regression_test | PASS |
| Symbol lifecycle | — | phase7 + symbol_lifecycle_test | PASS |
| Game lifecycle / timer / stress | — | phase7 (20-cycle + 50-cycle) | PASS |
| Behavioral acceptance (Phase 6) | 33 | re-run with suite | PASS |
| Golden | 34 | 34 + Home 2 = **36** | PASS |
| Golden determinism | — | golden_determinism_test + Phase 9 ×3 runs | PASS |
| Home integration | — | build_an_atom_home_* (+ golden) | PASS |
| Android runtime | NOT VERIFIED | integration_test BAA smoke 5/5 | **VERIFIED** |
| IAAM | 108 | 108 | PASS |
| Shared Chemistry (BAM smoke) | — | build_a_molecule suite | PASS |
| Analyze | CLEAN | CLEAN | PASS |

## Phase 7 fixes

| Issue | Fix |
| --- | --- |
| Timer continues conceptually after leave | `GameScreen.dispose` → `timer.stop()`; resume via `_resumeTimerIfNeeded` on return |
| StatusBar overflow when Timer ON (~31px) | `GameStatusBar` → `FittedBox` + compact spacing |
| GameModel.dispose vs ChangeNotifier | Do **not** override `ChangeNotifier.dispose`; only stop timer from Screen |

## Docs

- `LIFECYCLE_MAPPING.md` — Screen / Model / Timer ownership  
- `BEHAVIORAL_ACCEPTANCE.md` — Phase 6 user tasks (still gated)  
