# PHASE_0_SOURCE_AUDIT · Molecules and Light

> Date: 2026-09-21

## Goal

Lock the local Molecules and Light source before any Flutter model is written.

## Source version

| Item | Value |
|---|---|
| Package version | `1.6.0-dev.8` (`package.json`) |
| dependencies.json stamp | `1.6.0-dev.7` Tue Mar 28 2023 |
| molecules-and-light SHA | `a7f9b22e77b39e55ce79da55585cbc4ff6d3953e` |
| Physics dependency | `greenhouse-effect` SHA `6c84ad0f…` (`js/micro`, not the KartosLab climate sim) |

`MoleculesAndLightModel` only chooses the initial target and subclasses `PhotonAbsorptionModel`. `MoleculesAndLightScreenView` subclasses `MicroScreenView`. That is the official structure. The climate-scale Greenhouse Effect Flutter sim was removed and is not reused.

## Default state

| Control | Default |
|---|---|
| Photon target | `SINGLE_CO_MOLECULE` (Carbon Monoxide), unless `openSciEd` query which starts on N₂ |
| Wavelength | `IR_WAVELENGTH` = `850e-9` m |
| Emitter | off (`photonEmitterOnProperty` false) |
| Running | true |
| Time speed | NORMAL |
| Emission period when off | +∞ |
| Emission period when on | 0.8 s |
| Slow factor | 0.5 |
| Absorption probability | 0.5 when a strategy exists |

## Model architecture (source names)

- `PhotonAbsorptionModel` — clock, emitter, photon group, active molecule
- `MicroPhoton` — wavelength, position, velocity
- `Molecule` — wavelength → `PhotonAbsorptionStrategy` map
- `PhotonHoldStrategy` stores `absorbedWavelength` from the photon, not from the current selector
- `VibrationStrategy`, `RotationStrategy`, `ExcitationStrategy`, `BreakApartStrategy`, `NullPhotonAbsorptionStrategy`
- Molecules: `CO`, `N2`, `O2`, `CO2`, `CH4`, `H2O`, `NO2`, `O3`

## View architecture

Single screen. `layoutBounds` 768×504. Observation window, quad wavelength panel, molecule panel, time controls, spectrum dialog. No Waves / Photons / Layer Model screens.

## Status

PHASE 0 audit complete. Model migration follows in `lib/molecules_and_light/model`.
