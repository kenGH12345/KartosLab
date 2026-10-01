# Phase 3 Equations Report

> **req-id**: `req-port-balancing-chemical-equations`  
> **Date**: 2026-09-23  
> **Scope**: EquationsScreen Flutter Native View + Interaction only  
> **Phase 1 Model**: LOCKED — semantics unchanged (additive `getDisplayString` only)  
> **Phase 2 Intro**: regression PASS — not reworked

---

## Status

```text
PHASE 3 STATUS: PASS
```

---

## Source

```text
local source path: phet sourses/balancing-chemical-equations-main/balancing-chemical-equations-main
source package:    balancing-chemical-equations
SHA:               f09cf80cafc30a9c8b00e1b990b65c3fcf2bf910
nitroglycerin:     ca115ad1233059957fa599a7c249feef1cbfacac
```

Primary source files:

- `js/equations/model/EquationsModel.ts`
- `js/equations/view/EquationsScreenView.ts`
- `js/equations/view/ReactionTypeRadioButtonGroup.ts`
- `js/equations/view/EquationsComboBox.ts`
- `js/equations/view/EquationsViewProperties.ts` (extends IntroViewProperties)
- `js/equations/view/EquationsFeedbackNode.ts`

---

## Screens

```text
EquationsScreen
  lib/balancing_chemical_equations/equations/equations_screen.dart
Viewport: 768 × 504 (BCEConstants.LAYOUT_BOUNDS) + FittedBox
BOX_SIZE: 285 × 260 (source EquationsScreenView — taller than Intro 285×145)
```

---

## Reaction Types

| Type | Source order | Default | Control |
|------|--------------|---------|---------|
| Synthesis | 1st | **YES** | Aqua radio, white label, maxWidth 70 |
| Decomposition | 2nd | no | Aqua radio, maxWidth 106 |
| Combustion | 3rd | no | Aqua radio, maxWidth 86 |

```text
Control: HorizontalAquaRadioButtonGroup equivalent (ReactionTypeRadioButtonGroup)
Spacing: 16 between items; radio radius 8; xSpacing 4
Location: bottom bar leftMargin 20, centerY on HorizontalBarNode
```

Switching reaction type:

```text
reactionTypeProperty changed
  → equationProperty derived from per-type selection
  → coefficients PRESERVED on each Equation instance
  → viewMode / accordion NOT reset
  → NOT equivalent to Reset All
```

---

## Equation Dataset

```text
12 / 12 (source count)
```

| Pool | Count | Default selection | Coeff range |
|------|-------|-------------------|-------------|
| Synthesis | 4 | equation0 (2C+O₂→2CO) | 0..6 |
| Decomposition | 4 | equation0 (CH₃OH→CO+2H₂) | 0..6 |
| Combustion | 4 | equation0 (C₂H₄+3O₂→2CO₂+2H₂O) | 0..6 |

Identity: `equations.{synthesis\|decomposition\|combustion}.equation{N}`  
No string/index chemistry hacks.

Equation selector: PhET `EquationsComboBox` (sun ComboBox, `listPosition: 'above'`), labels via `Equation.getDisplayString()` (□ coeff + HTML subscripts).

---

## Model

```text
reused:   Phase 1 Equation / EquationTerm / AtomCount / ViewMode / ReactionType / EquationsDatasets
modified: Equation.getDisplayString() additive only (matches Equation.ts)
semantic changes: NONE to isBalanced / isSimplified / balance()
```

`EquationsModel` mirrors source:

- per-type equation lists + per-type selected equation
- derived `selectedEquation`
- `reset()` = reactionType + all equations + all three selections + view props

---

## Interaction

| Area | Result |
|------|--------|
| reaction type | radios → `setReactionType`; preserves per-type coeffs |
| equation selection | ComboBox → `selectEquation` by identity |
| coefficients | reused `CoefficientPicker` → Phase 1 terms; range 0..6 |
| accordion | reused `ParticlesNode` AccordionBox (Reactants/Products) |
| visualization | Particles / BalanceScales / BarCharts / None via `ViewMode` |
| feedback | `EquationsFeedbackNode`: Balanced + Simplified \| Not simplified |
| reset | `KratosResetAllButton` → model + view defaults |

View switch does **not** reset equation, coefficients, or reaction type.

---

## Assets

```text
Assets referenced:
  - nitroglycerin Element colors/radii (SHA ca115ad)
  - sun AquaRadio / ComboBox chrome (Canvas / Overlay equivalent)
  - scenery-phet ResetAll → KratosResetAllButton (L0)
  - FaceNode / check / times path equivalents (EquationsFeedbackNode)
  - Particles / Scales / Bars CustomPainters (Phase 2 reuse)

Assets reused: all of the above (no Material Icons / emoji / chart libs)

Assets substituted: 0
```

Procedural drawing where source is programmatic (BalanceScales, BarCharts, molecule spheres) — not counted as substitution.

---

## Tests

```text
Phase 1:  26 PASS
Phase 2:  13 PASS
Phase 3:  16 PASS
Full regression (test/balancing_chemical_equations/): 55 PASS
```

Phase 3 path: `test/balancing_chemical_equations/equations/equations_screen_test.dart`

Coverage: defaults, ordering, identities, type switch coeff preserve, coeff bounds, balance/simplified, Reset All, radios, combo identity, view modes, accordion.

---

## Analyze

```text
dart analyze lib/balancing_chemical_equations test/balancing_chemical_equations
→ No issues found!  (clean)
```

---

## Visual QA

```text
Structural: PASS — 768×504, reaction radios, equation combo, equation strip, View, viz, Reset All
P0: 0
P1: 0
P2: (recorded)
  - ComboBox Overlay chrome vs exact sun ComboBox bevel/highlight
  - Molecule Node.ts atom offsets for complex organics (C2H5OH etc.) approximated
  - Accordion expand animation vs sun AccordionBox easing
  - Bottom combo left position uses Flexible Row vs exact radio boundsProperty link
```

Tags: `[布局已对齐]` `[动态绘制已对齐]` `[原版资源一致 — Equations]`

---

## Known Issues

- Exact nitroglycerin `*Node.ts` geometry trees for all 38 molecules still P2 polish (Equations subset covered with source-style layouts; no placeholders).
- vegas / GameScreen deferred to Phase 4.
- Home integration not done (per Phase 3 scope).

---

## Final Gate

| Gate | Result |
|------|--------|
| Phase 1 semantics unchanged | PASS |
| 12 equations + reaction mapping | PASS |
| EquationsScreen renders + interacts | PASS |
| No string chemistry hacks | PASS |
| No duplicated chemistry model | PASS |
| P0 = 0 / P1 = 0 | PASS |
| Substituted = 0 | PASS |
| Full BCE regression + analyze | PASS |

```text
PHASE 3 STATUS: PASS
```

**STOP** — awaiting Phase 4 (GameScreen). Equations / Game scoring / timer / stars / Show Why not implemented.
