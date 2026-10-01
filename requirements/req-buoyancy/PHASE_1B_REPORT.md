# PHASE 1B REPORT — Five Screen Model Mapping

```
PHASE 1B STATUS

Scope:
Five Screen Model Mapping

Compare Model:
PASS

Explore Model:
PASS

Lab Model:
PASS

Shapes Model:
PASS

Applications Model:
PARTIAL
  STRUCTURE: PASS
  SPECIALIZED GEOMETRY (piecewise tables): PASS
  Boat second-basin p2 fluid coupling: DEFERRED / P1 OPEN

Shared Physics Integration:
PASS

Screen State:
PASS

Initial State:
PASS

User Action Mapping:
PASS

Reset:
PASS

Clock:
PASS

Lifecycle Contract:
PASS

Cross-Screen Isolation:
PASS

Determinism:
PASS

Boat/Bottle Specialized Geometry:
PASS (tables extracted from LOCAL source; not cube stand-ins)
Boat basin updateFluid full fidelity:
DEFERRED

Physics Pipeline Equivalence:
APPROXIMATE (P1 OPEN — semi-implicit Euler + inelastic walls vs p2)
  Impacts: all five screens for surface-crossing / settling / wall / near-equilibrium edge cases

Tests:
104 PASS (Phase 1A 33 + Phase 1B 71)

Analyze:
lib/buoyancy — No errors (info-only use_super_parameters)

Density regression:
81 PASS (untouched lib/density)

P0:
(none)

P1:
- Provenance LOCAL_COMMON_HEAD 0c835c64 vs PINNED 0295f8f6 mismatch (carried from Phase 0/1A)
- Physics pipeline equivalence vs p2 unresolved (APPROXIMATE)
- Applications boat basin childBasin / getPoolFluidVolume full transfer semantics incomplete vs source (structural stub present)
- Shape screen uses single mutable mass per slot instead of full 7-shape phet-io cache (physics-equivalent; PhET-iO parity deferred)

P2:
- use_super_parameters infos on screen model ctors
- Snapshot helpers present but not a full replay harness

Layout:
NOT STARTED

UI:
NOT STARTED

Golden:
0 / 0

Android:
NOT VERIFIED

Home:
NOT STARTED

Status:
READY CANDIDATE
```

---

## A. Screen Model Matrix

| Screen | Model | Shared Domain | Unique State | Controls | Status |
| ------ | ----- | ------------- | ------------ | -------- | ------ |
| Compare | `BuoyancyCompareModel` | `BuoyancyPhysicsWorld` | blockSet map (6 cubes), mode, sameMass/Volume/Density | mode + locked variable | PASS |
| Explore | `BuoyancyExploreModel` | world | A/B, TwoBlockMode | material/mass/volume, show B | PASS |
| Lab | `BuoyancyLabModel` | world | force flags, displaced liters | gravity, fluid, block | PASS |
| Shapes | `BuoyancyShapesModel` | world + ShapeGeometry | A/B slots, shape, ratios, material | shape/ratios/material/mode | PASS |
| Applications | `BuoyancyApplicationsModel` | world + piecewise tables | mode, bottle interior, boat basin | mode, interior, brick | PARTIAL |

## B. Default State

| Screen | Object | Material | Mass | Volume | Fluid | Gravity | Initial Position |
| ------ | ------ | -------- | ---: | -----: | ----- | ------: | ---------------- |
| Compare | A / B (sameMass) | brick / wood | 4 / 4 | 0.002 / 0.01 | water | 9.8 | pool L / R |
| Explore | A / B | wood / Al | 2 / 13.5 | derived | water | 9.8 | (−0.2,0.2) / (0.05,0.35) B hidden |
| Lab | block | wood | 2 | derived | water | 9.8 | (−0.2,0.2) |
| Shapes | A / B | wood | derived | ratios 0.25/0.75 | water | 9.8 | (−0.225,0) / (0.075,0) B hidden |
| Applications | bottle | composite | dens×0.01 | 0.01 | water | 9.8 | (0,0) |

## C. User Action Mapping

