# LAYOUT_SPEC — Quantum Wave Interference (PhET → Flutter)

> **Clear-columns fit (2026-09-28, user choice 2):** PhET ideal
> `160 + 204 + 376` exceeds layoutBounds width 768, so source formulas produce
> ~30px L/M/R overlap. Flutter Spec keeps the same anchors / +8 chains, but
> **uniformly scales** front-facing slit + detector (`frontFacingScale < 1` on
> **width and height**, preserving PhET 204×155 / 376×155 aspect) so columns
> stay separated by ≥ `S_STACK` (8px). Physics / local detector coordinates are
> unchanged — only page placement sizes scale.
>
> **Golden note:** Experiment goldens regenerated for clear-columns geometry.  
> **Primary screen:** Experiment（`ExperimentScreenView`）→ `ExperimentLayoutSpec` / `ExperimentLayoutComposer`  
> **Secondary screens:** High Intensity / Single Particles — dedicated Specs（见 §18 + 独立文档）  
> **Evidence priority:** TypeScript source + Scenery layout formulas ≫ screenshot measurement  
> **Edit rule:** 改布局优先改 Spec / constraint / Composer；禁止回退 page-level magic `Positioned`

---

## 1. Design Canvas

| Field | Value | Evidence |
|---|---|---|
| `layoutBounds` | **768 × 504** | Joist `ScreenView` default; QWI constants `SCENE_BUTTON_GROUP_CENTER_Y=470`, `SOURCE_CONTROL_PANEL_TOP=178` only make sense on H=504; Flutter `QwiLayout` / `RENDERING_MAP.md` already lock 768×504 |
| Origin | `(0,0)` top-left | Scenery / Joist convention |
| Aspect ratio | **1.5238** (`768/504`) | Derived |
| X margin | **15** | `QuantumWaveInterferenceConstants.SCREEN_VIEW_X_MARGIN` |
| Y margin | **15** | `QuantumWaveInterferenceConstants.SCREEN_VIEW_Y_MARGIN` |
| `visibleBounds` | Runtime viewport (may exceed / letterbox around layoutBounds) | Joist `visibleBoundsProperty`; Experiment ruler uses it for drag clamps |
| Content / play area | Entire `layoutBounds` | No separate chrome inside ScreenView (Home tab chrome is Flutter-only) |

### DESIGN_CANVAS

```text
width:  768
height: 504
aspect: 1.5238095238
xMargin: 15
yMargin: 15
```

### Normalized helpers

```text
xRatio = x / 768
yRatio = y / 504
wRatio = w / 768
hRatio = h / 504
```

---

## 2. Layout Philosophy (from source)

Experiment is **not** a freeform absolute map of widgets. It is a **constraint + column** system:

| Mechanism | Role |
|---|---|
| Fixed constants (`ExperimentConstants`) | Front-facing row Y/H/W, overhead scale |
| Right-anchored detector column | `detectorScreen.x = layoutBounds.maxX − margin − localMaxX` |
| Content-sized left column | `SourceControlPanel` + scene radios; emitter follows `centerX` |
| Centered middle column | `middleCenterX = (leftColumnRight + detectorLeft)/2 − 3` |
| Vertical chain (+8) | Detector → ScreenControls → Graph |
| Bottom row shared baseline | Ruler / Time / Eraser / Reset share `centerY` with Reset |
| ManualConstraint | SlitControlPanel **bottom** tied to tool-row geometry |

**Priority for Flutter recomposition:**

```text
Layout Formula  >  Normalized Ratio  >  Absolute Pixel
```

---

## 3. Layout Tree (Experiment)

