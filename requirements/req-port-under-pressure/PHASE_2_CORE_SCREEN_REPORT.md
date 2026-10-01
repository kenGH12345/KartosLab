# PHASE 2 — CORE SCREEN / SQUARE SCENE REPORT

**Sim:** PhET Under Pressure → Flutter  
**Req id:** `req-port-under-pressure`  
**Source View:** `fluid-pressure-and-flow-main/js/under-pressure/view/**`  
**Model:** Phase 1 LOCKED (no formula changes)

---

## PHASE 2 STATUS: PASS

判定：

- `UnderPressureScreen` + Square scene + shared controls/sensors/ruler/grid 可构造
- **Tip offset View 接线关闭**（`pressureReadOffset 51 × scale 1.5` → `viewToModelDeltaY`）
- Controls → Model → pressure binding 已测
- Reset / lifecycle 已测
- `dart analyze` clean；**50 tests PASS**（33 + 17）
- Trapezoid / Chamber / Mystery：仅 scene shell + placeholder（Phase 3）
- Home：**NOT TOUCHED**

```text
Flutter UI: Square core STARTED (Phase 2)
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## Viewport / MVT

```text
Viewport: 768 × 504
MVT: createSinglePointScaleInvertedYMapping
  Scale: 70 px/m
  Origin: (0, 245)
  Y: inverted (model +up → view +down)
```

`lib/under_pressure/transform/up_mvt.dart`

---

## SCREEN

`UnderPressureScreen` — `lib/under_pressure/view/under_pressure_screen.dart`  
Controller: `UnderPressureController` + `SimulationClock` → `model.step(dt)`

---

## SQUARE

| Item | Status |
|------|--------|
| Pool | PASS — rect walls, #f3f0e9 interior |
| Fluid | PASS — volume fraction + FluidColorModel color |
| Atmosphere / Sky | PASS — SkyNode-like gradient vs black |
| Grass | PASS — original `grassTexture.png` |
| Faucet stub | PASS — minimal handle → flowRate (polish Phase 3) |

---

## SENSOR

| Item | Status |
|------|--------|
| Count | 4 |
| Barometer | PASS — gauge + stem + tip + readout |
| Tip Offset | **PASS** — `UpBarometerMetrics.tipOffsetViewPx = 76.5` |
| Drag | PASS — center drag; measure at tip |
| Pressure | PASS — Model `getPressureAtCoords(tip)` only |
| Dock | PASS — snap to toolbox → `—` / null |
| Needle | PASS — instant (no tween) |

### Tip formula (source-faithful)

```text
tipY_model = centerY + viewToModelDeltaY(51 * 1.5)
```

Tests prove tip ≠ center measurement.

---

## CONTROLS

| Control | Status |
|---------|--------|
| Density | PASS — [700,1420], gasoline/water/honey |
| Gravity | PASS — [3.71,24.79], Mars/Earth/Jupiter |
| Atmosphere | PASS — On/Off → Model + sky |
| Units | PASS — metric/atmosphere/english → kPa/atm/psi display |

---

## RULER / GRID

| | |
|--|--|
| Ruler | PASS — visibility, drag, close, m/ft |
| Grid | PASS — view-only; 1 m / 1 ft labels |

---

## SCENE SELECTOR

| Scene | Phase 2 |
|-------|---------|
| Square | DONE |
| Trapezoid | shell + placeholder |
| Chamber | shell + placeholder |
| Mystery | shell + placeholder |

Icons: original FPAF PNGs (substituted 0).

---

## RESET / LIFECYCLE

- Reset All: `KratosResetAllButton` radius **18** → `controller.resetAll()`
- Reset stress ×10: PASS
- Lifecycle enter/leave/re-enter ×3: PASS

---

## VISUAL QA

Automated widget construct + binding tests PASS.  
Full S1–S20 screenshot harness: **Runtime NOT VERIFIED** this phase (manual screenshot capture deferred with Runtime).

Checklist coverage via tests:

| Shot | Covered by test/binding |
|------|-------------------------|
| S1 Initial | screen builds |
| S2–S4 Sensor regions | tip air/fluid/outside |
| S5–S6 Atmosphere | setAtmosphere |
| S7–S9 Density | setDensity |
| S10–S12 Gravity | setGravity |
| S13–S15 Units | setUnits |
| S16–S18 Ruler/Grid | toggles |
| S19–S20 Complex/Reset | reset stress |

---

## Assets

```text
Required: 7
Found: 7
Missing: 0
Substituted: 0
Path: assets/simulations/under_pressure/images/
```

---

## Tests

```text
Previous: 33
Added: 17
Final: 50 PASS
```

Files:

- `test/under_pressure/model/under_pressure_physics_oracle_test.dart` (33)
- `test/under_pressure/view/under_pressure_core_screen_test.dart` (17)

---

## Analyze

```text
No issues found!
```

---

## P0 / P1 / P2

### P0

None.

### P1

- ~~tip-offset View 接线~~ → **CLOSED**
- Chamber drop hit visual QA → Phase 3
- faucet/water View polish (scenery-phet FaucetNode parity) → Phase 3

### P2

- Control accordion chrome vs PhET AccordionBox micro-diff
- Cement border uses stroke color; full Pattern(cementTexture) polish later
- Density/gravity tick label alignment micro-diff

---

## Scope remainder

```text
Trapezoid: NOT COMPLETED (Phase 3)
Chamber: NOT COMPLETED (Phase 3)
Mystery: NOT COMPLETED (Phase 3)
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

Report: `requirements/req-port-under-pressure/PHASE_2_CORE_SCREEN_REPORT.md`
