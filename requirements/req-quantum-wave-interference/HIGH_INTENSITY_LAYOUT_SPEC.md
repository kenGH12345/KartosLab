# HIGH INTENSITY LAYOUT SPEC

> Source lock: PhET `HighIntensityScreenView.ts` + `QuantumWaveInterferenceConstants.ts`  
> Canvas: Joist `ScreenView` **768 × 504**  
> Status: Spec → Composer (this document is the layout truth for HI)

## 0. Non-goals

| Do | Do not |
|---|---|
| Place existing HI widgets | Change WaveKernel / Fresnel / PDF |
| Resolve display bounds | Change sampling **120 × 120** |
| Cite PhET formulas | Copy Experiment column formulas blindly |
| Distinguish sampling vs display | Modify TimeSpeed 0.15 / 0.35 / 0.65 |

```text
solver sampling space: 120 × 120
view display space:    WAVE_REGION 360 × 330 (HI/SP closeout 2026-09-29; was 420×385)
```

---

## 1. Canvas

| Token | Value | Source |
|---|---|---|
| `DESIGN_WIDTH` | 768 | Joist ScreenView |
| `DESIGN_HEIGHT` | 504 | Joist ScreenView |
| `SCREEN_VIEW_X_MARGIN` | 15 | `QuantumWaveInterferenceConstants` |
| `SCREEN_VIEW_Y_MARGIN` | 15 | same |

Responsive: parent uses `FittedBox` / design scaler (same as Experiment when HI ScreenView scales uniformly). Composer emits **design coordinates only**.

---

## 2. Root regions (HI-specific)

Derived from `HighIntensityScreenView` construction order — **not** Experiment’s overhead / front-facing row.

| Region | Bounds (design) | Role |
|---|---|---|
| `LEFT_COLUMN` | `[margin, 0] → [margin+leftColumnWidth, maxY]` | Source panel + scene radios + mass annotation |
| `WAVE_BAND` | wave region AABB + detector AABB | Wave field, barrier, detector screen |
| `RIGHT_COLUMN` | `[maxX − margin − RIGHT_PANEL_WIDTH, margin] → …` | DetectorScreenControls stack |
| `BOTTOM_SLIT_ROW` | bottom of wave band, `bottom = maxY − margin` | Slit configuration row |
| `BOTTOM_TOOL_ROW` | shared Reset centerY | Measuring tape checkbox, clear, Reset All |
| `OVERLAY` | full canvas | Measuring tape drag, snapshot dialog |

---

## 3. Wave region (core formula)

From `createWaveRegionLayout` / locals:

```text
CONTENT_VERTICAL_OFFSET     = 12
SOURCE_BEAM_THUMBNAIL_CENTER_Y = 40 + CONTENT_VERTICAL_OFFSET   // 52
THUMBNAIL_GAP               = 55
WAVE_REGION_Y_OFFSET        = -30

leftColumnWidth             = max(sourceControlPanel.width, sceneRadioButtonGroup.width)  // CONTENT_DRIVEN
leftColumnCenterX           = SCREEN_VIEW_X_MARGIN + leftColumnWidth / 2

waveRegionLeft  = SCREEN_VIEW_X_MARGIN + leftColumnWidth + 20
baseWaveRegionTop = SCREEN_VIEW_Y_MARGIN + SOURCE_BEAM_THUMBNAIL_CENTER_Y + THUMBNAIL_GAP
waveRegionTop   = baseWaveRegionTop + WAVE_REGION_Y_OFFSET
                = 15 + 52 + 55 − 30
                = 92

WAVE_REGION_WIDTH  = 420
WAVE_REGION_HEIGHT = 385
waveRegionRight = waveRegionLeft + WAVE_REGION_WIDTH
slitControlsBottom = layoutBounds.maxY − SCREEN_VIEW_Y_MARGIN
```

**Flutter estimate:** `leftColumnWidth = 168` (HI source panel `Positioned` width).  
→ `waveRegionLeft = 15 + 168 + 20 = 203`.

---

## 4. Detector (HI)

From `createAndAddWaveRegionNodes`:

```text
DETECTOR_SCREEN_WIDTH            = 66
DETECTOR_SCREEN_OVERLAP_FRACTION = 0.33
DETECTOR_SCREEN_VISIBLE_FRACTION = 0.67
DETECTOR_SCREEN_SKEW             = 66 · tan(20°)

detector.x = waveRegionRight − DETECTOR_SCREEN_WIDTH · OVERLAP_FRACTION
detector.y = waveRegionTop − DETECTOR_SCREEN_SKEW · VISIBLE_FRACTION
```

Flutter display module uses an **axis-aligned AABB** of width 66 and height `WAVE_REGION_HEIGHT` for hit/paint (skew is painter-level).  
Spec records PhET `y` for the parallelogram origin; AABB top for Composer = Spec `detector.top` (PhET y).

**Not** Experiment’s right-anchor `(maxX − margin − localMaxX)`.

---

## 5. Graph

From `DetectorPatternGraphLayerNode` (shared HI/SP node; **visibility toggles** with detector):

```text
DETECTOR_PATTERN_GRAPH_LEFT_GAP = 2

graph.left = waveRegionRight + 2
graph.top  = waveRegionTop
```

When graph is visible, PhET hides detector screen. Flutter may still paint both for MVP; **anchor formula stays PhET**.

Graph zoom control is a **Functional** child of the graph display module (not a separate root region).

---

## 6. Left column (Functional)

