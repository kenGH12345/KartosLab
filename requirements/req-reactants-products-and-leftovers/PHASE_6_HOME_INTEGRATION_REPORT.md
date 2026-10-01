# PHASE_6 — Home Integration Report

日期：2026-09-22

## Status

```text
Sandwiches = FINAL QA PASS
Molecules  = FINAL QA PASS
Game       = FINAL QA PASS
Home       = INTEGRATED
Overall    = READY CANDIDATE
```

Android = **NOT VERIFIED**（故非最终 READY）

## Wiring

```text
HomeScreen
  → 化学 → 反应物与生成物
      → ReactantsProductsAndLeftoversHome (KratosTabbedScreen)
          → SandwichesScreen | MoleculesScreen | GameScreen
```

| Item | Detail |
|---|---|
| Entry | `lib/reactants_products_and_leftovers/screens/reactants_products_and_leftovers_home.dart` |
| Registry | `lib/screens/home_screen.dart` `_SimEntry` + `_buildReactantsProductsAndLeftovers` |
| Controllers | Home 持有并 dispose（Plinko 模式） |
| Screens | Phase 1–5 实现，未改 Model / Challenge / Scoring |
| Card icon | `Icons.restaurant_outlined`（Home 统一 Material 策略） |
| Accent | `RpalColors.statusBarFill` |

## Freshness policy（明确）

依据 **KartosLab Home** 既有行为（Molecule Shapes / Plinko）：

> Back pop → dispose `*Home` 整树 → 再进 builder 新建 → **source-defined initial state**

不在导航层保留 Sandwiches / Molecules / Game 会话状态。

## Gates

| Gate | Result |
|---|---|
| Home integration | PASS |
| Navigation | PASS |
| Lifecycle | PASS |
| Re-entry | PASS |
| Phase 1–5 regression | PASS（含 Final QA） |
| Analyze | PASS |
| P0 / P1 | 0 / 0 |
| Substituted assets | 0 |
| Android | NOT VERIFIED |

## Tests

```text
flutter test test/reactants_products_and_leftovers/
→ 119 PASS

dart analyze … → No issues found
```

Home 新增：

- `home/rpl_home_entry_test.dart`
- `home/rpl_home_navigation_test.dart`
- `home/rpl_home_lifecycle_test.dart`
- `home/rpl_home_reentry_test.dart`

## Next

Phase 7 = Final Acceptance / Full Regression → 才可标 **READY**。
