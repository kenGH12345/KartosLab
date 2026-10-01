# Final Acceptance Report

## 1. Final Status

**READY CANDIDATE**

Not READY. Not NOT READY.

Core model, Intro, Systems, Energy, behavior tests, and Home entry passed. P0 = 0. Tests and analyze are clean. Code stayed frozen: no simulation or Home edit in this phase.

READY is blocked by items that are still not PASS: visual control faces are VERSION_DELTA, official pixels are NOT VERIFIED, and Chrome, a Windows window, and Android were not operated.

## 2. Source

- Sim version: `package.json` **1.3.0-dev.0**
- Dependency snapshot comment: **1.2.0-dev.3** (2025-05-07). Published release notes stop at 1.2 (2025-05-21). Behavior follows the local TypeScript, not the release note
- SHA recorded in `dependencies.json`: `66c44cc9c3a8bcccc3446ecd2156dc2b79151cc7`
- SHA verification limitation: `phet sourses/hookes-law-main/hookes-law-main` is not a git repository. `git rev-parse` cannot confirm that SHA against the files on disk

## 3. Screens

- Intro: PASS. Default is one system. System 2 exists and stays independent. 1→2 moves then fades in. 2→1 fades out then moves. Those directions were not collapsed
- Systems: PASS. Parallel is the visible default. Series already exists. Total / Components changes arrows only
- Energy: PASS. One blue spring. Displacement is the input. Bar Graph, Energy Plot, and Force Plot read the same spring

## 4. Model

- F = kx
- spring force = −F
- E = kx²/2
- values clamp, then round to 10 decimal places
- writing F and x does not recurse
- Intro: changing k keeps F and recomputes x
- Energy: changing k keeps x and recomputes F and E
- Series: F1 = F2, displacements add
- Parallel: x1 = x2, total F = F1 + F2
- Reset restores the system that is not on screen
- Intro, Systems, and Energy models do not share springs
- no mass, no gravity, no oscillation, no `step(dt)`

Evidence: Phase 1 report and the 27 model tests inside the 78.

## 5. Interaction

- Drag writes the arm, snaps to 0.01 m, then stops on pointer up
- `setDisplacement` does not snap
- Intro force arrow steps 1 N. Intro force slider steps 5 N. Energy displacement arrow steps 0.01 m
- Zero force hides arrows. Positive and negative force update the spring, arrows, and values
- Reset during the 1→2 animation returns the default and a later 1→2 still finishes
- Disposing Intro releases its ticker. A later write does not throw from a disposed screen listener

## 6. Systems

- Unequal series springs share F. Unequal parallel springs do not share F
- Component arrows read each spring's own force
- Drag on series keeps F1 = F2. Drag on parallel keeps x1 = x2
- Leaving the screen does not reset and does not copy the other screen

## 7. Energy

- x = 0.5 m then k = 400 N/m keeps x = 0.5, sets F = 200 N, spring force = −200 N, E = 50 J
- x = −0.5 m keeps E positive and F negative
- x = 0 hides the bar and the triangle
- Energy curve is two quadratic Bézier segments, not a chart library
- Force-plot energy is a triangle, and only while Force Plot is selected and Energy is checked
- The bar node stays mounted and moves left for a plot, then returns
- Graph switches do not build a second model

## 8. Visual

Counted from `visual-qa/FINAL_VISUAL_MATRIX.md` and Phase 5 sections 14–17. Early Intro/Systems/Energy QA notes are historical. Phase 5 is the later visual record.

| Class | Count | What it is |
| ----- | ----- | ---------- |
| P0 | 0 | No open blocker |
| P1 | 0 | No open structural item. Earlier QA P1 items were fixed or reclassified |
| P2 | 4 notes | Panel corner about 4 px, flat slider track, Flutter antialiasing, 1 px bevel highlight instead of a sampled sun image |
| VERSION_DELTA | 6 matrix rows | Arrow button, slider thumb, checkbox, radio, Systems control faces, Energy control faces. `sun` is not in this repo, so pressed inset and exact gradient stops were not copied |
| NOT VERIFIED | 2 matrix rows | Whether this machine resolves Arial rather than the sans-serif fallback. Official runtime screenshot diff |

VERSION_DELTA does not change hit targets, step sizes, or formulas. It is not marked PASS.

## 9. Tests

`flutter test test/hookes_law/` → **78 passed**.

| File | Tests |
| ---- | ----- |
| `model/hookes_law_model_test.dart` | 27 |
| `intro/intro_spring_geometry_test.dart` | 2 |
| `intro/intro_screen_test.dart` | 9 |
| `systems/systems_screen_test.dart` | 8 |
| `energy/energy_screen_test.dart` | 15 |
| `final_behavior_test.dart` | 12 |
| `home/home_integration_test.dart` | 5 |

Phase 5 baseline was 61. Phase 6 added 12. Phase 7 added 5. 61 + 12 + 5 = 78.

`test/hookes_law` has no `skip`. `final_behavior_test.dart` exists and ran. `lib/hookes_law` has no test-only branch and no debug bypass. Assertions from earlier phases were not edited in Phase 8.

## 10. Analyze

`dart analyze lib/hookes_law lib/screens/home_screen.dart test/hookes_law`

**No issues found.**

## 11. Home

- Category: 物理 → 力学
- Card: `Hooke's Law`, subtitle `Intro · Systems · Energy`, between Masses and Springs: Basics and Pendulum Lab
- Icon: `Icons.swap_vert_rounded` on the card only
- Route: existing `Navigator.push(MaterialPageRoute)` → `HookesLawHome`
- Default screen: Intro
- Systems and Energy tabs remain
- Tab change does not reset
- AppBar back returns to Home
- The next visit is a new instance at source defaults
- Stage stays 1024×618. Home theme font Courier does not replace the sim label's Arial

## 12. Platform

| Platform | Status | Evidence |
| -------- | ------ | -------- |
| Chrome | NOT VERIFIED | Test harness stayed on loading and was stopped. No Chrome window of Hooke's Law was used |
| Windows | NOT VERIFIED | The app binary was built and a process started. The Home → Hooke's Law path was not operated in that window |
| Android | NOT VERIFIED | No device and no emulator |

This phase did not retry Chrome. The last attempt already met the stop rule. No simulator code was changed to chase a platform result.

## 13. Regression

`flutter test test/home/bending_light_integration_test.dart` → **3 passed**.

Bending Light remains under 物理 / 光学与波动. Its production entry, back, and fresh model on re-entry still pass. No unrelated legacy analyze issue was assigned to Hooke's Law.

## 14. Known Limitations

- `sun` button faces (pressed inset, exact gradient stops) are VERSION_DELTA. They do not change interaction
- No official pixel diff
- Arial fallback on this machine was not measured
- Chrome, Windows window operation, and Android were not verified
- The source SHA was not re-checked with git
- `KratosTabbedScreen` draws an AppBar and TabBar outside the 1024×618 stage. That is the existing multi-screen shell, not a second viewport

## 15. Final Decision

Section 21 requires every core gate PASS, visual PASS, platform verification complete, and no unresolved critical VERSION_DELTA before READY.

Those platform and visual conditions are not met. There is also no P0, no missing screen, no behavior failure, no broken Home entry, no test regression, and no analyze error, so the result is not NOT READY.

**Final Status: READY CANDIDATE**
