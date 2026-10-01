# ANDROID_ACCEPTANCE_MATRIX_PHASE9

| Area | Test | Result | Evidence |
|---|---|---|---|
| Launch | Install + launch debug | PASS | integration A1; `qm_p9_01_launch_coins.png` |
| Launch | Release-like install + launch | PASS | `app-release.apk` install; `qm_p9_release_launch.png` |
| Coins | Classical path | PASS | A2; screenshots |
| Coins | Quantum path | PASS | A2; release Quantum mode capture |
| Coins | 10 / 100 / 10000 | PASS | A3 |
| Photons | Single | PASS | A4 |
| Photons | Continuous | PASS | A4 slider + adb ~20s `qm_p9_photons_cont.png` |
| Photons | Leave / re-enter | PASS | A7/A8 remount; Cont→Single |
| Spin | Exp 1–6 / Custom | PASS | A5 Exp2/3/Custom; A8 Exp2/5/Custom |
| Spin | Block Up/Down | PASS | A5 Cont. + Block chips |
| Spin | Continuous | PASS | A5/A8 Cont.; `qm_p9_spin_cont.png` |
| Bloch | Presets | PASS | A6 +X dropdown |
| Bloch | Observe | PASS | A6 |
| Bloch | Field | PASS | A6 Magnetic Field toggle + pump |
| Bloch | Erase ≠ Reset | PASS | A6 Erase then Reset All |
| Touch | Primary controls | PASS | integration taps on device |
| Lifecycle | Background/Resume | PASS | HOME→am start `qm_p9_resume.png` |
| Lifecycle | Back / Re-enter | PASS* | BACK exits harness Activity; re-launch OK (*no Home stack) |
| Performance | Stress | PASS (QUALITATIVE) | mem dumps; no ANR/crash |
| Assets | Runtime SVG/PNG | PASS | screenshots + APK listing |
| Fonts | Text readable release | PASS | release Coins screenshot |
| Audio | Playback | NOT VERIFIED | no sim-local mp3 |
| Orientation | Landscape lock | PASS | Manifest; no portrait forced |
| Rapid nav | ×10 | PASS | A7 |
| Full journey | Long path | PASS | A8 |
| Regression | Full QM | PASS | 200 PASS |
| Golden | PNG baseline | PASS | 30 retained |
