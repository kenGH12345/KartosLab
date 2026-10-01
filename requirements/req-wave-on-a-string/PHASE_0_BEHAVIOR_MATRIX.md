# PHASE 0 — BEHAVIOR MATRIX · Wave on a String

All rows are **source-defined** (`WOASModel` / views). Not textbook theory.

| Scenario | Source Behavior |
| -------- | --------------- |
| Initial | Manual + Fixed End; y*=0; damping 0.2; tension 0.8; amp 0.75; freq 1.5; playing; Normal; tools hidden; wrench arrows on |
| Manual drag | Wrench sets `nextLeftYProperty` (±1.3 cm); forces playing; interpolates into `yNow[0]`; interior evolves when `minDt` elapses; release keeps displacement |
| Oscillate | `yNow[0]=A*80*sin(-angle)`; angle += 2πf·FRAME·speedMult; shares same `evolve` for i=1..N-2 |
| Pulse | Button → `manualPulse`; triangular time envelope over `pulseWidth`; then idle until next press |
| Fixed End | `y[LAST]=0` every evolve; switch-to-Fixed calls `zeroOutEndPoint` only |
| Loose End | `y[LAST]=y[NEXT_TO_LAST]` (Neumann / free tip) |
| No End | `y[LAST]=yLast[NEXT_TO_LAST]` absorbing approximation; window graphics |
| Reflection | Emergent from boundary + evolve; Fixed inverts, Loose does not; No End mostly transmits (residual possible) |
| Amplitude change | Immediate next Oscillate/Pulse drive sample; string not cleared |
| Frequency change | Immediate Δangle rate; string not cleared |
| Damping change | Next evolve uses new β; live |
| Tension change | Next minDt uses new tensionFactor; live; higher → faster travel |
| Slow Motion | speedMultiplier=0.25 on phase, pulse, stopwatch, minDt |
| Pause | `isPlaying=false` → `step` skips manualStep; stopwatch frozen |
| Resume | `isPlaying=true` continues; buffers preserved |
| Step while paused | `TimeControlNode` step → `manualStep()` one chunk |
| Rulers | Toggle visibility; draggable; reset restores defaults |
| Timer | Visibility checkbox; advances only in manualStep; reset with Reset All |
| Restart | Clears string/pulse/angle; keeps modes & sliders & tools |
| Reset All | Full property reset + manualRestart + stopwatch |
| Mode switch | `waveModeProperty.lazyLink` → `manualRestart()` (clears wave) |
| Boundary switch | to Fixed → zero last point; else keep existing wave |
| Pause at boundary | Buffers freeze; no special clear |
| Damping min (0) | β=0; least attenuation |
| Damping max (1) | β=0.1; strongest attenuation in formula |
| Tension min (0.2) | slowest evolve cadence |
| Tension max (0.8) | fastest (default) |
| Freq min/max | 0 … 3 Hz drive only |
| Amp min/max | 0 … 1.3 cm drive only |
| Reset while paused | `isPlaying` returns to true (Property reset default) |
| Reset with tools visible | tools hide + positions reset |
| Reset after pulse | pulse flags cleared via manualRestart |
| Reset during wave | string zeroed |

## Edge notes

- Manual drag while paused **auto-starts** play (`isPlaying=true` in wrench drag).
- Oscillate ↔ Manual always **wipes** string (mode restart), unlike boundary Loose↔No End.
- Pulse width replaces Frequency control in UI (AlignGroup same slot).
