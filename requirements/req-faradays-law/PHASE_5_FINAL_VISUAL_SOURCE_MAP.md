# PHASE 5 — FINAL VISUAL SOURCE MAP · Faraday's Law

> CODE CHANGES (lib/) = **0**. Audit against local PhET source + Flutter capture + Phase 0–3 maps.

## Visual item map

| Visual item | PhET source | Flutter implementation | Result |
| --- | --- | --- | --- |
| Viewport | `LAYOUT_BOUNDS` 834×504 (`FaradaysLawConstants.js`) | `FaradaysLawConstants.layoutSize` + `FittedBox` contain | PASS |
| Background | `rgb(151,208,255)` | `0xFF97D0FF` Scaffold + play `ColoredBox` | PASS |
| Field lines | `MagnetFieldLines.js` LINE_DESCRIPTION ellipses + arrows | `FieldLinesPainter` + `kFieldLineEllipseSpecs` | PASS (P2-03 tangent) |
| Coil back | `CoilNode` back mipmaps under magnet | `CoilImageLayer(front:false)` before magnet in Stack | PASS |
| Magnet | `MagnetNode.js` Path + N/S Text | `MagnetPainter` (orientation swap, not scaleX) | PASS (P2-01 / VD-FONT) |
| Coil front | `CoilNode` front mipmaps above magnet | `CoilImageLayer(front:true)` after magnet | PASS |
| Bulb | `BulbNode` + `lightBulbBase.png` | `BulbWidget` + `light_bulb_base.png` | PASS (P2-05) |
| Voltmeter | `VoltmeterNode` / `VoltmeterGauge` / wires | `VoltmeterWidget` + `VoltmeterPainter` | PASS (P2-02) |
| Control panel | `ControlPanelNode.js` strip | `FaradaysLawControlPanel` | PASS |
| Coil selector | `RectangularRadioButtonGroup` + scaled CoilNode | `CoilRadioGroup` + coil PNG icons | PASS (P2-C2) |
| Voltmeter checkbox | sun `Checkbox` + "Voltmeter" | `FlLabeledCheckbox` | PASS (P2-C3) |
| Field Lines checkbox | sun `Checkbox` + "Field Lines" | `FlLabeledCheckbox` | PASS (P2-C3) |
| Flip Magnet | `FlipMagnetButton.js` | `FlipMagnetButton` | PASS (P2-C1) |
| Reset All | scenery-phet `ResetAllButton` scale 0.75 | `KratosResetAllButton` r=20.5×0.75 | PASS |

## Source constant → Flutter value

| Constant | Source | Flutter |
| --- | --- | --- |
| Layout | 834 × 504 | same |
| Background | `#97D0FF` | `0xFF97D0FF` |
| Magnet size / default pos | 140×30 @ (647,200) | same |
| Bottom / top coil | (448,310) / (422,110) | same |
| Coil image scale | 1/3 | `coilImageScale` |
| Coil xOffset / twoOffset | 8 / 8 | same |
| Bulb position | (190,200) + x−45 | same |
| Voltmeter position | bulb − (0,120) → (190,80) | same |
| Magnet N/S colors | `#DB1E21` / `#354D9A` | same |
| Wire color / width | `#7F3521` / 3 | same |
| Field line stroke | white / 3 | same |
| Checkbox x | 174 | `left: 174` |
| Coil radio left | 377 | `left: 377` |
| Flip right | maxX−110 | `right: 110` |
| Reset right / scale | maxX−10 / 0.75 | `right: 10` / 0.75 |
| Flip baseColor | `rgb(205,254,195)` | same |
| Coil radio baseColor | `#cdd5f6` | same |

## Z-order (source-aligned)

```
background
→ CoilsWiresPainter
→ BulbWidget
→ coil backs (4 + optional 2)
→ VoltmeterWidget (if visible)
→ FieldLinesPainter
→ Magnet (+ arrows)
→ coil fronts (4 + optional 2)
→ ControlPanel
```

Verified in `FaradaysLawPlayArea` Stack order + visual matrix / H_combined capture (magnet through coil sandwich).

## Polarity rendering

Source flips orientation property; halves redraw with N/S labels upright.  
Flutter: `MagnetPainter` swaps half placement by `MagnetOrientation` — **no** `Transform(scaleX: -1)`.
