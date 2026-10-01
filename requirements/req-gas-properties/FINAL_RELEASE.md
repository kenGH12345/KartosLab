# FINAL RELEASE — Gas Properties Flutter Native

> **Status: DONE / PROJECT_COMPLETE**  
> Closeout date: 2026-09-07  
> Ground Truth: local `phet sourses/gas-properties-main`  
> Code: `lib/gas_properties/` · Diffusion product UI: `lib/diffusion/` (unmodified)

---

## 1. Project Status

```text
Gas Properties Flutter Native Migration
Status: DONE / PROJECT_COMPLETE
```

Phase history: Forensics → Model → Implementation → Validation → Visual Reconstruction → Interaction Recovery → Layout polish (bottom cluster / lid / heater effects) → **Close**.  
No Phase 5+ development cycles.

Audit: `requirements/req-gas-properties/INTERACTION_AUDIT.md`

---

## 2. Screen Coverage

| Screen | Status |
|--------|--------|
| Ideal | **PASS** |
| Explore | **PASS** |
| Energy | **PASS** |
| Diffusion | **PASS** — product UI = unmodified `lib/diffusion` via `GasPropertiesDiffusionTab` |
| Home registration（热学与气体） | **PASS** |

---

## 3. Functional

**PASS** — four screens, particle inventory 0–1000, pump, heat/cool, lid, hold modes, pause/step/reset, diffusion partition/COM/flow, energy histograms/zoom/injection T/collision toggle.

---

## 4. Physics

**PASS** (unit + Phase 4 validation tests)

| Topic | PhET source | Flutter |
|-------|-------------|---------|
| PV = NkT | IdealGasLaw / PressureModel | `GasLawSolver` / `PressureSolver` |
| T ∝ ⟨KE⟩ | TemperatureModel | `TemperatureSolver` |
| Particle–particle / wall | CollisionDetector | `CollisionSolver` |
| Moving wall work | Explore leftWallDoesWork | `IdealGasProfile.explore` + relative vx |
| Ideal resize | pause + redistribute | `beginWidthAdjust` / `endWidthAdjust` |
| Heat/Cool | factor / 800 | `ParticleSystem.heatCool` |
| Pressure gauge 0.75 ps + noise | PressureModel | `PressureSolver.stepGauge` |
| Energy 19 bins / 1 ps / ×7 zoom | HistogramsModel | `EnergySamplingState` |
| Diffusion / Slow 0.3 ps/s / flow 300 | PhET DiffusionModel | product: `lib/diffusion` · legacy unit tests: `gas_properties` DiffusionModel |
| Hold Constant ×5 + Oops | IdealModel | `HoldConstantSolver` |

---

## 5. Interaction

**PASS**

| Control | Notes |
|---------|--------|
| Lid drag | `LidHandleDragListener` semantics |
| Left wall | Ideal pause+redistribute; Explore work |
| Pump / Heat / Cool | Model-backed |
| Hold Constant | Ideal only; Explore/Energy locked |
| Histogram zoom | 7 levels |
| Diffusion partition / COM / Flow / Normal·Slow | Model-backed |
| Stopwatch | Independent Start/Pause/Reset (`isRunning`) |
| Pressure Noise | Toggle in Tools (placement MINOR vs Preferences) |

---

## 6. Visual

**PASS** after **Visual Reconstruction** (Ideal Screen · 2026-09-06)

| Severity | Count | Notes |
|----------|------:|-------|
| P0 | **0** | No missing Ideal regions |
| P1 | **0** | Right rail / gauge / thermometer / pump / heater / bottom controls re-anchored |
| P2 | remaining | scenery-phet chrome fidelity (bevels, exact FineCoarseSpinner art, hose path) |
| P3 | remaining | 1px / AA / font metrics |

Ground truth: `screenshots/ideal/phet/initial.png`  
Flutter: `screenshots/ideal/flutter/initial.png`

---

## 6.1 Visual Reconstruction

```text
Model: unchanged
Solver: unchanged
Physics behavior: unchanged
View: reconstructed
Transform: calibrated (IdealLayoutSlots + single global scale)
Painter: corrected (thermometer / gauge / pump / heater / eraser)
Widgets: reconstructed (Particles FineCoarse / Hold / Tools / PhET circle buttons)
```

### Pre-fix P1 issues (addressed)

1. Right control panel clipped / squeezed by scene
2. Hold Constant overlapping other UI
3. Pressure Gauge overlapping control panel
4. Thermometer / Pump / Heater Material-button approximations
5. Particle spinner ≠ FineCoarseSpinner layout
6. Bottom Pause / Step / Reset not PhET circular placement
7. Coordinate system mixed `%` / Column flow vs reference space

### Fix approach

- Reference space **1008×618** → one `FittedBox` / global `layoutScale`
- Scene instruments anchored via `IdealLayoutSlots` (PhET IdealGasLawScreenView)
- Right rail = independent region `[panelsLeft … panelsRight]`
- Gauge / thermometer / pump / heater stay in **Simulation Scene** Z-layer

### Post-fix