```text
ROOT (ExperimentScreenView, layoutBounds 768×504)
│
├── OVERHEAD_APPARATUS                          [DISPLAY]
│   ├── OVERHEAD_EMITTER                        [DISPLAY + FUNCTIONAL emit]
│   ├── OVERHEAD_BEAM                           [DISPLAY]
│   ├── OVERHEAD_DOUBLE_SLIT                    [DISPLAY]
│   ├── OVERHEAD_DETECTOR                       [DISPLAY]
│   ├── OVERHEAD_VISIBLE_REGION (zoom white)    [DISPLAY]
│   └── OVERHEAD_DISTANCE_SPAN (“0.60 m”)       [DISPLAY]
│
├── LEFT_COLUMN
│   ├── SOURCE_CONTROL_PANEL                    [FUNCTIONAL + STRUCTURAL]
│   │   ├── WAVELENGTH_OR_SPEED_CONTROL
│   │   └── SOURCE_INTENSITY_CONTROL
│   └── SCENE_RADIO_BUTTON_GROUP (2×2)          [FUNCTIONAL]
│
├── MIDDLE_COLUMN (ExperimentSlitColumnNode)
│   ├── FRONT_FACING_SLIT_VIEW                  [DISPLAY]
│   │   ├── SLIT_WIDTH_SPAN
│   │   ├── SLIT_SEPARATION_SPAN
│   │   └── WHICH_PATH_DETECTOR_OVERLAYS
│   └── SLIT_CONTROL_PANEL                      [FUNCTIONAL + STRUCTURAL]
│       ├── SLIT_SEPARATION_CONTROL
│       ├── SCREEN_DISTANCE_CONTROL
│       └── SLIT_CONFIGURATION_COMBO
│
├── RIGHT_COLUMN (ExperimentDetectorColumnNode)
│   ├── FRONT_FACING_DETECTOR                   [DISPLAY + FUNCTIONAL zoom/snapshot]
│   │   ├── DETECTOR_CANVAS (intensity/hits)
│   │   ├── DETECTOR_SCALE_INDICATOR (“5 mm”)
│   │   ├── DETECTOR_ZOOM_±
│   │   └── SNAPSHOT_BUTTON_COLUMN
│   ├── SCREEN_CONTROLS_PANEL                   [FUNCTIONAL]
│   │   ├── DETECTION_MODE_RADIOS (Intensity/Hits)
│   │   └── SCREEN_BRIGHTNESS
│   └── GRAPH_ACCORDION                         [DISPLAY + FUNCTIONAL Y-zoom]
│       ├── TITLE_BAR
│       ├── CHART (W=376, H=103)
│       └── GRAPH_ZOOM_±
│
├── BOTTOM_TOOL_ROW                             [FUNCTIONAL]
│   ├── RULER_CHECKBOX
│   ├── TIME_CONTROL_NODE (hits only)
│   ├── ERASER_BUTTON (hits only)
│   └── RESET_ALL_BUTTON
│
└── OVERLAY
    ├── DETECTOR_RULER (draggable)              [OVERLAY]
    ├── SNAPSHOTS_DIALOG                        [OVERLAY]
    └── A11Y_DESCRIPTION_LAYER                  [OVERLAY]
```

---

## 4. Root Regions (large areas)

Absolute Y bands from constants (X is column-driven):

| ID | Type | Y range (approx) | yRatio | hRatio | Notes |
|---|---|---|---|---|---|
| `OVERHEAD_BAND` | DISPLAY | `0 … 180` | 0.000–0.357 | ~0.357 | Above front-facing row; distance label lives here |
| `FRONT_FACING_ROW` | DISPLAY | `180 … 335` | 0.357–0.665 | 0.308 | Slit view + detector + source panel top |
| `BELOW_ROW_CONTROLS` | MIXED | `343 … ~bottom tools` | 0.681–… | — | +8 under row; slit panel + screen controls + graph |
| `BOTTOM_TOOL_ROW` | FUNCTIONAL | ~`centerY = Reset.centerY` | — | FIXED chrome | Margin 15 from bottom |

Constants:

```text
FRONT_FACING_ROW_TOP    = 160   (Flutter: raised from PhET 180 for tighter overhead gap)
FRONT_FACING_ROW_HEIGHT = 155   (hRatio 0.3075; clear-columns may scale)
FRONT_FACING_CONTROLS_TOP = 180 + 155 + 8 = 343  (yRatio 0.6806)
SOURCE_CONTROL_PANEL_TOP = 178  (≈ row top)
SCENE_BUTTON_GROUP_CENTER_Y = 470 (yRatio 0.9325)
```

