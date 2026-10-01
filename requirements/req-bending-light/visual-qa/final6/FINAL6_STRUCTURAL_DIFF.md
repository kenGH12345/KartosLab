# FINAL6 Structural Diff

Comparison is the 1024×618 simulation viewport, DPR 1, crop `y=56`.
Official frames are phet-dev **1.2.5**. Flutter is the local **1.3.0-dev.0** implementation.
Different-pixel ratio uses max channel delta > 12. RGB is auxiliary. It is not a READY gate.

| Region | Mean abs | Ratio | Verdict |
| --- | --- | --- | --- |
| Panel | 20.71 | 0.345 | visual mismatch on the new controls; shell anchors unchanged |
| Toolbox | 41.76 | 0.606 | visual mismatch. Text chips are gone. Icons are still simplified |
| Graph | 21.02 | 0.310 | gradient SOURCE MATCH. Highlight is no longer a flat white fill |
| Sensors | 8.29 | 0.133 | placed probe/velocity still the previous nodes. P2 bevel remains |
| Play Area | 0.55 | 0.009 | SOURCE MATCH for the beam and media. Physics not touched |
| Background | 25.83 | 0.412 | VERSION_DELTA. The 1.2.5 navbar is not painted. Letterbox stays `#222222` |

## Panel

- Shell, `y=236`, `y=273`, right margin 10, fill `#EEEEEE`: unchanged, SOURCE MATCH.
- Index slider is no longer `Slider`. Track is white, 210×1, thumb 10×20. `knob.png` is not used here, matching the `HSlider` call site.
- Combo box is no longer `DropdownButton`. Closed state uses the call-site margins and radius.
- `+` / `-` text buttons are gone. They are circle arrow buttons at scale 0.7.
- Remaining mismatch: `sun` thumb gradient, combo highlight, and arrow bevel are not in the local tree, so those paints are reconstructed geometry, not a copied sun node.
- Ray / Wave and the checkboxes in this crop are still Material. That is why the panel ratio stays high.

## Toolbox

- Protractor icon is `protractor.png` at about scale 0.24. SOURCE MATCH for the asset.
- Intensity, velocity, wave, and prism icons are painted nodes, not name chips.
- They are not yet `IntensityMeterNode` at 0.45, `VelocitySensorNode` at 1.2, `WaveSensorNode` at 0.4, or `PrismNode` at height 55. That is a visual mismatch, not a text-chip mismatch.
- Drag preview follows the same child. Drop-outside behavior is unchanged.

## Graph

- Outer gradient `#5EB4DE` → `#005B86`: SOURCE MATCH.
- Sample through the chart on `FINAL6_GRAPH.png`: top band `(97, 176, 218)`, then gray `(222, 222, 222)` / `(211, 211, 211)`, then white center, then the lower blue band. That is the `ShadedRectangle` edge, not a solid white rectangle.
- Waveform formula unchanged.
- Z-order unchanged: toolbox earlier, chart later.

## Sensors

- Placed intensity probe is still `ProbeGlyph` at the source default radius. Local origin is the sensor center.
- Velocity box highlight and probe bevel were not restyled. They stay P2.

## Play Area

- Mean 0.55 on the intro play-area crop. The beam and the two media were not moved.

## Background

- The 40×40 corner differs because 1.2.5 paints joist navigation chrome and this build does not. VERSION_DELTA, same as QA-4/5.
