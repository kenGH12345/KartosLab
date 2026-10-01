# REACTION_MATRIX — RPL

数据来源：`SandwichesModel.ts`, `MoleculesModel.ts`, `ReactionFactory.ts`, `ChallengeFactory.ts`

## 计算规则（全部反应共用）

```
numberOfReactions = min( floor(q_i / c_i) )  for all reactants with c_i ≠ 0
if NOT isReaction(): numberOfReactions = 0

product_j.quantity = numberOfReactions × product_j.coefficient
leftover_i.quantity = reactant_i.quantity − numberOfReactions × reactant_i.coefficient
```

`isReaction()` = (非零系数 reactant 数 > 1) OR (任一系数 > 1)

Limiting reactant：所有满足 `floor(q_i/c_i) == numberOfReactions` 且 `c_i > 0` 的 reactant（可多个）。

---

## A. Sandwich Recipes（Sandwiches Screen）

| Name | Bread c | Meat c | Cheese c | Product c | Notes |
|---|---:|---:|---:|---:|---|
| Cheese | 2 | 0 | 1 | 1 | reactants: bread, cheese |
| Meat and Cheese | 2 | 1 | 1 | 1 | reactants: bread, meat, cheese |
| Custom | 0–3 each | 0–3 each | 0–3 each | 1 | 用户编辑系数；无效→No Reaction |

### 示例（Cheese，bread=6, cheese=4）

| | Value |
|---|---:|
| numberOfReactions | min(floor(6/2), floor(4/1)) = 3 |
| Products (sandwich) | 3 |
| Leftover bread | 6 − 3×2 = 0 |
| Leftover cheese | 4 − 3×1 = 1 |
| Limiting | bread（并列时两者皆可） |

---

## B. Molecule Reactions（Molecules Screen）

| Name | Reactants (c) | Products (c) |
|---|---|---|
| Make Water | 2 H₂, 1 O₂ | 2 H₂O |
| Make Ammonia | 1 N₂, 3 H₂ | 2 NH₃ |
| Combust Methane | 1 CH₄, 2 O₂ | 1 CO₂, 2 H₂O |

### 示例（Make Water，H₂=6, O₂=4）

| | Value |
|---|---:|
| numberOfReactions | min(3, 4) = 3 |
| H₂O | 6 |
| Leftover H₂ | 0 |
| Leftover O₂ | 1 |

### 示例（Make Water，H₂=4, O₂=6）

| | Value |
|---|---:|
| numberOfReactions | min(2, 6) = 2 |
| H₂O | 4 |
| Leftover H₂ | 0 |
| Leftover O₂ | 4 |

---

## C. Game Reaction Pools

### Level 1（INTERACTIVE = Before，pool = Level2 ∪ Level3）

共 39 条 unique factory functions（见下表合并）。

### Level 2（INTERACTIVE = After，单产物）

| # | Equation |
|---|---|
| 1 | PCl₃ + Cl₂ → PCl₅ |
| 2 | 2 H₂ + O₂ → 2 H₂O |
| 3 | H₂ + F₂ → 2 HF |
| 4 | H₂ + Cl₂ → 2 HCl |
| 5 | CO + 2 H₂ → CH₃OH |
| 6 | CH₂O + H₂ → CH₃OH |
| 7 | C₂H₄ + H₂ → C₂H₆ |
| 8 | C₂H₂ + 2 H₂ → C₂H₆ |
| 9 | C + O₂ → CO₂ |
| 10 | 2 C + O₂ → 2 CO |
| 11 | 2 CO + O₂ → 2 CO₂ |
| 12 | C + CO₂ → 2 CO |
| 13 | C + 2 S → CS₂ |
| 14 | N₂ + 3 H₂ → 2 NH₃ |
| 15 | N₂ + O₂ → 2 NO |
| 16 | 2 NO + O₂ → 2 NO₂ |
| 17 | 2 N₂ + O₂ → 2 N₂O |
| 18 | P₄ + 6 H₂ → 4 PH₃ |
| 19 | P₄ + 6 F₂ → 4 PF₃ |
| 20 | P₄ + 6 Cl₂ → 4 PCl₃ |
| 21 | 2 SO₂ + O₂ → 2 SO₃ |

### Level 3（INTERACTIVE = After，双产物）

| # | Equation |
|---|---|
| 1 | C₂H₅OH + 3 O₂ → 2 CO₂ + 3 H₂O |
| 2 | 2 C + 2 H₂O → CH₄ + CO₂ |
| 3 | CH₄ + H₂O → 3 H₂ + CO |
| 4 | CH₄ + 2 O₂ → CO₂ + 2 H₂O |
| 5 | 2 C₂H₆ + 7 O₂ → 4 CO₂ + 6 H₂O |
| 6 | C₂H₄ + 3 O₂ → 2 CO₂ + 2 H₂O |
| 7 | 2 C₂H₂ + 5 O₂ → 4 CO₂ + 2 H₂O |
| 8 | C₂H₆ + Cl₂ → C₂H₅Cl + HCl |
| 9 | CH₄ + 4 S → CS₂ + 2 H₂S |
| 10 | CS₂ + 3 O₂ → CO₂ + 2 SO₂ |
| 11 | 4 NH₃ + 3 O₂ → 2 N₂ + 6 H₂O |
| 12 | 4 NH₃ + 5 O₂ → 4 NO + 6 H₂O |
| 13 | 4 NH₃ + 7 O₂ → 4 NO₂ + 6 H₂O |
| 14 | 4 NH₃ + 6 NO → 5 N₂ + 6 H₂O |
| 15 | SO₂ + 2 H₂ → S + 2 H₂O |
| 16 | SO₂ + 3 H₂ → H₂S + 2 H₂O |
| 17 | 2 F₂ + H₂O → OF₂ + 2 HF |
| 18 | OF₂ + H₂O → O₂ + 2 HF |

### Game Challenge 生成约束

- 每 level 5 题（`playAll` query 除外）
- 每局恰好 1 题 zero-product（reactant 全 > 0，products 全 0）
- 无重复 reaction（同局内）
- reactant quantity 随机 ∈ [coefficient, maxQuantity]（有产物题）
- zero-product：reactant quantity ∈ [1, max(1, c−1)]，且 reaction 不能全 c=1
- 超范围时用 `fixQuantityRangeViolation` 递减 reactants

---

## D. Symbol 表

见 `RPALSymbols.ts` + sandwich 内部符号 bread/meat/cheese/sandwich。

Flutter 显示须支持 HTML subscript（H<sub>2</sub>O → H₂）。
