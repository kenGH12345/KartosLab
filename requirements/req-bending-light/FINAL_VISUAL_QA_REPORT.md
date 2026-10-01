# Bending Light — FINAL VISUAL QA REPORT

Date: 2026-09-18

Status: **NOT READY**

P0 = 0. P1 = 0. Those counts are the earlier source-fidelity list. They are not a visual PASS.

Android runtime: **NOT VERIFIED**

Home: **UNCHANGED**

## Official Reference

| Item | Value |
|---|---|
| URL | `https://phet-dev.colorado.edu/html/bending-light/1.2.5/phet/bending-light_en_phet.html` |
| Official runtime version | **1.2.5**, chipper build `2026-06-24 06:06:49 UTC` |
| Local source version | **1.3.0-dev.0** |
| Version verdict | `Official runtime version != local source version`. `OFFICIAL VERSION MATCH = NOT VERIFIED`. `LATEST VERSION MISMATCH` |
| Viewport | 1024×618 CSS pixels, both sides |
| DPR | ≈ 1 (`deviceScaleFactor` 1). Official measured `1.0000000298023224` |
| Browser zoom | 100%. `visualViewport.scale` = 1 on the official capture |
| Fullscreen | no |
| Scrollbar | official sim root `overflow: hidden`. Flutter capture has no page scrollbar |
| Canvas | official scenery canvases CSS 1024×618. Flutter `flt-glass-pane` canvas **1024×618** |
| Official capture | live HTML, `Page.captureScreenshot`, after reload under the viewport override |
| Flutter capture | live debug web demo. Canvas `drawImage` + `toDataURL`. `Page.captureScreenshot` of that canvas is blank and was not used |

`VIEWPORT MISMATCH`. The windows are the same size, but the official frame includes the joist navbar (content ends at y=569) and the Flutter frame includes a 56px AppBar and the debug banner. Comparison crops those and scales both stages to 834×504. Raw 1024×618 frames are not treated as the same rectangle.

Files: `visual-qa/official/OFFICIAL_*.png`, `visual-qa/flutter/FLUTTER_*.png`. States: `visual-qa/official/OFFICIAL_RUNTIME_INFO.md`.

## Comparison

Layout in every pair is **OFFICIAL | FLUTTER**, same 834×504 crop, 50% overlay.

| Scene | Side-by-side | Overlay | Mean abs RGB | Result |
|---|---|---|---|---|
| Intro | `comparison/INTRO_SIDE_BY_SIDE.png` | `comparison/INTRO_OVERLAY.png` | 11.16 / 8.41 / 12.30 | MISMATCH |
| More Tools | `comparison/MORE_TOOLS_SIDE_BY_SIDE.png` | `comparison/MORE_TOOLS_OVERLAY.png` | 16.35 / 15.87 / 18.36 | MISMATCH |
| Prisms | `comparison/PRISMS_SIDE_BY_SIDE.png` | `comparison/PRISMS_OVERLAY.png` | 11.79 / 11.92 / 15.78 | MISMATCH |
| White Light | `comparison/WHITE_LIGHT_SIDE_BY_SIDE.png` | `comparison/WHITE_LIGHT_OVERLAY.png` | 63.55 / 63.85 / 61.07 | MISMATCH |
| Graph | `comparison/GRAPH_SIDE_BY_SIDE.png` | `comparison/GRAPH_OVERLAY.png` | 23.06 / 23.72 / 26.01 | MISMATCH |
| Sensors | `comparison/SENSORS_SIDE_BY_SIDE.png` | `comparison/SENSORS_OVERLAY.png` | 17.93 / 16.48 / 21.25 | MISMATCH |

Matched states:

- Intro: Air/Water, Ray, Normal on, tools in toolbox, laser off.
- More Tools: air over glass (n=1.5), Ray, sensors in toolbox, laser off.
- Prisms: single color, 650 nm, no prism, laser off.
- White light: `colorMode=white`, one ray, laser on, no prism. Flutter play-area black fraction 0.825. Official radio adapter was not updated on that frame; Flutter selected the white-light icon. The beam still does not register (mean abs ≈ 63, far above the panel-only diffs).
- Graph: wave view, laser on, wave sensor on, paused at `t=5.375e-13`.
- Sensors: ray view, laser on, intensity and velocity enabled at stored positions, not dragged onto the beam.

## Evidence

| Item | Result | Evidence |
|---|---|---|
| Layout | MISMATCH | Intro / More Tools / Prisms overlays above. Air/water boundary can sit within a few pixels after registration. Panels, toolbox, and laser still double. |
| Typography | MISMATCH | Same overlays. Labels do not occupy the same pixels. Source is `PhetFont`. Flutter sets `fontSize` only, so the web default family is not PhetFont. |
| Controls | MISMATCH | Panel and slider double edges on every overlay |
| Occlusion | MISMATCH | `FLUTTER_GRAPH.png`: chart blue pixels only x=194–219 (25px wide). Design chart is 126×93 |
| Protractor | NOT VERIFIED | Extra live degree text is not drawn. These six frames leave the protractor in the toolbox, so the glyph was not registered |
| Graph | MISMATCH | `GRAPH_OVERLAY.png` plus the clipped chart |
| Sensors | MISMATCH | `SENSORS_OVERLAY.png`. Intensity probe position on 1.2.5 did not match the Flutter constructor formula; sensor code was not changed to force a match |
| White Light | MISMATCH | `WHITE_LIGHT_OVERLAY.png` |
| Z-order | MISMATCH | Graph chart is covered or clipped. A tool overlapping the right panel (`bumpLeft`) was not in these frames, so that case stays NOT VERIFIED |

No visual row is PASS. Source correspondence is not used as a PASS.

## Remaining P2

Not restyled. The overlays do not isolate them from the panel offset, except where noted.

- Probe gradient / bevel
- Velocity box highlight
- Laser body metallic gradient
- Single-color ray opacity: paint follows `sqrt(powerFraction)` and `RAY_WIDTH * scale`. Intro and Prisms lasers are off, so that stroke is not in those overlays. Sensors has a laser-on ray, but the overlay also contains panel error, so opacity is not isolated. Left as P2, not a further formula edit.
- Protractor extra angle text: already removed. Not re-added. Glyph registration remains NOT VERIFIED.

White-light sampling, Snell, dispersion, and the wave equation were not edited.

One view fix was required to capture white light: `colorMode` was read outside `ListenableBuilder` in `prisms_play_area.dart`, so the black environment never appeared after `setLightType`. It is now read inside the builder. That does not change the white-light algorithm.

`?qa=white|graph|sensors` on the demo entry (`qa_launch.dart`) only reproduces these three frames. It is not a Home control.

## Runtime

`Android runtime NOT VERIFIED`

Flutter web captures used a temporary `flutter run -d web-server`. If that process is stopped after the PNG is saved, exit code 1 is expected.

`Exit code 1 is expected because the temporary Flutter Web service was intentionally terminated after capture.`

## Home

`UNCHANGED`

## Regression

| Check | Result |
|---|---|
| `dart analyze lib/bending_light` | No issues found |
| `flutter test test/bending_light/` | **142 passed**. No tests were deleted. |

## READY

**NOT READY**

Missing gates:

- Official runtime is 1.2.5, not local 1.3.0-dev.0.
- `VIEWPORT MISMATCH` (navbar vs AppBar), even though both windows are 1024×618.
- Layout, typography, controls, occlusion, graph, sensors, white light, and z-order are MISMATCH or NOT VERIFIED. None of those is PASS.
- Android runtime was not run.

P0 = 0 and P1 = 0 do not make this READY.
