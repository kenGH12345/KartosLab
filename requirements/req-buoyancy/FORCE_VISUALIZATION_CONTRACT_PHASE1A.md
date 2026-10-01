# Force Visualization Contract — PHASE 1A

No View implementation in this phase.

| Item | Source | Contract |
| --- | --- | --- |
| Gravity force | `mass.gravityForce` = (0, -mg) | View reads y; tip = -Fy × zoom × 20 |
| Buoyancy force | `mass.buoyancyForce` = (0, ρ V_sub g) | Same mapping |
| Contact force | contact y only in arrows | Model may store full; view uses y |
| Zoom | `vectorZoomLevel` 0..7, scales 2^-8 .. 2^-1; default level 4 → 1/16 | `ForceVisualizationContract` |
| Visibility | DisplayProperties booleans | Screen Model later |

Flutter: `lib/buoyancy/domain/force/force_visualization_contract.dart`.
