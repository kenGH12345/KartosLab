# PHASE_1_MODEL_REPORT — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **Date**: 2026-09-23  
> **Scope**: Chemistry / Equation / Molecule / Coefficient / Balance / Dataset foundation only  
> **No UI** implemented

---

## PHASE 1 STATUS: PASS

---

## A. Dependency

| Dependency | Target SHA | Resolution |
|------------|------------|------------|
| **nitroglycerin** | `ca115ad1233059957fa599a7c249feef1cbfacac` | **PASS (semantics)** — `Element.ts` / `Atom.ts` verified via WebFetch at exact SHA; vendored under `phet sourses/nitroglycerin/` + `RESOLVED.json`. Full git clone blocked by network reset. |
| **vegas** | `6e4726b37f53b3d0fe6ea713787094c69d3beea3` | **DEFERRED** — not required for Phase 1 chemistry model (GameTimer / Stars / Reward → Phase 4). Local clone also network-blocked. |
| axon / joist / scenery / … | per `dependencies.json` | N/A for Phase 1 Dart model |

**Dependency Resolution (Phase 1 chemistry): PASS**

- Element / Atom identities and radii/colors match nitroglycerin SHA.  
- Molecule catalogue and equation datasets come from BCE local source (already present).  
- **P2**: Full nitroglycerin `MoleculeNode` geometry tree still needed before Particles visual phase; must clone/vendor before Phase 2/5.

No invented chemistry engine. No substitute 3D package.

---

## B. Model Mapping

| Concept | Source | Flutter |
|---------|--------|---------|
| Element | `nitroglycerin/Element` | `BceElement` |
| Atom | `nitroglycerin/Atom` | `BceAtom` |
| Molecule | `common/model/Molecule` | `BceMolecule` |
| EquationTerm | `EquationTerm` | `EquationTerm` |
| Coefficient | `coefficientProperty` | `EquationTerm.coefficient` (+ `CoefficientRange`) |
| balancedCoefficient | `EquationTerm.balancedCoefficient` | same |
| Equation | `Equation` | `Equation` |
| isBalanced | `isBalancedProperty` | `Equation.isBalanced` |
| isSimplified | `isSimplifiedProperty` | `Equation.isSimplified` |
| balance() | `Equation.balance()` | copies balanced → user coeffs |
| AtomCount | `AtomCount` | `AtomCount` |
| ViewMode | `ViewMode` | `ViewMode` |
| ReactionType | EquationsModel union | `ReactionType` |

Map file: `PHASE_1_MODEL_MAP.md`

---

## C. Dataset

| Pool | Source count | Flutter count | Match |
|------|--------------|---------------|-------|
| Intro | 3 | 3 | YES |
| Equations (S+D+C) | 4+4+4=12 | 12 | YES |
| Game L1 | 21 | 21 | YES |
| Game L2 | 11 | 11 | YES |
| Game L3 | 14 | 14 | YES |
| **Total** | **61** | **61** | **YES** |

Stable `Equation.id` (tandem-style); uniqueness tested.

Molecules catalogue: **38** statics (matches `Molecule.ts`).

---

## D. Balance Semantics (LOCKED)

### Source-truth algorithm

```text
multiplier = reactants[0].coefficient / reactants[0].balancedCoefficient
isBalanced ⇔ ∀ term: coefficient ≠ 0 ∧ coefficient == multiplier × balancedCoefficient
isSimplified ⇔ ∀ term: coefficient == balancedCoefficient
```

`equation.balance()` = set each user coefficient to its **stored** `balancedCoefficient`  
(**not** a runtime linear solver; canonical coeffs live in datasets).

### Test results

| Case | isBalanced | isSimplified |
|------|------------|--------------|
| `2 H₂ + O₂ → 2 H₂O` | **true** | **true** |
| `4 H₂ + 2 O₂ → 4 H₂O` | **true** | **false** |
| `6 H₂ + 3 O₂ → 6 H₂O` | **true** | **false** |
| `0 + 0 → 0` | **false** | false |
| Ammonia simplified `1 N₂ + 3 H₂ → 2 NH₃` | **true** | **true** |
| Ammonia N=2 `2 N₂ + 6 H₂ → 4 NH₃` | **true** | **false** |
| Intro methane `balance()` | **true** | **true** |
| All 61 dataset equations after `balance()` | **true** | **true** (+ atom conservation) |

**Note:** Source Intro ammonia balanced coeffs are **1:3:2**, not textbook `2:3:2`. Documented in tests.

### Coefficient ranges (source)

| Screen | min | max | default initial |
|--------|-----|-----|-----------------|
| Intro | 0 | 3 | 1 |
| Equations | 0 | 6 | 1 |
| Game | 0 | 7 | 1 |

---

## E. Tests

```text
flutter test test/balancing_chemical_equations/
→ +26 All tests passed!
```

Coverage: Element, Molecule composition, Coefficient clamp/reset, isBalanced / isSimplified / balance(), AtomCount, dataset counts, unique ids, all-equations balance integrity.

FAIL: 0

---

## F. Analyze

```text
dart analyze lib/balancing_chemical_equations test/balancing_chemical_equations
→ No issues found!
```

---

## G. P0 / P1 / P2

| Level | Count | Items |
|-------|-------|-------|
| **P0** | **0** | — |
| **P1** | **0** | — |
| **P2** | 2 | (1) Full nitroglycerin MoleculeNode tree not cloned — needed before Particles UI. (2) vegas not fetched — needed Phase 4 Game chrome. |

---

## H. Code layout (created)

```text
lib/balancing_chemical_equations/
  balancing_chemical_equations.dart
  bce_constants.dart
  model/
    bce_element.dart, bce_atom.dart, bce_molecule.dart
    equation_term.dart, equation.dart, atom_count.dart, view_mode.dart
  data/
    intro_equations.dart, equations_datasets.dart
    game_equation_pool1.dart, game_equation_pool2.dart, game_equation_pool3.dart
test/balancing_chemical_equations/model/chemistry_model_test.dart
```

---

## Locked concepts (do not merge)

```text
isBalanced ≠ isSimplified ≠ isCorrect
Game score (Phase 4) requires isSimplified
```

---

*Phase 1 complete. Stop. Await Phase 2 (Intro View) instruction.*
