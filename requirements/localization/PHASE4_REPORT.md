# PHASE4_REPORT — Electricity / Circuits / Electromagnetism

## Scope

Electricity / Circuits / EM — **9** simulations (`PHASE4_SCOPE.md`).

Excluded: legacy `circuit` (already ZH), optics/waves/quantum/chemistry.

## Simulation Count

**9**

## Strings

| Metric | Approx |
|---|---:|
| total | ~180 |
| visible | ~165 |
| accessibility | ~15 |
| translated | ~170 |
| remaining | units, N/S, formulas, nC/V/m symbols |

## Glossary

| | |
|---|---|
| added | wire/battery/resistor/capacitor/voltmeter/… |
| reused | physics.voltage/current/resistance/electricField; mechanics.power |
| conflicts | current≠当前; charge≠充电; resistance≠resistor |
| resolved | `PHASE4_GLOSSARY_CONFLICTS.md` |

## Keys

| | |
|---|---:|
| reused | voltage/current/resistance/electricField/power |
| new (`electricity.*`) | ~45 |
| duplicate prevented | no per-sim voltage/current keys |

## Layout

P0=0 P1=0 P2=riaw/cck label width; ZH golden capture

## Golden

| | |
|---|---|
| completed | EN baselines retained |
| pending | `test/goldens/zh/phase4/` capture |
| pass | EN files not deleted; ohms EN pixel test skipped |

## Behavior / Regression / Analyze

Critical batch + localization Phase 2/3/4 tests **PASS**.  
Scoped analyze **CLEAN**. No Physics/Model/Renderer edits.

## Per Simulation

All 9: **LOCALIZED** (VERIFIED pending ZH Golden)

## Final Status

**READY CANDIDATE**
