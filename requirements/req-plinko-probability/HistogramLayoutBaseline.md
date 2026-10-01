# HistogramLayoutBaseline

Source: `phet …/common/view/HistogramNode.js` + `PlinkoProbabilityConstants.HISTOGRAM_BOUNDS`.

## Model bounds (shared Intro / Lab)

| Symbol | Value |
|---|---|
| HISTOGRAM_BOUNDS | `(-0.5, -1.70) → (0.5, -1.03)` |
| chart width (model) | `1.0` (= board width) |
| chart height (model) | `0.67` |

Mapped via the same `ModelViewTransform2` as the Galton board (rectangle inverted-Y).

## View chrome (ScreenView / layout px)

| Element | Rule |
|---|---|
| Background | `modelToViewBounds(HISTOGRAM_BOUNDS)`, fill white, stroke gray 0.5 |
| Banner | top = `modelToViewY(maxY)`, height = **20** layout px (not model) |
| Bar plot maxH | `(maxY−minY)_view − BANNER_HEIGHT − 3` |
| X ticks | `top = axisBottom + 5`, font 16, `centerX = binCenter` |
| **Bin** label | `centerX = hist center`, `top = tickBottoms + 5` |
| **Count/Fraction** | `left = axisLeft − 30`, `centerY = HISTOGRAM_BOUNDS.centerY`, `rotation = −π/2` |
| Mean triangle | tip at `modelToViewY(minY)`, W/H = 20 layout px, tip up into axis |

## Bin / Count anchors (not free-floating)

- **Bin** is parented to XAxisNode: below tick labels, centered on histogram X.
- **Count** is parented to YAxisNode: left of axis, vertically centered on hist bounds, rotated.
- Flutter: `HistogramLayout` + `HistogramPainter` must keep these offsets in **layout px × layoutScale**.

## Intro vs Lab

Same `HistogramNode` component; parent is the common ScreenView MVT.  
Screen-specific: visibility / mode set (Intro: counter|cylinder; Lab: counter|fraction) and Lab ideal overlay — **not** duplicated geometry constants.

## Capture alignment (Visual QA)

PhET `ScreenView.DEFAULT_LAYOUT_BOUNDS` = **1024 × 618** (not HomeScreen 768×504).

At 1280×800 content-crop (navbar y=737):

- scale = `min(1280/1024, 737/618)` ≈ **1.193**
- board/hist width ≈ 714；panel right ≈ 1212
- Capture fills the 1280×737 content band so `PlinkoMvt.fromCanvasSize` matches PhET.

## Bar height

Normalized sample distribution × `maxBarHeight` only. Do not change histogram model counts / mean / probability.
