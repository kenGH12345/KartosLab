# Physics Geometry Spec — PHASE 1A

LOCAL SOURCE SNAPSHOT `0c835c64`.

| Shape | Physics Representation | Parameters | Volume | Submerged Volume | Collision | Visual | Difference |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Block | Axis-aligned box | w,h,d | whd | linear in height | AABB | Cuboid mesh + texture | none |
| Ellipsoid | Ellipsoid | w,h,d | 4/3 πabc | t²(3-2t)×V | approx AABB | Ellipsoid mesh | none |
| Vertical cylinder | Cylinder along y | r,h | πr²h | linear | AABB/radius | Cylinder mesh | none |
| Horizontal cylinder | Cylinder along x | r,L | πr²L | acos formula | AABB | Cylinder mesh | none |
| Cone / inverted | Cone | r,h,vertexUp | πr²h/3 | Cone.ts formulas | AABB | Cone mesh | none |
| Duck | **Ellipsoid** | w,h,d | ellipsoid | ellipsoid | AABB | Duck THREE mesh | Visual ≠ physics |
| Bottle | Piecewise tables | areas[], volumes[] | maxVolume | ApplicationsMass | 2D shape + tables | Bottle mesh | Precomputed |
| Boat | Piecewise tables | areas[], volumes[] | maxVolume | ApplicationsMass | 2D shape + tables | Boat mesh | Precomputed + basin |

Flutter: `ShapeGeometry` + `SubmergedVolume`. Boat/Bottle require source tables via `ApplicationGeometry` — table extraction DEFERRED, cube stand-in forbidden.
