# Panel mapping

Source: `MediumControlPanel.ts`, `IntroScreenView.ts`, `FloatingLayout.ts`, `PrismsScreenView.ts`.
Flutter: `control_widgets.dart`, `intro_play_area.dart`, `more_tools_play_area.dart`, `prisms_play_area.dart`.

Widths that depend on measured text are marked measured. They are not copied from a screenshot.

## Source

| Item | Bounds / anchor | Paint |
| --- | --- | --- |
| Medium panel | right = 824 at default bounds. Top panel bottom = 236. Bottom panel top = 273 | `#EEEEEE`, stroke `#696969`, line 1.5, radius 5, xMargin 13.5, yMargin 7 (Prisms 6) |
| Header | `PhetFont(12)` plus `fontWeight: 'bold'`, maxWidth 70 | — |
| Slider | track 210×1 when the readout is shown. Thumb 10×20 | track white |
| Readout | box 45×20. Buttons scale 0.7, spacing 4 | — |
| Laser panel | left 10, top 15 | `#EEEEEE`, xMargin 9, yMargin 6, radius 5, stroke `#696969` |
| Checkbox row | left 20, bottom 489. No panel of its own | checkbox boxWidth 15, spacing 5 |
| Reset | right 824, bottom 489, radius 19 | `ResetAllButton` |

`#f2fa6a` is the unused `MediumControlPanel` options default. The panel that is added uses `#EEEEEE`.

## Flutter

| Item | Source | Flutter | Match |
| --- | ---: | ---: | --- |
| Panel fill | `#EEEEEE` | `SourceLayout.panelFill` | PASS |
| Panel stroke | `#696969` / 1.5 / radius 5 | same constants | PASS |
| Panel width | 210 + 2×13.5 = 237 | `mediumPanelWidth` 237 | PASS |
| Header | PhetFont 12 bold | `PhetFont.of(12, bold)` | PASS |
| Top panel bottom | 236 | `introTopPanelBottom` | PASS |
| Bottom panel top | 273 | `introBottomPanelTop` | PASS |
| Right edge | 824 (padding 10) | `right: edgePadding` | PASS |
| Laser panel | left 10, top 15, gray | left 10, top 15, gray | PASS |
| Checkbox | left 20, bottom 489, no yellow box | left 20, bottom 15, no yellow box | PASS |
| Reset | padding 10, bottom 15, radius 19 | same | PASS |
| Slider thumb 10×20 | source `HSlider` | Material `Slider` | MISMATCH |
| Combo box | scenery-phet `ComboBox` | Material `DropdownButton` | MISMATCH |
| Arrow buttons | scale 0.7, 15×15 | text `+` / `-` | MISMATCH |
| Panel shadow | source `Panel` shadow is in sun, not in this tree | none | NOT VERIFIED |

The slider, combo box, and arrow buttons are still Material stand-ins. Their outer panel anchor and paint now follow the local source. Their inner chrome does not.
