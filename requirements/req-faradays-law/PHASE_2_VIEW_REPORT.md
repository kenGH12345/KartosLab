# PHASE 2 — VIEW REPORT · Faraday's Law

**日期**：2026-09-22  
**状态**：Phase 2 = COMPLETE · Overall = NOT READY  
**Home**：NOT STARTED · **Android**：NOT VERIFIED

---

## Implemented

### Lib

| Path | Role |
|------|------|
| `lib/faradays_law/faradays_law_assets.dart` | Asset paths |
| `lib/faradays_law/faradays_law_constants.dart` | + view constants |
| `lib/faradays_law/view/faradays_law_screen.dart` | Screen shell |
| `lib/faradays_law/view/faradays_law_play_area.dart` | Play area + clock + drag |
| `lib/faradays_law/view/faradays_law_mvt.dart` | Layout identity MVT |
| `lib/faradays_law/view/components/bulb_widget.dart` | Bulb |
| `lib/faradays_law/view/components/coil_image_layer.dart` | Coil front/back |
| `lib/faradays_law/view/components/voltmeter_widget.dart` | Voltmeter |
| `lib/faradays_law/view/painters/*` | Magnet, arrows, field lines, wires, voltmeter |

### Assets

`assets/simulations/faradays_law/` — four/two loop front/back + light_bulb_base  
`pubspec.yaml` — registered folder

### Interaction

```text
Pan on magnet
  → moveMagnetToPosition
  → SimulationClock → model.step(dt)
  → B → EMF → voltage → needle / bulb rebuild
```

### Animation

Single `SimulationClock` (60 fps). No per-widget Timers.

---

## Tests

| Suite | Count |
|-------|-------|
| Model (Phase 1) | 49 |
| View (Phase 2) | 10 |
| **Total** | **59 PASS** |

```text
flutter test test/faradays_law/
→ All tests passed!
```

## Analyze

```text
dart analyze lib/faradays_law test/faradays_law
→ No issues found!
```

## Gates

| Gate | Status |
|------|--------|
| Core View | PASS |
| Magnet drag | PASS |
| Coil layers / z-order | PASS |
| Field lines render | PASS |
| Voltmeter / Bulb | PASS |
| Model → View sync | PASS |
| Continuous clock | PASS |
| Reset visual state | PASS |
| Substituted | **0** |
| P0 | **0** |
| P1 | **0** |
| P2 | recorded (5) |
| Home | NOT STARTED |

## Overall

```text
Phase 2 = COMPLETE
Overall  = NOT READY
Home     = NOT STARTED
Android  = NOT VERIFIED
```

**Next**：PHASE 3 — CONTROLS（checkbox / coil selector / Flip / Reset）
