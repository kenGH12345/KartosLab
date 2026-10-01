# SCREEN_MODEL_CONTRACTS_PHASE1B

Source snapshot = LOCAL `0c835c64`. All models: pure Dart, no Flutter / dart:ui.

## Shared (BuoyancyScreenModel)

| Item | Contract |
| ---- | -------- |
| Inputs | `step(externalDt)`, drag `(id, BVec2 meters)`, `setGravity`, `setFluidMaterial`, `pause/resume/dispose`, `reset` |
| Outputs | `world.snapshot()`, lifecycle |
| Clock | injectable via `BuoyancyPhysicsWorld(clock:)` ; default owned by world |
| Shared Domain | `BuoyancyPhysicsWorld` only physics truth |

## Compare — BuoyancyCompareModel

| Item | Contract |
| ---- | -------- |
| Inputs | `setComparisonMode`, `setSameMass`, `setSameVolume`, `setSameDensity`, drag, step, reset |
| Outputs | `blockA/B`, mode, shared control values, snapshot |
| Mutable | mode, three shared numbers, 6 masses visibility/params |
| Shared deps | one `BuoyancyPhysicsWorld` for all cubes |
| Reset | mode→SAME_MASS; controls→defaults; `world.resetWorld`; reposition; visibility |
| User actions | mode radio; mass/volume/density slider; drag blocks |

## Explore — BuoyancyExploreModel

| Item | Contract |
| ---- | -------- |
| Inputs | `setMode`, `setBlockMaterial`, `setBlockMass`, `setBlockVolume`, drag, fluid, gravity, reset |
| Outputs | blockA/B, mode, snapshot |
| Mutable | mode, A/B material/size/pose |
| Shared deps | world |
| Reset | ONE_BLOCK; A wood 2kg; B Al 13.5kg hidden; water; earth |
| Notes | material keeps volume; named mass resizes volume; custom mass changes density |

## Lab — BuoyancyLabModel

| Item | Contract |
| ---- | -------- |
| Inputs | gravity preset/custom, fluid preset/density, block mass/volume/material, force display flags, drag, reset |
| Outputs | forces on mass, `fluidDisplacedVolumeLiters`, flags |
| Mutable | gravity, fluid, block, display flags |
| Shared deps | world |
| Reset | earth, water, wood 2kg, flags true |
| Notes | no arrow lengths in model |

## Shapes — BuoyancyShapesModel

| Item | Contract |
| ---- | -------- |
| Inputs | `setObjectShape`, `setObjectRatios`, `setMaterial`, `setMode`, drag, reset |
| Outputs | objectA/B shape+mass, material, mode |
| Mutable | shapes, ratios, material, visibility |
| Shared deps | world + `ShapeGeometry` / `SubmergedVolume` |
| Reset | both block 0.25/0.75 wood; B hidden; positions restored |
| Notes | Duck physics = ellipsoid; no visual mesh collider |

## Applications — BuoyancyApplicationsModel

| Item | Contract |
| ---- | -------- |
| Inputs | `setApplicationMode`, bottle interior APIs, block APIs, `resetBoatAndBlockPosition`, drag, reset |
| Outputs | bottle/boat/block, basin volume, mode, snapshot |
| Mutable | mode, interior, basin, spill flag |
| Shared deps | world + piecewise tables |
| Specialized | bottle/boat displacement tables **PASS**; boat basin p2 coupling **P1 OPEN** |
| Reset | bottle mode; interior water 0.004; basin 0 |

## Pointer boundary

View converts pixels → model meters (`BVec2`) before Model APIs. Models never accept Flutter `Offset`.
