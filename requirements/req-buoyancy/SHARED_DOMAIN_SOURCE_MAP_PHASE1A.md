# Shared Domain Source Map — PHASE 1A

LOCAL SOURCE SNAPSHOT: `density-buoyancy-common` HEAD `0c835c64`  
PINNED_LOCKFILE_SHA: `0295f8f6` — PROVENANCE MISMATCH = OPEN P1

| Domain | Source File | Class | Shared Across | Responsibility | Evidence |
| --- | --- | --- | --- | --- | --- |
| Material | `common/model/Material.ts` | `Material` | 5 screens + Density | Density, viscosity, colors, mystery | Static table |
| Mass | `common/model/Mass.ts` | `Mass` | 5 screens | m=ρV, drag, forces, % submerged | Multilink + methods |
| Shape | `common/model/MassShape.ts` + `Cuboid`/`Ellipsoid`/`Cone`/… | shapes | Shapes (+ Applications special) | Geometry + displacement | getDisplacedVolume |
| Pool | `common/model/Pool.ts` + `Basin.ts` | `Pool`/`Basin` | 5 screens | Fluid volume, surface Y, materials | computeY |
| Gravity | `common/model/Gravity.ts` | `Gravity` | 5 screens (Lab edits) | g values | EARTH/MOON/… |
| Buoyancy | `common/model/DensityBuoyancyModel.ts` | postStep | 5 screens | F_b = ρ V_sub (g+a) | lines ~294–300 |
| Force | same + `ForceDiagramNode.ts` | forces | 5 screens | Gravity, buoyancy, contact, viscosity | postStep |
| Drag | `Mass.ts` + `PhysicsEngine.ts` | pointer constraint | 5 screens | start/update/end, maxForce 2500 | RevoluteConstraint |
| Clock | `PhysicsEngine.ts` | `step` | 5 screens | fixed 1/120, max 30 substeps | QueryParameters |
| Boat/Bottle | `applications/*` | `ApplicationsMass` | Applications | Piecewise tables | evaluatePiecewiseLinear |

Flutter mapping: `lib/buoyancy/domain/**` + `lib/buoyancy/physics/**`.  
Banned reuse: `lib/density/solver/buoyancy_world.dart` (REFERENCE ONLY).
