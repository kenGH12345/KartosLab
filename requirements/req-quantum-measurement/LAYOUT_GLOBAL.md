# LAYOUT_GLOBAL — Quantum Measurement

> PHASE 2 · Source: joist `ScreenView.ts` + `QuantumMeasurementConstants.ts` + `QuantumMeasurementScreenView.ts`

## DESIGN_CANVAS

```
width  = 1024
height = 618
```

**Evidence (HIGH):** `ScreenView.DEFAULT_LAYOUT_BOUNDS = Bounds2(0, 0, 1024, 618)` (joist).  
QM: `QuantumMeasurementConstants.LAYOUT_BOUNDS = ScreenView.DEFAULT_LAYOUT_BOUNDS`.

## ROOT_LAYOUT_BOUNDS

```
x = 0
y = 0
width = 1024
height = 618
```

Same as design canvas. All four screens use this via `QuantumMeasurementScreenView` → `ScreenView`.

## CONTENT_BOUNDS (usable inset)

```
x = 10
y = 10
width = 1004
height = 598
```

**Evidence:** `SCREEN_VIEW_X_MARGIN = 10`, `SCREEN_VIEW_Y_MARGIN = 10`.

## Responsive / Transform

| Rule | Value | Evidence |
|---|---|---|
| Scale | `min(viewW/1024, viewH/618)` | `ScreenView.getLayoutScale` |
| Alignment | center remaining axis | `getLayoutMatrix` verticalAlign `'center'` (default) |
| Stretch | **No** | uniform scale only |
| Crop | **No** (letterbox/pillarbox in visibleBounds) | same |
| Internal reflow on resize | **Generally no** — children laid in design coords then scaled | ScreenView.layout |

**Nav bar / Home chrome:** Joist sim chrome is **outside** ScreenView layoutBounds. Flutter Home bottom bar is a separate KartosLab concern (later Home phase) — NOT part of PhET layoutBounds.

## Reset All

```
right  = layoutBounds.maxX - 10
bottom = layoutBounds.maxY - 10
```

**Evidence:** `QuantumMeasurementScreenView` ResetAllButton.

## Shared structural primitives

| Primitive | Spec |
|---|---|
| ExperimentDividingLine | vertical dashed Line, height **525**, lineWidth 2, dash [6,5] |
| SceneSelectorRadioButtonGroup | top scene toggle (Coins Classical/Quantum; Photons Single/Many) |
| Fonts | HEADER 20, TITLE 16, CONTROL 14, SCENE_SELECTOR bold 26 (PhetFont) |

## Overlay (global)

| Item | Finding |
|---|---|
| Screen-level dialogs | Photons: `AveragePolarizationInfoDialog` (module-relative) |
| Tooltips | NONE FOUND as floating overlay system in QM screens |
| Reset All | Fixed bottom-right overlay of play area |
| Keyboard help | Joist keyboard help (sim chrome) — not in layoutBounds content |

**Overlay: mostly NONE FOUND at ScreenView root; dialogs are screen-local.**

## Coordinate systems (global)

1. **Layout / ScreenView coords** — 1024×618  
2. **Local view coords** — child of Node after translation  
3. **Physics / model coords** — Photons (meters + MVT scale 640), Spin (MVT scale 180), Bloch (θ/φ → local sphere radius 100)
