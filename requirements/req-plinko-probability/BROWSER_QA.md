# BROWSER_QA · Plinko Probability

## Setup

| Item | Value |
|---|---|
| Behavior baseline | local `1.2.0-dev.6` |
| Visual reference | published latest |
| Flutter harness | `test/plinko_probability/browser_qa/browser_qa_test.dart` |
| Evidence dir | `visual-qa/BROWSER_QA/` |
| ORIGINAL spot-check | published Intro (2026-09-16) |

**Result: PASS** — all checklist items PASS. No sim code changed this round.

---

## Intro checklist

| Action | Expected (1.2.0-dev.6) | Actual | Match | Evidence |
|---|---|---|---|---|
| ×1 Play | `ballsToCreateNumber++` → spawn 1 after 150 ms | `balls=1 launched=1` | **PASS** | `02_intro_x1.png` |
| ×10 | `ballsToCreateNumber += 10` → spawn 10 | `launched=10` | **PASS** | `03_intro_x10.png` |
| ×100 (`maxBalls`) | enqueue `maxBallsIntro=100`; staggered @150 ms; cap at 100 | `queue_init=100 launched=36` (partial step) `cap=true` | **PASS** | `04_intro_x100.png` |
| counter ↔ cylinder | **view-only** (`histogramModeProperty`); histogram data unchanged | mode flips; `landed` + bin counts identical | **PASS** | `05_intro_counter.png` / `05_intro_cylinder.png` |
| Erase | clear balls, queue, launched, histogram | all zero | **PASS** | `07_intro_erase.png` |
| Reset | oneBall, rows=12, p=0.5, cylinder default, sound off | restored | **PASS** | `08_intro_reset.png` |

### Intro notes (source)

- `IntroModel.js` play: oneBall / tenBalls / maxBalls (`MAX_BALLS = maxBallsIntro`).
- Published UI label may show `×All`; local/Flutter uses `×100` / `maxBalls` — string diff documented earlier; **behavior** matches `maxBallsIntro=100`.
- Counter/cylinder: `IntroScreenView` links `viewProperties.histogramModeProperty` only — not model erase.

---

## Lab checklist

| Action | Expected | Actual | Match | Evidence |
|---|---|---|---|---|
| rows | peg rows + `binCount=rows+1` sync; erase on change | rows=20 bins=21 pegRows=20 | **PASS** | `lab_rows_20.png` |
| p=0.2 | `P(right)=p` via Bernoulli on `pathHops` | empP=0.1963 (942/4800) | **PASS** | — |
| p=0.5 | empP ≈ 0.5 | empP=0.5021 | **PASS** | — |
| p=0.8 | empP ≈ 0.8 | empP=0.8002 | **PASS** | `lab_p_high.png` |
| One + Play | exactly 1 ball; `isPlaying=false` | balls=1 playing=false | **PASS** | `lab_one.png` |
| Continuous | spawn @100 ms; pause stops; mode switch clears playing; no timer leak | after1=1 after2=2 paused stable | **PASS** | `lab_continuous.png` |
| Ball mode | animated ball; `pathHops` precomputed | phase=initial pathHops=13 | **PASS** | `lab_ball.png` |
| Path mode | land via existing `pathHops`; no re-roll | identical hops list; collected; N=1 | **PASS** | `lab_path.png` |
| None mode | stats update; ball/path visuals hidden in view | N=1 hopper=none | **PASS** | `lab_none.png` |
| Statistics | live μ/σ/x̄/s/N from landings | N=200 x̄=6.000 s=1.722 (μ=6 σ≈1.732) | **PASS** | `lab_statistics.png` |
| Ideal | binomial(n,p) independent of sample | sum=1.0; unchanged after +1 ball | **PASS** | `lab_ideal.png` |
| Audio | peg sound only if `hopperMode==ball` | pathGate=false ballGate=true | **PASS** | (gate assert) |
| Reset | full defaults (model + view) | rows=12 p=0.5 oneBall ball hist=counter | **PASS** | `lab_reset.png` |

### Lab notes (source)

- Bernoulli: `Ball.js` — `nextDouble() > p → left` else right ⇒ **P(right)=p**.
- Path/None: `LabModel.step` calls `updateStatisticsAndLand()`; Trajectory uses frozen `pathHops`.
- Ideal: `getBinomialDistribution()` theoretical; sample histogram separate.
- Continuous: `isPlayingProperty` + `ballCreationTimeInterval` (ball 0.1 / path 0.05 / none 0.015).

---

## Audio

| Event | Expected | Actual | Match |
|---|---|---|---|
| peg left/right | bonk1 / bonk2 via `PegSoundGeneration` | unchanged (no code edit) | **PASS** |
| throttle | 0.1 s | `SOUND_TIME_INTERVAL` | **PASS** |
| Lab path/none | no peg sound | controller gate `hopperMode==ball` | **PASS** |

---

## Reset (Intro + Lab)

| Screen | After dirty state | Match |
|---|---|---|
| Intro | balls/queue/hist/modes restored | **PASS** |
| Lab | rows/p/modes/playing/ideal/hist restored | **PASS** |

---

## Regression (post Browser QA)

See `FINAL_REPORT.md` — run:

```text
flutter test test/plinko_probability
flutter analyze lib/plinko_probability
```

---

## Verdict

| Gate | Status |
|---|---|
| Intro Browser QA | **PASS** |
| Lab Browser QA | **PASS** |
| Statistics / Ideal | **PASS** |
| Audio | **PASS** |
| Reset | **PASS** |
| Home lifecycle | **PASS** |
| **Browser QA overall** | **PASS** |

---

## Home Integration (post READY)

| Step | Result |
|---|---|
| `物理 → 数学与概率 → Plinko Probability` | wired in `home_screen.dart` |
| Open → Intro → Lab → Reset → Back → Reopen | **PASS** (`home_lifecycle_test.dart`) |
