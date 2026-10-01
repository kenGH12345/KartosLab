# Phase 4 Game Report

> **req-id**: `req-port-balancing-chemical-equations`  
> **Date**: 2026-09-23  
> **Scope**: GameScreen only (level selection + play + completed)  
> **Home / Visual seal**: NOT in scope

---

## Status

```text
PHASE 4 STATUS: PASS
```

---

## Source

```text
source path: phet sourses/balancing-chemical-equations-main/balancing-chemical-equations-main
package:     balancing-chemical-equations
SHA:         f09cf80cafc30a9c8b00e1b990b65c3fcf2bf910
```

Primary: `js/game/model/GameModel.ts`, `GameState.ts`, `GameLevel*.ts`, `EquationPool*.ts`, `LevelNode.ts`, `GameScreenView.ts`, `GameFeedbackNode.ts`, `NotBalancedPanel.ts` (ShowWhyNode).

Audits: `GAME_LOGIC_AUDIT.md`, `SOURCE_AUDIT_REPORT.md`.

---

## Game Model

| Concern | Implementation |
|---------|----------------|
| question model | `Equation` challenges from Phase 1 pools |
| dataset | Level1=21, Level2=11, Level3=14 (+ exclusions) |
| selection | `EquationPool.getEquations(5)` — random, no dupes, firstBigMolecule=false on L1, L3 exclusionsMap |
| attempt state | `GameState`: levelSelection → check ⇄ tryAgain → showAnswer → next → levelCompleted |
| score | +2 first simplified; +1 second simplified; 0 after Show Answer |
| timer | vendored vegas `GameTimer` (1s wall clock); default **disabled** |

Correct gate = **`isSimplified`** (not merely `isBalanced`).

---

## Game Semantics

```text
5 questions / level (CHALLENGES_PER_GAME)
first attempt correct  → +2 → next
second attempt correct → +1 → next
incorrect (attempt < 2) → tryAgain
incorrect (attempt = 2) → showAnswer (0 points)
Show Why → BalanceScales / BarCharts (level getViewMode) — atom totals, no score change
Show Answer → state next → equation.balance() (canonical coeffs) — 0 points
Start Over → resetToStart + level=null + levelSelection; bestScore/bestTime/timerEnabled KEPT
Reset All → clears bestScore/bestTime + timerEnabled
```

Perfect score = 10 (5 × 2). Stars on level buttons from **bestScore** (ScoreDisplayStars semantics).

---

## Vegas

| Item | Value |
|------|-------|
| Target SHA | `6e4726b37f53b3d0fe6ea713787094c69d3beea3` |
| Local clone | **Unavailable** (network) — same situation as Phase 1 |
| Vendored | `lib/.../vegas/game_timer.dart` — start/stop/reset/elapsed + formatTime |
| Vendored | `lib/.../vegas/game_utils.dart` — `updateScoreAndBestTime` |
| Usage | Timer optional; best score/time on endGame; LevelCompleted summary |
| Audio / RewardNode confetti | Deferred P2 (no sound assets; simple completed panel without particle rain) |
| Status | **PASS (semantics)** for timer + score/bestTime; full vegas UI polish = P2 |

---

## UI

```text
Viewport: 768×504
BG play: #ffffe4
Level selection: Choose Your Level! + 3 level buttons (icon molecule + stars) + Timer toggle + Reset All
Play: status bar (Challenge N of 5, Score, optional timer, Start Over)
      Particles only (BOX 285×340, spacing 140) — Accordion reused
      Equation + Check / Next (yellow TextPushButton style)
      Feedback panels: Balanced+Simplified | Balanced+NotSimplified | NotBalanced+Show Why
Completed: score / stars / optional time / Continue → startOver()
```

No Material Dialog / SnackBar. No View combo on Game (source Particles-only).

---

## Assets

```text
referenced: nitroglycerin molecules, L0 ResetAll, procedural stars/faces/check/times, scales/bars for Show Why
reused: Phase 2/3 ParticlesNode, BceEquationNode, BalanceScalesNode, BarChartsNode, KratosResetAllButton
substituted: 0
```

---

## Tests

```text
Phase 1:  26 PASS
Phase 2:  13 PASS
Phase 3:  16 PASS
Phase 4:  18 PASS
Full regression: 73 PASS
```

Path: `test/balancing_chemical_equations/game/game_screen_test.dart`

---

## Analyze

```text
dart analyze lib/balancing_chemical_equations test/balancing_chemical_equations
→ No issues found!
```

---

## Visual QA

```text
Structural: PASS
P0: 0
P1: 0
P2:
  - vegas RewardNode particle rain not implemented (perfect-score celebration simplified)
  - GameAudioPlayer sounds not wired
  - TimerToggle / LevelSelectionButton exact vegas chrome bevel
  - Status bar Exact FiniteStatusBar layout deltas
```

---

## Lifecycle

```text
enter Game → levelSelection
→ select level → check (5 challenges)
→ attempt / feedback / next …
→ levelCompleted → Continue → levelSelection
→ Start Over mid-game → levelSelection (best kept)
→ Reset All → best cleared
→ leave/re-enter: GameTimer disposed with model; no orphaned tickers
```

---

## Known Issues

- Full vegas package not git-cloned; timer/utils vendored at documented SHA semantics.
- Reward confetti + game audio = P2.
- Phase 2/3 P2 molecule Node.ts polish unchanged (not required for Game gate).

---

## Final Gate

| Gate | Result |
|------|--------|
| Real pools + identity | PASS |
| isSimplified scoring | PASS |
| Show Why conservation viz | PASS |
| Show Answer → balance() | PASS |
| Start Over ≠ Reset All | PASS |
| Phase 1–3 regression | PASS |
| P0/P1 = 0 | PASS |
| Substituted = 0 | PASS |

```text
PHASE 4 STATUS: PASS
```

**STOP** — awaiting Phase 5 (Visual / Home / Release). No Home integration in this phase.
