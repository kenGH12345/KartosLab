# LAB_RIGHT_PANEL_BASELINE

Source: `LabScreenView.js` · `LabPlayPanel.js` · `PegControls.js` · `StatisticsAccordionBox.js`  
Layout bounds: ScreenView **1024×618**. Panel fixed width **220** layout px.

Local crops: `visual-qa/RIGHT_PANEL/{PLAY,PEG_CONTROLS,STATISTICS}/`

## Stack (LabScreenView)

| Component | Anchor | Original (layout) | Flutter | Δ | Status |
|---|---|---|---|---|---|
| Play | `right: maxX−30`, `top: 10` | w=220 | `LabRightPanelLayout` × scale | 0 parent | PASS |
| PegControls | `top: play.bottom+7`, `right: play.right` | w=220 | same | 0 parent | PASS |
| Statistics | `top: peg.bottom+7`, `right: play.right` | w=220, fill `#FFF5EE` | same | 0 parent | PASS |

Vertical spacing = `PANEL_VERTICAL_SPACING` **7**.

## PLAY (`LabPlayPanel.js`)

| Prop | Original | Flutter | Status |
|---|---|---|---|
| Panel pad | x/yMargin 10 | `playX/YMargin * s` | PASS |
| HBox spacing | 20 | `playHBoxSpacing * s` | PASS |
| Play radius | 30 | `30 * s` (Ø≈71 @1.19) | PASS |
| Play baseColor | `rgb(0,224,121)` | same + 3D radial | PASS |
| Play icon | Path triangle h=r, w=0.8r, +0.1w xOff | same | PASS |
| Pause baseColor | **red** | red (was wrongly yellow) | PASS |
| Radio radius | 8 | `8 * s` diameter | PASS |
| Radio V spacing | 13 | same | PASS |
| Ball icons | ShadedSphereNode Ø16 | `_ShadedBall` | PASS |
| Continuous | 5 balls, spacing −ballW/2, HStrut+⋯ | same | PASS |
| align | center | `Center` + Row | P2 (~10px x AA) |

**Local Diff (01_Lab_initial):** mean≈22 · gt32≈20% → residual = anti-alias / sub-pixel → **P2**

## PEG_CONTROLS (`PegControls.js`)

| Prop | Original | Flutter | Status |
|---|---|---|---|
| fill | white | white | PASS |
| pad | 10×8 | same × s | PASS |
| VBox spacing | 20 | same | PASS |
| NumberControl | layoutFn3, track 170×2, ticks 18 | `PlinkoNumberControl` | PASS |
| Thumb | DEFAULT 17×34 + center line | same × s | PASS |
| Arrows | square ArrowButton | same | PASS |

**Local Diff:** mean≈21 · gt32≈14% → chrome AA / tick label → **P2**

## STATISTICS (`StatisticsAccordionBox.js`)

| Prop | Original | Flutter | Status |
|---|---|---|---|
| fill | `#FFF5EE` | `statsFill` | PASS |
| Title | EquationNode `N` bold red, maxDp=0 | same | PASS |
| Expand button | sideLength 20, right | `_ExpandCollapsePainter` | PASS |
| Sample | x̄ / s / s<sub>mean</sub> red | RichText subscript | PASS |
| Theoretical | μ / σ blue | same | PASS |
| Ideal | Checkbox + HistogramIcon + “Ideal” | same | PASS |
| Format | EquationNode.roundNumber maxDp=3 | `_formatEq` | PASS |
| Model | unchanged | unchanged | PASS |

**Local Diff:** mean≈25 · gt32≈19% → packing/font AA → **P2**

## Gate (this panel)

| Region | Grade |
|---|---|
| Play | **PASS** (P2 residual) |
| PegControls | **PASS** (P2 residual) |
| Statistics | **PASS** (P2 residual) |

→ Lab right-panel **B-P1 = 0** (remaining = P2 only).
