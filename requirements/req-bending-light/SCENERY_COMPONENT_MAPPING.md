# Scenery Component Mapping — FINAL QA-6

Local source: `phet sourses/bending-light-main` `1.3.0-dev.0`.
`sun/js/HSlider.ts`, `sun/js/ComboBox.ts`, `sun/js/buttons/ArrowButton.ts`, and `sun/js/Panel.ts` are **not in the local tree**. Sizes below are the call sites in `MediumControlPanel.ts` and `WavelengthControl.ts`, plus the scenery-phet nodes that are local.

| Source Node | Source Class | Asset | Flutter Class | Current State | Target |
| --- | --- | --- | --- | --- | --- |
| Wavelength track | `WavelengthSlider` → `SpectrumSlider` | none (spectrum paint) | `PhetSpectrumSlider` | source-equivalent track 20 / thumb 20 / white cursor stroke | Source-equivalent |
| Wavelength +/− | `ArrowButton` scale 0.6 | none (vector) | `PhetArrowButton` scale 0.6 | circle + triangle, no Material icon | Source-equivalent geometry. 3D bevel NOT VERIFIED (sun missing) |
| Index slider | `HSlider` track `Dimension2(210, 1)` thumb `Dimension2(10, 20)` fill white | **not** `knob.png` | `PhetHSlider` | white track, 10×20 thumb, ticks length 11 | Source-equivalent size. Thumb gradient NOT VERIFIED |
| Medium ListBox | `ComboBox` xMargin 7, yMargin 4, cornerRadius 3 | none | `PhetComboBox` | closed white/black, popup list, outside tap closes | Source-equivalent chrome. sun highlight color NOT VERIFIED |
| Index +/− | `ArrowButton` right/left, scale 0.7, arrow 15×15, margin 5 | none | `PhetArrowButton` | circle + triangle | same as wavelength arrows |
| Readout | `Rectangle(0,0,45,20)` fill white stroke black | none | readout `Container` 45×20 | source size | Source-equivalent |
| Wavelength readout | `Rectangle` 60×18 | none | `Container` 60×18 | source size (`maxTextWidth 50 + 10`) | Source-equivalent |
| Checkbox / radio | `sun` `Checkbox`, `AquaRadioButton` | none | `Checkbox`, `TextButton` Ray/Wave | **Material** | still Material — not this pass's first five items, still a structural gap |
| Reset | joist reset | L0 painter | `KratosResetAllButton` radius 19 | unchanged | already L0 |
| Panel title | `Text` `PhetFont(12)` bold | none | `PhetFont.of(12, bold)` | Arial | kept |
| Toolbox background | scenery `Panel` fill `#EEEEEE` | none | `ToolBoxPanel` | unchanged shell | Source-equivalent shell |
| Protractor icon | `ProtractorNode` scale 0.24 | `protractor.png` | `ProtractorToolboxIcon` | image, width 72 | source image, scale approximate |
| Intensity icon | `IntensityMeterNode` scale 0.45 | none (`ProbeNode` vector) | `IntensityToolboxIcon` | green body + `ProbeGlyph` | **simplified**. Not the full scaled node |
| Velocity icon | `VelocitySensorNode` scale 1.2 | none | `VelocityToolboxIcon` | orange body + blue arrow | **simplified** silhouette |
| Wave icon | `WaveSensorNode` scale 0.4 | none | `WaveToolboxIcon` | 54×40 gradient | chart-colored icon, not the full sensor |
| Prism icon | `PrismNode` scaled to height 55 | none | `PrismToolboxIcon` | generic path | **not** `PrismNode` geometry |
| Drag preview | forwarding `DragListener` shows the icon node | same as icon | `ToolboxChip` overlay of `child` | no text chip, no Material elevation | preview = placed icon widget |
| Probe (placed) | `ProbeNode` origin = sensor center | none | `ProbeGlyph` | intensity scale 0.6, radius 50 / inner 35 / handle 50×30 | source defaults. Bevel still secondary |
| Wave probes | `ProbeNode` radius 43, inner 32, handle 40×30, corner 9, scale 0.35, crosshairs | none | `ProbeGlyph` | must match those options where used | verify per screen |
| Graph frame | outer `Rectangle` 135×100 scale 0.93 | none | `WaveSensorBodyPainter` | unchanged from QA-5 | Source-equivalent |
| Graph gradient | `#5EB4DE` → `#005B86` | none | same painter | unchanged | Source-equivalent |
| Graph highlight | `ShadedRectangle` base white, `lightSource: rightBottom`, corner 5 | none | `paintShadedRectangle` | darker top/left, base white center | source factors. Not `Colors.white` |
| Graph waveform | `ChartNode` series | none | `WaveChartPainter` | equation unchanged | Source-equivalent |
| Time label | `PhetFont(16)` at `height * 0.82`, white | none | Time text | unchanged | Source-equivalent |

## Controls that are no longer Material

- `Slider` removed from `MediumControlPanel` and `WavelengthControl`.
- `DropdownButton` removed.
- `TextButton` `+` / `-` removed. Replaced by `PhetArrowButton`.
- Toolbox `Text` chips removed. The visible child is an icon widget. The name remains a semantics label only.

## Still Material (blocks READY)

- `Checkbox` for Normal / Angles / prism checks.
- `TextButton` for Ray / Wave and the time Play / Pause / Step / Normal / Slow row.
- Those still paint Material splash. `sun` checkbox and `TimeControlNode` are not in the local tree.
