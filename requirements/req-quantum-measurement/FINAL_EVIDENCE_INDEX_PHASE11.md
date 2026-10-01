# FINAL_EVIDENCE_INDEX_PHASE11

| Phase | Report | Evidence | Status |
|---:|---|---|---|
| 1 | `PHASE_1_REPORT.md` | NUMERICAL_MODEL, FUNCTION_MAP, RNG_SPEC, RESET_SEMANTICS, model tests | done |
| 2 | `PHASE_2_REPORT.md` | LAYOUT_*, layout_geometry tests | done |
| 3 | `PHASE_3_REPORT.md` | Coins composer/scenes, coins_phase3 tests, QCT embedding | done |
| 4 | `PHASE_4_REPORT.md` | Photons evidence/trajectory/animation, photons_phase4 | done |
| 5 | `PHASE_5_REPORT.md` | Spin evidence/config/trajectory, spin_phase5 | done |
| 6 | `PHASE_6_REPORT.md` | Bloch projection/measurement/erase, bloch_phase6 | done |
| 7 | `PHASE_7_REPORT.md` | GLOBAL_VISUAL_*, GOLDEN_BASELINE, 30 PNG, VISUAL_DIFF_LOG | done |
| 8 | `PHASE_8_REPORT.md` | FULL_USER_JOURNEY, BEHAVIOR_MATRIX, STATE_MACHINE, BEHAVIORAL_EVIDENCE, phase8_behavior_test | done |
| 9 | `PHASE_9_REPORT.md` | ANDROID_RUNTIME_EVIDENCE, ACCEPTANCE_MATRIX, RELEASE_HARDENING, android-qa/phase9 | done · Runtime VERIFIED |
| 10 | `PHASE_10_REPORT.md` | HOME_SOURCE_EVIDENCE, PLATFORM_EVENT_MAPPING, HOST_GESTURE_BOUNDARY, PLATFORM_ACCEPTANCE, phase10 + home Android | done · Home VERIFIED |
| 11 | `PHASE_11_REPORT.md` | FINAL_SOURCE_FREEZE, TRACEABILITY, ASSET_MANIFEST, RELEASE_CANDIDATE, this index, android-qa/phase11* | **Final gate** |

## Final suite pointers

| Suite | Path / result |
|---|---|
| Golden ×3 | `android-qa/phase11_golden_run{1,2,3}.txt` → 29 PASS each |
| Full QM | `android-qa/phase11_full_qm.txt` → **207 PASS** |
| Analyze | `android-qa/phase11_analyze.txt` → 1 info (super params) |
| Android Home final | `android-qa/phase11/android_home_final.txt` → 2 PASS |
| Android Runtime final | `android-qa/phase11/android_runtime_final.txt` → 8 PASS |
| Release APK meta | `android-qa/phase11_apk_meta.txt` |
| Release assets | `android-qa/phase11_apk_assets.txt` |
| Cold Home screenshot | `android-qa/phase11/qm_p11_cold_home.png` |
