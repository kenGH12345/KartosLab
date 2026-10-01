# SPIN_LAYOUT_SPEC

> Sources: `SpinScreenView.ts`, `SpinMeasurementArea.ts`, `SpinStatePreparationArea.ts`, `SternGerlach.ts`, `SpinExperiment.ts`

## 1. Source Evidence

| Claim | Evidence | Confidence |
|---|---|---|
| Divider X=300, top=70 | SpinScreenView | HIGH |
| measurementArea.left=300 | SpinScreenView | HIGH |
| Prep uses full LAYOUT_BOUNDS for VBox | SpinStatePreparationArea | HIGH |
| MVT scale 180 inverted Y | SpinMeasurementArea | HIGH |
| SG positions (0.8,0), (2,0.3), (2,−0.3) | SpinModel | HIGH |
| Source (−0.5, 0) | SpinModel | HIGH |
| Exp 1–6 apparatus via visibility/orientation, **shared node set** | SpinMeasurementArea + SpinModel | HIGH |

## 2. Root Geometry

```
SpinScreenView
├── SpinStatePreparationArea  (left of divider)
├── ExperimentDividingLine (x=300, top=70, height=525)
├── SpinMeasurementArea (left=300)
└── ResetAllButton
```

**Primary layout direction:** horizontal split prep | measure.

## 3. Coordinate Systems

| System | Definition |
|---|---|
| Layout | Divider, ResetAll, prep VBox |
| Measurement local | Origin at measurementArea origin; MVT maps model→view |
| Model | SG / particle source positions as in SpinModel |

```
view = (180 * mx, -180 * my)  // relative to MVT origin inside measurement area
```

## 4. Module Tree

```
SpinStatePreparationArea (VBox)
├── title / equations α|↑⟩+β|↓⟩
├── BlochSphereWithProjectionNode (scale 0.9)
├── spinStateRadioButtonGroup (+Z/+X/−Z) OR probability sliders (Custom)
└── expected % checkbox (as applicable)

SpinMeasurementArea (VBox)
├── experimentComboBox (Exp 1–6 + Custom)
├── apparatus layer
│   ├── ParticleSourceNode
│   ├── SternGerlachNode ×3
│   ├── MeasurementDeviceNode ×3
│   ├── histograms (continuous)
│   ├── ParticleSprites / ManyParticlesCanvasNode
│   └── exit blocker visual
└── source mode Single/Continuous controls (on ParticleSourceNode)
```

## 5–8. Anchors

| Module | Rule | Mode |
|---|---|---|
| Divider | centerX=300, top=70 | FIXED |
| Prep | left column; width constrained by divider | CONSTRAINED |
| Measurement | left=300; fills right | CONSTRAINED |
| ComboBox | top of measurement VBox | CONTENT |
| SG0/1/2 | model positions → MVT | FIXED model / FIXED transform |
| Histograms | center at modelToView(sg.x, 1.1), scale 0.8 | CONSTRAINED |
| Prep Bloch | scale 0.9 | FIXED scale |

## 9. Dynamic Geometry

| Driver | Effect |
|---|---|
| Experiment 1–6 / Custom | SG orientation + visibility of SG1/SG2 + MD visibility (see implementation-notes table) — **same nodes**, not 7 separate layouts |
| SourceMode Single | sprites + MD cameras; Continuous: canvas particles + histograms |
| BlockingMode | blocker at top or bottom exit of SG0 (+ BLOCKER_OFFSET) |

**Do not create seven independent layout trees.** Share primitives; toggle visibility/orientation per `SpinExperiment.experimentSetting`.

### Experiment apparatus config (model → view visibility)

| Exp | SG chain | usingSingleApparatus |
|---|---|---|
| 1 | SGz | true |
| 2 | SGx | true |
| 3 | SGz,SGx,SGx | false |
| 4 | SGz,SGz,SGz | false |
| 5 | SGx,SGz,SGz | false |
| 6 | SGx,SGx,SGx | false |
| Custom | default SGx,SGz,SGz | false |

Continuous + multi: SG0+H histograms; blocker modes apply.

## 10. Responsive

Uniform scale of whole ScreenView.

## 11. Z-Order

```
apparatus bodies
particle canvas/sprites (front for visibility)
measurement devices
combo / controls
```

Match SpinMeasurementArea child construction order.

## 12. Asset Geometry

| Asset | Use |
|---|---|
| spinScreenIcon.png | Screen/Home icon only |
| CAMERA_SOLID_SHAPE_SVG | MeasurementDeviceNode path — programmatic |

Particles: ShadedSphereNode / canvas — programmatic.

## 13. Typography

TITLE_FONT combo items; BOLD_HEADER for prep titles; RichText for kets.

## 14. Overlay

ComboBox list is scenery popup (parentNode = screen). Treat as overlay parent = ScreenView.

## 15. Animation Geometry

Particle paths: stage 0→1→2 along entrance/exit positions of SGs (model). Continuous: ManyParticlesCanvasNode bounds = apparatus region.

## 16. Unknowns

| Item | Status |
|---|---|
| Exact prep VBox left/width numeric | MEDIUM — derived from content + divider; measure Align when implementing |
| MeasurementDevice local icon size | MEDIUM |

## 17. Implementation Guidance

`QmSpinLayoutSpec` + MVT. Experiment differences = **state-driven visibility**, not separate Composers per experiment number.
