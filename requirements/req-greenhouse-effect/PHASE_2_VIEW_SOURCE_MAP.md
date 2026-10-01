# PHASE_2_VIEW_SOURCE_MAP · Greenhouse Effect

> Source: `phet sourses/greenhouse-effect-main/greenhouse-effect-main` @ `6c84ad0f`  
> Date: 2026-09-21

---

## Screens (entry)

`greenhouse-effect-main.ts` launches **three** screens (no Micro):

1. `WavesScreen` → `WavesModel` + `WavesScreenView`
2. `PhotonsScreen` → `PhotonsModel` + `PhotonsScreenView`
3. `LayerModelScreen` → `LayerModelModel` + `LayerModelScreenView`

Shared chrome: `GreenhouseEffectScreenView` + `GreenhouseEffectObservationWindow`.

---

## Node tree (common)

```
GreenhouseEffectScreenView  (joist ScreenView default layoutBounds ≈ 1024×618)
├── observationWindow (780×525 @ left/top margins 15/10)
│   ├── backgroundLayer   (landscape bg, sky/ground)
│   ├── presentationLayer (photons / waves / cloud)
│   ├── controlsLayer     (instruments)
│   └── foregroundLayer   (start sunlight, thermometer overlays)
├── clippingFrame (optional; Photons uses WebGL clip workaround)
├── legendAndControlsVBox
│   ├── EnergyLegend
│   └── screen-specific panels (Concentration / Sun+Layers)
├── timeControlNode (Normal/Slow, Play/Pause, Step → stepModel(1/60))
└── resetAllButton
```

### Waves extras
ConcentrationControlPanel, CloudCheckbox, SurfaceThermometerCheckbox, SurfaceTemperatureCheckbox.

### Photons extras
ConcentrationControlPanel, CloudCheckbox, MorePhotonsCheckbox, FluxMeter (model+view).

### Layer Model extras
SunAndReflectionControl, LayersControl, TemperatureUnitsSelector, MorePhotonsCheckbox, FluxMeter, visible atmosphere panes.

---

## Viewport / MVT

| Constant | Value | Source |
|---|---|---|
| Observation SIZE | **780 × 525** | `GreenhouseEffectObservationWindow` |
| `GROUND_VERTICAL_PROPORTION` | **0.25** | same |
| groundHeight in view | `525 * 0.25 / 2` | perspective band |
| MVT | `createSinglePointScaleInvertedYMapping(ZERO → (390, 525−groundHeight), scale=(525−groundHeight)/50000)` | same |
| Screen margins | X=15, Y=10 | `GreenhouseEffectConstants` |
| Right spacing | 12 | same |

Flutter: `GreenhouseModelViewTransform` mirrors this exactly. Model stays in meters; pixels only in view.

---

## Model additions required by View

| Class | Role |
|---|---|
| `Photon` / `PhotonCollection` / `PhotonAbsorbingEmittingLayer` | Photons + Layer Model particle radiation |
| `WavesModel` + `GreenhouseWave` | Waves screen propagation (clock-driven) |
| `LayerModelModel` | 3 layers, IR absorbance, sun proportion, albedo |
| `FluxMeter` / `FluxSensor` | Flux sampling of EMEnergyPackets |

---

## Assets reused (original PNGs)

Copied to `assets/greenhouse_effect/`:

- `twentyTwentiesLandscapeBackground/Foreground.png`
- `iceAgeLandscape*` (available; UI can switch later)
- `visiblePhoton.png`, `infraredPhoton.png`
- `unadornedLandscape.png`

Substituted icons for sun/controls: **none** of Material weather icons; Start Sunlight is a painted button (PhET `TextPushButton` equivalent chrome, not `Icons.wb_sunny`).

---

## Interaction map

| Control | Model |
|---|---|
| Start Sunlight | `sunEnergySource.isShining` |
| GHG slider | `manuallyControlledConcentration` |
| Cloud | `cloudEnabled` |
| Flux meter checkbox | `fluxMeterVisible` |
| More photons | `photonCollection.showAllSimulatedPhotons` |
| IR absorbance / layer count / sun | `LayerModelModel` setters |
| Pause / Slow / Step / Reset | base `GreenhouseEffectModel` + screen resets |
