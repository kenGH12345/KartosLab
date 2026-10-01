# INTERACTION AUDIT — Gas Properties Flutter Native

> Status: **INTERACTION_RECOVERY**  
> Ground Truth: local PhET `gas-properties-main` + scenery-phet  
> Date: 2026-09-06  
> Constraint: Model / Solver LOCKED — only HitTest / Gesture / Controller wiring / Transform inverse / View

---

## Coordinate contract

```text
Pointer (device)
  → FittedBox local (reference 1008×618)
  → GasCoordinateTransform.viewToModel*
  → Model (pm)
  → Controller mutation
  → RenderState → Painter
```

All scene hit regions share one `GasCoordinateTransform`. No per-widget ad-hoc % mapping.

---

## Ideal

| Object | Click? | Drag? | Hold? | Axis | Hit area | Controller | Model | Render | Status |
|--------|:------:|:-----:|:-----:|------|----------|------------|-------|--------|--------|
| Heavy FineCoarse | ✓ | — | ✓ repeat | — | spinner buttons | `setNumberHeavy` | particle count | panel | **PASS** |
| Light FineCoarse | ✓ | — | ✓ repeat | — | spinner buttons | `setNumberLight` | particle count | panel | **PASS** |
| Lid handle | — | ✓ | — | X | dilated handle | `setLidWidthFromOpeningLeft` | `lidWidth` | lid | **PASS** |
| Left wall / width | — | ✓ | — | X | left-wall strip | `beginWidthAdjust` / `setWidthDuringAdjust` / `endWidthAdjust` | width + redistribute | walls | **PASS** |
| Heat/Cool slider | — | ✓ | — | Y | heater body | `setHeatCool` | `heatCoolFactor` | flames/ice | **PASS** |
| Pump handle | — | ✓ down | — | Y | pump handle+shaft | `pump(50)` on stroke | particle inject | pump lift | **PASS** |
| Particle type radio | ✓ | — | — | — | dots under pump | `setParticleType` | `particleType` | selection | **PASS** |
| Eraser | ✓ | — | — | — | eraser button | `eraseParticles` | clear particles | empty | **PASS** |
| Thermometer body | — | — | — | — | none (PhET) | — | — | paint | N/A |
| T unit selector | ✓ | — | — | — | readout chevron | `setTemperatureUnitsKelvin` | display flag | label | **PASS** |
| Pressure gauge body | — | — | — | — | none | — | — | paint | N/A |
| P unit selector | ✓ | — | — | — | readout chevron | `setPressureUnitsAtm` | display flag | label | **PASS** |
| Hold Constant radios | ✓ | — | — | — | radio rows | `setHoldConstant` | hold mode | disabled/selected | **PASS** |
| Pause / Step / Reset | ✓ | — | — | — | circle buttons | toggle/step/reset | clock / full reset | UI | **PASS** |
| Tools Width | ✓ | — | — | — | checkbox | `setWidthVisible` | UI flag | width label | **PASS** |
| Tools Stopwatch | ✓ | — | — | — | checkbox | `setStopwatchVisible` | UI + panel | stopwatch | **PASS** |
| Tools Collision Counter | ✓ | — | — | — | checkbox | `setCollisionCounterVisible` | UI + badge | counter | **PASS** |
| Tools Pressure Noise | ✓ | — | — | — | checkbox | `setPressureNoiseEnabled` | pressureSolver | gauge | **PASS** |
| Return Lid | ✓ | — | — | — | button when blown | `returnLid` | `lidIsOn` | lid | **PASS** |

---

## Explore

| Object | Notes | Status |
|--------|-------|--------|
| Left wall drag | `leftWallDoesWork`; velocity via Model `step` | **PASS** |
| Wall velocity checkbox | Tools | **PASS** |
| Lid / Pump / Heat / Cool / Pause / Reset | Shared IdealGasLaw shell | **PASS** |
| Particles FineCoarse | Shared | **PASS** |

---

## Energy

| Object | Notes | Status |
|--------|-------|--------|
| Zoom ± | `zoomIn` / `zoomOut` | **PASS** |
| Injection temperature | checkbox + slider | **PASS** |
| Collisions toggle | Particles panel | **PASS** |
| Heat / Cool / Pump / Pause / Reset | Shared shell; width handle hidden (fixed V) | **PASS** |
| Histograms | paint + zoom controls | **PASS** |

---

## Diffusion

> **Product UI** = unmodified `lib/diffusion` (`DiffusionShell` / `DiffusionModel`) via `GasPropertiesDiffusionTab`.  
> `lib/gas_properties` DiffusionModel remains for physics unit tests only.

| Object | Notes | Status |
|--------|-------|--------|
| Partition toggle | Remove/Reset Divider (lib/diffusion) | **PASS** |
| Left/Right particle / mass / radius / T | NumberSpinner in DiffusionShell | **PASS** |
| COM / Flow / Scale / Stopwatch | checkboxes | **PASS** |
| Normal / Slow | time speed | **PASS** |
| Pause / Step / Reset | timing bar | **PASS** |

Ideal / Explore / Energy may import `lib/diffusion` widgets/painters when useful; **do not modify** `lib/diffusion/**`.

TabBarView uses `NeverScrollableScrollPhysics` so Ideal lid/wall horizontal drag is not stolen.

---

## PhET source anchors (must not invent)

1. **Lid** — `LidHandleDragListener.ts` — horizontal only; opening-left tracking  
2. **Width** — `ResizeHandleDragListener.ts` — Ideal pause+redistribute; Explore work+speed limit  
3. **Pump** — `BicyclePumpNode` — **vertical drag only**, inject on downward stroke (not tap)  
4. **Heater** — `HeaterCoolerFront` VSlider — continuous Y; snap to 0 on release  
5. **Thermometer / Gauge** — body not draggable; ComboBox units only  
6. **FineCoarseSpinner** — ArrowButton fireOnHold 400ms / 100ms; ±1 / ±50  
7. **Diffusion divider** — button toggle, not drag  

---

## Pre-recovery defects

| Defect | Root cause |
|--------|------------|
| Full-screen `GestureDetector` on play area | Guessed lid vs wall by proximity — forbidden |
| Pump `onTap` inject | PhET has no tap inject |
| Unit selectors missing | Display-only painters |
| Spinner no press-hold | Instant tap only |
| Drag not cleared on Reset | Stuck drag residual risk |

---

## Post-recovery architecture

```text
lib/gas_properties/interaction/
  drag_state.dart
  interaction_hit_test.dart
  scene_drag_layer.dart   // Ideal/Explore/Energy scene hits
```

Hit Z-order (top wins): Control panels → Unit selectors → Pump/Heater/Eraser → Lid → Wall → Particles(paint)

---

## Acceptance

```text
Ideal Drag = PASS
Explore Wall Drag = PASS
Pump Interaction = PASS
Heat/Cool Interaction = PASS
Controls / Tools / Pause-Step-Reset = PASS
Energy Controls = PASS
Diffusion Controls = PASS
Interaction Tests = PASS
Physics Regression = PASS
```
