# PHASE 1 — WAVE ALGORITHM REPORT

Source: `WOASModel.evolve` / `manualStep` / `step` (1.3.0-dev.0)

## Buffers

```text
yLast[i]  previous physics step
yNow[i]   current physics step
yNext[i]  computed next (then references rotate)
yDraw[i]  render / interpolate state
i = 0 .. 60  (61 beads)
```

## evolve()

```text
dt = 1; v = 1; dx = 1; α = v*dt/dx = 1
b = damping * 0.2
β = b * dt / 2 = damping * 0.1
a = 1 / (β + 1)
c = 2 * (1 - α²) = 0 when α=1

yNext[0] = yNow[0]

pre-boundary LAST:
  FIXED: yNow[LAST] = 0
  LOOSE: yNow[LAST] = yNow[NEXT_TO_LAST]
  NO_END: yNow[LAST] = yLast[NEXT_TO_LAST]

for i = 1 .. LAST-1:
  yNext[i] = a * (
    (β - 1) * yLast[i]
    + c * yNow[i]
    + α² * (yNow[i+1] + yNow[i-1])
  )

rotate references: yLast ← yNow ← yNext ← old yLast

post-boundary LAST:
  FIXED: yLast[LAST]=yNow[LAST]=0
  LOOSE: yLast[LAST]=oldNow; yNow[LAST]=yNow[NEXT_TO_LAST]
  NO_END: yLast[LAST]=oldNow; yNow[LAST]=yLast[NEXT_TO_LAST]
```

## Tension (NOT α)

```text
tensionFactor = linear(√0.2, √0.8, 0.2, 1, √tension)
minDt = 1 / (50 * tensionFactor * speedMultiplier)
evolve when timeElapsed >= minDt
```

Default tension 0.8 → tensionFactor 1 → minDt = FRAME_DURATION (0.02).

## Damping

```text
β = damping * 0.1
```

## Clock

```text
FRAME_DURATION = 1/50
step(dt): soft-limit |Δdt| ≤ 0.3 * lastDt; if playing accumulate → manualStep
manualStep: while dt >= FRAME_DURATION: drive; maybe evolve; yDraw update
speedMultiplier: Normal=1, Slow=0.25
maxDT named constant: NOT source-defined
```

## Drive

| Mode | Left end |
| ---- | -------- |
| Manual | interpolate `yNow[0]` toward `nextLeftY` across slices |
| Oscillate | `y = A_cm * 80 * sin(-angle)`; `Δangle = 2π f Δt_eff` |
| Pulse | triangular via angle ±da; `y = A_cm * 80 * (-angle/(π/2))` |

## yDraw

- After evolve: `yDraw[i] = yLast[i]` for all i
- Between evolves: interpolate i≥1 from yLast→yNow by `timeElapsed/minDt`
