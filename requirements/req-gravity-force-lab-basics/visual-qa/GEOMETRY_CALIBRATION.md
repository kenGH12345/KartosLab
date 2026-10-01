# GEOMETRY_CALIBRATION — Gravity Force Lab: Basics

## Layout

| Item | Value |
|---|---|
| layoutBounds | 768 × 464 |
| MVT | scale **0.05**, inverted Y, origin at layout center |
| Background | `#ffffc2` |
| Mass node Y | **215** (from top) |
| Distance arrow Y | **145** |
| Force arrow height | mass1 **125**, mass2 **175** |
| Mass controls Y | **385** (panel bottom ref) |
| Checkbox panel | right inset 15; fill `#f1f1f2` |
| Reset | bottom-right ≈ (maxX−10, maxY−10) |

## Model ↔ view

```
viewX = width/2 + modelX * 0.05
viewY = height/2 - modelY * 0.05   // masses use fixed view Y=215
```

Sphere view radius = `modelRadius * 0.05`.

## Interaction

- Snap 100 m; track ±5000 m
- minSeparation 200 m (surface gap) + radii
- NumberPicker ±1e9 kg, range 1e9…10e9
