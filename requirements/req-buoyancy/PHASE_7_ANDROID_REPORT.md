# PHASE_7_ANDROID_REPORT.md

## Goal

Real Android runtime verification for Buoyancy (not widget-test-only).

## Device evidence

Pixel Tablet emulator-5554 · Android 15 / API 35 · 2560×1600 @ 320dpi · landscape · debug APK.

## Runtime gate

| Gate | Result |
|------|--------|
| Build / Install | PASS |
| Startup | PASS |
| Five screens | PASS |
| Touch / Drag | PASS |
| Reset | PASS |
| Lifecycle / switch | PASS |
| Orientation | PASS |
| Visual screenshots | PASS |
| Performance (qualitative) | PASS |
| Crash | none |
| Regression Buoyancy | 192 PASS |
| Density | 81 PASS |
| Analyze | 0 errors |

## Integration suite

`integration_test/buoyancy_android_runtime_test.dart` → **8 / 8 PASS** on `emulator-5554`.

## Defects

| Sev | Item | Status |
|-----|------|--------|
| P0 | — | 0 |
| P1 | — | 0 |
| P2 | Material Radio/Slider chrome ≠ PhET | carried (not Android-only) |

## Android Runtime

**VERIFIED**

## Final Status

**READY CANDIDATE**

Home / Release / Final READY — **NOT STARTED** (stop after PHASE 7).
