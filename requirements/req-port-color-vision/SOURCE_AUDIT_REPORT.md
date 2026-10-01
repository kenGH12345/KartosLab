# Color Vision — Phase 0 Source Audit Report

> **req-id**: `req-port-color-vision`  
> **Audit date**: 2026-09-22  
> **Auditor**: KartosLab Flutter migration agent  
> **Priority order used**: Local PhET source → original assets → user screenshots → online sim → Flutter convenience

---

## 1. Source version

| Field | Value |
|-------|-------|
| Package name | `color-vision` |
| `package.json` version | **1.4.0-dev.0** |
| `dependencies.json` comment | color-vision **1.3.0-dev.5** (Fri Sep 27 2024) |
| Local tree SHA (`dependencies.json`) | `fb9da1b9d610746b61f5c25a41fe803e68867d9c` (branch `main`) |
| License | GPL-3.0 |
| Repo | https://github.com/phetsims/color-vision.git |
| Local path | `phet sourses/color-vision-main/color-vision-main` |
| Entry | `js/color-vision-main.js` |
| Screens (confirmed) | **2**: Single Bulb → RGB Bulbs |

### Key dependency SHAs (from `dependencies.json`)

| Repo | SHA (short) |
|------|-------------|
| axon | `edcccbdb` |
| joist | `5a7fe170` |
| scenery | `27d92873` |
| scenery-phet | `ad2afb03` |
| sun | `b6b4502c` |
| tambo | `95fb8462` |
| phet-core | `bfcfa8d4` |

Local `scenery-phet` VisibleColor available at:  
`phet sourses/scenery-phet/js/VisibleColor.ts`

---

## 2. Simulation structure

```
Sim(color-vision)
 ├── SingleBulbScreen  → SingleBulbModel + SingleBulbScreenView
 └── RGBScreen         → RGBModel + RGBScreenView
```

### Class hierarchy

```
ColorVisionModel (abstract base)
 ├── playingProperty: BooleanProperty(true)
 ├── headModeProperty: StringProperty('no-brain')  // 'brain' | 'no-brain'
 ├── perceivedColorProperty: DerivedProperty (subtype)
 ├── reset() / abstract manualStep()
 │
 ├── SingleBulbModel
 │     lightType, beamType, flashlightWavelength, filterWavelength,
 │     flashlightOn, filterVisible, lastPhotonColor, photonBeam, eventTimer
 │
 └── RGBModel
       red/green/blueIntensity, perceivedRed/Green/BlueIntensity,
       red/green/blueBeam, eventTimers
```

### ScreenView hierarchy

```
ColorVisionScreenView (shared chrome)
 ├── PerceivedColorNode (thought bubbles)
 ├── TimeControlNode (play/pause + step → model.manualStep)
 ├── ResetAllButton (radius 18 → model.reset)
 │
 ├── SingleBulbScreenView
 │     flashlight, wires, wavelength sliders, filter, radios,
 │     SolidBeamNode, SingleBulbPhotonBeamNode, HeadNode
 │
 └── RGBScreenView
       3× FlashlightAndBeamNode, 3× RGBSlider, RGBPhotonBeamNodes, HeadNode
```

### layoutBounds (both screens)

`Bounds2(0, 0, 768, 504)`  
`CENTER_Y_OFFSET = -20` → content baseline Y ≈ **232**

---

## 3. Model files (authoritative)

| File | Role |
|------|------|
| `js/common/model/ColorVisionModel.js` | Base: playing, headMode |
| `js/common/ColorVisionConstants.js` | BEAM_HEIGHT, X_VELOCITY, FAN_FACTOR, radio styles |
| `js/singlebulb/model/SingleBulbModel.js` | Single Bulb state + perceived color |
| `js/singlebulb/model/SingleBulbPhotonBeam.js` | Photon pool, filter transmission, lastPhotonColor |
| `js/singlebulb/model/SingleBulbPhoton.js` | Photon + isWhite / wavelength / intensity |
| `js/singlebulb/SingleBulbConstants.js` | BEAM_LENGTH=280, GAUSSIAN_WIDTH=70 |
| `js/rgb/model/RGBModel.js` | RGB intensities + additive perceived color |
| `js/rgb/model/RGBPhotonBeam.js` | Per-channel photon beam |
| `js/rgb/model/RGBPhoton.js` | Position / velocity / intensity |
| `js/rgb/model/RGBPhotonEventModel.js` | Rate = intensity×2 events/sec |
| `js/rgb/RGBConstants.js` | Beam lengths 300 / 250 / 330 |

---

## 4. View files (authoritative)

