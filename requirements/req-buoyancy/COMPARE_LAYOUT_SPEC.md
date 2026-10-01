# COMPARE_LAYOUT_SPEC.md

## Module tree

```
BuoyancyCompareScreenView
├── skyRectangle
├── sceneNode (THREE: pool, ground, fluid, masses, scale)
├── massDecorationLayer (forces/tags)
├── AlignBox blocksPanel (right, top)
├── AlignBox displayOptionsPanel (left, bottom)
├── AlignBox fluidPanel (center, bottom)
├── AlignBox resetAll
├── rightSidePanelsVBox (Manual layout from pool MVT)
│   ├── blocksValuePanel
│   ├── densityComparisonAccordionBox
│   └── percentSubmergedAccordionBox
└── popupLayer
```

## Geometry rules

| Module | Rule |
| ------ | ---- |
| Design root | 1024×618 |
| Camera | lookAt (0,-0.1,0); viewOffset (−25,0) |
| Blocks A/B | Model meters → THREE MVT; shared pool; L/R of poolBounds |
| rightSidePanels | top = modelToView(pool max corner).y+5; right = visible.right−5 |
| Force arrows | View mapping ×zoom×20 |

## Dynamic classification

| Object | Driver |
| ------ | ------ |
| blockA/B pose | PHYSICS_DRIVEN |
| comparison mode UI | STATIC / INPUT |
| waterline | PHYSICS_DRIVEN |
| force arrows | MODEL_DRIVEN view |

Dart: `lib/buoyancy/layout/buoyancy_compare_layout_spec.dart`
