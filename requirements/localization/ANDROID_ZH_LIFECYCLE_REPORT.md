# ANDROID_ZH_LIFECYCLE_REPORT

> PHASE 8 · emulator-5554

## Verdict

**PASS**

## Scenarios

| Scenario | Method | Result |
|---|---|---|
| Cold start APK | `am start -W` after Impeller disable | Status=ok, COLD, `firstWindowDrawn=true`, Home Chinese |
| Background → Resume | HOME key → `am start` | HOT resume, Home intact (`02_home_after_resume`) |
| Home → Sim → Back → Home | integration_test paths | PASS |
| Home → Sim A → Back → Sim B | high-risk + domain smoke loops | PASS |
| Continuous ticker sims | Collision / Buoyancy / Gas / SoM | No freeze; fixed-frame pumps (no settle) |
| Dispose leakage | leave + re-enter | No duplicate fatal / no stuck Splash |

## ANDROID_RUNTIME_ROOT_CAUSE (resolved)

| Field | Value |
|---|---|
| Symptom | Cold start stuck on Splash; `firstWindowDrawn=false` |
| Evidence | log/dumpsys before Impeller disable; 35KB black/splash screenshots |
| Root cause | Impeller/Vulkan path on Pixel Tablet API 35 emulator |
| Fix | `io.flutter.embedding.android.EnableImpeller=false` in `AndroidManifest.xml` |
| Impact | Android first-frame only; Model/Physics/Renderer unchanged |
| After | Cold start ~2.5–5s Status=ok |

## P0/P1 after remediation

None remaining for lifecycle.
