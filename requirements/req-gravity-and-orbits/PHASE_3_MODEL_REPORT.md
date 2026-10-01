# PHASE 3 — Model Report · Gravity and Orbits

## Implemented

| Module | Path | Source fidelity |
|---|---|---|
| Constants | `gao_constants.dart` | G, PEFRL ξ/λ/χ, DT, masses, FORCE_SCALE, stage |
| GaoVec / BodyState / Body | `model/` | position/velocity/mass/force/path/rewind |
| ModeConfig + center() | `mode_config.dart` | 4 presets × Model/ToScale |
| ModelState PEFRL | `physics/model_state.dart` | 5-step integrator + moon fudge 10200 |
| PhysicsEngine | `physics/physics_engine.dart` | substeps 1/4/7 × baseDT×0.13125 |
| GaoScene / GaoModel | `gao_scene.dart` / `gao_model.dart` | shared toggles + per-scene engines |
| MVT | `render/gao_mvt.dart` | inverted-Y rectangle mapping |

## Tests

`test/gravity_and_orbits/physics_engine_test.dart` — 11 PASS  
`test/gravity_and_orbits/orbit_regression_test.dart` — long orbit / pause / reset

## Explicit non-substitutions

- Not Euler / Verlet / elliptical closed form  
- Not MSS `NumericalEngine` / G=4.45…  
- Mass change does **not** resize diameter (matches Body.ts)

## Open

- Exact G lock vs phet-core (using 6.67430e-11; orbit regression green)  
- Measuring tape full interaction still thin  
- Explosion animation visual polish
