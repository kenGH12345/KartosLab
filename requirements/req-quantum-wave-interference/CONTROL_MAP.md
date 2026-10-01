# CONTROL_MAP — Controls, Ranges, Effects

单位与默认值均摘自源码。`doc/model.md` 中 HI slit 1–5 μm / 默认 3 μm **已过时**。

---

## Experiment

| Control | Default | Range | Unit | Model effect | Visual effect |
|---|---|---|---|---|---|
| Source type | photons | 4 types | — | switch scene | icons/colors |
| Photon wavelength | 650 | Property 380–780；UI 400–700 | nm | Fraunhofer λ；clear hits | photon color |
| Electron speed | 6e5 | 2e5–1e6 | m/s | λ=h/(mv)；clear | — |
| Neutron speed | 600 | 200–1000 | m/s | same | — |
| Helium speed | 600 | 200–1000 | m/s | same | — |
| Source intensity | 0.5 | 0–1 | — | hit rate ×100 | — |
| Slit config | bothOpen | 6（无 noBarrier） | enum | pattern formula | covers/detectors |
| Slit separation | 0.25 / 0.001 | photons 0.05–0.5；matter 1e-4–0.002 | mm | fringe spacing | slit spacing |
| Slit width | 0.02 / 6e-5 | fixed per source | mm | envelope width | aperture |
| Screen distance | 0.6 | 0.4–0.8 | m | sinθ / spacing | apparatus |
| Screen brightness | 50 | 0–100 | % | none | gain |
| Detection mode | intensity* | intensity\|hits | — | hit generation on/off | texture |
| Detector zoom | mid* | ±20/15/10/5 mm | mm visible | none（数据半宽不变） | ruler/graph scale |
| Graph | collapsed/open* | — | — | none | curve/hist |
| Ruler | hidden | — | mm | none | overlay |
| TimeSpeed | NORMAL | SLOW/NORMAL/FAST | ×0.25/1/4 | dt scale | animation rate |
| Snapshot | 0 | max 4 | — | store hits/meta | dialog |
| Reset All | — | — | — | full reset | — |

\*核对 Property 构造初值时以 `SceneModel` / `ExperimentModel` 为准。

---

## High Intensity

| Control | Default | Range | Unit | Model effect | Visual |
|---|---|---|---|---|---|
| Photon λ | 650 | 380–780 / UI 400–700 | nm | k、颜色 | wave color |
| e⁻ speed | 1.1e6 | 7e5–1.5e6 | m/s | λ & display speed | — |
| n speed | 500 | 200–800 | m/s | same | — |
| He speed | 1200 | 400–2000 | m/s | same | — |
| Barrier | doubleSlit* | none\|doubleSlit | — | propagation | barrier node |
| Slit config | bothOpen | + noBarrier + detectors | enum | coherence | covers/detectors |
| Slit separation | 2 μm / 2 nm / 0.30 nm | 1–3 μm / 1–3 nm / 0.10–0.40 nm | mm property | geometry | slits |
| Detection mode | intensity | intensity\|hits | — | averaging vs dots | texture |
| Wave display | electricField / realPart | amplitude\|E\|real | — | none | raster mode |
| Brightness | 50 | 0–100 | % | none | gain |
| Hit rate | 40/s (5 w/ slit det) | fixed | 1/s | accumulation | dots |
| TimeSpeed | NORMAL | ×0.15/0.35/0.65 | — | dt | wave speed feel |
| Step | — | dt=1/60 | s | advance | — |
| Tools | tape/stopwatch/plots | — | μm/nm | none | overlays |
| Snapshot | 0 | max 4 | — | PDF or hits | dialog |

---

## Single Particles

| Control | Default | Range | Unit | Model effect | Visual |
|---|---|---|---|---|---|
| Emit | — | one if idle | — | start packet | packet |
| Auto Repeat | false | bool | — | chain emissions | — |
| Speeds / λ / slits | same table as HI | same as HI | — | packet k, geometry | — |
| Detection mode | hits（固定） | — | — | always hits | dots |
| Probe | ready | pos[0,1]²；r[0.06,0.3] | frac | Bernoulli + projection | circle/% |
| TimeSpeed | NORMAL | ×0.15/0.7/**16** | — | dt | — |
| Min emit interval | 0.3 | fixed | s | rate limit | — |

---

## Photon color mapping（源码）

1. **渲染**：`VisibleColor.wavelengthToColor`（scenery-phet；非手写 red=long）
2. **A11y/标签色带**（`WavelengthColorUtils.getWavelengthColorZone`）：
   - ≤450 violet；≤485 blue；≤500 indigo；≤565 green；≤590 yellow；≤625 orange；else red

Matter wave 基色 RGB `(200,200,200)`（`WaveRasterizer`）。