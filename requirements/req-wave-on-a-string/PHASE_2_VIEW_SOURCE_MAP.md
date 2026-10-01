# PHASE 2 — VIEW SOURCE MAP

| PhET View object | Source role | Flutter implementation | Model input |
| ---------------- | ----------- | ---------------------- | ----------- |
| `WOASScreenView` | Root 1024×618 | `WoasScreen` / `WoasPlayArea` | whole model |
| `StringNode` | Path + 61 beads | `WoasStringPainter` | bead0=`nextLeftY`; i≥1=`yDraw[i]` |
| Beads | Circle→toDataURL | CustomPainter circles (VD-BEAD-CACHE) | display Ys |
| `centerLine` | Always-on dash | `WoasCenterLine` | none (y=0) |
| `ReferenceLine` | Tool, default hidden | `ReferenceLinePainter` + drag | `referenceLineVisible/Y` |
| `StartNode` / `WrenchNode` | Manual driver | `WoasStartNode` + wrench PNG | `yNow[0]`, `nextLeftY` drag |
| Oscillator wheel | Oscillate | `_OscillatorWheel` | `angle` |
| Pulse box/button | Pulse | `_PulseBox` → `triggerPulse` | pulse flags |
| `EndNode` clamp | Fixed | clamp.png | `stringEndType` |
| ring + post | Loose | ring PNGs + post | `yDraw[LAST]` |
| window back/front | No End | window PNGs sandwich | `NO_END` |
| `RulerNode`×2 | Tools | `WoasRulersOverlay` (simplified ticks) | visibility + positions |
| `StopwatchNode` | Tools | `WoasStopwatchOverlay` | `stopwatch` time/visible |
| BottomControlPanel / radios / TimeControl / ResetAll | Control area | **Phase 3** | — |

## Coordinate map

```text
model (0,0) → view (VIEW_ORIGIN_X=150, VIEW_ORIGIN_Y=265)
scale = SCALE_FROM_ORIGINAL = 1.25
viewX(i) = 150 + 1.25 * i * 10
viewY(y) = 265 + 1.25 * y
VIEW_END_X = 900
layout = Joist DEFAULT 1024×618
```
