# PHASE 0 — Source Audit

本地基准：`phet sourses/reactants-products-and-leftovers-main/reactants-products-and-leftovers-main`  
`package.json` 版本：`1.4.0-dev.0`  
`dependencies.json` 注释：`1.3.0-dev.6`（2024-10-28）  
入口：`js/reactants-products-and-leftovers-main.ts`

**唯一目标**：Reactants, Products and Leftovers（RPL）。禁止混入 Molecule Shapes / Molecules and Light / Balancing Chemical Equations 等。

## 1. Source Tree

| 路径 | 作用 |
|---|---|
| `js/reactants-products-and-leftovers-main.ts` | Sim 入口，注册 3 个 Screen |
| `js/ReactantsProductsAndLeftoversStrings.ts` | 字符串模块 |
| `js/common/model/` | `Reaction`, `Substance`, `RPALBaseModel`, `ReactionFactory`, `BoxType` |
| `js/common/view/` | `RPALScreenView`, `RPALSceneNode`, `QuantitiesNode`, `StacksAccordionBox`, `StackNode`, `HideBox` |
| `js/common/RPALConstants.ts` | layout bounds、数量范围、box 尺寸 |
| `js/common/RPALColors.ts` | 屏幕背景、面板、括号颜色 |
| `js/common/RPALSymbols.ts` | 化学式 HTML 符号 |
| `js/sandwiches/` | Sandwiches Screen（`SandwichesModel`, `SandwichRecipe`, `SandwichNode`） |
| `js/molecules/` | Molecules Screen（`MoleculesModel`） |
| `js/game/` | Game Screen（`GameModel`, `Challenge`, `ChallengeFactory`, Vegas 集成） |
| `images/` | bread/cheese/meat PNG + navbar/home icons |
| `assets/README.txt` | 三明治图像作者说明 |
| `reactants-products-and-leftovers-strings_en.json` | 英文 strings |
| `dependencies.json` | 依赖 SHA（含 nitroglycerin、vegas） |

## 2. Screens（阻塞确认）

```text
Reactants, Products and Leftovers
├── Sandwiches   SandwichesScreen
├── Molecules    MoleculesScreen
└── Game         GameScreen
```

来源：`reactants-products-and-leftovers-main.ts` 第 21–25 行。

## 3. 核心 Model 语义

### 3.1 Reaction（`js/common/model/Reaction.ts`）

- `reactants[]`, `products[]`, `leftovers[]`（leftovers 与 reactants 同序，各 1 leftover）
- `isReaction()`：多于 1 个系数 > 0，**或** 任一系数 > 1
- `getNumberOfReactions()`：对每个 `coefficient ≠ 0` 的 reactant 计算 `floor(quantity / coefficient)`，取 **最小值**
- `updateQuantities()`：
  - `product.quantity = numberOfReactions × product.coefficient`
  - `leftover[i].quantity = reactant[i].quantity − numberOfReactions × reactant[i].coefficient`
- `isReaction() == false` 时 `numberOfReactions = 0`（Custom 无效配方 → 无反应）

**Limiting reactant**：source 无独立 Property；即使 `floor(q/c)` 等于 `numberOfReactions` 的 reactant（可能多个并列）。

### 3.2 Substance（`js/common/model/Substance.ts`）

- `coefficientProperty`（整数，≥ 0，Custom 可改）
- `quantityProperty`（整数，≥ 0，默认 0）
- `symbol`（方程显示；三明治为内部名 bread/meat/cheese/sandwich）
- `iconProperty`（Scenery Node；Flutter 迁移阶段用占位或 asset id）

### 3.3 RPALBaseModel

Sandwiches / Molecules 共用：`reactions[]`, `reactionProperty`, `reset()` 重置选中反应及全部 reaction。

## 4. Sandwiches Screen

