# PHASE 4 STATUS — Behavioral surfaces (preliminary)

Scope:
Pump five Screen widgets, Model-driven animation via physics clock, drag via pointer adapter, Reset All, mode/shape/boat-bottle controls.

Not in this phase:
Formal golden gate, Android, Home catalog.

## Behavioral

| Action | Result |
| ------ | ------ |
| Physics step → view | PASS (`BuoyancyPlayArea` ticker → `model.step` → `sceneBuilder`) |
| Drag | PASS (ray/plane → Model drag API) |
| Compare mode + shared slider | PASS |
| Explore A/B visibility | PASS (B omitted from mesh list when hidden) |
| Lab gravity + force flags + V_disp | PASS |
| Shapes 7-kind selector | PASS |
| Applications bottle/boat + interior volume | PASS |
| Cabin basin coupling | DEFERRED (labeled in UI) |
| Reset All | PASS (`KratosResetAllButton`) |

## Tests

Buoyancy: **138 PASS**  
Density: **81 PASS**  
Analyze: **0 errors**

## Status

**PRELIMINARY READY CANDIDATE**

Frozen P1 unchanged:
- p2 integration equivalence = APPROXIMATE
- boat cabin basin coupling = DEFERRED
- provenance SHA mismatch = OPEN

Next (not claimed done): visual golden vs PhET, Home wiring, Android QA.
