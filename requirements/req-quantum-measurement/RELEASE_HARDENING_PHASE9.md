# RELEASE_HARDENING_PHASE9

| Item | Result | Evidence |
|---|---|---|
| Build reproducibility | PASS | clean assemble via flutter build profile/release after prior debug |
| Release-like build | PASS | `app-profile.apk` 118.3MB; `app-release.apk` 59.1MB (`-t` QM harness) |
| Assets packaged | PASS | classicalCoinHeads/Tails.svg, greenPhoton.png, spinScreenIcon.png in APK |
| Fonts packaged | PASS | Flutter fonts tree-shaken; UI text visible in release screenshot |
| SVG runtime | PASS | Coins SVG on device; known `<style/>` warning non-blocking |
| PNG runtime | PASS | Photons greenPhoton / Spin icon packaged; Photons/Spin screens render |
| Audio hooks | NOT VERIFIED | no sim-local mp3; shared tambo not exercised on device |
| Lifecycle | PASS | dispose on tab remount; A7; HOME/resume |
| Timers / Tickers | PASS | controller dispose unit (P8) + Android remount A7/A8 |
| Animations | PASS | Photons/Spin Cont + Bloch field exercised |
| Continuous mode | PASS | Photons/Spin Cont paths |
| 10k rendering | PASS | A3 on device |
| Rapid navigation | PASS | A7 ×10 |
| Background / Resume | PASS | adb HOME + am start |
| Back | PASS* | exits root Activity in harness (*Home Back TBD) |
| Re-enter | PASS | A8 re-pump app; am start after Back |
| Orientation | PASS | landscape locked by product |
| Touch | PASS | integration device taps |
| Semantics | PASS (basic) | labels visible; Flutter a11y tree sparse (uiautomator text empty) — P2 |

## Commands used

```text
flutter test integration_test/quantum_measurement_android_runtime_test.dart -d emulator-5554
flutter run -t lib/quantum_measurement/debug_quantum_measurement_main.dart -d emulator-5554
flutter build apk --profile -t lib/quantum_measurement/debug_quantum_measurement_main.dart
flutter build apk --release -t lib/quantum_measurement/debug_quantum_measurement_main.dart
adb install -r build/app/outputs/flutter-apk/app-release.apk
flutter test test/quantum_measurement/
```
