# SINGLE_PARTICLES_MAPPING — PhET → Flutter

Source lock: `quantum-wave-interference-main` TypeScript  
Layout: Joist `ScreenView` **768 × 504** (same as Experiment / High Intensity).

## Backend (non-negotiable)

```text
SingleParticlesModel
  → SingleParticlesSceneModel
  → SingleParticleWaveSolver (GaussianPacketSource + WaveKernel + Fresnel)
  → instantaneous |ψ|² PDF
  → discrete roulette hit (≤1 / packet)
  → DetectorProbe Bernoulli + measurement projection
  → WaveFieldRenderData / SpDetectorRenderData
  → Renderers / Screen
```

**Forbidden on this screen:**

- `FraunhoferSolver` / `sinc²` / `cos²` as probability backend
- High Intensity continuous `PlaneWaveSource` as packet substitute
- `Random()` / `DateTime.now()` in core simulation RNG
- Intensity detector mode (Hits only)

## Mapping table

| Source TypeScript | Flutter Model | Flutter Solver | Flutter RenderData | Flutter Controller | Flutter Painter / UI | State Transition | Test Coverage |
|---|---|---|---|---|---|---|---|
| `SingleParticlesModel` | `models/single_particles_model.dart` | — | — | `SingleParticlesController` | `single_particles_screen.dart` | enter/leave independent of Exp/HI | lifecycle / screen |
| `SingleParticlesSceneModel` | `SingleParticlesSceneModel` | `SingleParticleWaveSolver` | wave + detector PDF | controller façade | scene / controls | emit→prop→detect/probe→end | contract / model |
| `GaussianPacketSource` | via solver `createSource()` | `wave_kernel_types.dart` | WaveField RGBA | resample on dirty | `WaveFieldPixelPainter` | packetActive | core + SP tests |
| packet spread / chirp | constants → source | `wave_propagation.dart` | visual envelope | — | wave canvas | σ(t), chirpX/Y | numerics |
| `sampleDetectionDelayToTargetX` | scene timing | — | — | — | — | targetDetectionTime | hit lifecycle |
| on-slit decoherence / re-emission | `createPacketDecoherenceEventIfNeeded` / `startPacketReEmission` | `packetReEmission` + `applyDecoherenceEvent` | collapse / re-emit visual | — | barrier detectors | which-path | which-path tests |
| detector Hits | `HitBuffer` + `WaveRegionHitSampler` | instantaneous PDF | `SpDetectorRenderData` | — | `HiDetectorPainter` (hits) | ≤1 hit/packet | hit / determinism |
| `DetectorProbe` | `domain/probe.dart` + scene | `ProbeSolver` | probe overlay | drag / Detect | probe node | noBarrier only | probe tests |
| Graph PDF + 100-bin hist | instantaneous PDF + `HitsHistogramData` | — | graph data | zoom 1…6 | `HiGraphPainter` | zoom display-only | graph / histogram |
| Snapshot max 4 | `SnapshotStore` | — | hit metadata | Snap / View | panel | 5th no-op | snapshot |
| AutoRepeat 0.3 s | `autoRepeat` + clock | — | — | checkbox | source panel | Pause stops | auto-fire / time |
| TimeSpeed 0.15/0.7/16 | `TimeSpeedFactors.singleParticles` | — | — | time controls | bottom bar | stepOnce=1/60 | time tests |
| Measuring Tape μm/nm | `MeasuringTapeState` | — | — | tape checkbox | tape label | geometry only | ruler |
| Reset All | `model.reset()` | solver.reset | clear caches | `KratosResetAllButton` | L0 orange | RESET_SEMANTICS | reset |

## Defaults (TypeScript)

| Parameter | Value |
|---|---|
| Source | photons |
| Photon λ | 650 nm |
| Photon slit sep | 2 μm (1–3 μm) |
| Electron / neutron / He speeds | 1.1e6 / 500 / 1200 m/s |
| Barrier default | doubleSlit / bothOpen |
| Detection mode | **hits only** |
| Wave display (photon) | electricField |
| Wave display (matter) | realPart |
| σx, σy | 0.15 × region |
| Packet traversal | 1.5 s |
| Longitudinal / transverse spread | 2.5 / 1.5 traversals |
| Re-emission timeAdvance sigmas | 1.5 |
| Min emission interval | 0.3 s |
| Graph zoom default | level 6 |
| Max hits / snapshots | 25000 / 4 |
| TimeSpeed | 0.15 / 0.7 / 16 |
| Probe | noBarrier only |

## Coordinate notes

- Wave region: x ∈ [0, W], y ∈ [−H/2, +H/2]; display top = +y
- Hits: wave-region normalized y ∈ [0, 1]
- left/right (top view) ≡ top/bottom (front view) — do not invert
- Zoom / brightness: display only — not physics

## Lifecycle

```text
Spawn (emitPacket)
  → Propagate (solver.step)
  → optional on-slit which-path (decoherence OR re-emission)
  → Probe Detect? → success: end, 0 screen hits / fail: bite+renorm
  → else screen detect at targetDetectionTime → 1 hit
  → packet removed
  → autoRepeat? wait ≥0.3 s → next emit
```
