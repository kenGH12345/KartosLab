# Hooke's Law — Phase 6 Final Behavior Report

## 1. Status

**READY CANDIDATE**

Every core behavior in the gate was asserted. No behavior defect was found, so no model, layout, or view code was changed.

The whole simulator stays **NOT READY**. Phase 5 still has visual `VERSION_DELTA` and no official pixel diff. Home is not integrated. Chrome, a Windows window, and Android were not operated. This phase does not declare READY.

## 2. Regression baseline

Previous suite: 61 passed.

Added `test/hookes_law/final_behavior_test.dart`: 12 tests. No existing test was deleted, skipped, retried, or given a weaker expected value.

Current suite: **73 passed**.

## 3. Intro acceptance

- Default is one system. System 2 is allocated and stays at k = 200, F = 0, x = 0 until it is shown.
- 1 → 2 moves for 0.5 s, then fades system 2 in. 2 → 1 fades system 2 out, then moves system 1. The two directions were not unified.
- Force slider to 50 N at k = 200 gives x = 0.25 m. Spring-constant slider to 400 N/m keeps F = 50 N and sets x = 0.125 m. Spring force is −50 N.
- After both systems are visible, dragging system 2 does not change system 1. The value labels draw `50.0 N` and `26.0 N`.
- Reset during the 1 → 2 animation returns both springs and the one-system view. Another 1 → 2 after that still completes.

## 4. Systems acceptance

- Parallel is the default view. Series already exists.
- Series with k1 = 400 and k2 = 200, force slider at 50 N: F1 = F2 = 50 N, and x1 + x2 matches the equivalent displacement.
- Parallel with k1 = 200 and k2 = 400 at x = 0.1 m: F1 = 20 N, F2 = 40 N, total = 60 N. The component forces are not split in half.
- Dragging the parallel arm keeps x1 = x2. Dragging the series arm keeps F1 = F2. Pointer up does not add a later motion.
- Total ↔ Components changes which arrows exist. F, x, and k are unchanged.

## 5. Energy acceptance

- Displacement is the control. The x slider and x arrow write x. F and E follow the spring.
- x = 0.5 m, then the k slider to 400 N/m: x stays 0.5 m, F = 200 N, spring force = −200 N, E = 50 J. The bar rect is present.
- x = −0.5 m at k = 200 N/m: F = −100 N, spring force = 100 N, E = 25 J. The force-plot triangle uses −F, so its plot y is positive.
- x = 0: F = 0, spring force = 0, E = 0. The bar rect and the triangle are absent.
- Graph data still comes from `EnergyGraphData` and the spring getters. The curve is still two quadratic Béziers.

## 6. Cross-screen isolation

One Intro model, one Systems model, and one Energy model were kept by the test and shown one at a time.

Intro was set to F = 50 N. Systems top spring was set to 201 N/m. Energy was set to x = 0.01 m. Showing either of the other screens left those three values alone. Nothing was copied across.

## 7. Screen lifecycle

Intro → Systems → Energy → Intro → Systems → Energy rebuilds each screen. The held models and view properties still have the edited values when that screen comes back.

Intro was mounted and disposed three times. The next force write notified the test listener once and did not throw from a disposed screen.

## 8. Reset

- Intro Reset All, including during the 1 → 2 animation, restores both systems and the one-system view.
- Systems Reset All restores the hidden series spring as well as the visible parallel spring, and restores Total plus the parallel view.
- Energy Reset All restores x = 0, k = 100, the bar graph, and a cleared Energy checkbox.

## 9. Drag

Intro, Systems parallel, Systems series, and Energy drags update the model on the pointer move. After pointer up, pumping 0.5 s or 1 s does not change x or F. No rebound, oscillation, damping, or inertia was observed in those pumps.

## 10. Snap

Drag writes of 0.013 m, 0.027 m, and 0.044 m land on 0.01 m, 0.03 m, and 0.04 m. `setDisplacement` of those same values stays exact. The Intro force arrow still steps by 1 N and the force slider by 5 N. The Energy displacement arrow still steps by 0.01 m, separate from the drag snap path.

## 11. Graph

Bar Graph is the default. Energy Plot and Force Plot keep the same spring. The bar key remains in the tree, moves left of the plot, and returns to its first x when Bar Graph is selected again. The Energy checkbox shows the triangle only on Force Plot, and unchecking it removes the triangle without changing F or E. Rapid radio changes leave x and k on the last spring values.

## 12. Animation

1 → 2 and 2 → 1 stay asymmetric. Reset in the middle of 1 → 2 does not throw and does not leave system 2 visible. Three fast 1/2 toggles finish on two systems with hand 2 present and no exception.

## 13. Rapid interaction

Covered without a crash or a stale model:

- fast Intro 1/2 toggles
- Reset during the Intro animation
- pointer down, move, and up
- fast Energy graph radios
- repeated k and F writes (30 cycles) with no drift

A drag that is still down while Reset is tapped was not given its own gesture. Reset during the animation, and pointer-up after a move, were both run.

## 14. Test results

`flutter test test/hookes_law/`

**73 passed.**

## 15. Analyze

`dart analyze lib/hookes_law test/hookes_law`

**No issues found.**

## 16. Platform verification

`flutter devices` on this machine:

- Windows (desktop)
- Chrome
- Edge

No Android device and no emulator.

| Platform | Result |
| -------- | ------ |
| Flutter widget harness on this PC | PASS. 73 tests |
| Chrome | NOT VERIFIED. `flutter test --platform chrome` was still on “loading” after 5 minutes and was stopped. These screens are also not reachable as a running page without a Home route |
| Windows window | NOT VERIFIED. The tests used the Flutter tester, not a Windows embedder window of Hooke's Law |
| Android | NOT VERIFIED. No device and no emulator |

An APK or a Windows build was not treated as verification.

## 17. Remaining NOT VERIFIED

- Live Chrome, Windows, and Android sessions of Intro, Systems, and Energy.
- Official runtime pixel diff (unchanged from Phase 5).
- Whether the installed font is Arial or the sans-serif fallback (Phase 5).

## 18. Known limitations

- Phase 5 `VERSION_DELTA` remains: `sun` button faces are reconstructed because `sun` is not in this repo. Pressed inset was not copied.
- Keyboard steps are constants. This phase did not send key events through the controls.
- Home is not part of this phase. The three screens were swapped by the test, not by app navigation.

---

Behavioral gate: the checked behavior items passed in the Flutter tester. Live platform sessions did not. Visual acceptance and Home integration are still open.

Next phase is not started. No Home card, no Home category, no navigation change, and the simulator is not READY.
