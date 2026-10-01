# PHASE 5 — FINAL BEHAVIORAL ACCEPTANCE

**Sim:** PhET Under Pressure → Flutter  
**Req id:** `req-port-under-pressure`  
**Source:** `fluid-pressure-and-flow-main`  
**Model:** LOCKED (no physics changes this phase)

---

## PHASE 5 STATUS: PASS

判定：

- Physics Oracle A–H + Chamber / Faucet / Geometry：PASS
- Four geometries + Sensor tip + Faucet/Chamber dynamics：PASS
- Reset / Lifecycle / State Isolation / Clock：PASS
- Phase 4 Goldens **12 / 12 PASS**
- Under Pressure suite：**116 PASS**（86 + 30）
- Analyze：**No issues found!**
- Under Pressure Global Failures：**0**
- Full `flutter test`：其他项目有既有 failure（与 UP 无关）
- Home：**NOT TOUCHED**
- 未宣布 READY

```text
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
Audio: unavailable
```

---

## PHYSICS

| Item | Status |
|------|--------|
| Pressure | PASS — absolute = air(surface) + ρgh |
| Air | PASS — linear 0→150m × g/9.8 |
| Fluid | PASS |
| Atmosphere | PASS — OFF → air=0; fluid remains |
| Gravity | PASS — Mars/Earth/Jupiter scale air+fluid |
| Density | PASS — 700/1000/1420 fluid only |
| Depth | PASS — getWaterHeightAboveY |
| Units | PASS — display kPa/atm/psi; Pa internal |

---

## GEOMETRIES

| Scene | Status |
|-------|--------|
| Square | PASS |
| Trapezoid | PASS |
| Chamber | PASS |
| Mystery | PASS — presets ≠ Water |

---

## SENSOR

| Item | Status |
|------|--------|
| Count | 4 |
| Tip | PASS — tip ≠ center |
| Air / Fluid / Outside | PASS |
| Docked | PASS → null |
| Surface | PASS — y>0 air; y=0 exclusive boundary |

---

## DYNAMICS

| Item | Status |
|------|--------|
| Faucet closed / open / close | PASS |
| Faucet dt (small/normal/large) | PASS |
| Fluid level from Model | PASS |
| Chamber mass / invalid drop | PASS |
| Displacement | PASS |
| Fluid color | PASS |

---

## CONTROLS

| Item | Status |
|------|--------|
| Density / Gravity / Atmosphere / Units | PASS |
| Ruler / Grid | PASS — grid does not change pressure |
| Scene switching | PASS |

---

## RESET / LIFECYCLE / CLOCK / ISOLATION

| Item | Status |
|------|--------|
| Reset All | PASS |
| Reset stress ×10 | PASS |
| Leave/re-enter ×5 | PASS |
| Scene switch + re-enter | PASS |
| Clock (single volume Δ) | PASS |
| State isolation (chamber ≠ square volume) | PASS |

---

## GOLDENS

```text
12 / 12 PASS
```

（未重新生成 baseline 掩盖 regression。）

---

## ORACLE

| Oracle | Status |
|--------|--------|
| A–H | ALL PASS |
| Chamber Oracle | PASS |
| Faucet Oracle | PASS |
| Geometry Oracle | PASS |

---

## Tests

```text
Previous: 86
Added: 30
Final: 116
```

Acceptance file:

`test/under_pressure/acceptance/under_pressure_final_acceptance_test.dart`

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
| P1 | 0 |
| P2 | faucet shooter 叠层微差；shadow / font baseline 微差（视觉，未改 Model） |

---

## Regression

```text
Under Pressure Regression: PASS
Global Regression: FAIL — unrelated failures
Under Pressure Global Failures: 0
Other Project Failures: 56
```

Full suite summary line:

```text
+3649 ~1 -56
```

Failures observed in（非 UP）：`states_of_matter` visual QA capture、`pendulum_lab` / `projectile_motion` timeouts、`forces` scenario hang 等。**无 `test/under_pressure/**` failure。**

---

## Assets

```text
Required: 7
Found: 7
Missing: 0
Substituted: 0
```

（scenery-phet faucet PNGs = original PhET；非第三方替代。）

---

## Home / Runtime

```text
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

Phase 6：Home Integration / Release Gate。

---

## Report

`requirements/req-port-under-pressure/PHASE_5_FINAL_BEHAVIORAL_ACCEPTANCE.md`
