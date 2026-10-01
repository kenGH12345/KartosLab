# FINAL QA-8 Source Closure

Read from the local 1.3.0-dev.0 tree before editing. Order: local bending-light, then scenery-phet. `sun` is still absent and stays `VERSION_DELTA`.

| Item | Local Source | Current Flutter | Required | Status |
| --- | --- | --- | --- | --- |
| Intensity | `scenery-phet/js/ProbeNode.ts` via `IntensityMeterNode` scale 0.6 | circle + rounded handle | kite outline, inner hole, glass sensor, origin at sensor center | MISMATCH |
| Velocity | `VelocitySensorNode` body scale 0.7, then `MoreToolsScreenView` placed `{ scale: 2 }` | placed view uses only body scale 0.7 | placed node scale 2 around the triangle hotspot. Toolbox stays 1.2 | MISMATCH |
| Wave Sensor | `WaveSensorNode` adds `wire1Node` and `wire2Node` (`WireNode` cubics) | toolbox icon has no wires; placed wires use guessed offsets | two independent wires, body `rightBottom` offset `(-2, -0.18 h)`, probe `centerBottom`, normals `(25,0)` and `(0,25)` | MISMATCH |
| Prism | `PrismNode` adds `knob.png` when `getReferencePoint()` exists; fill is `mediumColorFactory.getColor(n).withAlpha(0.5)`; stroke `gray` | fixed `0xFFB3E5FC`, no knob on the icon; placed knob sits on the rotation center | knob asset + factory color, including the white-light black profile | MISMATCH |

Details used for the port:

- Probe outline: `arcExtent = 0.8`, neck radius 10, handle bottom `radius + handleHeight`, elliptical arc from `0.8π` to `0.2π` (the long way, sweep `1.4π`). Inner arc is a hole. Origin is the sensor center. Default color `#008541`, glass radial fill. Wave probes use radius 43, inner 32, handle 40×30, corner 9, scale 0.35, `ProbeNode.crosshairs()`.
- Intensity wire: `above(12)` from the scaled body `rightBottom`, stroke gray, line width 3. Probe translation is the model sensor position.
- Velocity arrow scale constant stays `1.5e-14`. The arrow is a child of the body, so it receives 0.7 and then the node scale. Zero magnitude still reads `?`.
- Wave wire colors: `rgb(88,89,91)` and `rgb(147,149,152)`, line width 3. Icon scale remains 0.4. Body scale remains 0.93.
- Prism knob: image height scaled to 15, offset `(-width-7, -height/2-8)`, rotation `atan2` from the reference point to the rotation center. Circle has no reference point and no knob. `MediumColorFactory` blends air/water/glass/diamond; white light uses the black-background profile.

The table above is the inventory taken before the edit. All four items are now SOURCE MATCH. See `FINAL_QA_8_REPORT.md`.
