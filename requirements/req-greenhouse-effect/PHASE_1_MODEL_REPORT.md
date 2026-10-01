# PHASE_1_MODEL_REPORT · Greenhouse Effect

> Date: 2026-09-21  
> Source SHA: `6c84ad0f43dfc71f8abd72119eef59a3b8b5de9d`  
> Local tree: `phet sourses/greenhouse-effect-main/greenhouse-effect-main`

---

## Goal

Migrate PhET Greenhouse Effect **core energy / radiation / time** semantics into Dart — no final UI, no Home.

---

## Source Model Mapping

| PhET (TS) | Role |
|---|---|
| `GreenhouseEffectModel` | isPlaying, timeSpeed NORMAL/SLOW, step / stepModel / reset |
| `LayersModel` | EMEnergyPacket pipeline; Sun; Ground; 12 AtmosphereLayers; Space; radiative balance |
| `ConcentrationModel` | GHG concentration → IR absorbance; Cloud; date/albedo |
| `EMEnergyPacket` | Visible/IR energy bundle with altitude + direction |
| `EnergyAbsorbingEmittingLayer` | Specific heat + Stefan–Boltzmann IR emission |
| `GroundLayer` | Albedo (visible); absorb; radiate IR up |
| `AtmosphereLayer` | Absorb IR only; radiate IR up+down when active |
| `SunEnergySource` | 343.6 W/m² × area × proportion × dt |
| `SpaceEnergySink` | Remove upward packets at TOA |
| `Cloud` | Partial visible reflection |

Screens Waves / Photons / Layer Model **extend** this core (wave / PhotonCollection visualization).

---

## Dart Model Mapping

| Dart | Path |
|---|---|
| `GreenhouseEffectModel` | `lib/greenhouse_effect/model/greenhouse_effect_model.dart` |
| `LayersModel` | `lib/greenhouse_effect/model/layers_model.dart` |
| `ConcentrationModel` | `lib/greenhouse_effect/model/concentration_model.dart` |
| packets / layers / sun / space / cloud | `lib/greenhouse_effect/model/*.dart` |
| constants | `lib/greenhouse_effect/greenhouse_effect_constants.dart` |

---

## Files Changed

**Added**

- `lib/greenhouse_effect/**` (model + constants)
- `test/greenhouse_effect/model/concentration_model_test.dart`
- `requirements/req-greenhouse-effect/PHASE_1_MODEL_STATE_GRAPH.md`
- `requirements/req-greenhouse-effect/PHASE_1_MODEL_REPORT.md`
- `requirements/req-greenhouse-effect/meta.yaml`, `process.txt`
- `phet sourses/greenhouse-effect-main/greenhouse-effect-main/` (full zip @ pinned SHA; was missing)

**Not touched:** Home, other sims, View.

---

## Physics / State Changes

- Sun produces **visible** downward packets at 50 km when shining.
- Packets move at **9000 m/s** (sim c).
- Ground: visible albedo reflect/absorb; IR fully absorbed; radiates IR upward.
- Atmosphere: IR absorption × concentration × barometric factor; glass radiates both ways.
- Cloud: optional visible top reflection (ConcentrationModel default on).
- Space: removes upward energy at TOA; tracks outgoing rate.
- `netInflowOfEnergy` / `inRadiativeBalance` (|Δ| < 5 W/m²).

---

## Time System

| API | Behavior (source-aligned) |
|---|---|
| `step(dt)` | no-op if paused; SLOW → `dt/2` |
| `stepModel(dt)` | accumulate; fixed substep **1/60 s** |
| `manualStep()` | `stepModel(1/60)` while paused (PhET Step button) |
| `reset()` | sun off, concentration 0.5 BY_VALUE, clear packets, T=245 K, Normal+Playing |

---

## Radiation Lifecycle (tested)

```
create (sun) → move → ground/atmosphere/cloud/space interact
→ absorb / reflect / transmit(attenuate) → re-emit IR → remove at space
```

---

## Tests

```
flutter test test/greenhouse_effect/
→ 12 passed
```

Coverage: initial state, pause, slow, manualStep, sun packet, ground, space, atmosphere IR, ice-age albedo, cloud force-on, reset.

---

## Analyze

```
dart analyze lib/greenhouse_effect test/greenhouse_effect
→ No issues found!
```

---

## Known Gaps (Phase 2+)

| Gap | Notes |
|---|---|
| `PhotonCollection` / discrete `Photon` | Photons + Layer Model screens |
| `WavesModel` / `Wave` | Waves screen visualization |
| `LayerModelModel` | 3-layer manual IR absorbance / active count |
| `FluxMeter` | optional instrument |
| View / Home | explicitly deferred |

Energy semantics for Waves/Photons **share** `ConcentrationModel`; missing pieces are visualization/photon-particle layers, not a different climate formula.

---

## Status

```
PHASE 1 COMPLETE
```

Sim overall: **NOT READY** (no View / Home / Visual QA).  
Android: **NOT VERIFIED**. Web: **NOT VERIFIED**.

Next: **Phase 2 — Main Simulation View** (Observation window + landscape chrome; still no Home until READY CANDIDATE).