---

## 5. Module Catalog

### 5.1 Functional

| ID | Source | Interaction |
|---|---|---|
| `SOURCE_CONTROL_PANEL` | `SourceControlPanel` | λ / speed, intensity |
| `SCENE_RADIO_BUTTON_GROUP` | `SceneRadioButtonGroup` | photons/electrons/neutrons/helium |
| `SLIT_CONTROL_PANEL` | `SlitControlPanel` | separation, distance, configuration |
| `DETECTION_MODE_RADIOS` | `ScreenControlsPanel` | intensity ↔ hits |
| `SCREEN_BRIGHTNESS` | `ScreenControlsPanel` | brightness % |
| `DETECTOR_ZOOM_±` | `PlusMinusZoomButtonGroup` | horizontal detector scale index |
| `GRAPH_ZOOM_±` | graph `PlusMinusZoomButtonGroup` | Y zoom only |
| `GRAPH_EXPAND` | `AccordionBox` | expand/collapse |
| `SNAPSHOT_TAKE` / `SNAPSHOT_VIEW` | Snapshot buttons | capture / dialog |
| `RULER_CHECKBOX` | `RulerCheckbox` | show ruler |
| `TIME_CONTROL_NODE` | `TimeControlNode` | play / NORMAL·FAST (hits) |
| `ERASER_BUTTON` | `EraserButton` | clear hits |
| `RESET_ALL` | `ResetAllButton` | full reset |
| `OVERHEAD_EMIT` | emitter button | toggle emitting |

### 5.2 Display

| ID | Source | Content |
|---|---|---|
| `OVERHEAD_*` | Overhead apparatus nodes | Perspective schematic |
| `FRONT_FACING_SLIT_VIEW` | `FrontFacingSlitNode` | 204×155 black plate + slits |
| `FRONT_FACING_DETECTOR` | `FrontFacingDetectorScreenNode` | 376×155 intensity/hits |
| `DETECTOR_SCALE_INDICATOR` | `DetectorScreenScaleIndicatorNode` | “5 mm” at local Y≈−10 |
| `GRAPH_CHART` | `GraphAccordionBox` chart | 376×103 |
| `DETECTOR_RULER` | `DetectorRulerNode` | overlay ruler calibrated to visible mm |

### 5.3 Structural

| ID | Source |
|---|---|
| `SOURCE_CONTROL_PANEL` shell | `Panel` (minWidth 160, xMargin 10, yMargin 10) |
| `SLIT_CONTROL_PANEL` shell | `Panel` preferredWidth = 204+20 = **224** |
| `SCREEN_CONTROLS_PANEL` | Panel fill/stroke **null** (no chrome box) |
| `GRAPH_ACCORDION` shell | `AccordionBox` cornerRadius 5 |

### 5.4 Overlay

| ID | Notes |
|---|---|
| `DETECTOR_RULER` | Drag bounds depend on detector + graph expanded |
| `SNAPSHOTS_DIALOG` | Shared across scenes |
| `SNAPSHOT_FLASH` | Transient white flash on detector / overhead |

---

## 6. Primary Layout Formulas (Experiment)

### 6.1 Right column (anchor: top-right of layoutBounds)

```text
controlsRight = layoutBounds.maxX − SCREEN_VIEW_X_MARGIN
              = 768 − 15 = 753

detectorLocalMaxX ≈ DETECTOR_SCREEN_WIDTH + BUTTON_COLUMN_GAP + snapshotColumnWidth
                  ≈ 376 + 6 + ~36…40

detectorScreen.x = controlsRight − detectorLocalMaxX
detectorScreen.y = FRONT_FACING_ROW_TOP = 180
detectorScreen.w = 376
detectorScreen.h = 155

screenControls.centerX = detectorScreen.x + 376/2
screenControls.top     = detectorScreen.bottom + 8
// ScreenControlsPanel is CONTENT_DRIVEN (fill/stroke null) — NOT stretched to 376.
// Flutter must center the intrinsic row; left-aligning a full-width Row caused
// Intensity/Hits to paint over SlitControlPanel.

graph.chartCenterX aligned to detector centerX
graph.top = screenControls.bottom + 8   (or detector.bottom + 8 if panel hidden)
```

