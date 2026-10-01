# LAB_LAYOUT_SPEC.md

## Module tree

```
BuoyancyLabScreenView
├── THREE scene + sky
├── leftSideContent (ManualConstraint left/bottom)
│   ├── fluidDisplacedAccordionBox
│   └── displayOptionsPanel
├── AlignBox bottomNode HBox (center, bottom)
│   ├── FluidDensityPanel
│   └── Gravity Panel(GravityControlNode)
├── AlignBox rightSideVBox (right, top)
│   ├── BlockControlNode panel
│   ├── objectDensityAccordionBox
│   └── percentSubmergedAccordionBox
├── AlignBox resetAll
└── popupLayer
```

## Force / measurement

| Item | Layout rule |
| ---- | ----------- |
| Force arrows | On mass overlay; length View-only (−Fy×zoom×20) |
| Lab defaults | forcesInitiallyDisplayed=true; massValuesInitiallyDisplayed=false |
| Fluid displaced | Accordion STATIC position; value MODEL_DRIVEN liters |

## Regions

| Region | Placement |
| ------ | --------- |
| Experiment | THREE pool/object center |
| Measurement (displaced) | left bottom stack |
| Controls | bottom center fluid+gravity; right top block |

Dart: `buoyancy_lab_layout_spec.dart`
