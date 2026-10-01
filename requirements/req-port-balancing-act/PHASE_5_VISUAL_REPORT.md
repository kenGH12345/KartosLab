# Balancing Act — Phase 5 Visual Reconstruction Report

> **req-id**: `req-port-balancing-act`  
> **Date**: 2026-09-23  
> **Scope**: Intro / Balance Lab / Game — View / rendering / assets / layout / typography / chrome only  
> **Gate**: **PASS**

---

## PHASE 5 STATUS: PASS

```
Viewport: 768 × 504 (shared; no per-screen viewport drift)

Intro MVT: scale 105; origin (w×0.375, h×0.79); Y inverted
Lab MVT:   scale 105; origin (w×0.375, h×0.79); Y inverted
Game MVT:  scale 115; origin (w×0.45, h×0.86); Y inverted

INTRO VISUAL:
Scene: plank / pivot / attachment / masses / shadows / sky-ground — unchanged MVT; [布局已对齐]
Controls: Show / Position / AB / KratosResetAll — shared panels + baseline text; [布局已对齐]
Typography: BaText / PhetFont Arial height:1 + TextHeightBehavior; [动态绘制已对齐]
Assets: original Intro SVGs; substituted = 0; [原版资源一致]
Result: PASS

BALANCE LAB VISUAL:
Scene: shared BaBalanceScenePainter; [布局已对齐]
Carousel: cornerRadius 10, xMargin 8, bevel shadow, lightweight chevron arrows, spacing 20; [布局已对齐]
Mass: Brick/Mystery SCALING_MVT=150; People SCALING_MVT=80 (source CreatorNodes); FittedBox scaleDown; [原版资源一致]
Show / Position: shared BaShowPanel / BaPositionPanel; [布局已对齐]
Rulers: RotatingRulerNode ticks/labels; font Arial (was Roboto); [动态绘制已对齐]
Marks: PositionMarkerSet; font Arial; [动态绘制已对齐]
AB: shared column switch; [布局已对齐]
Result: PASS

GAME VISUAL:
Level: 4 icons original SVG + BaScoreStars; [原版资源一致]
Stars: scenery-phet StarNode geometry (#fcff03 / #e1e1e1, r=15/7.5); no Icons.star; [动态绘制已对齐]
Challenge: unchanged state machine / titles; [布局已对齐]
Slider: BaMassValueEntry — custom HSlider thumb 15×30, panel rgb(234,234,174), ± arrows; no Material Slider; [动态绘制已对齐]
Score / Timer / Answer / Try Again / Correct Answer / Next / Level Results / Reset: behavior unchanged; chrome typography baseline polish; [布局已对齐]
Result: PASS

SHARED CHROME: PASS
  (Reset All L0, Show/Position panels, BaText, AB switch; screen-specific params preserved)

TYPOGRAPHY: PASS
  (PhetFont Arial height:1; BaText baseline; rulers/marks Arial)

SVG: P2
  flutter_svg `unhandled element <style/>` on regional person SVGs;
  original assets not mutated; visual fill classes may partially degrade via toolchain;
  no substitute assets introduced.

Visual QA:
I-1 Initial: PASS [布局已对齐]
I-2 Mass placed: PASS [布局已对齐]
I-3 Show: PASS [布局已对齐]
I-4 Position / rulers: PASS [动态绘制已对齐]
I-5 Position / marks: PASS [动态绘制已对齐]
I-6 AB: PASS [布局已对齐]
I-7 Reset: PASS [原版资源一致]

L-1 Initial: PASS [布局已对齐]
L-2 Brick: PASS [原版资源一致] (SCALING_MVT 150)
L-3 People: PASS [原版资源一致] (SCALING_MVT 80; USA local assets)
L-4 Mystery: PASS [原版资源一致] (SCALING_MVT 150)
L-5 Carousel next: PASS [布局已对齐]
L-6 Show labels: PASS [布局已对齐]
L-7 Show forces: PASS [布局已对齐]
L-8 Rulers: PASS [动态绘制已对齐]
L-9 Marks: PASS [动态绘制已对齐]
L-10 AB: PASS [布局已对齐]
L-11 Reset: PASS [原版资源一致]

G-1 Level select: PASS [布局已对齐]
G-2 Initial challenge: PASS [布局已对齐]
G-3 Mass placement: PASS [布局已对齐]
G-4 Wrong answer: PASS [布局已对齐]
G-5 Try Again: PASS (semantics untouched)
G-6 Correct Answer: PASS (semantics untouched)
G-7 Next: PASS (semantics untouched)
G-8 Level results: PASS [布局已对齐]
G-9 Stars: PASS [动态绘制已对齐]
G-10 Timer: PASS [布局已对齐]
G-11 Reset: PASS [原版资源一致]

Assets substituted: 0

Tests:
Previous: 79
Added: 5 (phase5_visual_geometry_test)
Final: 84

Analyze: No issues found!

P0: 0
P1: 0
P2:
  - Local BA audio files = 0; GameAudio hooks only (unchanged)
  - SVG <style/> flutter_svg warning — toolchain; assets not edited
  - Regional people / non-USA variants: local source ships multi-region SVGs;
    Flutter currently binds USA set (source-default region). No substitute invented.
  - Stanford mystery query-parameter set: not in local default kit; no pseudo-asset

Intro:
REGRESSION PASS

Balance Lab:
REGRESSION PASS

Game:
REGRESSION PASS

Home:
NOT TOUCHED

Runtime:
NOT VERIFIED

Android:
NOT VERIFIED

Report:
requirements/req-port-balancing-act/PHASE_5_VISUAL_REPORT.md
```

---

## Changes (View-only)

| Area | Change | Source anchor |
|---|---|---|
| Game slider | `BaMassValueEntry` custom HSlider + arrows; removed Material `Slider` | `MassValueEntryNode.ts` |
| Stars | `BaStarNode` / `BaScoreStars` StarShape geometry | `scenery-phet/StarNode.ts` |
| Lab thumbs | Brick/Mystery ×150; People ×80 | `*CreatorNode.ts` SCALING_MVT |
| Carousel | cornerRadius 10, xMargin 8, spacing 20, light shadow | `MassCarousel.ts` |
| Typography | `BaText` + Arial on rulers/marks | `PhetFont` |
| Geometry tests | lock thumb/star/MVT constants | Phase 5 QA |

**Not changed:** Model, Physics, ChallengeFactory, scoring, answer/Try Again/Next semantics, snap, Home, MVT scales/origins.

---

## Notes

- Phase 5 does **not** declare Balancing Act `READY`.
- Remaining P2 items are resource/toolchain limits, not visual hacks.
