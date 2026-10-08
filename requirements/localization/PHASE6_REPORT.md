# PHASE6_REPORT — Chemistry

## Scope

Chemistry — **15** simulations (`PHASE6_SCOPE.md`). Last domain localization batch.

## Simulation Count

**15**

## Strings

| Metric | Approx |
|---|---:|
| total | ~380 |
| visible | ~340 |
| accessibility | ~25 |
| translated | ~360 |
| remaining | formulas, pH, units (M/mol/L/atm), geometry enum ids, BAM catalog keys |

## Glossary

| | |
|---|---|
| added | atom/element/molecule/ion/proton… acid/base/solution/reactant… |
| reused | physics.mass/pressure/volume/wavelength; quantum.photon; common.resetAll |
| conflicts | atom≠element; solution≠答案; base≠基; concentration≠density; massNumber≠mass |
| resolved | `PHASE6_GLOSSARY_CONFLICTS.md` |

## Keys

| | |
|---|---:|
| new (`chemistry.*`) | ~55 |
| reused | mass/pressure/volume/energy/photon/wavelength/electricField |
| duplicate prevented | no chemistry.mass / chemistry.pressure |

## Legacy

Adapters: Bce/Mp/Som/Baa/Phs/Abs/Iaam/Ban/Bll/Mal/Rpal/Rs/Molarity + BamStrings ZH JSON. Old EN bags/assets retained.

## Layout

P0=0 P1=0 P2=pH/BCE/MP label width; ZH Golden capture

## Golden

| | |
|---|---|
| completed | EN baselines retained |
| pending | `test/goldens/zh/phase6/` capture |
| pass | EN not deleted |

## Behavior / Regression / Analyze

Localization Phase 2–6 tests targeted. No chemistry equation / geometry / pH / concentration solver edits. Formula protection maintained.

## Per Simulation

All 15: **LOCALIZED** (VERIFIED pending ZH Golden)

## Final Status

**READY CANDIDATE**
