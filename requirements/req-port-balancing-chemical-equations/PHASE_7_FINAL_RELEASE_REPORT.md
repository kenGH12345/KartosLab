# PHASE 7 FINAL RELEASE REPORT — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **Date**: 2026-09-23  
> **Scope**: Home Integration + Final Release Gate  
> **Model / datasets / scoring / Phase 1–6 visuals**: locked (unchanged except GameTimer.dispose lifecycle fix)

---

## 1. Executive Summary

```text
FINAL STATUS: READY
```

Balancing Chemical Equations is registered on KartosLab Home under **化学 → 配平化学方程式**, opens production `BalancingChemicalEquationsHome` (Intro / Equations / Game tabs), and passes BCE + Home sibling regressions with analyze clean.

One lifecycle bug found during Home QA and fixed:

- `GameTimer.dispose()` cancelled the periodic `Timer` but left `_isRunning == true` → after Back to Home, disposed timer still reported running. Now clears `_isRunning` on dispose.

---

## 2. Previous State (Phase 1–6)

| Phase | Status | Tests (cumulative) |
|-------|--------|--------------------|
| 1 Model | PASS | 26 |
| 2 Intro | PASS | 39 |
| 3 Equations | PASS | 55 |
| 4 Game | PASS | 73 |
| 5 Visual QA | PASS | 82 |
| 6 Behavioral | PASS | 104 |

Baseline entering Phase 7: **104 PASS**, analyze clean, P0/P1 = 0, P2 = 8, assets substituted = 0.

---

## 3. Home Integration

| Item | Detail |
|------|--------|
| Discipline | **化学** (existing top-level; no new discipline) |
| Subject group | **配平化学方程式** (`BceStrings.homeSubjectGroup`) — product theme, same pattern as RPL「反应物与生成物」 |
| Card title | `Balancing Chemical Equations` |
| Subtitle | `Intro · Equations · Game` |
| Icon | `Icons.balance_outlined` — **Home Material icon system** (no PhET homescreen PNG in local tree; not counted as BCE substituted asset) |
| Accent | `#3376C4` (Intro/Equations chrome bar) |
| Route | `Navigator.push(MaterialPageRoute(builder: _buildBalancingChemicalEquations))` |
| Entry widget | `BalancingChemicalEquationsHome` → `KratosTabbedScreen` |
| Screens | Reuses Phase 2–4: `IntroScreen` / `EquationsScreen` / `GameScreen` |
| Ownership | Home owns `IntroModel` / `EquationsModel` / `GameModel`; dispose on Back |

**Files added/updated:**

- `lib/balancing_chemical_equations/bce_strings.dart` (new)
- `lib/balancing_chemical_equations/screens/balancing_chemical_equations_home.dart` (new)
- `lib/screens/home_screen.dart` (register card + builder)
- `lib/balancing_chemical_equations/balancing_chemical_equations.dart` (export)
- `lib/balancing_chemical_equations/vegas/game_timer.dart` (dispose clears `isRunning`)
- `test/balancing_chemical_equations/home/*.dart` (13 tests)

Not used as entry: QA / demo / visual harness / debug pages.

---

## 4. Navigation QA

| Check | Result |
|-------|--------|
| Card under 化学 | **PASS** |
| Tap → `BalancingChemicalEquationsHome` | **PASS** |
| Default tab = Intro | **PASS** |
| Tabs Equations / Game | **PASS** |
| AppBar Back → Home | **PASS** |

---

## 5. Home → BCE → Home

| Cycle | Result |
|-------|--------|
| ×3 open/back | **PASS** |
| Home visible after pop | **PASS** |
| BCE subtree gone after pop | **PASS** |

---

## 6. Re-entry QA

| Scenario | Result |
|----------|--------|
| Dirty Intro → Back → reopen fresh | **PASS** |
| Dirty Equations → Back → reopen fresh | **PASS** |
| Game progress → Back → level selection / score 0 | **PASS** |
| Dirty all three → reopen all fresh | **PASS** |
| New model instances (not identical) | **PASS** |

Semantics: KartosLab `MaterialPageRoute` pop disposes Home → **fresh instance on re-entry** (same as RPL / Plinko).

---

## 7. Lifecycle QA

| Check | Result |
|-------|--------|
| Owned models disposed on Back | **PASS** (`notifyListeners` throws after dispose) |
| GameTimer stopped after Back | **PASS** (after dispose fix) |
| Home → Game → Home → Game ×3 | **PASS** — no duplicate timer leak |
| Reward / audio hooks | No leftover activity on Home (models disposed) |

