# VIEW_ASSET_AUDIT — Gases Intro Instruments

> Status: P0 audit complete · Physics/Model frozen · View-only reconstruction  
> Local source authority: `gas-properties-for-gases-intro` @ `10c7c08`  
> Classification: **[迁移组件缺失]** / **[行为差异]** / **[迁移布局 bug]** — do **not** use [视觉近似]

---

## 0. Layout Overflow Root Cause (FIXED)

| Item | Detail |
|---|---|
| Symptom | `RIGHT OVERFLOWED BY 11 PIXELS` |
| Classification | **[迁移布局 bug]** |
| False causes ruled out | Not font size; not missing clip; not need for fixed height |
| True cause | `SizedBox(width: 225)` (= `GasPropertiesConstants.RIGHT_PANEL_WIDTH`) **included** outer `margin` (right 8) + inner `padding` (10×2). Content max ≈ **197px**. `_ParticleSpinnerRow` intrinsic width ≈ **206–216px** → overflow ≈ 9–11px |
| Fix | Panel `SizedBox(width: rightPanelWidth)` is **content** width only; outer gap via sibling `SizedBox(width: 8)`. Particles row uses compact IconButtons (`28×28`, shrinkWrap). Home uses `AspectRatio(1008/618)` instead of FixedBox→FittedBox (layout-at-overflow-then-scale) |
| Source scroll | `IdealControlPanel` can exceed height with Hold Constant → Flutter `ListView` on panel |

---

## 1. Instrument Audit Matrix

### 1.1 Pressure Gauge

| Field | Source | Flutter |
|---|---|---|
| Source Node | `PressureGaugeNode` (gas-properties) wraps scenery-phet geometry | `PressureGaugeInstrument` + `GaugePainter` |
| Source file | `gas-properties/.../PressureGaugeNode.ts` + scenery-phet gauge | `lib/gases_intro/widgets/instruments.dart`, `painters/gauge_painter.dart` |
| Asset | **None** — dial/ticks/needle are **Path geometry** | CustomPainter (allowed: source is geometry) |
| Children | dial face, tick marks, needle, center pin, pressure read-out | painted dial + needle + kPa text |
| Transform | needle angle from pressure Property | `needleAngle = f(displayedPressureKpa)` |
| Input | none (display only) | none |
| Model binding | `pressureProperty` / displayed pressure | `IdealGasLawModel.renderData.displayedPressureKpa` |
| Gap class | residual tick/label fidelity → **[迁移组件缺失]** until pixel QA pass |

### 1.2 Thermometer

| Field | Source | Flutter |
|---|---|---|
| Source Node | `ThermometerNode` / gas-properties temperature display | `ThermometerInstrument` + `ThermometerPainter` |
| Source file | scenery-phet `ThermometerNode` + Ideal screen wiring | `instruments.dart`, `thermometer_painter.dart` |
| Asset | **None** — tube/bulb/mercury geometry | CustomPainter (geometry) |
| Children | tube, bulb, fluid fill, ticks, optional label | tube + bulb + fill height from T |
| Transform | fill ∝ temperature | `fillFraction = f(temperatureK)` |
| Input | **not** a slider | display only (correct) |
| Model binding | `temperatureProperty` | `renderData.temperatureK` |
| Gap class | scale labels / placement → **[迁移组件缺失]** |

### 1.3 “Piston” — **DOES NOT EXIST**

| Field | Source | Flutter |
|---|---|---|
| Source Node | **Movable left wall** + `HandleNode` — Ideal: `leftWallDoesWork = false` | Left-wall handle hit + `PlayAreaPainter` wall |
| Source file | `IdealGasLawModel` / `BaseContainerNode` / handle drag | `play_area_painter.dart`, `_PlayCanvas` GestureDetector |
| Asset | Handle geometry (scenery HandleNode), not piston PNG | Drawn handle + opaque hit rect |
| Children | left wall, handle grip, width readout (optional) | wall line + handle + drag |
| Transform | wall x ↔ container width / volume | `setWidth(width - dx/scale)` |
| Input | horizontal drag; pause+redistribute on release (Ideal) | `beginWidthAdjust` / `setWidth` / `endWidthAdjust` |
| Model binding | width → Volume → P,T via IdealGasLawModel | same frozen model API |
| Gap class | Calling it “piston” is **[行为差异]** documentation error — **must not invent piston geometry** |

### 1.4 Pump

| Field | Source | Flutter |
|---|---|---|
| Source Node | `GasPropertiesBicyclePumpNode` / scenery-phet `BicyclePumpNode` | `BicyclePumpWidget` + `BicyclePumpPainter` |
| Source file | gas-properties bicycle pump + scenery-phet paths | `instruments.dart` |
| Asset | **None** for body — Path geometry; hose/nozzle painted | CustomPainter (geometry) |
| Children | body, handle, hose, hose attachment, particle-type color | body/handle/hose paths; color from Heavy/Light |
| Transform | handle Y drag → stroke | `_handleT` + accum → `model.pump()` |
| Input | vertical drag; +50 particles / stroke | same |
| Model binding | pump → particle inject velocity/type | `IdealGasLawModel.pump()` |
| Gap class | hose→container nozzle alignment → **[迁移组件缺失]** |

