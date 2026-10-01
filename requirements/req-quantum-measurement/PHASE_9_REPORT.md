# PHASE 9 STATUS

```
PHASE 9 STATUS

Scope:
Android Runtime + Release Hardening

Build:
PASS

Install:
PASS

Launch:
PASS

Coins:
PASS

Photons:
PASS

Spin:
PASS

Bloch:
PASS

Touch:
PASS

Lifecycle:
PASS

Background / Resume:
PASS

Back / Re-enter:
PASS

10k Coins:
PASS

Continuous Photons:
PASS

Continuous Spin:
PASS

Bloch Magnetic Field:
PASS

Assets:
PASS

Fonts:
PASS

SVG / PNG Runtime:
PASS

Audio:
NOT VERIFIED

Performance:
PASS (QUALITATIVE + mem dumps)

Release-like Build:
PASS

Full Android User Journey:
PASS

Stress Path:
PASS

Regression:
PASS

Golden:
30 / 30

Full QM:
200 PASS

P0:
none

P1:
none

P2:
- SVG <style/> unhandled warning (non-blocking)
- Debug cold-start Choreographer frame skips
- Flutter Semantics sparse for uiautomator text dump

Android Runtime:
VERIFIED

Home:
NOT STARTED

Product:
NOT READY

Status:
READY CANDIDATE
```

---

## Summary

Simulation Runtime on **Pixel Tablet emulator-5554** (Android 15 / API 35 / 2560×1600 / 320dpi) verified via:

1. Device integration_test **8/8 PASS** (real touch)
2. Debug runtime screenshots (Coins/Photons/Spin/Bloch + Cont + resume)
3. Profile + Release APKs with QM entry (`-t debug_quantum_measurement_main.dart`)
4. Release APK asset packaging confirmed
5. Desktop regression **200 PASS**; Golden **30** retained
6. No ANDROID-DERIVED FIX required (Model/Layout/Golden frozen)

Harness: `lib/quantum_measurement/debug_quantum_measurement_main.dart` — **not** Home Integration.

---

## A. Device

| Device | Android | API | Resolution | Density | Build |
|---|---|---:|---|---|---|
| Pixel Tablet emulator-5554 | 15 | 35 | 2560×1600 | 320dpi (~2.0) | debug / profile / release |

## B. Runtime Acceptance

| Screen | Path | Result | Evidence |
|---|---|---|---|
| Coins | Classical + Quantum + counts | PASS | A2 A3; screenshots |
| Photons | Classical/Quantum/Cont/Stop | PASS | A4; `qm_p9_photons*.png` |
| Spin | Exp / Block / Cont | PASS | A5; `qm_p9_spin*.png` |
| Bloch | Preset/Observe/Field/Erase/Reset | PASS | A6; `qm_p9_bloch.png` |

## C. Lifecycle

| Scenario | Expected | Actual | Result |
|---|---|---|---|
| Tab remount dispose | prior screen disposed | A7 findsNothing after leave | PASS |
| Cont leave | no crash / remount clean | A4/A7/A8 | PASS |
| HOME → resume | Activity restored | Bloch still shown | PASS |
| BACK | Activity finish (harness root) | splash then re-launch OK | PASS |
| Rapid ×10 | no crash | A7 | PASS |

## D. Performance

| Scenario | Observation / Measurement | Result |
|---|---|---|
| Cold start | Skipped frames (debug) | QUALITATIVE OK |
| Photons Cont ~20s | PSS ~295 MB; no ANR | PASS |
| Spin Cont ~20s | PSS ~303 MB; no ANR | PASS |
| 10000 coins | A3 no freeze/OOM | PASS |
| Memory leak claim | NOT asserted | NOT MEASURED (precise) |

## E. Release Hardening

| Item | Result | Evidence |
|---|---|---|
| Profile APK | PASS | 118.3 MB |
| Release APK | PASS | 59.1 MB; launch screenshot |
| Assets in APK | PASS | listing file |
| Fonts | PASS | visible text |
| Audio | NOT VERIFIED | — |

## F. Regression

| Suite | Before | Current | Result |
|---|---:|---:|---|
| Model | included@200 | included | PASS |
| Behavior | 33 paths | 33 | PASS |
| Golden | 30 | 30 | PASS |
| Full QM | 200 | **200** | PASS |
| Android integration | 0 | **8** | PASS |

---

## Gates

```
Simulation Fidelity       PASS (prior phases)
Visual Fidelity           PASS (Golden 30)
Behavioral Acceptance     PASS (PHASE 8)
Android Runtime           VERIFIED
Lifecycle                 PASS
Performance               PASS (QUALITATIVE)
Release Hardening         PASS

Home                      NOT STARTED
Product                   NOT READY
```
