# PHASE 1 — MODEL TEST MATRIX

| Area | File | Coverage |
| ---- | ---- | -------- |
| Initial state | `woas_model_test.dart` | Manual/Fixed/0.2/0.8/0.75/1.5/playing/tools off/y*=0 |
| Control clamps | `woas_model_test.dart` | amp/freq/damping/tension/pulseWidth ranges |
| Evolve α/β/a/c | `wave_propagation_test.dart` | β mapping, closed form, rotate |
| Propagation | `wave_propagation_test.dart` | neighbor spread, tension cadence |
| Manual | `drive_mode_test.dart` | clamp, play resume, no amp, propagate |
| Oscillate | `drive_mode_test.dart` | sin drive, mode restart, amp live |
| Pulse | `drive_mode_test.dart` | triangular, duration, multi-frame |
| Fixed/Loose/No End | `boundary_test.dart` | endpoint rules, switch semantics |
| Pause/Slow/Clock | `clock_test.dart` | freeze, 0.25, soft ±30%, no hard maxDT |
| Restart vs ResetAll | `reset_restart_test.dart` | preserve vs restore defaults |
| Numeric goldens | `numeric_regression_test.dart` | fixtures A–E |

```text
flutter test test/wave_on_a_string/ → 46 PASS
dart analyze → CLEAN
```
