# PHASE_7 — Full Regression Report

日期：2026-09-22

## Commands

```bash
flutter test test/reactants_products_and_leftovers/
# → 119 PASS

dart analyze lib/reactants_products_and_leftovers \
  test/reactants_products_and_leftovers \
  lib/screens/home_screen.dart
# → No issues found

flutter test
# → +2668 ~1 -56  (Some tests failed.)
```

原始日志：`PHASE_7_FULL_TEST_RAW.txt`（Tee 输出）

## Totals（full project）

| Metric | Count |
|---|---:|
| Passed | 2668 |
| Skipped | 1 |
| Failed | 56 |
| RPL-specific failures | **0** |

## RPL-specific

| Suite | Result |
|---|---|
| `test/reactants_products_and_leftovers/**` | **119 PASS** |
| 含 Home entry / navigation / lifecycle / re-entry | PASS |
| 含 Final QA / Game pools / zero-product | PASS |

## Failed tests — all unrelated to RPL

| Simulation / area | Tests | Error type | RPL-related? |
|---|---:|---|---|
| `gas_properties` screenshot/golden | 2 | golden mismatch `[E]` | **No** |
| `chemistry/states_of_matter` visual_qa_capture | 15 | capture/visual `[E]` | **No** |
| `pendulum_lab` visual_qa_capture | 18 | capture/visual `[E]` | **No** |
| `projectile_motion` visual_qa_capture | 20 | capture/visual `[E]` | **No** |
| `forces` `netforce-tug scenario has valid pullers` | 1 | **TimeoutException 10 min** | **No** |

无任何路径包含 `reactants_products_and_leftovers`。

## Classification

```text
Full Regression = PASS WITH KNOWN UNRELATED FAILURES
```

依据 Phase 7 规则：RPL 自身无 regression；既有 unrelated failures 已区分；未修改 unrelated simulations。

## Code changes this phase

```text
CODE CHANGES = 0
```
