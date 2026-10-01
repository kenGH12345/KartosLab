# Sun Control Source Audit — FINAL QA-7

Local package is bending-light `1.3.0-dev.0`. There is no `sun/` directory anywhere under `phet sourses`.

| Item | Source File | Node | Dependency | Exists in local version? | Action |
| --- | --- | --- | --- | --- | --- |
| Slider thumb gradient | `sun/js/HSlider.ts` | `HSlider` thumb | sun | NO | `VERSION_DELTA`. Call site only gives track `210×1` white and thumb `10×20`. Do not invent a sun gradient to match 1.2.5. |
| Dropdown highlight | `sun/js/ComboBox.ts` | list highlight fill | sun | NO | `VERSION_DELTA`. Call site gives xMargin 7, yMargin 4, cornerRadius 3. Highlight color is not local. |
| Arrow-button bevel | `sun/js/buttons/ArrowButton.ts` | `ArrowButton` | sun | NO | `VERSION_DELTA`. Call site gives scale, arrow 15×15, margins 5. The 3D bevel is not local. |
| Aqua radio fill | `sun/js/AquaRadioButton.ts` | `AquaRadioButton` | sun | NO | `VERSION_DELTA`. Call site radius is 6. Circle is drawn. Aqua pigment is not local. |
| Checkbox mark path | `sun/js/Checkbox.ts` | `Checkbox` | sun | NO | `VERSION_DELTA`. Call site `boxWidth` 15, spacing 5. Check path is not local. |
| Round button bevel | `sun/js/buttons/RoundPushButton.ts` | play / step chrome | sun | NO | `VERSION_DELTA`. Button radii and icons are local (`scenery-phet`). The 3D face is not. |

Local and used:

| Item | File | Status |
| --- | --- | --- |
| Play triangle | `scenery-phet/js/PlayIconShape.ts` | SOURCE MATCH |
| Pause bars | `scenery-phet/js/PauseIconShape.ts` | SOURCE MATCH |
| Step bar + triangle | `scenery-phet/js/buttons/StepButton.ts` | SOURCE MATCH |
| Play radius 20.8 | `SceneryPhetConstants.DEFAULT_BUTTON_RADIUS` via `PlayPauseStepButtonGroup` | SOURCE MATCH |
| Step radius 15 | `PlayPauseStepButtonGroup` `DEFAULT_STEP_BUTTON_RADIUS` | SOURCE MATCH |
| Speed radios left, spacing 10 | `IntroScreenView` `TimeControlNode` options | SOURCE MATCH |
| Speed labels font 14, group spacing 9 | `TimeSpeedRadioButtonGroup.ts` | SOURCE MATCH |