| 选项 | 配方 (bread, meat, cheese) | 产物 |
|---|---|---|
| Cheese | 2, 0, 1 | 1 sandwich |
| Meat and Cheese | 2, 1, 1 | 1 sandwich |
| Custom | 系数可变 0–3，三原料均存在 | 1 sandwich（系数有效时动态 `SandwichNode`） |

- Custom 无效配方（`isReaction()==false`）显示 `No "Reaction"` 字符串，产物图标为不可见占位
- 面板标题：`Before "Reaction"` / `After "Reaction"`（非 Molecules 的 Before Reaction）
- **无** Game 的 Show All / Hide Molecules / Hide Numbers 控件；折叠面板由 `beforeExpandedProperty` / `afterExpandedProperty` 控制（Accordion 减号按钮）

## 5. Molecules Screen

| 选项 | 反应式（source 系数） |
|---|---|
| Make Water | 2 H₂ + 1 O₂ → 2 H₂O |
| Make Ammonia | 1 N₂ + 3 H₂ → 2 NH₃ |
| Combust Methane | 1 CH₄ + 2 O₂ → 1 CO₂ + 2 H₂O |

分子图示来自 **nitroglycerin** `*Node`（Canvas 绘制，非 PNG）。

## 6. Game Screen

- **3 levels**（model 内 0-based），每 level **5 challenges**（`CHALLENGES_PER_LEVEL = 5`）
- Level 1：猜 **Before**，反应池 = 全部
- Level 2：猜 **After**，单产物反应池（21 条）
- Level 3：猜 **After**，双产物反应池（18 条）
- 计分：首次 Check 正确 +2，第二次 Check 正确 +1；Show Answer 后 0 分
- PlayState 流：`FIRST_CHECK → TRY_AGAIN → SECOND_CHECK → SHOW_ANSWER → NEXT`
- 可选 Timer；Stars = challenges 数，perfect = challenges × 2
- Show All / Hide Molecules / Hide Numbers：**仅 Game 设置页**（`GameVisibilityPanel`）
- Reset All：Settings 重置 best scores/times；Sandwiches/Molecules 另重置 accordion 展开状态

## 7. 数量与范围（source 常量）

| 常量 | 值 |
|---|---|
| `QUANTITY_RANGE` | 0 – 8 |
| `SANDWICH_COEFFICIENT_RANGE` | 0 – 3 |
| `SCREEN_VIEW_LAYOUT_BOUNDS` | 835 × 504 |
| `SANDWICHES/MOLECULES_BEFORE_AFTER_BOX_SIZE` | 310 × 240 |
| `GAME_BEFORE_AFTER_BOX_SIZE` | 330 × 240 |
| `RESET_ALL_BUTTON_SCALE` | 0.75 |

Reactant quantity 通过 `NumberSpinner` 调节；Game After 挑战中 products/leftovers 也用 spinner。

## 8. Reset 行为

| Screen | reset 恢复 |
|---|---|
| Sandwiches/Molecules | 默认反应（第一个）、各 substance quantity=0、coefficient 初值、accordion expanded=true |
| Game | timer/visibility/level/score/challenges/best scores & times 全部初值 |

## 9. 交付物索引

- `SCREEN_ARCHITECTURE.md` — Screen/View/Model 对照
- `SOURCE_BEHAVIOR_MATRIX.md` — 控件与交互矩阵
- `REACTION_MATRIX.md` — 全部反应数据
- `GAME_LEVEL_MATRIX.md` — Game level/challenge/scoring
- `VIEWPORT_REPORT.md` — layout bounds 与 box 尺寸
- `ASSET_AUDIT.md` — 资源清单与迁移策略

## 10. Phase 0 结论

- 三 Screen 结构明确，计算核心统一在 `Reaction.updateQuantities()`
- Show/Hide 语义在 Sandwiches/Molecules（accordion）与 Game（visibility panel）**不同**，不可混用
- 分子视觉依赖 nitroglycerin，需 Canvas/CustomPainter 或等价几何，禁止 generic 圆球终态
- 下一步：**PHASE 1 — 实现 Dart Reaction 模型 + 单元测试**