### 6.2 Left column (anchor: content-driven left, top fixed)

```text
sourceControlPanel.top = SOURCE_CONTROL_PANEL_TOP = 178
sourceControlPanel.left = activeOverheadEmitter.left   // content-linked
emitter.centerX = sourceControlPanel.centerX           // bidirectional align

sceneRadioButtonGroup.centerX = sourceControlPanel.centerX
sceneRadioButtonGroup.centerY = SCENE_BUTTON_GROUP_CENTER_Y = 470
```

### 6.3 Middle column (anchor: horizontal center between L/R)

```text
leftColumnRight  = max(sourceControlPanel.right, sceneRadioButtonGroup.right)
rightColumnLeft  = detectorScreen.left
middleCenterX    = (leftColumnRight + rightColumnLeft) / 2 − MIDDLE_COLUMN_LEFT_SHIFT
                 // MIDDLE_COLUMN_LEFT_SHIFT = 3

frontFacingSlit.y = FRONT_FACING_ROW_TOP
frontFacingSlit.setViewCenterX(middleCenterX)
slitControlPanel.centerX = middleCenterX
slitControlPanel.top = frontFacingSlit.bottom + 8

// Widths are FIXED (not clamped to the L/R gap):
//   FrontFacingSlitNode VIEW_WIDTH = 204
//   SlitControlPanel minWidth = maxWidth = 204 + 20 = 224
// A previous Flutter squeeze to ~140px was incorrect and truncated NumberControl titles.

// Bottom stretch via ManualConstraint (not a free pixel):
slitControlPanel.bottom =
  resetAll.centerY + rulerCheckbox.height + TOOL_CHECKBOX_SPACING/2
  + SLIT_CONTROL_PANEL_BOTTOM_MARGIN
```

### 6.4 Bottom tool row (anchor: bottom-right + shared centerY)

```text
resetAll.right  = layoutBounds.maxX − 15
resetAll.bottom = layoutBounds.maxY − 15

rulerCheckbox.left = graphAccordion.left          // bottomControlsLeft
rulerCheckbox.centerY = resetAll.centerY

eraser.right = resetAll.left − BOTTOM_CONTROLS_SPACING   // 15
eraser.centerY = resetAll.centerY

timeControl.centerX = graphAccordion.centerX
timeControl.centerY = resetAll.centerY
```

### 6.5 Critical spacing constants

| Token | px | Where |
|---|---|---|
| `S_MARGIN` | 15 | Root inset X/Y; bottom controls spacing |
| `S_STACK` | 8 | Detector→controls→graph; slit→slitPanel |
| `S_TOOL_CHECKBOX` | 6 | ManualConstraint tool-row geometry |
| `S_SLIT_PANEL_BOTTOM` | 2 | Extra under tool geometry |
| `S_PANEL_CONTENT` | 20 | SlitControlPanel VBox spacing |
| `S_SETTINGS_ROW` | 40 | ScreenControls HBox radios↔brightness |
| `S_SNAPSHOT_GAP` | 6 | Detector → snapshot column |
| `S_ZOOM_INSET` | 6 | Detector ± margin inside screen |
| `SPAN_ARROW_Y` | −10 | Scale indicator above detector (local) |

---

## 7. Root Module Bounds Table (formula-derived)

Canvas W=768 H=504. Detector X depends on snapshot local bounds (~331 typical).

