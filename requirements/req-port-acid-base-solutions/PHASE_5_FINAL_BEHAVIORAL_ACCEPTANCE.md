# PHASE 5 — FINAL BEHAVIORAL ACCEPTANCE / FULL REGRESSION

**Sim:** PhET Acid-Base Solutions → Flutter  
**Req:** `req-port-acid-base-solutions`  
**Scope:** Acceptance only — no new UI, no chemistry/model changes, Home NOT TOUCHED

---

## PHASE 5 STATUS: PASS

```text
INTRO:
Water: PASS
Strong Acid: PASS
Weak Acid: PASS
Strong Base: PASS
Weak Base: PASS
Concentration: PASS (preset defaults + mutated C regen)
Views: PASS
PH Meter: PASS
PH Paper: PASS (250 px/s + reset clears)
Conductivity Tester: PASS (acid/base >0; pH===7 → 0)
Particles: PASS (counts == model; species ⊆ solution; rebuild stable)
Graph: PASS (model-driven values)
Equation: PASS
Reset: PASS
Lifecycle: PASS (x5)

MY SOLUTION:
Acid/Base: PASS (x5)
Weak/Strong: PASS (acid+base x3)
Concentration: PASS (min/default/max)
Strength: PASS (min/default/max)
Chemistry: PASS (combined matrix)
Particles: PASS
Graph: PASS
Equation: PASS
Views: PASS
Tools: PASS
Reset: PASS
Lifecycle: PASS (x5)

CROSS SCREEN:
Model Isolation: PASS
Tool Isolation: PASS
Rapid Navigation: PASS (x5)
Re-entry: PASS
State Isolation: PASS
Ticker/Listener: PASS (rebuild + paper pressed)

RESET STRESS:
Intro: PASS (x10)
My Solution: PASS (x10)

GOLDENS:
13 / 13 PASS

CHEMISTRY ORACLE:
A: PASS
B: PASS
C: PASS
D: PASS
E: PASS
F: PASS
G: PASS

Tests:
Previous: 126
Added: 28
Final: 154
All tests passed! (test/chemistry/acid_base_solutions/)

Acid-Base Regression:
PASS

Global Regression:
FAIL (other projects only)
  Acid-Base failures: 0
  Other project failures: >=15 (e.g. states_of_matter visual_qa_capture_test)
  Not modified.

Analyze:
No issues found!

P0: 0
P1: 0
P2:
  audio unavailable
  typography micro-deltas
  Show Solvent prefs dialog (Preferences-only in source)

Assets substituted: 0

Home:
NOT TOUCHED

Runtime:
NOT VERIFIED

Android:
NOT VERIFIED

Report:
requirements/req-port-acid-base-solutions/PHASE_5_FINAL_BEHAVIORAL_ACCEPTANCE.md
```

---

## Acceptance artifacts

| Item | Path |
|---|---|
| Phase 5 tests | `test/chemistry/acid_base_solutions/phase5_acceptance_test.dart` (28) |
| Oracle A–G | `oracle_chemistry_test.dart` + `oracle_tools_reset_test.dart` |
| Goldens | `golden_test.dart` + `goldens/*.png` (13) |

---

## Notes

- Model lock held: no chemistry / LogSlider mapping / reset-chain edits.
- Particle acceptance: View counts derived from controller layout match `absParticleCount` per species (H2O excluded from canvas).
- Cross-screen: separate `IntroController` / `MySolutionController` instances; tool positions and modes do not leak.
- Global `flutter test` exercised ABS goldens mid-suite without ABS `[E]`; unrelated sim visual captures failed — out of scope.

---

## Scope gates

```text
Home: NOT TOUCHED
Global READY: NOT DECLARED
Next: Phase 6 Home Integration / Release Gate
```
