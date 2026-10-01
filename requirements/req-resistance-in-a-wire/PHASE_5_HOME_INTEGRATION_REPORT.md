# PHASE 5 — HOME INTEGRATION / FINAL ACCEPTANCE

**Sim:** Resistance in a Wire · 1.8.0-dev.0  
**Date:** 2026-09-27  
**Status:** READY CANDIDATE

## Integration

| Item | Result |
|------|--------|
| Duplicate audit | NONE — first Home entry |
| Category | 电学与电路 (after Ohm's Law) |
| Title | 导线电阻 |
| Subtitle | 电阻率 · 长度 · 截面积 · R = ρL/A |
| Target | `ResistanceInAWireScreen` only |
| Builder | `_buildResistanceInAWire` → `const ResistanceInAWireScreen()` |
| Icon | `Icons.straighten_rounded` (Home Material convention) |
| production `dotRandom` | UNSEEDED (unchanged) |

## Sibling golden refresh (category layout)

Adding the card updated electricity-category Home goldens for:

- `test/ohms_law/home/goldens/` (H01/H02/H04)
- `test/balloons_and_static_electricity/home/goldens/` (category chrome)

Lifecycle suites for Ohm / Faraday / Balloons: PASS.

## Tests

| Suite | Result |
|-------|--------|
| Home lifecycle (H5-01…H5-12) | 14 / 14 |
| Home screenshots (H01…H05 + cold-start) | 7 / 7 |
| Home total | 21 / 21 |
| Phase 1 Model | 24 / 24 |
| Phase 2 View | 14 / 14 |
| Phase 2 Visual State | 16 / 16 |
| Phase 2 Golden | 12 / 12 |
| Phase 3 Runtime | 26 / 26 |
| Phase 4 Golden | 30 / 30 |
| Phase 4 Visual | 38 / 38 |
| **Final Combined** | **123 / 123** |
| Analyze | CLEAN |

H03b/H05b pixel goldens reuse Phase 4 `g01_initial.png` (seeded). Live Home open keeps unseeded `dotRandom`.

## Honesty flags (unchanged)

- Audio: PARTIAL
- Accessibility: PARTIAL
- Keyboard Reset: PARTIAL
- Performance: NOT VERIFIED
- Android: NOT VERIFIED

## P0 / P1 / P2

- P0: 0
- P1: 0
- P2: 1 — headless font / AA; Audio/A11y/Keyboard/Perf/Android carry-forward

## Model / View

- Model: FROZEN
- View: Home title/subtitle constants only (no layout / formula / wire redesign)
- Home: MODIFIED