| ID | Type | Parent | X | Y | W | H | X% | Y% | W% | H% | Anchor |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `OVERHEAD_BAND` | DISPLAY | ROOT | 0 | 0 | 768 | 180 | 0 | 0 | 1 | 0.357 | topStretch |
| `FRONT_FACING_ROW` | DISPLAY | ROOT | col-driven | 180 | — | 155 | — | 0.357 | — | 0.308 | top |
| `SOURCE_CONTROL_PANEL` | FUNC+STRUCT | ROOT | emitter-linked | 178 | ≥160 | content | — | 0.353 | ≥0.208 | content | topLeft→content |
| `FRONT_FACING_SLIT_VIEW` | DISPLAY | MIDDLE | center−102 | 180 | 204 | 155 | — | 0.357 | 0.266 | 0.308 | topCenter (column) |
| `FRONT_FACING_DETECTOR` | DISPLAY | RIGHT | ~331 | 180 | 376 | 155 | ~0.431 | 0.357 | 0.490 | 0.308 | topRight (via maxX) |
| `SCREEN_CONTROLS` | FUNC | RIGHT | center on det | 343 | content | content | — | 0.681 | — | — | topCenter |
| `GRAPH_ACCORDION` | DISPLAY+FUNC | RIGHT | chart-aligned | controls.bottom+8 | ~chart+chrome | title+(0\|103) | — | — | — | — | top / chartCenterX |
| `SCENE_RADIOS` | FUNC | ROOT | =source.centerX | centerY 470 | content | content | — | 0.933 | — | — | center |
| `RESET_ALL` | FUNC | ROOT | right−15 | bottom−15 | FIXED | FIXED | — | — | FIXED | FIXED | bottomRight |
| `RULER_CHECKBOX` | FUNC | ROOT | =graph.left | =reset.centerY | content | content | — | — | — | — | left + centerY |

> Cells marked “content” / “—” are **CONTENT_DRIVEN** or **constraint-driven**, not free ratios.

---

## 8. Display Coordinate Systems (physics vs layout)

### 8.1 Layout coordinate

```text
ScreenView local = layoutBounds pixels (768×504)
Panels / buttons / accordion / tabs (Flutter Home) = LAYOUT
```

### 8.2 Experiment detector display coordinate

```text
FRONT_FACING_DETECTOR local:
  x ∈ [0, 376]
  y ∈ [0, 155]

Physical visible window:
  half-width from DetectorScreenScale options (±20/15/10/5 mm)
  mapped linearly onto detector local X

Hits / intensity samples:
  model x ∈ [-1, 1] relative to visible half-width  →  detector local X
  model y ∈ [-1, 1]  →  detector local Y (top = −1)
```

**Must not** move detector physics when moving the panel on the page.

### 8.3 Front-facing slit display coordinate

```text
VIEW_WIDTH  = 204
VIEW_HEIGHT = 155
HORIZONTAL_PADDING = 10
Slit rectangles placed in view-local coords from physical slitSeparation / slitWidth
```

### 8.4 HI / SP wave region (reference)

```text
WAVE_REGION_WIDTH  = 420
WAVE_REGION_HEIGHT = 385
DETECTOR_SCREEN_WIDTH (skewed) = 66
```

Separate from Experiment front-facing detector.

### 8.5 Graph display coordinate

```text
CHART_WIDTH  = DETECTOR_SCREEN_WIDTH = 376  (matches detector)
CHART_HEIGHT = 103
CHART_Y_AXIS_GUTTER = 24
X range mirrors detector visible half-width
Y range from graph zoom level (independent of detector zoom)
```

---

## 9. Fixed vs Relative vs Dynamic

| Item | Class |
|---|---|
| layoutBounds 768×504 | FIXED design canvas |
| SCREEN_VIEW margins 15 | FIXED |
| FRONT_FACING_ROW_TOP/HEIGHT | FIXED |
| DETECTOR_SCREEN_WIDTH 376 / SLIT 204 | FIXED |
| GRAPH CHART 376×103 | FIXED |
| Stack gap 8 | FIXED |
| Source panel width | CONTENT_DRIVEN (minWidth 160) |
| Middle column centerX | RELATIVE (between L/R columns) |
| Detector X | RELATIVE to `layoutBounds.maxX` |
| SlitControlPanel bottom | CONSTRAINT-DRIVEN (ManualConstraint) |
| Graph expanded height | DYNAMIC (Accordion) |
| Time/Eraser visibility | DYNAMIC (detectionMode === hits) |
| Detector pattern / hits | PHYSICS_DRIVEN |
| Flutter FittedBox scale into Home body | VIEWPORT_DRIVEN (port-only chrome) |

