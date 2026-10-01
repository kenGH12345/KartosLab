# SHAPES_LAYOUT_SPEC.md

## Module tree

```
BuoyancyShapesScreenView
├── THREE + sky
├── AlignBox fluidDensity (center, bottom)
├── AlignBox displayOptions (left, bottom)
├── InfoButton (pool MVT anchored)
├── AlignBox rightSideVBox
│   ├── MultiSectionPanelsNode
│   │   ├── MaterialControlNode
│   │   ├── ShapeSizeControlNode A
│   │   └── ShapeSizeControlNode B (gated visible)
│   ├── objectDensityAccordionBox
│   └── percentSubmergedAccordionBox
├── BlocksModeRadioButtonGroup (with ResetAll)
├── AlignBox resetAll
└── popupLayer
```

## Shape catalog (source order)

block → ellipsoid → verticalCylinder → horizontalCylinder → cone → invertedCone → duck

## Visual ≠ Physics

| Object | Visual | Physics |
| ------ | ------ | ------- |
| Duck | Duck mesh | Ellipsoid |
| Others | matching THREE mesh | matching ShapeGeometry |
| H/V cylinders | distinct meshes | distinct axes — **not** rotate-90 |

## Force scale

`initialForceScale: 1/4` (larger arrows; masses smaller).

## Dynamic

Shape switch: keep bottom Y (Model). Pose: PHYSICS_DRIVEN meters → THREE MVT.

Dart: `buoyancy_shapes_layout_spec.dart`
