# PHASE_2 — Sandwiches Screen Report

日期：2026-09-22  
Overall Status：**NOT READY**（Molecules / Game / Home 未做）  
Sandwiches Screen：**COMPLETE**

## Source Mapping

| PhET | Flutter |
|---|---|
| SandwichesScreenView | `view/sandwiches_screen.dart` |
| SandwichesModel + view Properties | `view/sandwiches_controller.dart` |
| ReactionBarNode + ReactionRadioButtonGroup | `view/widgets/reaction_bar.dart` |
| SandwichesEquationNode | `view/widgets/sandwiches_equation_node.dart` |
| SandwichesSceneNode | `view/widgets/sandwiches_scene.dart` |
| StacksAccordionBox + StackNode | `view/widgets/stacks_accordion_box.dart` |
| QuantitiesNode | `view/widgets/quantities_node.dart` |
| SandwichNode | `view/widgets/sandwich_icon.dart` |
| NumberSpinner | `view/widgets/rpal_number_spinner.dart` |
| ResetAllButton | `KratosResetAllButton` × 0.75 |

## Viewport

- Logical：835 × 504（FittedBox 等比适配）
- Before/After box：310 × 240
- 详见 `RPL_SANDWICHES_VIEWPORT_REPORT.md`

## Assets

| Asset | Path | Status |
|---|---|---|
| bread.png | `assets/simulations/reactants_products_and_leftovers/images/` | Original |
| cheese.png | 同上 | Original |
| meat.png | 同上 | Original |
| home/navbar icons | 同上 | Original（备用） |

**Substituted = 0**

## Features

| Feature | Status |
|---|---|
| Cheese / Meat and Cheese / Custom | PASS |
| Quantity 0–8 NumberSpinner | PASS |
| Custom coefficient 0–3 | PASS |
| StacksAccordionBox expand/collapse | PASS |
| Before/After stacks | PASS |
| Products + Leftovers | PASS |
| Equation + No "Reaction" | PASS |
| Real-time Model → View | PASS |
| Reset All | PASS |
| Game Show/Hide（未引入） | N/A — 正确排除 |

## Tests

```text
flutter test test/reactants_products_and_leftovers/
→ 29/29 PASS

dart analyze lib/reactants_products_and_leftovers test/reactants_products_and_leftovers
→ No issues found
```

含：`reaction_model_test.dart`（16）+ `sandwiches/sandwiches_screen_test.dart`（13）

## Defects

| Severity | Count | Notes |
|---|---:|---|
| P0 | 0 | |
| P1 | 0 | |
| P2 | 若干 | Accordion 按钮几何非 sun 精确；NumberSpinner 箭头为扁平三角；方程区 FittedBox 缩放（Custom 三 spinner） |

## VERSION_DELTA

- Accordion 展开动画用 `AnimatedSize` 200ms（sun AccordionBox 时序可能略不同）
- Stack quantity：立即显隐（与 source 一致，无额外动画）
- Recipe radio 选中色近似 Aqua（非完整 sun 渐变）

## Next

**PHASE 3 — Molecules Screen**（勿接 Home / Game）
