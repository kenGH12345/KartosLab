# PHASE 6 — RE-ENTRY REPORT · Faraday's Law

## Strategy

```
Back → dispose (clock, listeners, owned model)
Re-entry → new FaradaysLawScreen → new FaradaysLawModel → source initial
```

## Checks after mutate → Back → open

| State | Expected | Result |
| --- | --- | --- |
| Magnet position | `(647, 200)` | PASS |
| Polarity | NS | PASS |
| Coil mode | 1 coil | PASS |
| Field lines | OFF | PASS |
| Voltmeter | OFF | PASS |
| Voltage | 0 | PASS |
| Arrows | ON | PASS |
| Model identity | ≠ previous instance | PASS |

## Multi-round

R1 / R2 / R3: each new model; no shared identity; each starts at initial before local mutation.

## Cross-instance isolation (no Home)

`FaradaysLawModel()` A/B/C independent unit test PASS.
