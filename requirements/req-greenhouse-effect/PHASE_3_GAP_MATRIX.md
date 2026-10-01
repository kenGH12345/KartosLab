# PHASE_3_GAP_MATRIX · Greenhouse Effect

> Date: 2026-09-21 · Source `@ 6c84ad0f` vs Flutter Phase 2

| Feature | Source | Flutter (pre-P3) | Gap | Priority |
|---|---|---|---|---|
| Wave attenuation / intensityChanges | Full `Wave` + `WaveAttenuator` | Simple sine, constant intensity | Missing attenuators & intensity segments | **P1** |
| Flux Meter chrome | Panel, 4 arrows, zoom, drag altitude | Readout + altitude line | Missing panel/arrows/zoom/drag | **P1** |
| Energy Legend | Wave or Photon icons by screen | Absent | Missing | **P1** |
| Time Period UI | BY_VALUE / BY_DATE + Ice Age/1750/1950/2020 | Model only; no date UI | Missing UI + landscape switch | **P1** |
| Energy Balance | Panel In/Out/Net from flux rates | Label only | Missing plot/panel | **P1** |
| Surface Temperature | Checkbox + glow + thermometer | Thermometer text always-ish | Partial | **P1** |
| Temperature Units | K / °C / °F | Display only °C default | Missing selector | **P1** |
| Cloud | Checkbox; reflection in model | Toggle + ellipse | Partial visual | P2 |
| More Photons | Checkbox; showState only | Checkbox present | OK functionally | P2 |
| Solar Intensity | Layer Model slider 0.5–2 | Present | OK | P2 |
| Surface Albedo | Layer Model control | Present | OK | P2 |
| Absorbing Layers | 0–3 + absorbance | Present | OK | P2 |
| Landscape by date | 4 period artworks | Always 2020 art | Missing switch | **P1** |
| Layer thermometers | Show temp on layers | Lines only | Partial | P1/P2 |
| Screen separation | 3 Screens | Tabs (acceptable interim) | VERSION_DELTA | P2 |

**Phase 3 target:** clear all **P1** rows functionally + visually enough for **READY CANDIDATE** (no Home).

## Post-Phase-3 resolution

| Feature | Result |
|---|---|
| Wave attenuation | **PASS** — attenuators + intensity-segment paint |
| Flux Meter chrome | **PASS** — panel, 4 channels, zoom, altitude |
| Energy Legend | **PASS** — screen-specific wave/photon icons |
| Time Period UI | **PASS** — BY_VALUE / BY_DATE + landscape switch |
| Energy Balance | **PASS** — In/Out/Net from model rates |
| Surface Temperature / Units | **PASS** |
| Landscape by date | **PASS** — 4 period asset pairs |
| Layer controls | **PASS** |

**P1 remaining after Phase 3: 0**
