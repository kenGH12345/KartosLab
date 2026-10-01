# HIGH_INTENSITY_MAPPING — PhET → Flutter

Source lock: `1.0.0-dev.5` / SHA `d9ee906…`  
Layout: Joist `ScreenView` **768 × 504** (same as Experiment; `SCENE_BUTTON_GROUP_CENTER_Y=470`).

## Backend (non-negotiable)

```text
HighIntensityModel
  → HighIntensityWaveSolver (Analytical WaveKernel + Fresnel)
  → FieldSample / time-averaged PDF
  → WaveFieldRenderData / DetectorRenderData
  → Renderers
```

**Forbidden:** `FraunhoferSolver` on this screen.

## Mapping table

| PhET | Flutter | Responsibility | Status |
|---|---|---|---|
| `HighIntensityModel` | `models/high_intensity_model.dart` + `HighIntensityController` | Top model + clock | DONE |
| `HighIntensitySceneModel` | `HighIntensitySceneModel` | Per-source scene | DONE |
| `HighIntensitySolver` / WaveKernel | `HighIntensityWaveSolver` + `wave_kernel.dart` | Continuous plane wave | DONE |
| Fresnel aperture transfer | `fresnel_aperture_transfer.dart` (via WaveKernel) | Slit propagation | DONE |
| `WaveDisplayMode` | `domain/wave_display_mode.dart` | amplitude / electricField / realPart | DONE |
| `WaveRasterizer` | `render/high_intensity/wave_rasterizer.dart` | FieldSample → RGBA | DONE |
| `WaveVisualizationCanvasNode` | `WaveFieldSampler` + `wave_field_renderer.dart` | 120² sample → scale to 420×385 | DONE |
| Detector intensity / hits | HI detector render path | PDF + roulette hits | DONE |
| Graph (PDF + 100 bins) | `hi_graph_renderer` / scene graph | Orientation [0,1] | DONE |
| Snapshot (PDF) | `SnapshotStore` + HI panel | Max 4 | DONE |
| Measuring tape | `MeasuringTapeState` + HI ruler view | μm/nm | DONE |
| Graph zoom (1…6) | `GraphZoomState` (default level 3) | Display window only | DONE |
| TimeControl (SLOW/NORMAL/FAST + step) | Controller + UI | ×0.15/0.35/0.65; stepOnce=1/60 | DONE |
| Formation factor | `stepDetectorPatternFormation` | Eased exponential | DONE |
| Slit-detector decoherence | `stepDecoherenceEvents` @ 5/s | Event-driven | DONE |
| `HighIntensityScreenView` | `view/high_intensity/high_intensity_screen.dart` | Screen shell | DONE |

## Defaults (TypeScript)

| Parameter | Value |
|---|---|
| Source | photons |
| Photon λ | 650 nm (UI 400–700) |
| Photon slit sep | 2 μm (1–3 μm) |
| Electron speed | 1.1e6 m/s |
| Neutron speed | 500 m/s |
| Helium speed | 1200 m/s |
| Barrier | doubleSlit / bothOpen |
| Detection mode | intensity |
| Wave display (photon) | electricField |
| Wave display (matter) | realPart |
| Brightness | 50% |
| Hit rate | 40/s (5/s with slit detectors) |
| Grid | 120×120 (solver sample; display 420×385) |
| Graph zoom default | level 3 (of 1…6) |
| TimeSpeed | 0.15 / 0.35 / 0.65 |

## Coordinate notes

- Wave region model: x ∈ [0, regionWidth], y ∈ [−H/2, +H/2]
- Detector / hits HI: **y ∈ [0, 1]** (wave-region normalized)
- Zoom affects visible graph/detector window only — not WaveKernel physics
- Brightness is display-only — PDF unchanged
