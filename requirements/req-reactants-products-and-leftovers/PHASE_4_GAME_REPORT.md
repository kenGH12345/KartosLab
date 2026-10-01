# PHASE_4 — Game Report

日期：2026-09-22  
范围：Game Screen only（Home 未接）

## Status

```text
Sandwiches = COMPLETE
Molecules  = COMPLETE
Game       = COMPLETE
Home       = NOT STARTED
Overall Status = NOT READY
```

## Source Mapping

见 `PHASE_4_GAME_VIEW_SOURCE_MAP.md`。

核心映射：

| Source | Flutter |
|---|---|
| GameModel.ts | `model/game_model.dart` |
| ChallengeFactory.ts | `model/challenge_factory.dart` |
| Challenge.ts / GameGuess.ts | `model/challenge.dart` / `game_guess.dart` |
| PlayState / GamePhase / GameVisibility | `model/game_enums.dart` |
| ReactionFactory pools | `model/reaction_factory.dart` |
| GameScreenView | `view/game_screen.dart` |
| SettingsNode | `view/widgets/game_settings_node.dart` |
| PlayNode | `view/widgets/game_play_node.dart` |
| ChallengeNode | `view/widgets/challenge_node.dart` |
| ResultsNode | `view/widgets/game_results_node.dart` |
| GameButtons | `view/widgets/game_buttons.dart` |
| RandomBox | `view/widgets/game_random_box.dart` |

## Level Mapping

| UI Level | Index | Interactive | Pool | Challenges |
|---:|---:|---|---:|---:|
| 1 | 0 | Before | 39 | 5 |
| 2 | 1 | After (1 product) | 21 | 5 |
| 3 | 2 | After (2 products) | 18 | 5 |

## Challenge Pool

- Level1 = LEVEL2 ∪ LEVEL3 = 39
- Exactly 1 zero-product challenge / set
- No duplicate reaction factories in a set
- Seeded `Random` injectable for tests

## PlayState

```text
FIRST_CHECK → NEXT | TRY_AGAIN
TRY_AGAIN → SECOND_CHECK (button or quantity edit)
SECOND_CHECK → NEXT | SHOW_ANSWER
SHOW_ANSWER → NEXT (fill correct, 0 pts)
NEXT → next challenge | RESULTS
```

## Answer Flow / Validation

```text
UI spinner → GameGuess quantities → GameModel.check() → Challenge.isCorrect()
```

无 View 硬编码答案。

## Score / Progress

- First check correct: +2
- Second check correct: +1
- Show answer: 0
- Perfect = 10
- Progress: `N of 5`（status bar）

## Feedback

- Wrong: frown face + Try Again / Show Answer
- Correct: smile face + points + Next
- Results: stars + score + optional timer + Continue → Settings
- Perfect: reward confetti painter

## Reset

`GameModel.reset()` → settings defaults；Settings 页 `KratosResetAllButton`。

## Assets

- MoleculeIcon for H2/O2/N2/H2O/NH3/CH4/CO2
- 其余 Game 分子：`SubstanceIcon` → FormulaText chip（VERSION_DELTA）
- Substituted bitmap assets = **0**
- HideBox / Timer / Face：CustomPainter（无 Material Icons）

## Tests

```text
flutter test test/reactants_products_and_leftovers/
→ 62 PASS
  (Sandwiches + Molecules + Game + reaction model)
```

## Analyze

```text
dart analyze lib/reactants_products_and_leftovers test/reactants_products_and_leftovers
→ No issues found
```

## P0 / P1 / P2

| Sev | Item | Status |
|---|---|---|
| P0 | Level select / play / check / next / reset | PASS |
| P0 | 5 challenges × 3 levels | PASS |
| P1 | Score / PlayState / validation | PASS |
| P1 | RandomBox layout fidelity | APPROX (VERSION_DELTA) |
| P2 | Full nitroglycerin molecule set for all 39 | DEFERRED (FormulaText chip) |
| P2 | Face / reward chrome polish | APPROX |

## VERSION_DELTA

1. RandomBox 位置为 seed 伪随机，非 scenery RandomBox 逐字节布局
2. Game 中非 Molecules-screen 分子用 FormulaText chip，非完整 AtomNode geometry
3. LevelCompletedNode / FiniteStatusBar 为语义等价 Flutter 重建
4. 无 Why? 面板（source Game 无独立 Why 解释节点）

## Gate

- [x] Game works end-to-end
- [x] Regression Sandwiches + Molecules PASS
- [x] Analyze clean
- [ ] Home — NOT STARTED
- [ ] Overall READY — **blocked on Home**
