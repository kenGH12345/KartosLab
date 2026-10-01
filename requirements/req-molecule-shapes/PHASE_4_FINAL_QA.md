# PHASE 4 — Final QA

## Verdict

```text
PHASE 4 COMPLETE
Overall Status: READY CANDIDATE
```

Home Integration **not** started（下一阶段单独进行）.

## Phase rollup

| Phase | Scope | Status |
|---|---|---|
| Phase 1 | Model verified | PASS |
| Phase 2 | Model Screen verified | PASS |
| Phase 3 | Real Molecules verified | PASS |
| Phase 4 | Final behavior + visual verified | PASS |

## Completion checklist

| Criterion | Result |
|---|---|
| Model Screen PASS | ✅ |
| Real Molecules Screen PASS | ✅ |
| 13 real molecules PASS | ✅ |
| Real / Model PASS | ✅ |
| Rotation PASS | ✅ |
| Options PASS | ✅ |
| Reset PASS | ✅ |
| VSEPR PASS | ✅ |
| Bond order PASS | ✅ |
| Lone pair PASS | ✅ |
| Geometry PASS | ✅ |
| Bond angle PASS | ✅ |
| 3D projection PASS | ✅ |
| Depth PASS | ✅ |
| Lifecycle PASS | ✅ |
| Tests ALL PASS | ✅ 58 |
| Analyze clean | ✅ |
| P0 = 0 | ✅ |
| P1 = 0 | ✅ |

## Remaining VERSION_DELTA (P2 only)

1. Lone-pair shell approximate (no full balloon OBJ mesh)
2. Bonding panel thumbnails are 2D CustomPaint (not WebGL dataURL)
3. Real ↔ Model toggle does not run source Attractor orientation match (coords/angles correct; view may jump)
4. Bond stroke uses single color (not A/B half-cylinder split)

No P0 / P1 open. These do not block Home Integration readiness of the two screens.

## Absolute rules kept

- No Model redesign / VSEPR semantic change
- No Real molecule data rewrite
- No Real / Model state merge
- No 3D→2D collapse
- No chemistry restrictions beyond source
- No Molecules and Light / Greenhouse / Basics logic
- No other simulation edits
- **No Home connection in this phase**

## Deliverables

| Doc | Path |
|---|---|
| Gap matrix | `PHASE_4_FINAL_GAP_MATRIX.md` |
| Behavioral QA | `PHASE_4_BEHAVIORAL_QA.md` |
| Visual matrix | `PHASE_4_FINAL_VISUAL_MATRIX.md` |
| This report | `PHASE_4_FINAL_QA.md` |
| Regression tests | `test/molecule_shapes/phase4/phase4_final_regression_test.dart` |

## Commands

```text
flutter test test/molecule_shapes/
→ 58 tests, All tests passed

dart analyze lib/molecule_shapes test/molecule_shapes
→ No issues found
```

### Global `flutter test` (recorded, not blocking)

```text
+2541 ~1 -56 — Some tests failed
```

Unrelated failures only (timeouts / visual capture), e.g.:

- `test/chemistry/states_of_matter/states_of_matter_visual_qa_capture_test.dart`
- `test/gas_properties/gas_properties_screenshot_capture_test.dart`
- `test/pendulum_lab/pendulum_visual_qa_capture_test.dart`
- `test/projectile_motion/projectile_visual_qa_capture_test.dart`
- `test/forces/forces_scenario_test.dart` (10 min hang)

**No Molecule Shapes code or tests were changed to chase global green.**  
Authoritative Molecule Shapes gate remains the scoped suite (58 PASS).

## Next phase

```text
HOME INTEGRATION + FINAL ACCEPTANCE
```

Do not start until explicitly kicked off.
