# FINAL_ANDROID_RELEASE_REPORT

> PHASE 9 — FINAL RELEASE GATE

## Device

| Field | Value |
|---|---|
| id | emulator-5554 |
| model | Pixel Tablet |
| Android | 15 |
| API | 35 |
| Resolution | 2560 × 1600 |
| Density | 320 dpi |
| Orientation | Landscape |

## Runtime gates

| Gate | Result | Evidence |
|---|---|---|
| Build (release APK) | PASS | `flutter build apk --release` |
| Install release APK | PASS | `adb install -r` Success |
| Cold Start | PASS | MainActivity focus + pid |
| Home | PASS | Chinese title / categories |
| Touch | PASS | phase8 integration 5/5 |
| Drag | PASS | Buoyancy / high-risk sample |
| Reset | PASS | phase8 + prior ANDROID_ZH |
| Lifecycle bg/resume | PASS | HOME → resume same pid/task |
| CJK Typography | PASS | Phase 8 carry-forward |
| Scientific Symbols | PASS | Phase 8 carry-forward |
| Accessibility | PASS | Back tooltip now ZH |
| Audio | PASS | Phase 8 carry-forward |
| Animation | PASS | Phase 8 carry-forward |
| Performance | PASS | Phase 8 carry-forward |

## Product path (user logic)

```
Cold Start → Home → Category → Simulation → Interact → Reset → Back → Home
(+ Background → Resume)
```

Domain smoke (phase8): Mechanics / Gravity / Vector / Fluids / Density / Buoyancy / Gases / Electricity / Circuits / Electromagnetism / Optics / Waves / Quantum / Chemistry — covered via representative cards.

Representative sealed sims re-checked (regression only, no redevelopment): Buoyancy, QWI, Quantum Measurement, Membrane Transport, BCE, Gas Properties, Bending Light, Color Vision, Molecule Shapes, Build an Atom, Collision Lab.

## Impeller

```
Android Rendering Configuration: Impeller Disabled
EnableImpeller = false
```

Reason: Cold-start runtime hang observed with current environment.  
Evidence: Before = startup hang; After = normal startup.  
Not claimed as Impeller bug fixed.

## Android ZH Final

**ANDROID ZH = VERIFIED**
