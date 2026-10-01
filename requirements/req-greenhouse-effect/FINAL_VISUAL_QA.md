# FINAL_VISUAL_QA · Greenhouse Effect

> Date: 2026-09-21 · after Home integration

| Check | Result |
|---|---|
| Home card title / subtitle / 热学与气体 | PASS (widget test) |
| Launch | PASS — AppBar + Waves / Photons / Layer Model |
| Back | PASS — returns to Home |
| Re-entry | PASS — sunlight off, Waves default |
| Overflow on 1280×900 Home path | None observed in lifecycle tests |
| Wave attenuation | Unchanged from Phase 3 |
| Flux arrows | Shaft + triangular head; length from flux rate. Still horizontal panel indicators, not PhET vertical observation-window arrows |
| Thermometer | Tube + bulb + formatted model value. Not the original PhET thermometer asset |
| Screen shell | Home AppBar + existing in-sim tabs. Not three independent PhET `Screen` shells |

## Priority

| Level | Count |
|---|---|
| P0 | 0 |
| P1 | 0 |
| P2 / VERSION_DELTA | Flux arrow orientation vs source; thermometer graphic vs source asset; combined tab surface vs three PhET screens |

These P2 items were not used as a reason to rewrite model or interaction.

## Assets

```text
Original simulation assets: unchanged
Substituted: 0
Home icon: Material Icons.wb_sunny_rounded (card only)
```
