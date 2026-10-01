# GLOBAL_VISUAL_SOURCE_EVIDENCE_PHASE7

> Sources: `QuantumMeasurementScreenView.ts`, `QuantumMeasurementConstants.ts`, `QuantumMeasurementColors.ts`, `ExperimentDividingLine.ts`, joist `ScreenView`

| Global Feature | Source Evidence | Coins | Photons | Spin | Bloch |
| -------------- | --------------- | ----- | ------- | ---- | ----- |
| Root bounds | `LAYOUT_BOUNDS = ScreenView.DEFAULT_LAYOUT_BOUNDS` = **1024×618** | same | same | same | same |
| Background | ScreenView default white; Coins scene fills classical `#FFF9F0` / quantum `#F5FAFE` | scene-specific | white | white | white |
| Scale | `ScreenView.getLayoutScale` = `min(w/1024, h/618)`, centered leftover | `QmDesignFrame` | same | same | same |
| Frame | no extra chrome beyond ScreenView + ResetAll | ResetAll BR inset 10 | same | same | same |
| Typography | PhetFont 20/16/14/12/8 + bold 26/20/16/14, Arial stack | `QmTypography` | same | same | same |
| Buttons | sun `TextPushButton`; experiment fill `#99CDFF`; start `#72EB97` | `QmPhetTextButton` | time controls custom | selector | Observe `QmPhetTextButton` |
| Panels | `PANEL_OPTIONS` fill `#F0F0F0`, stroke transparent, margin 10 | mixed | mixed | mixed | mixed |
| Dividers | `ExperimentDividingLine` height 525, stroke 2, dash **[6,5]**, **X screen-specific** | X=389/205 | none | X=300 | X=350 |

Shared: scale, ResetAll, divider **style**, fonts, panel fill.
Not shared: divider X, scene backgrounds, apparatus geometry.