| File | Role |
|------|------|
| `js/common/view/ColorVisionScreenView.js` | Shared chrome, layoutBounds |
| `js/common/view/HeadNode.js` | Exterior/Interior head + beam layering |
| `js/common/view/PerceivedColorNode.js` | 4 thought-bubble ellipses |
| `js/common/view/FlashlightNode.js` | Vector flashlight (icons only) |
| `js/common/view/FlashlightAndBeamNode.js` | RGB flashlight composite |
| `js/singlebulb/view/SingleBulbScreenView.js` | Single Bulb layout |
| `js/singlebulb/view/SolidBeamNode.js` | Continuous beam geometry/color |
| `js/singlebulb/view/SingleBulbPhotonBeamNode.js` | Canvas 3×2 photon rects |
| `js/singlebulb/view/FlashlightWithButtonNode.js` | Flashlight + red on/off button |
| `js/singlebulb/view/GaussianWavelengthSlider.js` | Filter color + gaussian clip |
| `js/singlebulb/view/FlashlightWireNode.js` | Wire to bulb slider |
| `js/singlebulb/view/FilterWireNode.js` | Wire + OnOffSwitch for filter |
| `js/singlebulb/view/FilterHalfEllipse.js` | Colored filter fill overlay |
| `js/rgb/view/RGBScreenView.js` | RGB layout |
| `js/rgb/view/RGBSlider.js` | Vertical 0–100% intensity slider |
| `js/rgb/view/RGBPhotonBeamNode.js` | RGB photon canvas |

---

## 5. Default states

### Shared (`ColorVisionModel`)

| Property | Default |
|----------|---------|
| `playingProperty` | `true` |
| `headModeProperty` | `'no-brain'` (Exterior View) |

### Single Bulb

| Property | Default | Notes |
|----------|---------|-------|
| `lightTypeProperty` | `'colored'` | Monochromatic (not white) |
| `beamTypeProperty` | `'beam'` | Solid beam |
| `flashlightWavelengthProperty` | **570 nm** | Yellow |
| `filterWavelengthProperty` | **570 nm** | Yellow |
| `flashlightOnProperty` | **false** | Matches user screenshots |
| `filterVisibleProperty` | **false** | Filter off until toggle |
| `lastPhotonColorProperty` | transparent black | Photon-mode perceived color |

### RGB Bulbs

| Property | Default |
|----------|---------|
| `redIntensityProperty` | **0** |
| `greenIntensityProperty` | **0** |
| `blueIntensityProperty` | **0** |
| `perceivedRed/Green/BlueIntensity` | **0** |

Matches user screenshots: dark thought bubbles, no beams, Exterior selected, Monochromatic+Beam selected, flashlight off.

---

## 6. Color algorithms (must migrate exactly)

### 6.1 `VisibleColor.wavelengthToColor` (scenery-phet)

- Range: **380–780 nm**
- Piecewise linear RGB segments (380–440, 440–490, 490–510, 510–580, 580–645, 645–780)
- `reduceIntensityAtExtrema: true` (default): falloff below 420 and above 645
- Output: `round(255 * intensity * channel)`
- **Flutter already has equivalent**: `lib/bending_light/physics/visible_color.dart` → `visibleColorArgb`
- **Do NOT** use the coarser HSV rainbow in `lib/common/controls/spectrum_slider.dart` for Color Vision physics

### 6.2 Single Bulb `perceivedColorProperty` (beam mode)

```
!flashlightOn                          → BLACK
filterVisible && lightType==colored    → wavelengthToColor(flashλ).withAlpha(α)
                                         α=0 outside ±35nm; else 1-|Δλ|/35
filterVisible && lightType==white      → wavelengthToColor(filterλ)
!filterVisible && lightType==white     → WHITE
else                                   → wavelengthToColor(flashλ)
```

Photon mode: use `lastPhotonColorProperty` (updated when photons exit beam bounds).

### 6.3 Filter photon transmission (`SingleBulbPhotonBeam`)

- `GAUSSIAN_WIDTH = 70` → half-width **35 nm**
- Colored photon: probability `1 - |Δλ|/35` (0 outside band)
- White photon: probability **0.5** (aesthetic choice in source)
- Surviving white photon → recolored to filter wavelength (keeps full intensity via `wasWhite`)
- Surviving colored: `intensity = max(probability, 0.2)` (floor for visibility)
- Absorbed → removed; if none pass, emit black photon to reset perceived color
- Flashlight off → emit black photon to clear perceived color

### 6.4 RGB additive mixing

```
perceivedColor = Color(
  floor(perceivedRed   * 2.55),
  floor(perceivedGreen * 2.55),
  floor(perceivedBlue  * 2.55)
)
```

Perceived channel intensities come from the **most recent photon** that reaches the eye (end of beam), **not** from instantaneous slider values. Intensity 0 emits a black photon (intensity 0) to decay perceived color to black.

