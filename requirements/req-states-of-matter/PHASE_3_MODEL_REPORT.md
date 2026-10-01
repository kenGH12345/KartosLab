# PHASE 3 — Model Report · States of Matter

> req-id: `req-states-of-matter`  
> Date: 2026-09-15  
> Scope: MultipleParticleModel — monatomic + diatomic O₂ + water

---

## Summary

Phase 3 model core under `lib/chemistry/states_of_matter/model/` now includes
**monatomic (Neon/Argon/Adjustable)** plus **diatomic oxygen** and **water**
engines, ported from PhET `js/common/model/engine/*`.

Physics follows PhET Verlet + phase changers (including extracted liquid/solid
snapshots). Unit tests green under `test/states_of_matter/` (**35** total).

---

## Delivered Model Components

| Component | Path | Status |
|---|---|---|
| Constants / colors / attributes | `som_constants.dart`, `atom_attributes.dart` | Done |
| Enums | `atom_type`, `substance_type`, `phase_state` | Done |
| `MoleculeForceAndMotionDataSet` | + water rotational inertia from `WaterMoleculeStructure` | Done |
| `LjPotentialCalculator` | `lj_potential_calculator.dart` | Done |
| Monatomic Verlet / phase | `engine/monatomic_*` + `data/monatomic_liquid_states` | Done |
| Diatomic O₂ | `diatomic_atom_position_updater`, `diatomic_verlet_algorithm`, `diatomic_phase_state_changer` + `data/diatomic_liquid_states` | Done |
| Water | `water_molecule_structure`, `water_atom_position_updater`, `water_verlet_algorithm` (coulomb charges), `water_phase_state_changer` + `data/water_phase_states` | Done |
| `HydrogenAtom` | `hydrogen_atom.dart` | Done |
| `MultipleParticleModel` | `initializeDiatomic` / `initializeTriatomic` wired | Done |
| Thermostats | `engine/kinetic/*` | Done |

---

## Substance init counts (solid)

| Substance | Molecules | Atoms | Notes |
|---|---|---|---|
| Neon (monatomic) | 100 | 100 | unchanged |
| **Oxygen (O₂)** | **50** | **100** | `pow(round(W/((r·2.1)·3)),2)` then even |
| **Water** | **76** | **228** | `ceil(pow(across/3, 2))` to match PhET dumps (float formula ≈75.11) |

---

## Oxygen / Water status

| Item | Status |
|---|---|
| DiatomicAtomPositionUpdater | Ported |
| DiatomicVerletAlgorithm | Ported |
| DiatomicPhaseStateChanger + liquid snapshot | Ported / extracted |
| WaterMoleculeStructure | Ported |
| WaterAtomPositionUpdater | Ported |
| WaterVerletAlgorithm (charges) | Ported formulas exactly |
| WaterPhaseStateChanger + solid/liquid snapshots | Ported / extracted |
| States substance selector (O₂ + Water) | Updated |
| Phase Changes substance panel (O₂ + Water) | Updated |
| Monatomic path regression | Tests still green |

### Snapshot extraction notes

- Source: PhET `DiatomicPhaseStateChanger.ts` / `WaterPhaseStateChanger.ts` embedded objects
- Tooling: Node eval → JSON under `model/engine/data/`; `tool/gen_o2_water_phase_states.py` → Dart maps
- Trimmed PhET dump `+1` rotation entries to `numberOfMolecules` (O₂ liquid rotA/R was 51 for 50 mol; water liquid 77 for 76)
- Water molecule count: PhET `Math.pow(across/3,2)` ≈ 75.11; solid/liquid dumps use **76** → Dart uses `.ceil()`

---

## Verified Behaviors (tests)

- Neon solid init → 100 molecules (unchanged)
- O₂ solid init → 50 molecules / 100 atoms
- Water solid init → 76 molecules / 228 atoms
- `setPhase` solid/liquid/gas for O₂ and water does not throw
- `step` advances for O₂ and water
- `reset` after O₂/water restores solid Neon
- Prior monatomic / PhaseChanges / DualAtom / smoke tests still pass

**Test total: 35** · `tool/_run_som_tests.bat` PASS  
**Analyze: Errors=0 Warnings=0** · `tool/_run_som_analyze.bat` PASS

---

## Intentionally Deferred

| Item | Reason |
|---|---|
| Home / `home_screen.dart` wiring | Final Gate (do not modify) |
| Water H render-order in painter | Model flag present; painter polish later |
| Visual QA screenshots | View phase |

---

## Handoff

Controllers:

- States: `validSubstances: {neon, argon, diatomicOxygen, water}`
- Phase Changes: `{neon, argon, diatomicOxygen, water, adjustableAtom}`

Coordinate contract unchanged:

- layoutBounds **834×504**
- MVT inverted-Y: model (0,0) → `(0.325W, 0.75H)`, scale `280/10000`
