# PHASE_3_KICKOFF — Static circuit render

> Started automatically after Phase 2 PASS · 2026-09-12

## Goal

MVT + static circuit visuals from **PhET Scenery geometry / original assets** — no interaction polish, no Home.

## Done so far

- [x] `YawPitchMvt` + unit tests

## Next

1. `BatteryPainter` from `BatteryGraphicNode.js` constants (Canvas, not Icon)
2. Capacitor plates via BoxNode/PlateNode geometry
3. Wire path (model segment endpoints — may need minimal WireSegment model)
4. Switch static pose at BATTERY_CONNECTED angles
5. Screen body Stack preview (optional, not Home)

## Constraints

- Reuse 6 PNGs where applicable (not for battery)
- No Material Icons
- No screenshot pixel hardcoding as layout SSOT
