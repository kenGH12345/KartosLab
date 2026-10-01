========================================
F&M BASICS — P1 / VISUAL QA STATUS
========================================

Core Tests:
52 / 52 PASS
(prior 47 + 5 behavioral_acceptance)

Analyze:
CLEAN (info-only lints; no errors/warnings on screens)

Net Force Visual:
PASS

Motion Visual:
PASS

Friction Visual:
PASS

Acceleration Visual:
PASS

P0:
0

P1:
0

P2:
~8 (Material slider density, brick gravel fidelity, full water fluid mesh, mountains palette, Go color debate vs grey gold desc, checkbox hit targets, region cultures, keyboard a11y)

Behavioral Acceptance:
PASS (model-level black-box; see behavioral_acceptance_test.dart)

Cross-Screen Regression:
PASS (independent model isolation test)

Home Integration:
ALREADY WIRED (ForcesHome) — formal regression NOT re-run this phase

Current Status:
READY CANDIDATE

Notes:
- MODEL frozen this phase (view-only visual fixes).
- Do NOT declare READY until Android Runtime verified + optional manual Home regression.
- Screenshots: requirements/req-forces-and-motion-basics/visual-qa/FLUTTER/
