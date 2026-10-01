# PHASE 3 — ADVANCED SCENES REPORT

**Sim:** PhET Under Pressure → Flutter  
**Req id:** `req-port-under-pressure`  
**Source View:** `fluid-pressure-and-flow-main/js/under-pressure/view/**`  
**Model:** Phase 1 LOCKED (no formula changes)

---

## PHASE 3 STATUS: PASS

判定：

- Trapezoid / Chamber / Mystery 完整 View 接入同一 `UnderPressureModel`
- Chamber drop hit 使用 source `MassModel.isInTargetDroppedArea`（Bounds2 quirk 保留）
- Faucet + `FaucetFluidNode` 由 `SimulationClock` → `PoolWithFaucetsModel.step` 驱动 volume
- Mystery dataset / 切 scene 恢复 density·gravity 按 source
- Phase 2 Square / tip-offset / controls regression PASS
- `dart analyze` clean；**71 tests PASS**（50 + 21）
- Home：**NOT TOUCHED**

```text
Flutter UI: all 4 scenes STARTED
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## Viewport / MVT

```text
Viewport: 768 × 504
MVT: 70 px/m · inverted Y · origin (0,245)
```

---

## TRAPEZOID

| Item | Status |
|------|--------|
| Geometry | PASS — left/right trapezoid + bottom chamber; source `verticles` |
| Fluid | PASS — `TrapezoidPoolWaterNode` polygon from border functions |
| Sensor | PASS — tip offset unchanged |
| Pressure | PASS — Model `getPressureAtCoords` only |
| Ruler / Grid | PASS — shared tools; trapezoid mid-label grid |
| Visual | PASS (widget) — Runtime screenshot NOT VERIFIED |

---

## CHAMBER

| Item | Status |
|------|--------|
| Geometry | PASS — openings / chambers / passage path |
| Mass | PASS — 3 masses, gradient body, drag bounds = layout |
| Drop Hit | **PASS / CLOSED** — `isInTargetDroppedArea` + stack snap |
| Displacement | PASS — `leftDisplacement` → water levels + pressure |
| Fluid | PASS — `ChamberPoolWaterNode` shape |
| Pressure | PASS |
| Reset | PASS — stack / displacement / masses |
| Visual | PASS (widget) — Runtime NOT VERIFIED |

Drop hit 接线：

```text
pointer → view → MVT.viewToModel → MassModel.position
→ setDragging(false) → isInTargetDroppedArea → stack.push
→ MassStackNode.syncStackPositions
```

---

## FAUCET

| Item | Status |
|------|--------|
| Model | PASS — Phase 1 `FaucetModel` / `PoolWithFaucetsModel` |
| Open / Close | PASS — flowRate UI → Model |
| Clock | PASS — `step(dt)` volume Δ = rate × dt |
| Volume | PASS — Square / Trapezoid / Mystery |
| Water View | **PASS / CLOSED** — `UpFaucetFluidNode` + pool fluid from Model |
| Visual | PASS (procedural faucet silhouette; no third-party asset) |

---

## MYSTERY

| Item | Status |
|------|--------|
| Dataset | PASS — densities `[1700,840,1100]` · gravity `[20,14,6.5]` · colors source |
| Geometry | PASS — square pool via `MysteryPoolModel` |
| Fluid | PASS — mystery colors when choice=fluidDensity |
| Pressure | PASS |
| Sensor | PASS |
| Reset | PASS — custom indices + square reset |
| Visual | PASS — Mystery Fluid / Planet radios + A/B/C combo |

---

## SCENE SWITCHING

| Transition | Status |
|------------|--------|
| Square → Trapezoid | PASS |
| Trapezoid → Chamber | PASS |
| Chamber → Mystery | PASS |
| Mystery → Square | PASS |
| Rapid multi-hop | PASS |

---

## STATE RETENTION

| State | Behavior (source) |
|-------|-------------------|
| Density / Gravity | Shared; mystery entry saves & restores prior |
| Units / Atmosphere / Ruler / Grid | Shared across scenes |
| Sensors | Shared positions |
| Faucet volume | Per-pool (square / trapezoid / mystery independent) |
| Mass | Chamber only |
| Mystery choice / combo | Mystery only |

---

## LIFECYCLE / RESET STRESS

- enter → interact → leave → re-enter ×3：PASS  
- Reset stress ×10（scene / faucet / mass / mystery）：PASS  

---

## VISUAL QA

Widget construct / binding tests cover T1–T4, C1–C5, F1–F5, M1–M4 paths.  
**Runtime screenshots S\* / T\* / C\* / F\* / M\*：NOT VERIFIED**（无设备跑图）。

---

## Assets

```text
Required: 7
Found: 7
Missing: 0
Substituted: 0
```

Faucet / mass / pool geometry：source procedural → Flutter procedural（非截图 PNG）。

---

## Tests

```text
Previous: 50
Added: 21
Final: 71
```

Oracle A–H + Chamber + Faucet + Geometry：仍全部 PASS。

---

## Analyze

```text
No issues found!
```

---

## P0 / P1 / P2

| | |
|--|--|
| P0 | 0 |
| P1 | Chamber drop hit QA：**CLOSED**；faucet/water View：**CLOSED** |
| P2 | accordion chrome；cement Pattern 细化；faucet scenery-phet 像素级轮廓；mystery combo 完整下拉 |

---

## Phase 2 Regression

```text
Square / Sensor / Tip Offset / Controls / Ruler / Grid / Reset / Lifecycle: PASS
```

---

## Scope remainder

```text
Trapezoid: DONE
Chamber: DONE
Mystery: DONE
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## Report

`requirements/req-port-under-pressure/PHASE_3_ADVANCED_SCENES_REPORT.md`
