# APPLICATIONS_LAYOUT_SPEC.md

## Module tree

```
BuoyancyApplicationsScreenView
├── THREE (BottleView / BoatView / Cuboid brick / fluid / pool)
│   └── threeRenderer.localClippingEnabled for bottle
├── resetBoatButton (modelToView pool corner; boat mode only)
├── AlignBox rightSideVBox
│   ├── BottlePanel | BoatPanel (mutually exclusive visible)
│   ├── objectDensityAccordionBox
│   └── percentSubmergedAccordionBox
├── AlignBox displayOptions (left, bottom)
├── applicationModeRadioButtonGroup (bottle/boat icons; with ResetAll)
├── AlignBox resetAll
└── popupLayer
```

## Meshes

| Object | Visual | Physics | Layout rule |
| ------ | ------ | ------- | ----------- |
| Bottle | BottleView mesh + clip | TEN_LITER piecewise | **≠** cylinder/cube |
| Boat | BoatDesign vertices | ONE_LITER × stepMultiplier³ | **≠** cube |
| Brick | Cuboid | block | 1:1 |
| Boat basin fluid | interior fluid mesh | basin volume | Geometry OK; **coupling DEFERRED** |

## Waterline

STATIC container mesh + DYNAMIC fluidY (pool and basin). **Never** fixed design Y=312.

## Boat cabin basin

FOUND DURING LAYOUT ARCHAEOLOGY: interior bounds / INTERNAL_* tables exist.  
**Status remains DEFERRED** for fluid coupling — LayoutSpec must not invent transfer.

## MVT

Same THREEModelViewTransform as other Buoyancy screens (`usesSameThreeMvtAsOtherBuoyancyScreens`).

Dart: `buoyancy_applications_layout_spec.dart`
