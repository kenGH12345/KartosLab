# PHASE_5 — Final Behavioral Report

日期：2026-09-22  
范围：Sandwiches + Molecules + Game Final Behavioral QA（**不含 Home**）

## Status

```text
Sandwiches = FINAL QA PASS
Molecules  = FINAL QA PASS
Game       = FINAL QA PASS
Home       = NOT STARTED
Overall Status = NOT READY
```

## Source re-check（未按 Flutter 反推）

| Area | Source | Confirmed |
|---|---|---|
| Sandwich recipes | Cheese(2,0,1) / Meat&Cheese(2,1,1) / Custom(0,0,0 mutable) | PASS |
| Quantity range | 0–8 | PASS |
| Custom coefficients | 0–3；`isReaction` 语义不变 | PASS |
| Molecules reactions | Water / Ammonia / Combust Methane | PASS |
| Game pools | 39 / 21 / 18；interactive Before/After/After | PASS |
| Challenges / level | 5；exactly 1 zero-product | PASS |
| Scoring | +2 / +1 / Show Answer=0 | PASS |
| PlayState | FIRST_CHECK→TRY_AGAIN→SECOND_CHECK→SHOW_ANSWER→NEXT→RESULTS | PASS |

## Sandwiches behavior

| Gate | Result |
|---|---|
| Recipe cycle | PASS |
| Quantity 0/1/normal/8 + clamp | PASS |
| Limiting reactant A/B / both / zero | PASS |
| Custom invalid / valid | PASS |
| Accordion ≠ model | PASS |
| Reset → defaults | PASS |

测试：`test/.../final/sandwiches_final_test.dart`

## Molecules behavior

| Gate | Result |
|---|---|
| 3 reactions | PASS |
| Quantity boundary all reactions | PASS |
| Stoichiometry via Model | PASS |
| FormulaText H₂O/NH₃/CH₄ | PASS |
| MoleculeIcon geometry set | PASS |
| Accordion / Reset | PASS |

测试：`test/.../final/molecules_final_test.dart`

## Game behavior

| Gate | Result |
|---|---|
| Pools 39/21/18 | PASS |
| Zero-product ×40 seeds ×3 levels | PASS |
| Level 1/2/3 full 5-question loops → Results 10 | PASS |
| Guess → GameGuess → check() | PASS |
| Try Again / Show Answer=0 | PASS |
| Check enabled rules | PASS |
| Next isolation | PASS |
| Level score isolation | PASS |

测试：`test/.../final/game_final_test.dart`

## Regression

```text
flutter test test/reactants_products_and_leftovers/
→ 106 PASS

dart analyze lib/reactants_products_and_leftovers test/reactants_products_and_leftovers
→ No issues found
```

## Code changes this phase

无 Model / 无布局重设计。仅新增 Final QA 测试与报告。P0=0，未触发行为修复。

## Gate table

| Gate | Result |
|---|---|
| Sandwiches behavior | PASS |
| Molecules behavior | PASS |
| Game behavior | PASS |
| Cross-screen isolation | PASS（见 CROSS_SCREEN 报告） |
| Reset | PASS（见 RESET 报告） |
| Lifecycle | PASS |
| Visual P0 | 0 |
| Visual P1 | 0 |
| Visual P2 | 见 VISUAL 报告 |
| Substituted assets | 0 |
| Tests | 106 |
| Analyze | PASS |
| Home | NOT STARTED |
| Android | NOT VERIFIED |
