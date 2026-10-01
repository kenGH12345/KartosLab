# Balancing Act — Phase 3 Balance Lab Report

> **req-id**: `req-port-balancing-act`  
> **Date**: 2026-09-23  
> **Scope**: Balance Lab Screen only  
> **Gate**: **PASS**

---

## PHASE 3 STATUS: PASS

```
Viewport: 768 × 504
MVT: scale 105; origin (w×0.375, h×0.79); Y inverted

Balance Lab:
Screen: BaBalanceLabScreen
Model: BalanceLabModel (Phase 1, unchanged physics)
Plank: BaBalanceScenePainter (procedural, shared with Intro)
Pivot: procedural fulcrum + attachment bar
Mass: brick procedural; people/mystery original SVG
Carousel: 5 pages bricks / people×2 / mystery×2
Drag/Drop: creator forward → continuous → Phase 1 snap
Snap: Phase 1 plank.addMassToSurface (no View reimplementation)
Physics: SimulationClock → BalanceLabModel.step only
Show: labels / forces / level via BalanceViewProperties
Position: none / rulers (RotatingRulerNode fidelity) / marks (PositionMarkerSetNode)
AB Switch: DOUBLE ↔ NO (BaColumnSwitch)
Reset: Model + ViewProperties + carousel pageIndex
Lifecycle: leave pause / re-enter rebind ticker

Visual QA:
Initial: empty plank + carousel bricks + controls [布局已对齐]
Mass Placement: creator drag → snap [动态绘制已对齐]
Carousel: page nav + thumbs [原版资源一致]
Show: checkboxes [布局已对齐]
Position: rulers/marks upgraded from Phase 2 simplified [动态绘制已对齐]
AB: column switch [布局已对齐]
Reset: KratosResetAllButton [原版资源一致 / L0]

Assets substituted: 0

Tests:
Previous: 49
Added: 12
Final: 61

Analyze: No issues found!

P0: 0
P1:
  - ChallengeFactory (deferred — Game)
  - Frame-rate-sensitive integration (deferred)
P2:
  - Carousel chrome / chevron vs sun Carousel bevel micro-diff
  - Toolbox thumb scale (source SCALING_MVT=150; Flutter fitted to panel)
  - Person sitting images not used in Lab (standing only — matches creator nodes)
  - SVG <style/> flutter_svg warning (non-blocking)
  - Font baseline micro-diff vs PhetFont

Intro: REGRESSION PASS (49 prior + shared ruler upgrade)

Game: NOT STARTED

Home: NOT TOUCHED

Report: requirements/req-port-balancing-act/PHASE_3_BALANCE_LAB_REPORT.md
```

---

## 1. Scope

Implemented:
- `BaBalanceLabScreen` + `BaBalanceLabController`
- Mass carousel (5 pages per `MassCarousel.ts`)
- Creator drag → `BalanceLabModel.create*` → continuous drag → snap / miss animate-remove
- Show / Position / AB Switch / Reset All
- Proper `BaRotatingRulerPainter` + `BaPositionMarksPainter` (also used by Intro)
- Original people (usa standing) + mysteryObject01–08 SVGs
- Procedural brick stacks (`rgb(205,38,38)`)
- Lab tests + Phase 1/2 regression

**Not** implemented: Game, Home.

---

## 2. Source References

| Item | Source |
|------|--------|
| Screen | `BalanceLabScreenView.ts` extends `BasicBalanceScreenView` + `MassCarousel` |
| Model | Phase 1 `BalanceLabModel` (locked) |
| Carousel | `MassCarousel.ts` — bricks / people×2 / mystery×2 |
| Creators | `BrickStackCreatorNode` / `*CreatorNode` / `ModelElementCreatorNode` forwarding |
| Rulers | `RotatingRulerNode.ts` — length 4.0 m, tick 0.25 m, height 50 px |
| Marks | `PositionMarkerSetNode.ts` + `PositionMarkerNode.ts` |
| Layout | 768×504; MVT scale 105 |
| Reset | `KratosResetAllButton` L0 |

---

## 3. Architecture

```
BaBalanceLabScreen (TickerProvider)
└── BaViewport (768×504)
    └── _BaLabStage
        ├── BaBalanceScenePainter
        ├── BaPositionMarksPainter / BaRotatingRulerPainter
        ├── Level / Force painters
        ├── BaMassNode × N (dynamic)
        ├── BaColumnSwitch
        ├── Show + Position + BaMassCarousel
        └── KratosResetAllButton
```

Physics: `SimulationClock` → `BalanceLabModel.step(dt)` only.

---

## 4. Carousel

| Page | Content |
|------|---------|
| bricks | 1–4 brick stack creators |
| people1 | Boy + Man |
| people2 | Girl + Woman |
| mystery1 | mystery ids 0–3 |
| mystery2 | mystery ids 4–7 |

Nav: prev/next (no wrap). Reset → page 0.

Miss: `removeMassAnimated` → fly to create destination → remove from model.

---

## 5. Assets (Phase 3 copies)

| Asset | Flutter Path | Status |
|-------|--------------|--------|
| mysteryObject01–08.svg | `assets/simulations/balancing_act/images/objects/` | FOUND |
| usaBoy/Girl/Man/WomanStanding.svg | `…/images/usa/` | FOUND |
| Brick stacks | PROCEDURAL | OK |
| fireExtinguisher / trashCan | Phase 2 | FOUND |

**Assets substituted = 0**

---

## 6. Rulers / Marks (Phase 2 fix)

Phase 2 simplified rulers replaced with source-faithful painters:
- Ruler: 4.0 m length, 17 ticks @ 0.25 m, dual “meters” labels, center divider, rgba(236,225,113,0.5), rotates with plank
- Marks: orange dashed line + circle + bold distance labels, skip center 0

---

## 7. Tests

| Suite | Count |
|-------|------:|
| Phase 1 model | 39 |
| Phase 2 Intro | 10 |
| Phase 3 Lab | 12 |
| **Total** | **61** |

Lab coverage: construction, carousel pages, drag/snap, occupied, miss animate-remove, Show/Position/AB, Reset, person/mystery creators, continuous drag, lifecycle re-enter.

---

## 8. Analyze

```
dart analyze lib/balancing_act test/balancing_act
→ No issues found!
```

---

## 9. Gate checklist

| Criterion | Result |
|-----------|--------|
| Lab enterable | PASS |
| Drag/drop + snap | PASS |
| Physics via model.step | PASS |
| Carousel 5 pages | PASS |
| Show / Position / AB / Reset | PASS |
| Rulers/marks not simplified | PASS |
| Viewport + MVT | PASS |
| Assets substituted = 0 | PASS |
| Tests 61 PASS | PASS |
| Analyze clean | PASS |
| P0 = 0 | PASS |
| Game NOT STARTED | PASS |
| Home NOT TOUCHED | PASS |
| Physics semantics unchanged | PASS |

**PHASE 3 STATUS: PASS**
