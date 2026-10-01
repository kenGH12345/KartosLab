# PHASE 3 — CONTROLS SOURCE MAP

| Source Control | Source Type | Default | Model State | Handler | Flutter |
| -------------- | ----------- | ------- | ----------- | ------- | ------- |
| Drive Mode | Radio panel TL | Manual | `waveMode` | `setWaveMode` → restart | `WoasRadioPanel` |
| Boundary | Radio panel TR | Fixed End | `stringEndType` | `setStringEndType` (+ Fixed zero end) | `WoasRadioPanel` |
| Amplitude | NumberControl | 0.75 cm | `amplitudeCm` | `setAmplitudeCm` | `WoasNumberControl` (Osc/Pulse) |
| Frequency | NumberControl | 1.50 Hz | `frequencyHz` | `setFrequencyHz` | visible Oscillate only |
| Pulse Width | NumberControl | 0.5 s | `pulseWidthS` | `setPulseWidthS` | visible Pulse only |
| Damping | NumberControl | 20% | `damping` 0..1 | `setDamping(v/100)` | always |
| Tension | NumberControl | 80% | `tension` 0.2..0.8 | `setTension(v/100)` | always |
| Pause/Play | TimeControlNode | playing | `isPlaying` | `setPlaying` | `WoasTimeControls` |
| Step | TimeControlNode | — | — | `manualStep()` | step button |
| Slow/Normal | TimeSpeed radio | Normal | `timeSpeed` | `setTimeSpeed` | Normal / Slow Motion |
| Rulers | Checkbox | off | `rulersVisible` | `setRulersVisible` | checkbox |
| Stopwatch | Checkbox | off | `stopwatch.isVisible` | `setStopwatchVisible` | checkbox |
| Reference Line | Checkbox | off | `referenceLineVisible` | `setReferenceLineVisible` | checkbox |
| Restart | RestartUndoButton | — | — | `restart()` | `WoasRestartButton` |
| Reset All | ResetAllButton | — | — | `resetAll()` | `KratosResetAllButton` |

## Conditional UI (source `BottomControlPanel`)

| Mode | Controls shown |
| ---- | -------------- |
| Manual | Damping, Tension |
| Oscillate | Amplitude, Frequency, Damping, Tension |
| Pulse | Amplitude, Pulse Width, Damping, Tension |

## Mode vs Boundary switch

| Event | Source behavior |
| ----- | --------------- |
| Drive mode change | `manualRestart()` — clear wave; **keep** parameters |
| Boundary → Fixed | `zeroOutEndPoint()` only |
| Boundary → Loose/No End | no string clear |
| Restart | clear wave/phase/pulse; keep controls |
| Reset All | all defaults + restart |
