# PHASE 5 GOLDEN MATRIX

Viewport: **1024×618** (design frame). App bounds from `BuoyancyGlobalLayoutSpec`. Camera: FOV 50, up `(0,0,-1)`, zoom `6.125`; Compare lookAt `(0,-0.1,0)` + viewOffset `(-25,0)`; other screens lookAt `(0,-0.18,0)`.

## Gate definition

| Gate | Meaning |
|------|---------|
| Flutter golden | `matchesGoldenFile` determinism vs checked-in PNG |
| Source Δ | Pixel / structure vs user PhET screenshots + local TS |

**本回合用户未附原版截图。** Source Δ 只能做结构/源码事实门禁，不能宣称 vs PhET 像素 PASS。

## Matrix

| Screen | State | Reference | Flutter | Delta | Root Cause | Severity | Result |
|--------|-------|-----------|---------|-------|------------|----------|--------|
| Compare | default (sameMass) | Source camera + LayoutSpec; PhET shot N/A | `compare_default_1024x618.png` | Flutter-Flutter lock OK; vs PhET unknown | Missing user PhET capture | P1 | FLUTTER PASS / SOURCE PENDING |
| Compare | sameVolume | Mode API | `compare_same_volume_1024x618.png` | Two blocks visible L/R; mid radio selected | — | P2 | FLUTTER PASS |
| Compare | reset | Reset API → sameMass | `compare_reset_1024x618.png` | Matches default golden bytes path | — | — | FLUTTER PASS |
| Explore | default | Source defaults wood A | `explore_default_1024x618.png` | Panel + pool + block | PhET chrome Δ (Material radios) | P2 | FLUTTER PASS / SOURCE PENDING |
| Explore | two blocks | Mode twoBlocks | `explore_two_blocks_1024x618.png` | B mesh present | — | — | FLUTTER PASS |
| Explore | aluminum low | Material + pose | `explore_aluminum_low_1024x618.png` | Gray cube, lower pose, fluidY tracked | Texture UV flat vs THREE materials | P1 RENDERER | FLUTTER PASS |
| Lab | default | Earth / water | `lab_default_1024x618.png` | Gravity radios + V_disp + forces panel | — | P2 | FLUTTER PASS / SOURCE PENDING |
| Lab | moon | Gravity preset | `lab_moon_1024x618.png` | Moon selected; scene stable | — | — | FLUTTER PASS |
| Shapes | block | Catalog default | `shapes_block_1024x618.png` | Cuboid mesh | — | — | FLUTTER PASS |
| Shapes | duck | DuckData mesh | `shapes_duck_1024x618.png` | Duck silhouette (not cube) | Flat-shade mesh vs THREE | P1 RENDERER | FLUTTER PASS |
| Shapes | ellipsoid | Ellipsoid mesh | `shapes_ellipsoid_1024x618.png` | Distinct from block/duck | — | — | FLUTTER PASS |
| Applications | bottle | BottleDesign lathe | `applications_bottle_1024x618.png` | Elongated bottle profile, not cylinder stub | No cabin | — | FLUTTER PASS |
| Applications | boat | BoatDesign 1L | `applications_boat_1024x618.png` | Hull silhouette + block; waterline | cabin basin = DEFERRED | P1 FROZEN | FLUTTER PASS / CAVEAT |

## Structural checks (all goldens)

| Item | Observe |
|------|---------|
| viewport / app bounds | 1024×618 MediaQuery + designFrame |
| camera | Perspective FOV 50; Compare offset shifts framing left |
| main object bounds | Model→view projection; no Positioned fake meters |
| waterline | `scene.fluidY` → translucent plane |
| controls / reset | Right panels + `KratosResetAllButton` bottom-right |
| duck / boat / bottle | Source meshes (not cube substitutes) |
| textures | wood/brick/foam/ice/metal asset paths; substituted = 0 |

## Counts

- Golden files: **13**
- Flutter golden PASS: **13 / 13**
- Source-screenshot PASS: **0 / 13** (references not supplied this turn)
- Overall Golden gate for READY: **NOT FULL PASS** (requires Source Δ)

## Renderer note

No THREE engine. Painter's-algorithm triangle mesh is **ADAPTABLE** but marked **P1 RENDERER LIMITATION** for: missing source materials/lighting/depth buffer, flat shading, pool drawn as planes not full THREE scene graph.
