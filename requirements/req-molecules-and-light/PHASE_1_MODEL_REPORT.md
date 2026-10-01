# PHASE_1_MODEL_REPORT · Molecules and Light

## Goal

Port `PhotonAbsorptionModel` photon/molecule interaction without a view.

## Source mapping

`MoleculesAndLightModel` ← `PhotonAbsorptionModel` + `MoleculesAndLightModel` initial target CO.

Strategies keep the source class split. `absorbedWavelength` is taken from the photon at absorption time.

## Files

`lib/molecules_and_light/model/` — photon, molecule, strategies, model.

The KartosLab Greenhouse Effect climate sim was removed from `lib/`, `test/`, assets, and Home. It is not this model.

## Tests

`flutter test test/molecules_and_light/`

## Status

PHASE 1 model in place. View phases are not started.
