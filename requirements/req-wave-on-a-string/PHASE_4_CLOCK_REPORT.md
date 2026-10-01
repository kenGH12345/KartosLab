# PHASE 4 — CLOCK REPORT

## Source

`WOASModel.step` / `manualStep` · `TimeSpeed.NORMAL=1` · `SLOW=0.25` · `FRAME_DURATION=1/50`

## Flutter

| Control | Mapping | Verified |
| ------- | ------- | -------- |
| Pause | `isPlaying=false` → `step` skips `manualStep` | PASS |
| Play | resume; angle/wave continuous | PASS |
| Step | `manualStep()` one FRAME (or provided dt) while paused | PASS |
| Normal | `speedMultiplier=1` | PASS |
| Slow | `speedMultiplier=0.25` on angle, pulse, stopwatch, minDt | PASS |
| Soft dt | ±30% of `lastDt` — no invented maxDT=0.1 | PASS (Phase 1) |

## Invariants

- One `SimulationClock` → `model.step(dt)`
- No AnimationController-as-physics
- Stopwatch advances only inside `manualStep` with speedMultiplier
- Pause freezes stopwatch (no manualStep)
