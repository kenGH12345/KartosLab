# Balancing Act — Phase 4 Game Report

> **req-id**: `req-port-balancing-act`  
> **Date**: 2026-09-23  
> **Scope**: Game Screen only  
> **Gate**: **PASS**

---

## PHASE 4 STATUS: PASS

```
Viewport: 768 × 504
MVT: scale 115; origin (w×0.45, h×0.86); Y inverted

Game:
Screen: BaGameScreen
Model: BalanceGameModel (Phase 1 + production factory default)
Level: StartGameLevelNode-style select (4 levels, stars, timer toggle)
ChallengeFactory: SourceFaithfulChallengeFactory (production) + DeterministicChallengeFactory (tests)
Challenge Dataset: 4×6 kind schema from BalanceGameChallengeFactory.generateChallengeSet
Challenge Generation: simple/easy/moderate/advanced × balance/tilt/massDeduction + uniqueness history
Plank: shared BaBalanceScenePainter + single-column tilted support
Mass: catalog + Game mystery masses; original SVGs
Drag/Drop: movable only; miss → (3,0)
Snap: Phase 1 plank.addMassToSurface
Physics: SimulationClock → model.step; timer 1 Hz via dt accumulate
Answer: Balance isBalanced; Tilt torque sign; MassDeduction mass==fixedTotal
Score: first correct +2; retry correct +1; wrong 0; show answer 0
Try Again: restore initialColumnState; keep masses & incorrectGuesses
Correct Answer: setChallenge(NO_COLUMNS) + balancedConfiguration placement
Next: next challenge or showingLevelResults + bestScores/bestTimes
Reset: model.reset + UI entry state
Lifecycle: leave pause / re-enter rebind ticker

Vegas:
Reward: FaceWithPointsNode semantic (procedural face); LevelCompletedNode overlay
Animation: plank physics only (no fake Tween)
Audio: BaGameAudioPlayer hooks (correct/wrong/gameOver*); local BA audio assets = 0 (P2)

Visual QA:
Initial: level select [布局已对齐]
Level: 4 icons original SVG [原版资源一致]
Challenge: titles + status bar [布局已对齐]
Placement: MVT 115 scene [动态绘制已对齐]
Wrong: face + Try Again [布局已对齐]
Try Again: column restore [动态绘制已对齐]
Correct Answer: solution placement [动态绘制已对齐]
Next: challenge advance [布局已对齐]
Celebration: LevelCompleted overlay + audio hooks [布局已对齐]
Reset: KratosResetAllButton [原版资源一致 / L0]

Assets substituted: 0

Tests:
Previous: 61
Added: 18
Final: 79

Analyze: No issues found!

P0: 0
P1: (none blocking)
  - Frame-rate sensitivity of ω+=α is source-faithful (documented; not "fixed")
P2:
  - Local BA audio files = 0; Vegas ding/boing not bundled — hooks only
  - SVG <style/> flutter_svg warning
  - ScoreDisplayStars procedural micro-diff vs vegas
  - MassValueEntry uses Flutter Slider chrome (value semantics source-faithful)
  - Font baseline micro-diff

Intro:
REGRESSION PASS

Balance Lab:
REGRESSION PASS

Home:
NOT TOUCHED

Runtime:
NOT VERIFIED

Android:
NOT VERIFIED

Report:
requirements/req-port-balancing-act/PHASE_4_GAME_REPORT.md
```

---

## 1. Scope

Implemented:
- `BaGameScreen` + `BaGameController` (MVT scale **115**)
- `SourceFaithfulChallengeFactory` — production random factory from PhET source
- Deterministic factory retained for tests
- Level select / scoreboard / Check / Try Again / Show Answer / Next / Continue
- Mass deduction slider + tilt prediction selector (original plank tip SVGs)
- Face feedback + LevelCompleted overlay
- `BaGameAudioPlayer` semantic hooks
- Single-column tilted support in scene painter
- Game tests + full Intro/Lab regression

**Not** implemented: Home.

---

## 2. ChallengeFactory

| Track | Class |
|-------|-------|
| Production default | `SourceFaithfulChallengeFactory.generateChallengeSet` |
| Tests | `DeterministicChallengeFactory.generateChallengeSet` |

Level 0–3 sequences match source `generateChallengeSet` switch exactly.

---

## 3. Answer / Score (source-locked)

| Event | Points |
|-------|--------|
| First correct | +2 |
| Correct after 1 wrong | +1 |
| Wrong | +0 |
| Show Answer | +0 |

Validation:
- Balance: `plank.isBalanced()` after columns removed
- Tilt: prediction ↔ `getTorqueDueToMasses()` sign
- Mass deduction: entered kg == `getTotalFixedMassValue()`

---

## 4. Assets (Phase 4)

Copied from PhET:
- `gameLevel1–4Icon.svg`, `gameIcon.svg`
- `plankBalanced.svg`, `plankTippedLeft/Right.svg`
- Game object SVGs (rocks, buckets, fireHydrant, television, crate, …)

**Assets substituted = 0**

---

## 5. Tests

| Suite | Notes |
|-------|-------|
| Phase 1–3 | 61 prior |
| game_factory_test | production factory + frame-rate notes |
| game_screen_test | UI / controller / lifecycle / audio |
| **Total** | **79 PASS** |

---

## 6. Gate

| Criterion | Result |
|-----------|--------|
| Game enterable | PASS |
| ChallengeFactory production | PASS |
| Answer / score / tryAgain / next / displayCorrectAnswer | PASS |
| Physics via model.step | PASS |
| MVT 115 | PASS |
| Assets substituted = 0 | PASS |
| Tests 79 PASS | PASS |
| Analyze clean | PASS |
| P0 = 0 | PASS |
| Home NOT TOUCHED | PASS |
| Android runtime | NOT VERIFIED |

**PHASE 4 STATUS: PASS**
