# PHASE 1 — MODEL SOURCE MAP · Faraday's Law

## Model Mapping

| PhET class / module | Dart |
|---------------------|------|
| `FaradaysLawConstants.js` | `FaradaysLawConstants` |
| `OrientationEnum` | `MagnetOrientation` |
| `Magnet.js` | `Magnet` |
| `Coil.updateMagneticField` | `magneticFieldAtCoil` + `Coil.updateMagneticField` |
| `Coil.js` | `Coil` |
| `Voltmeter.js` | `VoltmeterModel` |
| `BulbNode` brightness mapping | `BulbModel` |
| `MagnetFieldLines.js` LINE_DESCRIPTION | `FieldLineEllipseSpec` / `FieldLinesModel` / `FieldLineGeometry` |
| `FaradaysLawModel.js` | `FaradaysLawModel` |
| `FaradaysLawScreen` maxDT | `FaradaysLawConstants.maxDt` + `step` clamp |

未移植（Phase 2+ / a11y）：ScreenView、DragListener UI、Keyboard、Sound、PhET-iO。

---

## Formula Mapping

| Source expression | Dart |
|-------------------|------|
| `sign = orientation === NS ? -1 : 1` | `orientation.magneticFieldSign` |
| `r² = dist² / NEAR²` | `rSquared` in `magneticFieldAtCoil` |
| `r² < 1 → B = sign * 2` | same |
| `B = sign * (3·dx² − r²) / r⁴` | same |
| `N = numberOfSpirals / 2` | `Coil.numberOfCoils` |
| `emf = N * (B − B_prev) / dt` | `Coil.step` |
| `signal = 0.2 * (bottom.emf + top.emf)` | `VoltmeterModel.step` |
| Needle Verlet-style integration | `VoltmeterModel.step` (responsiveness 50, friction 10) |
| Activity clamp `< 1e-3 → 0` | same |
| Halo `scale = 20 * \|V\|`, hide if `< 0.1` | `BulbModel.haloScale` / `haloVisible` |
| `dt` capped at `0.1` | `FaradaysLawModel.step` |

---

## State Mapping

| Source Property | Dart state |
|-----------------|------------|
| `magnet.positionProperty` | `Magnet.position` |
| `magnet.orientationProperty` | `Magnet.orientation` |
| `magnet.fieldLinesVisibleProperty` | `Magnet.fieldLinesVisible` |
| `magnet.isDraggingProperty` | `Magnet.isDragging` |
| `topCoilVisibleProperty` | `FaradaysLawModel.topCoilVisible` |
| `magnetArrowsVisibleProperty` | `FaradaysLawModel.magnetArrowsVisible` |
| `voltmeterVisibleProperty` | `FaradaysLawModel.voltmeterVisible` |
| `voltageProperty` | `VoltmeterModel.voltage` (+ root getter) |
| `coil.magneticFieldProperty` | `Coil.magneticField` |
| `coil.previousMagneticFieldProperty` | `Coil.previousMagneticField` |
| `coil.emfProperty` | `Coil.emf` |
| `voltmeter.signalProperty` | `VoltmeterModel.signal` |
| needle ω / α | `needleAngularVelocity` / `needleAngularAcceleration` |

---

## Coil configuration

| `topCoilVisible` | Coils stepped | N (EMF turns) |
|------------------|---------------|---------------|
| `false` (default) | bottom only | bottom N=2 |
| `true` | bottom + top | bottom N=2, top N=1 |

---

## Field lines

Not a B solver. Model exposes `FieldLineGeometry` with source ellipses `(a,b)`:

| index | a | b |
|-------|---|---|
| 0 | 600 | 300 |
| 1 | 350 | 125 |
| 2 | 180 | 50 |
| 3 | 90 | 25 |

Visibility / magnet position / polarity (`arrowDirectionFlipped` when SN) tracked for Phase 2 Painter.
