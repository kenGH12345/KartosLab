# LAYOUT_SOURCE_EVIDENCE.md

Consolidated Phase 2 evidence. Snapshot = LOCAL `0c835c64`.

| Screen | Feature | File | Class | Evidence | Confidence |
| ------ | ------- | ---- | ----- | -------- | ---------- |
| Global | design 1024×618 | CompareScreenView / joist | DEFAULT_LAYOUT_BOUNDS | explicit | HIGH |
| Global | margins | DensityBuoyancyCommonConstants | MARGIN 10 / 5 | L32–46 | HIGH |
| Global | AlignBox | DensityBuoyancyScreenView | addAlignBox | L483–489 | HIGH |
| Global | camera | DensityBuoyancyScreenView | scaleIncrease 3.5 | L122–152 | HIGH |
| Global | THREE MVT | MassView / Mobius | THREEModelViewTransform | imports | HIGH API |
| Global | force ×20 | ForceDiagramNode | setTip | L130 | HIGH |
| Compare | lookAt/offset | CompareScreenView | BASICS | L58–61 | HIGH |
| Compare | right panels | layoutRightSidePanels | modelToView | L207–218 | HIGH |
| Explore | B visibility | ExploreScreenView | visibleProperty | L92–108 | HIGH |
| Explore | mode radio | alignNodeWithResetAllButton | L122–127 | HIGH |
| Lab | forces on | LabScreenView | forcesInitiallyDisplayed | L44 | HIGH |
| Lab | left stack | ManualConstraint | L78–88 | HIGH |
| Shapes | force scale | ShapesScreenView | 1/4 | L61–62 | HIGH |
| Shapes | duck | DuckView | mesh≠ellipsoid | Duck | HIGH |
| Applications | boat reset btn | ApplicationsScreenView | modelToView | L86–94 | HIGH |
| Applications | mode panels | applicationModeProperty | L138–145 | HIGH |
| Applications | basin | BoatDesign INTERNAL_* | geometry | HIGH |
| Applications | coupling | ApplicationsModel.updateFluid | DEFERRED | HIGH |
