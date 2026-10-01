# PHASE 0 — SOURCE AUDIT / Migration Blueprint

**Sim:** PhET Under Pressure → Flutter (KartosLab)  
**Req id:** `req-port-under-pressure`  
**Local thin shell:** `phet sourses/under-pressure-main/under-pressure-main`  
**Real implementation (phetLib):** `fluid-pressure-and-flow` → `js/under-pressure/**` + `js/common/**`  
**Audit sources used:**  
1. Local `under-pressure` (launcher / package / README / assets screenshots)  
2. Official GitHub `phetsims/fluid-pressure-and-flow` `main` (raw files — local FPAF zip was incomplete / downloading at audit time)  
3. User-provided original screenshot (square scene)  
4. Official runtime URL (not executed this phase)  

**under-pressure package.json:** `1.2.0-dev.0` · `phetLibs: ["fluid-pressure-and-flow"]`  
**Entry:** `js/under-pressure-main.ts` → imports `UnderPressureScreen` from FPAF  
**Official runtime:** `https://phet.colorado.edu/sims/html/under-pressure/latest/under-pressure_all.html`

---

## PHASE 0 STATUS: PASS

判定依据：

- Production **Joist Screen = 1**（Under Pressure standalone）；内部 **4 Scenes**（非 4 个 Joist Screen）已从 source 确认
- 压力计算链、Atmosphere、Density、Gravity、Units、Depth、Gauge tip、Fluid volume / faucet、Mystery、Layout/MVT 均有 **source class / function 证据**
- Interaction / Clock / Assets inventory / Dependencies / Source tests(0) / Physics Oracle 已规划
- **无未解释的核心 pressure semantics**
- Flutter UI / Home / Runtime / Android：**未开始 / 未触碰 / 未验证**