| Screen | User Action | Source Handler | Model API | State Effect | Status |
| ------ | ----------- | -------------- | --------- | ------------ | ------ |
| Compare | select same mass/volume/density | blockSetProperty | `setComparisonMode` | visibility swap | PASS |
| Compare | adjust locked mass | massProperty | `setSameMass` | both densities | PASS |
| Compare | adjust locked volume | volumeProperty | `setSameVolume` | both sizes; fixed masses | PASS |
| Compare | adjust locked density | densityProperty | `setSameDensity` | both densities | PASS |
| Explore | show/hide B | modeProperty | `setMode` | B.visible | PASS |
| Explore | material | materialProperty | `setBlockMaterial` | keep V; mass changes | PASS |
| Explore | mass / volume | MaterialMassVolumeControlNode | `setBlockMass` / `setBlockVolume` | size or custom dens | PASS |
| Lab | gravity | gravityProperty | `setSelectedGravityPreset` | world.gravity | PASS |
| Lab | fluid | fluidMaterialProperty | `setFluidPreset` / `setFluidDensity` | pool fluid | PASS |
| Shapes | shape | shapeNameProperty | `setObjectShape` | geometry+submerged | PASS |
| Shapes | ratios | horizontal/verticalRatio | `setObjectRatios` | resize | PASS |
| Applications | bottle/boat | applicationModeProperty | `setApplicationMode` | visibility + basin pour | PASS |
| Applications | bottle interior | materialInside* | `setBottleInterior*` | composite density | PASS |
| All | drag | Mass.startDrag/update/end | `startDrag/updateDrag/endDrag` | DragConstraint | PASS |
| All | reset | model.reset | `reset()` | source defaults | PASS |

## D. Reset

| Screen | State | Source Reset | Flutter Reset | Status |
| ------ | ----- | ------------ | ------------- | ------ |
| Compare | mode+controls+6 cubes+fluid+g | BlockSetModel.reset | `reset()` not `new Model()` | PASS |
| Explore | mode+A/B+fluid | ExploreModel.reset | same | PASS |
| Lab | block+gravity+fluid+flags | LabModel.reset | same | PASS |
| Shapes | shapes+material+mode+pos | ShapesModel.reset | same | PASS |
| Applications | objects+mode+basin | ApplicationsModel.reset + resetBoatAndBlockPosition | both APIs | PASS |

## E. Physics Dependency

| Screen | Shared Physics | Specialized Physics | Status |
| ------ | -------------- | ------------------- | ------ |
| Compare | BuoyancyPhysicsWorld | — | PASS |
| Explore | world | — | PASS |
| Lab | world | — | PASS |
| Shapes | world + SubmergedVolume per shape | Duck=ellipsoid | PASS |
| Applications | world + piecewise SubmergedVolume | boat basin transfer stub | PARTIAL |

## F. Deferred

| Item | Reason | Severity | Blocking Phase |
| ---- | ------ | -------- | -------------- |
| Boat basin full updateFluid | childBasin root-finding / assignable basins / viscosity adjust not fully ported | P1 | Phase 2–3 behavior polish; not blocking model mapping |
| p2 Euler equivalence | Dart fixed-step Euler ≈ p2; not proven equivalent | P1 | Behavior QA |
| Provenance SHA mismatch | local HEAD ≠ lockfile pin | P1 | documentation / release gate |
| PhET-iO shape cache (7×2) | single mutable mass per slot | P2 | PhET-iO (out of scope) |

## G. Tests

| Suite | Tests | Result |
| ----- | ----: | ------ |
| Phase 1A (physics_core) | 33 | PASS |
| Compare | 13 | PASS |
| Explore | 12 | PASS |
| Lab | 11 | PASS |
| Shapes | 14 | PASS |
| Applications | 15 | PASS |
| Isolation + reference | 6 | PASS |
| **Total buoyancy** | **104** | **PASS** |
| Density regression | 81 | PASS |

---

## Artifacts

- `MODEL_SOURCE_EVIDENCE_PHASE1B.md`
- `SCREEN_STATE_MACHINES_PHASE1B.md`
- `SCREEN_MODEL_CONTRACTS_PHASE1B.md`
- `DEFAULT_STATE_SPEC_PHASE1B.md`
- `lib/buoyancy/{compare,explore,lab,shapes,applications}/model/`
- `lib/buoyancy/applications/model/application_displacement_tables.dart` (LOCAL extract)

## Next

**PHASE 2 — FIVE SCREEN LAYOUT ARCHAEOLOGY** (no UI implementation in 1B).
