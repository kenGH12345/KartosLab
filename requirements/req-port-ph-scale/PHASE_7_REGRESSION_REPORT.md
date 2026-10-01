# PHASE 7 REGRESSION REPORT

**req-id:** `req-port-ph-scale`  
**date:** 2026-09-22  

---

## Baseline

| Source | Evidence |
|---|---|
| Faraday Phase 7 | `requirements/req-faradays-law/PHASE_7_FULL_REGRESSION_REPORT.md` — **2805** pass / **1** skip / **56** fail |
| Reactants Phase 7 | `requirements/req-reactants-products-and-leftovers/PHASE_7_FULL_REGRESSION_REPORT.md` — ~2668 pass / **56** fail |
| Pattern | Same **−56** “KNOWN UNRELATED” set: visual QA capture timeouts + `netforce-tug` hang |

```text
Git = unavailable (not a git repository)
CODE CHANGES in Phase 7 = 0
```

---

## Current

### Command

```bash
flutter test
```

### Result

```text
Passed:  3119
Skipped: 1
Failed:  56
Duration: 689629 ms (~11.5 min)
EXIT_CODE: 1
Log: requirements/req-port-ph-scale/_p7_full_test.txt
```

---

## Comparison

| Metric | Faraday P7 baseline | Phase 7 (this run) |
|---|---|---|
| Passed | 2805 | **3119** (+ suite growth incl. pH Scale 84) |
| Skipped | 1 | **1** |
| Failed | **56** | **56** |
| pH Scale failures | — | **0** |
| New failures caused by pH Scale | — | **0** |

```text
Result = PASS WITH KNOWN UNRELATED FAILURES
Fail count vs Faraday Phase 7 baseline = IDENTICAL (56)
```

---

## pH Scale

### Command

```bash
flutter test test/chemistry/ph_scale/
```

```text
84 PASS
```

Unchanged vs Phase 6.

### Analyze

```bash
dart analyze lib/chemistry/ph_scale lib/screens/home_screen.dart
```

```text
CLEAN — No issues found!
```

---

## New Failures

```text
NONE attributable to pH Scale
```

No `[E]` lines under `test/chemistry/ph_scale/`.

---

## Pre-existing Failures

All **56** failures classified **PRE-EXISTING / KNOWN UNRELATED** (same families as Faraday Phase 7):

| Package | Count | Class |
|---|---|---|
| `projectile_motion` visual QA capture | 20 | C — harness / capture timeout |
| `pendulum_lab` visual QA capture | 18 | C — harness / capture timeout |
| `chemistry/states_of_matter` visual QA capture | 15 | C — harness / capture timeout |
| `gas_properties` screenshot golden | 2 | C — harness / golden |
| `forces` `netforce-tug` | 1 | C — hang / 10 min TimeoutException |

**Do not modify these sims for pH Scale acceptance.**

---

## Infrastructure / Harness

| Item | Class | Notes |
|---|---|---|
| SimulationClock + `toImage` | C — VISUAL-HARNESS | Phase 5/6 documented; not an app regression |
| visual_qa_capture / golden suites | C | Drive majority of −56 |
| netforce-tug 10 min timeout | C | Documented in Faraday Phase 7 |

---

## Build

```bash
flutter build apk --debug -t lib/main.dart
```

```text
PASS — Built build\app\outputs\flutter-apk\app-debug.apk
```

Assets / fonts / compile: OK. Kotlin plugin future-warning only (unrelated).

---

## Home

```text
PASS
```

Wiring (`lib/screens/home_screen.dart`):

```text
化学 → 溶液与浓度 → pH 标度 → PhScaleScreen
```

- Entry + builder present  
- `dart analyze` on `home_screen.dart` CLEAN  
- Peer Home smoke (`test/plinko_probability/browser_qa/home_lifecycle_test.dart`) PASS  
- pH Scale screen widget tests (3 tabs / graph chrome) PASS  

No Home redesign.

---

## Asset Regression

```text
PASS
```

- `pubspec.yaml`: `assets/simulations/ph_scale/images/` + `icons/`  
- Substituted = **0** (Phase 5/6)  
- No evidence of asset-name collisions in build  

---

## Lifecycle Regression

```text
PASS
```

- KeepAlive on Macro/Micro/My Solution (Phase 6) — covered by phase6 widget tests  
- Dispose + tab switch tests PASS  
- No duplicate global listeners / shared mutable state across sims  

---

## Font Regression

```text
PASS
```

- `PhScaleFonts` scoped under `lib/chemistry/ph_scale/` only  
- Not applied as global Theme  
- Other sims (e.g. molecule_polarity) use their own Arial — independent  

---

## Dependency Boundary

```text
PASS
```

```text
lib/chemistry/ph_scale/**
  ├── model / view / assets / tests
  └── Home: import PhScaleScreen only (home_screen.dart)
```

Shared: `KratosResetAllButton`, `SimulationClock` — read-only reuse, no shared API mutation in Phase 7.

---

## Changed Files

```text
Phase 7 CODE CHANGES = 0
```

Only documentation / test logs under `requirements/req-port-ph-scale/`.

Git unavailable — boundary verified via path search (`PhScaleFonts` / `PhScaleScreen` imports).

---

## P0

```text
0
```

## P1

```text
0
```

## P2

Phase 5 visual leftovers (unchanged by design):

- faucet/dropper assembly  
- indicator bubble  
- joist bottom chrome  
- screenshot matrix / pixel-diff incomplete  
- SimulationClock `toImage` harness  

---

## Phase 7 Status

```text
PHASE 7 STATUS: PASS
(with KNOWN UNRELATED FAILURES — fail count 56 = Faraday baseline)
```

## Overall

```text
NOT READY
```

Reason: Phase 5 Visual = **PARTIAL**; PHASE 8 Home Final + PHASE 9 Final Status remain.

---

## Next Gate

```text
PHASE 8 — Home Final Verification
```
