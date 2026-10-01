# VISUAL_LAYOUT_BASELINE · States of Matter

> req-id: `req-states-of-matter`  
> Date: 2026-09-16  
> Source: local PhET **1.3.0-dev.3**  
> Status: **GEOMETRY RECONSTRUCTION IN PROGRESS**

---

## Coordinate pipeline (single transform)

```text
Viewport (e.g. 1280×800 Visual QA / Home content area)
        ↓  SomSceneLayout.fitScale = min(W/834, H/504)
Physical = 834×scale × 504×scale
        ↓  Transform.scale(scale) inside SomSceneShell
Logical ScreenView layoutBounds = 834 × 504
        ↓  SomCoordinateTransform (States / Phase Changes)
           or SomInteractionTransform (Interaction)
Model / widgets in logical px
```

**Forbidden:** FittedBox + unscaled 834×504 centered in a larger capture viewport  
(was the root cause of “content shrunk / giant black margins” in FLUTTER PNGs).

| Space | Size | Notes |
|---|---|---|
| PhET `SCREEN_VIEW_OPTIONS.layoutBounds` | 834 × 504 | `SOMConstants.ts` |
| MPM container (model) | 10000 × 10000 pm | physics — do not change for visual |
| MPM → view scale | 280 / 10000 = 0.028 | `VIEW_CONTAINER_WIDTH` |
| MPM origin (0,0) in view | (271.05, 378) | `0.325W`, `0.75H`, Y inverted |
| Interaction MVT | (0,0)→(145,360), scale 0.25 | **not** inverted |

---

## States (`StatesSceneLayout`)

| Component | x | y | w | h | Anchor / Notes |
|---|---|---|---|---|---|
| Particle area (initial) | 271.05 | 98 | 280 | 280 | MVT bounds |
| Thermometer | centerX − 0.3×W_model | area.top − 55 | 56 | — | PhET thermometerXOffset |
| Heater | area.centerX | area.bottom + 30 | ×0.79 | — | scale 0.79 |
| TimeControl | heater.left − 50 | heater.centerY | ~70 | — | |
| Molecules panel | right − 15 | top + 10 | 175 | ~148 | |
| Phase buttons | right − 15 | below molecules + 10 | 175 | — | was overlapping — fixed |
| Reset | right − 15 | bottom − 5 | r=17 | — | |

---

## Phase Changes (`PhaseChangesSceneLayout`)

| Component | x | y | w | h | Anchor / Notes |
|---|---|---|---|---|---|
| Particle area | same MVT as States | | 280 | 280 | |
| Pressure gauge | right = area.left+0.2W | area.top − 75 | 100 | 110 | **left of lid**, not right |
| Thermometer | −0.15×W_model | area.top − 55 | 56 | — | |
| Pointing hand | lid centerX | lidTop − 8 | 90 | — | asset |
| Pump translation | 106 | 466 | 90 | 110 | PhET `Vector2(106,466)` |
| Hose attach | area.left | area.bottom − 70 | — | — | scene-level hose |
| Heater / TimeControl | same rules as States | | | | |
| Right panels | right − 15 | stacked | 170 | — | substances / LJ / phase diagram |
| Reset | right − 15 | bottom − 5 | r=17 | — | |

---

## Interaction (`InteractionSceneLayout`)

| Component | x | y | w | h | Anchor / Notes |
|---|---|---|---|---|---|
| Fixed atom | MVT(0,0)=(145,360) | | r×0.25 | — | push pin above |
| Movable atom | MVT(x,0) | | r×0.25 | — | drag → viewToModelX |
| Potential graph | 145 − 31 = 114 | inset+5 | 320 | 180 | SoM basic graphXOffset −31 |
| Atoms panel | reset.left − 20 | inset | 209 | — | |
| TimeControl | centerX+20 | bottom − 14 | — | — | |
| Reset | right − 15 | bottom − 5 | r=17 | — | |

---

## P1 checklist (Major Geometry)

| Criterion | States | Phase Changes | Interaction |
|---|---|---|---|
| Scene fills viewport (Joist-like scale) | improved (re-captured) | improved | improved |
| Container relative scale | improved | improved | n/a |
| Right panel placement / no overlap | mostly (minor Water/Solid gap) | Column stack (re-fix) | OK |
| Pump + hose + gauge | n/a | gauge LEFT + hose connected | n/a |
| Graph + atom pair MVT | n/a | n/a | MVT 0.25 @ (145,360) |
| No major clipping | pending polish | pending polish | pending polish |

**Round-1 verdict:** Scene underscale root cause fixed; Phase gauge/hose/pump anchors corrected; Interaction MVT restored.  
Right-panel chrome / accordion sizing / piston hand scale remain **P1 residuals** — not READY.  
P2 chrome still blocked.

---

## Implementation map

| File | Role |
|---|---|
| `transform/som_scene_layout.dart` | fitScale |
| `widgets/som_scene_shell.dart` | single scale shell |
| `transform/som_coordinate_transform.dart` | MPM MVT |
| `transform/som_interaction_transform.dart` | Interaction MVT |
| `layout/states_scene_layout.dart` | States anchors |
| `layout/phase_changes_scene_layout.dart` | Phase Changes anchors |
| `layout/interaction_scene_layout.dart` | Interaction anchors |
