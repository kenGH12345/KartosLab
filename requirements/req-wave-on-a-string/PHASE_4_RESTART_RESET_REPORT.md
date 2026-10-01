# PHASE 4 — RESTART / RESET REPORT (Dynamic)

Reconfirms Phase 3 under continuous simulation.

## Restart (`manualRestart` / `restart()`)

**Clears:** y\*, angle, pulse flags, timeElapsed, nextLeftY  

**Keeps:** mode, boundary, amp/freq/pulseWidth, damping, tension, playing, speed, tools, stopwatch time/visibility

## Reset All (`reset` / `resetAll()`)

Restores source defaults:

```text
Manual · Fixed · Amp 0.75 · Freq 1.50 · PulseWidth 0.5
Damping 0.2 · Tension 0.8 · Playing=true · Normal
Tools off · stopwatch reset · wave=0 · reference positions default
```

Including: Reset while paused → `isPlaying=true`.

## Proof

`restart_reset_tools_dynamic_test.dart` + E2E-G/H + Phase 3 control tests — **Restart ≠ ResetAll** PASS
