# DEFAULT_SCREEN_CALIBRATION — Curve Fitting Visual QA

## Round notes (2026-09-05)

Visual QA P0/P1 pass addressing layout, control defaults, deviations barometer, and bucket geometry.

| Issue | Classification | Status |
|---|---|---|
| Order/Fit visible when Curve off | **[已确认源码：curveVisible=false hides Order/Fit]** (`ControlPanels.js` `linkAttribute`) | fixed — `ControlPanelsColumn` omits Order/Fit widgets |
| Graph squeezed by overlay panels | **[迁移布局问题]** Stack+Positioned gutters | fixed — explicit 3-column `Row` |
| Deviations incomplete (short bars, no ticks) | **[迁移 UI 缺口]** | fixed — full `BarometerNode` port |
| Bucket Material/approx look | **[资源/视觉迁移缺口]** | fixed — phetcommon `Bucket` geometry + Hole/Front gradients |

## Layout (3-column)

```
Row(
  LeftColumn  width = columnOuterWidth (210),
  Expanded(GraphColumn),  // MVT from GraphColumn Size
  RightColumn width = columnOuterWidth (210),
)
```

| Quantity | Value / rule |
|---|---|
| `panelMaxWidth` | 180 |
| `columnOuterWidth` | 210 ≈ panel + margins |
| Graph MVT | `MathCoordinateTransform.forGraphViewport(size)` |
| `viewOrigin` | GraphColumn center |
| `scale` | `min(graphColW, graphColH) / 20` (background span [-10,10]) |
| Shell | `CfPageShell` = `SizedBox.expand` (no rigid 1024×618 FittedBox) |

### Expected column fractions (normalized to full center width W)

**[待确认：缺截图文件]** — fractions below are computed, not pixel-measured.

| Region | Left edge | Right edge | Width / W |
|---|---|---|---|
| Left column | 0 | 210/W | 210/W |
| Graph column | 210/W | 1 − 210/W | 1 − 420/W |
| Right column | 1 − 210/W | 1 | 210/W |

Example at W=1024: left ≈ 0.205, graph ≈ 0.590, right ≈ 0.205.

Graph white background remains model `[-10,10]²`, centered in GraphColumn.

## Control panel default

- Source: `curveVisibleProperty = false` → Order + Fit `visible=false`
- Flutter: only `ViewOptionsPanel` (Curve / Residuals / Values) on default pump
- Widget test: `test/curve_fitting/default_controls_visibility_test.dart`

## Deviations / Barometer

- Axis height `BAROMETER_AXIS_HEIGHT` 270 (χ² slightly shorter for top arrow)
- Fill RIGHT of axis, grows upward; ticks + labels LEFT
- χ² ticks via `chiSquaredValueToRatio`: 0, 0.5, 1, 2, 3, 10, 30, 100
- r² ticks: 0, 0.25, 0.5, 0.75, 1
- Fill only when `curveVisible`; color from `ChiBarometerColor` / blue

## Bucket

- Hole: ellipse, LinearGradient black→`#c0c0c0`, stroke `#777`
- Front: `Bucket.containerShape` trapezoid/cubic + elliptical arc; luminance gradient on `rgb(65,63,117)`
- Z-order: hole → decorative points → front
- `POINT_POSITIONS` offsets in view px relative to hole center (+ (0,−6) pointsNode offset)

## Screenshot compare

**[待确认：缺截图文件]** — no PhET runtime PNGs captured this round. Use layout fractions above + widget test until screenshots exist under `visual-qa/screenshots/`.
