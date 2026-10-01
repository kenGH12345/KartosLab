# PHASE 1 — NUMERIC REGRESSION

Tolerance: typically `1e-12` unless noted.

## Fixture A — undamped center evolve

```text
damping=0, Loose, bead 30: yLast=yNow=10, neighbors 0
after evolve:
  yNow[30] = -10
  yLast[30] = 10
  yNow[29] = yNow[31] = 10
```

## Fixture B — damped isolated→coupled (bead 25, damping=0.2)

```text
β=0.02, a=1/1.02
step1 yNow[25] = -3.843137254901961
step2 yNow[25] =  3.8462129950019217
step3 yNow[25] = -3.695381112844984
```

## Fixture C — Fixed LAST stays 0 over 5 evolves

## Fixture D — Oscillate drive samples

```text
A=0.75 cm, f=1.50 Hz
after n FRAME_DURATION slices:
  angle_n = (2π * 1.5 * 0.02 * n) % 2π
  y0 = 0.75 * 80 * sin(-angle_n)
```

## Fixture E — post-evolve yDraw == yLast (all 61)

## Tension cadence

```text
tension 0.8 → minDt 0.02
tension 0.2 → minDt 0.1
after 3 frames: low tension unevolved (y still 10); high tension evolved
```