---

## 7. Photon / animation logic

| Constant | Value | Meaning |
|----------|-------|---------|
| `BEAM_HEIGHT` | 130 | Photon canvas height |
| `X_VELOCITY` | **-240** | px/s (leftward; constant x-velocity) |
| `FAN_FACTOR` | 1.05 | Y fan spread |
| Photon draw size | **3×2** | fillRect |
| Single Bulb spawn rate | **120** events/s | `ConstantEventModel(120)` |
| RGB spawn rate | `intensity * 2` /s | `RGBPhotonEventModel` |
| `dt` cap | **0.5** s | Anti-spiral |
| `manualStep` | **1/60** s | Pause step |

Beam lengths:

| Beam | Length |
|------|--------|
| Single | 280 |
| RGB Red | 300 |
| RGB Green | 250 |
| RGB Blue | 330 |

`filterOffset` set from view: `filterLeftNode.centerX - PHOTON_BEAM_START` (`PHOTON_BEAM_START = 320`).

Y spawn:

```
yVelocity = (random * FAN_FACTOR - FAN_FACTOR/2) * 60
initialY  = yVelocity * (25/60) + BEAM_HEIGHT/2
y         = initialY + yVelocity * timeElapsed
```

---

## 8. Beam mode (SolidBeamNode)

- Visible only when `flashlightOn && beamType === 'beam'`
- Geometry: trapezoid/triangle fan; cut at filter center when filter on
- `DEFAULT_BEAM_ALPHA = 0.8`
- Left of filter → perceived color; right → source color; filter off → whole beam
- White + filter on: left = filter λ, right = white

---

## 9. Exterior / Interior View

| `headMode` | UI label | Back asset | Front asset |
|------------|----------|------------|-------------|
| `'no-brain'` | Exterior | `head.png` | `headFront.png` |
| `'brain'` | Interior | `silhouette.png` | `silhouetteFront.png` |

Layering (critical):  
back head → photon/beam nodes → front head (nose cutout covers photons entering eye) → mode radios.

Thought bubbles (`PerceivedColorNode`): 4 ellipses, stroke `#c0b9b9`, fill = `perceivedColorProperty`.

---

## 10. Controls inventory

### Single Bulb

| Control | Type | Source |
|---------|------|--------|
| Bulb Color | Spectrum slider (track 200×30, thumb 30×40) | scenery-phet SpectrumSlider* |
| White / Monochromatic | RectangularRadioButtonGroup | icons PNG |
| Beam / Photons | RectangularRadioButtonGroup | icons PNG |
| Flashlight on/off | Red round sticky button r=15 | FlashlightWithButtonNode |
| Filter Color | GaussianWavelengthSlider | custom + WavelengthSpectrumNode |
| Filter on/off | OnOffSwitch on FilterWireNode | sun |
| Exterior / Interior | Radio on HeadNode | head/silhouette icons |
| Play/Pause + Step | TimeControlNode | joist/scenery-phet |
| Reset All | ResetAllButton **radius 18** | scenery-phet |

### RGB Bulbs

| Control | Type |
|---------|------|
| R/G/B intensity | Vertical RGBSlider 0–100%, default 0 |
| Exterior / Interior | Same HeadNode radios |
| Play/Pause + Step | Same |
| Reset All | Same radius 18 |

No per-flashlight on/off on RGB — intensity 0 = off.

---

## 11. Layout constants (key numbers)

### Shared chrome

| Element | Position |
|---------|----------|
| PerceivedColorNode | left:20, top:5 |
| TimeControlNode | bottom:484, centerX:381 |
| ResetAllButton | bottom:499, right:738, **r=18** |

### Single Bulb

| Element | Position / scale |
|---------|------------------|
| Flashlight | centerY≈235, right:728, scale **0.85** |
| Bulb slider | top:40, right:698 |
| Filter PNGs | centerY:232, scale **0.7**, right: flashlight.left-100 |
| Photon beam canvas | x:320, size 280×130, centerY:232 |
| Filter slider | bottom:484, right:698 |

### RGB

| Element | Position |
|---------|----------|
| Red beam | x:280,y:190, rot **-π/6**, len 300 |
| Green beam | x:320, centerY:232, rot 0, len 250 |
| Blue beam | x:320,y:145, rot **+π/6**, len 330 |
| Flashlights VBox | spacing 85, right:684, centerY:232, scale **0.73** |
| Sliders VBox | spacing 15, right:738 |

---

## 12. Assets (original — must reuse)

### Images (`images/`) — intrinsic sizes measured 2026-09-22

