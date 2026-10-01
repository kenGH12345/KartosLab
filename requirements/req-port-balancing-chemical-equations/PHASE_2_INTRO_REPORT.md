# PHASE_2_INTRO_REPORT — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **Date**: 2026-09-23  
> **Scope**: IntroScreen Flutter Native View + Interaction only  
> **Phase 1 Model**: LOCKED — not modified

---

## PHASE 2 STATUS: PASS

---

## A. Screen

```text
Screen:   IntroScreen (lib/balancing_chemical_equations/intro/intro_screen.dart)
Viewport: 768 × 504 (PhET layoutSize) → FittedBox → Flutter host
Model:    IntroModel (ChangeNotifier) binds Phase 1 Equation instances
```

Coordinate path:

```text
PhET geometry (BOX_SIZE, HorizontalAligner, bottom bar)
        ↓
SizedBox(768×504) + FittedBox(contain)
        ↓
Flutter window
```

Background `#d9ebff`; bottom chrome `#3376c4`; Reset All = `KratosResetAllButton` (L0).

---

## B. Equation

```text
Default:   intro.makeAmmonia ("Make Ammonia") — first of IntroEquations.createAll()
Selection: radio row (Make Ammonia / Separate Water / Combust Methane) → selectEquation(identity)
Reset:     IntroModel.reset() → equations.first + each Equation.reset() + view defaults
```

Switch semantics (source-matched):

```text
switch equation  →  selectedEquation changes
                 →  coefficients PRESERVED per equation instance
                 →  NOT equation.reset()
```

Proven by unit test `switching equation preserves coefficients`.

UI uses equation `id` (`intro.makeAmmonia` …), not title string branching.

---

## C. Coefficient

```text
Interaction: CoefficientPicker (NumberPicker-style ▲/▼ + long-press 400/200ms per source)
Boundary:    Intro range 0..3 (BceCoefficientRanges.intro)
Model binding:
  UI → EquationTerm.coefficient
     → Equation element totals / isBalanced / isSimplified
```

View never hardcodes chemistry (no `if coefficient == 2`). Formula display separates coefficient from subscripts (`BceEquationNode`).

---

## D. View Modes

Single source-of-truth: `enum ViewMode { particles, balanceScales, barCharts, none }`.

| Mode           | Result |
| -------------- | ------ |
| Particles      | `ParticlesNode` — Accordion boxes + molecule instances × coefficient |
| Balance Scales | `BalanceScalesNode` — per-element fulcrum/beam/tilt from atom totals |
| Bar Charts     | `BarChartsNode` — reactant/product bars + `=` / `≠` |
| None           | visualizations off; equation/controls/coefficients unchanged |

View switch does **not** reset equation or coefficients (tested).

Scale angle (source-matched):

```text
NUMBER_OF_TILT_ANGLES = 6
maxAngle = π/2 − acos(fulcrumH / (beamLength/2))
angle = clamp(|diff|, 6) × (maxAngle/6) × sign(products − reactants)
```

---

## E. Accordion

```text
Reactants: AccordionBox title "Reactants", default expanded = true
Products:  AccordionBox title "Products",  default expanded = true
```

- Both independently toggleable; can both be open or closed.
- Expand/collapse via title-bar ± (CustomPaint, not Material Icons).
- Content: molecule stack reflecting `coefficient × molecule` instances.
- Reset All restores both expanded = true.

---

## F. Assets

```text
Original Assets:
  - nitroglycerin Element colors / radii (SHA ca115ad) via BceElement
  - Intro molecule layouts (H2/N2/O2/NH3/H2O/CH4/CO2) CustomPainter from nitroglycerin-style geometry
  - BalanceScales / BarCharts / arrow / accordion chrome — Canvas equivalents of scenery nodes
  - KratosResetAllButton (L0 = scenery-phet ResetAllButton)

Substituted: 0
```

No Material Icons / emoji / CircleAvatar molecules.  
**P2 note**: full nitroglycerin `*Node.ts` atom-offset trees for all 38 molecules deferred to Visual polish; Intro subset geometries are source-derived, not placeholders.

---

## G. Tests

```text
Phase 1:  26 PASS (chemistry model regression — unchanged)
Intro:    13 PASS (IntroModel + IntroScreen widget)
Total:    39 PASS
```

Path: `test/balancing_chemical_equations/`  
Coverage: defaults, equation select, coefficient bounds/balance, view mutual exclusion, accordion, Reset All.

---

## H. Analyze

```text
dart analyze lib/balancing_chemical_equations test/balancing_chemical_equations
→ No issues found!
```

---

## I. Visual

```text
Structural: PASS — 768×504 layout, equation strip, radios, View combo, particles/scales/bars/none, Reset All
P0: 0
P1: 0
P2: (recorded, not blocking)
  - Accordion expand animation vs sun AccordionBox easing may differ slightly
  - Scales/Bars use FittedBox contain when stacked height exceeds BOX area
  - Full molecule node trees for non-Intro molecules not yet needed
  - Sub-pixel spacing / bevel / anti-alias vs screenshots
```

Judgment tags: `[布局已对齐]` `[动态绘制已对齐]` `[原版资源一致 — Intro subset]`

---

## J. Status

```text
PHASE 2 STATUS: PASS
```

### Deferred (explicit — do not implement in Phase 2)

- EquationsScreen  
- GameScreen / scoring / timer / stars / feedback  
- Home integration  
- vegas dependency (Phase 4)

### Architecture (locked for this phase)

```text
Source Equation
      ↓
Phase 1 Chemistry Model
      ↓
Intro View
      ├── Equation Selection (id → IntroModel)
      ├── Coefficients → EquationTerm
      ├── Reactants Accordion
      ├── Products Accordion
      └── ViewMode
            ├── Particles
            ├── Balance Scales
            ├── Bar Charts
            └── None
```

**STOP** — awaiting Phase 3+ instruction. No Equations / Game work.
