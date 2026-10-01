# POST–PHASE 6 — GRAPH / EQUATION LAYOUT POLISH REPORT

**Sim:** PhET Acid-Base Solutions → Flutter  
**Req:** `req-port-acid-base-solutions`  
**Scope:** View-only — `AbsConcentrationGraph` + `AbsReactionEquation`  
**Locked:** Phase 1 model / chemistry; Home entry (Phase 6)

**Date:** 2026-09-23

---

## STATUS: PASS

```text
Graph:
Bars: PASS — width 25, spacing 16 (ConcentrationBarNode)
Height: PASS — |log10(c)+8|·maxH/10
Values: PASS — RotatedBox −90°; full mantissa (e.g. 1.0 x 10⁻⁷) not clipped
Y-axis title: PASS — RotatedBox; left of 10ⁿ ticks (leftChrome=70)
Under-axis formulas: PASS — none (matches PhET; identity via equation)

Equation:
Layout: PASS — HBox spacing 4, scale 1.5 (ReactionEquationFactory)
Overlap: PASS — adjacent formulas do not overlap
Position: PASS — centerX = beaker.position.x; top = beaker.y + 10
Water 2 H₂O: PASS — dual particle icons + "2 H₂O"
Species order: PASS — matches visible bar left-to-right order

Views:
Intro Graph: PASS
My Solution Graph: PASS
Particles / Hide Views: unchanged

Goldens: 13 / 13 PASS (updated)
Analyze: No issues found!
Assets substituted: 0

Tests:
visual_qa: PASS (incl. no under-axis formulas; equation no-overlap + beaker center)
golden_test: PASS
ABS suite: 165 / 165 PASS

P0: 0
P1: 0
P2:
  equation vs bar columns are naturally spaced (PhET HBox), not pixel-locked to bar centers
  typography micro-deltas / runtime device QA still NOT VERIFIED

KartosLab Global READY: NOT DECLARED (unchanged)
Acid-Base Solutions: READY (Phase 6) + Graph/Equation polish PASS
```

---

## Problem → Fix

| Issue (user / screenshot) | Root cause | Fix |
|---|---|---|
| Switch to Graph: values clipped (`× 10ⁿ` missing mantissa) | `Transform.rotate` layout bounds | `RotatedBox(quarterTurns: 3)` |
| Under-axis formulas / “分子式要在轴下” then “要像原版” | PhET has **no** x-axis formulas; identity is equation under beaker | Removed under-axis labels; keep equation only |
| Formulas overlapping (`+` / `⇌` on text) | Forced term slots onto bar centers (slot wider than spacing) | Restore PhET HBox natural spacing |
| Equation not under beaker | `Center` on full layout width | `Positioned(left: beaker.dx)` + `FractionalTranslation(-0.5, 0)` |

---

## Source alignment

| PhET | Flutter |
|---|---|
| `ConcentrationGraphNode.ts` | `abs_concentration_graph.dart` — `AbsConcentrationGraph` + `AbsGraphLayout` |
| `ConcentrationBarNode.ts` | `_ConcentrationBar` + `absBarHeight` / `absConcentrationToGraphString` |
| `ReactionEquationNode.ts` | `abs_reaction_equation.dart` — `AbsReactionEquation` |
| `ReactionEquationFactory.ts` | `_equationFor` / `_term` / `_water2Term` / `_plus` / `_arrow` |

Visual judgment:

- `[原版资源一致]` — no new substitute assets  
- `[布局已对齐]` — equation centered under beaker; graph chrome matches source dims  
- `[动态绘制已对齐]` — bar heights + sci-notation strings match source formulas  

---

## Files touched

- `lib/chemistry/acid_base_solutions/view/abs_concentration_graph.dart`
- `lib/chemistry/acid_base_solutions/view/abs_reaction_equation.dart`
- `test/chemistry/acid_base_solutions/visual_qa_test.dart`
- `test/chemistry/acid_base_solutions/goldens/*.png` (graph / equation frames)

---

## Release note

```text
Acid-Base Solutions Graph/Equation polish: PASS
Home READY (Phase 6) unchanged
Do not declare KartosLab Global READY
```

**Report:** `requirements/req-port-acid-base-solutions/POST_PHASE_6_GRAPH_EQUATION_POLISH_REPORT.md`