---

## 8. Final Smoke Test

Automated coverage equivalent to required smoke flow:

```text
Home → 化学 → BCE → Intro (default)
→ Equations tab → Game tab → answer one challenge
→ Back → Home → re-enter BCE (fresh)
```

Widget tests exercise registration, production route, tabs, Back from Intro/Equations/Game, Game scoring path, timer cleanup, re-entry defaults.

---

## 9. BCE Regression

```bash
flutter test test/balancing_chemical_equations/
→ 117 PASS
```

---

## 10. Home Regression

```bash
flutter test test/reactants_products_and_leftovers/home/ \
            test/plinko_probability/browser_qa/home_lifecycle_test.dart
→ PASS (sibling Home suites; exit 0)
```

Other sims' Home wiring unchanged except adding one `_SubjectGroup` under 化学.

---

## 11. Global Regression

```text
Global Regression: NOT RUN (full `flutter test` suite)
```

Reason: full-repo suite is large; Phase 7 ran **BCE full suite + chemistry sibling Home suites** instead. Do not claim full-project PASS.

---

## 12. Test Count

```text
Previous: 104
Added:    13
Final:    117
```

Home tests:

| File | Count |
|------|------:|
| `bce_home_entry_test.dart` | 2 |
| `bce_home_navigation_test.dart` | 4 |
| `bce_home_lifecycle_test.dart` | 2 |
| `bce_home_reentry_test.dart` | 5 |
| **Total added** | **13** |

---

## 13. Analyze

```bash
dart analyze lib/balancing_chemical_equations lib/screens/home_screen.dart \
             test/balancing_chemical_equations
→ No issues found!
```

---

## 14. P0 / P1 / P2

```text
P0: 0
P1: 0
P2: 8
```

### P2 (carried from Phase 5/6 — non-blocking)

1. GameAudio source mp3 unavailable (hooks no-op)  
2. Complex molecule exact nitroglycerin `*Node.ts` offsets  
3. Accordion expand easing vs sun AccordionBox  
4. LevelSelectionButton / TimerToggle vegas bevel chrome  
5. Status bar FiniteStatusBar micro-layout  
6. No automated pixel screenshot baseline  
7. Intro/Equations micro spacing / FittedBox for tall charts  
8. Reward CustomPaint vs source Node raster cache  

Home card uses Material `Icons.balance_outlined` per KartosLab Home convention — **not** a BCE substituted simulation asset.

---

## 15. Assets

```text
Assets substituted: 0
```

No Material Icons / emoji / network art substituted for PhET molecule or sim chrome. Home tile icon follows existing Home Material system.

---

## 16. Runtime Verification

```text
Runtime: NOT VERIFIED
```

No interactive Chrome / desktop session executed in this gate. Widget tests only.

---

## 17. Android Verification

```text
Android: NOT VERIFIED
```

No device / emulator run. Does **not** block READY per Phase 7 rules when explicitly recorded.

---

## 18. Remaining Issues

- P2 list above (visual/audio polish).  
- Full-repo `flutter test` not executed.  
- Live runtime / Android manual QA deferred.

---

## 19. Final Release Matrix

| Gate | Result |
|------|--------|
| Phase 1 Model | **PASS** |
| Phase 2 Intro | **PASS** |
| Phase 3 Equations | **PASS** |
| Phase 4 Game | **PASS** |
| Phase 5 Visual QA | **PASS** |
| Phase 6 Behavioral QA | **PASS** |
| Home Registration | **PASS** |
| Home Routing | **PASS** |
| Home → BCE | **PASS** |
| BCE → Home | **PASS** |
| Re-entry | **PASS** |
| Back Navigation | **PASS** |
| Lifecycle | **PASS** |
| BCE Regression | **PASS** (117) |
| Home Regression | **PASS** (sibling suites) |
| Global Regression | **NOT RUN** |
| Analyze | **PASS** |
| P0 | **0** |
| P1 | **0** |
| P2 | **8** |
| Assets substituted | **0** |
| Runtime | **NOT VERIFIED** |
| Android | **NOT VERIFIED** |

---

## 20. FINAL STATUS

READY criteria met:

- P0 = 0, P1 = 0  
- Home Registration / Routing / Home↔BCE / Re-entry / Back / Lifecycle = PASS  
- BCE regression PASS, Home regression PASS, Analyze CLEAN  
- Assets substituted = 0  

```text
FINAL STATUS: READY
```

**STOP** — Balancing Chemical Equations migration complete. No further phase.
