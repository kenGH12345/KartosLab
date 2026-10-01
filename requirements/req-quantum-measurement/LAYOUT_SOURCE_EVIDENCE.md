# LAYOUT_SOURCE_EVIDENCE

| Screen | Module | Source File | Class / Symbol | Constant / Expression | Layout Rule | Confidence |
|---|---|---|---|---|---|---|
| Global | Design canvas | joist ScreenView.ts | DEFAULT_LAYOUT_BOUNDS | Bounds2(0,0,1024,618) | Root layout | HIGH |
| Global | Margins | QuantumMeasurementConstants.ts | SCREEN_VIEW_*_MARGIN | 10 | Content inset | HIGH |
| Global | Scale | ScreenView.getLayoutScale | min(w/1024,h/618) | Uniform + center | HIGH |
| Global | ResetAll | QuantumMeasurementScreenView.ts | right/bottom − margin | Bottom-right | HIGH |
| Global | Divider height | ExperimentDividingLine.ts | DIVIDER_HEIGHT=525 | Dashed vertical | HIGH |
| Coins | Scene offset | CoinsScreenView.ts | SCENE_POSITION=(0,75) | Translate scenes | HIGH |
| Coins | Divider prep/measure | CoinsExperimentSceneView.ts | floor(0.38W)/ceil(0.2W) | 389 / 205 | HIGH |
| Coins | Area centers | updateActivityAreaPositions | divider/2 ; divider+(W−d)/2 | Horizontal split | HIGH |
| Coins | Start btn | CoinsExperimentSceneView.ts | centerY=245 | On divider | HIGH |
| Coins | Single box | SingleCoinTestBox.ts | 165×145 | FIXED | HIGH |
| Coins | Multi box | MultiCoinTestBox.ts | 200×200 | FIXED | HIGH |
| Coins | 10k pixels | CoinSetPixelRepresentation.ts | SIDE_LENGTH=√10000 | Canvas | HIGH |
| Coins | Indicator radius | InitialCoinStateSelectorNode.ts | 36 | Coin size | HIGH |
| Photons | Radio | PhotonsScreenView.ts | centerX, top margin | Top toggle | HIGH |
| Photons | Scene Y | PhotonsScreenView.ts | radio.bottom+10 | CONTENT_DRIVEN | HIGH |
| Photons | Experiment center | PhotonsExperimentSceneView.ts | (420,225) | FIXED empirical | HIGH |
| Photons | MVT | PhotonTestingArea.ts | scale 640 inv-Y | Physics→view | HIGH |
| Photons | Path lengths | PhotonsExperimentSceneModel.ts | 0.15 / 0.11 / +0.09 | Trajectory | HIGH |
| Spin | Divider | SpinScreenView.ts | x=300, top=70 | Split | HIGH |
| Spin | Measure left | SpinScreenView.ts | left=300 | | HIGH |
| Spin | MVT | SpinMeasurementArea.ts | scale 180 | | HIGH |
| Spin | SG positions | SpinModel.ts | (0.8,0)(2,±0.3) | Apparatus | HIGH |
| Bloch | Divider | BlochSphereScreenView.ts | x=350, top=70 | | HIGH |
| Bloch | Prep center | BlochSphereScreenView.ts | mid left column | | HIGH |
| Bloch | Measure left | BlochSphereScreenView.ts | 350+40 | | HIGH |
| Bloch | Sphere R | BlochSphereNode.ts | 100 | | HIGH |
| Bloch | Prep scale | BlochSpherePreparationArea.ts | 0.9 | | HIGH |
| Coins | SVG viewBox | images/*.svg | — | Intrinsic size | MEDIUM |
| Photons | Sprite scale | PhotonSprites.ts | — | Display size | MEDIUM |
| Bloch | MeasurementArea root | BlochSphereScreenView.ts | left=390 top=10 | Area placement | HIGH |
| Bloch | MeasurementArea relations | BlochSphereMeasurementArea.ts | sphere.top=eq.bottom+35; controls.left=sphere.right+60 | Observe/Erase column | HIGH (CONTENT_DRIVEN) |
| Bloch | Observe absolute XY | BlochSphereMeasurementArea.ts | VBox content | Pixel XY | SOURCE-DERIVED LIMITATION |
| Spin | Prep column width | SpinStatePreparationArea | content-driven | Exact width | MEDIUM |
| All | Font baseline Flutter vs PhetFont | — | — | P2 risk | LOW→P2 |

**UNKNOWN remaining:** none blocking Spec completeness for Composer start; MEDIUM items listed for implementation kickoff.
