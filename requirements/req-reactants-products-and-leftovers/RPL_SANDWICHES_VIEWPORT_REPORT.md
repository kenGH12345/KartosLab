# RPL Sandwiches Viewport Report

Source：`RPALConstants.ts`, `RPALScreenView.ts`, `SandwichesSceneNode.ts`, `ReactionBarNode.ts`

## Logical Layout

```text
SCREEN_VIEW_LAYOUT_BOUNDS = 835 × 504
```

Flutter：`FittedBox` / `AspectRatio` 等比适配物理屏，内部以 835×504 为坐标系。

## Vertical Stack

```text
y=0
├── ReactionBarNode
│     height ≈ radioButtonGroup.height + 2×Y_MARGIN (Y_MARGIN=10)
├── gap 12
├── Scene (Before/After boxes 240 tall + quantities below)
└── Reset All @ (right-10, bottom-10), scale 0.75
```

## Horizontal Scene

```text
[Before 310×240] —10px— [Arrow] —10px— [After 310×240]
centerX = layoutBounds.centerX
```

## Quantities Alignment

- `beforeXOffsets = createXOffsets(reactants.length, 310)`
- `afterXOffsets = createXOffsets(products.length + leftovers.length, 310)`
- quantitiesNode.x = beforeAccordion.x
- quantitiesNode.top = beforeAccordion.bottom + 6

## createXOffsets

```text
xMargin = (n > 2) ? 0 : 0.15 * boxWidth
deltaX = (boxWidth - 2*xMargin) / n
xOffset_i = xMargin + deltaX/2 + i*deltaX
```

## Colors

| Element | RGB |
|---|---|
| Screen bg | 218, 236, 255 |
| Status / title bar | 51, 118, 196 |
| Box fill | white |
| Box stroke | 51,118,196 α0.3 |
| Bracket | 51, 118, 196 |

## Reset Button

```text
radius_effective = 20.5 × 0.75 ≈ 15.375
position: right = 835-10, bottom = 504-10
```
