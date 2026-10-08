# RELEASE_ARTIFACT_REPORT

> PHASE 9 — FINAL RELEASE GATE  
> Build timestamp: 2026-10-08T17:17:05+08:00

## Artifact

| Field | Value |
|---|---|
| Product | KartosLab (kratos) |
| Package ID | `com.demo.kratos` |
| Version | 1.0.0+1 (`pubspec.yaml`) |
| Build mode | **release** |
| Command | `flutter build apk --release` |
| APK path | `D:\OneDrive\Desktop\KartosLab\KartosLab\build\app\outputs\flutter-apk\app-release.apk` |
| APK size | 99024163 bytes (94.4 MB) |
| SHA-256 | `BEFDFFB2A4B294B19BC718E2620784C1CAE035584CE328DDA69BCA0BA5A7FA92` |
| Flutter | 3.44.3 · Dart 3.12.2 · channel stable |
| Android SDK / API | Android 15 · API 35 (install target) |
| Device | Pixel Tablet · emulator-5554 · 2560×1600 · 320 dpi · Landscape |

## Integrity checks

| Check | Result |
|---|---|
| APK exists | PASS |
| `adb install -r` Success | PASS |
| Cold start (`am start com.demo.kratos/.MainActivity`) | PASS |
| Process alive (`pidof`) | PASS |
| Focus on MainActivity | PASS |
| No FATAL in logcat (app) | PASS |
| Home Chinese chrome (screenshot) | PASS (`android_evidence/phase9_release_home.png`) |
| Representative sims (integration_test phase8 5/5) | PASS |
| Background → Resume | PASS |

## Android Rendering Configuration

```
EnableImpeller = false
```

Reason: Cold-start runtime hang observed with Impeller enabled in current environment  
Evidence: Before = Splash hang (firstWindowDrawn=false); After = normal startup  
**Not described as “Impeller bug fixed.”** Release configuration note only.

## Notes

- Debug APK was used only for `integration_test` instrumentation; final install verification re-applied **release** APK.
- SHA-256 computed via PowerShell `Get-FileHash -Algorithm SHA256` on the release APK file.
