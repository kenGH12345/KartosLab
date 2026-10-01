# PHASE 6 — HOME LIFECYCLE QA

| Scenario | Result |
| -------- | ------ |
| create → mount → run → Back → dispose | PASS |
| Oscillate active → Back | PASS · no exception |
| Pulse active → Back | PASS |
| Manual displace → Back | PASS |
| Timer ON → Back | PASS |
| setState after dispose | none observed |
| Ticker after dispose | PlayArea disposes SimulationClock | PASS |

## Ownership chain

```text
Home push
 → WoasScreen.initState → new WoasModel()
 → WoasPlayArea.initState → SimulationClock.attach + play
Back
 → WoasPlayArea.dispose → clock.dispose + removeListener
 → WoasScreen.dispose → model.dispose (if owned)
```
