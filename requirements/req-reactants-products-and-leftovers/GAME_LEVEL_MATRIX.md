# GAME_LEVEL_MATRIX — RPL

Source：`GameModel.ts`, `ChallengeFactory.ts`, `RPALLevelSelectionButtonGroup.ts`, `PlayState.ts`

## Level 概览

| Level (UI) | Model index | Interactive box | Challenge count | Perfect score | Stars |
|---:|---:|---|---:|---:|---:|
| 1 | 0 | Before | 5 | 10 | 5 |
| 2 | 1 | After | 5 | 10 | 5 |
| 3 | 2 | After | 5 | 10 | 5 |

`perfectScore = getNumberOfChallenges(level) × POINTS_FIRST_CHECK`（2）

## Level 按钮图标（source）

| Level | 左 | 右 | 含义 |
|---|---|---|---|
| 1 | ? | HCl | 猜 Before |
| 2 | H₂O | ? | 猜 After（单产物） |
| 3 | NH₃ | ?? | 猜 After（双产物） |

## Reaction Pool 大小

| Level | Pool size | 说明 |
|---:|---:|---|
| 1 | 39 | LEVEL2_POOL + LEVEL3_POOL |
| 2 | 21 | 单产物 |
| 3 | 18 | 双产物 |

## Challenge 结构

```text
Challenge
├── reaction: Reaction          # 正确答案（quantities 已设）
├── interactiveBox: BEFORE | AFTER
├── guess: GameGuess            # 用户答案（一侧 quantity 初值 0）
├── moleculesVisible: bool      # 来自 gameVisibility
├── numbersVisible: bool
└── points: int                 # 0, 1, or 2
```

### GameGuess 初始化

| interactiveBox | reactants | products | leftovers |
|---|---|---|---|
| BEFORE | clone(q=0) | clone(实际) | clone(实际) |
| AFTER | clone(实际) | clone(q=0) | clone(q=0) |

## Scoring

| 事件 | 分数 |
|---|---:|
| FIRST_CHECK 正确 | +2 |
| SECOND_CHECK 正确 | +1 |
| SHOW_ANSWER | 0 |
| TRY_AGAIN | 0 |

## PlayState 状态机

```text
                    ┌─────────────┐
                    │ FIRST_CHECK │
                    └──────┬──────┘
                     correct│ incorrect
                           ▼           ▼
                      ┌────────┐   ┌──────────┐
                      │  NEXT  │   │ TRY_AGAIN│
                      └───┬────┘   └────┬─────┘
                          │      user edits qty
                          │             ▼
                          │      ┌──────────────┐
                          │      │ SECOND_CHECK │
                          │      └──────┬───────┘
                          │       correct│ incorrect
                          │              ▼           ▼
                          │         ┌────────┐  ┌─────────────┐
                          └────────►│  NEXT  │  │ SHOW_ANSWER │
                                    └────────┘  └──────┬──────┘
                                                       ▼
                                                  ┌────────┐
                                                  │  NEXT  │
                                                  └────────┘
```

## Game Phase

| Phase | View | 进入条件 |
|---|---|---|
| SETTINGS | SettingsNode | 初始 / Results 返回 |
| PLAY | PlayNode | `play(level)` |
| RESULTS | ResultsNode | 最后一题 NEXT |

## Timer

- `timerEnabledProperty` 默认 false
- `play()` → `timer.start()`；最后一题正确或 `results()` → stop
- best time 仅在 timer enabled 且破纪录时更新（Vegas `GameUtils.updateScoreAndBestTime`）

## Visibility（Settings，影响下一局 `initChallenges`）

| Value | moleculesVisible | numbersVisible |
|---|---|---|
| SHOW_ALL | true | true |
| HIDE_MOLECULES | false | true |
| HIDE_NUMBERS | true | false |

## Reset（GameModel.reset）

重置：timerEnabled, gameVisibility, level, score, challenges, challengeNumber, gamePhase→SETTINGS, playState→NONE, 全部 bestScore=0, bestTime=null

## 随机化

- `dotRandom` 选 reaction、zero-product 题索引、quantities
- Flutter 需可注入 RNG 以便测试 deterministic seed

## Challenge Generation Detail（Phase 4）

```text
LEVEL
 → ChallengeFactory.createChallenges(level, maxQuantity=8, visibility)
 → pick 5 reactions from pool (no duplicate factory)
 → exactly 1 zero-product challenge (reactant qty < coefficient)
 → other 4: reactant qty ∈ [coefficient, maxQuantity]
 → clamp products/leftovers ≤ maxQuantity
 → Challenge(reaction, interactiveBox[level], moleculesVisible, numbersVisible)
 → GameGuess clones quantities (interactive side = 0)
```

### Question type by level

| Level | User answers | Known side |
|---:|---|---|
| 1 | reactant quantities (Before) | products + leftovers |
| 2 | product + leftover quantities (After) | reactants |
| 3 | product + leftover quantities (After) | reactants |

### Input

PhET NumberSpinner → Flutter `RpalNumberSpinner`（非裸 TextField）。

### Validation

`Challenge.isCorrect()` → `GameGuess.isCorrect(reaction)` 全量 equalsSubstance。

### Score / Progress

见上文 Scoring；progress 显示 `challengeNumber of numberOfChallenges`。

## Query Parameters（dev）

| Param | 效果 |
|---|---|
| playAll | 每 level 跑满 pool 全部反应 |
| showAnswers | 显示正确答案 debug text |
| showReward | 强制显示 reward |
| gameLevels | 限制可选 levels |

