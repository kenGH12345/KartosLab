# PHASE 4 — View / Interaction Report

## Architecture

```
GaoController (ChangeNotifier + SimulationClock 60fps)
  → GaoModel / GaoScene / GaoPhysicsEngine
  → GaoMvt
  → Painters (grid/path/vectors) + GaoBodiesLayer (Image.asset)
  → Controls (scene/gravity/checkbox/mass/zoom/time/reset)
```

## Interactions verified in code

| Action | Behavior |
|---|---|
| Drag body | position only; clearPath; rewind save when paused |
| Drag velocity tip | v from tip via scale; clearPath |
| Play/Pause/Step | clock ↔ model.step / stepWhilePaused |
| Slow/Normal/Fast | engine.timeSpeed substeps |
| Gravity on/off | coast vs PEFRL |
| Path checkbox on | clearPath then record |
| Scene select | swap active scene (independent engines) |
| Scene reset | bodies+time for scene |
| Return Objects | pause + rewind |
| Reset All | KratosResetAllButton → model.resetAll |
| Clear | simulationTime=0 only |

## UI gaps / P1–P2

| Item | Severity | Notes |
|---|---|---|
| Measuring tape stub | P1 | Needs full MeasuringTapeNode port |
| Panel pixel spacing | P2 | Visual QA |
| Explosion animation | P2 | collided hides body; SunRenderer spikes TBD |
| Velocity snap &lt;10px → 0 | P2 | PhET DraggableVectorNode |

## Lifecycle

Controller.dispose → clock.dispose；embedded tabs own controllers per screen.
