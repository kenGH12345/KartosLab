# PHASE_2_REPORT — Layout Archaeology

```
PHASE 2 STATUS

Scope:
Layout Archaeology (2A → 2B → 2C)

Global:
PASS

Compare:
PASS

Explore:
PASS

Lab:
PASS

Shapes:
PASS

Applications:
PARTIAL (structure/mesh PASS; cabin basin coupling DEFERRED)

Coordinate Systems:
PASS

MVT:
PASS (THREE API documented; numeric matrix OPEN for Composer / missing mobius)

Anchor Mapping:
PASS

Constraint Mapping:
PASS

Dynamic Geometry:
PASS

Responsive Rules:
PASS

Typography:
PASS

Asset Geometry:
PASS (audit; wiring Phase 3)

Texture Mapping:
PASS (catalog intent; wiring Phase 3)

Mesh Geometry:
PASS (Boat/Bottle/Duck rules)

Z-Order:
PASS

Source Evidence:
PASS

Geometry Tests:
13 PASS (layout_archaeology_test.dart)

P0:
(none)

P1:
- p2 integration = APPROXIMATE (FROZEN — FOUND DURING LAYOUT: still OPEN)
- Boat cabin updateFluid = DEFERRED (FROZEN)
- provenance SHA mismatch (FROZEN)
- THREE projection matrix without local mobius (Composer)

P2:
- Texture intrinsic size wiring
- Minor baseline/padding

Model:
READY CANDIDATE / FROZEN (Phase 1B unchanged)

Composer:
NOT STARTED

UI:
NOT STARTED

Golden:
0 / 0

Android:
NOT VERIFIED

Home:
NOT STARTED

Status:
READY CANDIDATE
```

---

## A. Global Geometry

| Item | Source | Flutter Rule | Confidence | Status |
| ---- | ------ | ------------ | ---------- | ------ |
| Design size | DEFAULT_LAYOUT_BOUNDS | 1024×618 | HIGH | PASS |
| Scale | Joist getLayoutScale | min(w/1024,h/618) center | HIGH | PASS |
| Insets | MARGIN_SMALL | 5 | HIGH | PASS |
| Camera | DensityBuoyancyScreenView | lookAt/zoom/position constants | HIGH | PASS |
| Production MVT | THREEModelViewTransform | not 2D scale map | HIGH API | PASS / Composer OPEN |

## B. Screen Geometry

| Screen | Root Bounds | Content Bounds | MVT | Primary Region |
| ------ | ----------- | -------------- | --- | -------------- |
| Global | 1024×618 | visible − 5 | THREE | pool center |
| Compare | same | AlignBoxes + right VBox | THREE + Basics lookAt/offset | pool + right panels |
| Explore | same | L/C/R AlignBoxes | THREE default lookAt | pool + right AB |
| Lab | same | left manual + bottom HBox + right | THREE | pool + forces |
| Shapes | same | + InfoButton | THREE; forceScale 1/4 | pool + shape panels |
| Applications | same | mode radio + panels | THREE same | bottle/boat scene |

## C. Major Modules

| Screen | Module | Parent | Category | Anchor | Geometry Rule |
| ------ | ------ | ------ | -------- | ------ | ------------- |
| All | ResetAll | ScreenView | Control | AlignBox R/B | margin 5 |
| All | sky | ScreenView | Structural | visibleBounds | fill |
| Compare | blocksPanel | AlignBox | Control | R/T | — |
| Compare | rightSidePanels | ScreenView | Measurement | pool MVT + visible.right | — |
| Explore | ABControls | right VBox | Control | AlignBox R/T | — |
| Explore | mode radio | ScreenView | Control | with ResetAll | — |
| Lab | fluidDisplaced | left stack | Measurement | visible L/B | — |
| Lab | gravity panel | bottom HBox | Control | center bottom | — |
| Shapes | ShapeSizeControl | right panel | Control | AlignBox R/T | — |
| Shapes | InfoButton | ScreenView | Overlay | pool MVT +10 | — |
| Applications | Bottle/Boat panel | right VBox | Control | mode visibility | — |
| Applications | resetBoat | ScreenView | Functional | pool MVT | boat mode |

## D. Dynamic Geometry

| Screen | Object | Static/Dynamic | Driver | Coordinate Space |
| ------ | ------ | -------------- | ------ | ---------------- |
| All | pool frame | STATIC mesh | — | model→THREE |
| All | waterline | DYNAMIC | PHYSICS | model meters |
| Compare | A/B | DYNAMIC | PHYSICS | model meters |
| Explore | A/B | DYNAMIC | PHYSICS | model meters |
| Lab | block + arrows | DYNAMIC | PHYSICS / MODEL view | model / overlay |
| Shapes | A/B shapes | DYNAMIC | PHYSICS | model meters |
| Applications | bottle/boat/brick | DYNAMIC | PHYSICS | model meters |
| Applications | basin fluid | DYNAMIC | PHYSICS (coupling DEFERRED) | model meters |

## E. Shape / Mesh

| Screen | Object | Visual Geometry | Physics Geometry | Mapping |
| ------ | ------ | --------------- | ---------------- | ------- |
| Shapes | duck | Duck mesh | ellipsoid | visual≠physics |
| Shapes | H/V cyl | distinct meshes | axis params | not rotate-90 |
| Applications | bottle | BottleView | TEN_LITER tables | ≠ cylinder |
| Applications | boat | BoatDesign mesh | ONE_LITER×m³ | ≠ cube |
| Applications | basin | interior mesh | INTERNAL_* / DEFERRED coupling | geometry only |

## F. Assets / Textures

| Asset | Type | Intrinsic Size | Mapping | Reuse |
| ----- | ---- | -------------: | ------- | ----- |
| Material textures | mipmaps / THREE | source | material UV | Phase 3 wire |
| Bottle/Boat | procedural mesh | vertex tables | THREE | source |
| Icons bottle/boat | generated/image | icon helpers | radio | source |
| resetArrow_png | PNG | scenery-phet | reset boat btn | source (note: Reset All still Kratos later) |
| Substituted | — | — | — | **0 target** (wiring later) |

## G. Source Evidence

See `LAYOUT_SOURCE_EVIDENCE.md`.

## H. Risks

See `LAYOUT_RISK_REGISTER_PHASE2.md`.

---

## Artifacts

- `lib/buoyancy/layout/buoyancy_*_layout_spec.dart`
- `test/buoyancy/layout/layout_archaeology_test.dart`
- Phase 2A/2B/2C reports + screen specs

## Next

**PHASE 3 — Visual Component + Composer Implementation**  
Per-screen composers only; Applications must use real Bottle/Boat geometry.