| File | Size | Used by |
|------|------|---------|
| `flashlight0Deg.png` | 173×67 | Single Bulb; RGB green |
| `flashlightNeg45Deg.png` | 177×131 | RGB red |
| `flashlightPos45Deg.png` | 178×129 | RGB blue |
| `filterLeft.png` | 74×194 | Filter left shell |
| `filterRight.png` | 74×194 | Filter right shell |
| `head.png` / `headFront.png` | 300×434 | Exterior |
| `silhouette.png` / `silhouetteFront.png` | 296×427 | Interior |
| `headIcon.png` | 44×63 | Exterior radio |
| `silhouetteIcon.png` | 42×62 | Interior radio |
| `beamViewIcon.png` / `photonViewIcon.png` | 43×43 | Beam mode radios |
| `whiteLightIcon.png` / `singleColorLightIcon.png` | 43×43 | Light type radios |
| `flashlightIcon.png` | — | Home/nav icons |

### Sounds (`sounds/`)

Ambient + note/chord MP3 JS modules. Main launch **mutes** `sim-specific` output level to 0 (`color-vision-main.js`). Flutter Phase 1–5: sound optional / deferred; do not block visual/behavior READY on sound.

### Artwork source (`assets/`)

AI source files (Flashlights, Heads, Artwork) — not runtime; PNGs are the runtime assets.

**Target**: `Substituted Assets = 0`

---

## 13. Pause / Step / Reset

| Action | Behavior |
|--------|----------|
| Pause | `playingProperty = false` → `step(dt)` skips photon updates & event timers |
| Step | `manualStep()` advances beams + timers by **1/60 s** regardless of playing |
| Reset All | Resets all model Properties to defaults + clears photon arrays |

---

## 14. Existing Flutter codebase assessment

| Path | Verdict |
|------|---------|
| `lib/color_vision/` | **NOT** a faithful PhET port — Magic Lab / challenge / cauldron demo |
| Home entry | Already under 光学与波动 →「色觉」→ `ColorVisionHome` |
| Reusable | Photon pool idea; `visibleColorArgb` from bending_light |
| Must rewrite | Screens, painters, model state machine, assets, Reset All |
| Strategy | **Rewrite** screens/model/view; keep Home hook; isolate/remove Magic Lab UI |

---

## 15. Migration plan implications

### Flutter target structure

```
lib/color_vision/
  model/          # SingleBulbModel, RGBModel, photons, beams, VisibleColor bridge
  view/           # ScreenViews, painters, head, beams
  screens/        # ColorVisionHome (Single Bulb | RGB Bulbs tabs)
  widgets/        # PhET-style controls (spectrum, gaussian, RGB slider, radios)
  assets/         # copied original PNGs under assets/simulations/color_vision/
```

### Hard rules for this sim

1. Reset All → `KratosResetAllButton` with **radius: 18** (PhET source, not default 20.5)
2. Wavelength → `visibleColorArgb` / scenery-phet algorithm only
3. All PNGs from `images/` via `Image.asset` — no Material Icons
4. Photons via CustomPainter, not Widget-per-photon
5. Perceived color chain must match §6 exactly

---

## 16. Unresolved questions

| # | Question | Impact | Proposed resolution |
|---|----------|--------|---------------------|
| UQ-1 | Sound generators (PerceivedColorSoundGenerator) in Flutter? | P2 | Defer; PhET main already mutes sim-specific |
| UQ-2 | Exact filterOffset after scale — depends on PNG layout | P1 layout | Compute from measured sizes × 0.7 like source |
| UQ-3 | SolidBeamNode Bounds2 arg order quirk | Beam geometry | Explicit min/max in Flutter |
| UQ-4 | Keep Magic Lab as hidden/extra tab? | Scope | **No** — replace with PhET tabs; archive/delete Magic Lab UI |
| UQ-5 | Home title currently「色觉 / RGB 合成 · 滤光」 | Copy | Update subtitle to「Single Bulb · RGB Bulbs」in Phase 7 |
| UQ-6 | Accessibility / PDOM / keyboard help | P2 | Defer after visual READY CANDIDATE |
| UQ-7 | GaussianWavelengthSlider scenery-phet SpectrumSliderTrack exact pixels | Visual | Port from scenery-phet sources in Phase 2/4 |

---

## 17. Phase 0 gate checklist

- [x] Screens confirmed (2)
- [x] Models / Views / Constants mapped
- [x] Defaults match screenshots (flashlight off, 570nm, Exterior, Beam, Monochromatic, RGB=0)
- [x] Color / filter / photon / RGB mixing algorithms extracted
- [x] Assets inventoried with intrinsic sizes
- [x] Pause / Step / Reset semantics documented
- [x] Existing Flutter gap assessed (rewrite required)
- [x] Unresolved questions listed

**Phase 0 Status: PASS** — ready for Phase 1 Model.
