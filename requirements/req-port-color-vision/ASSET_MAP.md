# Color Vision — ASSET_MAP

> **req-id**: `req-port-color-vision`  
> **Policy**: `VISUAL_ASSET_POLICY` / rule `85-phet-original-assets`  
> **Target**: Substituted Assets = **0**

All runtime images are original PhET PNGs from `color-vision/images/`, copied to:

`assets/simulations/color_vision/images/`

Declared via `CvAssets` (`lib/color_vision/cv_assets.dart`).

| Original Path (PhET) | Intrinsic | Flutter Path | Scale | Rotation | Used By |
|---|---|---|---|---|---|
| `images/flashlight0Deg.png` | 173×67 | `assets/simulations/color_vision/images/flashlight0Deg.png` | 0.85 (Single) / 0.73 (RGB green) | 0 | `SingleBulbScreenView` flashlight; `RgbScreenView` green flashlight |
| `images/flashlightNeg45Deg.png` | 177×131 | `assets/simulations/color_vision/images/flashlightNeg45Deg.png` | 0.73 | 0 (baked −45°) | `RgbScreenView` red flashlight |
| `images/flashlightPos45Deg.png` | 178×129 | `assets/simulations/color_vision/images/flashlightPos45Deg.png` | 0.73 | 0 (baked +45°) | `RgbScreenView` blue flashlight |
| `images/filterLeft.png` | 74×194 | `assets/simulations/color_vision/images/filterLeft.png` | 0.7 | 0 | `SingleBulbScreenView` filter left shell |
| `images/filterRight.png` | 74×194 | `assets/simulations/color_vision/images/filterRight.png` | 0.7 | 0 | `SingleBulbScreenView` filter right shell |
| `images/head.png` | 300×434 | `assets/simulations/color_vision/images/head.png` | 0.96 | 0 | Exterior head back (`HeadMode.noBrain`) |
| `images/headFront.png` | 300×434 | `assets/simulations/color_vision/images/headFront.png` | 0.96 | 0 | Exterior head front (nose cutout) |
| `images/silhouette.png` | 296×427 | `assets/simulations/color_vision/images/silhouette.png` | 0.96 | 0 | Interior head back (`HeadMode.brain`) |
| `images/silhouetteFront.png` | 296×427 | `assets/simulations/color_vision/images/silhouetteFront.png` | 0.96 | 0 | Interior head front |
| `images/headIcon.png` | 44×63 | `assets/simulations/color_vision/images/headIcon.png` | 0.6 | 0 | Exterior / Interior radio |
| `images/silhouetteIcon.png` | 42×62 | `assets/simulations/color_vision/images/silhouetteIcon.png` | 0.6 | 0 | Exterior / Interior radio |
| `images/beamViewIcon.png` | 43×43 | `assets/simulations/color_vision/images/beamViewIcon.png` | 0.74 | 0 | Beam / Photons radio |
| `images/photonViewIcon.png` | 43×43 | `assets/simulations/color_vision/images/photonViewIcon.png` | 0.74 | 0 | Beam / Photons radio |
| `images/whiteLightIcon.png` | 43×43 | `assets/simulations/color_vision/images/whiteLightIcon.png` | 0.74 | 0 | White / Monochromatic radio; tab icon |
| `images/singleColorLightIcon.png` | 43×43 | `assets/simulations/color_vision/images/singleColorLightIcon.png` | 0.74 | 0 | White / Monochromatic radio; Single Bulb tab |
| `images/flashlightIcon.png` | — | `assets/simulations/color_vision/images/flashlightIcon.png` | tab ~22px | 0 | RGB Bulbs tab icon |

## Non-image / painted (not substituted assets)

| Element | Source | Flutter |
|---|---|---|
| Thought bubbles | `PerceivedColorNode.js` ellipses | `CvThoughtBubbles` CustomPainter |
| Solid beam | `SolidBeamNode.js` | `SolidBeamPainter` |
| Photons 3×2 | `*PhotonBeamNode.js` | `PhotonCanvasPainter` |
| Spectrum / Gaussian tracks | scenery-phet + `GaussianWavelengthSlider.js` | `CvSpectrumSlider` / `CvGaussianSlider` |
| Filter colored fill | `FilterHalfEllipse.js` | `_FilterHalfEllipsePainter` |
| Reset All | scenery-phet `ResetAllButton` r=18 | `KratosResetAllButton(radius: 18)` |
| Play/Pause + Step | `TimeControlNode` (no speed radios) | `CvTimeControls` |

## Crop / Opacity / Transform notes

- No crop of PNG transparent padding; `BoxFit.fill` within scaled intrinsic size.
- Filter half-ellipses are dynamic fills (not assets) layered with left/right PNGs.
- RGB beam rotations ±π/6 applied to photon canvases only (flashlight art is pre-rotated).
- Slider border stroke `#c0b9b9` matches `ColorVisionConstants.SLIDER_BORDER_STROKE`.

## Substituted Assets

**0** — all chrome icons and scene images are original PhET PNGs via `Image.asset` / `CvAssets`.
