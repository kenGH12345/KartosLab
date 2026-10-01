# PHASE_3_VISUAL_MATRIX · Greenhouse Effect

> Date: 2026-09-21 · Source `@ 6c84ad0f` · Flutter Phase 3

| Screen | State | Layout | Objects | Animation | Controls | Status |
|---|---|---|---|---|---|---|
| Waves | Initial | Observation 780×525 + side panel | Landscape (by mode), Energy Legend (wave icons) | Clock idle until Start Sunlight | Conc BY_VALUE, Cloud, Energy Balance, Thermometer, Units | **PASS** |
| Waves | Playing | Same | Sunlight + IR waves with attenuation | Wave length/phase from model clock | Start Sunlight toggles shine | **PASS** |
| Waves | Cloud on | Same | Cloud oval + VIS attenuator | Intensity drops past cloud | Cloud checkbox | **PASS** |
| Waves | By date Ice Age | Ice Age landscape assets | Glacier albedo | Conc from date map | Ice Age / 1750 / 1950 / 2020 | **PASS** |
| Photons | Initial | Same + photon legend | Photon assets | — | Conc + More Photons + Flux Meter | **PASS** |
| Photons | More Photons | Same | Higher displayed photon density | showAll flag only (energy unchanged) | More Photons checkbox | **PASS** |
| Photons | Flux Meter | Sensor line + panel chrome | Vis↓/Vis↑/IR↓/IR↑ arrows, zoom, altitude | Rates from EMEnergyPacket crossings | Flux meter toggle | **PASS** |
| Layer | 0 layers | Layer lines hidden when inactive | 2020 meadow art | Photons optional | Absorbance / layers / solar / albedo | **PASS** |
| Layer | 3 layers | Active layer lines + K labels | Layer temps from model | Absorbance shared | Layer count slider 0–3 | **PASS** |
| Layer | High absorbance | Same | Stronger IR absorption | Model binding | IR absorbance slider | **PASS** |
| All | Energy Balance on | Panel overlay TOA In/Out/Net | Bars from energyComingFromSun / energyGoingIntoSpace | Updates each step | Energy balance checkbox | **PASS** |

### Visual notes

- `[原版资源一致]` Ice Age / agricultural / fifties / twentyTwenties landscape PNGs + visible/infrared photon PNGs
- `[布局已对齐]` Observation window size locked to PhET MVT constants
- `[动态绘制已对齐]` Waves use `intensityAt(distance)` segments; Flux altitude from sensor; Energy Balance from model rates
- Remaining **P2**: scenery-phet Panel bevel/shadow, exact Flux arrow geometry, thermometer graphic (text readout only)

**Substituted assets = 0**
