# More Tools Mapping

Source: `bending-light/js/more-tools/` plus shared `scenery-phet` nodes used by that screen.
Behavior reference is local source only. White-light XYZ / Bresenham is `PrismsModel` (`LaserType.WHITE`), not More Tools runtime, so it is not in this table.

| Original Component | Original Responsibility | Dart Model | Flutter View | Interaction |
|---|---|---|---|---|
| `MoreToolsModel` | Intro model plus glass bottom, velocity sensor, wave sensor | `MoreToolsModel` | `MoreToolsPlayArea` | Reset calls `super.reset()` then both sensors reset |
| `BendingLightModel.setWavelength` | 380–700 nm, step 1, default 650 nm; updates n and rays | `BendingLightModel.setWavelength` | `WavelengthControl` | Slider writes meters. White light (Prisms only) disables the slider |
| `TimeControlNode` | Play / pause / step / normal / slow. Visible in wave view or when the wave sensor is out | `IntroModel.step` / `stepOnce` / `togglePlaying` / `setSpeed` | `BlTimeControl` | Screen `Ticker` calls `model.step()` only. Dispose stops the ticker. Time does not `notifyListeners` |
| `WaveParticle` + `propagateParticles` | Spacing = medium wavelength, phase from `getPhaseOffset`, cap 150 | `waveParticlesFor` / `waveOffsetAt` | `WaveParticlePainter` / `WaveFrontPainter` | Positions come from ray state. No widget timer |
| `ChartNode` | Window `timeWidth=72e-16`, y in [-1, 1], vertical grid every `timeWidth/4` | `WaveChartWindow` + `Probe.series` | `WaveChartPainter` | Repaints from `waveFrame` only. Series capped at 240 |
| `WaveSensor` | Two probes sample `getWaveValue` after each time step | `WaveSensor.step` in `MoreToolsModel.afterTimeStep` | Body, probe 1, probe 2, two cubic wires, chart | Body drag and each probe drag are separate. First drop keeps relative offsets |
| `Probe` | Position + time series | `Probe` (`maxSamples=240`) | `_ProbeDot` | Probe drag writes `probe.position` then `updateModel` |
| `IntensityMeter` | Circle sensor radius `1e-6`. 0/1/2 ray hits; two hits use the midpoint | `rayCircleHits` + `sensorSamplePoint` in `IntroModel._addAndAbsorb` | `IntensityMeterWidget` | Body drag vs probe drag. Return to toolbox sets `enabled=false` |
| `VelocitySensor` | `getVelocity` from the ray under the point (`c/n` along the ray) | `MoreToolsModel._syncVelocity` | `_ProbeDot` readout `value.magnitude` | Placement and drag go through the model. View does not compute speed |
| `WireNode` | Cubic `start`, `start+normal1`, `end+normal2`, `end`. Normals `(25,0)` and `(0,25)` view px | `CubicWire.between` | `CubicWirePainter` | Painter only strokes the model path |
| `ProtractorNode` | Outer ring rotates; inner disk translates. `angle += atan2(center-end) - atan2(center-start)` | View pose `ProtractorTool.angle` (not physics) | `ProtractorWidget` | Ring if distance ≥ `0.72 * radius`. Numeric readout is counter-rotated |
| Toolbox forwarding drag | One instance. Icon hides while enabled. Drop outside toolbox places the tool; drop back disables it | `enabled` flags | `ToolboxChip` overlay ghost + `droppedOutsideToolbox` | Pointer centers the tool. No second instance |
| `IntroScreenView.bumpLeft` | If a tool overlaps a right panel, shift left by overlap + 20 view px. First panel only | `bumpLeftViewDx` | `_bump` on drop | World coordinates unchanged. Only the screen delta is converted |
| Dispersion | Wavelength changes `n` via Sellmeier / air / 650 nm interpolation | Existing Phase 1 `DispersionFunction` through `setWavelength` → `updateModel` | Wavelength slider | No extra wavelengths invented for More Tools (single laser wavelength) |
