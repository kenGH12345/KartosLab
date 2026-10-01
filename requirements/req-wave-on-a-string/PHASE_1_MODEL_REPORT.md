# PHASE 1 — MODEL REPORT · Wave on a String

> **Status:** COMPLETE  
> **Source:** wave-on-a-string **1.3.0-dev.0** (`WOASModel.ts`)  
> **Dart:** `lib/wave_on_a_string/model/woas_model.dart`  
> **No View / Home / assets registered.**

## Summary

Native Dart port of PhET `WOASModel` with:

- 61 beads × 4 buffers (`yLast` / `yNow` / `yNext` / `yDraw`)
- `step` → `manualStep` → `evolve` clock chain
- Manual / Oscillate / Pulse drives
- Fixed / Loose / No End boundaries
- Restart ≠ ResetAll
- Soft ±30% `lastDt` limiter (no invented `maxDT`)

## Files

| Path | Role |
| ---- | ---- |
| `lib/wave_on_a_string/woas_constants.dart` | Constants + tensionFactor/minDt helpers |
| `lib/wave_on_a_string/model/woas_model.dart` | Main model |
| `lib/wave_on_a_string/model/woas_mode.dart` | Drive enum |
| `lib/wave_on_a_string/model/woas_end_type.dart` | Boundary enum |
| `lib/wave_on_a_string/model/woas_time_speed.dart` | Normal/Slow |
| `lib/wave_on_a_string/model/woas_stopwatch.dart` | Timer tool state |
| `test/wave_on_a_string/model/*.dart` | Unit + numeric regression |

## Amplitude conversion (source fact)

```text
UI / Property: amplitudeCm  (default 0.75, range 0..1.3)
Drive: y[0] = amplitudeCm * MODEL_UNITS_PER_CM * f(phase)
MODEL_UNITS_PER_CM = 80
```

Not `amplitudeMeters = cm/100`. Manual mode does **not** use amplitude.

## Frequency (source fact)

```text
angle = (angle + 2π * f * FRAME_DURATION * speedMultiplier) % 2π
y[0] = A * 80 * sin(-angle)
```

## Tests / Analyze

```text
flutter test test/wave_on_a_string/  → 46 PASS
dart analyze lib/wave_on_a_string test/wave_on_a_string → No issues found
```

## Gate

| Gate | Result |
| ---- | ------ |
| 61-bead model | PASS |
| Manual / Oscillate / Pulse | PASS |
| Fixed / Loose / No End | PASS |
| Damping / Tension / Amp / Freq / PulseWidth | PASS |
| Pause / Slow / Clock | PASS |
| Restart ≠ ResetAll | PASS |
| Numeric regression | PASS |
| No Flutter View | PASS |
| No Home changes | PASS |

```text
Phase 1 = COMPLETE
Overall = NOT READY
Home = NOT STARTED
Android = NOT VERIFIED
```
