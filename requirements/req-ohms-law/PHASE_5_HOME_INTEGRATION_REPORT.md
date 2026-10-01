# Ohm's Law — PHASE 5 Home Integration / Final Acceptance

**Date:** 2026-09-27  
**Source:** 1.5.0-dev.6  
**Status:** READY CANDIDATE

## Audit inventory (pre-change)

| Item | Finding |
|------|---------|
| Home card "欧姆定律" / "Ohm's Law" | **Absent** (no duplicate) |
| Route / registry | No `OhmsLawScreen` registration |
| `circuit_screen` "欧姆定律" | Educational copy only — not a Home entry |
| Canonical target | `OhmsLawScreen` (Phase 2–4 product screen) |

## Integration

| Field | Value |
|-------|-------|
| Category | 物理 → **电学与电路** |
| Title | `Ohm's Law` (PhET English; peer Faraday/Hooke) |
| Subtitle | `欧姆定律 · 电压 · 电阻 · 电流` |
| Icon | `Icons.electrical_services_rounded` |
| Builder | `_buildOhmsLaw` → `const OhmsLawScreen()` |
| Duplicate entries | **1** card only |

## Files touched

- `lib/screens/home_screen.dart` — register card + builder
- `lib/ohms_law/view/ohms_law_screen.dart` — `subtitle` / `homeIcon` metadata only (no play-area redesign)
- `test/ohms_law/home/ohms_law_home_lifecycle_test.dart` — H5-01…H5-12
- `test/ohms_law/home/ohms_law_home_screenshot_test.dart` — H01…H05
- `test/ohms_law/home/goldens/*.png` — 5 Home goldens

**Model:** FROZEN · **View play-area / Phase 4 goldens:** untouched · **Home:** MODIFIED

## Test counts

```
previous test/ohms_law: 81
+ Home lifecycle:       14
+ Home screenshots:      5
= Full test/ohms_law:  100
```

| Suite | Result |
|-------|--------|
| Phase 1 Model | 27 / 27 |
| Phase 2 View | 11 / 11 |
| Phase 2 Visual State | 14 / 14 |
| Phase 2 Golden | 1 / 1 |
| Phase 3 Runtime | 23 / 23 |
| Phase 4 Golden | 38 / 38 (aliases) |
| Phase 4 Visual Regression | 20 / 20 |
| Home Tests | 19 / 19 |
| Home Golden | 5 / 5 |
| Home Regression | 19 / 19 |
| Sibling: Faraday home | 9 / 9 |
| Sibling: Balloons home | 8 / 8 |
| Sibling: Hooke's Law suite | PASS (included in peer run) |
| Full test/ohms_law | 100 / 100 |
| dart analyze | CLEAN |

## Gates

P0: 0 · P1: 0 · P2: headless font / anti-aliasing; Audio PARTIAL; A11y PARTIAL; Keyboard PARTIAL; Performance NOT VERIFIED; Android NOT VERIFIED

## Honesty

- Home goldens are **implementation regression** captures of KartosLab Home chrome + route, not official PhET Home pixels.
- No new Ohm's Law animation added (source has none).
- Audio / SR / 60fps / Android unchanged from Phase 3–4 honesty flags.
