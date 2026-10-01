# PHASE_2_VIEW_REPORT · Molecules and Light

## Goal

Single MicroScreenView-style Flutter surface bound to Phase 1 model.

## Source mapping

`MoleculesAndLightScreen` ← `MicroScreenView` layout (768×504). Observation painter ← `MicroObservationWindow` + `PhotonEmitterNode` + `MicroPhotonNode` + `MoleculeNode`.

## Files changed

- `lib/molecules_and_light/view/molecules_and_light_screen.dart`
- `observation_window_painter.dart`, `molecules_and_light_mvt.dart`
- `model/molecule_geometry.dart`, vibration/rotation in `molecule.dart`
- `assets/molecules_and_light/`
- `test/molecules_and_light/view_test.dart`

## Model binding

UI taps → `MoleculesAndLightModel` setters → `SimulationClock` → `model.step` → CustomPaint.

## Animation

Vibration 5 Hz and rotation 1.1 rev/s from source `Molecule.js`. Photons use model velocity. Pause sets `running=false` so `step` is a no-op.

## Tests

`flutter test test/molecules_and_light/` → **11 PASS**

Analyze → **No issues found**

## P0 / P1 / P2

| Level | Status |
|---|---|
| P0 | 0 |
| P1 | Spectrum diagram is a simplified labelled gradient (not full WavelengthSpectrumNode geometry) — treat as remaining visual gap before READY |
| P2 | Control panel bevel/shadow; molecule 3D CH₄ perspective polish; emitter button is painted circle over PNG |

## Status

```text
PHASE 2 MAIN VIEW COMPLETE
Overall: NOT READY (Home / deeper visual QA not done)
Home: not integrated
```
