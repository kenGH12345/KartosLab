# FINAL QA-6 Report

## Source Component Mapping

See `SCENERY_COMPONENT_MAPPING.md`.

Local `sun` sources for `HSlider`, `ComboBox`, `ArrowButton`, and `Panel` are absent. Control sizes come from the `MediumControlPanel` and `WavelengthControl` call sites. `ProbeNode` and `ShadedRectangle` are local and were followed directly.

## Panel Controls

- Index slider: `PhetHSlider`. White track 210×1, thumb 10×20, major ticks length 11. Drag writes the index callback, which still goes through the model. Not a Material `Slider`. Not `knob.png`.
- Wavelength: `PhetSpectrumSlider`. Track height 20, thumb 20×20, white cursor stroke. More Tools width 120. Prisms width 146. Color comes from `visibleColorArgb`.
- List: `PhetComboBox`. Closed fill white, stroke black, corner 3, xMargin 7, yMargin 4. Open list, outside tap closes, value change closes. Not `DropdownButton`.
- Arrows: `PhetArrowButton`. Index scale 0.7, wavelength scale 0.6. Triangle mark, no `Icons.add` / `Icons.remove`, no splash on these buttons.
- Readouts: 45×20 and 60×18, white fill, black stroke.
- Panel parent was not moved. `y=236`, `y=273`, right margin 10, width 237 stay.

Still Material, so the panel is not finished: Ray/Wave `TextButton`, Normal/Angles `Checkbox`, time Play/Pause/Step row.

## Toolbox Nodes

Text chips are gone. The chip child is the icon, and the drag ghost is that same child.

- Protractor: `protractor.png`, width 72 (source scale 0.24 of 302 is 72.5).
- Intensity / velocity / wave / prism: painted stand-ins. They are not the full source nodes. See the mapping table.

Drag-out still hides the icon when the tool is enabled, and a second copy is not created. Existing toolbox tests were not deleted.

## Graph Paint

See `GRAPH_PAINT_MAPPING.md`.

The inner-most rectangle is `paintShadedRectangle` with base white and light from `rightBottom`. A vertical sample of `FINAL6_GRAPH.png` shows gray edge pixels (`211`, `222`) around a white center. It is not `Colors.white` as the only paint. The waveform formula was not edited.

## Interaction Regression

Widget tests, not only pixels:

- Slider: width 210, drag changes the value, restoring the value restores the thumb.
- Combo: open shows the other media, selecting Water updates the value, resetting the value closes the list.
- Arrows: increment, stop at the max, decrement.
- Toolbox: preview is `IntensityToolboxIcon` plus `ProbeGlyph`, not the string `Intensity`.
- Existing intro / prisms / more-tools pump tests still pass, including medium selection, wave toggle, prism add, and reset. The reset tap warning on the 800×600 test surface is the known viewport overflow, not a failure.

## Visual Comparison

Frames are in `requirements/req-bending-light/visual-qa/final6/` and `visual-qa/flutter/FINAL6_*.png`.

- `FINAL6_INTRO.png`
- `FINAL6_MORE_TOOLS.png`
- `FINAL6_PRISMS.png`
- `FINAL6_WHITE_LIGHT.png`
- `FINAL6_GRAPH.png`
- `FINAL6_SENSORS.png`
- `FINAL6_PANEL.png`
- `FINAL6_TOOLBOX.png`
- `FINAL6_GRAPH_DETAIL.png`

Regional numbers: `visual-qa/final6/FINAL6_STRUCTURAL_DIFF.md`.

Play-area crop mean 0.55. White-light sample `(500, 235)` is `(255, 255, 255)` on the Flutter frame, same as the previous beam check. The white-light formula was not changed.

## Remaining P2

- `sun` slider thumb gradient, combo highlight color, and arrow-button bevel. Not in the local tree.
- Full toolbox nodes: `IntensityMeterNode` scale 0.45, `VelocitySensorNode` scale 1.2, `WaveSensorNode` scale 0.4, `PrismNode` height 55.
- Probe bevel, velocity readout highlight, laser metallic gradient.
- Material `Checkbox`, Ray/Wave `TextButton`, and the time-control `TextButton`s. These are still structural, not P2, and they keep the status below.

## Test Result

`flutter test test/bending_light/` — **153 passed** (baseline was 147; no tests removed).

## Analyze Result

`dart analyze lib/bending_light` — **clean**.

## Android

`NOT VERIFIED`

## Home

`UNCHANGED`

## Final Status

`NOT READY`

Material checkboxes and the Ray/Wave/time buttons are still on screen. Toolbox icons are no longer text chips, but they are not the source sensor nodes yet. Those two gaps fail the scenery-fidelity gate even though the slider, combo, arrows, and graph highlight are no longer the previous substitutes.
