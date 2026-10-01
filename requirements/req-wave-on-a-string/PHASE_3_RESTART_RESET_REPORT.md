# PHASE 3 — RESTART / RESET REPORT

## Restart (`manualRestart` / Restart button)

Clears: `y*` buffers, angle, pulse flags, timeElapsed, nextLeftY  

Keeps: mode, boundary, amplitude, frequency, pulseWidth, damping, tension, playing, speed, tools, stopwatch time

## Reset All (`reset`)

Restores:

```text
Manual, Fixed End
Amplitude 0.75 cm, Frequency 1.50 Hz, Pulse Width 0.5 s
Damping 0.2, Tension 0.8
Playing=true, Normal
Tools off, stopwatch reset
wave = 0
```

Plus Restart semantics.

## Proof

`test/wave_on_a_string/controls/restart_vs_reset_test.dart` — **Restart ≠ ResetAll** PASS
