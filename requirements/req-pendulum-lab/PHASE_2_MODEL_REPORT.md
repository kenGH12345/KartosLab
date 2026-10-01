# PHASE 2 — Model Report

**Source:** `Pendulum.js` / `PendulumLabModel.js` / `EnergyModel.js` / `LabModel.js`  
**Flutter:** `lib/pendulum_lab/model/`

## Physics VERIFIED (unit tests)

| Item | Status |
|------|--------|
| RK4 + float `numSteps=max(7,dt*120)` | PASS |
| frictionTerm linear + ω\|ω\| | PASS |
| Energy KE/PE/thermal transfer | PASS |
| modAngle via `remainder` | PASS |
| Length → ω scale | PASS |
| Rest θ=0 stable | PASS |
| Cross zero continuity | PASS |
| dt cap 0.05 × timeSpeed × 1.007 | PASS |
| stepManual 0.01 | PASS |
| Return vs Reset | PASS |
| Planet X anti-cheat | PASS |
| Earth g = 9.8 | PASS |
| Drag degree round / ±180 ban | PASS |

## Architecture

```
SimulationClock → PendulumLabController → PendulumLabModel.step
Model: no Flutter widgets; ChangeNotifier for view (project convention)
Painter: no physics inside paint()
```

## Tests

`flutter test test/pendulum_lab` → **24 PASS**  
`flutter analyze lib/pendulum_lab test/pendulum_lab` → **No issues**
