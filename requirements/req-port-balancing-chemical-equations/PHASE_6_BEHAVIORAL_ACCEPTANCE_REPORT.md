# PHASE 6 BEHAVIORAL ACCEPTANCE REPORT — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **Date**: 2026-09-23  
> **Scope**: Behavioral Acceptance + Full Regression  
> **Home**: NOT modified  
> **Model architecture / datasets / scoring rules**: NOT redesigned

---

## 1. Phase Summary

```text
PHASE 6 STATUS: PASS
```

Source-locked semantics re-verified against Phase 0–5 reports and local PhET tree:

- `isBalanced` = all coeffs are `N × balancedCoefficient` with `N ≥ 1`
- `isSimplified` = all coeffs `== balancedCoefficient`
- `balance()` = copy dataset canonical coefficients (not a runtime solver)
- Game: 5 challenges / round; first attempt = 2 pts; second = 1 pt; Show Answer = 0
- `Start Over ≠ Reset All`

No production Model redesign. One test assertion adjusted for Equations coefficient **range clamp** (source-faithful boundary): when `balancedCoefficient × 2 > range.max` (e.g. synthesis `5 O₂ → 10`), N=2 cannot be represented → skip N=2 balance assert for those equations only.

---

## 2. Baseline: 82 PASS

```text
Previous (Phase 5): 82 PASS
```

Breakdown carried forward: Model 26 + Intro 13 + Equations 16 + Game 18 + Visual/lifecycle 9 = 82.

---

## 3. Tests Added

| File | Count | Focus |
|------|------:|-------|
| `test/balancing_chemical_equations/behavioral/phase6_acceptance_test.dart` | **22** | Intro / Equations×12 / balance semantics / Game scoring / Show Why·Answer / Start Over / Timer / Audio hooks / cross-screen / rapid ± |

Production code changes this phase: **none** (behavior already matched source; only test matrix completed).

---

## 4. Final Test Count

```text
Previous: 82
Added:    22
Final:    104 PASS
```

```bash
flutter test test/balancing_chemical_equations/
→ 104 PASS
```

---

## 5. Intro Behavioral Matrix

| Area | Result |
|------|--------|
| Equation selection A→B→C→A | **PASS** — per-equation coeffs preserved |
| Coefficient editing 0..3 | **PASS** — no negative / no NaN / clamp at max |
| View modes cycle Particles→Scales→Bars→None→Particles | **PASS** — mutually exclusive |
| Atom totals sync across view switches | **PASS** — Model-driven H/O counts |
| Accordion expand/collapse rapid toggle | **PASS** — no state corruption |
| Reset All | **PASS** — equation + coeffs + view restored |

---

## 6. Equations Behavioral Matrix

| Area | Result |
|------|--------|
| All 12 datasets default / balance / incorrect / reset | **PASS** |
| N=2 when `balanced×2 ≤ range.max` | **PASS** (`isBalanced` true, `isSimplified` false) |
| N=2 when clamped (e.g. 5×2 O₂) | **PASS** — not asserted as balanced (source range 0..6) |
| Reaction type switch + per-type selection | **PASS** |
| Equations Reset All | **PASS** |
| Rapid reaction / equation / view switching | **PASS** |

---

## 7. Game Behavioral Matrix

| Area | Result |
|------|--------|
| 5-question round | **PASS** → `levelCompleted` |
| First attempt all correct → score 10 | **PASS** |
| Mixed 2+1+2+1+2 → score 8 | **PASS** |
| Show Answer path | **PASS** — awards 0; uses `balance()` |
| Show Why | **PASS** — toggle; score/coeffs unchanged |
| Start Over | **PASS** — score/state reset; `bestScore` kept |
| Reset All (Game) | **PASS** — clears `bestScore` + timer preference |
| Rapid check / tryAgain / showAnswer / next | **PASS** |

---

## 8. Score Validation

| Pattern | Expected | Actual |
|---------|----------|--------|
| 2+2+2+2+2 | 10 | **PASS** |
| 2+1+2+1+2 | 8 | **PASS** |
| Show Answer after 2 fails | 0 | **PASS** |
| Intermediate scores 0/2/4/6/8/10 | covered by round + mixed | **PASS** |

---

## 9. Show Why / Show Answer

| Action | Result |
|--------|--------|
| Show Why | **PASS** — conservation UI flag; no score/coeff mutation |
| Show Answer | **PASS** — `equation.balance()` → canonical coeffs; `points == 0` |

---

## 10. Reset All / Start Over

