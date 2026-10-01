# PHASE_5_REPORT — Voltmeter measurement + plate charge / E-field

> 2026-09-12 · Capacitance screen

## Scope delivered

| Item | Status | Source |
|------|--------|--------|
| Probe tip shape | PASS | `VoltmeterShapeCreator.js` tip size / offset / −yaw |
| `getProbeTarget` order | PASS | `ParallelCircuit.js:322-378` (no bulb on Capacitance) |
| `computeValue` | PASS | `Voltmeter.js:163-227` |
| probesAreTouching → 0 | PASS | tip Path intersect |
| Plate charges | PASS | `PlateChargeNode.js` grid + ± glyphs |
| E-field lines | PASS | `EFieldNode.js` spacing / arrows |
| Visibility toggles | PASS | `plateChargesVisible` / `electricFieldVisible` |
| Readout `toFixed(3)` | PASS | `VoltmeterBodyNode.js:159` |
| Home / common / other sims | untouched | — |

## SOURCE → Flutter

| PhET | Flutter |
|------|---------|
| `ProbeTarget.js` | `probe_target.dart` |
| `CircuitPosition.js` | `circuit_position.dart` |
| `VoltmeterShapeCreator` | `voltmeter_shape_creator.dart` |
| `ParallelCircuit.getProbeTarget` | `probe_hit_tester.dart` |
| `Voltmeter.computeValue` | `Voltmeter.computeValue` |
| `PlateChargeNode` | `PlateChargePainter` |
| `EFieldNode` | `EFieldPainter` |

## Coordinate / hit notes

```
probe model (x,y)
+ PROBE_TIP_OFFSET (0.00018, 0.00025)
→ rotate −yaw about tip origin
→ MVT modelToViewXYZ
→ Path tip
→ intersect battery terminal / plate box faces / switch circle / wire capsules (stroke≈7)
→ ProbeTarget
→ computeValue (rail remap when BATTERY_CONNECTED / LIGHT_BULB_CONNECTED)
→ measuredVoltage (null = "?")
```

Battery terminal hit uses BatteryPainter-aligned ellipse (**[已确认] geometry constants**, terminal Shape path from `BatteryGraphicNode` not byte-identical → **[推测] ellipse+band**).

Wire hit uses stadium capsules of half-width 3.5 (**[已确认] stroke 7**, **[推测] capsule vs kite getStrokedShape**).

## Tests

- `voltmeter_measurement_test.dart` — computeValue cases + plate probe integration + charge count
- Full `test/capacitor_lab_basics`: **57 PASS**
- `dart analyze lib/capacitor_lab_basics`: clean

## Gate

| Gate | Result |
|------|--------|
| Voltmeter measurement | PASS |
| Probe hit targets (Capacitance) | PASS |
| Plate charges viz | PASS |
| E-field viz | PASS |
| analyze | PASS |
| Regression | PASS |

## [待确认] / deferred

1. Battery terminal exact Path from `BatteryGraphicNode.terminalShape`  
2. Wire capsule vs kite stroked union  
3. Light-bulb base / wires hit (Phase 6)  
4. Current indicators (Phase 7)  
5. Plate area LinearFunction (Phase 4 carry-over)  

## Next

`PHASE_6_KICKOFF.md` — Light Bulb screen interaction + discharge UI
