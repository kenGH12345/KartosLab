# PHASE_3 — Molecules Screen Report

日期：2026-09-22  
Overall：**NOT READY**  
Molecules Screen：**COMPLETE**

## Source Mapping

| PhET | Flutter |
|---|---|
| MoleculesScreenView | `view/molecules_screen.dart` |
| MoleculesModel + accordion | `view/molecules_controller.dart` |
| ReactionBar + MoleculesEquationNode | `molecules_reaction_bar.dart` / `molecules_equation_node.dart` |
| MoleculesSceneNode | `molecules_scene.dart` |
| QuantitiesNode (symbols) | `molecules_quantities_node.dart` |
| nitroglycerin *Node | `molecule_icon.dart` CustomPainter |
| RichText formulas | `formula_text.dart` |

## Viewport

- 835 × 504（与 Sandwiches / RPALConstants 一致）
- Before/After：310 × 240，boxYMargin 6
- Titles：Before Reaction / After Reaction

## Reactions

| Order | Name | Equation |
|---|---|---|
| 1 | Make Water | 2 H₂ + O₂ → 2 H₂O |
| 2 | Make Ammonia | N₂ + 3 H₂ → 2 NH₃ |
| 3 | Combust Methane | CH₄ + 2 O₂ → CO₂ + 2 H₂O |

## Features

| Feature | Status |
|---|---|
| Reaction selector | PASS |
| Equation + subscripts | PASS |
| Molecule stacks (instances) | PASS |
| Quantity 0–8 | PASS |
| Products / Leftovers | PASS |
| Limiting reactant (model) | PASS |
| Accordion | PASS |
| Reset | PASS |
| Game Show/Hide | 正确未引入 |
| Sandwiches regression | PASS（29 旧测保留） |

## Assets / Molecules

- 无 Molecules PNG；nitroglycerin 几何 → CustomPainter（AtomNode 半径公式 + ShadedSphere 近似）
- Molecules 集合：H₂ O₂ H₂O N₂ NH₃ CH₄ CO₂
- **Substituted bitmap assets = 0**（分子为 source-geometry 绘制）

## Tests

```text
flutter test test/reactants_products_and_leftovers/
→ 44/44 PASS

dart analyze ...
→ No issues found
```

## Defects

| Sev | Count | Notes |
|---|---:|---|
| P0 | 0 | |
| P1 | 0 | |
| P2 | 若干 | ShadedSphere 高光非 scenery-phet 像素级；FormulaText baseline 近似 |

## VERSION_DELTA

- Oxygen 色使用 `FF5500`（RED_COLORBLIND 近似）
- Atom 球为径向渐变近似，非完整 ShadedSphereNode 高光网格

## Next

**PHASE 4 — Game Screen**