| Action | Screen | Result |
|--------|--------|--------|
| Reset All | Intro | **PASS** — source defaults |
| Reset All | Equations | **PASS** — source defaults |
| Start Over | Game | **PASS** — level selection; `bestScore` retained |
| Reset All | Game | **PASS** — clears `bestScore`; timer off |

`Start Over ≠ Reset All` confirmed by test.

---

## 11. Timer Lifecycle

| Check | Result |
|-------|--------|
| Single `GameTimer` instance across Start Over / re-select | **PASS** (`identical`) |
| start / stop / restart | **PASS** |
| `formatTime` | **PASS** (`0:00`, `1:05`) |
| No duplicate timers on model reuse | **PASS** |

Widget enter/exit ticker coverage retained from Phase 5 visual/lifecycle tests.

---

## 12. Reward Lifecycle

| Check | Result |
|-------|--------|
| Perfect score → reward rain | **PASS** (Phase 5 visual + Phase 6 perfect round) |
| Enter/exit/re-enter no duplicate reward ticker | **PASS** (Phase 5 lifecycle test retained) |
| Particle cleanup on dispose / leave | **PASS** |

No production reward changes this phase.

---

## 13. Audio Hooks

| Hook | Result |
|------|--------|
| correctAnswer / wrongAnswer / gameOver* / dispose | **PASS** — callable no-ops |
| Source mp3 | **P2** — unavailable in local tree (not substituted) |

Do **not** treat missing audio assets as behavioral PASS for sound playback — hooks only.

---

## 14. Cross-Screen Lifecycle

| Cycle | Result |
|-------|--------|
| Intro → Equations → Game ×3 (models) | **PASS** |
| Listener remove → no stale callbacks | **PASS** |
| Widget cross-screen dispose (Phase 5) | **PASS** retained |

No duplicate listeners after remove; dispose clean.

---

## 15. Rapid Interaction

| Scenario | Result |
|----------|--------|
| Coefficient + + + − − + ×50 | **PASS** — in-range, no NaN |
| Equation / reaction / view thrash | **PASS** |
| Game check → tryAgain → showAnswer → next loop | **PASS** |

---

## 16. P0 / P1 / P2

```text
P0: 0
P1: 0
P2: 8 (unchanged from Phase 5; audio remains P2)
```

### P2 (remaining — non-blocking)

1. GameAudio source mp3 unavailable (hooks no-op)  
2. Complex molecule exact nitroglycerin `*Node.ts` offsets  
3. Accordion expand easing vs sun AccordionBox  
4. LevelSelectionButton / TimerToggle vegas bevel chrome  
5. Status bar FiniteStatusBar micro-layout  
6. No automated pixel screenshot baseline  
7. Intro/Equations micro spacing / FittedBox for tall charts  
8. Reward CustomPaint vs source Node raster cache (motion OK)

No new P0/P1. No MODEL DEVIATION filed.

---

## 17. Full Regression

```text
flutter test test/balancing_chemical_equations/
→ 104 PASS
```

---

## 18. dart analyze

```bash
dart analyze lib/balancing_chemical_equations test/balancing_chemical_equations
→ No issues found!
```

---

## 19. Remaining Issues

- P2 list above (visual/audio polish only).  
- **Home Integration**: deliberately **not** started.  
- Equations range clamp: N×balanced may exceed `0..6` — cannot represent some “balanced but not simplified” multiples in UI; Model semantics unchanged.

---

## 20. Final Status

```text
PHASE 6 STATUS: PASS

P0 = 0
P1 = 0
Core behavioral matrix = ALL PASS
Full regression = PASS (104)
Analyze = CLEAN
```

**STOP** — do not start Home Integration / Phase 7 until instructed.

---

## Final Behavioral Matrix (acceptance gate)

| Area | Coverage |
|------|----------|
| Intro equation selection | **PASS** |
| Intro coefficient editing | **PASS** |
| Intro visualization modes | **PASS** |
| Intro Accordion | **PASS** |
| Intro Reset All | **PASS** |
| Equations 12 datasets | **PASS** |
| Balance semantics | **PASS** |
| Simplified semantics | **PASS** |
| Equations reset | **PASS** |
| Game 5-question round | **PASS** |
| First attempt = 2 | **PASS** |
| Second attempt = 1 | **PASS** |
| Show Why | **PASS** |
| Show Answer | **PASS** |
| Start Over | **PASS** |
| Game Timer | **PASS** |
| Reward | **PASS** |
| Audio hooks | **P2** (hooks PASS; mp3 unavailable) |
| Cross-screen lifecycle | **PASS** |
| Rapid interaction | **PASS** |
| Full regression | **PASS** |
| Analyze | **PASS** |
