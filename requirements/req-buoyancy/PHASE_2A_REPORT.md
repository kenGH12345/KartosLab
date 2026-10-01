# PHASE_2A_REPORT

```
PHASE 2A STATUS

Scope:
Global / Shared Layout Archaeology

Source:
Buoyancy 1.3.0-dev.2 / LOCAL common 0c835c64

Design Bounds:
PASS (1024×618 via ScreenView.DEFAULT_LAYOUT_BOUNDS)

Global Scaling:
PASS (Joist uniform min-scale + center)

Orientation:
PASS (landscape design; letterbox on host)

Global Coordinate:
PASS (spaces documented; Model +y up)

MVT:
PASS (API: THREEModelViewTransform + camera params)
NOTE: exact THREE matrix internals UNKNOWN without mobius tree — not BLOCKED for archaeology

Global Shell:
PASS (shared sky/THREE/ResetAll; screen-specific panels)

Typography:
PASS

Controls:
PASS (catalogued; anti-Material)

Panels:
PASS

Geometry Tests:
6 PASS (global group in layout_archaeology_test.dart)

P0:
(none)

P1:
- Provenance SHA mismatch (frozen from Phase 0/1A)
- p2 integration APPROXIMATE (frozen — not “fixed” by layout)
- Boat cabin coupling DEFERRED (frozen)
- THREE matrix numeric projection without mobius = OPEN for Composer

P2:
- DebugView 600-scale documented as debug-only

2B:
NOT STARTED → proceed next

2C:
NOT STARTED

Composer:
NOT STARTED

UI:
NOT STARTED

Golden:
0 / 0

Android:
NOT VERIFIED

Home:
NOT STARTED

Status:
READY CANDIDATE
```
