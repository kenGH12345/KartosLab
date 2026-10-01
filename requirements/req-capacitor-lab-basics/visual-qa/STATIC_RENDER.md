# STATIC_RENDER — Visual QA

> Phase 3 · 2026-09-12  
> Design space: **1024 × 618** · MVT scale **12000** · pitch **30°** · yaw **−45°**  
> Widget: `CapacitanceStaticScreenBody` + `StaticCircuitView`  
> Gate: analyze clean · unit+widget tests PASS

---

## Coordinate pipeline

```
Model (m) — Battery/Capacitor/WireSegment xyz
    ↓ YawPitchMvt.modelToViewPosition / Delta / XYZ
Scenery view (px) — scale-only for wire shapes (xy); full yaw/pitch for plates
    ↓ Flutter CustomPaint / Positioned Image.asset
Flutter canvas — same numeric view frame inside SizedBox(1024,618)
```

| Item | Original Source | Flutter Implementation | Evidence | Result |
|------|-----------------|------------------------|----------|--------|
| Design size | `CLBModel` CANVAS 1024×618 | `ClbConstants.canvasWidth/Height` | constants + widget SizedBox | `[源码一致]` PASS |
| MVT | `YawPitchModelViewTransform3.js` | `YawPitchMvt` | unit tests polar/z/delta | `[源码一致]` PASS |
| Battery center | `CLBCircuitNode` MVT(battery.position) | `CircuitRenderData.batteryCenter` | fromClbModel | `[源码一致]` PASS |
| Capacitor center | MVT(capacitor.position) | plate faces via BoxShapeCreator + delta layout | BoxShapeCreator.js | `[源码一致]` PASS |
| Wire | WireShapeCreator scale-only + stroke 7 | CircuitGeometry → WirePainter | geometry tests | `[源码一致]` / stroke `[视觉近似]` |

---

## Battery

| Item | Original Source | Flutter | Evidence | Result |
|------|-----------------|---------|----------|--------|
| Geometry | BatteryGraphicNode ellipses/bands | BatteryPainter Path | constants match | `[源码一致]` PASS |
| Scale | BatteryNode `scale: 0.30` | `batteryGraphicScale` | unit scaled width | PASS |
| Gradient | createGradient stops | LinearGradient approx | stops simplified | `[视觉近似]` |
| Anchor | Node center = MVT(pos) | translate center − localCenterY | BatteryPainter | PASS |
| No Icon | — | Canvas only | code review | PASS |

---

## Capacitor plates

| Item | Original Source | Flutter | Evidence | Result |
|------|-----------------|---------|----------|--------|
| Faces | BoxShapeCreator top/front/right | BoxShapeCreator + CapacitorPlatesPainter | unit face points | PASS |
| Color | PLATE_COLOR (245,245,245) | ClbColors.plate | PlateNode.js | PASS |
| Darker faces | color.darkerColor() | RGB×0.7 / ×0.7² | `[推测]` factor | `[待确认]` factor · geometry PASS |
| Separation layout | CapacitorNode.updateGeometry | CircuitRenderData plate offsets | modelToViewDeltaXYZ | PASS |

---

## Wire

| Item | Original Source | Flutter | Evidence | Result |
|------|-----------------|---------|----------|--------|
| Endpoints | BatteryToSwitchWire / CapacitorToSwitchWire / CircuitSwitch | CircuitGeometry | unit hinge/terminal/cap | PASS |
| Stroke | lineWidth 7 round → strokedShape; WireNode fill/stroke | WirePainter | `[视觉近似]` outline | PASS structure |
| Layer | bottomWire under battery; topWire over capacitor | StaticCircuitView Stack | CLBCircuitNode order | PASS |

---

## Original PNG assets

| Asset | Scale / transform | Flutter | Result |
|-------|-------------------|---------|--------|
| voltmeterBody | 0.336 · top-left at MVT(body) | Image.asset + Transform.scale | `[源码一致]` placement; default body (0,0,0) may be off-play `[待确认]` UX |
| probeRed/Black | 0.25 · yaw rotate(−yaw) · top-center origin | Image + Transform | PASS |
| switchCueArrow | 25/h · translate(−80,−250) · !switchUsed | Image overlays | `[视觉近似]` center ≈ blade mid |
| capacitanceScreenIcon | Home only | not in static circuit | N/A Phase 3 |
| lightBulbBase | LB screen | not in Capacitance static | N/A this body |

Substituted Assets: **0**

---

## Layering checklist

1. bottom wires  
2. battery  
3. plates  
4. top wires  
5. voltmeter images  
6. cue arrows  

Matches `CLBCircuitNode` intent (handles/current indicators deferred). **PASS**

---

## Phase gate summary

| Gate | Status |
|------|--------|
| MVT | PASS |
| Battery | PASS (`[视觉近似]` gradient) |
| Capacitor Plates | PASS (`[待确认]` darkerColor factor) |
| Wire | PASS (`[视觉近似]` stroke outline) |
| Original Assets | PASS |
| Layering | PASS |
| Coordinate | PASS |
| Analyze | PASS |
| Tests | PASS (42+) |

Runtime pixel screenshot vs PhET URL: **not captured in CI this session** — widget smoke confirms paint; mark visual pixel diff `[待确认]` for human/runtime QA.
