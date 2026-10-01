# Drag Constraint Spec — PHASE 1A

Source: `Mass.startDrag` / `updateDrag` / `endDrag` + `PhysicsEngine.addPointerConstraint`.

LOCAL SNAPSHOT `0c835c64`.

## Events

| Event | Source | Flutter | Status |
| --- | --- | --- | --- |
| startDrag | y += 0.0001; RevoluteConstraint; userControlled=true | `DragConstraint.startDrag` | PASS |
| updateDrag | pivotA = pointer model position | `DragConstraint.updateDrag` | PASS |
| endDrag | remove constraint; velocity kept | `DragConstraint.endDrag` | PASS |
| during drag | physics continues; forces still applied | world.step while userControlled | PASS |
| maxForce | `0 * mass + 2500` | `pointerMassForce * m + 2500` | PASS |

## Not Density spring

`lib/density/solver/buoyancy_world.dart` uses spring-damper stiffness 180 / damping 34 capped at 2500.  
Buoyancy Phase 1A uses force-limited positional constraint toward pointer (Dart stand-in for p2 RevoluteConstraint). **NOT REUSED.**

## Forbidden

- `position = pointer` teleport
- `pausePhysics()` on pan start
- `velocity = 0` on release
