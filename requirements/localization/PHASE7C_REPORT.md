# PHASE7C_REPORT

> FINAL ZH GOLDEN REMEDIATION · 2026-10-08

## Objective

Close remaining LOCALIZED (12) → VERIFIED via real ZH PNG goldens + test-time audio/animation/layout isolation. No Android. No new l10n architecture.

## Remaining Modules (start)

12 LOCALIZED — see `PHASE7C_REMAINING.md`.

## Remediated

| ID | Fix |
|---|---|
| l10n-architecture | Status promote (infra; no UI golden required) |
| collision-lab | ControlPanel `Container`→`Material` (ListTile ink) |
| friction | `enableAudio:false`, `autoStartClock:false` |
| resistance-in-a-wire | Seeded `dotRandom` |
| cck-ac-virtual-lab | Toolbox `_tile` ellipsis / FittedBox (CJK overflow) |
| circuit | Lazy `SoundEffects` / deferred until first tap |
| beers-law-lab | Silent ConcentrationAudio injection |
| fourier-making-waves | Panel Material + TickerMode |
| quantum-coin-toss | TickerMode freeze |
| acid-base-solutions | Seeded IntroController + TickerMode |
| states-of-matter | Seeded SomRandom + paused clock + TickerMode |
| molarity | RecordingMolarityAudio injection |

## ZH Golden

| Metric | Count |
|---|---:|
| Total required (7C set) | 11 UI + 1 infra |
| PASS | 11 (PNG) + infra N/A |
| FAIL | 0 |
| PENDING | 0 |

Harness: `test/localization/phase7c_remaining_golden_test.dart`  
PNGs: `test/goldens/zh/home/<id>_default.png`  
Determinism: double `matchesGoldenFile` + two consecutive suite runs PASS.

## Final Counts

| Status | Count |
|---|---:|
| Total Modules | 69 |
| VERIFIED | 69 |
| LOCALIZED | 0 |
| PARTIAL | 0 |
| NOT STARTED | 0 |

## Gates

| Gate | Result |
|---|---|
| User-facing English | 0 (approved exceptions only) |
| Chinese | dominant |
| Mixed | 0 user-facing |
| Exceptions | unchanged whitelist |
| Accessibility | PASS |
| Layout | P2 only (CJK baseline / minor spacing) |
| Typography | P2 only |
| Term Consistency | PASS |
| Behavior | PASS |
| Regression | PASS (localization suite + 7C goldens) |
| Analyze | CLEAN (scoped remediations) |
| Model | PASS (frozen) |
| Physics | PASS (frozen) |
| Renderer | PASS (frozen) |
| P0 | 0 |
| P1 | 0 |
| P2 | documented |

## Audio

See `PHASE7C_AUDIO.md`.

## Integrity

Allowed: localization strings, golden tests, test clock/audio adapters, layout constraints, typography, documentation, migration status.  
No intentional Model / Physics / Solver / Renderer changes for golden PASS.

## Global ZH Status

**GLOBAL ZH VERIFIED**

## Stop

Phase 7C complete. Do **not** enter PHASE 8 (Android) from this phase.
