# PHASE 4 — More Tools / Sensors / Wave / Measurement

Status: **PHASE 4 COMPLETE**

P0 = 0. P1 = 0. `dart analyze lib/bending_light` = No issues found. `flutter test test/bending_light/` = **119 passed** (Phase 1–3 regression included).

Not READY. Home was not modified. Android runtime **NOT VERIFIED**.

## 1. More Tools architecture

Closed loop is user gesture → model setter → `updateModel` / `step` → rays, sensors, time → view.

`MoreToolsModel` extends `IntroModel`. It adds `VelocitySensor` and `WaveSensor`. Wavelength still goes through `setWavelength`, which rebuilds media indices and rays. Time ticks bump `waveFrame` (`ValueNotifier`) and do not call `notifyListeners`, so the control panels are not rebuilt every frame. The wave ribbon, particles, and chart listen only to `waveFrame`.

Mapping table: `MORE_TOOLS_MAPPING.md`.

## 2. Toolbox

Drag-out replaces the Phase 3 tap-to-place path for Intro and More Tools.

- Pointer down starts an overlay ghost (`ToolboxChip`).
- Drag moves that ghost with the pointer.
- Drop inside the toolbox does nothing (`droppedOutsideToolbox`).
- Drop outside writes the tool position and sets `enabled=true`.
- The chip hides while the tool is enabled (one instance, no duplicate).
- Dropping the body back into the toolbox sets `enabled=false` and the chip returns.
- Relative probe offsets are kept on the first drop (intensity probe, both wave probes).
- Placement centers the body on the pointer, matching the forwarding listener. There is no extra snap.

Prisms toolbox icons are unchanged (checkbox / tap prototypes). That screen has no put-back drag in the original.

## 3. Probe

Intensity body and probe are separate hit targets. Wave sensor body, probe 1, and probe 2 are separate hit targets. Measurement uses the probe position, not the body rectangle. Miss is `Reading.isMiss` (`—`). A hit shows percent. Reset clears pose and series.

## 4. Wire

`CubicWire.between` builds `start`, `start+(25,0)`, `end+(0,25)`, `end` in view pixels. `CubicWirePainter` only strokes that path. Intensity has one wire. The wave sensor has two. Connection points are chosen in the play-area widgets, not inside the painter.

## 5. Wave

`setLaserView(wave)` keeps the existing `cos(kx − ωt + φ)` state on each ray. `step` / `stepOnce` advance model time (`1e-16` normal, `0.5e-16` slow) and refresh the cos argument. `WaveFrontPainter` draws the perpendicular offset from `WaveMath.waveMagnitude`. No extra wave parameters were added.

## 6. Wave Particle

`waveParticlesFor` spaces particles by the medium wavelength, takes phase from `getPhaseOffset`, and caps the count at 150. Incident rays start at the tail. Other rays shift the tail the way `propagateParticles` does. The painter draws those model positions. It does not use `sin(random)` or a fixed animation.

## 7. Wave Sensor Graph

`WaveChartPainter` maps samples into `x = [time−72e-16, time]`, `y = [-1, 1]`, with four vertical grid intervals and a dashed baseline. Samples are taken in `MoreToolsModel.afterTimeStep` only while the sensor is enabled and `getWaveValue` is non-null. `Probe.maxSamples` is 240; older points are dropped. Pause stops `step()`. Reset clears the series and time.

## 8. Time Control

`BlTimeControl` calls `togglePlaying`, `stepOnce`, and `setSpeed`. The `Ticker` lives on the play-area state and is disposed with the screen. It calls `model.step()` only when the clock should be visible (wave view, or More Tools wave sensor enabled). The widget does not own a `Timer`.

## 9. Wavelength

Slider range is 380–700 nm, step 1, default 650 nm. `onChanged` calls `setWavelength` in meters. That updates the dispersion index and retraces rays. It does not only recolor the laser.

## 10. Dispersion rendering

More Tools stays a single wavelength. Changing the slider changes `n` through the Phase 1 Sellmeier / air / 650 nm path already used by `updateModel`. No extra dispersed rays were added.

## 11. White light rendering

White light is Prisms `LaserType.WHITE`, not More Tools. XYZ and Bresenham were not ported. The wavelength slider on Prisms is disabled for white light, same as the original. No `Color.lerp` rainbow was added.

## 12. Protractor

Outer ring (`distance ≥ 0.72 * radius`) applies `protractorAngleDelta` (`atan2` difference). The tick arc rotates with `ProtractorTool.angle`. The numeric readout is counter-rotated so it does not turn upside down. Inner drag translates the center. Reset clears angle and hides the tool.

## 13. Intensity Sensor

