# PHASE 4 — DYNAMIC TEST MATRIX · Faraday's Law

## Behavior matrix (observable)

| Scenario | B | EMF | Voltage | Needle | Bulb | Field |
| --- | --- | --- | --- | --- | --- | --- |
| Stationary | stable | ~0 | settles ~0 | ~0 | off | tracks pos if ON |
| Slow move | updates each step | N·ΔB/dt | follows signal | follows V | \|V\| | geometry moves |
| Fast move | same Δpos larger \|EMF\| | larger \|EMF\| | larger transient | larger | brighter | same rules |
| Reverse | ΔB sign flip | EMF sign flip | sign flip | direction flip | same \|V\| | unchanged by reverse alone |
| Stop | holds last B | →0 | damps to 0 | damps | dims | holds pos |
| NS | source sign | baseline | baseline | baseline | \|V\| | arrows NS |
| SN | flipped B | flipped EMF | flipped V | flipped | same \|V\| | arrows flipped |
| 1 coil | bottom only stepped | top emf stale/0 | from bottom | from V | \|V\| | independent |
| 2 coil | both stepped | Σemf | from Σ | from V | \|V\| | independent |
| Field OFF | unchanged | unchanged | unchanged | unchanged | unchanged | not painted |
| Voltmeter OFF | unchanged | unchanged | **preserved** | hidden | unchanged | — |
| Reset | initial | 0 | 0 (VD-02) | 0 | off | OFF |

## Test files

| File | Coverage |
| --- | --- |
| `test/faradays_law/dynamic/magnet_motion_test.dart` | stationary, slow/fast, reverse, stop, deterministic, frame independence, dt, polarity, double flip |
| `test/faradays_law/dynamic/coil_configuration_dynamic_test.dart` | 1/2 coil, persistence, control≠physics reset |
| `test/faradays_law/dynamic/voltmeter_bulb_field_dynamic_test.dart` | needle/signal, \|V\| bulb, field geometry |
| `test/faradays_law/dynamic/reset_dynamic_test.dart` | reset after motion; no B history leak |
| `test/faradays_law/dynamic/dynamic_behavior_widget_test.dart` | E2E A–E + reset/dispose lifecycle |
| `test/faradays_law/dynamic/dynamic_test_helpers.dart` | shared trajectories |

## E2E widget scenarios

| ID | Flow | Result |
| --- | --- | --- |
| A | launch → drag magnet | position updates via Model |
| B | Flip → same motion | EMF sign reverses |
| C | 1 coil vs 2 coil same traj | signal differs via Model |
| D | Field OFF/ON during move | visibility only; EMF/V preserved |
| E | Voltmeter OFF/ON | visibility only; Model V preserved |

## Oracle

Tests use Phase 1 Model + source equations/constants — **not** screenshot needle angles.
