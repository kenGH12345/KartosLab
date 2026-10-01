# Balancing Act — Game Visual / Playability Hotfix Report

> **req-id**: `req-port-balancing-act`  
> **Date**: 2026-09-23  
> **Scope**: Post–Phase 7 Game QA fix (SVG color + chrome layout)  
> **Gate**: **PASS**  
> **Trigger**: User screenshots — black mass silhouettes; tilt / mass-entry unplayable (image 4 = PhET original)

---

## STATUS: PASS

```
Issue A — Black silhouettes (people / mystery / objects):
Root cause: flutter_svg ignores <style/> + class= → fills missing → black
Fix: BaStyledSvg.inlineCssStyles (runtime CSS→presentation attrs, in-memory only)
      BaSvgPicture.asset wired to BaMassNode / BaMassCarousel / BaGameScreen
Assets mutated: 0 (source SVG files untouched)
Assets substituted: 0

Issue B — Game chrome unplayable:
Root cause: tilt selector + mass entry positioned at model Y ≈ −0.55 (ground band)
Source (BalanceGameView.ts):
  tilt.bottom = modelToViewY(PLANK_HEIGHT + 0.8)
  massEntry.top = title.maxY + 4  (title.top = scoreboard.bottom + 20)
  buttons.center = modelToView(0, −0.3)
  face.centerY = modelToViewY(2.2)
Fix: BaGameScreen._ChallengeChrome aligned to source positions

Visual QA:
Mass SVGs:     [原版资源一致] — CSS inlined; colored fills restored
Tilt chrome:   [布局已对齐] — bottom @ plankHeight+0.8
Mass entry:    [布局已对齐] — under challenge title
Check/Next:    [布局已对齐] — model (0, −0.3)
Face feedback: [布局已对齐] — centerY model 2.2

Tests:
Previous: 116
Added: 6 (4 BaStyledSvg unit + 2 Game layout widget)
Final: 122

Analyze: No issues found! (changed files)

P0: 0
P1: 0
P2 (retained / reduced):
  - BA audio assets unavailable (hooks only)
  - USA regional people asset limitation
  - Stanford mystery unavailable in default local kit
  - SVG <style/> warning eliminated for BA load path (inliner); other sims unchanged
  - FaceWithPointsNode still procedural (opacity/diameter micro-diff vs vegas)

Intro / Lab / Home: REGRESSION PASS (full BA suite)

Runtime / Android: NOT VERIFIED (hot-reload / device QA deferred to user)

Global Regression: unchanged baseline (unrelated fails outside BA)

Report: requirements/req-port-balancing-act/GAME_VISUAL_HOTFIX_REPORT.md
```

---

## 1. Problem (user report)

| Symptom | Evidence |
|---|---|
| Masses / people render as solid black shapes | Screenshots of Game Level 1+ mass-deduction challenges |
| Tilt / mass challenges hard to play | Prediction UI & mass slider near ground / overlapping Try Again |
| Reference | Image 4 = original PhET Game (colored assets + chrome under title / above plank) |

---

## 2. Root causes

### 2.1 SVG black fill

PhET SVGs (e.g. `usaBoyStanding.svg`, `fireExtinguisher.svg`, `mysteryObject*.svg`) put fills in `<defs><style>.cls-N{fill:...}</style></defs>` and mark shapes with `class="cls-N"`.

`flutter_svg` does not apply those rules → paths draw with default black fill.

### 2.2 Game chrome Y

Phase 4/5 placed tilt selector and mass entry near `modelToViewY(-0.55)`, colliding with the Check / Try Again band. Source pins tilt bottom to `PLANK_HEIGHT + 0.8` and mass entry under the title.

---

## 3. Changes

| File | Change |
|---|---|
| `lib/balancing_act/view/widgets/ba_styled_svg.dart` | **New** — `BaStyledSvg` + `BaSvgPicture` |
| `lib/balancing_act/view/widgets/ba_mass_node.dart` | `SvgPicture` → `BaSvgPicture` |
| `lib/balancing_act/view/widgets/ba_mass_carousel.dart` | people / mystery thumbs → `BaSvgPicture` |
| `lib/balancing_act/view/ba_game_screen.dart` | tilt/mass/face layout; plank icons → `BaSvgPicture` |
| `test/balancing_act/ba_styled_svg_test.dart` | **New** — inliner unit tests |
| `test/balancing_act/game_screen_test.dart` | tilt bottom + mass-entry top layout asserts |

**Non-goals (unchanged):** Model / ChallengeFactory / physics / Home / asset files / Phase 0–7 feature scope.

---

## 4. Verification

```
flutter test test/balancing_act/          → 122 PASS
flutter analyze (hotfix files)            → No issues found!
Assets substituted                        → 0
Source SVG files modified                 → 0
```

---

## 5. Gate

| Item | Result |
|---|---|
| Game visual (SVG color) | **PASS** |
| Game playability (tilt / mass entry) | **PASS** |
| BA regression | **PASS** (122) |
| Assets substituted | **0** |
| P0 / P1 | **0** |
| Runtime device QA | not_verified |

**HOTFIX GATE: PASS** — Game visual + playability closed; Phase 7 READY status retained.
