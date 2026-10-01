# P2_INTEGRATION_FIDELITY.md

LOCAL common HEAD `0c835c64` ≡ lockfile `0295f8f6` for PhysicsEngine / DensityBuoyancyModel (copyright-only delta).

## Mechanism table

| Mechanism | PhET Source | Flutter | Difference | Visible Impact | Status |
|-----------|-------------|---------|------------|----------------|--------|
| Fixed timestep | `p2FixedTimeStep` default 1/120 | `BuoyancyPhysicsConstants.fixedTimeStep` | none | none | ALIGNED |
| Max substeps | `p2MaxSubSteps` 30 | `maxSubSteps` 30 | none | none | ALIGNED |
| Accumulator / interpolation ratio | `p2.World.step` + `accumulator % dt` | `PhysicsClock.planSubsteps` | no view interpolation of body pose (uses step pose) | sub-frame jitter only | RESIDUAL |
| applyGravity | `world.applyGravity = false` | gravity applied in postStep forces | none (same pattern) | none | ALIGNED |
| Gravity / buoyancy / viscosity formulas | `DensityBuoyancyModel` postStep | `BuoyancyForces.applyPostStepForces` | none for pool masses | none | ALIGNED |
| Velocity clamp 5 m/s | `velocity.magnitude > 5` in postStep | `velocityCap = 5` | none — **SOURCE fact** | none | ALIGNED |
| Restitution | `p2Restitution` 0 | inelastic floor/wall | none | none | ALIGNED |
| Contact solver | p2 GSSolver + ContactMaterial stiffness/relaxation | position projection `CollisionResolver` | no iterative constraint solver | micro bounce / stack order vs p2 | RESIDUAL engine |
| Drag | `p2.RevoluteConstraint` maxForce=2500 | `DragConstraint` force clamp 2500 | constraint type differ; maxForce same | drag feel ≈ force-limited | RESIDUAL engine |
| SIZE_SCALE / MASS_SCALE | internal p2 units | SI model units throughout | Flutter stays SI (PhysicsEngine converts) | none if forces SI | ALIGNED (SI path) |
| Sleeping | p2 wakeUp on drag | no sleep | objects always integrate | negligible for buoyancy sizes | RESIDUAL |
| Boat vertical accel for cabin buoyancy | `getAdditionalVerticalAcceleration` | `boatVerticalAcceleration` via basinContext | present | cabin contents | ALIGNED |

## Closure decision

**P2 Integration: RESOLVED (user-visible Buoyancy semantics)**

Residual: GSSolver / RevoluteConstraint stand-ins remain **engine-layer approximations**, documented above. They are **not** P1 because:

1. Layer: contact solver + pointer constraint implementation only  
2. Cannot ship full p2.js without mechanical engine port (explicitly out of scope)  
3. Normal user ops (drag, float/sink, reset, settle) pass PHASE 5/6 behavioral tests  
4. Final equilibrium density ordering preserved (wood floats / aluminum sinks)  
5. Max observed class of error: contact micro-jitter / drag force profile, not wrong buoyancy direction or teleport  

Forbidden magic (arbitrary damping multipliers beyond source viscosity hack, fake sleep, post-hoc screenshots) is **not** present. `velocityCap=5` is source-authored.
