# COMPONENT_MAP — QWI Original Module → Flutter → Composer

> Layout architecture: **Spec → Composer → Existing Components**  
> Specs: `LAYOUT_SPEC.md` · `HIGH_INTENSITY_LAYOUT_SPEC.md` · `SINGLE_PARTICLES_LAYOUT_SPEC.md`  
> Primitives: `lib/.../view/layout/qwi_layout_primitives.dart`

## Architecture

```text
Original PhET Layout
        ↓
Layout Archaeology / LAYOUT_SPEC*
        ↓
Screen-specific LayoutSpec
        ↓
Layout Composer
        ↓
Existing Components
```

| Layer | Owns |
|---|---|
| Component | Internal visuals, local coords, interaction |
| LayoutSpec | Source-derived bounds / anchors / relationships |
| Composer | Placement, transform into design canvas |

**Forbidden maintenance path:** Screen → `Positioned(left:…)` → Padding tweak → screenshot.

---

## Shared primitives

| Primitive | File |
|---|---|
| `QwiRect` / `QwiAnchor` / `QwiSpacing` | `qwi_layout_primitives.dart` |
| Design canvas 768×504, margin 15 | All Specs |
| `KratosResetAllButton` (radius 20.5) | L0 common |

---

## Experiment

| Original Module | Flutter Component | Composer placement | Layout rule |
|---|---|---|---|
| Overhead apparatus | `ExperimentOverheadView` | Display layer | Overhead band |
| Source emitter (front) | `ExperimentSourceView` | Display | Middle / left of row |
| Double slit (front) | `ExperimentBarrierView` | Display | Middle centerX |
| Detector screen | `ExperimentDetectorView` | Display | Right-anchor formula |
| Snapshot column | `ExperimentSnapshotsView` | Functional | Detector.right + gap |
| Graph accordion | `ExperimentGraphView` | Display | Controls.bottom + 8 |
| SourceControlPanel | `ExperimentSourceControls` | `sourcePanel` | Top ≈ row top |
| Scene radios | `ExperimentParticleSelector` | `sceneRadios` | centerY = 470 |
| SlitControlPanel | `ExperimentSlitControls` | `slitPanel` | Below row + 8 |
| Screen controls | `ExperimentScreenControls` | `screenControls` | Detector.bottom + 8 |
| Measuring tape | `ExperimentRulerView` | Overlay / checkbox | Bottom shared centerY |
| Time controls | in Experiment controls | `timeControls` | Bottom shared centerY |
| Eraser | Experiment clear | `eraser` | Bottom shared centerY |
| Reset All | `KratosResetAllButton` | `reset` | Bottom-right |

Spec: `ExperimentLayoutSpec` · Composer: `ExperimentLayoutComposer` · Scene: `ExperimentScene` → Composer only.

---

## High Intensity

| Original Module | Flutter Component | Composer placement | Layout rule |
|---|---|---|---|
| Wave region | `WaveFieldPixelPainter` | `waveRegion` | left=203*, top=92, 420×385 |
| Barrier / slits | `_HiBarrierPainter` | Relative to wave | barrierFractionX |
| Detector screen | `HiDetectorPainter` | `detector` | waveRight − 66·0.33 |
| Pattern graph | `HiGraphPainter` | `graph` | waveRight + 2 |
| SourceControlPanel | `HiSourceControls` | `sourcePanel` | top = **178** |
| Scene radios | `QwiParticleSelector` | `sceneRadios` | centerY = 470 |
| Wave display mode | `HiWaveModeControls` | Right column | top-right rail |
| Time controls | `HiTimeControls` | Right column | with wave display |
| Screen / snap | `HiDetectorControls` + Snap | Right column | stacked +8 |
| Slit row | `HiSlitControls` | `slitControls` | waveLeft, bottom margin |
| Measuring tape | `QwiMeasuringTapeOverlay` | Overlay | wave bounds |
| Tape checkbox | Checkbox row | Bottom tools | shared centerY |
| Clear / Reset | Clear + `KratosResetAllButton` | Bottom tools | shared centerY |

\* `203` = Spec resolve with leftColumnWidth estimate 168 — not a page magic number.

Spec: `HighIntensityLayoutSpec` · Composer: `HighIntensityLayoutComposer`.

---

## Single Particles

| Original Module | Flutter Component | Composer placement | Layout rule |
|---|---|---|---|
| Packet / wave | `WaveFieldPixelPainter` | `waveRegion` | Same formula as HI |
| Barrier | `_SpBarrierPainter` | Relative to wave | — |
| Detector | `HiDetectorPainter` | `detector` | Same as HI |
| Hits graph | `SpGraphPainter` | `graph` | waveRight + 2 |
| **Detector Probe** | `QwiProbeNode` | `probeLayer` | **wave + 80** (SP-only) |
| Source + **Auto Fire** | `SpSourceControls` | `sourcePanel` | top = **35** (≠ HI 178) |
| Scene radios | `QwiParticleSelector` | `sceneRadios` | centerY = 470 |
| Wave mode / time | `SpWaveModeControls` / `SpTimeControls` | Right column | top-right |
| Screen / snap | `SpDetectorControls` + Snap | Right column | stacked |
| Slit row | `SpSlitControls` | `slitControls` | waveLeft, bottom |
| Tape / Reset | Overlay + Reset | Bottom tools | shared centerY |

**Model semantics (Composer must not touch):** Auto Fire ≥ 0.3s; packet / probeProbability / hit sampling.

Spec: `SingleParticlesLayoutSpec` · Composer: `SingleParticlesLayoutComposer`.

---

## Physics isolation

| Changed by Composer? | Area |
|---|---|
| No | WaveKernel, Fresnel, Fraunhofer, GaussianPacket |
| No | PDF / hits / decoherence / probe calc |
| No | TimeSpeed 0.15 / 0.35 / 0.65; step 1/60 |
| No | Sampling grid 120×120 |
| Yes | Display bounds, anchors, z-order only |

---

## Home

| Item | Status |
|---|---|
| Home card / route / Back | Unchanged by Layout Composition |
| Home → QWI tabs | Integration tests |

---

*COMPONENT_MAP — Final Layout Regression*
