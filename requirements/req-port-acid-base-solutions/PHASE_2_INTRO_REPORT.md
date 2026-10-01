# PHASE 2 — INTRO SCREEN REPORT

**Sim:** PhET Acid-Base Solutions → Flutter  
**Req:** `req-port-acid-base-solutions`  
**Scope:** Intro Screen View only  
**Model lock:** Phase 1 chemistry untouched (52 tests still pass)

---

## PHASE 2 STATUS: PASS

```text
My Solution View: NOT STARTED
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## Viewport / MVT

```text
Viewport / layoutBounds: 768 × 504  (ABSScreenView)
MVT: NONE — model ≡ view, 1:1, +y down
ResetAll scale: 768/1024 = 0.75 → radius 20.5×0.75
```

---

## Intro

| Item | Implementation |
|---|---|
| Screen | `view/intro_screen.dart` (`AbsIntroScreen`) |
| Model | `IntroModel` via `IntroController` (not MySolutionModel) |
| Presets | Water, Strong Acid, Weak Acid, Strong Base, Weak Base |
| Solution Selector | Aqua-style radio panel (`IntroSolutionPanel`) |
| Concentration | **No Intro UI** (source: presets only; C defaults from model) |
| Beaker | Procedural `AbsBeakerPainter` (rim, liquid, ticks, **1L**) |
| Liquid | `transparentSolutionColor` from ABSColors |
| Particles | `AbsParticlesLayer` + cached `IntroController.particles` |
| Particle Count | Phase 1 `absParticleCount` via `AbsParticleField` |
| Particle Lifecycle | Regenerate only on solution change / resetAll — not on rebuild |

### Views

- Particles (magnifier + solvent.png optional via preferences)
- Graph (equilibrium concentration bars)
- Hide Views

### Tools

| Tool | Behavior |
|---|---|
| PH Meter | Drag Y; blank until tip in beaker; readout = `model.pH` |
| PH Paper | Drag; color from `AbsColors.pHToColor`; float via `step` @ **250 px/s** |
| Conductivity Tester | Dual probe drag; brightness from model (`pH==7→0`) |

ToolMode.none **not** exposed in UI.

### Interactions

```text
preset radio → IntroModel.select → chemistry + particle regen
Views radio → AbsViewProperties.viewMode
Tools radio → AbsViewProperties.toolMode (+ interrupt press flags)
meter/paper/probes drag → model tool positions
Reset All → model.reset + viewProperties.reset + particle regen
Ticker → pHPaper.step(dt)
```

### Reset

Verified: solution→Water, tools home, viewMode/particles, toolMode/pHMeter, particle population refreshed.

### Lifecycle

Ticker started in `initState`, disposed in `dispose`. Widget test: enter/interact/reset/leave ×3.

---

## Visual QA (structure)

| State | Coverage |
|---|---|
| Initial Water | default controller + widget pump |
| Strong/Weak Acid/Base | preset switch tests |
| Particles / Graph / Hide | view mode tests |
| PH Meter / Paper / Tester | tool integration tests |
| Reset | resetAll + widget tap Reset |

Screenshot pixel harness: not run (no dedicated ABS screenshot golden in repo).

---

## Assets substituted

```text
Assets substituted: 0
PNG used: solvent, magnifyingGlassIcon, lightBulbIcon
(copied to assets/simulations/acid_base_solutions/images/)
```

Beaker / molecules / equations / graph / meter / paper / probes: **procedural** (source-faithful).

---

## Tests

```text
Previous: 52
Added: 14
Final: 66
All tests passed!
```

Paths:

- `test/chemistry/acid_base_solutions/oracle_*.dart` (Phase 1)
- `test/chemistry/acid_base_solutions/intro_screen_test.dart` (Phase 2)

## Analyze

```text
dart analyze lib/chemistry/acid_base_solutions test/chemistry/acid_base_solutions
→ No issues found!
```

---

## P0 / P1 / P2

### P0
(none)

### P1 (polish — non-blocking for Intro PASS)

1. ConductivityTester chrome is simplified vs full scenery-phet `ConductivityTesterNode` (glow bulb + wires; behavior/oracle OK)
2. Concentration graph: missing rotated Y-axis title + scientific-notation value labels (bars/heights use source formula)
3. No golden screenshot matrix yet for pixel QA

### P2

1. Local audio still unavailable  
2. Typography / spacing micro-deltas vs runtime  
3. Preferences Show Solvent toggled only via model API (dialog UI not in Intro chrome)

---

## File index (new)

```text
lib/chemistry/acid_base_solutions/view/
  intro_screen.dart
  intro_controller.dart
  intro_solution_panel.dart
  abs_assets.dart
  abs_beaker_painter.dart
  abs_particle_painter.dart
  abs_particles_layer.dart
  abs_ph_meter_layer.dart
  abs_ph_paper_layer.dart
  abs_conductivity_layer.dart
  abs_reaction_equation.dart
  abs_concentration_graph.dart
  abs_views_panel.dart
  abs_tools_radio_group.dart
assets/simulations/acid_base_solutions/images/{solvent,magnifyingGlassIcon,lightBulbIcon}.png
```

---

*Phase 2 Intro complete. Do not start My Solution until requested.*