---

## 10. Z-Order (Experiment ScreenView addChild order + overlays)

Approximate paint / pick order from construction:

```text
1  OVERHEAD_APPARATUS
2  SLIT_COLUMN (front slit + slit panel)
3  DETECTOR_COLUMN (detector + screen controls + graph)
4  SOURCE_CONTROL_PANEL
5  SCENE_RADIO_BUTTON_GROUP
6  RESET_ALL
7  RULER_CHECKBOX
8  TIME_CONTROL
9  ERASER
10 DETECTOR_RULER (overlay, added last among tools)
11 A11Y description node
```

Within `FrontFacingDetectorScreenNode`:

```text
background → canvas → flash → zoom± → scaleIndicator → snapshotColumn
```

**Rule:** Bottom tools and ruler must remain above graph chrome when graph expands.

---

## 11. Responsive / Viewport Rules

### PhET (original)

- Design is authored in fixed `layoutBounds`.
- Joist scales the ScreenView into the browser viewport (**uniform scale**, letterboxing).
- No Experiment-specific reflow that hides columns at small widths.
- `visibleBoundsProperty` used for ruler drag limits, not for reflowing panels.

### Flutter port implication

- `QwiDesignScaler` (`FittedBox` + contain) is the Joist scale analogue.
- **Home AppBar + SafeArea are outside design canvas** — must not be compensated by rewriting PhET constants.
- Do **not** invent a second layout by shrinking `FRONT_FACING_ROW_TOP` ad hoc; if chrome eats space, fix shell/scaler, not physics layout formulas.

---

## 12. Spacing System (Experiment)

| Token | px | Usage |
|---|---|---|
| S0 | 2 | Slit panel bottom margin; brightness VBox |
| S1 | 4 | Accordion content X margin; snapshot VBox |
| S2 | 6 | Zoom inset; tool checkbox spacing; accordion Y margin |
| S3 | 8 | Primary vertical stack gap |
| S4 | 10 | Source panel margins; slit horizontal padding |
| S5 | 15 | Root margin; bottom control spacing |
| S6 | 20 | Slit panel section spacing |
| S7 | 40 | ScreenControls radios↔brightness |

---

## 13. Panel Inner Metrics

### SourceControlPanel

```text
minWidth: 160
xMargin: 10
yMargin: 10
fill/stroke: panel colors
```

### SlitControlPanel

```text
preferredWidth: FRONT_FACING_SLIT_VIEW_WIDTH + 20 = 224
content spacing: 20
```

### ScreenControlsPanel

```text
fill: null
stroke: null
xMargin: 0
yMargin: 6
HBox spacing: 40
radios: vertical, spacing 8
```

### GraphAccordionBox

```text
chart: 376 × 103
y-gutter: 24
contentXMargin: 4
contentYMargin: 6
cornerRadius: 5
default expanded: false
```

---

## 14. Relationship Summary

```text
OVERHEAD_EMITTER.centerX     = SOURCE_CONTROL_PANEL.centerX
OVERHEAD_SLIT.centerX        = MIDDLE_COLUMN.centerX
FRONT_FACING_SLIT.centerX    = MIDDLE_COLUMN.centerX
SLIT_CONTROL_PANEL.centerX   = MIDDLE_COLUMN.centerX

FRONT_FACING_DETECTOR.top    = FRONT_FACING_ROW_TOP
FRONT_FACING_SLIT.top        = FRONT_FACING_ROW_TOP
SOURCE_CONTROL_PANEL.top     ≈ FRONT_FACING_ROW_TOP

SCREEN_CONTROLS.top           = DETECTOR.bottom + 8
GRAPH.top                    = SCREEN_CONTROLS.bottom + 8
GRAPH.chartWidth             = DETECTOR.width

RULER_CHECKBOX.left          = GRAPH.left
TIME.centerX                 = GRAPH.centerX
RESET.bottomRight            = layoutBounds − margins
RULER/TIME/ERASER.centerY    = RESET.centerY

SLIT_CONTROL_PANEL.bottom    ↔ tool-row geometry (ManualConstraint)
```

