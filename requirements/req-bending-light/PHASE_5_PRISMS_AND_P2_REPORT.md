# PHASE 5 — Prisms and P2

Status: **PHASE 5 COMPLETE** as a behavior gate. **NOT READY.** Home was not modified. Android runtime **NOT VERIFIED**.

`dart analyze lib/bending_light`: No issues found. `flutter test test/bending_light/`: **136 passed**.

## 1. Files

- `lib/bending_light/physics/visible_color.dart` — `VisibleColor.wavelengthToColor`
- `lib/bending_light/physics/cie_tables.dart` — XYZ and D65 tables from source
- `lib/bending_light/physics/white_light.dart` — stroke color and the unused XYZ matrix
- `lib/bending_light/components/play_area_painters.dart` — `WhiteLightPainter`
- `lib/bending_light/components/wave_view.dart` — chart dash, phase, stroke 2
- `lib/bending_light/components/protractor_widget.dart` — `protractor.png`
- `lib/bending_light/components/velocity_sensor_widget.dart` — arrow and readout
- `lib/bending_light/components/probe_glyph.dart` — probe silhouette
- `lib/bending_light/view/prisms_play_area.dart` — white layer behind prisms, protractor scale 0.46
- `assets/simulations/bending_light/protractor.png`
- `test/bending_light/phase5/`
- `test/bending_light/integration/phase5_screenshot_test.dart`

Intro Snell, vector Snell, Fresnel, and the laser drag model were not rewritten.

## 2. P2 source mapping

See `PHASE_5_P2_MAPPING.md`.

## 3. Prisms

`PrismsModel` still traces with vector Snell, depth cap 50, and power cutoff 0.001. The view only paints `model.rays` and `model.prisms`. Rotation still calls `prism.rotate` then `updateModel`. White mode does not switch the tracer to Intro Snell.

## 4. White light

`paintCanvas` is the implementation, not the Bresenham comment above it. Each ray is a width-3 stroke. Color is `VisibleColor` scaled by D65 and `sqrt(powerFraction)`. Overlapping strokes use `BlendMode.plus`. The canvas is behind the prism nodes. In white mode the environment fill is black, because `MediumColorFactory.getColor` uses the against-black profile when the laser is white, and air on that profile is black.

`XYZ_TO_RGB_MATRIX` is in the constants file and is not called by `paintCanvas`. It is ported and tested. It is not used to color pixels.

Wavelength samples are 400, 410, … 690 nm. No rainbow shader and no `Color.lerp`.

## 5. Graph

`ChartNode` has a scrolling dashed grid and one zero line. It does not draw numeric tick labels. Those were not invented. The body shows the source string `Time`. Series stroke width is 2. Repaint still follows `waveFrame` only.

## 6. Protractor

The node is the scenery-phet PNG (302×302), not a drawn semicircle. Intro and More Tools use scale 0.8. Prisms uses 0.46. The printed ticks rotate with the image. The extra numeric readout stays counter-rotated. The drag ring starts at 0.6× radius, matching the inner ellipse `0.3 * width`.

## 7. Velocity sensor

The arrow vector is `modelToViewDelta(velocity) * 1.5e-14`. The view does not recompute speed. Magnitude 0 hides the arrow and shows `?`. Otherwise the label is `toFixed(magnitude/c, 2)` plus ` c`. The body is scaled by 0.7. Y-up in the model points up on screen.

## 8. Probe

Intensity probe: `ProbeNode` defaults, scale 0.6, color `#008541`. Wave probes: radius 43, inner 32, handle 40×30, scale 0.35, crosshairs, colors `#5c5d5f` and `#ccced0`. Hit targets stay on the glyph. The wire is still the cubic from Phase 4.

## 9. Tests

New tests cover visible color at 650 / 550 / 450 nm, UV/IR null, white samples, D65 stroke, XYZ matrix difference, white-light wavelength set, prism rotation retrace, step cap, chart phase, velocity arrow direction, zero readout, intensity hit/miss, and vector-Snell TIR.

## 10. Analyze

`dart analyze lib/bending_light` → No issues found.

## 11. Visual QA

Canvas capture of the live painters (Ticker still hangs `toImage`).

| File | Check | Result |
|---|---|---|
| `PHASE_5_INTRO.png` | intro rays + medium | PASS |
| `PHASE_5_MORE_TOOLS.png` | wave ribbon on the more-tools transform | PASS |
| `PHASE_5_PRISMS.png` | prism + single-color rays | PASS |
| `PHASE_5_WHITE_LIGHT.png` | black environment, additive strokes, prism on top | PASS |
| `PHASE_5_GRAPH.png` | window, zero line, dashed grid, waveform | PASS |
| `PHASE_5_SENSORS.png` | cubic wire on a live meter position | PASS |

Protractor PNG is in the widget, not in these canvas files. Chart numeric ticks: source has none, so this is not a mismatch.

## 12. Remaining P2

- Probe linear-gradient bevel and the exact elliptical outer path
- Velocity body highlight stops (base color and layout are in place)
- Protractor extra `deg` overlay is not in `ProtractorNode`
- Single-color ray alpha is still the Phase 2 power fade, not `SingleColorLightCanvasNode`

## 13. Final QA

Behavior gates for this phase are met, so Final QA can start. The project stays **NOT READY**. Do not connect Home. Do not claim Android PASS.
