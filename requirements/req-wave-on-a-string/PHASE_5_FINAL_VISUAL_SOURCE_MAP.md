# PHASE 5 — FINAL VISUAL SOURCE MAP

Source: wave-on-a-string **1.3.0-dev.0** · Flutter Phase 2–3 view

| Visual item | PhET source | Flutter implementation | Result |
| ----------- | ----------- | ---------------------- | ------ |
| Viewport | Joist `DEFAULT_LAYOUT_BOUNDS` 1024×618 | `woasLayoutWidth/Height` 1024×618; FittedBox contain; no AppBar | PASS |
| MVT | `VIEW_ORIGIN=(150,265)` · `SCALE=1.25` | `viewOriginX/Y` · `scaleFromOriginal` | PASS |
| String | `StringNode` Path stroke `#F00` from yDraw | `WoasStringPainter` polyline from `woasBeadDisplayYs` | PASS |
| 61 beads | `NUMBER_OF_BEADS=61`; Circle + highlight; i%10 cyan | same count/colors/radius; CustomPainter (VD-BEAD-CACHE) | PASS |
| Y transform | `modelToViewY = ORIGIN_Y + scale*y` | `modelToViewY`; 0.75cm → 75 view units (not 0.75px) | PASS |
| X geometry | `x_i = ORIGIN_X + scale*i*GAP` | `beadViewX(i)` | PASS |
| Driver Manual | `WrenchNode` + ArrowNode | `Image.asset(wrench.png)` + arrows | PASS |
| Driver Oscillate | StartNode wheel/rod | `WoasStartNode` wheel geometry | PASS |
| Driver Pulse | StartNode pulse chrome | mode branch in StartNode | PASS |
| Fixed End | `clamp.png` at VIEW_END | `WoasAssets.clamp` | PASS |
| Loose End | ringBack/Front + postGradient | original PNGs + gradient post | PASS |
| No End | windowBack behind / windowFront above string | `WoasEndNode` + `WoasWindowFront` | PASS |
| Center line | Line dash `[8,5]` `#6c4a1d` always | `WoasCenterLine` always | PASS |
| Reference Line | separate tool Path `#F00` | `ReferenceLinePainter` gated by checkbox | PASS (≠ center) |
| Ruler | scenery-phet `RulerNode` | `WoasRulersOverlay` (simplified ticks = P2) | PASS |
| Timer | `StopwatchNode` sim time | `WoasStopwatchOverlay` from `WoasStopwatch` | PASS |
| Mode radios | AlignBox top-left green panel | `WoasRadioPanel` Manual/Oscillate/Pulse | PASS |
| End radios | AlignBox top-right | Fixed/Loose/No End | PASS |
| NumberControls | WOASNumberControl Amp/Freq/Pulse/Damp/Tension | `WoasNumberControl` conditional | PASS |
| Pause/Step | `TimeControlNode` | `WoasTimeControls` keys | PASS |
| Speed | Normal / Slow Motion radios | same labels + selection | PASS |
| Restart | RestartUndoButton light blue | `WoasRestartButton` Path glyph (P2 approx) | PASS |
| Reset All | scenery-phet ResetAllButton | `KratosResetAllButton` L0 orange | PASS |
| Bottom panel | `#D9FCC5` | `WoasBottomControlPanel` | PASS |
| Z-order | End behind string; windowFront above; Start above | Stack order in `WoasPlayArea` | PASS |

Screenshots: `requirements/req-wave-on-a-string/visual-qa/screenshots/` (26 PNGs).
