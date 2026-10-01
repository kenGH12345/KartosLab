# ASSET_MAP — Charges and Fields

> Behavior Reference = local source `1.1.0-dev.12`  
> Visual Reference = published latest (cross-check)

| # | Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Transform | Notes |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `mipmaps/electricPotentialPanelOutline_png.ts` | ElectricPotentialSensorNode panel + toolbox icon | `assets/simulations/charges_and_fields/electricPotentialPanelOutline.png` | sensor ≈ `1.55*73.6/w`; toolbox smaller | 0 | none | 1 | Image.asset | Extracted from mipmap L0 base64 |
| 2 | `mipmaps/pencil_png.ts` | PencilButton | `assets/simulations/charges_and_fields/pencil.png` | ~26×20 @ 0.8 btn | 0 | none | 1 | Image.asset | Extracted from mipmap L0 base64 |

## Canvas / Path equivalents (not bitmap)

| Visual | Source | Flutter |
|---|---|---|
| ± charge disc + sign | ChargedParticleRepresentationNode | `ChargePainter` |
| E-field grid arrows | ElectricFieldArrowShape + CanvasNode | `ElectricFieldGridPainter` |
| Potential color grid | ElectricPotentialCanvasNode | `ElectricPotentialGridPainter` |
| Equipotential strokes | ElectricPotentialLineView | `EquipotentialLinesPainter` |
| Grid | GridNode | `CafGridPainter` |
| E-sensor disc | ElectricFieldSensorRepresentationNode | Container circle |
| Measuring tape | MeasuringTapeNode | Custom tape widgets |
| Eraser | scenery-phet EraserButton | `_EraserIconPainter` (geometry) |
| Reset All | ResetAllButton | **L0** `KratosResetAllButton` radius 20.8 |

## Substituted Assets

**Substituted = 0** (bitmaps are original PhET mipmaps; vector UI is Canvas rebuild per policy).
