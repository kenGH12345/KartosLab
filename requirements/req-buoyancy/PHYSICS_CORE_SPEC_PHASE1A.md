# Physics Core Spec — PHASE 1A

LOCAL SOURCE SNAPSHOT: `0c835c64`  
PINNED_LOCKFILE_SHA: `0295f8f6` (OPEN P1)

## Coordinate system

- Model meters; **+y up**
- Gravity force (0, -mg); buoyancy (0, +ρ V_sub g)

## Units

m, kg, kg/m³, N, s, m³. UI conversion stays out of Model.

## State variables

Per mass: id, position, velocity, material, geometry, containedMass, userControlled, dragTarget, forces, submergedVolume, percentSubmerged.  
Pool: fluidVolume, fluidMaterial, fluidY, bounds.  
Clock: accumulator, simulationTime, paused.

## Forces (postStep order)

1. updateFluid / computeFluidY  
2. constraint force if dragging  
3. submerged = min(displaced, fluidVolume)  
4. F_b if submerged ≠ 0  
5. viscosity (hacked formula from source)  
6. F_g always  
7. percentSubmerged from |F_b|/(V g ρ)

## Integration

Semi-implicit Euler per fixed substep (Dart stand-in for p2). Velocity capped at 5 m/s. Restitution 0.

## Fixed step

`fixedDt = 1/120`, `maxSubSteps = 30`. External frame dt feeds accumulator. Pause freezes; resume continues. **Frame dt ≠ physics dt.**

## Collision

Pool floor/walls, ground y=0 outside pool, invisible barriers ±0.875 x, teleport-up if below pool minY.

## Drag

See `DRAG_CONSTRAINT_SPEC_PHASE1A.md`.

## Reset

`resetWorld` / `resetMass` / clock reset — composable, not one inseparable mega-reset.

## Determinism

Same initial state + same external dt sequence → identical snapshot (tested).

## Boat/Bottle

`ApplicationGeometry` interface + piecewise evaluator. Full BoatDesign/Bottle table dump DEFERRED. No cube approximation.
