# PHASE8_ANDROID_ZH_REPORT

> ANDROID CHINESE RUNTIME VERIFICATION · 2026-10-08

## Device

| Field | Value |
|---|---|
| Device | Pixel Tablet (`emulator-5554`) |
| Android Version | 15 |
| API | 35 |
| Resolution | 2560×1600 |
| Density | 320 |
| Orientation | landscape (`screenOrientation=landscape`) |

## Build / Startup

| Gate | Result |
|---|---|
| `flutter doctor` | Android toolchain available (licenses warning pre-existing) |
| `flutter devices` | emulator-5554 listed |
| `flutter build apk --debug` | PASS → `app-debug.apk` |
| Install | `adb install -r` Success |
| Cold start | PASS after Impeller disable |
| Home first frame | Chinese catalog |

## Runtime harness

- `integration_test/phase8_android_zh_runtime_test.dart` → **5/5 PASS**
  - Home Chinese chrome
  - Collision Lab interact + Reset + Back
  - Buoyancy tabs + drag + Back
  - High-risk sample set (circuit, gas, quantum, chemistry, fourier, CCK, …)
  - Domain smoke (forces, vector, density, ohms, optics, waves, build-an-atom)
- Evidence PNGs under `requirements/localization/android_evidence/`
- Localization suite `flutter test test/localization/` → PASS
- `dart analyze` (l10n + Home + Manifest) → No issues found

## Integrity

| Layer | Result |
|---|---|
| GLOBAL ZH | unchanged **VERIFIED** (not downgraded) |
| Model / Physics / Renderer | not modified for Android PASS |
| Android integration fix | Impeller disabled (see LIFECYCLE report) |
| Test-only | buoyancy android test expects ZH gravity labels |

## Severity

| Level | Count | Notes |
|---|---:|---|
| P0 | 0 | |
| P1 | 0 | Impeller cold-start hang remediating |
| P2 | >0 | Material Back tooltip English; minor CJK baseline/spacing |

## Final

GLOBAL ZH: **VERIFIED**  
ANDROID ZH: **VERIFIED**  
Product Final Status: **READY CANDIDATE** (Android gates closed; not a store Release declaration)

## Stop

Phase 8 complete. Do not auto-enter Release / other domain batches from this phase.
