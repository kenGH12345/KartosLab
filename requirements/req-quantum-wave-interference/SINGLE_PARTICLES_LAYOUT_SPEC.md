# SINGLE PARTICLES LAYOUT SPEC

> Source lock: PhET `SingleParticlesScreenView.ts` + shared constants  
> Canvas: Joist **768 × 504**  
> Status: Spec → Composer (independent of Experiment; wave formula **verified against HI**)

## 0. Non-goals

| Do | Do not |
|---|---|
| Place existing SP widgets | Change GaussianPacket / probeProbability |
| Resolve display bounds | Touch auto-fire **0.3s** interval semantics |
| Separate Probe / Auto Fire modules | Copy HI panel tops blindly |
| Cite PhET formulas | Change 120×120 sampling |

---

## 1. Canvas

Same Joist canvas as HI/Experiment: **768 × 504**, margins **15**.

---

## 2. Root regions (SP)

| Region | Role |
|---|---|
| `LEFT_COLUMN` | Source panel (+ Auto Fire), scene radios, mass annotation |
| `WAVE_BAND` | Packet / wave field, barrier, emitter, detector |
| `PROBE_LAYER` | Detector probe (SP-only Display + Functional) |
| `RIGHT_COLUMN` | Wave display / time + screen / snapshot / tools |
| `BOTTOM_SLIT_ROW` | Slit configuration |
| `BOTTOM_TOOL_ROW` | Measuring tape, clear, Reset |
| `OVERLAY` | Tape drag, snapshot dialog, max-hits panel |

---

## 3. Wave region — **shared formula with HI** (source-proven)

Identical locals in `SingleParticlesScreenView`:

```text
CONTENT_VERTICAL_OFFSET = 12
TOP_ROW_CENTER_Y        = 40 + 12   // 52
THUMBNAIL_GAP           = 55
WAVE_REGION_Y_OFFSET    = -30

waveRegionLeft  = X_MARGIN + leftColumnWidth + 20
waveRegionTop   = Y_MARGIN + TOP_ROW_CENTER_Y + THUMBNAIL_GAP + WAVE_REGION_Y_OFFSET
                = 92
WAVE_REGION     = 420 × 385
```

Flutter `leftColumnWidth` estimate: **168** → `waveRegionLeft = 203`.

May share resolved wave/detector/graph helpers with HI Spec **only because both ScreenViews use the same formulas**.

---

## 4. Detector / Graph

Same as HI:

```text
detector.x = waveRegionRight − 66 · 0.33
detector.y = waveRegionTop − SKEW · 0.67
graph.left = waveRegionRight + 2
graph.top  = waveRegionTop
```

SP detection mode is always **hits** (no intensity radio in PhET).

---

## 5. Left column — **differs from HI**

| Module | Placement | Note |
|---|---|---|
| `SOURCE_CONTROL_PANEL` | `centerX = leftColumnCenterX`, `top = Y_MARGIN + 20` (= **35**) | **Not** `SOURCE_CONTROL_PANEL_TOP` 178 |
| `AUTO_FIRE` | Inside source panel (`additionalContent`) | Functional; model interval untouched |
| `SCENE_RADIO_BUTTON_GROUP` | `centerY = 470` | Same constant |
| Emitter | `right = waveRegionLeft + 2`, `centerY = waveTop + H/2` | Display |

---

## 6. Probe (SP-only)

From `DetectorProbeNode(…, waveRegionLeft, waveRegionTop, slitSeparationCenter…)`:

| Aspect | Rule |
|---|---|
| Drag region | Wave display bounds |
| Panel anchor | Below / near slit separation control (PhET); Flutter uses wave bottom center estimate |
| Layer | Above wave, below chrome overlays |
| Kind | Display (circle) + Functional (Detect / radius) |

Composer places `QwiProbeNode` in wave AABB (+ panel extension); **no page-level magic Positioned**.

---

## 7. Right / bottom

Same ManualConstraint pattern as HI:

```text
detectorScreenControls.right = maxX − margin
detectorScreenControls.top   = margin
bottomButtonsRow → (maxX − margin, maxY − margin)
```

Flutter right rail（同 HI · 2026-09-29 closeout）:

```text
1. Wave Display + Time    → top-anchored at Y_MARGIN
2. Screen + Snap          → under Wave Display, gap = 10
3. Tools                  → under Screen, gap = 10; above Reset
```

粒子选择器：强制 2×2，锚在左栏底部空白（同 HI）。

Reset: L0 `KratosResetAllButton` radius 20.5, shared bottom centerY.

---

## 8. Z-order

1. Detector  
2. Wave / packet + barrier  
3. Probe  
4. Graph  
5. Emitter / max-hits  
6. Left / right controls  
7. Slit + bottom tools  
8. Measurement overlay  
9. Snapshot dialog  

---

## 9. Component map

| Layout node | Flutter |
|---|---|
| Wave / packet | `WaveFieldPixelPainter` |
| Barrier | `_SpBarrierPainter` |
| Detector | `HiDetectorPainter` |
| Graph | `SpGraphPainter` |
| Probe | `QwiProbeNode` |
| Source / Auto Fire | `SpSourceControls` |
| Particles | `QwiParticleSelector` |
| Wave mode / time | `SpWaveModeControls`, `SpTimeControls` |
| Screen / snap | `SpDetectorControls` + snap |
| Slits | `SpSlitControls` |
| Tape | `QwiMeasuringTapeOverlay` |
| Reset | `KratosResetAllButton` |

---

## 10. Shared with HI?

| Item | Share? |
|---|---|
| Wave / detector / graph formulas | **Yes** (identical ScreenView math) |
| Source panel top 178 | **No** — SP uses `Y_MARGIN + 20` |
| Probe / Auto Fire | SP-only |
| Experiment front-facing formulas | **No** |

---

## 11. Formula checklist

1. Canvas 768×504  
2. waveTop == 92  
3. waveLeft == margin + leftW + 20  
4. Wave 420×385  
5. Detector overlap formula  
6. Graph waveRight + 2  
7. Source panel top == 35  
8. Scene radios centerY == 470  
9. Right panel right-anchored  
10. Bottom shared Reset centerY  
11. Probe bound to wave region  
