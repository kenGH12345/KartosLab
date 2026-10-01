# VIEWPORT_REPORT — RPL

Source：`js/common/RPALConstants.ts`, `RPALScreenView.ts`, `SettingsNode.ts`, `PlayNode.ts`

## 全局 Layout Bounds

```text
SCREEN_VIEW_LAYOUT_BOUNDS = Bounds2(0, 0, 835, 504)
```

PhET 注释：不因 default layout 变化而修改（phet-io 兼容）。Flutter 迁移应以此为主设计 viewport，配合 `LayoutBuilder` 缩放。

**不要**假设 1024×618 或 768×504。

## 屏幕背景

`RPALColors.screenBackgroundColorProperty` = `rgb(218, 236, 255)`

## Before/After Box 尺寸

| Screen | Constant | Size (w×h) |
|---|---|---|
| Sandwiches | SANDWICHES_BEFORE_AFTER_BOX_SIZE | 310 × 240 |
| Molecules | MOLECULES_BEFORE_AFTER_BOX_SIZE | 310 × 240 |
| Game | GAME_BEFORE_AFTER_BOX_SIZE | 330 × 240 |

## Stack 布局（StacksAccordionBox）

- `maxQuantity` = QUANTITY_RANGE.max = **8**
- `boxYMargin`: Sandwiches 8，默认 6
- `deltaY = (contentHeight - 2×margin - maxIconHeight) / (maxQuantity - 1)`
- stacks 自底向上堆叠

## Scene 垂直布局（Sandwiches/Molecules）

```text
reactionBarNode.top = layoutBounds.top
sceneNodes.top = reactionBarNode.bottom + 12
quantitiesNode.top = beforeAccordionBox.bottom + 6
resetAllButton: right = layoutBounds.right - 10, bottom = layoutBounds.bottom - 10
resetAll scale = 0.75
```

## Reaction Bar

- 方程居中
- Radio group：`radioButtonGroup.right = layoutBounds.right - X_MARGIN`（ReactionBarNode）

## Game Settings 布局

```text
SCREEN_X_MARGIN = 40
SCREEN_Y_MARGIN = 40
title + levelButtons + visibilityPanel (VBox spacing 45) → center of layoutBounds
timerToggle: left = layoutBounds.left + 40, bottom = layoutBounds.bottom - 40
resetAll: right = layoutBounds.right - 40, bottom = layoutBounds.bottom - 40
```

## Game Play 布局

```text
statusBar at top of layoutBounds
challengeBounds = (left, statusBar.bottom, right, layoutBounds.bottom)
equation: top = challengeBounds.top + 10, arrow centered horizontally
beforeBox: right = arrow.left - 5
afterBox: left = arrow.right + 5
quantitiesNode.top = beforeBox.bottom + 4
GameButtons: centerX = guessBox.centerX, bottom = guessBox.bottom - 15
```

## 字体（source 参考）

| 用途 | Font |
|---|---|
| Quantity display/spinner | PhetFont 28 |
| Symbol below icon | PhetFont 16 |
| Bracket labels | PhetFont 12 |
| Equation coefficients (molecules) | 见 MoleculesEquationNode |
| Settings title | PhetFont 40 |
| Level label on button | PhetFont 45 |

## 颜色

| 元素 | Color |
|---|---|
| Status bar / title bar | rgb(51, 118, 196) |
| Box fill | white |
| Box stroke | DARK_BLUE alpha 0.3 |
| Bracket stroke | DARK_BLUE |

## KartosLab 三视口 QA 目标（Phase 5）

| 视口 | 尺寸 |
|---|---|
| Mobile | 375 × 667 |
| Tablet | 1024 × 768 |
| Desktop | 1920 × 1080 |

缩放策略：保持 835×504 逻辑坐标系，等比 fit（参考其他 sim MVT）。
