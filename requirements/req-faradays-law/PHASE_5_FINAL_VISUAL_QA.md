# PHASE 5 — FINAL VISUAL QA · Faraday's Law

## Status

```
Phase 5 = COMPLETE
CODE CHANGES (lib/) = 0
Overall = NOT READY
Home = NOT STARTED
Android = NOT VERIFIED
```

## Visual gates

| Gate | Result |
| --- | --- |
| Final viewport | PASS — 834×504, `#97D0FF`, no AppBar |
| Initial visual | PASS — magnet right NS, 1 coil, arrows on, V/field off, bulb off |
| Magnet | PASS — size/colors/orientation swap (not mirror) |
| Coil | PASS — original four/two loop mipmaps @ 1/3 |
| Z-order | PASS — back → magnet → front (H_combined through-coil) |
| Field lines | PASS — 4 ellipses × 2 sides; polarity arrow flip |
| Voltmeter | PASS — body/gauge/needle/wires from Model angle |
| Bulb | PASS — base PNG + body painter; \|V\| halo |
| Controls | PASS — Voltmeter / Field Lines / coil radios / Flip / Reset All |
| Typography | PASS w/ P2 — labels present; test-capture font tofu noted (VD-FONT) |
| Assets | PASS — Substituted = 0 |
| Behavior regression | PASS — Phase 1–4 unchanged |

## P0 / P1 / P2

| | Count |
| --- | --- |
| **P0** | **0** |
| **P1** | **0** |
| **P2** | recorded (see below) |

### P2 reconfirmed (not fixed — Phase 5 policy)

| ID | Item | Status |
| --- | --- | --- |
| P2-01 | Magnet 3D bevel / anti-alias vs Scenery | still P2 |
| P2-02 | Voltmeter ShadedRectangle → flat + light stroke | still P2 |
| P2-03 | Field-line arrow tangent ~1–2° | still P2 |
| P2-04 | Top-coil wire arc simplified | still P2 |
| P2-05 | Bulb base Image vs Path body ≤ few px | still P2 |
| P2-C1 | Flip button bevel vs sun RectangularPushButton | still P2 |
| P2-C2 | Coil radio icon scale approx 0.21× | still P2 |
| P2-C3 | Checkbox centerY approx vs live radio | still P2 |
| P2-FONT | Headless capture may show label tofu / N·S soft glyphs | **new record** (runtime OK; no lib change) |

None elevated to P1: structure, assets, z-order, and control types match source.

## Substituted assets

**0**

## Known VERSION_DELTA

| ID | Note |
| --- | --- |
| VD-02 | `reset()` clears voltage immediately |
| VD-SOUND | Sounds not wired |
| VD-A11Y | Keyboard / GrabDrag a11y not ported |
| VD-DRAG | AABB drag limits |
| VD-FONT | MagnetPainter uses `Roboto`; checkbox labels use default Flutter font vs PhET `PhetFont`/Arial — accepted for Phase 5; no layout rewrite |

## Tests / Analyze

```
flutter test test/faradays_law/  → 127 PASS
dart analyze lib/faradays_law test/faradays_law → No issues found
```

| Suite | Count |
| --- | --- |
| Model | 49 |
| View | 10 |
| Controls | 10 |
| Dynamic | 36 |
| Visual | 22 |
| **Total** | **127** |

## Behavior regression

No Model / dynamic / control semantics changes. `lib/faradays_law/**` untouched in Phase 5.
