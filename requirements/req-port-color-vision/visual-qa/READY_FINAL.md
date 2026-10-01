# Color Vision — READY Final Report

> Date: 2026-09-22  
> req-id: `req-port-color-vision`

---

## Final Status: READY

### Tests

**Color Vision:**
- `test/color_vision/model/` — 26 PASS
- `test/color_vision/behavioral/` — PASS (defaults, white/mono, filter, pause/step/reset, RGB mixing, extrema, Home tabs)
- `test/color_vision/view/` smoke — PASS
- `test/color_vision/browser_qa/` lifecycle — PASS
- `test/color_vision/visual/screenshot_capture_test.dart` — 10/10 PASS

**Full Regression:**
```
+3035 ~1 -56
```
- Color Vision failures: **0**
- Failures are pre-existing unrelated visual-capture tests:
  - projectile_motion (20)
  - pendulum_lab (18)
  - states_of_matter (15)
  - gas_properties (2)
  - forces (1)
- Same pattern as prior READY sims (e.g. wave-on-a-string reported 56 pre-existing fails)

Log: `visual-qa/full_test_raw.txt`

### Analyze

| Scope | Result |
|-------|--------|
| `lib/color_vision/` + Home entry | **CLEAN** |
| Full `dart analyze` | Pre-existing errors in `phet/quantum_coin_toss/**` (unrelated); CV only 1 fixed `unnecessary_import` info |

### Gates

```
P0: 0
P1: 0
P2: 5 (documented micro — see below)
```

### Screens

| Screen | Status |
|--------|--------|
| Single Bulb | **PASS** |
| RGB Bulbs | **PASS** |

### Behavior

**PASS** — Model locked; acceptance matrix covers White/Mono, Beam/Photons, Filter, Exterior/Interior, Pause/Step/Reset, RGB combinations, slider extrema, screen isolation, Home tab lifecycle.

### Visual

**PASS** — Pixel QA vs user originals (`VISUAL_PIXEL_QA.md`):
- S1/R1 Flutter captures at 768×504
- DIFF overlays generated
- Chrome live Single Bulb screenshot matches structure of PhET reference
- Assets Substituted = **0**

### Assets

```
Original reused: YES
Substituted: 0
```

### Home

**PASS** — 物理 → 光学与波动 → 色觉 → `ColorVisionHome` (Single Bulb | RGB Bulbs). Subtitle `Single Bulb · RGB Bulbs`. Lifecycle tests PASS. Chrome Home screenshot captured.

### Platform

| Platform | Status | Evidence |
|----------|--------|----------|
| Windows | **VERIFIED** | `flutter run -d windows` → Built `kratos.exe`, VM Service up (`windows_run_raw.txt`) |
| Chrome | **VERIFIED** | Home at `:8099`; Color Vision smoke at `:8101` — Single Bulb UI live (`CHROME_*.png`, `chrome_cv_smoke_raw.txt`); no Dart runtime errors via DTD |
| Edge | **NOT VERIFIED** | Not run this session (Chrome covers web) |
| Android | **NOT VERIFIED** | Emulator present but not required for READY |

### Remaining P2

1. Spectrum / Gaussian track micro-bevel vs scenery-phet SpectrumSliderTrack
2. Filter OnOffSwitch thumb gradient polish vs sun OnOffSwitch
3. Flashlight/filter wire corner radii ±1–3 px
4. RGB label plate rotation/offset micro-alignment
5. Original screenshots include Joist chrome; Flutter captures are play-area only (inflates global MSE)

### Changed Files (this READY round)

- `lib/color_vision/view/rgb_slider.dart` — PhET 28×14 rectangular thumb
- `lib/color_vision/view/single_bulb_screen_view.dart` — FilterWire switch outline
- `test/color_vision/visual/screenshot_capture_test.dart` — precacheImage
- `test/color_vision/behavioral/acceptance_matrix_test.dart` — new
- `test/color_vision/browser_qa/home_lifecycle_test.dart` — import cleanup
- `tool/color_vision_platform_smoke.dart` — Chrome/Windows smoke entry
- `requirements/req-port-color-vision/visual-qa/**` — captures, diffs, logs, reports
- `lib/screens/home_screen.dart` — subtitle (prior session)

### Reports

- `SOURCE_AUDIT_REPORT.md`
- `ASSET_MAP.md`
- `PHASE_STATUS.md`
- `visual-qa/VISUAL_PIXEL_QA.md`
- `visual-qa/READY_FINAL.md` (this file)

### Model lock

No Model / VisibleColor / Photon / EventTimer / wavelength / Reset r=18 changes this round.
