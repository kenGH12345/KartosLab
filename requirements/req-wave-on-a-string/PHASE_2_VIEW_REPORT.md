# PHASE 2 — VIEW REPORT

## Status

```text
Phase 2 = COMPLETE
Overall = NOT READY
```

## Implemented

| File | Role |
| ---- | ---- |
| `lib/wave_on_a_string/view/woas_layout.dart` | 1024×618 + MVT helpers + asset paths |
| `lib/wave_on_a_string/view/woas_string_painter.dart` | polyline + 61 beads |
| `lib/wave_on_a_string/view/woas_start_node.dart` | Manual/Oscillate/Pulse left apparatus |
| `lib/wave_on_a_string/view/woas_end_node.dart` | Fixed/Loose/No End |
| `lib/wave_on_a_string/view/woas_overlays.dart` | center line, rulers, stopwatch |
| `lib/wave_on_a_string/view/woas_play_area.dart` | clock + Stack + sync |
| `lib/wave_on_a_string/view/woas_screen.dart` | thin shell (no Home) |
| `assets/simulations/wave_on_a_string/*.png` | original PhET bitmaps |

## Model subscription

```text
initState → addListener → setState
SimulationClock → model.step(dt)
dispose → removeListener + clock.dispose
```

## Interaction (Phase 2)

- Manual wrench vertical drag → `setManualDisplacement` → Model → beads
- Pulse button (play-area) → `triggerPulse`
- Reference line drag when visible
- Control panel / mode radios / ResetAll / TimeControl → **Phase 3**

## Rendering strategy

- One `CustomPainter` for string+beads (no 61 AnimationControllers)
- Original PNGs for wrench/clamp/rings/windows
- Arrows: Path painter (source ArrowNode equivalent; not Material Icons)

## Model delta (minimal)

Added visibility/position notify setters for tools (`setRulersVisible`, `setReferenceLineVisible/Y`, `setStopwatchVisible`) so View can rebuild — no physics change.

## Tests

```text
flutter test test/wave_on_a_string/ → 57 PASS
dart analyze → CLEAN
```

## Not in Phase 2

BottomControlPanel, mode/end radios, Restart, ResetAll, TimeControl, Home.
