# PHASE3_REPORT — Fluids / Density / Buoyancy / Gases

## Scope

Fluids / Density / Buoyancy / Gases — **7** simulations (`PHASE3_SCOPE.md`).

Excluded: concentration, beers-law, states-of-matter, circuits, EM, optics, quantum, chemistry batch.

## Simulation Count

**7**

## Strings

| Metric | Approx |
|---|---:|
| total user-facing in batch | ~220 |
| visible | ~200 |
| accessibility | ~10 |
| translated | ~210 |
| remaining | units, formulas, O₂/Na⁺/ATP, archaeology About body |

## Keys

| Metric | Count |
|---|---:|
| reused (`physics.*` / `common.*`) | density/mass/volume/pressure/buoyancy/particles… |
| new (`fluids.*`) | ~70 |
| duplicates prevented | gravity/density/pressure not recreated per-sim |

## Glossary

- New terms: fluid/liquid/gas/atmosphere/temperature/container/materials…
- Conflicts: fluid≠liquid, wood=木材, pressure=压强 — see `PHASE3_GLOSSARY_UPDATE.md`

## Layout

| Class | Notes |
|---|---|
| overflow | None P0/P1 observed in code constraints |
| clipping | Monitor buoyancy tabs / membrane titles (P2) |
| typography | Phase 1 fallback |
| P0/P1/P2 | **0 / 0 / P2** (label width, ZH golden capture) |

## Golden

| | |
|---|---|
| completed | EN baselines retained |
| pending | Full ZH capture under `test/goldens/zh/phase3/` |
| pass/fail | ZH capture **pending** → blocks VERIFIED |

## Behavior

Critical batch tests **PASS** (density widget, gas home/interaction, membrane solutes, under-pressure core, buoyancy physics_core, localization suite).

## Regression

- `test/localization/` PASS (incl. Phase 2 + Phase 3 + Home/Shared Chrome)
- Phase 3 sim critical tests PASS
- No physics/model/renderer edits

## Analyze

Scoped analyze on touched UI/l10n paths: **CLEAN**

## Simulation Status

| Simulation | Status |
|---|---|
| density | LOCALIZED |
| buoyancy | LOCALIZED |
| under-pressure | LOCALIZED |
| gases-intro | LOCALIZED |
| gas-properties | LOCALIZED |
| diffusion | LOCALIZED |
| membrane-transport | LOCALIZED |

VERIFIED deferred until Chinese Golden capture + full sim golden suite.

## Final Status

**READY CANDIDATE**
