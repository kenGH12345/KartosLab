# PHASE 4 — NUMERIC REGRESSION

## Phase 1 fixtures A–E

Still locked in `test/wave_on_a_string/model/numeric_regression_test.dart` — **PASS**.

## Phase 4 fixtures

| Fixture | Coverage | File |
| ------- | -------- | ---- |
| F | Manual disturbance · y0/yMid/yEnd sequence + determinism | `numeric_dynamic_fixtures_test.dart` |
| G | Oscillate closed-form angle/y0 + Fixed LAST=0 | same |
| H | Pulse multi-frame triangular duration | same |

## Tolerance

Identical sequences: `1e-12`. Cross-path FRAME aggregation: `1e-6` / `1e-9`.
