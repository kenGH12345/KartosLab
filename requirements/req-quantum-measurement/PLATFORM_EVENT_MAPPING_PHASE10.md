# PLATFORM_EVENT_MAPPING_PHASE10

> Simulation → Platform event vocabulary. Adapters are non-blocking.

| Simulation Event | Meaning | Platform Event | Source |
|---|---|---|---|
| Open | Simulation route entered | `simulation_opened` | host (`QuantumMeasurementHome.initState`) |
| Screen change | Internal tab changed | `simulation_screen_changed` | view (`onTabChanged`) |
| Key action | User action (future hooks) | `simulation_action` | view/model (optional emit) |
| Reset | Source Reset All | `simulation_reset` | model (optional; not auto-wired to every button yet) |
| Exit | Simulation route disposed | `simulation_closed` | host (`dispose`) |

## Implementation

| Component | Path | Status |
|---|---|---|
| `SimulationEvent` / `SimulationEventKind` | `lib/common/simulation/simulation_event.dart` | PASS |
| `NoOpSimulationEventSink` | same | PASS |
| `IsolatingSimulationEventSink` | same — swallows adapter exceptions | PASS |
| Network analytics backend | — | **NOT IMPLEMENTED** |

## Privacy

Simulation events carry only:

- `simulationId` (`quantum-measurement`)
- `kind` / optional `screenId` / `actionId`
- non-PII payload map

No user account / personal profile fields from the sim.

## Failure isolation

```text
event sink throws
  → IsolatingSimulationEventSink catches
  → Coins / Photons / Spin / Bloch continue
```

Verified by unit test `Isolating sink swallows adapter failures`.