| Check | Result |
|-------|--------|
| Model / Solver / Physics tests | **UNCHANGED / PASS** |
| Ideal Layout | **PASS** |
| P0 / P1 | **0 / 0** |
| Analyze | **0** |
| `test/gas_properties/` | **53 PASS** |
| `apk --debug` | **PASS** |

---

## 6.2 Interaction Recovery

```text
Model: unchanged
Solver: unchanged
Physics behavior: unchanged
HitTest: discrete regions (Lid / Wall / Pump / Heater / Units)
Gesture: DragState machine (Idle ↔ Dragging + cancel/reset clear)
Controller: wired to existing mutations only
```

| Gate | Result |
|------|--------|
| Ideal Drag (lid / wall) | **PASS** |
| Explore Wall Drag | **PASS** |
| Pump (downward stroke inject, no tap) | **PASS** |
| Heat/Cool continuous + snap-0 | **PASS** |
| Controls / Tools / Pause·Step·Reset | **PASS** |
| Energy Controls | **PASS** |
| Diffusion Controls | **PASS** |
| Unit selectors (T / P) | **PASS** |
| FineCoarse press-hold | **PASS** |
| Interaction tests | **PASS** |

Architecture: `lib/gas_properties/interaction/`  
Inventory: `INTERACTION_AUDIT.md`

---

## 7. Performance

**PASS / KNOWN LIMITATION**

| N | FrameTiming FPS | Evidence |
|---|----------------:|----------|
| 100 | ≈56 | Pixel Tablet **emulator** · profile |
| 500 | ≈46 | same |
| 1000 | ≈46 | same; EGL steady ≈10 ms |

```text
Android Pixel Tablet emulator / profile evidence
No physical Android device connected
```

Optimizations kept: panel throttle 100 ms, RenderState cache, Paint reuse.  
**Do not claim strict 60 FPS.** Do not fake metrics.

---

## 8. Tests / Build

```text
flutter analyze lib/gas_properties     → 0 issues
flutter test test/gas_properties/      → 73 PASS + 2 known golden drift
flutter build apk --debug              → PASS (earlier closeout)
```

| Suite | Result |
|-------|--------|
| Model / Solver / Interaction | **PASS** |
| Ideal / Explore / Energy goldens | **PASS** |
| Diffusion product interaction (`lib/diffusion` embed) | **PASS** |
| Diffusion screenshot goldens (`initial` / `partition_removed`) | **KNOWN DRIFT** — baselines predate `GasPropertiesDiffusionTab` → `lib/diffusion`; not a physics regression |

Full-repo `flutter test` (2026-09-06 closeout): **+1533 ~1 -2** unrelated (`keplers_home_nav_test`, `forces_scenario` timeout).

---

## 9. Known Differences (P2/P3 only)

1. Pump / heater / gauge / thermometer are CustomPainter approximations (not full scenery-phet Node trees)
2. Collision Counter is a badge panel (not fully draggable scenery chrome)
3. Pressure Noise remains a Tools checkbox (not Preferences dialog)
4. FrameTiming average below strict 60 FPS (~46 @500/1000 on emulator)
5. Screenshot PhET side is the Ideal Ground Truth PNG provided for Visual Reconstruction
6. Explore / Energy inherit IdealGasLaw shell layout; Energy left histograms remain simplified chrome
7. Diffusion screenshot goldens not refreshed after embedding `lib/diffusion`
8. Collision Counter not fully draggable floating scenery tool

### Late polish (accepted into DONE)

| Item | Result |
|------|--------|
| Bottom-right cluster `[hose][Pump][Tools] / [eraser][Heavy][Light] / [Reset]` | **DONE** |
| Lid = right-anchored bar + right-end ribbed handle; escape via opening | **DONE** |
| Heater flames / ice intensity vs factor | **DONE** |
| `TabBarView` never-scroll so Ideal lid/wall horizontal drag works | **DONE** |

---

## 10. Architecture

```text
IdealGasLawModel | (product Diffusion = lib/diffusion DiffusionModel)
  ↓
Solver (collision / P / T / hold / histogram / gas law)  [Ideal family]
  ↓
Controller (Ticker → stepRealTime → notify)
  ↓
Transform / IdealLayoutSlots / GasRenderState
  ↓
Painter + Interaction hit regions
  ↓
GasIdealFamilyShell | GasPropertiesDiffusionTab → DiffusionShell
```

- **Ideal / Explore / Energy** share `IdealGasLawModel` (+ profile flags).
- **Diffusion (product)** embeds unmodified `lib/diffusion`. Do not modify `lib/diffusion/**` for this sim.
- Legacy `gas_properties` DiffusionModel retained for older physics unit tests only.
- No WebView; no fake physics in View.

Tooling (not product path): `gas_properties_capture_main.dart`, `gas_properties_perf_main.dart` / harness — validation only.

---

## 11. Final Verdict

```text
Status: DONE / PROJECT_COMPLETE
Model: UNCHANGED / LOCKED
Solver: UNCHANGED / LOCKED
Visual: VISUAL_READY
Interaction: INTERACTION_READY
Diffusion UI: lib/diffusion (unmodified)
Analyze: 0
Tests: 73 PASS (+ 2 known diffusion golden drift)
```

**Project closed.** Do not open Phase 5+. Further work only by explicit product request.
