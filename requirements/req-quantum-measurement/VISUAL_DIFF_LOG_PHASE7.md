# VISUAL_DIFF_LOG_PHASE7

| Screen | Region | Observed Difference | Root Cause | Source Evidence | Fix | Before | After | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| All | Scale | Risk of per-screen origin drift | duplicated designFrame copies | ScreenView.getLayoutScale | `QmGlobalLayoutSpec.designFrame` shared | 4 copies | 1 primitive | PASS |
| Bloch | Divider | Solid 2px bar | Composer used Container fill | ExperimentDividingLine dash [6,5] | `QmExperimentDividingLine` | solid | dashed | PASS |
| Spin / Coins | Divider | Duplicate painters | copy-paste | same Line primitive | shared widget | 2 painters | 1 | PASS |
| Bloch | Observe | Material ElevatedButton | convenience | TextPushButton | `QmPhetTextButton` | Material | PhET fill | PASS |
| Photons | Play/Pause | Material Icons | convenience | TimeControlNode | `QmTimeControlButton` CustomPaint | Icons | path icons | PASS |
| Photons | Slow | FilterChip | convenience | Checkbox | `QmCheckbox` | chip | 16px box | PASS |
| Bloch | B-field | Material Checkbox | unbounded ListTile | Checkbox 16 | `QmCheckbox` | ListTile | 16 box | PASS |
| Assets | greenPhoton | missing PNG | not copied | PhotonSprites | decode from `_png.ts` | missing | 50×50 PNG | PASS |
| Typography | mixed | Roboto/default vs Arial | no shared PhetFont | PhetFont | `QmTypography` | mixed | Arial 14/16/20 | PASS |

Threshold: geometry tests catch ≥10px structure errors; Golden is evidence of raster, not a license to offset.
