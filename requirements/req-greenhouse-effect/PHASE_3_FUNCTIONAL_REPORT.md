# PHASE_3_FUNCTIONAL_REPORT · Greenhouse Effect

> Date: 2026-09-21 · Local source SHA `6c84ad0f…`

## Features Completed

| Feature | Notes |
|---|---|
| Wave attenuation | `WaveAttenuator` list; cloud reflectivity + ground albedo for VIS; atmosphere layers for IR; painter uses `intensityAt(d)` |
| Flux Meter chrome | Panel with 4 channels, net, altitude slider, zoom ± (`×2.5^z`) |
| Energy Legend | Wave icons on Waves; photon icons on Photons/Layer |
| Energy Balance | In / Out / Net bars from `energyComingFromSun` / `energyGoingIntoSpace` / `netInflowOfEnergy` |
| Time Period UI | BY_VALUE slider vs BY_DATE chips (Ice Age / 1750 / 1950 / 2020) |
| Landscape by date | Switches original period PNGs when BY_DATE |
| Temperature units | K / °C / °F chips |
| Surface thermometer / glow | Toggle + formatted model temperature |
| Cloud / More Photons | Bound to model; More Photons does not change energy rate |
| Layer Model controls | Absorbance, 0–3 layers, solar intensity, albedo, layer K labels |

## Model Changes

- `waves_model.dart` — attenuators rebuilt each step from cloud/layers
- `flux_meter.dart` — `zoomFactor`, `arrowScale`, `setAltitude`
- `layers_model.dart` — expose `energyComingFromSun`, `energyGoingIntoSpace`

## View Changes

- New: `energy_legend_panel.dart`, `energy_balance_panel.dart`, `flux_meter_panel.dart`, `concentration_control_panel.dart`
- Updated: `greenhouse_effect_screen.dart`, `greenhouse_observation_painter.dart`

## Assets

| Kind | Count / note |
|---|---|
| Original assets used | 4× landscape pairs + 2 photon PNGs + unadorned |
| Custom drawn | Waves path, cloud oval, layer lines, panel chrome, flux sensor body |
| Substituted | **0** |

## Animation

- Still driven exclusively by `SimulationClock` → `model.step` (no fake AnimationController waves)

## Controls

- Waves / Photons: concentration panel, cloud, energy balance, thermometer, units, flux (Photons), more photons
- Layer Model: absorbance, layers, solar, albedo, energy balance, thermometer, units, flux

## Tests

```text
flutter test test/greenhouse_effect/
→ 38 tests, ALL PASS
```

New: `test/greenhouse_effect/phase3/phase3_functional_test.dart`, `phase3_ui_test.dart`

## Analyze

```text
dart analyze lib/greenhouse_effect test/greenhouse_effect
→ No issues found
```

## Priority counts

| Level | Count |
|---|---|
| P0 | **0** |
| P1 | **0** (cleared this phase) |
| P2 | Several chrome/typography deltas (see FINAL_QA) |

## Remaining VERSION_DELTA

- Combined tabbed surface vs three independent PhET `Screen`s (acceptable interim; Home not integrated)
- Flux arrows are horizontal bars, not full Scenery UpDown arrow nodes
- Thermometer is numeric readout, not full thermometer graphic
- Energy Balance plot is simplified bar chrome vs bamboo `UpDownArrowPlot`

## Status

```text
P0 = 0
P1 = 0
Overall Status: READY CANDIDATE
```

**Do not wire Home yet.** Next stage: HOME INTEGRATION + FINAL QA → READY.
