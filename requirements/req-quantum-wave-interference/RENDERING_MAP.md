# RENDERING_MAP — Flutter Rendering Architecture

## Directory plan

```text
lib/simulations/quantum_wave_interference/
  domain/          # Phase 1 — pure Dart
  solvers/
  render_data/
  view/
    common/
    experiment/
    high_intensity/
    single_particles/
  render/
    wave_renderer.dart
    packet_renderer.dart      # may share wave_renderer
    barrier_renderer.dart
    detector_renderer.dart
    hit_renderer.dart
    graph_renderer.dart
    ruler_renderer.dart
    probe_renderer.dart
    snapshot_renderer.dart
```

禁止单一巨型 Painter 承担全部绘制。

---

## Render Data contracts

| Type | Contents | Producer |
|---|---|---|
| `WaveFieldRenderData` | grid W×H；RGBA or layered samples；display mode | WaveRasterizer ← solver |
| `WavePacketRenderData` | optional metadata（center, sigma）for overlays | SP scene |
| `DetectorRenderData` | mode；PDF column；brightness；formation factor | scene |
| `HitRenderData` | typed list/buffer of (x,y)；source color；cap | scene |
| `GraphRenderData` | intensity polyline or 100 bins；zoom | scene + view zoom |
| `ProbeRenderData` | center, radius, p%, state | DetectorProbe |
| `SnapshotRenderData` | immutable SnapshotRecord → texture | snapshot store |
| `BarrierRenderData` | slit geometry display coords；covers；detector flashes | scene |

---

## Canvas vs Widget

| Concern | Tech |
|---|---|
| Wave field 120²→420×385 | `CustomPainter` / Image buffer |
| Detector intensity column / hits stamps | Canvas texture（增量 hits） |
| Graph curves / histograms | Canvas |
| Controls, panels, checkboxes | Flutter widgets |
| Probe / ruler / tape drag | custom interaction + small overlay painters |
| Hits | **bitmap/buffer**；禁止 1 hit = 1 Widget |

PhET HI/SP：`MAX_RENDERED_HITS = 10000`（可低于 MAX_HITS=25000）。

---

## Design coordinates

| Constant | Value |
|---|---|
| `WAVE_REGION_WIDTH` | 420 |
| `WAVE_REGION_HEIGHT` | 385 |
| `DETECTOR_SCREEN_WIDTH`（HI/SP） | 66 |
| Detector skew angle | 20° |
| Overlap / visible fractions | 0.33 / 0.67 |
| `RIGHT_PANEL_WIDTH` | 180 |
| `SCREEN_VIEW_*_MARGIN` | 15 |
| Experiment front-facing detector width | 376 |
| Experiment front-facing row | top 180，height 155 |
| Graph (HI/SP) | 102 × 385 |

统一：`design → Transform → Flutter screen`；三屏共用坐标工具，禁止各猜比例。

---

## Pipelines

### Wave（HI/SP）
```text
solver grid (default 120)
 → FieldSample / LayeredFieldSample
 → WaveRasterizer RGBA
 → scale to 420×385 canvas
```

### Detector Experiment
```text
Fraunhofer or hits[]
 → renderDetectorScreenTexture (scale default 2)
 → front-facing + overhead views
```

### Detector HI/SP
```text
PDF or hits[]
 → DetectorScreenTextureRenderer (scale default 1)
 → skewed parallelogram
```

### Visual must not alter physics
Brightness / colorPower / formationFactor / waveVisualizationAmplitudeColorPowerMultiplier = **display only**.

---

## Performance budget (planning)

| Workload | Expected |
|---|---|
| Wave raster | 120×120 evaluate/sample/color per frame when dirty |
| Hits | up to 25k stored；render ≤10k stamps |
| Graph | 200 intensity samples（× scale）或 100 bins |
| Snapshots | ≤4 × (hits copy or PDF array) per scene × 4 sources × 3 screens |
| Target FPS | 60 desktop / ≥30 mid Android under default settings |

详见 `PERFORMANCE_PLAN.md`。