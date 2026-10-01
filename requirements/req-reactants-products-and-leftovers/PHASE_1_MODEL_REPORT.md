# PHASE 1 — Core Reaction Model Report

日期：2026-09-22  
状态：**PASS**（模型 + 单元测试）

## 实现范围

| 文件 | 对应 Source |
|---|---|
| `model/substance.dart` | `Substance.ts` |
| `model/reaction.dart` | `Reaction.ts` |
| `model/sandwich_recipe.dart` | `SandwichRecipe.ts` |
| `model/reaction_factory.dart` | `ReactionFactory.ts`（Molecules 三反应 + Game pool 子集） |
| `model/rpal_base_model.dart` | `RPALBaseModel.ts` |
| `model/sandwiches_model.dart` | `SandwichesModel.ts` |
| `model/molecules_model.dart` | `MoleculesModel.ts` |
| `model/game_guess.dart` | `GameGuess.ts` |
| `model/box_type.dart` | `BoxType.ts` |
| `rpal_constants.dart` | `RPALConstants.ts` |
| `rpal_symbols.dart` | `RPALSymbols.ts` |

## 未纳入 Phase 1（后续阶段）

- UI / ScreenView / QuantitiesNode
- `ChallengeFactory` 完整随机生成（Phase 4）
- `GameModel` 状态机（Phase 4）
- nitroglycerin 分子 Canvas
- PNG asset 复制

## 计算验证

与 `Reaction.ts` 一致：

- `isReaction()` 语义
- `numberOfReactions = min(floor(q/c))`
- products / leftovers 更新公式
- `limitingReactantIndices` 为 source 隐式行为的显式 helper（测试用）

## 测试

路径：`test/reactants_products_and_leftovers/reaction_model_test.dart`

覆盖：定义、数量变化、产物/剩余物、limiting reactant、zero/no reaction、reset、Sandwich/Molecules/GameGuess。

## 下一步

**PHASE 2 — Sandwiches Screen**（UI + PNG assets + StacksAccordionBox）
