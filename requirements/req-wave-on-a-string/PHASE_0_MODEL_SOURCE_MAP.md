# PHASE 0 — MODEL SOURCE MAP · Wave on a String

Local source: `phet sourses/wave-on-a-string-main/wave-on-a-string-main`  
Version: **1.3.0-dev.0**

| Source class / function | Role | State | Update | Flutter future class (tentative name only) |
| ----------------------- | ---- | ----- | ------ | ------------------------------------------ |
| `WOASModel` | Main sim model | yLast/yNow/yNext/yDraw; all Properties | `step` → `manualStep` → `evolve` | `WoasModel` |
| `WOASModel.step(dt)` | Clock entry; dt soft-limit; play gate | `lastDtProperty`, `stepDtProperty`, `isPlayingProperty` | accumulate → `manualStep` | same |
| `WOASModel.manualStep(dt?)` | FRAME_DURATION loop; drive; tension timing; stopwatch | `timeElapsed`, `angle`, pulse flags, `yNow[0]`, `yDraw` | per-slice drive + conditional `evolve` | same |
| `WOASModel.evolve()` | Discrete damped wave update α=1 | interior beads + LAST boundary | rotate arrays | same |
| `WOASModel.manualPulse()` | Arm one pulse | pulsePending/sign/angle | sets flags | same |
| `WOASModel.manualRestart()` | Soft reset string | clears y* + pulse/angle | emit changed | same |
| `WOASModel.reset()` | Reset All | all Properties + stopwatch + `manualRestart` | — | same |
| `WOASModel.zeroOutEndPoint()` | Fixed-end switch | LAST yNow/yDraw = 0 | emit | same |
| `waveModeProperty` | **interaction state** Manual/Oscillate/Pulse | enum | mode change → restart | `WoasMode` |
| `stringEndTypeProperty` | **boundary state** | enum | Fixed → zero end | `WoasEndType` |
| `tensionProperty` | **control** → minDt | 0.2–0.8 | live | — |
| `dampingProperty` | **control** → beta | 0–1 | live | — |
| `amplitudeProperty` | **control** drive A | 0–1.3 cm | Oscillate/Pulse | — |
| `frequencyProperty` | **control** drive f | 0–3 Hz | Oscillate | — |
| `pulseWidthProperty` | **control** pulse duration | 0.2–1 s | Pulse | — |
| `isPlayingProperty` | **clock state** | bool default true | Pause/Play | — |
| `timeSpeedProperty` | **clock state** NORMAL/SLOW | enum | speedMultiplier 1/0.25 | — |
| `angleProperty` | oscillator/pulse phase | radians | manualStep | — |
| `nextLeftYProperty` / `leftMostBeadYProperty` | Manual target Y | model units / cm | wrench drag | — |
| `yNowChangedEmitter` | notify view | — | after step/evolve/restart | ChangeNotifier / Stream |
| `isStringStillProperty` | a11y / still detection | flatness heuristic | on yNowChanged | optional |
| `Stopwatch` (scenery-phet) | timer tool | time, visible, position | `stopwatch.step` in manualStep | reuse Kartos stopwatch pattern |
| `WOASMode` | enumeration | MANUAL/OSCILLATE/PULSE | — | Dart enum |
| `WOASEndType` | enumeration | FIXED/LOOSE/NO_END | — | Dart enum |
| `WOASConstants` | beads, FPS, MVT constants | compile-time | — | `woas_constants.dart` |
| `doc/model.md` | conceptual PDE notes | — | documentation only | reference |

## Tagged categories

```text
wave state     → yLast, yNow, yNext, yDraw, timeElapsed, beta, alpha
clock state    → isPlayingProperty, timeSpeedProperty, lastDtProperty, stepDtProperty
control props  → tension, damping, amplitude, frequency, pulseWidth
boundary state → stringEndTypeProperty (+ LAST_INDEX constraints)
interaction    → waveModeProperty, nextLeftYProperty, pulse* flags, wrenchArrowsVisibleProperty
tools          → rulersVisible, referenceLineVisible, positions, stopwatch
```

## Update rule (canonical)

```text
before: yLast, yNow, left drive target, boundary enum, damping, tension, speedMultiplier
  → FRAME_DURATION slices
  → write yNow[0] from Manual/Oscillate/Pulse
  → if timeElapsed >= minDt(tension, speed): evolve()
  → yDraw interpolate
after: rotated buffers + emitter
```

## Explicit non-goals for future Model

- Do **not** replace with pure `A sin(kx−ωt)` field solver.
- Do **not** invent mass/spring constants not in source.
- Preserve Restart ≠ Reset All.
