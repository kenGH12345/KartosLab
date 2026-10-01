# PHASE 7 — Mix View Source Map

> PhET: `MixturesScreenView.ts` + view deps · Flutter: Mix screen/controller/widgets  
> Viewport: **768 × 464** · Mix MVT origin **(246, 153)** = `(round(0.32W), round(0.33H))`

## Layout / MVT

| Item | PhET | Flutter |
|---|---|---|
| layoutBounds | 768×464 | `IaamConstants.layoutWidth/Height` |
| Mix MVT | inverted-Y, origin (246,153), scale 1 | `IaamTransform.mixScreen()` |
| Make MVT (unchanged) | (307,227) | `IaamTransform.makeScreen()` |
| Chamber | black rect, model 450×280 @ origin | view bounds via MVT + clip |
| Bucket Y | −250 | `kMixBucketY` |
| Slider control Y | −238 | `kMixSliderY` |
| PT | scale 0.55, top=10, right=W−10, Z≤18 | Mix PT widget |
| Composition accordion | left=PT.left, top=PT.bottom+15 | |
| Average accordion | top=composition.bottom+10 | |
| My/Nature radios | top=average.bottom+10 | |
| Eraser | top=chamber.bottom+5, left=chamber.left | |
| Mode radios | right=chamber.right, top=chamber.bottom+5 | |
| Reset All | right=maxX−10, bottom=maxY−10, scale 0.85 | `KratosResetAllButton` |

## Z-order (back → front)

1. Slider controls (`ControlIsotope`)
2. Bucket holes
3. Chamber (black)
4. Small-atom / Nature canvas (`IsotopeCanvasNode`)
5. Eraser, PT, accordions, radios, Reset
6. Large isotope `ParticleView`s
7. Bucket fronts

## Visibility

| State | Large ParticleViews | Canvas | Eraser / Mode |
|---|---|---|---|
| Nature | hidden | natures atoms | hidden |
| My + buckets | large atoms | hidden | shown |
| My + sliders | hidden | isotopesList | shown |

## Node → Flutter mapping

| PhET Node | Flutter |
|---|---|
| `MixturesScreenView` | `MixIsotopesScreen` |
| — | `MixturesController` |
| `ExpandedPeriodicTableNode` (Z≤18) | `MixExpandedPeriodicTable` / shared PT |
| `BucketHole` / `BucketFront` | `NeutronBucketPainter` + isotope color label |
| `ParticleView` (large) | positioned `CustomPaint` + drag |
| `IsotopeCanvasNode` | `IsotopeCanvasPainter` (single CustomPainter) |
| `ControlIsotope` | `ControlIsotopeWidget` |
| `IsotopeProportionsPieChart` | `IsotopeProportionsPieChart` |
| `AverageAtomicMassIndicator` | `AverageAtomicMassIndicator` |
| `IsotopeMixtureSelectionNode` | Aqua radios My / Nature |
| `InteractivityModeSelectionNode` | Rectangular radios bucket / slider icons |
| `EraserButton` | Mix eraser (DISPLAY_PANEL yellow + eraser glyph) |
| `ResetAllButton` | `KratosResetAllButton` |
| `getIsotopeColor` | `get_isotope_color.dart` |

## Colors

| Role | Value |
|---|---|
| Isotope cycle | purple `rgb(180,82,205)`, green, orangered `rgb(255,69,0)`, teal `rgb(72,137,161)` |
| Accordion | `#FEFF99` |
| Mode selected stroke | `#3291b8` |
| Mass pointer | `rgb(0,143,212)` |
| Chamber | black |

## Behavior ownership

| Concern | Owner |
|---|---|
| counts / Nature / averages / drop / packing | `MixturesModel` (frozen) |
| pointer → model drag | `MixturesController` |
| paint / layout / clip | View / Painter |
