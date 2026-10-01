# SHARED_CONTROL_VISUAL_SPEC_PHASE7

| Control | Source | Fill / stroke | Radius | Font | Padding / size | Flutter primitive | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TextPushButton | sun | experiment `#99CDFF` or start `#72EB97` | ~6 | TITLE 16 | xMargin 20 yMargin 6 | `QmPhetTextButton` | Coins Flip/Reveal; Bloch Observe |
| Aqua radio | sun AquaRadioButton | ring `#0094BD`, 16px, inner 8 | circle | CONTROL 14 | — | `QmAquaRadio` | Photons behavior, Spin prep |
| Checkbox | sun Checkbox | box **16**, stroke black | square | CONTROL 14 | spacing 5 | `QmCheckbox` | Bloch Magnetic Field; Photons Slow |
| Slider | DEFAULT_CONTROL_SLIDER_OPTIONS | track 150×1 black, thumb 12×26 | — | CONTROL | — | `qmSliderTheme` + Slider | Track height 1; thumb approximated round |
| Panel | PANEL_OPTIONS | fill `#F0F0F0`, stroke transparent, xyMargin 10 | 5 Flutter | — | 10 | `QmPanel` | Source stroke transparent; 0.5 hairline kept for contrast (P2) |
| ComboBox | sun ComboBox | white panel | — | CONTROL | yMargin 6 | DropdownButton (Bloch presets) | Same visual family, not identical chrome |
| Time controls | scenery-phet TimeControlNode | play/pause/step icons | — | — | ~36×32 | `QmTimeControlButton` | CustomPaint, **not** Material Icons |
| Reset All | scenery-phet ResetAllButton | `#F79722` | 20.5 | — | — | `KratosResetAllButton` | L0 |
| Scene selector | SceneSelectorRadioButtonGroup | QCT shared | — | SCENE_SELECTOR 26 bold | — | existing QCT widget | Coins + Photons |

Material `ElevatedButton` / `Icons.play_arrow` / `FilterChip` **removed** from Bloch Observe and Photons time row.
Remaining Material: `ChoiceChip` (Bloch axis / Photons polarization) — similar to Aqua group, not identical (P1 polish).
