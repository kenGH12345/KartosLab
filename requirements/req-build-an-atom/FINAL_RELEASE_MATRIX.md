# Build an Atom — Final Release Matrix (Phase 9)

Date: 2026-09-28  
Source: `build-an-atom` **1.10.0-dev.0** (`dependencies.json` SHA `d5ef0ac590d0b7609af3af34f5c0f5281e2aa376`)

| Gate | Result | Evidence |
| --- | --- | --- |
| Source Integrity | PASS | `lib/chemistry/build_an_atom` 56 dart files; PhET tree present; no TODO/FIXME/UnimplementedError in product lib |
| Dependency Lock | PASS | shred `427a2abe…` = lock; vegas `8300aa3f…` = lock; BAA SHA matches `dependencies.json` |
| Model | PASS | Phase 0–1 model suite + Phase 7 isolation |
| Atom | PASS | behavioral A–N + Atom goldens + Android drag |
| Symbol | PASS | behavioral O–Q + Symbol goldens + Android reset |
| Game | PASS | behavioral R–AF + Game goldens + Android Level1/Timer/Retry/ShowAnswer/Reset/StartOver |
| Visual | PASS | Phase 5 chrome + ASSET_MAP; Substituted Assets = 0 for runtime images |
| Golden | PASS | BAA 34/34 + Home 2/2 = **36/36**; Run×3 all PASS |
| Golden Determinism | PASS | `golden_determinism_test` + 3 consecutive full golden runs |
| Behavioral | PASS | Atom 13 / Symbol 3 / Game 12 (+ educational/lifecycle groups) |
| Lifecycle | PASS | phase7 20-cycle + 50-cycle game + Home rapid×10 |
| Home | PASS | Formal `构建原子` under 化学→原子结构; QA removed; home_* tests |
| Regression | PASS | BAA **221** PASS; IAAM **108** PASS |
| Analyze | CLEAN | `dart analyze lib/chemistry/build_an_atom lib/screens/home_screen.dart test/chemistry/build_an_atom` → No issues found |
| Android | **VERIFIED** | `integration_test/build_an_atom_android_smoke_test.dart` on `emulator-5554` (Pixel Tablet, API 35) — 5/5 PASS |
| Assets | PASS | 11 PNGs under `assets/build_an_atom/images/`; pubspec dir entry only; **0 mp3** in BAA repo |
| QA Route Cleanup | PASS | 0 user-facing `构建原子 (QA)`; only docs/tests assert absence |

## Final checklist

```text
[x] Source integrity PASS
[x] Dependency lock PASS
[x] Asset integrity PASS
[x] No formal QA residue
[x] Home entry PASS
[x] Home back PASS
[x] Atom PASS
[x] Symbol PASS
[x] Game PASS
[x] Behavior PASS
[x] Lifecycle PASS
[x] Golden 36/36
[x] Golden Determinism PASS
[x] Regression PASS
[x] Analyze CLEAN
[x] Audio evidence documented (P2)
[x] Typography P2 documented
[x] Android VERIFIED
```

## P2 Remaining (non-blocking)

1. **Audio** — BAA repository contains **0** original mp3; `GameAudioAdapter` is vegas/tambo **hooks only** (no forged audio).
2. **PhetFont / Symbol baseline** — `BaaPhetFont` uses platform **Arial**; glyph metrics may subpixel-differ from PhET desktop.

## Working tree note

This KartosLab workspace folder is **not** a git root (`fatal: not a git repository`). Integrity verified via file presence + SHA checks against `DEPENDENCY_LOCK.md` / `dependencies.json`.

## Android evidence

Device: `Pixel Tablet` · `emulator-5554` · Android 15 (API 35)  
Command: `flutter test integration_test/build_an_atom_android_smoke_test.dart -d emulator-5554`  
Covered: Home entry, Atom drag, Symbol reset, Game Level1 + Timer + Retry + Show Answer + Start Over + Reset, Back, rapid re-entry ×5.

## Final Status

```text
Release Gate: PASS
Final Status: READY
```

## Post-release UX (2026-09-28)

Interaction + right-column polish closed — see [`POST_RELEASE_UX_CLOSEOUT.md`](./POST_RELEASE_UX_CLOSEOUT.md).  
Release gate remains **READY**.
