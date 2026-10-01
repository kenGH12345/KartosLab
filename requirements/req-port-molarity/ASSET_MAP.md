# Molarity — ASSET_MAP

> Phase 4 Visual QA · source: PhET `molarity` 1.6.0-dev.6  
> Official: https://phet.colorado.edu/sims/html/molarity/latest/molarity_all.html

## Policy

Priority: Original PhET Asset → Scenery geometry → Flutter Canvas equivalent.

**Substituted Assets: 0**

## Assets

| ID | Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Transform / Notes |
|----|---------------|---------|--------------|-------|----------|------|---------|-------------------|
| beaker | `molarity-main/images/beaker.png` (560×681) | `BeakerImageNode` / `BeakerNode` | `assets/chemistry/molarity/beaker.png` | 0.75 | 0 | none | 1.0 | SHA256 match with PhET source file. Cylinder POI: UL(98,192) LR(526,644) end BG(210,166) FG(210,218). |
| precipitate.mp3 | `molarity-main/sounds/precipitate.mp3` | `PrecipitateSoundGenerator` | `assets/chemistry/molarity/sounds/precipitate.mp3` | — | — | — | — | Audio (Phase 3). |
| softNoSolute_v2.mp3 | `molarity-main/sounds/softNoSolute_v2.mp3` | `ConcentrationSoundGenerator` | `assets/chemistry/molarity/sounds/softNoSolute_v2.mp3` | — | — | — | — | Audio (Phase 3). |

## Dynamic (no raster asset)

| Element | Source | Flutter |
|---------|--------|---------|
| Solution liquid | `SolutionNode` Path geometry | `_SolutionPainter` |
| Precipitate particles | `PrecipitateNode` rectangles | `_PrecipitatePainter` (seeded RNG for goldens) |
| Concentration bar / arrow | `ConcentrationDisplay` | `MolarityConcentrationDisplay` |
| Vertical sliders | `VerticalSlider` | `MolarityVerticalSlider` |
| Reset All | scenery-phet `ResetAllButton` | `KratosResetAllButton` radius `20.5×1.32` |
| Saturated! | `SaturatedIndicator` | `MolaritySaturatedBanner` |

## Layout (source-defined)

- Canvas: 1100×700 (`MolarityScreenView.layoutBounds`)
- Background: `#FFFFFF` (official runtime screenshot)
- Cluster centered on layoutBounds.center
- Relative offsets: `MolarityLayout` ↔ `MolarityScreenView.js` lines 249–302

## Visual judgment tags

- `[原版资源一致]` beaker.png byte-identical to PhET
- `[布局已对齐]` ScreenView relative placement constants
- `[动态绘制已对齐]` liquid ∝ V · C bar 0..5 · precipitate floor(200·p)