---

## 15. Flutter Component Mapping

| Layout ID | Existing Flutter component | Status |
|---|---|---|
| ROOT / canvas | `QwiDesignScaler` + `ExperimentScene` | EXISTS (needs Composer) |
| OVERHEAD_* | `ExperimentOverheadView` | EXISTS |
| OVERHEAD_EMITTER | `ExperimentSourceView` | EXISTS |
| FRONT_FACING_SLIT_VIEW | `ExperimentBarrierView` | EXISTS |
| FRONT_FACING_DETECTOR | `ExperimentDetectorView` | EXISTS |
| DETECTOR_SCALE_INDICATOR | inside `ExperimentDetectorView` | EXISTS |
| DETECTOR_ZOOM_± | inside `ExperimentDetectorView` | EXISTS |
| SOURCE_CONTROL_PANEL | `ExperimentSourceControls` + `QwiPanel` | EXISTS |
| SCENE_RADIO_BUTTON_GROUP | `ExperimentParticleSelector` / `QwiParticleSelector` | EXISTS |
| SLIT_CONTROL_PANEL | `ExperimentSlitControls` + `QwiPanel` | EXISTS |
| SCREEN_CONTROLS | `ExperimentDetectorControls` | EXISTS |
| GRAPH_ACCORDION | `ExperimentGraphAccordion` | EXISTS |
| RULER_CHECKBOX | `ExperimentRulerCheckbox` | EXISTS |
| DETECTOR_RULER | `ExperimentRulerView` | EXISTS |
| TIME_CONTROL | `ExperimentTimeControls` | EXISTS |
| ERASER | `_ClearScreenButton` in `experiment_scene.dart` | EXISTS |
| RESET_ALL | `KratosResetAllButton` | EXISTS (L0) |
| SNAPSHOT column / panel | `ExperimentSnapshotIconColumn` / `ExperimentSnapshotPanel` | EXISTS |
| NumberControl chrome | `QwiNumberControl` / `QwiWavelengthControl` | EXISTS |
| Panel chrome | `QwiPanel` | EXISTS |
| Coordinate map | `QwiCoordinateTransform` | EXISTS |
| Layout constants bag | `QwiLayout` | EXISTS — **must become Spec-driven, not page magic** |
| **Layout Composer** | — | **MISSING** |
| **QwiLayoutSpec (data)** | — | **MISSING** (this file is the source of truth to implement) |

HI/SP (for completeness):

| Layout ID | Flutter |
|---|---|
| WAVE_FIELD | HI/SP scene painters |
| PROBE | `QwiProbeNode` |
| MEASURING_TAPE | `QwiMeasuringTape` |

---

## 16. Component Assembly Map (target)

```text
ExperimentScreen
└── QwiDesignScaler                         // Joist scale analogue
    └── QwiLayoutComposer(spec: ExperimentLayoutSpec)
        ├── OVERHEAD_APPARATUS
        │     ExperimentOverheadView + ExperimentSourceView
        ├── LEFT_COLUMN
        │     SourceControls + ParticleSelector
        ├── MIDDLE_COLUMN
        │     BarrierView + SlitControls
        ├── RIGHT_COLUMN
        │     DetectorView + DetectorControls + GraphAccordion
        │     + SnapshotIconColumn
        ├── BOTTOM_TOOL_ROW
        │     RulerCheckbox + TimeControls + Eraser + KratosResetAllButton
        └── OVERLAY
              RulerView + SnapshotPanel
```

### Responsibility boundary

| Layer | Owns |
|---|---|
| Component | Internal visuals, local interaction, local coords |
| `QwiLayoutSpec` | Geometry, anchors, gaps, formulas, responsive class |
| `QwiLayoutComposer` | Places components into bounds from Spec |
| Model / Solver | **UNCHANGED** |

**Forbidden:** `ExperimentDetectorView(left: 512, top: 84)` hardcoding page coords inside the component.

---

## 17. Known Port Drift (audit only — do not “fix” here)

Observed during archaeology vs this Spec:

