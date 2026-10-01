# PHASE 6 — HOME INTEGRATION / FINAL RELEASE GATE

**Sim:** PhET Under Pressure → Flutter  
**Req id:** `req-port-under-pressure`  
**Source behavior:** `fluid-pressure-and-flow-main`  
**Home:** KartosLab `HomeScreen` registry

---

## PHASE 6 STATUS: READY

判定：

- Home 卡片已接入：**物理 → 密度与浮力 → Under Pressure**
- Navigation / Back / Re-entry / Lifecycle / State Isolation：PASS
- Under Pressure suite：**126 PASS**（116 + 10）
- Goldens：**12 / 12 PASS**
- Home peer regression（Balancing Act / Faraday / Hooke's Law）：PASS
- Analyze clean；P0/P1 = 0
- 全仓库 `flutter test`：`+3659 ~1 -56`；**New Under Pressure/Home failures = 0**
- Global 仍有既有 unrelated failures（与 Phase 5 同类）
- Runtime / Android：**NOT VERIFIED**
- **未**声称全仓库 READY

```text
Under Pressure: READY
Global Repository: FAIL — unrelated baseline failures
```

---

## HOME

| Item | Status |
|------|--------|
| Card | PASS — `Under Pressure` / `压强 · 深度 · 密度` |
| Category | PASS — `物理` → `密度与浮力`（与「密度」并列） |
| Icon | PASS — Material `Icons.compress_rounded`（Home 统一策略） |
| Navigation | PASS — `Navigator.push` → `UnderPressureHome` |
| Back | PASS — AppBar Back → Home（内部 scene 无独立 route） |
| Re-entry | PASS ×3 — fresh controller / defaults |
| Lifecycle | PASS — dispose clock；无 2× volume |
| Visual | PASS — 与同类 Material card 一致 |

入口：

`lib/under_pressure/screens/under_pressure_home.dart`  
注册：`lib/screens/home_screen.dart`（`_buildUnderPressure`）

---

## UNDER PRESSURE

| Item | Status |
|------|--------|
| Screen | PASS — `UnderPressureScreen` in Home shell |
| Square / Trapezoid / Chamber / Mystery | PASS（Phase 3–5） |
| Faucet / Sensor / Ruler / Grid / Reset | PASS |
| Behavior | PASS（Phase 5 acceptance） |
| Visual / Goldens | PASS 12/12 |

---

## CROSS-BOUNDARY

| Flow | Status |
|------|--------|
| Home → Under Pressure | PASS |
| Under Pressure → Home | PASS |
| Chamber/Mystery then Back | PASS（仍回 Home） |
| Re-entry fresh state | PASS |
| State Isolation | PASS — mass/faucet 不残留 |
| Reset after Re-entry | PASS |
| Peer sim（密度）→ Back → UP | PASS |

---

## Tests

```text
Previous: 116
Added: 10
Final: 126
```

Home tests：

`test/under_pressure/home/under_pressure_home_lifecycle_test.dart`

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
| P2 | faucet shooter 叠层微差；shadow / font baseline 微差 |

---

## Regression

```text
Under Pressure Regression: PASS (126)
Home Regression: PASS (peer Balancing Act / Faraday / Hooke's Law)
Global Regression: FAIL — unrelated baseline failures
Global Baseline: Phase 5 style (~56 unrelated)
New Under Pressure/Home Global Failures: 0
```

Full suite：

```text
Phase 5: +3649 ~1 -56  (UP failures 0)
Phase 6: +3659 ~1 -56  (UP/Home failures 0; +~10 new UP home tests)
```

---

## Assets

```text
Assets substituted: 0
```

Home icon = Material（KartosLab Home 既有策略，非第三方 PNG）。

---

## Runtime / Android / Audio

```text
Runtime: NOT VERIFIED
Android: NOT VERIFIED
Audio: unavailable / N/A
```

---

## Report

`requirements/req-port-under-pressure/PHASE_6_HOME_RELEASE_REPORT.md`
