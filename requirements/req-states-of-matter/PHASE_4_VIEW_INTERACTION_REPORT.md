# PHASE 4 — View / Interaction Report · States of Matter

> req-id: `req-states-of-matter`  
> Date: 2026-09-15  
> Scope: **States + Phase Changes + Interaction** (functional; Phase Changes / Interaction not pixel-perfect)

---

## Status

| Screen | Status |
|---|---|
| States | Implemented (layout + controls + particle render) |
| Phase Changes | Implemented (functional: pump, hand, gauge, diagram, LJ graph, Adjustable) |
| Interaction | Implemented (functional: DualAtom LJ, forces, drag, pair selector) |
| Home integration | **Deferred** (do not modify `home_screen.dart`); in-sim tabs via `StatesOfMatterHome` |

---

## Files Added / Updated (this slice)

```
lib/chemistry/states_of_matter/
  model/phase_changes_model.dart
  model/dual_atom_model.dart
  model/atom_pair.dart
  model/motion_atom.dart
  model/force_display_mode.dart
  model/sigma_table.dart
  model/multiple_particle_model.dart          # injectMoleculesFromPump(+3)
  controller/phase_changes_controller.dart
  controller/atomic_interactions_controller.dart
  painters/dial_gauge_painter.dart
  painters/phase_diagram_painter.dart
  painters/lj_potential_graph_painter.dart
  widgets/pointing_hand_lid_control.dart
  widgets/bicycle_pump_button.dart
  widgets/phase_changes_substance_panel.dart
  screens/phase_changes_screen.dart
  screens/atomic_interactions_screen.dart
  screens/states_of_matter_home.dart          # tabs 2 & 3 wired
  transform/som_coordinate_transform.dart     # viewToModelDeltaY
  som_assets.dart                             # pushPin
  som_strings.dart
  states_of_matter.dart                       # barrel exports

test/states_of_matter/
  phase_changes_model_test.dart
  dual_atom_model_test.dart

tool/_run_som_analyze.bat
```

---

## Screen 1 — States (unchanged contract)

| Element | Anchor |
|---|---|
| Logical viewport | FittedBox / AspectRatio **834/504** |
| MVT | model (0,0) → `(0.325W, 0.75H)`, scale `280/10000` |
| Controller | `StatesOfMatterController` + `MultipleParticleModel({neon, argon})` |

Painters **do not** advance physics.

---

## Screen 2 — Phase Changes (functional)

| Element | Behavior |
|---|---|
| Model | `PhaseChangesModel` extends MPM; valid `{neon, argon, adjustableAtom}` |
| Lid hand | `SomAssets.pointingHand` drag → `targetContainerHeight` (1500–10000); expand≤1500/s shrink≤1250/s |
| Dial gauge | `DialGaugePainter` reads `pressure` (atm display) |
| Pump | `injectMoleculesFromPump(3)` when `isPumpEnabled` |
| Return lid | Yellow button when `isExploded` |
| Substance panel | Neon / Argon / Adjustable + epsilon slider → `setEpsilon` |
| Phase diagram | Simplified painter; marker from mapped T/P |
| LJ graph | `LjPotentialCalculator` from `getSigma`/`getEpsilon` |

---

## Screen 3 — Interaction (functional)

| Element | Behavior |
|---|---|
| Model | `DualAtomModel` 1D LJ along x; NORMAL/SLOW time multipliers |
| Atoms | Fixed (pushPin asset) + grabbable movable; drag pauses motion |
| Forces | Radios: hide / total / components (custom arrows, not Material Icons) |
| Pair selector | Neon-Neon / Argon-Argon / Adjustable (+ epsilon slider) |
| Potential graph | Shared `LjPotentialGraphPainter` with distance marker |

---

## Assets

| Asset | Path | Use |
|---|---|---|
| solid / liquid / gas icons | `mipmaps/*.png` | States phase control `[原版资源一致]` |
| pointingHand | `mipmaps/pointingHand.png` | Phase Changes lid `[原版资源一致]` |
| pushPin | `images/pushPin.png` | Interaction fixed atom `[原版资源一致]` |

No Material Icons as PhET phase / hand / pin substitutes.

---

## Tests

| Suite | Count (approx) |
|---|---|
| Existing (transform, LJ, data set, verlet, MPM, States smoke) | 19 |
| `phase_changes_model_test.dart` | 6 |
| `dual_atom_model_test.dart` | 4 |
| **Total** | **29** All passed via `tool\_run_som_tests.bat` |

Analyze: `tool\_run_som_analyze.bat` → No issues on `lib/chemistry/states_of_matter` + `test/states_of_matter`.

---

## Known gaps (OK / deferred)

- **Water / Diatomic Oxygen** substance rows & engines still deferred
- Phase Changes / Interaction **not pixel-perfect** vs PhET (functional first)
- Bicycle pump is simplified button (+3), not full `BicyclePumpNode` hose animation
- Phase diagram / LJ graph simplified geometry (data-driven, not full accordion chrome)
- Heterogeneous Interaction pairs (Ne-Ar, O2 mixes) not in reduced selector
- Visual QA harness + ASSET_MAP Substituted=0 Final Gate still open
- App `home_screen.dart` entry still deferred
