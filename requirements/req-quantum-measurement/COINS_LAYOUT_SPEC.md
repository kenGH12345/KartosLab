# COINS_LAYOUT_SPEC

> PHASE 2 · Sources: `CoinsScreenView.ts`, `CoinsExperimentSceneView.ts`, preparation/measurement areas, test boxes, `CoinSetPixelRepresentation.ts`

## 1. Source Evidence

| Claim | File | Confidence |
|---|---|---|
| Scene translate (0,75) | CoinsScreenView SCENE_POSITION | HIGH |
| Divider prep = floor(1024×0.38)=389 | CoinsExperimentSceneView | HIGH |
| Divider measure = ceil(1024×0.2)=205 | same | HIGH |
| Prep/measure centerX formulas | updateActivityAreaPositions | HIGH |
| Start button centerY=245 | empirically determined | HIGH (source) |
| Divider height 525 | ExperimentDividingLine | HIGH |
| Single box 165×145 | SingleCoinTestBox | HIGH |
| Multi box 200×200 | MultiCoinTestBox | HIGH |
| Pixel grid √10000=100 | CoinSetPixelRepresentation | HIGH |
| Classical vs Quantum = **two scene views**, visibility via activeProperty — **not** side-by-side panels | CoinsScreenView | HIGH |

## 2. Root Geometry

```
Screen: CoinsScreenView
layoutBounds: 1024×618
children z (back→front content): radio AlignBox, classicalScene, quantumScene
+ ResetAll from base
Scene local origin after SCENE_POSITION (0, 75)
```

## 3. Coordinate Systems

| System | Use |
|---|---|
| Layout | Radio AlignBox, ResetAll |
| Scene local | After translation (0,75); divider X in scene coords ≈ layout X |
| Local VBox/HBox | Prep & measurement columns |

**No physics MVT on Coins** — coins are pure view nodes / canvas.

## 4. Module Tree

```
CoinsScreenView
├── experimentModeRadioButtonGroup (AlignBox, top, horizontal center in [10..1014])
├── classicalCoinsExperimentSceneView  [visible iff CLASSICAL]
│   └── CoinsExperimentSceneView
│       ├── preparationArea (CoinExperimentPreparationArea VBox)
│       ├── measurementArea (CoinExperimentMeasurementArea VBox)
│       ├── ExperimentDividingLine
│       ├── startMeasurementButton (arrow)
│       └── newCoinButton
└── quantumCoinsExperimentSceneView    [visible iff QUANTUM]
    └── (same structure)
```

**Category:** radio=Functional; prep/measure=Structural; coin displays=Display; buttons=Functional; divider=Structural; traveling coins=Overlay/animation on scene root.

## 5–8. Module Geometry / Anchors / Constraints

| Module | Anchor / Rule | Size | Mode |
|---|---|---|---|
| Scene selector | AlignBox top: y=10; x from margin to maxX−margin | content-driven height | RELATIVE width / CONTENT height |
| Scene root | translation (0, 75) | — | FIXED offset |
| Divider X | Property animates 389↔205 | height 525 | DYNAMIC (mode) |
| Divider centerX | = dividerX | — | ANCHOR |
| Start Measurement | centerX=dividerX, centerY=245 | arrow 60×head | FIXED |
| Prep centerX | dividerX/2 | VBox content | CONSTRAINED |
| Measure centerX | dividerX+(1024−dividerX)/2 | VBox | CONSTRAINED |
| New Coin | centerX=prep.centerX, top=prep.bottom+10 | maxWidth 150 text | CONSTRAINED |
| Header maxWidth | prep 250 / measure 150 | scale down if needed | DYNAMIC |
| Single test box | 165×145, origin at box center | FIXED | FIXED |
| Multi test box | 200×200 | FIXED | FIXED |
| Experiment buttons | width 180, VBox spacing 10 | FIXED | FIXED |
| Multi HBox | spacing 30: box \| selector \| histogram \| buttons | CONTENT | RELATIVE |
| Section headers | maxWidth 400 | CONTENT | CONSTRAINED |

## 9. Dynamic Geometry

| Driver | Effect |
|---|---|
| preparingExperiment | Divider X animates 0.5s cubicOut; Start vs New Coin visibility |
| numberOfCoins 10/100 | Individual SmallCoinNode inside 200×200 clip |
| numberOfCoins 10000 | CoinSetPixelRepresentation canvas (100×100 px buffer → sideLengthInView square) |
| systemType | Background color; text colors; which scene visible |

**10000 rendering abstraction required:** Canvas / CustomPainter pixel buffer — **never 10000 Widgets**.

## 10. Responsive

Entire CoinsScreenView scales with ScreenView matrix. Internal ratios use design 1024 width. Do not reflow columns with Flex for phone unless later KartosLab policy — source is design-space scale.

## 11. Z-Order (scene)

```
preparationArea, measurementArea
dividingLine, startMeasurementButton, newCoinButton
traveling coin nodes: single → moveToBack; multi/pixel → moveToFront
```

## 12. Asset Geometry

| Asset | Intrinsic | Display | Anchor |
|---|---|---|---|
| classicalCoinHeads.svg / Tails.svg | SVG viewBox (source) | CoinNode radius (indicator 36, radio 16, small varies) | center |
| Quantum coin | programmatic | same radii | center |

Exact SVG viewBox: read file at asset copy time — mark **MEDIUM** until measured in Flutter.

## 13. Typography

| Role | Font constant |
|---|---|
| Scene selector | SCENE_SELECTOR_FONT bold 26 |
| Section headers | SceneSectionHeader → BOLD_HEADER ~20 |
| Controls | CONTROL_FONT 14 |
| Button set | CONTROL_FONT, width 180 |

Baseline: PhET Text vs Flutter Text — expect P2 baseline drift; align using center of button chrome not text alone.

## 14. Overlay

Start Measurement / New Coin are scene children (not modal). No tooltip overlay FOUND.

## 15. Animation Geometry

| Animation | Spec |
|---|---|
| Divider slide | duration 0.5s, Easing.CUBIC_OUT, property dividerX |
| Coin travel | from travelingCoinsOrigin (= prep indicator coin global center → local) into test boxes |
| Flip | SmallCoinNode / pixel flip animations (~MEASUREMENT_PREPARATION_TIME 1s) |

## 16. Unknowns

| Item | Status |
|---|---|
| Exact radio button group height (affects AlignBox) | CONTENT_DRIVEN — measure at runtime |
| CoinSetPixelRepresentation sideLengthInView numeric | passed from MultiCoinTestBox / MaxCoinsViewManager — verify when wiring (**MEDIUM**) |
| QCT Flutter layout vs this spec | QCT is **candidate component**, not layout truth |

## 17. Implementation Guidance

1. Two full scene instances; toggle visibility — do **not** one Column with Classical|Quantum side-by-side.  
2. Drive prep/measure with dividerX Property + centerX formulas.  
3. Spec class: `QmCoinsLayoutSpec`. Composer later applies only.
