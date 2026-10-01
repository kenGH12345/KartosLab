# PHASE 4 — DYNAMIC SOURCE MAP · Faraday's Law

> Prove continuous source-defined Model chain. CODE CHANGES = 0 (no lib edits).

## Dynamic chain (source → Flutter)

```
Pointer / setMagnetPosition
        ↓
Magnet.position (+ orientation)
        ↓
Coil.updateMagneticField → magneticFieldAtCoil
        ↓
ΔB = B − previousB
        ↓
EMF = N · ΔB / dt          (Coil.step; N = spirals/2)
        ↓
signal = 0.2 · Σemf        (VoltmeterModel.step)
        ↓
voltage / needle dynamics  (responsiveness 50, friction 10)
        ├──────────────────┐
        ↓                  ↓
Voltmeter needle         Bulb |voltage|
(clamped ±π/2)           haloScale = 20·|V|
```

Polarity: `orientation.magneticFieldSign` → B sign → field-line arrow flip → EMF sign → needle direction.

Coil config: `topCoilVisible` gates whether `topCoil.step` runs; signal always `0.2*(bottom+top)`.

Clock: `SimulationClock.onTick → FaradaysLawModel.step(dt)`; `dt≤0` no-op; `dt>0.1` clamp.

---

## Behavior → Source → Flutter → Test

| Dynamic behavior | Source implementation | Flutter implementation | Test |
| --- | --- | --- | --- |
| Magnet movement | `FaradaysLawModel.moveMagnetToPosition` / drag | `moveMagnetToPosition` / play-area drag | `magnet_motion_test`, `dynamic_behavior_widget_test` A |
| B update | `Coil.updateMagneticField` + calibrated dipole | `Coil.updateMagneticField` / `magneticFieldAtCoil` | `magnet_motion_test` slow trajectory |
| ΔB | `B − previousMagneticField` in `Coil.step` | same | `magnet_motion_test` EMF identity |
| EMF | `emf = N * ΔB / dt` (`Coil.js`) | `Coil.step` | `magnet_motion_test`, Phase 1 induced_voltage |
| Voltage dynamics | `Voltmeter.js` Verlet + friction | `VoltmeterModel.step` | `voltmeter_bulb_field_dynamic_test` |
| Needle | `voltage` as angle; gauge clamp ±π/2 | `needleAngle` / `clampedNeedleAngle` | voltmeter dynamic tests |
| Bulb | `BulbNode` halo `20*\|V\|`, hide `<0.1` | `BulbModel` | bulb dynamic tests |
| Polarity | `Magnet.orientationProperty` flip | `Magnet.flipPolarity` / `flipPolarity` | polarity + widget B |
| Field lines | `MagnetFieldLines` predefined ellipses | `FieldLinesModel.geometry` | field lines dynamic |
| Coil configuration | `topCoilVisibleProperty` | `setTopCoilVisible` + gated `topCoil.step` | `coil_configuration_dynamic_test` |
| Reset | `FaradaysLawModel.reset` (+ VD-02 clear V) | `FaradaysLawModel.reset` | `reset_dynamic_test`, widget lifecycle |
| Clock / dt | Joist `maxDT: 0.1` on screen | `FaradaysLawConstants.maxDt` + clamp | `magnet_motion_test` clock group |
| Control during motion | property listeners; no physics reset on show toggles | `setFieldLinesVisible` / `setVoltmeterVisible` | coil + widget D/E |
| Dispose | ScreenView dispose / clock stop | `SimulationClock.dispose` + removeListener | widget dispose test |

---

## Control impact (physics)

| Control | Changes Model physics? | Notes |
| --- | --- | --- |
| Field Lines toggle | **No** (visibility only) | Does not change B/EMF/voltage |
| Voltmeter toggle | **No** (visibility only) | Does not reset voltage |
| 1 ↔ 2 coil | **Yes** (config) | Gates top coil step; `topCoil.reset()`; may shove magnet if intersecting top restricted area |
| Flip Magnet | **Yes** (polarity) | Flips B sign / field arrows / EMF sign; keeps position |
| Reset All | **Yes** (full) | Restores initial; VD-02 clears voltage immediately |

---

## View-side physics

| Location | Allowed | Found |
| --- | --- | --- |
| `lib/faradays_law/view/` | Read Model state; call `model.step(dt)` from clock | **No** `voltage=` / `emf=` / `ΔB` / brightness formulas |
| Play area clock | `clock.onTick → model.step(dt)` only | Confirmed |

**View Physics Calculations = 0**
