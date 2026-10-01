# Hooke's Law — Final Behavior Matrix

Phase 6. Each row is a user action or the drag/control write that action uses, then the model, then the view. `PASS` means that loop was asserted. It is not a live Chrome or Windows window session.

| Screen | Scenario | Expected Source Behavior | Flutter Result | Status |
| ------ | -------- | ------------------------ | -------------- | ------ |
| Intro | Default | One system. k = 200, F = 0, x = 0. System 2 exists at the same defaults and is not shown | `intro-hand-1` present, `intro-hand-2` absent. System 2 stays at defaults | PASS |
| Intro | Two systems | System 2 appears only after the move. The two springs do not share k, F, or x | Drag on hand 2 sets x = 0.13. System 1 stays at F = 50, x = 0.125. Value text `50.0 N` and `26.0 N` both draw | PASS |
| Intro | 1 → 2 | Move 0.5 s, then fade in | System 2 is absent during the move, opacity 0 at the end of the move, opacity 1 after the fade | PASS |
| Intro | 2 → 1 | Fade out, then move. Not the reverse of 1 → 2 | Mid-fade opacity about 0.5 while system 2 is still there. System 1 moves only after system 2 is gone | PASS |
| Intro | Drag | Pointer moves the arm, snap 0.01 m, F = kx, spring force = −F. Pointer up does not keep moving | 30 px drag → x = 0.13, F = 26. One second after pointer up, x and F are unchanged | PASS |
| Intro | Snap vs other writes | Drag snaps 0.013 / 0.027 / 0.044 m to 0.01 / 0.03 / 0.04 m. `setDisplacement` does not. Force arrow steps 1 N. Force slider steps 5 N | Drag pipeline and `setDisplacement(0.013)` asserted. Arrow and slider steps asserted on the Intro screen | PASS |
| Intro | Change k | F stays. x = F/k | Slider writes F = 50 at k = 200 (x = 0.25), then k = 400. F stays 50, x = 0.125, spring force = −50 | PASS |
| Intro | Reset | Both systems and the 1-system view return to defaults, including a reset during 1 → 2 | After reset mid-animation: F = 0, system 2 k = 200, hand 2 absent. A later 1 → 2 still completes | PASS |
| Systems | Default | Parallel is visible. Series already exists at k = 200, F = 0 | Parallel hand is shown. Series force is still 0 | PASS |
| Systems | Series | F1 = F2 and x1 + x2 = x even when k1 ≠ k2 | k1 = 400, k2 = 200, slider F = 50. Both springs read 50 N. Displacements add to the equivalent x | PASS |
| Systems | Parallel | x1 = x2. F = F1 + F2. Unequal k is not split evenly | k1 = 200, k2 = 400, x = 0.1. F1 = 20, F2 = 40, total = 60. A later drag still keeps x1 = x2 | PASS |
| Systems | Total / Components | Only arrow visibility changes | Model snapshot of F, x, and k is identical before and after both switches | PASS |
| Systems | Hidden reset | Reset All restores the system that is not on screen | Parallel k edited, view switched to series, series k edited, Reset All. Both springs return to 200 and the view returns to parallel / total | PASS |
| Systems | Leave | Leaving does not reset | Parallel k = 201 survives a trip to Energy and back. Series force is not copied from parallel | PASS |
| Energy | x is the input | Changing x updates F, spring force, and E. The view does not invent those numbers | x slider to 0.5 at k = 100 gives F = 50, E = 12.5. x arrow steps 0.01 m | PASS |
| Energy | Change k | x stays. F = kx. E = kx²/2 | x = 0.5, k slider to 400. x stays 0.5, F = 200, spring force = −200, E = 50. Bar rect is shown | PASS |
| Energy | Negative x | F < 0, spring force > 0, E > 0. Plots use the same spring | At k = 200, x = −0.5: F = −100, spring force = 100, E = 25. Triangle height is positive because plot y is −F | PASS |
| Energy | Zero | F = 0, spring force = 0, E = 0. Bar and triangle are hidden | Bar rect and triangle are absent at x = 0 | PASS |
| Energy | Graph switch | Same model. Bar stays mounted and moves left for a plot, then returns | Bar x decreases when Energy Plot is selected and returns on Bar Graph. x, k, F, E unchanged across rapid radio taps | PASS |
| Energy | Energy checkbox | Triangle only while Force Plot is selected and Energy is checked. Model unchanged | Check shows the triangle. Uncheck removes it. F and E stay 100 N and 25 J | PASS |
| Energy | Curve | E = kx²/2, force line F = kx, two quadratic Béziers, scales 1.1 and 0.25 | Bézier controls, force-line ends, and triangle size match `EnergyGraphData`. No chart library | PASS |
| Energy | Reset | x, k, graph mode, and the checkbox return to defaults | x = 0, k = 100, bar graph, checkbox off, triangle absent | PASS |
| All | Isolation | Editing one screen does not write the other two | Intro F = 50, Systems top k = 201, Energy x = 0.01 stay put while the other screens are shown | PASS |
| All | Come back | Dispose and rebuild do not reset a model the test still holds | Intro, Systems, and Energy each show their edited values after a full Intro → Systems → Energy → Intro → Systems → Energy cycle | PASS |
| All | Listeners | Dispose removes screen listeners. A later write runs once | Three mount/unmount cycles, then one force write, one listener call, no exception | PASS |
| All | Rapid input | Fast 1/2 toggles, reset during animation, fast graph radios, pointer up | No exception. Final 2-system view and final bar graph match the last command | PASS |
| All | Precision | 10-decimal rounding. Repeated F/x/k writes do not drift | 30 Intro k/F cycles stay at F = 50. 30 Energy k/x cycles end at x = 0.5, F = 200, E = 50 | PASS |
| Platform | Chrome window | Operate the three screens in Chrome | Chrome is installed. `flutter test --platform chrome` stayed on “loading” for more than 5 minutes and was stopped. The screens are not on a runnable route | NOT VERIFIED |
| Platform | Windows window | Operate the three screens in a Windows embedder window | Widget tests ran on this PC. No Windows window of these screens was opened | NOT VERIFIED |
| Platform | Android | Operate the three screens on a device or emulator | `flutter devices` lists Windows, Chrome, and Edge only | NOT VERIFIED |
