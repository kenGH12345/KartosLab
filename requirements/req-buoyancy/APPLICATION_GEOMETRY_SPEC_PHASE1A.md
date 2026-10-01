# Application Geometry Spec — PHASE 1A

Boundary only. Full table extraction from `Boat.ts` / `Bottle.ts` / `BoatDesign.ts` is **DEFERRED**.

| Item | Status |
| --- | --- |
| Interface `ApplicationGeometry` | PASS |
| Piecewise linear area/volume | PASS (`ApplicationsMass.evaluatePiecewiseLinear`) |
| Second basin (boat) fluid update | DEFERRED to 1B Applications model |
| Cube stand-in | FORBIDDEN |

Shared buoyancy/gravity/step still apply to application masses once tables are supplied.
