# PHASE 6 — HOME INTEGRATION / FINAL RELEASE GATE

**Sim:** PhET Acid-Base Solutions → Flutter  
**Req:** `req-port-acid-base-solutions`  
**Scope:** Home card / entry shell / navigation / lifecycle only  
**Locked:** Chemistry, Intro/My Solution views, Graph, ConductivityTester, Goldens

---

## PHASE 6 STATUS: READY

```text
HOME:
Card: PASS — 酸碱溶液
Category: PASS — 化学 → 溶液与浓度
Icon: PASS — Icons.science_outlined (Home Material strategy)
Navigation: PASS — Navigator.push → AcidBaseSolutionsHome
Back: PASS — pageBack → HomeScreen
Re-entry: PASS — ×3
Lifecycle: PASS
Visual: PASS — sibling cards 摩尔浓度 / pH 标度 intact

ACID-BASE:
Intro: PASS
My Solution: PASS
Chemistry: PASS (locked)
Tools: PASS
Particles: PASS
Graph: PASS
Equation: PASS
Reset: PASS
Goldens: 13 / 13 PASS

CROSS-BOUNDARY:
Home → Acid-Base: PASS
Acid-Base → Home: PASS
Re-entry: PASS
State Isolation: PASS (re-open defaults to Intro Water)
Lifecycle: PASS
Reset after Re-entry: PASS

Tests:
Previous: 154
Added: 10
Final: 164

Analyze: No issues found!

P0: 0
P1: 0
P2:
  audio unavailable
  typography micro-deltas
  Show Solvent prefs dialog (Preferences-only)

Acid-Base Regression: PASS (164/164)
Home Regression: PASS (ph_scale home + abs home)
Goldens: 13 / 13 PASS

Global Regression:
FAIL — unrelated baseline failures (Phase 5)
  Acid-Base failures: 0
  New Acid-Base/Home global failures: 0

Assets substituted: 0

Runtime: NOT VERIFIED
Android: NOT VERIFIED

Report:
requirements/req-port-acid-base-solutions/PHASE_6_HOME_RELEASE_REPORT.md
```

---

## Integration map

| Piece | Path |
|---|---|
| Home shell | `lib/chemistry/acid_base_solutions/screens/acid_base_solutions_home.dart` |
| Catalog entry | `lib/screens/home_screen.dart` — `_SubjectGroup('溶液与浓度')` |
| Factory | `_buildAcidBaseSolutions` → `AcidBaseSolutionsHome` |
| Tabs | Intro → `AbsIntroScreen`; My Solution → `AbsMySolutionScreen` via `KratosTabbedScreen` |
| Home tests | `test/chemistry/acid_base_solutions/home/abs_home_lifecycle_test.dart` (10) |

---

## Architecture notes

- No new Home taxonomy — placed with 摩尔浓度 / pH 标度 under **溶液与浓度**.
- Single entry + tabs (matches PhET 2-screen sim / PhScale / Plinko pattern).
- Inactive tab tickers muted via `KratosTabSwitcher` `TickerMode`.
- Pop + push recreates shell → fresh Intro/My Solution controllers (isolation).

---

## Release statement

```text
Acid-Base Solutions: READY
Global Repository: FAIL — known unrelated baseline (not ABS/Home)
```

Phase 0–6 complete for this sim. Do not claim entire KartosLab Global PASS.
