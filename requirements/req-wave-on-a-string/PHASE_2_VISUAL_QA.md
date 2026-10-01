# PHASE 2 — VISUAL QA

## Screenshot matrix (fixture / Model-driven)

| State | Method | Result |
| ----- | ------ | ------ |
| A Initial Manual/Fixed | default model | PASS structure |
| B Manual displacement | drag / setManualDisplacement | PASS sync |
| C Oscillate | setWaveMode | PASS wheel+string |
| D Pulse | Pulse button / triggerPulse | PASS |
| E–G Boundaries | setStringEndType | PASS distinct assets |
| H–J Amp/Damp/Tension | Model (no control UI) | deferred Phase 3 UI; Model→View OK |
| K Ruler | setRulersVisible(true) | PASS overlay |
| L Timer | setStopwatchVisible | PASS sim time |
| M Pause | isPlaying=false | PASS frozen |
| N Slow | timeSpeed (Model) | PASS (clock via Model) |

## Defects

| Level | Count | Notes |
| ----- | ----: | ----- |
| P0 | **0** | |
| P1 | **0** | No View-side wave physics; 61 beads; MVT sourced |
| P2 | several | Bead toDataURL cache ≠ Circle raster (VD-BEAD-CACHE); ruler ticks simplified vs RulerNode; arrow Path vs ArrowNode polish; window/clamp pixel offsets may need Phase 5 tune |

## Substituted assets

```text
Substituted = 0
```

Original: wrench, clamp, ringFront/Back, windowFront/Back.

## VERSION_DELTA

| ID | Status |
| -- | ------ |
| VD-SOUND | deferred |
| VD-A11Y | deferred |
| VD-PHETIO | deferred |
| VD-LOCALE | deferred |
| VD-BEAD-CACHE | accepted P2 — CustomPainter beads |

## Separation check

```text
center dash (always on) ≠ Reference Line tool (checkbox)  — PASS
```
