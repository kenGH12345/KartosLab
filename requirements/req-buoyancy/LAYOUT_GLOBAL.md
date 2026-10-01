# LAYOUT_GLOBAL.md — PHASE 2A

Source snapshot = **LOCAL** `0c835c64`. Buoyancy **1.3.0-dev.2**.

## Design bounds

| Item | Value | Evidence |
| ---- | ----- | -------- |
| layoutBounds | `Bounds2(0, 0, 1024, 618)` | Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS`; `BuoyancyCompareScreenView` passes explicitly; other Buoyancy screens do not override |
| design width | 1024 | same |
| design height | 618 | same |
| content margin (AlignBox) | `MARGIN_SMALL` = 5 | `DensityBuoyancyScreenView.addAlignBox` |
| panel margin | `MARGIN` = 10 | `PANEL_OPTIONS.xMargin/yMargin` |
| spacing | 10 / 5 | `SPACING` / `SPACING_SMALL` |

## Global scaling

| Item | Rule |
| ---- | ---- |
| Mode | Uniform center (Joist `ScreenView.getLayoutScale` = min(w/1024, h/618)) |
| Stretch | No — letterbox/pillarbox |
| Screen-specific scale | Same ScreenView matrix for all five; camera lookAt/viewOffset may differ |

## Orientation

Landscape design aspect (1024×618). Joist allows host rotation with letterboxing. No portrait-locked override found in Buoyancy sources.

## Global shell (shared)

| Element | Shared? | Notes |
| ------- | ------- | ----- |
| Sky gradient | Yes | `skyRectangle` fills `visibleBounds` |
| THREE scene (pool/ground/fluid/masses) | Yes | via `DensityBuoyancyScreenView` |
| ResetAllButton | Yes | AlignBox right/bottom |
| displayOptionsPanel | Yes (Buoyancy) | placement screen-specific |
| Navigation / sim title | Joist chrome | outside ScreenView |
| UniversalBuoyancyShell | **Do not invent** | screens differ in panels |

## Camera (scene “MVT” inputs)

| Screen set | lookAt | viewOffset | zoom |
| ---------- | ------ | ---------- | ---- |
| Default Buoyancy | `(0,-0.18,0)` | `(0,0)` | `1.75×3.5` |
| Compare | `(0,-0.1,0)` | `(-25,0)` | same default zoom |

Camera position: `(0, 0.2, 2) × 3.5`.

## Coordinate spaces

See `GLOBAL_COORDINATE_SPEC_PHASE2A.md`.

## Flutter helper

`lib/buoyancy/layout/buoyancy_global_layout_spec.dart`
