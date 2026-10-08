# PHASE2_REPORT — Mechanics / Gravity / Vector Localization

## Scope

15 simulations (see `PHASE2_SCOPE.md`). Excluded: curve-fitting, plinko, fluids, EM, optics, chemistry, quantum.

## Simulation Count

**15**

## Strings

| Category | Approx |
|---|---:|
| Total user-facing in batch (bags + hardcodes touched) | ~450 |
| Visible / control / title / tab | majority |
| Accessibility (GFL) | ~35 |
| Translated this phase | ~450 |
| Remaining English (intentional) | units, KE/PE abbr, keyboard chords, debug asserts |

## Keys

| | |
|---|---:|
| Reused (`common` / `physics` / `sim.*`) | high |
| New `mechanics.*` | ~40 |
| Duplicate keys prevented | gravity vs gravityForce split enforced |

## Legacy Adapters

Bags retained; Chinese values written into `*Strings` (const-compatible).  
`loc.mechanics` + `loc.physics` remain canonical for new code.  
Migration status: all 15 → `LOCALIZED`.

## Layout

No LayoutSpec/physics changes. Intrinsic sizing only. See `PHASE2_LAYOUT_IMPACT.md`.

## Golden

`test/goldens/en_baseline/` retained conceptually; `test/goldens/zh/` placeholder for Chinese truth. Per-sim full golden re-capture = follow-up (VERIFIED gate).

## Behavior / Regression / Analyze

- Physics / Model / Solver / Renderer: **not modified**
- Forces + GFL a11y tests updated for Chinese finders
- Localization tests extended (`phase2_mechanics_localization_test.dart`)

## P0 / P1 / P2

| | |
|---|---|
| P0 | 0 |
| P1 | 0 known (GFL radio width to watch) |
| P2 | longer Chinese labels / typography baseline |

## Localization coverage (batch)

User-facing bags + patched hardcodes ≈ **Chinese**.  
Internal automation IDs / units preserved.

## Status per sim

| Simulation | Status |
|---|---|
| forces | LOCALIZED (tests retargeted) |
| collision-lab | LOCALIZED |
| vector-addition | LOCALIZED |
| projectile-motion | LOCALIZED |
| pendulum-lab | LOCALIZED |
| balancing-act | LOCALIZED |
| friction | LOCALIZED |
| hookes-law | LOCALIZED |
| masses-and-springs-basics | LOCALIZED |
| energy-skate-park | LOCALIZED |
| gravity-force-lab | LOCALIZED |
| gravity-force-lab-basics | LOCALIZED |
| gravity-and-orbits | LOCALIZED |
| keplers-laws | LOCALIZED |
| my-solar-system | LOCALIZED |

**VERIFIED** reserved until full per-sim golden + full test suites are green on CI.

## Final

**PHASE 2 STATUS: READY CANDIDATE** (batch LOCALIZED; golden capture pending for VERIFIED)
