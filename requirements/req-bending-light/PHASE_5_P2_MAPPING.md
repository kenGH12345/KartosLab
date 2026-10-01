# PHASE 5 P2 Mapping

Source of truth: local `bending-light` 1.3.0-dev.0. If a step is only in a comment and not in the method that runs, the method wins.

| P2 | Source file / class | Flutter file | Behavior | Visual source | Test |
|---|---|---|---|---|---|
| White light | `WhiteLightCanvasNode.paintCanvas` | `WhiteLightPainter` | Sample `_.range(400,700,10)`. Stroke width 3. Composite `lighter` (`BlendMode.plus`). Alpha `clamp(D65*sqrt(power)/118,0,1)/8`. Skip if `a<=1e-5` | `VisibleColor.wavelengthToColor`, not a gradient | `phase5/white_light_test.dart` |
| XYZ / RGB matrix | `BendingLightConstants` `XYZ`, `D65`, `XYZ_TO_RGB_MATRIX` | `cie_tables.dart`, `XyzToRgb` | Tables exist. `paintCanvas` does not call the matrix | Not used for pixels | `XyzToRgb.linearRgb` |
| Bresenham | Comment at top of `WhiteLightCanvasNode` | not ported | The running method strokes lines. No pixel Bresenham loop in this version | — | comment recorded, no fake Bresenham |
| Graph ticks | `ChartNode` | `WaveChartPainter` | Window `72e-16`, y `[-1,1]`, vertical spacing `/4`, dash 10/5, phase `getDelta` | No numeric tick labels in `ChartNode` | `WaveChartWindow.gridPhase` |
| Time label | `WaveSensorNode` title `"Time"` | chart body text `Time` | Below the plot, on the blue body | PhetFont on the body, not on the plot | widget text |
| Series stroke | `SeriesCanvasNode` `lineWidth = 2` | `WaveChartPainter` | Colors `#5c5d5f` and `#ccced0` | stroke 2 | existing wave sensor tests |
| Protractor | `ProtractorNode` + `protractor_png` | `ProtractorWidget` | Intro/More Tools scale 0.8. Prisms scale 0.46 and rotatable. Ring is outside `0.6 * radius` | `assets/simulations/bending_light/protractor.png` (302×302) | `protractorOuterRing` |
| Velocity arrow | `VelocitySensorNode`, `arrowScale = 1.5e-14` | `VelocitySensorView` | Arrow from model velocity via `modelToViewDelta`. Hidden when magnitude is 0. Label `x.xx c` or `?` | Triangle `#CF8702`, arrow blue 0.6, body scale 0.7 | `velocityArrowViewDelta` / `velocityReadout` |
| Probe | `ProbeNode`, intensity scale 0.6, wave scale 0.35 + crosshairs | `ProbeGlyph` | Sensor center is the origin. Handle hangs down. Body drag and tip drag stay separate | Circle + handle + inner disc. Full linear-gradient bevel is not reproduced | intensity hit tests |
| Prisms white mode | `PrismsModel.propagate` + `addLightNodes` | `PrismsPlayArea` | Vector Snell unchanged. White canvas is behind the prism layer. Environment fill is the black profile (air = black) | Prism fill stays the existing medium color at alpha 0.5 | white-light ray wavelength set |
