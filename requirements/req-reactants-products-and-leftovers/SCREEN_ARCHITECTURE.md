# SCREEN_ARCHITECTURE — RPL

Source：`js/reactants-products-and-leftovers-main.ts`

## Sim Shell

```text
Sim(title, [ SandwichesScreen, MoleculesScreen, GameScreen ])
```

KartosLab 迁移：沿用现有 `KratosTabBar` + 单 sim home 模式（参考 plinko_probability）。

---

## Screen 1 — Sandwiches

| 层 | Source 类 | 职责 |
|---|---|---|
| Screen | `SandwichesScreen` | 注册 screen name、background、model、view |
| Model | `SandwichesModel extends RPALBaseModel<SandwichRecipe>` | 3 个 `SandwichRecipe` |
| ScreenView | `SandwichesScreenView extends RPALScreenView` | equation bar + scenes + Reset All |
| Scene | `SandwichesSceneNode extends RPALSceneNode` | Before/After accordion + quantities |
| Equation | `SandwichesEquationNode` | 图像方程；Custom 可编辑系数 |
| Ingredient | `SandwichNode` | bread/meat/cheese PNG 堆叠；产物 sandwich |

### Controls

- 右上：`ReactionRadioButtonGroup`（Cheese / Meat and Cheese / Custom）
- Before/After：`StacksAccordionBox` + expand/collapse（减号按钮）
- 下方：`QuantitiesNode` — reactants NumberSpinner；products/leftovers 只读
- Custom：`SandwichesEquationNode` 内 coefficient NumberSpinner（0–3）
- 右下：`ResetAllButton`（scale 0.75）

### Layout

- `RPALScreenView`：`reactionBarNode.top = layoutBounds.top`
- `sceneNodes.top = reactionBarNode.bottom + 12`
- `contentSize = SANDWICHES_BEFORE_AFTER_BOX_SIZE (310×240)`

---

## Screen 2 — Molecules

| 层 | Source 类 | 职责 |
|---|---|---|
| Screen | `MoleculesScreen` | |
| Model | `MoleculesModel extends RPALBaseModel` | 3 个 `ReactionFactory` 反应 |
| ScreenView | `MoleculesScreenView extends RPALScreenView` | |
| Scene | `MoleculesSceneNode extends RPALSceneNode` | `showSymbols: true` |
| Equation | `MoleculesEquationNode` | RichText 系数 + 化学式 + 箭头 |

### Controls

- 右上：Make Water / Make Ammonia / Combust Methane
- 同 Sandwiches 的 accordion + quantities（标题为 Before/After **Reaction**）
- Reset All

### Layout

- `MOLECULES_BEFORE_AFTER_BOX_SIZE = 310×240`
- `minIconSize` 由最大分子节点尺寸决定

---

## Screen 3 — Game

| 层 | Source 类 | 职责 |
|---|---|---|
| Screen | `GameScreen` | |
| Model | `GameModel implements TModel` | phases, score, challenges, timer |
| ScreenView | `GameScreenView` | 3 phase nodes |
| Settings | `SettingsNode` | level select, visibility, timer, reset |
| Play | `PlayNode` | status bar + challenge area |
| Challenge | `ChallengeNode` | equation, RandomBox, QuantitiesNode, GameButtons |
| Results | `ResultsNode` | LevelCompletedNode + RPALRewardNode |

### Game Phases (`GamePhase`)

1. **SETTINGS** — `SettingsNode`
2. **PLAY** — `PlayNode` + `ChallengeNode`
3. **RESULTS** — `ResultsNode`

### Game Controls

| 控件 | 位置 | 模型 |
|---|---|---|
| Level 1/2/3 buttons | Settings 中央 | `model.play(level)` |
| Show All / Hide Molecules / Hide Numbers | Settings 下方 | `gameVisibilityProperty` |
| Timer toggle | Settings 左下 | `timerEnabledProperty` |
| Reset All | Settings 右下 | `model.reset()` |
| Check / Try Again / Show Answer / Next | Challenge 交互框内 | `PlayState` |
| Status bar (score, challenge #, timer) | Play 顶部 | Vegas `FiniteStatusBar` |

### Challenge View

- `RandomBox`：分子随机位置（非 stack）
- 猜 Before：before=guess spinners，after=answer 隐藏（HideBox）
- 猜 After：after=guess spinners，before=answer 显示
- `hideMoleculesBox` / `hideNumbersBox` 在 NEXT 前覆盖 answer 侧

---

## 共用 L0 映射（Flutter）

| PhET | KartosLab L0 |
|---|---|
| ResetAllButton | `KratosResetAllButton` radius 20.5×0.75≈15.4 或按 sim 定 |
| NumberSpinner | 待建 RPL NumberSpinner（禁 Material 默认） |
| Reaction radio | `KratosRadioGroup` 或 RPL 专用 |
| AccordionBox | RPL StacksAccordionBox |

---

## Screen 状态隔离

- 每 Screen 独立 `Model` 实例（PhET tandem 亦分 screen）
- Sandwiches quantity **不**泄漏到 Molecules / Game
- Game score/timer **不**影响其他 Screen
