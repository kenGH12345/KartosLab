# PHASE 1 — MODEL / PHYSICS CORE REPORT

**Sim:** PhET Under Pressure → Flutter (KartosLab)  
**Req id:** `req-port-under-pressure`  
**Source of truth:** `phet sourses/fluid-pressure-and-flow-main` (`js/under-pressure/model/**`, `js/common/**`)  
**Thin shell (not used for physics):** `phet sourses/under-pressure-main`

---

## PHASE 1 STATUS: PASS

判定依据：

- Absolute pressure chain 与 FPAF `UnderPressureModel.getPressureAtCoords` 逐项一致
- Square / Trapezoid / Chamber / Mystery 几何与 `getWaterHeightAboveY` 已迁移
- Faucet volume step、Chamber mass dynamics、FluidColor step、Units、Reset 已可测
- Physics Oracle A–H + Chamber + Faucet + Geometry：**33 tests PASS**
- `dart analyze lib/under_pressure test/under_pressure` → **No issues found!**
- Flutter UI / Home：**未开始 / 未触碰**

```text
Flutter UI: NOT STARTED
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## Models

| Model | Flutter path | Status |
|-------|--------------|--------|
| UnderPressureModel | `lib/under_pressure/model/under_pressure_model.dart` | PASS |
| SquarePoolModel | `lib/under_pressure/model/pool/square_pool_model.dart` | PASS |
| TrapezoidPoolModel | `lib/under_pressure/model/pool/trapezoid_pool_model.dart` | PASS |
| ChamberPoolModel | `lib/under_pressure/model/pool/chamber_pool_model.dart` | PASS |
| MysteryPoolModel | `lib/under_pressure/model/pool/mystery_pool_model.dart` | PASS |
| PoolWithFaucetsModel | `lib/under_pressure/model/pool/pool_with_faucets_model.dart` | PASS |
| FaucetModel | `lib/under_pressure/model/faucet/faucet_model.dart` | PASS |
| MassModel | `lib/under_pressure/model/mass/mass_model.dart` | PASS |
| PressureSensor (Sensor) | `lib/under_pressure/model/sensor/pressure_sensor.dart` | PASS |
| FluidColorModel | `lib/under_pressure/model/fluid/fluid_color_model.dart` | PASS |
| Constants / Units / Math | `under_pressure_constants/units/math.dart` | PASS |

---

## Physics

### Pressure

**Absolute pressure (Pa)** — not gauge-only `ρgh`.

### Exact calculation chain (source-faithful)

```text
tip (x, y)
  → if y > 0: getAirPressure(y)
  → else if isPointInsidePool(x,y):
       waterHeight = getWaterHeightAboveY(x,y)
       if waterHeight <= 0: getAirPressure(y)
       else: getAirPressure(waterHeight + y) + getWaterPressure(waterHeight)
  → else: null
```

### Air Pressure

```text
getStandardAirPressure(h) = linear(0, 150, 101325, 99490, h)
getAirPressure(h) = isAtmosphere ? standard(h) * g / 9.8 : 0
```

### Fluid Pressure

```text
getWaterPressure(h) = h * g * ρ
```

`h` = vertical fluid column above tip (`getWaterHeightAboveY`), model meters.

### Atmosphere

- Default ON  
- OFF → air contribution 0 (fluid contribution retained)

### Gravity

- Range `[3.71, 24.79]`, default `9.8`  
- Scales both fluid and air terms

### Density

- Range `[700, 1420]`, default `1000`  
- Mystery overrides: `[1700, 840, 1100]` (outside slider range — source)

### Depth

- Vertical column above tip — **not** bottom distance / hypotenuse

---

## Pressure Query

`UnderPressureModel.getPressureAtCoords(x, y)` — returns `double?` (null outside pool underground).

Sensors: 4× docked at `(7.75, 2.5)`; docked → `value = null` (View shows `-`).

---

## Units

| | |
|--|--|
| Internal | **always Pa** |
| metric | kPa, `toFixed(..., 3)` |
| atmosphere | atm × `9.8692e-6`, 4 decimals |
| english | psi × `145.04e-6`, 4 decimals |

---

## Scenes

| Scene | Notes |
|-------|-------|
| Square | Rect pool; faucets; default |
| Trapezoid | Dual sloping chambers + bottom connector; `LinearFunction` borders |
| Chamber | Connected vessels; 3 masses; displacement / lengthRatio |
| Mystery | Square geometry; Fluid A/B/C or Planet A/B/C; restores g/ρ on leave |

---

## Dynamics

| System | Interface |
|--------|-----------|
| Faucet | `step(dt)` → `volume ± flowRate * dt` |
| Chamber | mass Newton + friction 0.98; 15 substeps when stacked; displacement heuristic |
| Fluid color | `FluidColorModel.step()` after density change |

Model entry: `UnderPressureModel.step(dt)` — View phase wires `SimulationClock` → `step`.

---

## Sensors / Ruler / Grid / Reset

- Sensors: count 4; measure via `refreshSensorValues`; docked null  
- Ruler: `isRulerVisible`, `rulerPosition` (view coords default 300,100)  
- Grid: `isGridVisible` (view-only flag)  
- Reset: mirrors source `UnderPressureModel.reset()` + all scene resets + barometers + fluid color  

---

## Oracle

| Oracle | Result |
|--------|--------|
| A Basic Pressure | PASS |
| B Density | PASS |
| C Gravity | PASS |
| D Depth | PASS (also asserts bottom exclusive bound → null) |
| E Atmosphere | PASS |
| F Units | PASS |
| G Gauge Position | PASS |
| H Reset | PASS |
| Chamber C1–C6 | PASS |
| Faucet F1–F5 | PASS |
| Geometry ×4 | PASS |

---

## Tests

```text
Source: 0
Added: 33
Final: 33 PASS
```

File: `test/under_pressure/model/under_pressure_physics_oracle_test.dart`

---

## Analyze

```text
dart analyze lib/under_pressure test/under_pressure
No issues found!
```

---

## Regression

- No shared READY sim code modified  
- Balancing Act / Acid-Base Solutions: **unchanged** (not touched)

---

## P0 / P1 / P2

### P0

None.

### P1 (deferred to View — not blocking Phase 1 Model)

1. Tip offset (`viewToModelDeltaY(bottom − center)`) — Model API takes tip coords; View must apply offset when dragging gauges  
2. Chamber stack drop hit-testing is Bounds2-quirked (source asymmetric width) — verified via C1; visual QA later  
3. Faucet stream visual / water polygon View  

### P2

1. `volume` labeled “Liters” in source but numerically = height fraction  
2. Any-pool volume Property.link can rewrite `currentVolume` while another scene is active (source quirk retained)

---

## Deliverables

```text
lib/under_pressure/model/**
test/under_pressure/model/under_pressure_physics_oracle_test.dart
requirements/req-port-under-pressure/PHASE_1_MODEL_REPORT.md
```

**Not delivered (by design):** Screen View, Home wiring, assets into Flutter, screenshot QA.
