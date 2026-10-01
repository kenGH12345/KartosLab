# PHASE 6 — HOME LIFECYCLE QA · Faraday's Law

## Lifecycle matrix

| Scenario | Result |
| --- | --- |
| Open from Home | PASS |
| Interact (controls / position) | PASS |
| Back | PASS |
| Dispose (clock + listener + owned model) | PASS |
| Re-enter | PASS |
| Fresh state | PASS |
| Repeat ×3 | PASS |
| Navigate while moving / clock ticking | PASS |
| Navigate during voltage transition | PASS (step then Back) |
| Reset then Back | PASS |
| Controls changed then Back | PASS |

## Ownership

```
Home push FaradaysLawScreen
  → Screen creates FaradaysLawModel (owner)
  → PlayArea SimulationClock → model.step(dt)
Back / pop
  → PlayArea.dispose: clock.dispose + removeListener
  → Screen.dispose: model.dispose (if owned)
```

## No global singleton

Grep `lib/faradays_law/`: no `FaradaysLawModel.instance` / shared static model.