| Module | Placement | Source |
|---|---|---|
| `SOURCE_CONTROL_PANEL` | `centerX = leftColumnCenterX`, `top = SOURCE_CONTROL_PANEL_TOP (178)` | HI ScreenView |
| `SCENE_RADIO_BUTTON_GROUP` | `centerX = leftColumnCenterX`, `centerY = SCENE_BUTTON_GROUP_CENTER_Y (470)` | constants |
| `PARTICLE_MASS_ANNOTATION` | under emitter; SP/HI beam thumbnail | optional Flutter |

---

## 7. Right column (Functional)

From `createAndAddDetectorScreenControls` ManualConstraints:

```text
RIGHT_PANEL_WIDTH = 180

detectorScreenControls.right = maxX − SCREEN_VIEW_X_MARGIN
detectorScreenControls.top   = SCREEN_VIEW_Y_MARGIN

rightPanelCenterX = maxX − margin − RIGHT_PANEL_WIDTH / 2

bottomButtonsRow → positionBottomButtonsRow(maxX − margin, maxY − margin)
waveDisplayAndTimeControlsGroup → positionWaveDisplayAndTimeControlsGroup(rightPanelCenterX, …)
```

Flutter composition（对齐原版截图 · 2026-09-29 closeout）:

```text
1. Wave Display + Time    → top-anchored at Y_MARGIN
2. Screen + Snap          → under Wave Display, gap = 10
3. Tools (Measuring Tape…)→ under Screen, gap = 10;
                             stack fits above Reset (gap 12)
```

Display wave (closeout): **360 × 330**（留缝控行 + 右栏间隙；采样仍 120×120）。

Modules:

| Module | Kind |
|---|---|
| `WAVE_DISPLAY_MODE_CONTROL` | Functional (Electric Field / Amplitude / Real Part) |
| `TIME_CONTROLS` | Functional (Pause / Step / Speed) — semantics unchanged |
| `SCREEN_CONTROLS` | Functional (detection mode, brightness, clear, snapshot) |
| `TOOLS_CHECKBOXES` | Functional (Measuring Tape, …) |
| `RESET_ALL` | Functional — L0 `KratosResetAllButton`, radius 20.5 |

---

## 8. Bottom slit row

```text
slit row left  ≈ waveRegionLeft
slit row bottom = maxY − margin
```

`createAndAddSlitConfigurationControlsRow(…, waveRegionLeft, slitControlsBottom, …)`.

---

## 9. Measuring tape / Snapshot

| Module | Kind | Layout |
|---|---|---|
| `MEASURING_TAPE_CHECKBOX` | Functional | Bottom tool row (left) |
| `MEASURING_TAPE_OVERLAY` | Overlay | Full canvas; geometry tied to **wave display bounds** |
| `SNAPSHOT_CONTROL` | Functional | Inside screen controls |
| `SNAPSHOT_DIALOG` | Overlay | Centered modal (Flutter port) |

Do not re-open measuring-tape / snapshot internal behavior.

---

## 10. Zoom

| Module | Kind |
|---|---|
| `GRAPH_ZOOM_CONTROL` | Functional (buttons on graph) |
| `ZOOMED_WAVE` / source beam thumbnail | Display (PhET HI thumbnail) — Flutter may omit visual beam; bounds reserved |

---

## 11. Z-order (addChild order ≈ back → front)

1. Detector screen  
2. Wave region (field + barrier / slits)  
3. Graph layer  
4. Left / right controls  
5. Slit row + bottom buttons  
6. Measurement tools overlay  
7. Snapshot dialog  

---

## 12. Simulation ↔ view mapping

| Space | Size | Owner |
|---|---|---|
| Solver sample | 120 × 120 | Model / WaveKernel — **immutable** |
| Wave display | 420 × 385 | This Spec / Composer |
| Detector PDF / hits | y ∈ [0,1] wave-normalized | Model; view maps into detector AABB |

Composer must not change sampling dimensions.

---

## 13. Component map

| Layout node | Existing Flutter |
|---|---|
| Wave field | `WaveFieldPixelPainter` / HI wave canvas |
| Barrier | `_HiBarrierPainter` |
| Detector | `HiDetectorPainter` |
| Graph | `HiGraphPainter` |
| Source / particle | `HiSourceControls`, `QwiParticleSelector` |
| Wave mode / time | `HiWaveModeControls`, `HiTimeControls` |
| Screen / snap | `HiDetectorControls` + snap buttons |
| Slits | `HiSlitControls` |
| Tape | `QwiMeasuringTapeOverlay` |
| Reset | `KratosResetAllButton` |

---

## 14. Shared with Experiment?

| Rule | Share? |
|---|---|
| Canvas 768×504, margin 15 | Yes (Joist) |
| `RIGHT_PANEL_WIDTH` 180 | Yes (constants) |
| Bottom Reset bottom-right | Yes (pattern) |
| Detector right-anchor Experiment formula | **No** — HI uses waveRegionRight − overlap |
| Front-facing row / middle centerX | **No** — HI has no front-facing row |
| Wave top formula | HI-only (and SP — verify separately) |

---

## 15. Formula checklist (unit tests)

1. Canvas 768×504  
2. `waveRegionTop == 92` (with standard offsets)  
3. `waveRegionLeft == margin + leftColumnWidth + 20`  
4. Wave size 420×385  
5. Detector `left == waveRight − 66·0.33`  
6. Graph `left == waveRight + 2`, `top == waveTop`  
7. Source panel `top == 178`  
8. Scene radios `centerY == 470`  
9. Right panel `right == maxX − margin`  
10. Reset bottom-right; bottom tools share centerY  
