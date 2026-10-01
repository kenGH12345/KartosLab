========================================
FORCES AND MOTION: BASICS
FINAL MIGRATION REPORT (INTERIM)
========================================

Status:
NOT READY

Source:
forces-and-motion-basics 2.7.0-dev.0

Screens:

Net Force:
PASS (model) / Visual QA PENDING

Motion:
PASS (model) / Visual QA PENDING

Friction:
PASS (model) / Visual QA PENDING

Acceleration:
PASS (model) / Visual QA PENDING

Tests:
Previous: forces_scenario_test (legacy)
Added: force/stack/friction/net_force/clock/motion_force/motion_reset/interaction/reset/screens_smoke
Final: 47+ unit/widget tests PASS (core suite)

Analyze:
clean (info-only on new model/screens)

P0:
0 (core physics aligned to PhET)

P1:
- SVG <style> not expanded (flutter_svg warns; colors may wash out) — need BaSvgPicture-style expand
- Stack heights approximate (not image-bounds)
- Pusher drag-to-apply-force not ported (slider only)
- Water bucket slosh animation not ported
- Pixel Visual QA vs gold screenshots not signed off
- Puller color preference UI (purple/orange) not wired
- Keyboard a11y not ported

P2:
- Checkbox trailing Material icons (speed/force)
- Region cultures beyond usa for girl/man
- Ice visual at μ=0
- Legacy lib/forces/screens/netforce_screen.dart + motion_screen.dart stubs remain unused

Shared Model:
PASS

Object Stack:
PASS (model) / geometry Visual PENDING

Force System:
PASS

Friction:
PASS (μ_k = 0.75 μmg)

Acceleration:
PASS (model)

Speedometer:
PASS (bound to speed)

Accelerometer:
PASS (bound to a)

Stopwatch:
PASS (sim-clock synced)

Time Controls:
PASS (pause/step/reset)

Reset:
PASS

Lifecycle:
PASS (clock dispose; tabs keep alive)

Cross-Screen Regression:
PARTIAL (smoke via ForcesHome tabs)

Visual QA:
BLOCKED / PENDING (P1 SVG + pixel)

Home Integration:
PASS (existing entry → ForcesHome 4 tabs)

Home Regression:
NOT DONE (manual)

Android Runtime:
NOT VERIFIED

Known Limitations:
See P1 list. Do not claim READY until Visual QA P1=0.
