# Final Scenery Node Mapping — QA-7

Order used: local bending-light source, then its scenery-phet dependency, then screenshots only as evidence. `sun` is not in the local tree.

| UI | Source Class | Package | Source Bounds | Scale | Paint | Flutter |
| --- | --- | --- | --- | --- | --- | --- |
| Ray | `AquaRadioButton` | sun, called from `LaserTypeAquaRadioButtonGroup` | radius 6, font 12 | 1 | circle. Aqua fill not local | `PhetAquaRadio` |
| Wave | same | same | same, VBox spacing 10 | 1 | same | `PhetAquaRadio` |
| Checkbox | `Checkbox` | sun | `boxWidth` 15, spacing 5 | 1 | box local; check path not local | `PhetCheckbox` |
| Normal icon | `NormalLine` | bending-light | height 17, dash `[4, 3]` | 1 | black stroke | `NormalLineIcon` |
| Angles icon | `AngleIcon` | bending-light | edge 15, arc `0.55 * edge` | 1 | black stroke | `AngleMarkIcon` |
| TimeControl | `TimeControlNode` | scenery-phet | radios left, flow spacing 10 | 1 | see sun audit | `SourceTimeControl` |
| Play / Pause | `PlayPauseButton` | scenery-phet | radius 20.8 | 1 | `PlayIconShape` / `PauseIconShape` | `_PlayPausePainter` |
| Step | `StepForwardButton` | scenery-phet | radius 15, bar `0.15 r`, triangle `0.65 r` | 1 | black icon. Bevel not local | `_StepPainter` |
| Speed | `TimeSpeedRadioButtonGroup` | scenery-phet | spacing 9, font 14 | 1 | radio radius = label height / 2 | `PhetAquaRadio` font 14, radius 7 |
| Intensity | `IntensityMeterNode` | bending-light | body 150×95, probe `ProbeNode` | body 0.6, icon 0.45 | green gradients, shaded readout, gray wire | `IntensityMeterGraphic` |
| Velocity | `VelocitySensorNode` | bending-light | triangle 8×15, body 54×37 | body 0.7, icon 1.2, placed 2 | `#CF8702` gradient, shaded readout | `VelocitySensorGraphic` |
| Wave Sensor | `WaveSensorNode` | bending-light | body 135×100 | body 0.93, icon 0.4 | same chart paint as the graph | `WaveSensorGraphic` |
| Prism | `PrismNode` | bending-light | prototype shape, then height 55 | `55 / viewHeight` | stroke gray, fill alpha 0.5 | `prismIconGeometry` |
| Protractor | `ProtractorNode.createIcon` | scenery-phet | image 302×302 | 0.24 | `protractor.png` | `ProtractorToolboxIcon` |

`IntensityMeterNode`, `VelocitySensorNode`, and `WaveSensorNode` toolbox icons are `new ThatNode(..., { scale })` of a model copy. They are the same class as the placed node, with a different scale option. Flutter uses the same graphic class and the source scale.
