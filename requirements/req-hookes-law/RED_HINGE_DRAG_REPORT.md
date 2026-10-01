# Hooke's Law — Red Hinge Drag Report

Post-acceptance correction. Phase 8 status is unchanged: **READY CANDIDATE**. This is not READY.

## 1. What was wrong

The painted red hinge is the right side of `RoboticHandNode`. Source puts the drag listener on that whole hand (`RoboticArmNode.ts`: "Robotic hand is draggable, other parts are not").

The Flutter hit box was a fixed `78×72` rectangle starting 8 px left of the spring end. That covered the black grippers. The rounded red hinge sits further right, so a press on the red part did not start a drag.

## 2. What changed

`roboticHandHitRect()` now follows the painted hand: closed grippers plus the red hinge, then the source touch dilation `localBounds.dilatedXY(0.3 * width, 0.2 * height)`.

Intro, Systems parallel, Systems series, and Energy all use `roboticHandDragTarget`. Drag writes are unchanged: 0.01 m snap on the pointer move, stop on pointer up.

## 3. What did not change

- The grey telescoping rod is still not a drag target
- The small red box at the fixed right end of the arm is still not a drag target
- Model formulas, graph, animation, Home route, and viewport were not changed
- No test expectation was weakened or skipped

## 4. Tests

`flutter test test/hookes_law/`

**78 passed.**

## 5. Analyze

`dart analyze lib/hookes_law test/hookes_law`

**No issues found.**

## 6. Still not verified

Chrome, a Windows window operation of Home → Hooke's Law, and Android stay **NOT VERIFIED**. Visual `VERSION_DELTA` and the missing official pixel diff are unchanged.

## 7. Status

This drag-target correction is done.

Simulation status remains **READY CANDIDATE**.
