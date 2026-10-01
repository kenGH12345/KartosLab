# ANDROID_RUNTIME_PHASE7.md

## Device

| Field | Value |
|-------|-------|
| Device | Pixel Tablet (`emulator-5554`) |
| Android Version | 15 |
| API | 35 |
| Resolution | 2560 × 1600 |
| Density | 320 dpi (scale 2.0) |
| Orientation | Landscape (preferred orientations set in harness) |
| Build Mode | debug |
| APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| Install | PASS (`Installing ... app-debug.apk` during integration_test) |
| Package | `com.demo.kratos` |
| Entry | `lib/buoyancy/debug_buoyancy_main.dart` (runtime harness, **not Home**) |

## Evidence commands

```text
flutter emulators --launch Pixel_Tablet
flutter test integration_test/buoyancy_android_runtime_test.dart -d emulator-5554
flutter run -t lib/buoyancy/debug_buoyancy_main.dart -d emulator-5554 --debug
adb shell screencap / pull → requirements/req-buoyancy/android_screenshots/
```

## Checklist

| Item | Result | Evidence |
|------|--------|----------|
| Startup | **PASS** | APK install + first frame Compare; `flutter run` Syncing/VM Service |
| Compare | **PASS** | A1/A2 integration; screenshot `01_compare.png` |
| Explore | **PASS** | A3; screenshot `02_explore.png` (wood floating) |
| Lab | **PASS** | A4; screenshot `03_lab.png` |
| Shapes | **PASS** | A5 (block→…→duck→block); screenshot `04_shapes.png` |
| Applications | **PASS** | A6; screenshot `05_applications.png` (bottle profile) |
| Touch | **PASS** | IntegrationTest real device gestures on emulator |
| Drag | **PASS** | A2–A6 swipe on `BuoyancyPlayArea`; A8 continues physics |
| Reset | **PASS** | A2–A6 `KratosResetAllButton`; Lab reset restores earth radio |
| Lifecycle | **PASS** | A7 full tab cycle ×10; no exception; persistent host models |
| Screen Switching | **PASS** | A1 + A7 |
| Orientation | **PASS** | Landscape lock in harness; tablet landscape 2560×1600 framing OK |
| Visual | **PASS** | Five screenshots: scene/mesh/water/controls/Reset visible; no blank/black |
| Performance | **PASS** | No freeze/crash during 8 integration cases (~78s device time); continuous pump 60 frames OK |
| Crash / Exception | **PASS** | `tester.takeException() == null` all cases; no FlutterError in run log |
| Regression | **PASS** | `flutter test test/buoyancy` → 192 PASS; Density 81 PASS |
| Analyze | **PASS** | `dart analyze lib/buoyancy` → 0 errors |

## Screenshots

| File | Screen |
|------|--------|
| `android_screenshots/01_compare.png` | Compare default |
| `android_screenshots/02_explore.png` | Explore |
| `android_screenshots/03_lab.png` | Lab |
| `android_screenshots/04_shapes.png` | Shapes |
| `android_screenshots/05_applications.png` | Applications bottle |

## Notes

- Home / Registry untouched.
- Material Radio/Slider chrome remains **P2** (visible on Android; not introduced by Android).
- Audio: NONE (source) — N/A.

## Android Runtime

**VERIFIED**
