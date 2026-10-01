# Graphs Screen Calibration

> 2026-09-04 · Graphs Visual QA layout fix  
> PhET: `1.6.0-dev.2` · Sources: `GraphsScreenView.ts`, `EnergyGraphAccordionBox.ts`, `GraphsConstants.ts`

## Problem (before)

Flutter placed `EnergyGraphOverlay` as a **Stack Positioned** over the entire play area.
The panel became a tall vertical card that covered / compressed Track + Skater.

PhET treats the energy graph as a **short horizontal AccordionBox** (plot height **141**) whose chart width equals `TRACK_WIDTH × MVT` (10 m × 61.40).

## Fix principle

Page-level layout (not overlay):

```
┌─ EnergyGraphPanel (topPanel) ─┬─ ControlColumn ─┐
├─ SimulationViewport (PlayArea)┤                 │
├─ Bottom visibility + time ────┤                 │
└───────────────────────────────┴─────────────────┘
```

- `EspScreenBody.topPanel` reserves vertical space above `EspSimulationViewport`
- `GraphsScreen` no longer uses `playOverlay`
- Deleted `energy_graph_overlay.dart`

## PhET source geometry

| Constant | Value | Source |
|---|---|---|
| `GRAPH_HEIGHT` | **141** | `EnergyGraphAccordionBox.ts:56` |
| `TRACK_WIDTH` | **10** m | `GraphsConstants.ts:52` |
| Plot width | `10 × 61.40 = 614` view-px | `modelToViewDeltaX(TRACK_WIDTH)` |
| Content layout | checkboxes \| y-label+zoom \| plot | `EnergyGraphAccordionBox.ts:285-287` |
| Accordion top | `= controlPanel.top` | `GraphsScreenView.ts:60-61` |
| Chart right align | track x=5 + contentRight | `GraphsScreenView.ts:73` |

## Flutter rects @ 1024×618 (from `graphs_layout_test`)

Captured: `visual-qa/graphs-current.png` · `visual-qa/graphs-layout-rects.json`

| Region | px (x,y,w,h) | Normalized (x,y,w,h) |
|---|---|---|
| Graph | 8, 8, 748, **209** | 0.008, 0.013, 0.730, 0.338 |
| Simulation origin | y=217 (below graph) | y≈0.351 |
| Control | 772, 8, 244, ~606 | 0.754, 0.013, 0.238, 0.980 |
| Bottom time | ~238, 553, 519, 48 | 0.232, 0.895, 0.506, 0.078 |

### Notes on simulation rect

`PlayArea` reports logical FittedBox child size (784×546). Visual bounds are the **Expanded** slot below the graph (y≥217). Graph bottom (8+209=217) ≤ PlayArea top — **no overlay**.

## Graph internal layout (Flutter)

| Element | Flutter | PhET | Tag |
|---|---|---|---|
| Plot height | 141 | GRAPH_HEIGHT 141 | **[源码一致]** |
| Plot width | min(available, 614) | TRACK_WIDTH×MVT | **[源码一致]** |
| Title font | 16 | PhetFont 20 (scaled for CJK) | **[视觉近似]** |
| Expand button | 19×19 geometry | sideLength 19 | **[源码一致]** |
| ABSwitch size | 37×18 target | SWITCH_SIZE | **[行为一致]** |
| Eraser | scenery-phet `eraser.svg` | EraserButton | **[源码直接使用]** |
| Zoom | vertical magnifiers | MagnifyingGlassZoomButtonGroup | **[几何绘制]** |
| Legend | left checkbox column | VerticalCheckboxGroup left of plot | **[源码一致]** |
| Y label + zoom | column left of plot | VBox left of plot | **[源码一致]** |

## QA checklist

| # | Check | Result |
|---|---|---|
| 1 | Graph does not cover simulation | **PASS** (page Column) |
| 2 | Graph does not cover Control | **PASS** (left of right column) |
| 3 | Track keeps horizontal room | **PASS** (FittedBox below graph) |
| 4 | Skater not under graph | **PASS** |
| 5 | Control independent right column | **PASS** |
| 6 | Bottom controls not crushed | **PASS** |

## Remaining deltas (non-blocking)

| Item | Tag |
|---|---|
| PhET floats accordion *inside* play layer (same MVT); Flutter uses reserved top band | **[有意差异·布局]** — same visual hierarchy, cleaner non-overlap |
| Chart right-edge lock to model x=5 | **[视觉近似]** — width matches TRACK_WIDTH×MVT when space allows |
| Pixel diff vs user PhET screenshot | **[待确认]** — compare `graphs-current.png` to reference |

## Tests

```
flutter test test/energy_skate_park/graphs_layout_test.dart
flutter test test/energy_skate_park  → 47 passed
dart analyze lib/energy_skate_park   → clean
```
