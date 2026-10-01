# Functional Gap Closure · Energy Skate Park

> Updated 2026-09-04 · Gravity custom + prior closure

## Closed — Gravity (2026-09-04)

| Item | Status | Notes |
|---|---|---|
| Custom gravity magnitude [1,26] | **[行为一致]** | Was **[迁移功能缺口]** on combo screens |
| Combo Custom display (exact ===) | **[行为一致]** | `PhysicalComboBox` adapter; no Earth snap |
| Slider + 1-decimal readout (non-Intro) | **[行为一致]** | `GravityNumberControl` decimalPlaces:1 |
| Intro slider-only | **[行为一致]** | `IntroScreenView` includeGravitySlider |
| Gravity → PE / solver immediate | **[行为一致]** | `EspModel.gravityMagnitude` → `updateEnergy` |
| Reset → 9.8 | **[源码一致]** | `Skater.gravityMagnitudeProperty.reset` |
| Tests | Done | `gravity_test.dart` · suite **60** passed |

## Closed (prior closure pass)

| Item | Status | PhET source |
|---|---|---|
| **Return tool to toolbox** | **[行为一致]** | `EnergySkateParkScreenView.ts` intersectsBounds |
| Measuring tape / stopwatch return | **[行为一致]** | base bounds / node bounds |
| Checkbox / tab / scenery-phet icons | **[源码直接使用]** / **[几何绘制]** | see ASSET_MAPPING |
| Graphs page layout (topPanel) | **[视觉已对齐]** | GRAPHS_SCREEN_CALIBRATION.md |

## Previously closed (unchanged)

| Item | Status |
|---|---|
| Hermite / stepEuler / energy / track physics | **[源码一致]** — not modified |
| Measurement drag / Playground CAD / Home tabs | **[行为一致]** |

## Still open

| Item | Status |
|---|---|
| Delete/Backspace keyboard return + erase sound | **[待实现]** |
| Stopwatch play/pause on overlay | **[行为近似]** |
| Non-usa locale skater sets | **[待实现]** |
| Bar graph checkbox geometry | **[视觉近似]** |
| Pixel screenshot diff vs reference | **[待确认]** |
| Keyboard track connect (Playground) | **[有意差异]** |
| Acceleration units toggle (m/s² vs N/kg) | **[待实现]** — prefs |

## Gravity pipeline

```
GravityControls (slider / combo)
  → EspController.setGravityMagnitude
  → EspModel.gravityMagnitude (clamp [1,26] + updateEnergy)
  → Skater.gravityMagnitude / gravity(=−mag)
  → PhysicsSolver (SkaterState.gravity) + PE/KE render
```

Selecting Combo **Custom** does not write the model (PhET `if (value)`); Custom appears when magnitude ∉ {1.6, 9.8, 24.8}.

## Return-to-toolbox spec (from source)

```
Drag end → globalBounds.intersects(toolboxPanel.globalBounds) → visible=false
Measuring tape: base image bounds only (not tip)
Stopwatch hide: isRunning=false, time=0 (positions preserved)
No animation · no easing · no snap position
```

## Legend

- **[源码一致]** / **[行为一致]** / **[视觉已对齐]** / **[视觉近似]** / **[有意差异]** / **[待实现]** / **[待确认]**
