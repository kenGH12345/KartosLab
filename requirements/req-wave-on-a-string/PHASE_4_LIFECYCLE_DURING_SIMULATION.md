# PHASE 4 — LIFECYCLE DURING SIMULATION

## Dispose

| Scenario | Result |
| -------- | ------ |
| Oscillate active → dispose PlayArea | PASS — clock disposed; listener removed; no exception on later model notify |
| Pulse + Timer visible → dispose | PASS |

## Reset during motion

Oscillate active → `resetAll()` → wave/phase/params default → mode switch Oscillate → clean re-run **PASS**.

## Performance notes

- 1000× `FRAME_DURATION` Oscillate: finite angle, 61 drawPositions
- Single `SimulationClock` per PlayArea
- No 61× AnimationController / Timer multiplication

## Note

Full Home / route lifecycle QA is **Phase 6** — not in scope here.
