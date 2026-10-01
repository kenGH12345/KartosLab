# Final QA Report

## 1. Overall Status

**NOT READY**

P0 = 0. P1 = 0 for the behaviors that were executed in tests and source comparison.

READY is withheld because the view rows that the gate defines against **official runtime** (layout, typography, control z-order) were not compared to a running PhET frame. The captures below are real model painters. They do not contain the control panels, protractor image, or toolbox, so those items are not marked PASS.

Home: UNCHANGED. Android runtime: **NOT VERIFIED**.

## 2. Test Result

- `flutter test test/bending_light/` → **142 passed** (baseline was 136; asset wiring did not delete tests)
- `dart analyze lib/bending_light` → **No issues found**

## 3. Screen Result

- Intro: laser drag, medium, wavelength, time, reset covered by existing tests. PASS for those behaviors.
- More Tools: toolbox drop rules, probes, intensity hits, velocity label, wave samples, chart window. PASS for those behaviors.
- Prisms: vector trace, rotation retrace, white-light sample set, TIR, step cap. PASS for those behaviors.

None of the three screens was clicked through on an official PhET build in this pass.

## 4. Physics Result

- Intro Snell: PASS
- Prisms Snell: PASS (still not the Intro formula)
- Fresnel: PASS
- Dispersion: PASS
- White light: PASS against `paintCanvas`, not the Bresenham comment
- Wave: PASS. Time stays on the model `Ticker` → `step()`

## 5. Interaction Result

- Laser: PASS (quadrant clamp, knob drag, reset)
- Prism: PASS (translate, rotate, reset clears prisms)
- Toolbox: PASS (no second instance; icon hides while enabled)
- Probe: PASS hit testing. Appearance is P2
- Intensity: PASS 0/1/2. Not a radius test
- Velocity: PASS direction, `1.5e-14`, `1.00 c`, zero → `?` and no arrow
- Wave: PASS
- Protractor: PASS image and ring threshold. Extra readout is P2
- Wavelength: PASS 380–700 nm into `setWavelength`
- Reset: PASS (`reset_all_test.dart`)

## 6. Visual Result

Canvas capture. Not `toImage` (the clock ticker hangs that path).

| File | What it actually shows | Result |
|---|---|---|
| `visual-qa/FINAL_INTRO.png` | Intro medium + model rays | PASS for rays. Controls not in frame |
| `visual-qa/FINAL_MORE_TOOLS.png` | More Tools transform + wave ribbon | PASS for wave ribbon. Toolbox not in frame |
| `visual-qa/FINAL_PRISMS.png` | Prism fill + single-color rays | PASS for that layer |
| `visual-qa/FINAL_WHITE_LIGHT.png` | Black environment, additive strokes, prism on top | PASS vs `paintCanvas` order |
| `visual-qa/FINAL_GRAPH.png` | Chart window, dashed grid, zero line, waveform | PASS. No numeric ticks, matching source |
| `visual-qa/FINAL_SENSORS.png` | Cubic wire on live meter positions | PASS for the wire. Probe glyph not in this painter |

This QA also replaced the painted brown knob and the `1x/5x/White` text with `knob.png` and the clipped `laser.png`. Those widgets are not inside the six captures.

## 7. Remaining Issues

P2, acceptable only as chrome:

- `ProbeGlyph` has the source radius, handle, and crosshairs, but not the `ProbeNode` linear-gradient bevel.
- `VelocitySensorView` uses the source colors and label rules, but not every `ShadedRectangle` stop.
- `LaserPointerPainter` matches `LaserPointerNode` outer sizes. The metal gradient is simpler than scenery-phet.
- Protractor still draws a counter-rotated `deg` string that `ProtractorNode` does not have.
- Single-color ray alpha is still the Phase 2 power fade, not `SingleColorLightCanvasNode`.
- Wavelength control is a Flutter `Slider` bound to the source range. It is not the sun slider skin.

No P0. No P1 left in the tested paths.

## 8. Android

**Android runtime NOT VERIFIED.** No device or emulator was used. This is not an Android PASS.
