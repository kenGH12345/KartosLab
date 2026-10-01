# PHASE 3 STATUS

Scope:
Visual Component + Screen Composer Implementation

Global Runtime:
PASS

Camera / MVT:
PASS (minimal THREE perspective adapter; KartosLab has no THREE engine)

Renderer:
PASS (ADAPTABLE painter’s-algorithm mesh renderer — not a THREE engine)

Transform:
PASS (`BuoyancyThreeTransform`)

Compare:
PASS

Explore:
PASS

Lab:
PASS

Shapes:
PASS

Applications:
PARTIAL (visual geometry PASS; cabin coupling DEFERRED)

Duck Mesh:
PASS (DuckData.ts BufferGeometry; physics remains ellipsoid)

Boat Mesh:
PASS (`BoatDesign.getPrimaryGeometry` algorithm; bounds match ONE_LITER_BOUNDS)

Bottle Mesh:
PASS (source lathe / TEN_LITER scale — not a Cylinder widget)

Brick:
PASS (cube from source volume)

Textures:
PASS (extracted wood/brick/foam/ice/metal JPEGs; Substituted = 0 for those maps)

Waterline:
PASS (model `pool.fluidY` → scene)

Force Visualization:
PASS (`ForceVisualizationContract` tipY; hide |Fy|<0.05)

Drag / Hit Testing:
PASS (ray ∩ z=0 plane → Model.startDrag)

Composer Architecture:
PASS (five composers; no MegaComposer)

Components:
~28 named visual/runtime pieces (see COMPONENT_INVENTORY_PHASE3.md)

Tests:
138 PASS (`test/buoyancy`)

Regression:
PASS (Density 81 PASS)

Analyze:
`dart analyze lib/buoyancy` — 0 errors (infos only)

Physics Integration:
APPROXIMATE (p2 Euler equivalence unchanged)

Boat Cabin Coupling:
DEFERRED

Original Assets:
PASS (extracted source data-URLs → `assets/buoyancy/images/`)

P0:
none

P1:
- p2 integration equivalence = APPROXIMATE
- boat cabin basin coupling = DEFERRED
- provenance SHA mismatch = OPEN
- THREE internals without mobius = adapter (FOV 50 assumed as THREE default)
- bottle visual is source-constant lathe (not full Bottle.ts base/saddle mesh)

P2:
- overlay controls are source-aligned in placement, not pixel-identical Sun panels
- texture sampling on meshes is fallback vertex color (maps registered, not UV-lit in painter)

Golden:
PREPARED (default screens pump; no golden files)

Android:
NOT VERIFIED

Home:
NOT STARTED

Status:
READY CANDIDATE

---

## A. Screen Composer

| Screen | Composer | LayoutSpec | Camera | Transform | Status |
| ------ | -------- | ---------- | ------ | --------- | ------ |
| Compare | CompareComposer | BuoyancyCompareLayoutSpec | lookAt (0,-0.1,0) offset (-25,0) | BuoyancyThreeTransform | PASS |
| Explore | ExploreComposer | BuoyancyExploreLayoutSpec | default lookAt (0,-0.18,0) | same | PASS |
| Lab | LabComposer | BuoyancyLabLayoutSpec | default | same | PASS |
| Shapes | ShapesComposer | BuoyancyShapesLayoutSpec | default | same | PASS |
| Applications | ApplicationsComposer | BuoyancyApplicationsLayoutSpec | default | same | PARTIAL |

## B. Component Inventory

See `COMPONENT_INVENTORY_PHASE3.md`.

## C. Camera

| Screen | Projection | LookAt | Zoom | Offset | Status |
| ------ | ---------- | ------ | ---- | ------ | ------ |
| Compare | perspective FOV 50 | (0,-0.1,0) | 6.125 | (-25,0) | PASS |
| Explore/Lab/Shapes/Applications | perspective FOV 50 | (0,-0.18,0) | 6.125 | (0,0) | PASS |

## D. Mesh

| Object | Source Geometry | Vertex/Topology | Physics Representation | Status |
| ------ | --------------- | --------------- | ---------------------- | ------ |
| Duck | DuckData.ts positions | 2874 verts / 958 tris | ellipsoid | PASS |
| Boat | BoatDesign.getPrimaryGeometry | 5040 verts; bounds = ONE_LITER | piecewise tables | PASS |
| Bottle | Bottle.ts scale/centroid lathe | 864 verts | TEN_LITER tables | PASS |
| Brick | cubeFromVolume | 8 verts | cube | PASS |

## E. Interaction

| Screen | Pointer Input | World Conversion | Model API | Result |
| ------ | ------------- | ---------------- | --------- | ------ |
| all | Listener down/move/up | getRayFromScreenPoint + z-plane | startDrag/updateDrag/endDrag | PASS |

## F. Assets

| Asset | Source | Flutter | Runtime | Substituted |
| ----- | ------ | ------- | ------- | ----------: |
| wood_col.jpg | Wood26_col_jpg.ts | assets/buoyancy/images/wood_col.jpg | registered | 0 |
| brick_col.jpg | Bricks25_col_jpg.ts | brick_col.jpg | registered | 0 |
| foam_col.jpg | Styrofoam_001_col_jpg.ts | foam_col.jpg | registered | 0 |
| ice_col.jpg | Ice01_col_jpg.ts | ice_col.jpg | registered | 0 |
| metal_col.jpg | Metal10_col_jpg.ts | metal_col.jpg | registered | 0 |
| boat_icon.png | boat_icon_png.ts | boat_icon.png | Applications overlay | 0 |
| bottle_icon.png | bottle_icon_png.ts | bottle_icon.png | Applications overlay | 0 |

## G. Regression

| Suite          | Previous | Current | Result |
| -------------- | -------: | ------: | ------ |
| Shared Physics |       33 |      33 | PASS |
| Screen Model   |       71 |      71 | PASS |
| Density        |       81 |      81 | PASS |
| Layout         |       13 |      13 | PASS |
| PHASE 3 extra  |        0 |      16 | PASS |
| PHASE 4 extra  |        0 |       5 | PASS |
| Buoyancy total |      117 |     138 | PASS |
