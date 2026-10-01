# PHOTONS_LAYOUT_SPEC

> Sources: `PhotonsScreenView.ts`, `PhotonsExperimentSceneView.ts`, `PhotonTestingArea.ts`, `Laser.ts` / scene model distances

## 1. Source Evidence

| Claim | Evidence | Confidence |
|---|---|---|
| Radio centerX = layoutBounds.centerX, top = Y_MARGIN | PhotonsScreenView | HIGH |
| sceneTranslation = (0, radio.bottom+10) | PhotonsScreenView | HIGH |
| experimentArea.center = (420, 225) | PhotonsExperimentSceneView | HIGH |
| MVT scale 640, inverted Y, origin at node center | PhotonTestingArea | HIGH |
| Laser @ (−0.15,0) m, PBS @ 0, Mirror @ (0.11,0) | scene model | HIGH |
| Detectors positioned via TOTAL_PHOTON_PATH_LENGTH | scene model | HIGH |
| Two scenes Single/Many visibility DerivedProperty | PhotonsScreenView | HIGH |

## 2. Root Geometry

```
PhotonsScreenView (1024×618)
├── experimentModeRadioButtonGroup
├── singlePhotonExperimentSceneView  [translation Y = radio.bottom+10]
└── manyPhotonsExperimentSceneView   [same translation]
```

## 3. Coordinate Systems

| System | Definition |
|---|---|
| Layout | Radio / ResetAll |
| Scene local | After sceneTranslation |
| Experiment area local | Centered at (420,225) in scene |
| **Model meters** | PBS origin (0,0); +X right; +Y up in model |
| **View** | `x_v = 640 * x_m`, `y_v = -640 * y_m` relative to experiment area origin |

## 4. Module Tree

```
PhotonsExperimentSceneView
├── PhotonTestingArea (experiment)
│   ├── LaserNode
│   ├── photonBehaviorModeBox (Classical/Quantum) — left of laser, above
│   ├── PolarizingBeamSplitterNode
│   ├── MirrorNode
│   ├── PhotonDetectorNode ×2 (V top, H bottom)
│   └── PhotonSprites
├── PhotonDetectionProbabilityPanel (left)
├── ObliquePolarizationAngleIndicator
├── PhotonPolarizationAngleControl (bottom-left)
├── averagePolarization title+equations (right)
├── NormalizedOutcomeVectorGraph
├── AveragePolarizationCheckboxGroup
├── TimeControlNode (pause/step/speed)
└── (info dialog on demand)
```

## 5–8. Anchors / Constraints

| Module | Rule | Mode |
|---|---|---|
| Radio | centerX=512, top=10 | FIXED |
| Scene Y | radio.bottom+10 | CONTENT_DRIVEN |
| Experiment area | center (420,225) scene-local | FIXED (empirical in source) |
| Probability panel | centerX=(10+experiment.left)/2, top=20 | CONSTRAINED |
| Polarization indicator | centerX=probability.centerX, y=experiment.y | CONSTRAINED |
| Angle control | left=10, bottom=layoutH−sceneTy−10 | CONSTRAINED |
| Avg polarization box | right=layoutW−10, top=0 (scene) | CONSTRAINED |
| Behavior radios | left=laser.left, bottom=laser.top−15 | CONSTRAINED |

## 9. Dynamic Geometry

| Driver | Geometry effect |
|---|---|
| Single vs Many | Swap scene visibility; same experimentArea center |
| Photon motion | Sprites follow model positions via MVT |
| Polarization | Indicator angles; not panel position |

## 10. Responsive

Uniform ScreenView scale. Experiment center (420,225) stays in design space.

## 11. Z-Order (testing area)

```
apparatus nodes (laser, PBS, mirror, detectors)
PhotonSprites (typically front for visibility)
behavior control box
```

Exact child order: PhotonTestingArea children array — Composer must match source order.

## 12. Asset Geometry

| Asset | Use | Notes |
|---|---|---|
| greenPhoton.png | PhotonSprites / screen icon | SpriteImage; scale inside PhotonSprites — measure intrinsic at copy (**HIGH** path, **MEDIUM** display scale until read) |

## 13. Typography

CONTROL_FONT / BOLD_TITLE_FONT / BOLD_HEADER_FONT per QuantumMeasurementConstants.

## 14. Overlay

`AveragePolarizationInfoDialog` — dialog overlay. ResetAll global.

## 15. Animation Geometry — PHOTON_TRAJECTORY_SPEC

### Emit

- Laser position model: `(-0.15, 0)` + beam width jitter ±`PHOTON_BEAM_WIDTH/2` (0.04 m)
- Direction: Photon.RIGHT = +X

### Intermediate

- Hit PBS polarizing surface (diagonal line through PBS size 0.07×0.07 centered at origin)
- Classical: reflect UP or transmit RIGHT
- Quantum: SPLIT both paths with opacities

### Mirror

- Center `(0.11, 0)`; reflects transmitted photons downward toward H detector

### Detect

- Vertical detector: `(0, TOTAL_PHOTON_PATH_LENGTH - 0.15)` ≈ `(0, 0.20)`
- Horizontal detector: `(0.11, -(0.35 - 0.15 - 0.11))` ≈ `(0.11, -0.09)`

### Time-independent geometry

Path lengths equalized so after measurement one full-opacity photon enters a detector (model.md).

### View mapping

```
viewPoint = experimentAreaOrigin + (640 * mx, -640 * my)
```

where experimentAreaOrigin is the ScreenView position of PhotonTestingArea's local (0,0) (= its center, since MVT maps model 0→ local 0 and node is centered at 420,225).

## 16. Unknowns

| Item | Status |
|---|---|
| Exact radio height → scene Y | runtime CONTENT_DRIVEN |
| PhotonSprites sprite pixel size | MEDIUM — read PhotonSprites.ts when implementing |
| TimeControlNode exact position | MEDIUM — continue in PhotonsExperimentSceneView remainder |

## 17. Implementation Guidance

Keep **PhotonTestingArea** as one Composer region with MVT. Do not place laser/PBS with absolute Flutter offsets unrelated to meters×640.
