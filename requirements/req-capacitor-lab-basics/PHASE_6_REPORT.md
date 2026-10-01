# PHASE_6_REPORT — Light Bulb screen interaction

> 2026-09-12

## Delivered

| Item | Status | Notes |
|------|--------|--------|
| 3-state switch snap / limits | PASS | `CircuitGeometry` + `SwitchGestureLayer` |
| LightBulb→Switch wires | PASS | 12 segments; render layers |
| BulbNode + `lightBulbBase` PNG | PASS | Canvas glass/filament/halo + **原图底座** |
| Probe bulb base / wires | PASS | `ProbeHitTester` top/bottom + wireLightBulb* |
| `LightBulbInteractiveScreenBody` | PASS | panels + TimeControl + Stopwatch + Reset |
| Discharge via model step ticker | PASS | `ClbLightBulbModel.step` |
| Home / common / other sims | untouched | — |

## Entry

```dart
LightBulbInteractiveScreenBody(model: ClbLightBulbModel(shared: …))
```

## Gate

| Gate | Result |
|------|--------|
| 3-state Switch | PASS |
| Bulb wires + asset | PASS |
| TimeControl / Stopwatch | PASS（UI 文本按钮，非 Material Icon） |
| analyze | PASS |
| Tests | **64 PASS** suite |

## [待确认] / deferred → Phase 7

1. Bulb glass / filament / halo 几何细节 vs `BulbNode.js` 像素级  
2. TimeControl / Stopwatch 与 PhET scenery 控件视觉等价  
3. Stopwatch toolbox drop-to-reset  
4. Current indicator arrows（battery + bulb 侧）  
5. Capacitance plate-area LinearFunction（Phase 4 carry）  

## Next

`PHASE_7_KICKOFF.md` — current indicators + polish + cross-screen reset
