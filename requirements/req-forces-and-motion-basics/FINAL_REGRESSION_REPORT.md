========================================
FORCES AND MOTION: BASICS
FINAL REGRESSION REPORT
========================================

Core Tests:
62 / 62 PASS
(prior 52 gate + forces_scenario 7 + home_lifecycle 3;
visual/screenshot_capture excluded — not a Home Integration gate)

Analyze:
CLEAN
(active F&M surface: info-only, exit 0;
legacy unused stubs under lib/forces/models + motion_screen/netforce_screen remain out of active path)

P0:
0

P1:
0

P2:
~8
(Material slider chrome, brick grit, water fluid, mountain paint,
Go button color nuance, keyboard a11y, legacy stub files, SVG style edge cases)

Visual QA:
PASS

Behavioral Acceptance:
PASS

Cross-Screen Regression:
PASS

Home Integration:
PASS
(Home catalog 物理 → 力学 → 力与运动 → ForcesHome;
Net Force / Motion / Friction / Acceleration tab cycle + reopen)

Home Regression:
PASS
(F&M → sibling FrictionScreen → F&M rebuild OK)

Android Runtime:
NOT VERIFIED

Final Status:
READY CANDIDATE

Visual / UX follow-up (2026-09-24):
See VISUAL_UX_FOLLOWUP_REPORT.md
(toolbox homes, sit/hold stack, BoxFit.fill, Listener drag, tab overlay fade)

Remaining Limitations:
- Android Runtime not verified on device/emulator
- P2 visual/chrome residuals intentionally frozen (no P2 polish this round)
- Legacy unused screens/models still present (not wired by ForcesHome)
- Manual device Home navigation not run in this session; wiring + lifecycle covered by home_lifecycle_test.dart
