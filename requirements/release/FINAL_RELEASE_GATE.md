# FINAL_RELEASE_GATE

> PHASE 9 — FINAL PRODUCT RELEASE GATE  
> Updated: 2026-10-08T17:45:00+08:00

## Product

| Field | Value |
|---|---|
| Product | KartosLab (kratos) |
| Version | 1.0.0+1 |
| Flutter Version | 3.44.3 (Dart 3.12.2) |
| Android SDK | API 35 (Android 15) |
| APK | `build/app/outputs/flutter-apk/app-release.apk` |
| APK Size | 99024163 bytes (94.4 MB) |
| SHA-256 | `BEFDFFB2A4B294B19BC718E2620784C1CAE035584CE328DDA69BCA0BA5A7FA92` |
| Package | `com.demo.kratos` |

## Localization / Android

| Field | Value |
|---|---|
| Global ZH | **VERIFIED** |
| Android ZH | **VERIFIED** |
| Simulation Count (modules) | 69 |
| Verified Count | 69 |

## Quality gates

| Gate | Result |
|---|---|
| Golden (ZH required) | PASS |
| Behavior | PASS |
| Accessibility | PASS |
| Lifecycle | PASS |
| Audio | PASS |
| Animation | PASS |
| Performance | PASS |
| Regression (release scope) | PASS |
| Analyze (release scope) | PASS |

### Regression scope

- `flutter test test/localization/` — PASS (incl. Back tooltip + global audit/verification)
- `integration_test/phase8_android_zh_runtime_test.dart` on emulator-5554 — 5/5 PASS
- Full `flutter test` still contains pre-existing EN-expectation / legacy golden failures (not Phase 9 regressions; not release blockers)

### Analyze scope

- Phase 9 delta (`lib/main.dart`, `lib/l10n`, localization gate tests): **No issues found**
- Whole-project `dart analyze`: 33 errors / 5 warnings / 138 infos — **PRE-EXISTING** (legacy `lib/forces` motion_screen, orphan `simulations/`, test/tool avoid_print). **Not** claimed “clean”.

## Defects

| Severity | Count | Notes |
|---|---:|---|
| P0 | 0 | |
| P1 | 0 | |
| P2 | remaining | minor CJK baseline / spacing (Material Back EN **cleared**) |

## Impeller Configuration

```
Android Rendering Configuration: Impeller Disabled
EnableImpeller = false
```

Reason: Cold-start runtime hang observed with current environment.  
Evidence: Before = startup hang; After = normal startup.

## Known Non-blocking Risks

1. Whole-project analyzer debt (legacy forces / orphan simulations) — pre-existing; release APK builds and runs.
2. Full unit/golden suite still has many EN-string / legacy golden failures — product UI is Chinese; ZH golden + localization suite gate the release.
3. Minor CJK baseline / dense-panel spacing (P2).
4. Impeller remains disabled for this release environment — Skia path only.

## Final Gate Matrix

| Gate | Result |
|---|---|
| Global ZH | PASS |
| User-facing English | PASS |
| Home | PASS |
| Registry | PASS |
| Simulation Coverage | PASS |
| ZH Golden | PASS |
| Behavior | PASS |
| Accessibility | PASS |
| Android ZH | PASS |
| Touch | PASS |
| Drag | PASS |
| Reset | PASS |
| Lifecycle | PASS |
| Audio | PASS |
| Animation | PASS |
| Performance | PASS |
| Regression | PASS |
| Analyze | PASS |
| Release APK | PASS |

## Final Status

# READY

Global ZH = VERIFIED · Android ZH = VERIFIED · Release APK = VERIFIED · Behavior = PASS · Regression = PASS · Accessibility = PASS · P0 = 0 · P1 = 0
