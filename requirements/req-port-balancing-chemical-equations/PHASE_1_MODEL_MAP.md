# PHASE_1_MODEL_MAP — Balancing Chemical Equations

> Source → Flutter 一一对应（语义锁死）  
> Date: 2026-09-23

| Source | Flutter | Notes |
|--------|---------|-------|
| `nitroglycerin/Element` | `BceElement` | SHA `ca115ad…`；symbol / radii / color |
| `nitroglycerin/Atom` | `BceAtom` | wraps `BceElement` |
| `common/model/Molecule` | `BceMolecule` | static catalogue；`atoms: List<BceAtom>`；`symbol` RichText |
| `common/model/EquationTerm` | `EquationTerm` | `balancedCoefficient` + mutable `coefficient` |
| `EquationTerm.coefficientProperty` | `EquationTerm.coefficient` + `Listenable` | Integer + range |
| `EquationTerm.balancedCoefficient` | `EquationTerm.balancedCoefficient` | Positive int from dataset |
| `common/model/Equation` | `Equation` | reactants / products / terms |
| `Equation.isBalancedProperty` | `Equation.isBalanced` | multiplier N≥1 |
| `Equation.isSimplifiedProperty` | `Equation.isSimplified` | N=1 |
| `Equation.balance()` | `Equation.balance()` | copy balanced → user coeffs |
| `Equation.getAtomCounts()` | `Equation.getAtomCounts()` | via `AtomCount` |
| `common/model/AtomCount` | `AtomCount` | element + reactantsCount + productsCount |
| `common/model/ViewMode` | `ViewMode` | particles / balanceScales / barCharts / none |
| `BCEPreferences.initialCoefficientProperty` | `BcePreferences.initialCoefficient` | 0 \| 1 |
| Intro / Equations / Game equation factories | `data/*.dart` | identity = tandem-style `id` string |
| Game `Equation` challenge payload | same `Equation` | Phase 4 uses as challenge |
| ReactionType | `ReactionType` | synthesis / decomposition / combustion |

**Not in Phase 1:** Game score / timer / stars / UI / MoleculeNode geometry.
