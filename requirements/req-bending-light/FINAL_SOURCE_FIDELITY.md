# Final Source Fidelity — QA-7

| Item | Verdict | Why |
| --- | --- | --- |
| Ray / Wave | SOURCE MATCH on type and layout | `AquaRadioButton` radius 6, font 12, vertical spacing 10. Not a Material button. |
| Aqua pigment | VERSION_DELTA | `sun/js/AquaRadioButton.ts` is not in the local tree. |
| Checkbox box | SOURCE MATCH | `boxWidth` 15, spacing 5, no Material splash. |
| Checkbox mark | VERSION_DELTA | `sun/js/Checkbox.ts` path is not local. The mark is two segments, not `Icons.check`. |
| Normal / Angle icons | SOURCE MATCH | `NormalLine(17, [4, 3])` and `AngleIcon` edge 15. |
| TimeControl layout | SOURCE MATCH | Radios on the left, spacing 10, play radius 20.8, step radius 15. Clock stays on the model. |
| Play / pause / step icons | SOURCE MATCH | `PlayIconShape`, `PauseIconShape`, `StepButton` proportions. |
| Round-button bevel | VERSION_DELTA | `RoundPushButton` is sun and is not local. |
| Intensity body | SOURCE MATCH | 150×95 gradients, inner `#008541`, shaded readout, title, wire, then scale 0.45. |
| Intensity probe | SOURCE MATCH | `ProbeNode` kite outline, inner hole, glass or crosshairs, origin at the sensor center. Intensity scale 0.6. Wave probes scale 0.35. |
| Velocity toolbox | SOURCE MATCH | Same triangle, 54×37 body, gradient, shaded readout, body scale 0.7, node scale 1.2. |
| Velocity placed scale | SOURCE MATCH | Placed node applies `scale: 2` around the triangle hotspot. Body scale stays 0.7. Arrow constant stays `1.5e-14`. |
| Wave toolbox body | SOURCE MATCH | Chart painter plus two probes at the model offsets, scale 0.4. |
| Wave toolbox wires | SOURCE MATCH | Two independent `WireNode` cubics. Body start is `rightBottom + (-2, -0.18 h)`. Probe end is `centerBottom`. |
| Prism icon shape | SOURCE MATCH | Prototype points through `BlMvt.prisms()`, height 55, gray stroke, fill alpha 0.5. |
| Prism icon fill | SOURCE MATCH | `MediumColorFactory.getColor`. White light uses the black-background profile. |
| Prism icon knob | SOURCE MATCH | `knob.png` when `getReferencePoint()` exists. Height 15 before the icon scale. Circle has no knob. |
| Protractor | SOURCE MATCH | `protractor.png` at 0.24. |
| Graph | SOURCE MATCH | Unchanged from QA-6. |
| Panel shell / sliders / combo / arrows | SOURCE MATCH | Not retuned. Sun thumb, highlight, and arrow bevel stay VERSION_DELTA. |
| Physics / Home | unchanged | |
