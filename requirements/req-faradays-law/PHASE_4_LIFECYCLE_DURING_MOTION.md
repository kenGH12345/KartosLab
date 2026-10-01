# PHASE 4 — LIFECYCLE DURING MOTION · Faraday's Law

## Reset during / after motion

| Check | Result |
| --- | --- |
| Magnet → default position | PASS |
| Polarity → NS | PASS |
| Coil → 1 coil (`topCoilVisible=false`) | PASS |
| Field lines → OFF | PASS |
| Voltmeter → OFF | PASS |
| Voltage / needle ω·α → 0 (VD-02) | PASS |
| EMF → 0 | PASS |
| Bulb brightness → 0 | PASS |
| Magnet arrows → visible again | PASS |
| Prior motion does not contaminate next B/EMF after reset+fresh sync | PASS |

**Natural stop ≠ Reset:** stopping motion leaves B at last value and damps voltage via voltmeter dynamics; `reset()` clears voltage immediately (VD-02) and restores all properties.

Tests: `reset_dynamic_test.dart`, `dynamic_behavior_widget_test` Reset All lifecycle.

## Dispose during motion / clock

| Check | Result |
| --- | --- |
| Dispose play area while clock running | no exception |
| `SimulationClock.dispose` | PASS |
| Model listener removed | PASS (`removeListener` in dispose) |
| No required callbacks after dispose | PASS |
| Model still steppable after view gone | PASS |

Implementation: `FaradaysLawPlayAreaState.dispose` → `clock.dispose()` + `model.removeListener`.

Test: `dispose during clock does not throw; model still usable`.

## Control during motion (summary)

| Control | Mid-motion effect |
| --- | --- |
| Field Lines | Immediate visibility; B/EMF/V unchanged |
| Voltmeter | Immediate show/hide; Model voltage unchanged |
| Coil 1↔2 | Config + `topCoil.reset()`; may relocate magnet if intersecting top restricted zone (source); does **not** clear voltage |
| Flip | Polarity / field arrows / EMF sign; position kept |

## Result

```
Lifecycle during motion = PASS
Reset during motion = PASS
Dispose during motion = PASS
```