| Issue | Spec rule violated |
|---|---|
| Slit panel forced to width 224 into ~150px mid-gap | Middle width is **residual between columns**, panel may overhang in PhET but Composer must not cover LEFT/RIGHT functional hit targets |
| Page-level `Positioned` forest in `ExperimentScene` | Missing Layout Composer |
| Ad-hoc changes to `frontFacingRowTop` / detector width | Overrides FIXED ExperimentConstants |
| Graph chart height altered for fit | GRAPH CHART_HEIGHT is FIXED 103 in source |
| Home chrome treated as reason to rewrite constants | Chrome is VIEWPORT_DRIVEN outside canvas |

These are **inputs to Layout Composition**, not excuses to keep tweaking padding.

---

## 18. High Intensity / Single Particles (Composer sealed)

Same canvas **768×504**, margins 15.

| Screen | Spec doc | Dart Spec | Composer |
|---|---|---|---|
| High Intensity | `HIGH_INTENSITY_LAYOUT_SPEC.md` | `HighIntensityLayoutSpec` | `HighIntensityLayoutComposer` |
| Single Particles | `SINGLE_PARTICLES_LAYOUT_SPEC.md` | `SingleParticlesLayoutSpec` | `SingleParticlesLayoutComposer` |

### Shared (source-proven identical)

```text
waveRegionLeft  = margin + leftColumnWidth + 20
waveRegionTop   = 92   (= 15 + 52 + 55 − 30)
WAVE_REGION     = 420 × 385
detector.x      = waveRight − 66 · 0.33
graph.left      = waveRight + 2
```

### Must stay independent

| Rule | HI | SP |
|---|---|---|
| Source panel top | `SOURCE_CONTROL_PANEL_TOP` **178** | `Y_MARGIN + 20` **35** |
| Probe | — | SP-only (`probeLayer = wave + 80`) |
| Auto Fire | — | SP-only (inside source controls; **0.3s** is Model) |

Component map: `COMPONENT_MAP.md`.

---

## 19. Composition Gate Checklist

- [x] Design canvas confirmed
- [x] Layout tree from source
- [x] Root regions + formulas
- [x] Module types classified
- [x] Anchors / relationships / spacing
- [x] Physics vs layout separation documented
- [x] Flutter component map (`COMPONENT_MAP.md`)
- [x] `ExperimentLayoutSpec` + `ExperimentLayoutComposer`
- [x] `HighIntensityLayoutSpec` + `HighIntensityLayoutComposer`
- [x] `SingleParticlesLayoutSpec` + `SingleParticlesLayoutComposer`
- [x] Reassemble without page-level magic numbers
- [x] Visual regression / golden
- [x] Full project QA / Final Layout Regression

---

## 20. Sources Cited

| File | Used for |
|---|---|
| `js/experiment/ExperimentConstants.ts` | Row top/height, detector/slit widths, overhead scale |
| `js/common/QuantumWaveInterferenceConstants.ts` | Margins, scene Y, source panel top, HI/SP sizes |
| `js/experiment/view/ExperimentScreenView.ts` | Column centering, bottom row, ManualConstraint |
| `js/experiment/view/ExperimentDetectorColumnNode.ts` | Detector X, +8 stack |
| `js/experiment/view/ExperimentSlitColumnNode.ts` | Slit column center / panel top |
| `js/experiment/view/FrontFacingDetectorScreenNode.ts` | Local detector structure, scale Y, snapshots |
| `js/experiment/view/FrontFacingSlitNode.ts` | Slit view local metrics |
| `js/experiment/view/GraphAccordionBox.ts` | Chart 376×103 |
| `js/experiment/view/ScreenControlsPanel.ts` | No-fill panel, HBox spacing 40 |
| `js/experiment/view/SlitControlPanel.ts` | Panel width 224 |
| `js/common/view/SourceControlPanel.ts` | minWidth 160 |
| `requirements/.../RENDERING_MAP.md` | Prior lock of 768×504 / Experiment sizes |

---

*End of LAYOUT_SPEC — Experiment Layout Archaeology*
