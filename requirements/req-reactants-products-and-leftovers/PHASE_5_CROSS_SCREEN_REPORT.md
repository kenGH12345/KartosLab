# PHASE_5 — Cross-Screen Report

日期：2026-09-22

## Isolation model

PhET RPL：三屏各自独立 Model（本 Flutter 端口同样各自 `SandwichesController` / `MoleculesController` / `GameController`，无全局 singleton）。

## Tests

`test/reactants_products_and_leftovers/final/cross_screen_state_test.dart`

| Scenario | Result |
|---|---|
| Mutate Sandwiches + Molecules + Game concurrently | PASS — 彼此数量 / recipe / score 不互相覆盖 |
| Fresh instances after dirty peers | PASS — 新实例 = source defaults |
| Controllers / models not identical | PASS |

## Persistence rules（source-equivalent）

| Screen | In-memory while instance alive | New instance |
|---|---|---|
| Sandwiches | 保留 recipe / quantities / accordion 直到 Reset | Cheese, qty=0, accordion open |
| Molecules | 保留 reaction / quantities / accordion 直到 Reset | Make Water, qty=0 |
| Game | 保留 bestScores 直到 Reset；play() 清当前 score | Settings, score=0 |

## Game visibility / timer

确认 **未** 泄漏到 Sandwiches / Molecules（Game-only settings）。

## Cross-screen Result

**PASS**
