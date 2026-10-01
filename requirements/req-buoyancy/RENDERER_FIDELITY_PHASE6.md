# RENDERER_FIDELITY_PHASE6.md

## RENDERER STATUS: **PASS**

Not “no THREE ⇒ fail”. Evaluated **source-visible semantics** for Buoyancy.

## Evidence

| Concern | Source | Flutter | User-visible loss? |
|---------|--------|---------|-------------------|
| Perspective FOV | THREE default 50° | `fovDegrees: 50` | no |
| lookAt / up / zoom | DensityBuoyancyScreenView / Compare overrides | `BuoyancyCameraConfig` | no |
| Compare viewOffset (−25,0) | BUOYANCY_BASICS_VIEW_OFFSET | `viewOffset: Offset(-25,0)` | no |
| Model→view | THREEModelViewTransform | `BuoyancyThreeTransform` ray + projection | no (pointer roundtrip tests) |
| Duck silhouette | DuckData BufferGeometry | `DuckSourceMesh` | no |
| Boat / Bottle | BoatDesign / Bottle lathe | source meshes | no |
| Waterline | fluidY model | translucent plane at `scene.fluidY` | no |
| Cabin waterline | basin fluidY | `cabinFluidY` plane | no (PHASE 6) |
| Depth buffer / materials | THREE MeshPhong + textures | painter's algorithm + flat shade + JPEG color maps where loaded | **cosmetic only** — silhouette / framing / waterline intact |

## Why PASS (not P1)

Missing THREE engine does **not** produce incorrect buoyancy teaching visuals for the five screens when:

- camera framing matches source knobs  
- meshes are source geometry (not cubes)  
- waterlines track model fluidY  
- drag uses inverse projection  

Residual flat shading / approximate depth sort is **P2 cosmetic**, not P1 fidelity blocker.

## Explicit non-issues

Do **not** reopen P1 solely for “no THREE”.
