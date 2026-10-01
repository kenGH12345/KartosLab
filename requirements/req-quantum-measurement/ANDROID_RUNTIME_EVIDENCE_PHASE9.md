# ANDROID_RUNTIME_EVIDENCE_PHASE9

Date: **2026-09-30**  
Commit: *(workspace not a git root; evidence by APK + screenshots + logs)*  
Install method: `flutter test integration_test/... -d emulator-5554`; `flutter run -t lib/quantum_measurement/debug_quantum_measurement_main.dart`; `adb install -r app-profile.apk` / `app-release.apk`  
Orientation: **landscape locked** (`AndroidManifest.xml` `android:screenOrientation="landscape"`)  
Product constraint: portrait **not** exercised (source/product-defined lock)

## Device

| Field | Value |
|---|---|
| Device | Pixel Tablet (`emulator-5554`) |
| Model | Pixel Tablet |
| Android | 15 |
| API | 35 |
| Resolution | 2560 × 1600 physical |
| Density | 320 dpi (devicePixelRatio ≈ 2.0) → logical ~1280 × 800 |
| Flutter | 3.44.3 · Dart 3.12.2 |
| Build modes | debug (integration + run) · profile APK · release APK |

## Viewport / DesignFrame

Logical ~1280×800 with ~44px runtime chrome.  
`QmDesignFrame` scale = `min(w/1024, h/618)` observed: cream/white letterbox, no control clipping on Coins/Photons/Spin/Bloch screenshots.

## Tests performed

### Integration (real device touch)

`flutter test integration_test/quantum_measurement_android_runtime_test.dart -d emulator-5554`  
**8 / 8 PASS** (~2m25s) — log: `android-qa/phase9/integration_test_log2.txt`

| ID | Coverage |
|---|---|
| A1 | Launch + four screens |
| A2 | Coins Classical Flip/Reveal + Quantum Reprepare/Observe |
| A3 | Counts 10 / 100 / 10000 |
| A4 | Photons Classical/Quantum/Many→Single + slider continuous burst |
| A5 | Spin Exp 2/3, Cont., Block ↓/↑, Custom |
| A6 | Bloch +X Observe Erase Field Reset |
| A7 | Rapid switch ×10 + dispose |
| A8 | Full Android user journey + leave/re-enter |

### Manual / adb runtime

| Item | Evidence |
|---|---|
| Launch Coins | `qm_p9_01_launch_coins.png`, `qm_p9_coins_now.png` |
| Photons | `qm_p9_photons.png`, `qm_p9_after_tap.png` |
| Photons Cont ~20s | `qm_p9_photons_cont.png`, `mem_photons_cont.txt` |
| Spin | `qm_p9_spin.png`, `qm_p9_spin_cont.png` |
| Bloch | `qm_p9_bloch.png` |
| Background → Resume | HOME 5s → `am start` → `qm_p9_resume.png` (Bloch restored) |
| Back | KEYCODE_BACK exits root Activity (harness has no Home stack) → splash then re-launch |
| Release launch | `qm_p9_release_launch.png` (Coins, SVG OK) |

### Build

| Mode | Artifact | Size |
|---|---|---|
| Profile (QM `-t`) | `build/app/outputs/flutter-apk/app-profile.apk` | 118.3 MB |
| Release (QM `-t`) | `build/app/outputs/flutter-apk/app-release.apk` | 59.1 MB |

Release asset zip listing includes:

- `quantum_measurement/images/classicalCoinHeads.svg`
- `quantum_measurement/images/classicalCoinTails.svg`
- `quantum_measurement/images/greenPhoton.png`
- `quantum_measurement/images/spinScreenIcon.png`

→ `release_asset_listing.txt`

## Observed behavior

- **Coins:** Classical/Quantum SVG coins render; Start Measurement (green arrow); Flip/Reveal/Observe via integration; 10000 selectable without crash.
- **Photons:** PBS/detectors/source; Classical/Quantum; Many Photons + rate; leave via tab remount disposes screen (harness mounts one screen).
- **Spin:** Experiment selector, SGz apparatus, Single/Cont., Block chips reachable in Cont.+multi (A5).
- **Bloch:** Dual spheres, +X vector, Observe/Erase/Magnetic Field/Reset (A6 + screenshots).
- **Lifecycle:** Rapid remount ×10 PASS; HOME/resume returned to Bloch without crash.
- **Memory (QUALITATIVE dumpsys):** baseline TOTAL PSS ≈ 267 MB → Photons cont ≈ 295 MB → Spin cont ≈ 303 MB. Growth under animation expected; **not** claimed leak-free.
- **Jank:** Choreographer “Skipped N frames” on cold start (debug) — QUALITATIVE; no ANR.
- **SVG:** `unhandled element <style/>` warning (known) — coins still paint.
- **Audio:** sim-local mp3 = none; shared tambo hooks **NOT runtime verified**.

## Issues

| ID | Severity | Notes |
|---|---|---|
| — | — | No P0/P1 Android runtime defects found |
| P2 | info | SVG `<style/>` unhandled (pre-existing) |
| P2 | info | Debug cold-start frame skips |
| Note | — | Standalone harness BACK exits Activity (no Home). Product Home Back deferred to Home Integration phase. |

## ANDROID-DERIVED FIX

**None** this phase (no Model/LayoutSpec/Golden changes).
