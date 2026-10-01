# PHASE_2_VIEW_SOURCE_MAP · Molecules and Light

Source: `MicroScreenView` / `MicroObservationWindow` / panels under `greenhouse-effect/js/micro/view` (Molecules and Light dependency).

## Hierarchy

```text
MoleculesAndLightScreen (Screen)
└── MicroScreenView (layoutBounds 768×504, bg #C5D6E8)
    ├── MicroObservationWindow 500×300 @ (15,15), fill black, r=7
    │   ├── moleculeLayer → MoleculeNode
    │   ├── photonLayer → MicroPhotonNode (PNG by wavelength)
    │   └── photonEmitterLayer → PhotonEmitterNode (PNG + green sticky on button)
    ├── WindowFrameNode (blue frame)
    ├── QuadEmissionFrequencyControlPanel @ (15, 350)
    ├── MoleculeSelectionPanel @ (530, frame.top)
    ├── TimeControlNode (Normal/Slow + Play/Pause + Step)
    ├── Show Light Spectrum RectangularPushButton
    └── ResetAllButton radius 18
```

## Light emitter assets

| Wavelength | On | Off |
|---|---|---|
| Microwave | microwaveSource.png | (same — microwave has no off image toggle like others) |
| Infrared | infraredSource.png | infraredSourceOff.png |
| Visible | flashlight.png | flashlightOff.png |
| Ultraviolet | uvSource.png | uvSourceOff.png |

## Photon assets

`microwavePhoton.png` / `infraredPhoton.png` / `visiblePhoton.png` / `ultravioletPhoton.png`

## MVT

`createSinglePointScaleInvertedYMapping(ZERO → (275,150), scale 0.10)`

## Emitter

Width 125; placed at emission point (−1350,0) + offset (100,0) in model, then MVT.

## Status

Mapped. Flutter Main View implements this as a single screen.
