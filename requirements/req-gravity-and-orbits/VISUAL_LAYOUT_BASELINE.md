# VISUAL_LAYOUT_BASELINE · Gravity and Orbits

> Stage 参考：`GravityAndOrbitsSceneView` SCALE=0.8, WIDTH=790/0.8, HEIGHT=618/0.8  
> Flutter：单场景 MVT（`GaoMvt.fromZoom`），禁止多层 FitBox/AspectRatio/Painter.scale 叠加。

## Single scene transform

```
defaultZoomScale (ModeConfig.zoom) × zoomLevel [0.5,1.3]
  → z = scale × 1.5e-9
  → modelBounds centered on gridCenter
  → viewBounds = Rect(30, 0, stageW×(H-50)/H, stageH×(H-50)/H)
  → createRectangleInvertedYMapping
```

## Regions

| Region | Placement |
|---|---|
| Play area | Left Expanded, black |
| Zoom | Top-left of play area |
| Return Objects | Top center when out of bounds / collided |
| Time control + counter | Bottom-left of play area |
| Reset All | Bottom-right of play area (`KratosResetAllButton` r=20.5) |
| Right panel (scenes/gravity/checkboxes) | Width ~220, stroke #8E9097 |
| Mass panel | Below right panel |
| Measuring tape | To Scale only when checkbox on |

## Body display

`viewDiameter = |modelDeltaToViewDelta(diameter)|` clamped [8,400]；PNG `BoxFit.contain`；无非等比拉伸。

## Vectors

`tip = modelToView(position + vector × displayScale)` ≡ `tail + modelToViewDelta(vector×scale)`（线性 MVT）。

## Checklist

- [x] Single MVT
- [x] Original body PNGs
- [x] KratosResetAllButton
- [ ] Pixel-perfect panel spacing vs PhET (Visual QA)
- [ ] Measuring tape full drag (stub → full)
