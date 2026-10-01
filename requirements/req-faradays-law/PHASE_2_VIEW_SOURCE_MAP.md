# PHASE 2 — VIEW SOURCE MAP · Faraday's Law

| PhET View | Flutter |
|-----------|---------|
| `FaradaysLawScreen` | `FaradaysLawScreen` |
| `FaradaysLawScreenView` | `FaradaysLawPlayArea` |
| `CoilsWiresNode` | `CoilsWiresPainter` |
| `BulbNode` | `BulbWidget` + `_BulbPainter` + `light_bulb_base.png` |
| `CoilNode` back | `CoilImageLayer(front: false)` |
| `CoilNode` front | `CoilImageLayer(front: true)` |
| `VoltmeterAndWiresNode` / `VoltmeterNode` / `VoltmeterGauge` | `VoltmeterWidget` + `VoltmeterPainter` + wires painter |
| `MagnetNodeWithField` | magnet `GestureDetector` host in `FaradaysLawPlayArea` |
| `MagnetFieldLines` | `FieldLinesPainter` |
| `MagnetNode` | `MagnetPainter` |
| `MagnetMovementArrowsNode` | `MagnetArrowsPainter` |
| `ControlPanelNode` | **Phase 3** (not in Phase 2) |
| `FlipMagnetButton` / Reset / Checkboxes | **Phase 3** |

## Layout constants

| Source | Flutter |
|--------|---------|
| `LAYOUT_BOUNDS` 834×504 | `FaradaysLawConstants.layoutSize` |
| background `rgb(151,208,255)` | `0xFF97D0FF` |
| `BULB_POSITION` (190,200) | same + `bulbXDisplacement -45` |
| `VOLTMETER_POSITION` | (190, 80) |
| magnet 140×30 @ (647,200) | same |
| bottom coil (448,310) / top (422,110) | same |
| coil image scale `1/3` | `coilImageScale` |
| `CoilNode.xOffset` / `twoOffset` | 8 / 8 |
| field ellipses LINE_DESCRIPTION | `kFieldLineEllipseSpecs` |

## Z-order (implemented)

```text
background (#97D0FF)
→ CoilsWiresPainter
→ BulbWidget
→ coil backs (4 + optional 2)
→ VoltmeterWidget (if visible)
→ FieldLinesPainter
→ Magnet (+ arrows)
→ coil fronts (4 + optional 2)
```

Matches source: magnet sandwiched between coil back/front; field lines travel with magnet layer.
