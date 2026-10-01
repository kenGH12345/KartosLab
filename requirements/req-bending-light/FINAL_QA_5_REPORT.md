# FINAL QA-5 Report — Source-exact UI

Date: 2026-09-19

Local source is bending-light `1.3.0-dev.0`. Official frames are phet-dev `1.2.5`. `OFFICIAL VERSION MATCH = NOT VERIFIED`.

Android: **NOT VERIFIED**. Home: **UNCHANGED**. Physics was not modified.

## Source geometry

Recorded in `SOURCE_GEOMETRY_SNAPSHOT.md` before the Flutter edits were judged. The constants that drive the new layout:

- Scene `layoutBounds` `834×504`. This is source. It is not replaced by `1024×618`.
- `FloatingLayout` padding 10 left/right, 15 top/bottom. At the default bounds, right panels sit at x=824 and bottom controls sit at y=489.
- Top medium panel bottom = 236. Bottom medium panel top = 273. Both are measured from `modelToViewY(0)`, not from the top of the window.
- Medium panel fill `#EEEEEE`, stroke `#696969`, line 1.5, radius 5, xMargin 13.5, slider track 210. `#f2fa6a` is an unused options default.
- Toolbox parent `beforeLightLayer2`. Graph parent `afterLightLayer2`. Right panels parent `afterLightLayer3`.
- Graph outer rectangle 135×100, scale 0.93, vertical gradient `#5EB4DE` to `#005B86`. Chart clip is the inner white rect eroded by 3. `126×93` is the scaled body rounded. `136×100` was a viewport color bbox, not a design size.

## Flutter geometry

`SourceLayout` holds those constants. Intro and More Tools place the medium panels on the interface anchors, the ray panel at left 10 / top 15, and the toolbox above the checkbox at the bottom. Prisms toolbox left is 12 and the bottom edge follows `floatBottom`. The graph body painter draws the source gradient, the inner blue rect, and the white plot. The waveform painter only draws the grid and the series. The wave equation was not touched.

## Source match

| Item | Result |
| --- | --- |
| Scene 834×504 inside a 1024×618 window | SOURCE MATCH for 834×504. Navbar y=569 is VERSION_DELTA (1.2.5 measurement, joist not in tree) |
| Panel fill, stroke, radius, width, right edge, vertical anchors | SOURCE MATCH |
| Panel slider thumb, combo box, arrow buttons | MISMATCH. Still Material widgets |
| Panel drop shadow | NOT VERIFIED. `sun/Panel` is not in the local tree |
| Toolbox parent, margins, fill, spacing, left/bottom anchors | SOURCE MATCH |
| Toolbox item graphics | MISMATCH. Icons are still text chips, not `ProbeNode` / protractor icon scale 0.24 |
| Graph gradient stops and direction | SOURCE MATCH |
| Graph z-order (graph above toolbox, below right panels) | SOURCE MATCH |
| Graph inner shaded highlight | MISMATCH. Source `ShadedRectangle` light is flattened to white |
| Graph waveform formula | SOURCE MATCH. Not edited |
| Sensor model positions | NOT VERIFIED as a new geometry pass. Positions were not moved |
| Protractor asset and scales 0.8 / 0.46 | SOURCE MATCH |
| Protractor extra degree text | SOURCE MATCH that local `ProtractorNode` draws none. Glyph pixels NOT VERIFIED (tool stays in the toolbox) |
| PhetFont family `Arial, sans-serif` | SOURCE MATCH. Browser fallback was not re-measured this pass |
| White-light algorithm | SOURCE MATCH. Not edited. Beam was already aligned |

## Visual evidence

Same browser crop as QA-4: 1024×618 simulation viewport, y=56 of a 1024×740 window, DPR 1. Official files were not recaptured. Flutter files are new. FINAL4 was not overwritten.

| Scene | Side by side | Overlay |
| --- | --- | --- |
| Intro | `visual-qa/final5/FINAL5_INTRO_SIDE_BY_SIDE.png` | `FINAL5_INTRO_OVERLAY.png` |
| More Tools | `FINAL5_MORE_TOOLS_SIDE_BY_SIDE.png` | `FINAL5_MORE_TOOLS_OVERLAY.png` |
| Prisms | `FINAL5_PRISMS_SIDE_BY_SIDE.png` | `FINAL5_PRISMS_OVERLAY.png` |
| White Light | `FINAL5_WHITE_LIGHT_SIDE_BY_SIDE.png` | `FINAL5_WHITE_LIGHT_OVERLAY.png` |
| Graph | `FINAL5_GRAPH_SIDE_BY_SIDE.png` | `FINAL5_GRAPH_OVERLAY.png` |
| Sensors | `FINAL5_SENSORS_SIDE_BY_SIDE.png` | `FINAL5_SENSORS_OVERLAY.png` |

Also `FINAL5_PANEL_OVERLAY.png` and `FINAL5_TOOLBOX_OVERLAY.png`, cropped from the Intro pair.

## RGB

These numbers are not a READY threshold. Stage region y<569. A pixel counts as different when the max channel delta is greater than 12.

| Scene | QA-4 stage mean | QA-5 stage mean | Different pixel ratio |
| --- | ---: | ---: | ---: |
| Intro | 9.52 | 9.08 | 0.203 |
| More Tools | 18.01 | 17.07 | 0.293 |
| Prisms | 10.53 | 13.39 | 0.374 |
| White Light | 51.08 | 78.85 | 0.382 |
| Graph | 26.87 | 21.63 | 0.336 |
| Sensors | 19.66 | 18.82 | 0.301 |

White light went up because the Prisms toolbox and panels moved to the source anchors, into a region the 1.2.5 frame paints differently. The beam was not rewritten. See `WHITE_LIGHT_SPATIAL_ANALYSIS.md`.

## Remaining P2

Still not restyled:

- Probe gradient / bevel
- Velocity box highlight
- Laser metallic gradient
- Single-color ray opacity

## Regression

- `flutter test test/bending_light/` — 147 passed. No test removed. Five layout tests were added.
- `dart analyze lib/bending_light` — no issues.

The temporary web server was stopped after the captures. Exit code 1 from that process is expected.

## Final status

**NOT READY**

The panel shell, toolbox anchors, and graph gradient now follow the local source, and the graph stays above the toolbox. The panel interior, toolbox icons, shaded chart highlight, and sensor bodies are still not the scenery nodes. That is a structural source mismatch, so this is not READY.