```text
Flutter UI: NOT STARTED
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

**本地 FPAF：** 审计过程中已下载并解压至 `phet sourses/fluid-pressure-and-flow-main/`（含 `js/under-pressure/**` + `images/`）。Phase 1 应以该目录 + thin shell 为 Source of Truth。

---

## 1. Source Truth 优先级（本审计遵守）

```text
1. Local PhET source (under-pressure + fluid-pressure-and-flow)
2. Local original assets (FPAF images/ + under-pressure assets/ screenshots)
3. User-provided original screenshots
4. Official runtime
5. Inference (仅标注)
```

行为 / 物理 / 状态机 → **source 优先**。  
截图 → layout / visual / spacing / controls 外观。

---

## 2. Critical Architecture Finding

`under-pressure` **不是自包含模拟**。README / `package.json` 明确依赖：

```json
"phetLibs": [ "fluid-pressure-and-flow" ]
```

入口：

```ts
// under-pressure/js/under-pressure-main.ts
import UnderPressureScreen from '../../fluid-pressure-and-flow/js/under-pressure/UnderPressureScreen.js';
new Sim( title, [ new UnderPressureScreen() ], { ... } );
```

同一 `UnderPressureScreen` 也是 **Fluid Pressure and Flow** 三屏套件的 **Screen 1**（另两屏 Flow / Water Tower **不属于** Under Pressure standalone 迁移范围）。

```text
NON-PRODUCTION / OUT OF SCOPE for Under Pressure port:
├── FlowScreen          (FPAF screen 2)
└── WaterTowerScreen    (FPAF screen 3)
```

---

## 3. Official Screen Count / Local Production Screen Count

```text
Official Screen Count (Under Pressure standalone): 1
Local Production Screen Count: 1

Screen 1:
  Class: UnderPressureScreen
  Model: UnderPressureModel
  View:  UnderPressureScreenView
  Name:  FluidPressureAndFlowStrings.underPressureScreenTitle → "Under Pressure"
  Icon:  images/underPressure.png (FPAF)
  Internal scenes (NOT joist screens): square | trapezoid | chamber | mystery
```

### Scene inventory（`currentSceneProperty`）

| Order | Scene key | Model | View | Icon asset |
|------|-----------|-------|------|------------|
| 1 | `square` (default) | `SquarePoolModel` | `SquarePoolView` | `squarePoolIcon.png` |
| 2 | `trapezoid` | `TrapezoidPoolModel` | `TrapezoidPoolView` | `trapezoidPoolIcon.png` |
| 3 | `chamber` | `ChamberPoolModel` | `ChamberPoolView` | `chamberPoolIcon.png` |
| 4 | `mystery` | `MysteryPoolModel` extends Square | `MysteryPoolView` | `mysteryPoolIcon.png` |

Scene 切换 UI：`SceneChoiceNode`（左侧竖排 `RectangularRadioButtonGroup`，`x:10, y:260`）。

---

## 4. Source Structure

```text
under-pressure-main/                    # thin shell ONLY
├── js/
│   ├── under-pressure-main.ts          # Sim entry · 1 screen
│   ├── underPressure.ts                # namespace
│   └── UnderPressureStrings.ts         # title only
├── assets/                             # marketing screenshots only (4 PNG)
├── package.json / dependencies.json / README.md
└── (无 images/ · 无 sounds/ · 无 tests/)

fluid-pressure-and-flow/                # REAL source of truth
├── js/
│   ├── under-pressure/
│   │   ├── UnderPressureScreen.ts
│   │   ├── model/
│   │   │   ├── UnderPressureModel.js      # pressure API + shared props
│   │   │   ├── SquarePoolModel.js
│   │   │   ├── TrapezoidPoolModel.js
│   │   │   ├── ChamberPoolModel.js
│   │   │   ├── MysteryPoolModel.js
│   │   │   ├── PoolWithFaucetsModel.js    # volume + faucet step
│   │   │   ├── FaucetModel.js
│   │   │   └── MassModel.js               # chamber masses
│   │   └── view/                          # ScreenView + scene views + controls
│   ├── common/
│   │   ├── Constants.js                   # layout 768×504, g, density, P atm
│   │   └── model/
│   │       ├── getStandardAirPressure.js
│   │       ├── Units.js
│   │       ├── Sensor.js                  # barometer model
│   │       ├── FluidColorModel.js
│   │       └── VelocitySensor.js          # Flow only — OUT OF SCOPE
│   └── common/view/
│       ├── BarometerNode.js
│       ├── ControlSlider.js
│       ├── UnitsControlPanel.js
│       └── FPAFRuler.js                   # used by Flow/WaterTower; UP uses UnderPressureRuler
├── images/                                # production raster assets
├── assets/                                # design sources (.ai/.psd) + screenshots
├── doc/model.md                           # TODO stub — NOT authoritative
└── doc/implementation-notes.md            # TODO stub — NOT authoritative
```

---

## 5. Architecture Diagram

```text
UnderPressure (standalone Sim)
├── Screens (Joist)
│   └── UnderPressureScreen [ONLY]
│       ├── Model: UnderPressureModel
│       │   ├── Properties (shared)
│       │   │   ├── isAtmosphereProperty (Boolean, default true)
│       │   │   ├── isRulerVisibleProperty / isGridVisibleProperty
│       │   │   ├── measureUnitsProperty ('metric'|'atmosphere'|'english')
│       │   │   ├── gravityProperty / fluidDensityProperty
│       │   │   ├── currentSceneProperty
│       │   │   ├── currentVolumeProperty (derived mirror of scene volume)
│       │   │   ├── rulerPositionProperty
│       │   │   ├── mysteryChoiceProperty ('fluidDensity'|'gravity')
│       │   │   └── accordion expanded props
│       │   ├── sceneModels
│       │   │   ├── square → SquarePoolModel
│       │   │   ├── trapezoid → TrapezoidPoolModel
│       │   │   ├── chamber → ChamberPoolModel (+ MassModel×3)
│       │   │   └── mystery → MysteryPoolModel
│       │   ├── fluidColorModel → FluidColorModel
│       │   ├── barometers[4] → Sensor
│       │   └── Physics API
│       │       ├── getAirPressure(height)
│       │       ├── getWaterPressure(height)
│       │       ├── getPressureAtCoords(x,y)
│       │       └── getPressureString / getGravityString / getFluidDensityString
│       └── View: UnderPressureScreenView
│           ├── BackgroundNode (sky/ground + atmosphere black)
│           ├── SceneChoiceNode
│           ├── Square/Trapezoid/Chamber/Mystery PoolViews
│           ├── ControlPanel (ruler/grid/atmosphere)
│           ├── UnitsControlPanel
│           ├── ControlSlider ×2 (density / gravity)
│           ├── Sensor panel + BarometerNode ×4
│           ├── UnderPressureRuler
│           └── ResetAllButton (radius: 18)
│
├── Shared Models (FPAF common)
│   ├── Constants / Units / Sensor / FluidColorModel / getStandardAirPressure
├── Physics
│   └── UnderPressureModel pressure chain (see §6)
├── Fluid Models
│   └── PoolWithFaucetsModel volume; Chamber displacement
├── Gauge → Sensor + BarometerNode + scenery-phet GaugeNode
├── Controls → ControlPanel / Units / ControlSlider / AtmosphereControlNode
├── Tools → Ruler / Grid / Barometers / Scene icons
├── Assets → FPAF images/ (grass, cement, scene icons, home icon)
├── Audio → NONE
└── Dependencies → axon, dot, kite, scenery, scenery-phet, joist, sun, phet-core, phetcommon, tandem, (+ twixt/tambo via joist stack)
```

---

## 6. Physics Core / Exact Source Calculation Chain

`doc/model.md` 为 `TODO` — **公式以代码为准**。

### Exact Source Calculation Chain

```text
Sensor tip (x, y_tip)   [BarometerNode: position.y + viewToModelDeltaY(bottom-centerY)]
        ↓
UnderPressureModel.getPressureAtCoords(x, y)
        │
        ├─ if y > 0 (above ground / sky):
        │     → getAirPressure(y)
        │
        ├─ else if currentSceneModel.isPointInsidePool(x,y):
        │     waterHeight = currentSceneModel.getWaterHeightAboveY(x,y)
        │     ├─ if waterHeight <= 0:
        │     │     → getAirPressure(y)          // air pocket inside pool above fluid
        │     └─ else:
        │           → getAirPressure(waterHeight + y) + getWaterPressure(waterHeight)
        │
        └─ else:
              → null                            // outside pool underground → no reading
        ↓
barometer.valueProperty (Pa | null)
        ↓
GaugeNode needle (Range MIN_PRESSURE..MAX_PRESSURE) + Units.getPressureString
```

### Step → Source

| Step | Function / Class | Unit | Notes |
|------|------------------|------|-------|
| Air pressure | `getAirPressure(height)` | Pa | If `!isAtmosphere` → **0** |
| Standard atm | `getStandardAirPressure(height)` | Pa | Linear: height 0→150 m maps `101325` → `99490` |
| Gravity scale on air | `* gravity / EARTH_GRAVITY` | — | Atmosphere scales with g |
| Fluid column | `getWaterPressure(h) = h * g * ρ` | Pa | Absolute hydrostatic contribution |
| Combined | air(at surface-ish) + water | Pa | **Absolute pressure** (not gauge pressure) |
| Display | `Units.getPressureString(P, units, abbreviated=false)` | kPa/atm/psi | See §11 |

### Confirmed constants (`Constants.js`)

| Name | Value | Unit |
|------|-------|------|
| `EARTH_GRAVITY` | 9.8 | m/s² |
| `MARS_GRAVITY` | 3.71 | m/s² |
| `JUPITER_GRAVITY` | 24.79 | m/s² |
| `GASOLINE_DENSITY` | 700 | kg/m³ |
| `WATER_DENSITY` | 1000 | kg/m³ |
| `HONEY_DENSITY` | 1420 | kg/m³ |
| `EARTH_AIR_PRESSURE` | 101325 | Pa |
| `EARTH_AIR_PRESSURE_AT_500_FT` | 99490 | Pa |
| `MAX_POOL_HEIGHT` | 3 | m |
| `MIN_PRESSURE` / `MAX_PRESSURE` | 50000 / 250000 | Pa (gauge dial range) |

### Depth definition（确认）

- **Depth / waterHeight** = **竖直液柱高度**：fluid surface Y − sensor tip Y（模型坐标，y 向上为正到地面为 0，池内 y 为负）
- **不是**到池底距离、不是最短几何距离
- **水平位置**：决定 `isPointInsidePool`；液柱高度在 square/trapezoid 对 x 不敏感（表面水平）；chamber 有 left-opening 特例与 `leftDisplacement / lengthRatio` 表面高度

Square:

```js
getWaterHeightAboveY(x,y) =
  poolDimensions.y2 + maxHeight * volume/maxVolume - y
```

Trapezoid:

```js
getWaterHeightAboveY(x,y) =
  maxHeight * volume/maxVolume + bottomChamber.y2 - y
```

Chamber（连通器 / Pascal）:

```js
// left opening above fluid → 0
// else:
poolDimensions.leftChamber.y2 + DEFAULT_HEIGHT(2.3)
  + leftDisplacement / lengthRatio - y
// lengthRatio = RIGHT_OPENING_WIDTH / LEFT_OPENING_WIDTH = 2.3/0.5
```

### Absolute vs Gauge

Source 返回 **absolute pressure in Pascals**（Atmosphere ON 时含大气项）。  
**不是**教科书式 gauge pressure `ρgh` only。  
Atmosphere OFF → `getAirPressure ≡ 0`，水下仍有 `ρgh`。

---

## 7. Atmosphere

| Item | Source |
|------|--------|
| Type | `BooleanProperty` `isAtmosphereProperty` |
| Default | `true` (On) |
| Can turn off | Yes (`AtmosphereControlNode` On/Off AquaRadioButtons) |
| Air value at ground | `getStandardAirPressure(0) = 101325 Pa` when On |
| Height dependence | Linear to 99490 Pa at model height 150 m |
| Gravity coupling | `P_air *= gravity / 9.8` |
| Off | `getAirPressure → 0` |
| Visual | `BackgroundNode`: skyNode vs black rectangle |
| Fluid visual | No density change from atmosphere alone |
| Units | Internal Pa; display via Units conversion |

**禁止自行写死「+101.3 kPa」而不走 `getStandardAirPressure` + gravity scale。**

---

## 8. Fluid Density

| Item | Source |
|------|--------|
| Property | `fluidDensityProperty` |
| Default | `WATER_DENSITY = 1000` |
| Range | `[700, 1420]` = gasoline → honey |
| Presets ticks | gasoline(min), water(1000), honey(max) |
| Step (arrow buttons) | `1` with `decimals: 0` (ControlSlider) |
| Display | `Units.getFluidDensityString`: metric `kg/m³` (0 or 1 decimal); english `lb/ft³` via `62.4/1000` |
| Color | `FluidColorModel.step()` RGB lerp gas↔water↔honey |
| Mystery overrides | See §19 |

---

## 9. Gravity

| Item | Source |
|------|--------|
| Property | `gravityProperty` |
| Default | `EARTH_GRAVITY = 9.8` |
| Range | `[3.71, 24.79]` = Mars → Jupiter |
| Presets | Mars(min), Earth(9.8), Jupiter(max) |
| Step | `0.1` (`decimals: 1`) |
| Display | metric `m/s²` 1 decimal; english `ft/s²` via `32.16/9.80665` |
| Effect | Scales both `getWaterPressure` and air pressure |
| Mystery | See §19 |

**No Moon preset in source.**

---

## 10. Units

`measureUnitsProperty`: `'metric' | 'atmosphere' | 'english'` (default `'metric'`).

| Mode | Pressure display | Conversion from Pa | Rounding (`Utils.toFixed`, abbreviated=false for barometer) |
|------|------------------|--------------------|--------------------------------------------------------------|
| metric | kPa | `/1000` | 3 decimals |
| atmosphere | atm | `* 9.8692E-6` | 4 decimals |
| english | psi | `* 145.04E-6` | 4 decimals |

**Internal unit always Pascals.**  
Abbreviated=true exists in API (metric 1 / others 2) but barometer calls `getPressureString(..., false)`.

Ruler / grid labels: metric meters vs english feet (`Units.feetToMeters`, `FEET_PER_METER = 3.2808399`).

---

## 11. Ruler

| Item | Source |
|------|--------|
| Visibility | `isRulerVisibleProperty` (ControlPanel checkbox) |
| Position | `rulerPositionProperty` Vector2 **view coords** default `(300, 100)` |
| View | `UnderPressureRuler` (not `FPAFRuler`) |
| Drag | `DragListener` on meters/feet ruler → `rulerPositionProperty`; bounds = layoutBounds |
| Close | `CloseButton` → sets `isRulerVisibleProperty = false` |
| Metric | `RulerNode` 0..5 m, major = 1 m view width, 4 minor ticks, rotated π/2 |
| English | 0..10 ft via `Units.feetToMeters` |
| Visibility switch | english → feetRuler; else metersRuler |
| Model vs render | Position is view Property; tick geometry procedural via scenery-phet `RulerNode` |
| Reset | Property.reset() in `UnderPressureModel.reset()` |

---

## 12. Grid

| Item | Source |
|------|--------|
| Visibility | `isGridVisibleProperty` (Boolean, default false) — **View-only** |
| Render | `GridLinesNode` + scene wrappers (`SquarePoolGrid`, `TrapezoidPoolGrid`) |
| Spacing | 1 m (metric/atmosphere) or 1 ft (english) |
| Style | 1.5px light gray + 1px dark bottom border |
| Labels | Depth readouts left of pool (`0..3` m or `0..10` ft) |
| Origin | Pool top / ground y=0 |
| Measurement | **Does not** feed pressure model |
| Reset | Property reset |

---

## 13. Pressure Gauge (Barometer)

| Item | Source |
|------|--------|
| Count | `NUM_BAROMETERS = 4` |
| Model | `Sensor` (`positionProperty`, `valueProperty`, `updateEmitter`) |
| Initial position | `(7.75, 2.5)` model meters — in sensor toolbox area |
| View | `BarometerNode` = procedural GaugeNode + readout Panel + metal stem + triangle probe |
| Scale | `1.5` in ScreenView |
| Needle | `GaugeNode`: **instant** Property → matrix rotation (no tween/damping) |
| Dial range | 50 kPa .. 250 kPa (`MIN_PRESSURE`..`MAX_PRESSURE`) |
| Readout when docked | `MathSymbols.NO_VALUE` (`-`) when position === initial or value null |
| Measurement point | **Probe tip**, not dial center |
| Drag | Continuous; snap back to toolbox if released intersecting sensor panel |
| Linked props | scene, gravity, density, atmosphere, currentVolume (+ chamber `updateEmitter`) |
| Pressure type | **Absolute Pa** |

---

## 14. Fluid Containers / Scenes

### Square (default)

- Rect pool: x∈[2.3, 6], y∈[-3, 0]
- Input faucet (2.7, 0.44) scale 0.42; output (6.6, -3.45) scale 0.3
- `maxVolume = maxHeight = 3` (comment: “Liters” but numerically = meters of fill fraction)
- Default `volumeProperty = 1.5` → half full

### Trapezoid

- Dual chambers + bottom connector; sloping walls via `LinearFunction` borders
- Same faucet/volume inheritance as square

### Chamber

- Connected openings (left narrow / right wide), horizontal passage
- **No faucets**; 3 draggable masses (500, 250, 250 g labels in MassNode)
- Water height via stack displacement + `lengthRatio`
- Dynamics: mass Newton integration + friction 0.98; heuristic restore when empty stack

### Mystery

- Geometry = Square pool
- Mystery Fluid or Mystery Planet radio
- ComboBox Fluid A/B/C or Planet A/B/C
- Hidden slider shows `?` via `ControlSlider.disable()`

---

## 15. Fluid Movement

**Real simulation exists** for faucet fill/drain and chamber masses.

```text
UnderPressureModel.step(dt)
  → fluidColorModel.step()
  → currentSceneModel.step(dt)

PoolWithFaucetsModel.step:
  volume += input.flowRate * dt  (clamp max)
  volume -= output.flowRate * dt (clamp 0)

ChamberPoolModel.step:
  MassModel.step (stack / falling)
  update leftDisplacementProperty
```

- Clock: Joist screen `step` → Flutter will need **real simulation clock** for faucet + chamber
- Fluid surface in square/trapezoid: **quasi-static** level from volume (no free-surface wave PDE)
- Faucet stream visual: `FaucetFluidNode` rectangle width ∝ flowRate

---

## 16. Fluid Entity Table

| Entity | Source class | Meaning | Unit | Mutable | Derived |
|--------|--------------|---------|------|---------|---------|
| Fluid density ρ | `fluidDensityProperty` | Density | kg/m³ | Yes | — |
| Gravity g | `gravityProperty` | Gravity | m/s² | Yes | — |
| Atmosphere flag | `isAtmosphereProperty` | Include air | bool | Yes | — |
| Air pressure | `getAirPressure` | Absolute air | Pa | — | Yes |
| Water column pressure | `getWaterPressure` | ρgh | Pa | — | Yes |
| Total pressure | `getPressureAtCoords` | Absolute | Pa\|null | — | Yes |
| Volume | `volumeProperty` (per scene) | Fill fraction proxy | “L”≈m height fraction | Yes | — |
| Water height | `getWaterHeightAboveY` | Column above tip | m | — | Yes |
| Fluid color | `FluidColorModel.colorProperty` | RGB | Color | — | Yes |
| Left displacement | `ChamberPoolModel.leftDisplacementProperty` | Mass load effect | m | Yes | — |
| Stack mass | `stackMassProperty` | Chamber | kg? (mass numbers 500/250) | Yes | — |

---

## 17. Mystery / Custom

| Item | Source |
|------|--------|
| Choice | `mysteryChoiceProperty`: `'fluidDensity'` (default) \| `'gravity'` |
| Fluid densities | `[1700, 840, 1100]` → Fluid A/B/C (`customFluidDensityProperty` index 0..2) |
| Gravities | `[20, 14, 6.5]` → Planet A/B/C |
| Mystery fluid colors | purple tones `[113,35,136]`, `[179,115,176]`, `[60,29,71]` |
| On enter mystery | saves old g/ρ; applies choice |
| On leave mystery | restores old g/ρ |
| Switching mystery type | resets the non-mystery quantity |
| Randomization | **None** — fixed discrete choices |

---

## 18. Interaction Matrix

| Interaction | Target | Continuous? | Model mutation | Release behavior |
|-------------|--------|-------------|----------------|------------------|
| Drag barometer | `Sensor.positionProperty` | Yes | tip → `getPressureAtCoords` → value | Snap to toolbox if over panel → reset position, hide value |
| Faucet handle | `FaucetModel.flowRateProperty` | Yes | volume integrate in step | Holds flow while open |
| Density slider/arrows | `fluidDensityProperty` | Yes | pressure, color | Accordion expand state kept |
| Gravity slider/arrows | `gravityProperty` | Yes | pressure, air scale | — |
| Atmosphere On/Off | `isAtmosphereProperty` | Discrete | air=0 or standard | Sky black when Off |
| Units radio | `measureUnitsProperty` | Discrete | display only (+ ruler/grid units) | — |
| Ruler checkbox | `isRulerVisibleProperty` | Discrete | — | — |
| Grid checkbox | `isGridVisibleProperty` | Discrete | view only | — |
| Drag ruler | `rulerPositionProperty` | Yes | view position | Close button hides |
| Scene radio | `currentSceneProperty` | Discrete | switches scene model/view | — |
| Mystery fluid/planet | `mysteryChoiceProperty` + combo indices | Discrete | overrides ρ or g | Disables corresponding slider |
| Drag chamber mass | `MassModel.position` / stack | Yes | displacement → water height | Drop into opening stacks; invalid teleports reset |
| Reset All | `UnderPressureModel.reset` + view resetActions | Discrete | all props + scenes + barometers | ResetAllButton radius **18** |

Barometer chain:

```text
press → drag positionProperty
  → Multilink(position + linkedProps)
  → getPressureAtCoords(tip)
  → valueProperty
  → GaugeNode needle + Units string
```

---

## 19. Clock / Animation Classification

| Kind | What | Flutter need |
|------|------|--------------|
| **Real simulation** | `UnderPressureModel.step` → faucet volume; chamber masses; fluid color update | Yes — Screen clock / Ticker |
| **UI animation** | Accordion expand/collapse; ResetAllButton press scale (scenery-phet) | View phase |
| **Instant binding** | Gauge needle (`valueProperty.link`); water rect height; pressure text | No clock |
| **Static visual** | Sky/ground textures; cement border; scene icons | No clock |

**Needle: instant, not damped.** Do not invent AnimationController for needle unless matching GaugeNode.

---

## 20. Layout / MVT

**Source-confirmed** (`Constants.SCREEN_VIEW_OPTIONS`):

```text
layoutBounds: Bounds2(0, 0, 768, 504)
```

（PhET 注释明确禁止随意改动。）

MVT (`UnderPressureScreenView`):

```js
ModelViewTransform2.createSinglePointScaleInvertedYMapping(
  Vector2.ZERO,          // model origin
  new Vector2(0, 245),   // view point for model (0,0)
  70                     // 1 m = 70 px
);
```

- Ground line y_model=0 → view Y = 245  
- Model +Y up (sky); pool into −Y  
- Control panel width 140; yellow `#f2fa6a`  
- ResetAll: `radius: 18`, right-bottom inset  
- Sensor panel: 100×130, yellow, left of control panel  

**截图不得单独改写为其他 layout；768×504 有 source 证据。**

---

## 21. Procedural vs Asset

### Original assets (required for UP)

| Asset | Used by |
|-------|---------|
| `grassTexture.png` | Square/Trapezoid/Chamber grass Pattern |
| `cementTextureDark.jpg` | Pool cement stroke Pattern |
| `squarePoolIcon.png` | SceneChoice |
| `trapezoidPoolIcon.png` | SceneChoice |
| `chamberPoolIcon.png` | SceneChoice |
| `mysteryPoolIcon.png` | SceneChoice |
| `underPressure.png` | Home/screen icon |

### Procedural

- Water fill rectangles / chamber water paths  
- SkyNode / GroundNode / black no-atmosphere  
- Barometer (GaugeNode + Path stem)  
- Faucet (`scenery-phet` FaucetNode)  
- Grid lines + depth labels  
- Ruler (`scenery-phet` RulerNode)  
- Control panels, sliders, radio buttons  
- Mass blocks (chamber)  

### Design-only (not runtime)

- `assets/*.ai`, `*.psd`, mockups — not required as Flutter assets

### Flow/WaterTower-only images (OUT OF SCOPE)

`pipe*`, `handle*`, `nozzle`, `wheel`, `injectorBulbCropped`, `flowMockup`, `waterTowerMockup`, `spoutHandle`, …

---

## 22. Asset Audit

```text
Required assets (UP runtime): 7
Found (local FPAF images/): 7
Missing: 0
Assets substituted: 0
```

| Asset | Source reference | Local path | Impact |
|-------|------------------|------------|--------|
| grassTexture.png | SquarePoolBack Pattern | `fluid-pressure-and-flow-main/images/` | OK |
| cementTextureDark.jpg | cement border | same | OK |
| squarePoolIcon.png | SceneChoiceNode | same | OK |
| trapezoidPoolIcon.png | SceneChoiceNode | same | OK |
| chamberPoolIcon.png | SceneChoiceNode | same | OK |
| mysteryPoolIcon.png | SceneChoiceNode | same | OK |
| underPressure.png | UnderPressureScreen homeIcon | same | OK |

under-pressure thin shell `assets/` 仅含 marketing screenshots（非 runtime）。  
**本阶段不生成替代 asset。**

---

## 23. Audio

```text
Local audio: 0
Source references: 0
Missing: n/a
```

P2 candidate only if product later requires interaction SFX — **source has no sounds/**.

---

## 24. Dependencies

### Used by Under Pressure path (import evidence)

```text
axon, dot, kite, scenery, scenery-phet, joist, sun, phet-core, phetcommon, tandem,
fluid-pressure-and-flow (host), chipper (strings), assert (dev)
```

### Declared in under-pressure README clone list (also)

```text
babel, brand, perennial-alias, phetmarks, query-string-machine, sherpa, tambo, twixt, utterance-queue
```

### Indirect / FPAF-only

```text
numeric-1.2.6.js preload (FPAF package) — Flow math; UP path may not need
lodash `_` used in ChamberPoolModel / BarometerNode / ScreenView
```

### Declared but unused by UP thin shell itself

Thin shell only imports joist + FPAF UnderPressureScreen + strings.

---

## 25. Source Tests

```text
Source tests: 0
```

No `js/*Tests.js`, no `tests/` in FPAF tree.  
`doc/model.md` empty.

> **Phase 1 必须自建 Physics Oracle（见下）。**

---

## 26. Physics Oracle Design

All expected values from **source functions** (port or reimplement bit-identical):

### Oracle A — Basic pressure

Inputs: ρ, g, depth(waterHeight), atmosphere, tip (x,y) inside square pool.  
Expected: `getPressureAtCoords` Pa.

### Oracle B — Density variation

Fix g, depth, atm ON; sweep ρ ∈ {700,1000,1420}.

### Oracle C — Gravity variation

Fix ρ, depth; sweep g ∈ {3.71, 9.8, 24.79}; verify air scale too.

### Oracle D — Depth variation

Fix ρ,g; waterHeight ∈ {0, 0.5, 1.5, 3}.

### Oracle E — Atmosphere

Same tip underwater: ON vs OFF → ΔP = air contribution.

### Oracle F — Units

Same Pa → metric/atmosphere/english strings (`Utils.toFixed` rules).

### Oracle G — Gauge position

- Tip above ground y>0  
- Tip in pool above water  
- Tip in fluid  
- Tip outside pool y≤0 → null  
- Tip offset uses probe deltaY  

### Oracle H — Reset

Mutate density, gravity, atmosphere, units, ruler, grid, scene, volume, barometer positions, mystery → `reset()` → all defaults.

### Numerical edge cases

- depth/waterHeight = 0  
- ρ/g min/max  
- atmosphere on/off  
- volume 0 / maxVolume  
- gauge value null docked  
- pressure clamp on dial only (needle), not on physics value  

### Precision

Match `Utils.toFixed` / `Utils.toFixedNumber` — **do not** casually use Dart `toStringAsFixed` with different rounding.

---

## 27. Source Quirks

1. `maxVolume = maxHeight` numerically (3) — volume units labeled liters but act as height fraction  
2. Air height map uses 150 m for “500 ft” constant  
3. Atmosphere pressure scales with g  
4. Chamber uses **length ratio** not area ratio (comment: visibility)  
5. ControlSlider header comments mention 5% tick snap — **implementation has no snap**  
6. `isGridVisibleProperty` / `rulerPositionProperty` marked TODO unused in model comments but **are used** by view  
7. Barometer returns `null` outside pool (underground) — dash display  
8. Mystery densities **outside** normal slider range (1700 > honey 1420)  
9. ResetAllButton radius **18** (not 20.5 default rule) — follow this sim’s source  
10. Empty `doc/model.md` — ignore for formulas  

---

## 28. Screenshot Audit

### Screenshot A — User-provided (this prompt)

```text
Screenshot: user prompt / workspace image
Screen: Under Pressure Screen 1
Scene: square (scene button 1 selected)
State:
  Atmosphere ON, Units Metric, Ruler OFF, Grid OFF
  Density 1000 kg/m³ (water), Gravity 9.8 m/s² (Earth)
  Volume ~ half tank; barometer in sky showing "-"
Major regions: sky / grass / brown ground / rect tank / right yellow panels / left scene rail
Controls: ruler, grid, atmosphere, units, fluid density, gravity, Reset All
Objects: input faucet, output faucet, cyan fluid, pressure gauge(s)
Visual states: matches SquarePool default defaults
```

### Screenshot B–E — Local `under-pressure/assets/*.png`

Marketing shots (alt1/alt2/screen1/main) — layout evidence only; not formula truth.

---

## 29. Layout Evidence (from screenshot + source)

| Item | Evidence |
|------|----------|
| Viewport | Source `768×504` |
| Ground | view Y≈245 |
| Scale | 70 px/m |
| Right panels | stacked yellow accordion + units |
| Scene icons | left vertical |
| Gauge | toolbox / free drag |
| Tank | buried rect, cement rim, grass cutout |

---

## 30. State Matrix

```text
Base State (defaults)
├── Atmosphere ON / OFF
├── Units: metric | atmosphere | english
├── Ruler ON/OFF (+ position)
├── Grid ON/OFF
├── Density ∈ [700,1420] + mystery {840,1100,1700}
├── Gravity ∈ [3.71,24.79] + mystery {6.5,14,20}
├── Gauge ×4 positions / docked
├── Fluid volume [0, maxVolume] (square/trapezoid/mystery)
├── Scene: square | trapezoid | chamber | mystery
├── Chamber: mass stack / free / falling
└── Mystery mode: fluidDensity | gravity + choice index 0..2
```

---

## 31. Risk Board

### P0

1. ~~Local FPAF missing~~ → **已解除**：`phet sourses/fluid-pressure-and-flow-main/` 已就位  
2. （无剩余 P0 阻塞项）— 核心 pressure semantics 已确认  

### P1

1. No source tests → large Physics Oracle burden  
2. Chamber mass dynamics + displacement pressure coupling  
3. Absolute pressure + height-dependent atmosphere + g-scaling  
4. Four geometries × inside-pool tests  
5. Mystery overrides outside normal density range  
6. Probe tip offset measurement semantics  
7. Faucet volume integration clock  
8. Units conversion constants must match exactly  

### P2

1. No audio  
2. Design `.ai` files unused  
3. Empty doc/ stubs  
4. ControlSlider comment vs code snap mismatch  
5. Network flaky when fetching FPAF zip  

---

## 32. Migration Blueprint (for Phase 1 Model)

1. Vendor/copy **FPAF under-pressure + common** source into workspace knowledge  
2. Port `Constants`, `Units`, `getStandardAirPressure`, `UnderPressureModel` pressure API bit-identical  
3. Port four scene models + `PoolWithFaucetsModel` + `FaucetModel` + `MassModel`  
4. Build Oracle A–H in Dart against golden vectors from JS  
5. **Do not** start Flutter Screen View until Model oracles pass  
6. View later: MVT 70px/m, 768×504, `KratosResetAllButton` radius **18**, original grass/cement/icons  

---

## 33. Phase Gate Checklist

| Criterion | Status |
|-----------|--------|
| Production screens confirmed | ✅ 1 Joist + 4 scenes |
| Models confirmed | ✅ |
| Pressure calculation confirmed | ✅ absolute Pa chain |
| Density / Gravity / Atmosphere | ✅ |
| Gauge / Depth | ✅ tip + waterHeight |
| Ruler / Grid | ✅ |
| Units | ✅ |
| Fluid state / movement | ✅ |
| Interactions | ✅ |
| Clock / animation | ✅ |
| Layout / MVT | ✅ 768×504 / 70 px/m |
| Assets audited | ✅ Found 7 / Missing 0 / Substituted 0 |
| Dependencies audited | ✅ |
| Source tests audited | ✅ 0 |
| Physics Oracle designed | ✅ A–H |

```text
PHASE 0 STATUS: PASS

Flutter UI: NOT STARTED
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED

Report: requirements/req-port-under-pressure/PHASE_0_SOURCE_AUDIT.md
```
