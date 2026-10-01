# PHASE_2_VISUAL_QA · Greenhouse Effect

> Date: 2026-09-21 · Method: automated tests + source-aligned layout review (no Home)

## Checklist

| Scene | Result |
|---|---|
| Initial (sun off, landscape) | PASS — Start Sunlight visible |
| Solar radiation (Waves / Photons) | PASS — model-driven |
| Infrared | PASS — ground IR photons / IR waves when T rises |
| Atmosphere layers (Layer Model) | PASS — active layer lines |
| Cloud | PASS — enabled ellipse |
| Earth / landscape | PASS — original PNG bg/fg |
| Flux meter | PASS — altitude line + net flux text when visible |
| Controls / Pause / Slow / Step / Reset | PASS (widget + model tests) |

## P0 = 0

No blocking crashes or missing core objects in the Flutter screen.

## Remaining visual work (→ Phase 3+)

- Exact EnergyLegend artwork
- Flux meter panel body / wire routing
- Concentration date radio strip
- Full wave intensity-change rendering
- Side-by-side official HTML5 visual diff on Web

## Status

**NOT READY** — View runnable; Home not integrated; P1 deltas open.
