# PHASE_2_MAIN_VIEW_REPORT · Greenhouse Effect

> Date: 2026-09-21  
> Status: **PHASE 2 MAIN SIMULATION VIEW COMPLETE** · overall **NOT READY** (no Home)

---

## Files Changed

**Model**
- `photon.dart`, `photon_collection.dart`
- `flux_meter.dart` (+ sensor)
- `photons_model.dart`, `waves_model.dart`, `layer_model_model.dart`
- `layers_model.dart` — fluxMeter hook in step/reset

**View**
- `greenhouse_model_view_transform.dart`
- `greenhouse_observation_painter.dart`
- `greenhouse_effect_screen.dart` (Waves / Photons / Layer Model tabs)

**Assets**
- `assets/greenhouse_effect/*.png` (original PhET images)
- `pubspec.yaml` asset entry

**Tests / docs**
- `test/greenhouse_effect/model/phase2_model_test.dart`
- `test/greenhouse_effect/view/greenhouse_effect_screen_test.dart`
- `PHASE_2_VIEW_SOURCE_MAP.md`, `GREENHOUSE_EFFECT_VIEWPORT_REPORT.md`, this file, `PHASE_2_VISUAL_QA.md`

---

## Source View Mapping

See `PHASE_2_VIEW_SOURCE_MAP.md`. Three official screens share observation MVT; Flutter exposes them as tabs in one runnable screen (not Home).

---

## Viewport / MVT

See `GREENHOUSE_EFFECT_VIEWPORT_REPORT.md`. Centralized in `GreenhouseModelViewTransform`.

---

## Model additions

| Addition | Source parity notes |
|---|---|
| PhotonCollection | Sun photon rate 10/s; IR from ground T⁴; layer absorb/re-emit |
| WavesModel | Clock-driven visible/IR wave length+phase (simplified vs full Wave attenuator graph) |
| LayerModelModel | 3 layers inactive; IR absorbance 0.1–1; sun proportion; photons+flux |
| FluxMeter | Samples EMEnergyPacket crossings at sensor altitude |

---

## View architecture

```
SimulationClock (always ticking)
  → model.step(dt)   // respects isPlaying / slow
  → setState
  → CustomPaint(GreenhouseObservationPainter)
```

No per-widget fake AnimationControllers for physics.

---

## Assets reused

Landscape + photon PNGs from greenhouse-effect `images/`. **Substituted Material sun icons = 0.**

---

## Animation architecture

Single `SimulationClock` → `GreenhouseEffectModel.step`. Pause freezes model; Step calls `manualStep(1/60)`.

---

## Interactions

Start sunlight, GHG/cloud (concentration screens), layer absorbance/count/sun (Layer Model), flux meter visibility, more photons, Normal/Slow, Pause/Play, Step, Reset All (`KratosResetAllButton`).

---

## Tests / Analyze

```
flutter test test/greenhouse_effect/  → 20 passed
dart analyze lib/greenhouse_effect test/greenhouse_effect → No issues found
```

---

## P0 / P1 / P2

| Level | Count | Notes |
|---|---|---|
| P0 | **0** | Screen runs; photons/waves/layers/flux/reset work |
| P1 | several | Full Wave attenuator/reflection graph simplified; concentration date UI partial; FluxMeter body chrome simplified to readout+altitude line; EnergyLegend not pixel-ported |
| P2 | many | scenery-phet panel bevels, exact checkbox art, cloud ellipse vs asset, thermometer instrument chrome |

---

## Known VERSION_DELTA

- Waves: simplified `GreenhouseWave` vs full `Wave` + attenuator maps + glacier reflection.
- PhotonAbsorbingEmittingLayer: thickness/jump options reduced; Photons screen uses `photonAbsorptionTime: 0` as in source PhotonsModel options.
- Layer Model landscape currently uses twenty-twenties assets (ice-age assets on disk for later).
- Three screens combined via tabs (PhET uses separate Screen instances).

---

## Status

```
PHASE 2 MAIN SIMULATION VIEW COMPLETE
```

Overall: **NOT READY** (Home Integration pending; P1 visual deltas remain).  
Web / Android: **NOT VERIFIED**.
