# STATIC_RENDER_REPORT — Capacitor Lab Basics

> Phase 3 · 2026-09-12

## Architecture

```
ClbModel / CapacitanceModel
        ↓ CircuitRenderData.fromClbModel (read-only snapshot)
StaticCircuitView
        ↓ WirePainter / BatteryPainter / CapacitorPlatesPainter
        ↓ Image.asset (voltmeter, probes, cue)
```

Painters **do not** recompute C/Q/V/E.

## Deliverables

- `YawPitchMvt` complete API  
- `BoxShapeCreator` / `CircuitGeometry`  
- `CircuitRenderData`  
- Painters + `StaticCircuitView` + `CapacitanceStaticScreenBody`  
- Tests: MVT/geometry/battery bounds + widget smoke  

## Verdict labels

| Area | Label |
|------|-------|
| MVT / anchors / plate geometry / wire endpoints | `[源码一致]` |
| Battery cylinder shapes + scale 0.30 | `[源码一致]` |
| Battery gradient stops / wire stroked outline | `[视觉近似]` |
| darkerColor factor / cue arrow exact anchor / runtime pixel QA | `[待确认]` |
| Interaction / animation / Home | deferred (not BLOCKED for Phase 3 scope) |

## Assets

```
Original PNG Reused in static view: voltmeterBody, probeRed, probeBlack, switchCueArrow
Canvas Reconstructed: battery, plates, wires
Substituted Assets: 0
```
