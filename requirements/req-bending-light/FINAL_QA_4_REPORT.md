# FINAL QA-4 Report — Visual Convergence

Date: 2026-09-18

Official runtime: phet-dev **1.2.5** (2026-06-24). Local source: **1.3.0-dev.0**. These are not the same visual baseline. `OFFICIAL VERSION MATCH = NOT VERIFIED`.

Android runtime: **NOT VERIFIED**. Home: **UNCHANGED**. No Home integration.

## 1. Fixed

### Viewport / chrome

`BendingLightViewport` is a fixed 1024×618 box. The QA AppBar and the debug banner sit outside it. Stage coordinates stay 834×504. The stage is placed the way the 1.2.5 capture was measured: content ends at y=569, scale `569/504`, horizontally centered. There is no `+56` or debug offset inside MVT.

Checked on the Intro frame: pixel (500, 560) is official `(200, 226, 246)` and Flutter `(199, 226, 246)`.

The bottom 49px is left empty. A fake joist navbar was not drawn.

### PhetFont

`PHET_FONT_MAPPING.md`. Family comes from `sceneryPhetQueryParameters.fontFamily` default `'Arial'`, then `PhetFont` appends `', sans-serif'`. Flutter uses that family. Sizes that were wrong relative to a `new PhetFont(n)` call were updated, including material title 12 bold, combo items 10, “What is n?” 16, Objects / prism labels 10, chart title `16 × 0.93`, intensity title `24 × 0.6`.

### White light

Color formula was not changed. The black environment now fills the 1024×618 viewport when white mode is on, matching `fillRect` of the full canvas, not only the widget under the AppBar. Beam rows at y≈235 line up with the official frame. The play-area band y=160–240, x<640 has mean absolute RGB under 4.

### Graph

The chart is centered on `bodyPosition` at `135×100` scaled by `0.93`. It is painted after the toolbox. Source puts the toolbox in `beforeLightLayer2` and the wave sensor in `afterLightLayer2`. The blue body on the Flutter canvas is about 136×100 px. The previous capture was a 25 px sliver.

Waveform math was not changed.

### Sensors

Positions and the velocity scale `1.5e-14` were not changed. Probe gradient was not restyled.

### Protractor

Left in the toolbox. The default official frames also leave it there. It was not dragged out, so the glyph was not registered.

## 2. Evidence

Flutter PNGs are the simulation viewport only, 1024×618, cropped at y=56 of a 1024×740 window (AppBar above the viewport). Official PNGs are the existing 1.2.5 captures.

| Scene | Official | Flutter | Side by side | Overlay |
|---|---|---|---|---|
| Intro | `visual-qa/official/OFFICIAL_INTRO.png` | `visual-qa/flutter/FINAL4_INTRO.png` | `visual-qa/final4/FINAL4_INTRO_SIDE_BY_SIDE.png` | `visual-qa/final4/FINAL4_INTRO_OVERLAY.png` |
| More Tools | `OFFICIAL_MORE_TOOLS.png` | `FINAL4_MORE_TOOLS.png` | `FINAL4_MORE_TOOLS_SIDE_BY_SIDE.png` | `FINAL4_MORE_TOOLS_OVERLAY.png` |
| Prisms | `OFFICIAL_PRISMS.png` | `FINAL4_PRISMS.png` | `FINAL4_PRISMS_SIDE_BY_SIDE.png` | `FINAL4_PRISMS_OVERLAY.png` |
| White Light | `OFFICIAL_WHITE_LIGHT.png` | `FINAL4_WHITE_LIGHT.png` | `FINAL4_WHITE_LIGHT_SIDE_BY_SIDE.png` | `FINAL4_WHITE_LIGHT_OVERLAY.png` |
| Graph | `OFFICIAL_GRAPH.png` | `FINAL4_GRAPH.png` | `FINAL4_GRAPH_SIDE_BY_SIDE.png` | `FINAL4_GRAPH_OVERLAY.png` |
| Sensors | `OFFICIAL_SENSORS.png` | `FINAL4_SENSORS.png` | `FINAL4_SENSORS_SIDE_BY_SIDE.png` | `FINAL4_SENSORS_OVERLAY.png` |

Diff heatmaps: `visual-qa/final4/FINAL4_*_DIFF.png`.

Results:

- Intro play area (center cells) mean abs about 0.5–3. Right panels and the toolbox still differ. **MISMATCH**
- White light beam aligned. Lower toolbox/control band is not. **MISMATCH**
- Graph body is full size and on top of the toolbox. Fill is still solid `#005B86`, not the source vertical gradient. **MISMATCH**
- Sensors play-area center is close. Left probes and right panels are not. **MISMATCH**
- Protractor glyph: **NOT VERIFIED**

## 3. Pixel metrics

Before is the QA-3 mean of the three channel means, after an 834×504 registration. After is the QA-4 mean absolute RGB on the stage region y<569 of two raw 1024×618 frames. The crops are not the same, so a smaller After is not by itself a pass. Different-pixel ratio counts pixels whose max channel delta is greater than 12.

| Scene | Before | After | Different Pixel Ratio | Result |
|---|---:|---:|---:|---|
| Intro | 10.62 | 9.52 | 0.214 | MISMATCH |
| More Tools | 16.86 | 18.01 | 0.337 | MISMATCH |
| Prisms | 13.16 | 10.53 | 0.237 | MISMATCH |
| White Light | 62.82 | 51.08 | 0.269 | MISMATCH |
| Graph | 24.26 | 26.87 | 0.406 | MISMATCH |
| Sensors | 18.55 | 19.66 | 0.356 | MISMATCH |

Stage channel means (R/G/B):

- Intro 10.81 / 7.91 / 9.84
- More Tools 18.25 / 18.41 / 17.38
- Prisms 10.30 / 10.42 / 10.88
- White Light 51.03 / 51.42 / 50.78
- Graph 26.91 / 27.68 / 26.01
- Sensors 19.90 / 19.08 / 20.01

Full-frame means are higher because of the navbar strip: Intro 27.17, More Tools 35.01, Prisms 28.09, White Light 48.85, Graph 43.10, Sensors 36.48.

White light is not judged by the average alone. The beam band is under 4. The 51 comes from the lower half and the right-hand controls. Graph is not judged by the average alone. The 25 px clip is gone; the remaining difference is fill, waveform pixels, and the toolbox band.

## 4. Remaining P2

Not restyled in this pass:

- Probe gradient / bevel
- Velocity box highlight
- Laser metallic gradient
- Single-color ray opacity

Also still open, and not called P2, because they still move large regions:

- Chart body gradient (`#5EB4DE` → `#005B86`) and inner white plot versus the solid blue fill
- Toolbox and right-panel pixels versus the 1.2.5 frames
- Navbar strip (left empty on purpose)

## 5. Regression

- `flutter test test/bending_light/` — 142 passed. No tests removed.
- `dart analyze lib/bending_light` — no issues.

The temporary Flutter web server was stopped after the captures. Exit code 1 from that process is expected. It is not a launch failure.

## 6. Final status

**NOT READY**

The viewport basis and the graph clip are fixed. White-light beam geometry lines up. Typography has a source mapping, but the glyphs are not pixel-identical. Panel, toolbox, chart fill, and sensor chrome still fail a same-pixel check. Version match is still NOT VERIFIED. Android is NOT VERIFIED. Home was not touched.