`getSensorShape` in the source is a circle of radius `1e-6` (kite arc). `rayCircleHits` returns 0, 1, or 2 intersections. Two hits use the midpoint (`sensorSamplePoint`), then the ray is truncated the same way as `addAndAbsorb`. A miss stays invalid. This replaces the Phase 1 `distance < radius` test. Snell, Fresnel, and prism tracing were not edited.

## 14. Velocity Sensor

`getVelocity` is evaluated in `MoreToolsModel.updateModel`. The view prints `value.magnitude`. Air and glass differ because the ray speed is `c/n`. An off-beam point is the zero / invalid reading. The original arrow scale `1.5e-14 * velocity` is not drawn; the number is the model value.

## 15. Layout collision

`bumpLeftViewDx` shifts a dropped tool left by `(node.right − panel.left) + 20` view pixels when it overlaps a right panel. Only the first overlapping panel applies. The delta is converted with `viewToModelDelta`. World size and `BlMvt` origins are unchanged. Tools are not clipped off the layout bounds (`clampModelPoint`).

## 16. Tool lifecycle

Toolbox drag-out → enabled → move → measure → reset is covered by the More Tools tests. Screen `dispose` stops the ticker. `ListenableBuilder` drops its listener with the element. `IntroModel.dispose` disposes `waveFrame`.

## 17. Tests

`test/bending_light/more_tools/` (24 tests):

- `toolbox_drag_test.dart`
- `probe_interaction_test.dart`
- `wire_geometry_test.dart`
- `wave_sensor_test.dart`
- `wave_particle_test.dart`
- `time_control_test.dart`
- `wavelength_test.dart`
- `protractor_rotation_test.dart`
- `intensity_sensor_test.dart`
- `velocity_sensor_test.dart`
- `layout_collision_test.dart`

Wave cases cover t = 0, t > 0, pause, resume, reset, wavelength, and medium. Intensity cases cover miss, one hit, two hits. Velocity cases cover on-beam, off-beam, and air vs glass.

## 18. Regression

`flutter test test/bending_light/` → 119 passed. That includes Phase 1 physics, Phase 2 play area, Phase 3 interaction, and Phase 4.

## 19. Runtime status

- Widget / unit tests: PASS (119)
- `dart analyze lib/bending_light`: No issues found
- Demo entry remains `flutter run -t lib/bending_light/bending_light_demo_main.dart`
- Windows / Chrome / Edge are the devices previously listed on this machine
- **Android runtime NOT VERIFIED** (no device or emulator). This is not an Android PASS.

## 20. Screenshots

Canvas capture, not `RenderRepaintBoundary.toImage`. A widget screenshot hangs while the clock `Ticker` is scheduled. These images are the real painters (`WaveFrontPainter`, `WaveParticlePainter`, `WaveChartPainter`, `CubicWirePainter`, `RaysPainter`) fed by a live `MoreToolsModel` after `stepOnce`.

- `visual-qa/PHASE_4_MORE_TOOLS.png`
- `visual-qa/PHASE_4_WAVE.png`
- `visual-qa/PHASE_4_SENSORS.png`
- `visual-qa/PHASE_4_TOOLBOX.png`

The toolbox panel in `PHASE_4_TOOLBOX.png` is the same canvas pass, not a separate placeholder screen.

## 21. P0

None.

Wave samples match `WaveMath.waveMagnitude`. Time drives `waveFrame` and the chart window. Probe hits use the circle intersection. Wavelength calls `setWavelength`. Toolbox drop writes model positions. Wires are cubics from `CubicWire`. Reset clears sensors. Layout bump keeps tools inside the play area.

## 22. P1

None.

Graph samples were checked against `getCosArg`. Protractor delta matches the atan2 formula. Sensor hits are 0/1/2, not a radius test. Drop position is the pointer. `bumpLeft` matches the first-panel rule. The ticker is disposed with the screen.

## 23. P2

- Chart has no numeric tick labels or axis titles.
- Protractor is a painted semicircle and ticks, not `protractor.png`.
- Wave particles are dots, not the original rotated ellipses.
- Velocity arrow (`1.5e-14 * velocity`) is not drawn; the readout is the magnitude.
- Wire stroke is a solid 3 px stroke, not the original wire chrome.
- Intensity body/probe are colored rectangles and a circle, not the original node art.
- Drag threshold before the forwarding listener starts is not reproduced; any pan that ends outside the toolbox places the tool.
- Wave-mode kite `waveShape` intersection is still the Phase 1 `contains` test. Ray-mode intensity uses the circle.

## 24. Remaining work

- Prisms white-light XYZ / Bresenham canvas (not More Tools).
- Original PNG chrome for protractor, probe, and velocity arrow.
- Do not connect Home.
- Do not treat this as final project acceptance.
