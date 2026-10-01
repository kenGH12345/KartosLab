# PHASE 6 — Behavior Report

**req-id:** `req-port-ph-scale`  
**date:** 2026-09-22  

---

## PHASE 6 STATUS

```text
PHASE 6 STATUS: PASS
Overall Status: NOT READY
```

Reason Overall NOT READY: Phase 5 Visual still **PARTIAL**; Gates 7–9 remain.

Matrix: `PHASE_6_BEHAVIOR_MATRIX.md`

---

## Model

```text
UNCHANGED
```

Chemistry Model / Ratio / Particle Counts / Graph math **LOCKED**.  
Only behavioral wiring fix: `AutomaticKeepAliveClientMixin` on Macro / Micro / My Solution (source: joist keeps screen models across switch; TabBarView was disposing State).

---

## Tests

```text
Before: 66 PASS
After:  84 PASS  (+18 Phase 6 behavioral)
```

```text
flutter test test/chemistry/ph_scale/  → 84 PASS
dart analyze lib/chemistry/ph_scale    → CLEAN
```

New file: `test/chemistry/ph_scale/phase6_behavior_test.dart`

---

## Acceptance gates

| Gate | Status |
|---|---|
| Macro | **PASS** — autofill, solute, faucet rates/dilution/drain, probe null/in-fluid, Reset |
| Micro | **PASS** — Ratio/Counts sync acid/neutral/base; view+graph reset |
| My Solution | **PASS** — spinner 0.01, clamp [−1,15], pH→Ratio/Counts/Graph sync, volume→Counts |
| Ratio | **PASS** — 50/50 neutral; acid/base majority; not derived from Counts |
| Particle Counts | **PASS** — Avogadro from derived; volume↑ N↑ at fixed pH |
| Graph | **PASS** — values from `SolutionDerivedProperties` only |
| Graph Drag | **PASS** — My Solution H₃O→pH; empty V no-op; extremes clamp finite |
| Cross-Screen | **PASS** — independent models; KeepAlive preserves tab State |
| Reset | **PASS** — Macro/Micro/MySol model+view+graph equivalence |
| Lifecycle | **PASS** — dispose Macro+clock; tab switch KeepAlive |
| Extreme Values | **PASS** — pH −1/7/15 finite; sci notation no `e+` |
| SimulationClock | **HARNESS ISSUE** — `toImage` hang = visual harness only; interaction/dispose OK |

---

## Macro

```text
PASS
```

- Autofill 0.5 L water pH 7; solute → stock pH  
- Faucet max 0.25 L/s; dropper 0.05 L/s  
- Dilution / drain update volume+pH  
- Probe out-of-fluid → null display  

---

## Micro

```text
PASS
```

---

## My Solution

```text
PASS
```

No free-text pH (SOURCE NumberSpinner) — invalid = clamp only.

---

## Ratio / Particle Counts / Graph

```text
PASS / PASS / PASS
```

Single path: Model → Derived → Ratio | Counts | Graph.

---

## Cross-Screen

```text
PASS
```

SOURCE: three independent `createModel` instances; switch preserves.  
Flutter: KeepAlive aligned.

---

## Reset

```text
PASS
```

---

## Lifecycle

```text
PASS
```

---

## Extreme Values

```text
PASS
```

---

## SimulationClock

```text
HARNESS ISSUE (VISUAL only)
```

Interaction / dispose / reset unaffected.

---

## Analyze

```text
CLEAN
```

---

## Regression

```text
ph_scale suite: PASS (84)
Full-repo flutter test: DEFERRED → PHASE 7 (suite buffered/long-running; ph_scale gated CLEAN)
```

---

## P0 / P1 / P2

| Sev | Count |
|---|---|
| P0 | **0** |
| P1 | **0** |
| P2 | Phase 5 visual leftovers (faucet assembly, indicator bubble, joist chrome, screenshot matrix) — **out of Phase 6 scope** |

---

## Known Issues

1. Phase 5 Visual PARTIAL (screenshot pixel-diff deferred)  
2. SimulationClock + `toImage` harness hang (not behavioral)  
3. Visual P2 unchanged by design  

---

## Next Gate

```text
PHASE 7 — Full Regression
```

Then PHASE 8 Home Final → PHASE 9 Final Status.

```text
Phase 6 PASS ≠ Overall READY
```
