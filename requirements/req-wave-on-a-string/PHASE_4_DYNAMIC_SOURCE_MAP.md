# PHASE 4 — DYNAMIC SOURCE MAP

Source: wave-on-a-string **1.3.0-dev.0** · `WOASModel.ts` / Flutter `WoasModel`

| Behavior | Source implementation | Flutter implementation | Test |
| -------- | --------------------- | ---------------------- | ---- |
| Manual drive | `nextLeftYProperty` + interpolate in `manualStep` | `setManualDisplacement` → `yNow[0]+=perStepDelta` | `dynamic_wave_test` · E2E-A |
| Oscillate drive | `y=A*80*sin(-angle)`; `Δangle=2πf·FRAME·speed` | same in `manualStep` | `dynamic_wave_test` · fixture G |
| Pulse drive | `manualPulse` → triangular `angle` envelope over `pulseWidth` | `triggerPulse` + pulse branch | `dynamic_wave_test` · fixture H · E2E-C |
| Fixed boundary | `y[LAST]=0` pre/post evolve; `zeroOutEndPoint` on switch | `WoasEndType.fixedEnd` | `boundary_reflection_dynamic_test` |
| Loose boundary | `y[LAST]=y[NEXT_TO_LAST]` | `looseEnd` | same |
| No End | `y[LAST]=yLast[NEXT_TO_LAST]` absorbing approx | `noEnd` | same |
| Reflection | Emergent from evolve + boundary (not separate API) | same | Fixed/Loose/No End dynamic |
| Damping | `β=damping*0.1` in `evolve` | `beta` | `dynamic_wave_test` damping group |
| Tension | `minDt=1/(50·tensionFactor·speed)` — **not α** | `minDtFor` | tension evolve cadence test |
| Amplitude | Oscillate/Pulse drive scale only | `amplitudeCm` | amp 0/0.75/1.3 |
| Frequency | Oscillate `Δangle` rate | `frequencyHz` | freq rate test |
| Pulse Width | `da=π·FRAME·speed/pulseWidth` | `pulseWidthS` | width 0.2/0.5/1.0 |
| Pause | `isPlaying=false` → `step` skips `manualStep` | `setPlaying` | `clock_pause_speed_test` |
| Step | `TimeControlNode` → `manualStep()` | `manualStep` / step button | E2E-E |
| Slow | `speedMultiplier=0.25` | `WoasTimeSpeed.slow` | clock tests · E2E-F |
| Restart | `manualRestart()` clear buffers/phase; keep controls | `restart()` | `restart_reset_tools_dynamic_test` |
| Reset All | `reset()` all properties + `manualRestart` | `resetAll()` | same · E2E-H |
| Ruler | visibility + position props | `rulersVisible` + coords | tools dynamic |
| Timer | `stopwatch.step(FRAME*speed)` in `manualStep` | `WoasStopwatch` | tools / clock |

## Dynamic chain (verified)

```text
Drive / Input → WoasModel → step(dt) → manualStep → evolve
→ yLast/yNow/yNext → yDraw → 61 beads → Core View
```

View/Control physics calculations = **0** (sin in Restart glyph painter only).
