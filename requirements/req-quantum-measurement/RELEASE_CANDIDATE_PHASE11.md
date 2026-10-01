# RELEASE_CANDIDATE_PHASE11

| Field | Value |
|---|---|
| Simulation | Quantum Measurement |
| Simulation ID | `quantum-measurement` |
| Source Version | 1.0.4 |
| Flutter Commit | N/A (workspace not a git repository) |
| Flutter SDK | 3.44.3 stable (`e1fd963c6f`) |
| Android Device | Pixel Tablet emulator-5554 · Android 15 · API 35 · 2560×1600 · 320dpi · landscape |
| APK | `build/app/outputs/flutter-apk/app-release.apk` |
| APK Size | 90.9 MB (95 339 163 bytes) |
| APK SHA256 | `7205C14BB373B2EBFF0610081227E571A5594ACFF17B04C3EAFE41562227756E` |
| Build Mode | release (`flutter clean` → `pub get` → `build apk --release`) |
| Golden | 30 PNG · suite ×3 PASS (29 tests/run) |
| Full QM | **207 PASS** |
| Behavior | 33 user-path tests PASS |
| Home | VERIFIED (phase10 unit 7 + Android H1/H2) |
| Android Runtime | VERIFIED (8 integration + final re-run 8/8) |
| Known P2 | SVG `<style/>` warning; sparse a11y; audio NOT REQUIRED/NOT VERIFIED; performance QUALITATIVE; session NOT IMPLEMENTED |
| Product gate | **READY WITH KNOWN NON-BLOCKING RISKS** |
| Release Candidate | **YES** |

## Reproducibility note

First release attempt failed when parallel `integration_test` polluted `GeneratedPluginRegistrant` with `IntegrationTestPlugin` (known KartosLab hardening issue). Final artifact produced after `flutter clean` with registrant free of integration_test.
