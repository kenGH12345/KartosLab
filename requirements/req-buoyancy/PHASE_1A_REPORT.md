# PHASE 1A REPORT

```text
PHASE 1A STATUS

Scope:
Shared Domain + Physics Core

Source Version:
1.3.0-dev.2

Local Common Snapshot:
0c835c64

Pinned Lockfile SHA:
0295f8f6

Provenance:
P1 OPEN
(local HEAD ≠ pinned lockfile; no checkout performed)

Shared Domain:
PASS

Material:
PASS

Shape:
PASS

Fluid:
PASS

Mass:
PASS

Gravity:
PASS

Buoyancy:
PASS

Submerged Volume:
PASS
(block/ellipsoid/duck/cylinders/cones + piecewise API)

Physics Step:
PASS

1/120 Fixed Step:
PASS

30 Substep Cap:
PASS

Collision:
PASS
(simplified inelastic walls; not full p2 contact solver)

Drag Constraint:
PASS
(force-limited constraint; NOT Density spring)

Drag Release:
PASS

Boat/Bottle Geometry Boundary:
DEFERRED
(interface + piecewise PASS; source table dump deferred)

Reset Core:
PASS

Determinism:
PASS

Numerical Stability:
PASS
(1000 steps finite)

World Isolation:
PASS

Existing Density Solver:
NOT REUSED

Flutter UI:
NOT STARTED

Layout:
NOT STARTED

Golden:
0 / 0

Android:
NOT VERIFIED

Home:
NOT STARTED

Tests:
33 PASS (test/buoyancy/physics_core_test.dart)
Density smoke: buoyancy styrofoam test PASS

Analyze:
0 errors (lib/buoyancy, test/buoyancy)

P0:
none

P1:
PROVENANCE MISMATCH (0c835c64 vs 0295f8f6)
full p2 contact/friction equivalence
BoatDesign/Bottle precomputed tables not extracted
outer joist clock still UNKNOWN (host supplies externalDt)

P2:
contact force magnitude is approximate wall reaction
viscosity visual force not shown in ForceViewData yet

Status:
READY CANDIDATE
```

## A. Shared Domain

| Domain | Source Class | Flutter Class | Shared | Status |
| --- | --- | --- | --- | --- |
| Material | `Material` | `BuoyancyMaterial` | yes | PASS |
| Gravity | `Gravity` | `BuoyancyGravity` | yes | PASS |
| Mass | `Mass` | `BuoyancyMass` | yes | PASS |
| Shape | `MassShape` + geometries | `ShapeGeometry` / `MassShapeKind` | yes | PASS |
| Pool/Fluid | `Pool`/`Basin` | `BuoyancyPool` | yes | PASS |
| Force | postStep + ForceDiagram | `Force2` + contract | yes | PASS |
| Drag | pointer constraint | `DragConstraint` | yes | PASS |
| World | `DensityBuoyancyModel` | `BuoyancyPhysicsWorld` | yes | PASS |
| Clock | `PhysicsEngine.step` | `PhysicsClock` | yes | PASS |
| Boat/Bottle | `ApplicationsMass` | `ApplicationGeometry` | Applications | DEFERRED tables |

## B. Physics Equations

| Quantity | Source Equation / Algorithm | Unit | Implementation | Status |
| --- | --- | --- | --- | --- |
| Gravity | F_g=(0,-m g) | N | `BuoyancyForces` | PASS |
| Buoyancy | F_b=(0, ρ V_sub (g+a)) | N | same | PASS |
| Viscosity | hacked μ formula + clamp | N | same | PASS |
| Submerged | min(displaced, fluidVolume) | m³ | same | PASS |
| % submerged | 100\|F_b\|/(V g ρ) | % | same | PASS |
| Mass | round(ρ V)+contained | kg | `BuoyancyMass` | PASS |
| Step | 1/120, max 30 | s | `PhysicsClock` | PASS |
| Drag maxForce | 2500 + 0·m | N | `DragConstraint` | PASS |

## C. Shape Physics

| Shape | Physics Representation | Submerged Volume | Collision | Visual Representation |
| --- | --- | --- | --- | --- |
| Block | box | linear | AABB | Cuboid mesh later |
| Ellipsoid | ellipsoid | t²(3-2t) | AABB | mesh later |
| Duck | ellipsoid | ellipsoid | AABB | duck mesh later |
| V/H cylinder | cylinder | source formulas | AABB | mesh later |
| Cone ± | cone | Cone.ts | AABB | mesh later |
| Bottle/Boat | piecewise tables | ApplicationsMass | deferred basin | mesh later |

## D. Force Pipeline

| Step | Source Behavior | Flutter Behavior | Status |
| --- | --- | --- | --- |
| Fluid update | updateFluid → computeY | `pool.computeFluidY` | PASS |
| Constraint | pointer force | `DragConstraint.computeForce` | PASS |
| Buoyancy/visc/g | postStep apply | `BuoyancyForces.applyPostStepForces` | PASS |
| Integrate | p2 world.step | semi-implicit Euler @ 1/120 | PASS (approx) |
| Collide | p2 contacts | inelastic walls | PASS (approx) |

## E. Drag

| Event | Source | Flutter | Status |
| --- | --- | --- | --- |
| start | lift 1e-4 + constraint | `startDrag` | PASS |
| update | pivot follow | `updateDrag` | PASS |
| release | remove, keep v | `endDrag` | PASS |

## F. Tests

| Suite | Tests | Result |
| --- | ---: | --- |
| Buoyancy | 3 | PASS |
| Gravity | 2 | PASS |
| Submerged Volume | 7 | PASS |
| Mass/density | 3 | PASS |
| Drag | 3 | PASS |
| Physics Step | 6 | PASS |
| Determinism | 1 | PASS |
| Stability/isolation/reset/contract | 8 | PASS |
| **Total** | **33** | **PASS** |

## Code layout

```text
lib/buoyancy/
  domain/  material, mass, shape, fluid, force, world
  physics/ constants, clock, submerged_volume, forces, drag, collision, world
  application/ application_geometry.dart
```

No Screen Models. No Flutter UI imports in domain/physics.
