# PHASE 3 — Model Report · Plinko Probability

> 日期：2026-09-16  
> 依据：本地源码 1.2.0-dev.6

## Implemented

| Module | Path | Status |
|---|---|---|
| Constants / Colors / Assets | `plinko_constants/colors/assets.dart` | ✅ |
| PlinkoRandom | `model/plinko_random.dart` | ✅ seedable |
| GaltonBoard / Peg | `model/galton_board.dart` | ✅ |
| Ball (Bernoulli path + parabolic step) | `model/ball.dart` | ✅ |
| IntroBall / LabBall | `model/intro_ball.dart` / `lab_ball.dart` | ✅ |
| Histogram + sample stats | `model/histogram.dart` | ✅ |
| IntroModel / LabModel | `model/intro_model.dart` / `lab_model.dart` | ✅ |
| Binomial theoretical | `LabModel.getBinomial*` | ✅ |
| Controllers + SimulationClock | `controller/*` | ✅ |
| PlinkoMvt | `transform/plinko_mvt.dart` | ✅ |
| Painters (board/pegs/balls/hopper/histogram/cylinders) | `painters/*` | ✅ MVP |
| Screens + independent Home | `screens/*` | ✅ |
| Unit tests | `test/plinko_probability/model/*` | ✅ **27 PASS** |

## Critical fidelity notes

1. **Not rigid-body physics** — path precomputed with `P(right)=p`.
2. Animation = peg-to-peg parabolic interpolation (`shift*r, -r²`).
3. Lab path/none → `updateStatisticsAndLand()`.
4. Changing p or rows → erase.
5. Substituted assets for icons: **0** (original PNGs copied).

## Next

- Major Geometry polish vs ORIGINAL screenshots
- Peg rotation angle exact formula from PegsNode.paintCanvas
- Sound playback wiring (assets ready)
- Visual QA / Browser QA / Statistical Validation
- Final Gate → then Home integration
