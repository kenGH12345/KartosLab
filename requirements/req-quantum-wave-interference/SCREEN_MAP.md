# SCREEN_MAP — Three Screens

**禁止**用单个 model + `if (screen == …)` 伪装三屏。  
源码：三套独立顶层 Model；HI/SP 共享 `BaseScreenModel`/`BaseSceneModel` 基类，但**实例互不共享状态**。

---

## Overview

| | Experiment | High Intensity | Single Particles |
|---|---|---|---|
| Top model | `ExperimentModel` | `HighIntensityModel` | `SingleParticlesModel` |
| Scene ×4 | `experiment/.../SceneModel` | `HighIntensitySceneModel` | `SingleParticlesSceneModel` |
| Wave field | **None** | Continuous plane wave | Gaussian packet |
| Pattern backend | Closed-form Fraunhofer | Analytical WaveKernel + time avg | Analytical WaveKernel instantaneous |
| Detection modes | intensity + hits | intensity + hits | **hits only** |
| Barrier | Always present | none \| doubleSlit | none \| doubleSlit |
| noBarrier | ❌ | ✅ | ✅ |
| Probe | ❌ | ❌ | ✅（仅 noBarrier） |
| Ruler | Detector mm ruler | Measuring tape | Measuring tape |
| Auto-fire | n/a（连续 hits） | continuous emission | `autoRepeatProperty` |
| TimeSpeed | 0.25 / 1 / 4 | 0.15 / 0.35 / 0.65 | 0.15 / 0.7 / 16 |
| stepOnce | ❌ | ✅ 1/60 | ✅ 1/60 |
| Independent of other screens | ✅ | ✅ | ✅ |

---

## Experiment

### Default state
- Scene: photons；λ=650 nm；sourceStrength=0.5；slitSeparation=0.25 mm；slitWidth=0.02 mm；screenDistance=0.6 m；brightness=50%；slit=`bothOpen`；detectionMode 默认 intensity（对照源码 Property 初值）；playing + NORMAL。

### Model
- 4 independent `SceneModel`；切换 source 保留各场景 hits/settings。
- 无 WaveSolver。

### Controls
- Source type radios；photon λ / matter speed；intensity；slit config combo；slit separation；screen distance；brightness；Intensity/Hits；graph accordion；ruler；zoom ±20/15/10/5 mm；time；reset；snapshots。

### Simulation
- Hits：rejection sampling vs Fraunhofer intensity；rate = 100 × strength / s。

### Detector / Graph / Tools
- Front-facing + overhead apparatus；graph 100-bin hits / theoretical intensity；ruler display-only。

### Reset / Lifecycle
- Reset All：全 scenes + tools + time；clear hits & snapshots。  
- 改物理参数 → clearScreen（清 hits，保留其他设置）。

---

## High Intensity

### Default state
- Photons；barrier doubleSlit；slit bothOpen；sep 2 μm；wave display electricField（matter→realPart）；detection intensity；brightness 50%；playing NORMAL。

### Model
- `HighIntensitySceneModel` + `HighIntensitySolver`。
- Pattern formation factor 缓入；hit rate 40/s（缝探测器时 5/s）。

### Controls
- Source；λ/speed；barrier；slit config（含 noBarrier & detectors）；detection mode；wave display；brightness；graph toggle；measuring tape / stopwatch / plots；time + step；snapshots；reset。

### Differences vs Experiment
- 有可见波场；无 screen-distance slider；无 source intensity slider；缝尺度 μm/nm；TimeSpeed 因子不同；解析 Fresnel 而非 Fraunhofer 闭式（探测器 PDF 来自 solver）。

---

## Single Particles

### Default state
- Photons；autoRepeat=false；no packet；hits mode；probe ready @ (0.5,0.5) r=0.1；slit sep 2 μm；barrier doubleSlit / bothOpen。

### Model
- Packet emission；detection timing rejection+invCDF；probe Bernoulli；which-path re-emission。

### Controls
- Emit；Auto Repeat；barrier/slit；probe tools；wave display；brightness；graph；tape/stopwatch/plots；time+step；snapshots；reset。

### Highest risks
见 `SINGLE_PARTICLES_MAP.md`。

---

## Shared vs screen-specific

| Shared (code reuse, not state) | Screen-specific |
|---|---|
| `WaveKernel`, Fresnel, decoherence math | Experiment Fraunhofer SceneModel |
| Detector texture helpers, Snapshot type | HI pattern formation + continuous hits |
| SourceType, SlitConfiguration enums | SP packet + probe + autoRepeat |
| Constants (masses, MAX_HITS, MAX_SNAPSHOTS) | Three TimeSpeed factor sets |
| | Experiment ruler vs HI/SP measuring tape |

**No global simulation singleton.**