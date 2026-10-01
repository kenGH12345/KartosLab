# BLOCH_ANIMATION_SPEC_PHASE6

## Clocks

| Clock | Role |
|---|---|
| Model `step(dt)` | Physics: φ precession + measurement delay accumulator |
| Flutter `Ticker` | Supplies elapsed-time `dt` only |
| View | Reprojects tip from Model angles each tick |

No second physics clock in View. No per-frame degree increment.

## Precession

```
Δφ = rotatingSpeed * MAX_PRECESSION_RATE * dt
MAX_PRECESSION_RATE = π/2 rad/s
rotatingSpeed = magneticFieldStrength ∈ [-1,1]  only while TIMING_OBSERVATION && B enabled
```

## Measurement delay (B-field path)

```
timeElapsed += dt * modelToViewTime
when timeElapsed >= measurementDelay → collapse (_observe)
```

## Measurement animation

Source has **no** interpolated collapse tween of the vector. Collapse is instantaneous Model state change; View Multilink updates tip immediately.

## Deterministic checkpoints (Golden prep)

| t | Meaning |
|---|---|
| t=0 | Field Start just pressed; φ = φ₀ |
| t = (π/2) / MAX_PRECESSION_RATE with speed=1 | Quarter turn of φ if delay allows |

Use `BlochAnimationController.stepFixed(dt)` — never `DateTime.now()`.

## Lifecycle

Dispose ticker on screen leave / dispose. Reset / Erase / B-off must not leak timers.
