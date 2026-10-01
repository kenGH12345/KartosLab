# PHASE 5 VISUAL QA REPORT — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **Date**: 2026-09-23  
> **Scope**: Visual Reconstruction + Cross-Screen QA  
> **Home**: NOT modified  
> **Model**: NOT modified (chemistry / scoring / datasets locked)

---

## 1. Summary

```text
PHASE 5 STATUS: PASS
```

Viewport locked: **768 × 504** (+ FittedBox host scale).

Visual truth order followed: local PhET source → assets (procedural where source is procedural) → screenshot intent → Flutter defaults avoided.

User-attached official screenshots were referenced as visual targets; no BCE PNG assets were found under local `assets/` (source screenshots live only as store docs in PhET tree when present). Widget harness at 768×504 used for structural QA.

---

## 2. Visual QA

### Intro — PASS

| Area | Result |
|------|--------|
| Equation radios | Make Ammonia / Separate Water / Combust Methane |
| Coefficient pickers | NumberPicker triangles; coeff ≠ subscript |
| AccordionBox | Reactants / Products ± chrome |
| View combo | Particles / Scales / Bars / None — **custom Overlay ComboBox** (Material Dropdown removed) |
| Particles / Scales / Bars / None | Present; model-driven |

### Equations — PASS

| Area | Result |
|------|--------|
| Reaction radios | Synthesis / Decomposition / Combustion |
| Equation ComboBox | listPosition-above style Overlay |
| Feedback | Balanced + Simplified / Not simplified |
| Particles box | 285×260 |

### Game — PASS

| Area | Result |
|------|--------|
| Level selection | 3 buttons + stars + timer toggle + Reset All |
| Play | Status bar, Particles 285×340, Check/Next yellow |
| Feedback panels | NotBalanced + Show Why / NotSimplified / Simplified |
| Reward | **BCERewardNode** 150 falling nodes on perfect score |
| Audio hooks | GameAudioPlayer call sites wired (assets unavailable → silent P2) |

---

## 3. Molecule QA

| Item | Result |
|------|--------|
| Atom radii / colors | BceElement SHA ca115ad formula (AtomNode scaleRadius) |
| H2O / NH3 | Relayout to match nitroglycerin `H2ONode` / `NH3Node` anchors |
| Intro + Equations set | Non-empty layouts tested |
| Complex organics (C2H5OH, N2O5, …) | Source-style procedural clusters — **P2** vs exact Node.ts trees |

No Circle+Text formula placeholders. No emoji / Material molecule icons.

---

## 4. Animation QA

| Animation | Result |
|-----------|--------|
| Particle coeff change | Instant (source) |
| Scale tilt | Instant discrete 6-step |
| Accordion | Instant expand/collapse content (sun easing not pixel-matched) — **P2** |
| Reward rain | Continuous ticker; dispose on leave; L1 atoms / L2 molecules / L3 face+star |
| Show Why / Show Answer | Instant visibility / balance() |

---

## 5. Audio QA

```text
GameAudioPlayer wired at Check / LevelCompleted
Sound files: NOT in local tree (vegas/tambo not cloned)
→ P2 — source asset unavailable (methods are intentional no-ops; not Material substitutes)
```

---

## 6. Cross-Screen Lifecycle

```text
PASS
```

Covered by tests:

- Intro → Equations → Game → re-enter Intro; dispose models; pump timers
- Game enter → perfect → reward → Start Over → repeat ×3 without duplicate reward

No Timer/Ticker left after dispose. GameTimer + Reward ticker disposed with widgets/models.

State persistence: Intro/Equations models retain selection when screens rebuilt with same model instance (source-like). Game Start Over / Reset All unchanged from Phase 4 semantics.

---

## 7. Screenshot QA

| Case | Result |
|------|--------|
| Intro default / equations / views | Structural PASS (widget harness 768×504) |
| Equations default / balanced | Structural PASS |
| Game selection / play / perfect+reward | Structural PASS |
| Pixel-diff vs official PNG | **Harness limitation** — BCE official screenshots not vendored under Flutter assets; no automated pixel compare |

TRUE visual mismatches fixed this phase: Material View Dropdown → PhET ComboBox; missing Reward rain; H2O/NH3 geometry anchors.

---

## 8. P0 / P1 / P2

```text
P0: 0
P1: 0
```

### P2 (remaining)

1. GameAudio sound files unavailable (local vegas/tambo missing)  
2. Complex molecule exact nitroglycerin `*Node.ts` offsets (organics / N2O5 / P2O5 etc.)  
3. Accordion expand easing vs sun AccordionBox  
4. LevelSelectionButton / TimerToggle vegas bevel chrome  
5. Status bar FiniteStatusBar micro-layout  
6. No automated pixel screenshot baseline  
7. Prior Intro/Equations micro spacing / FittedBox scale for tall charts  
8. Reward uses CustomPaint atoms/molecules (source rasterizes Nodes) — motion matches; bitmap cache differs (renderer)

---

## 9. Assets

```text
Original / procedural reused: Element colors, molecule sphere geometry, scales, bars, Reset All L0, ComboBox/Aqua radio chrome, Reward faces/stars
Substituted: 0
```

No Material Icons / emoji molecules.

---

## 10. Regression

```text
flutter test test/balancing_chemical_equations/
→ 82 PASS

dart analyze lib/balancing_chemical_equations test/balancing_chemical_equations
→ No issues found!
```

Breakdown: Phase1 26 + Phase2 13 + Phase3 16 + Phase4 18 + Phase5 visual/lifecycle 9 = 82.

---

## 11. Remaining Issues

See P2 list. **Do not block Phase 5.** Home Integration still deferred.

Model issues found: **none** (no MODEL ISSUE filed).

---

## 12. Final Status

```text
PHASE 5 STATUS: PASS
```

**STOP** — awaiting confirmation before Home Integration / Release Gate.
