# MODEL_MAP — Domain Objects for Flutter

目标：PHASE 1 实现的纯 Dart 领域层（无 Flutter widgets）。

---

## Ownership hierarchy

```text
ExperimentModel
 └─ SceneModel × {photons, electrons, neutrons, heliumAtoms}

HighIntensityModel : WaveRegionScreenModel
 └─ HighIntensitySceneModel ×4
     └─ HighIntensityWaveSolver

SingleParticlesModel : WaveRegionScreenModel
 └─ SingleParticlesSceneModel ×4
     ├─ SingleParticleWaveSolver
     └─ DetectorProbe
```

切换 source = 切换 active scene，**不销毁**其他 scene 状态。

---

## Proposed Dart types（以源码字段为准）

### `SourceType`
`photons | electrons | neutrons | heliumAtoms`

### `QuantumSourceModel`（per scene）
| Field | Notes |
|---|---|
| `sourceType` | enum |
| `wavelengthNm` | photons only；matter derived |
| `particleSpeed` | matter；photons 0 |
| `sourceStrength` | Experiment only [0,1] |
| `isEmitting` | bool |
| `autoRepeat` | SP only |
| `effectiveWavelengthM` | derived |

### `BarrierModel`
| Field | Notes |
|---|---|
| `barrierType` | none \| doubleSlit（Exp 始终有 barrier） |
| `slitConfiguration` | see enum |
| `slitSeparationMm` | property units = mm in PhET |
| `slitWidthMm` | Exp fixed per source；HI/SP from display layout |
| `barrierPositionFraction` | [0.38, 0.62]，default 0.5 |

### `SlitConfiguration`
`bothOpen | leftCovered | rightCovered | leftDetector | rightDetector | bothDetectors | noBarrier`

### `DetectorModel`
| Field | Notes |
|---|---|
| `detectionMode` | intensity \| hits（SP forced hits） |
| `screenDistanceM` | Experiment only |
| `brightness` | 0–100 visual |
| `hits` | list / buffer |
| `totalHits` | int |
| `left/rightDetectorHits` | which-path counters |
| `intensityDistribution` | Float64List PDF |
| `maxHits` | 25000 |

### `WaveField` / solvers
- Interface `WaveSolver`
- `HighIntensityWaveSolver`, `SingleParticleWaveSolver`
- Pure `WaveKernel.evaluateSample`

### `WavePacketState`（SP）
active, center, sigma, chirp, reEmission descriptor, targetDetectionTime

### `DetectorProbeModel`
position, radius, state, probability

### `SnapshotRecord`
见 `Snapshot.ts` schema（max 4 / scene）

### `SimulationClock`
`time`, `dt`, `paused`, `speed`, `stepOnce()` — **不**依赖 Flutter SchedulerBinding

### `GraphData`
intensity samples / hits histogram bins（100）

### `RulerModel` / `MeasuringTapeModel`
display-only；units mm / μm / nm

---

## What View must NOT do

```text
❌ calculate probability
❌ generate particle hit
❌ advance simulation time
❌ apply Fraunhofer / Fresnel
❌ Bernoulli detect without model
```

View only consumes **Render Data** produced by model/solver.