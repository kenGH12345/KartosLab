# EXPLORE_LAYOUT_SPEC.md

## Module tree

```
BuoyancyExploreScreenView
├── THREE scene + sky
├── AlignBox displayOptions (left, bottom)
├── AlignBox fluidDensityPanel (center, bottom)
├── AlignBox rightSideVBox (right, top)
│   ├── ABControlsNode (A + B controls)
│   ├── objectDensityAccordionBox
│   └── percentSubmergedAccordionBox
├── blocksModeRadioButtonGroup (align with ResetAll)
├── AlignBox resetAll
└── popupLayer
```

## B visibility

Source: `blockB.visibleProperty` / mode TWO_BLOCKS.  
**Semantics:** visibility false on existing mass — **not** “not instantiated”. Controls for B remain in ABControlsNode; accordion readouts rebuild when B shown.

## Dynamic

| Object | Driver |
| ------ | ------ |
| A/B | PHYSICS_DRIVEN model meters |
| mode radio | INPUT_DRIVEN |
| fluid panel | STATIC + model fluid |

## Barrier

`setRightBarrierViewPoint(rightSideVBox.boundsProperty)` — prevents drag behind controls.

Dart: `buoyancy_explore_layout_spec.dart`