### 1.5 Heater / Cooler

| Field | Source | Flutter |
|---|---|---|
| Source Node | `HeaterCoolerNode` (scenery-phet) under container | `HeaterCoolerWidget` |
| Source file | scenery-phet heater + Ideal screen position | `instruments.dart` |
| Asset | **Yes**: `flame.png`, `iceCubeStack.png` | `assets/gases_intro/flame.png`, `iceCubeStack.png` |
| Children | stove body, heat zone, cool zone, flame/ice overlays | stove CustomPaint + asset overlays |
| Transform | slider/finger → heatCool factor ∈ [-1,1] | drag → `model.setHeatCoolFactor` |
| Input | vertical control; disabled when paused | `model.isPlaying` gate |
| Model binding | `v *= 1 + f/800` in model | frozen model |
| Gap class | stove chrome vs source → **[迁移组件缺失]** |

### 1.6 Particles

| Field | Source | Flutter |
|---|---|---|
| Source Node | `ParticlesNode` / shaded spheres | `PlayAreaPainter` + `shaded_sphere.dart` |
| Source file | gas-properties particle view | `play_area_painter.dart` |
| Asset | **None** — radius circles + 3D-ish shading | geometry CustomPainter |
| Children | Heavy (purple, 125 pm), Light (orange-red, 87.5 pm) | colors/radii from constants |
| Transform | nm → play-area pixels via layout scale | `PlayAreaLayout` |
| Input | none on particle glyphs | — |
| Model binding | particle list from model | `renderData.particles` |
| Gap class | wall collision flash (if any) → verify vs source **[行为差异]** if missing |

### 1.7 Container

| Field | Source | Flutter |
|---|---|---|
| Source Node | `BaseContainerNode` / Ideal container | `PlayAreaPainter` container paths |
| Source file | gas-properties container nodes | `play_area_painter.dart`, `PlayAreaLayout` |
| Asset | geometry walls + optional lid | drawn walls / lid / clip region |
| Children | top, bottom, left (movable), right, interior clip, lid | same logical parts |
| Transform | width property → left wall x | layout mapping |
| Physics vs Visual | collision bounds ≠ decorative stroke | Model container vs painter stroke **separated** |
| Gap class | lid explosion / return lid chrome → **[迁移组件缺失]** residual |

---

## 2. Asset → Source → Flutter Map

| Asset / Resource | Source | Flutter Asset | Flutter Component |
|---|---|---|---|
| flame.png | gas-properties / scenery-phet heater | `assets/gases_intro/flame.png` | `HeaterCoolerWidget` |
| iceCubeStack.png | same | `assets/gases_intro/iceCubeStack.png` | `HeaterCoolerWidget` |
| eraser.svg | erase particles control | `assets/gases_intro/eraser.svg` | toolbar IconButton |
| resetArrow.png | Reset All | `assets/gases_intro/resetArrow.png` | `_TimeBar` |
| Gauge dial/needle | scenery-phet Paths | *(geometry)* | `GaugePainter` |
| Thermometer | scenery-phet Paths | *(geometry)* | `ThermometerPainter` |
| Bicycle pump | scenery-phet Paths | *(geometry)* | `BicyclePumpPainter` |
| Particles | shaded Sphere nodes | *(geometry)* | `shaded_sphere` |
| Left-wall handle | HandleNode Paths | *(geometry)* | painter + hit rect |
| Piston PNG | **N/A — not in Gases Intro** | — | **must not add** |

---

## 3. Control Panel Hierarchy (source-aligned)

| Source block | Flutter |
|---|---|
| Hold Constant (Laws only) | `_ControlPanel` radio list when `showHoldConstant` |
| Width checkbox | CheckboxListTile |
| Stopwatch checkbox | CheckboxListTile |
| Collision Counter checkbox | CheckboxListTile |
| Particles accordion | section + Fine/Coarse ±1/±50 spinners |
| Panel width | 225 content px |
| Overflow height | `ListView` scroll |

---

## 4. Data Flow (View bindings only)

```
Pointer (handle) → beginWidthAdjust/setWidth/endWidthAdjust → Volume → GasModel → P/T → Gauge/Thermometer
Pointer (pump)   → model.pump() → particles + velocities → Render
Pointer (heat)   → setHeatCoolFactor → kinetic scale → T/P → Instruments
UI Particles     → setNumberHeavy/Light → ParticleSystem → Render
```

Physics solvers unchanged (frozen).

---

## 5. Error Classification Log

| Issue | Class |
|---|---|
| RIGHT OVERFLOWED BY 11px | **[迁移布局 bug]** — fixed |
| Fake “piston” naming / inventing piston | **[行为差异]** — corrected to left-wall Handle |
| Gauge/thermometer/pump as CustomPaint | OK when source is geometry; residual fidelity = **[迁移组件缺失]** |
| Missing PNG/SVG when source has file | **[迁移组件缺失]** |
| Slider-as-thermometer | **[行为差异]** — not used |
| Parameter-dashboard instead of play-area instruments | **[交互呈现不完整]** — addressed by shell structure |
