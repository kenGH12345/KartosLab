# Balancing Act — Phase 7 Home Integration / Release Gate

> **req-id**: `req-port-balancing-act`  
> **Date**: 2026-09-23  
> **Scope**: Home card / category / navigation / lifecycle / release gate  
> **Gate**: **READY**

---

## PHASE 7 STATUS: READY

```
HOME:
Card:         PASS (物理 → 力学 · Icons.scale_rounded · accent BaColors.skyTop)
Category:     PASS (物理 / 力学 — same as Hooke's / Pendulum / Projectile)
Icon:         PASS (Home Material icon pattern; not PhET SVG; distinct from BCE balance_outlined)
Navigation:   PASS (HomeScreen → BalancingActHome via WidgetBuilder)
Back:         PASS (AppBar Back → HomeScreen)
Re-entry:     PASS (fresh controllers ×3)
Visual:       PASS (matches existing _SimCard system; no Home redesign)

BALANCING ACT:
Intro:        PASS
Balance Lab:  PASS
Game:         PASS
Reset:        PASS (after Home entry)
Behavior:     PASS (Phase 6 retained)
Visual:       PASS (Phase 5 retained; no visual rework)

CROSS-BOUNDARY:
Home → BA:            PASS
BA → Home:            PASS
Re-entry:             PASS
Lifecycle:            PASS (Back disposes owned controllers; screens pause clocks)
State Isolation:      PASS (other 力学 sim then BA clean)

Tests:
Previous: 107
Added: 9
Final: 116

Analyze: No issues found!

P0: 0
P1: 0
P2:
  - BA audio assets unavailable (hooks only)
  - SVG <style/> flutter_svg toolchain warning
  - USA regional people asset limitation
  - Stanford mystery unavailable in default local kit

Balancing Act Regression: PASS (flutter test test/balancing_act/ → 116 PASS)

Home Regression: PASS
  (hookes_law/home + bce/home + plinko home_lifecycle + ba home → all PASS)

Global Regression: FAIL
  Baseline: 56 unrelated failures (Phase 6)
  This run: +3362 ~1 -56
  Same failure families: states_of_matter / pendulum / projectile visual_qa timeouts; forces_scenario
  Balancing Act failures: 0
  New BA/Home global failures: 0

Assets substituted: 0

Runtime: NOT VERIFIED
Android: NOT VERIFIED

Report:
requirements/req-port-balancing-act/PHASE_7_HOME_RELEASE_REPORT.md
```

---

## Integration summary

| Piece | Path / detail |
|---|---|
| Entry | `lib/balancing_act/screens/balancing_act_home.dart` |
| Pattern | `KratosTabbedScreen` — Intro / Balance Lab / Game (BCE / Plinko) |
| Ownership | Controllers owned by Home; disposed on Back |
| Catalog | `lib/screens/home_screen.dart` → 物理 → 力学 |
| Card | title `Balancing Act`, subtitle `Intro · Balance Lab · Game` |
| Icon | `Icons.scale_rounded` (Home convention) |
| Tests | `test/balancing_act/home/home_integration_test.dart` (9) |

**Not modified:** BalanceModel, physics, snap, ChallengeFactory, scoring, Intro/Lab/Game view visuals.

---

## Release statement

```
Balancing Act Release Status: READY

Global Repository Status: FAIL — unrelated pre-existing failures (56)
```

`READY` means Balancing Act meets KartosLab project release criteria for this sim.  
It does **not** mean the entire KartosLab repository is globally healthy.
