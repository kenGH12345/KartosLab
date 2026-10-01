# COMPARE_SOURCE_EVIDENCE_PHASE2B / EXPLORE / LAB

## Compare

| Feature | File | Evidence |
| ------- | ---- | -------- |
| layoutBounds | BuoyancyCompareScreenView.ts L63 | DEFAULT_LAYOUT_BOUNDS |
| camera | L58–61 | BASICS lookAt + viewOffset |
| AlignBoxes | L71–79 | blocks/display/fluid |
| rightSide layout | L207–218 | modelToView pool + visibleBounds |
| shared pool | Model + CuboidViews | two blocks same scene |

## Explore

| Feature | File | Evidence |
| ------- | ---- | -------- |
| AlignBoxes | ExploreScreenView L43–59, L120 | display/fluid/right |
| mode radio | L122–127 | alignNodeWithResetAllButton |
| B visibility | L92–108 | visibleProperty link rebuilds readouts |
| barrier | L129 | setRightBarrierViewPoint |

## Lab

| Feature | File | Evidence |
| ------- | ---- | -------- |
| forcesInitiallyDisplayed | LabScreenView L44 | true |
| left stack | L65–88 | ManualConstraint left/bottom |
| bottom HBox | L96–112 | fluid + gravity center bottom |
| right VBox | L150–159 | block + density + submerged |
| ForceDiagram | ForceDiagramNode.ts L130 | ×20 mapping |
