Simulation:
Hooke's Law

Current Status:
READY CANDIDATE

Blocking Factors:

- Visual control faces are VERSION_DELTA. The `sun` package is not in this repository, so pressed inset and exact gradient stops are not source-verified. This does not change formulas or hit targets. It is not marked PASS.
- Official runtime pixel comparison is NOT VERIFIED.
- Whether this machine draws Arial or the sans-serif fallback is NOT VERIFIED.
- Chrome is NOT VERIFIED. The Chrome test harness stayed on loading and was stopped.
- Windows is NOT VERIFIED. A desktop process was started, but Home → Hooke's Law was not operated in that window.
- Android is NOT VERIFIED. No device and no emulator.
- The recorded source SHA `66c44cc9c3a8bcccc3446ecd2156dc2b79151cc7` was not confirmed with `git rev-parse`, because the local source directory is not a git repository.

These items block READY. They are not P0 defects, and this file is not a READY label.
