# PHASE_1_REPORT — Global Localization Infrastructure

> 2026-10-08

## Architecture

**READY** — `lib/l10n/KartosLocalization` with namespaced API:

- `loc.common.*` / `loc.shared.*` / `loc.home.*` / `loc.physics.*`
- `loc.accessibility.*` / `loc.sim.title(id)`
- Default locale **zh-CN**; English tables retained for future switch
- Catalog mirrors under `resources/localization/`
- Docs: `LOCALIZATION_ARCHITECTURE.md`, `LOCALIZATION_KEY_POLICY.md`

## Glossary

- Canonical terms in `lib/l10n/namespaces/physics_l10n.dart` + updated glossary usage
- Conflicts documented in `GLOSSARY_CONFLICTS.md` (gravity/引力, mass≠weight, pressure=压强, …)
- Weight canonicalized as **重量** (PHASE 1 freeze)

## Keys

| Namespace | Approx keys |
|---|---:|
| common | ~40 |
| home + category | ~25 |
| physics | ~35 |
| accessibility | ~10 |
| sim titles/subtitles | ~130 (65 sims × 2) |
| **Total localization keys** | **~240** |

## Legacy Strings

- 32 `*Strings` bags **retained**
- Adapter: `LegacyStringsAdapter` / `CommonLegacyStringsAdapter`
- Status map: `LEGACY_STRINGS_MIGRATION.md` + `migration_status.json`
- Home/Shared Chrome = LOCALIZED; most sims = NOT STARTED / PARTIAL

## Home

**LOCALIZED**

- All category + card titles/subtitles via `loc`
- Removed English `Physics` / `Chemistry` dual labels
- Unavailable state Chinese
- Card layout: minHeight + 2-line ellipsis (see layout impact)

## Shared Chrome

**LOCALIZED**

- `KratosResetAllButton` default tooltip + semantics
- `TimeControlBar` play/pause/step/reset tooltips
- `KratosPhetTimeControl` semantics
- `SpectrumSlider` wavelength label
- Experiment logger export/clear/delete tooltips via `loc.common`

## Accessibility

- `accessibility.*` namespace + Home card `openSimulation`
- Reset/Play/Pause/Step semantics on L0 chrome
- Automation Keys unchanged (`phet_play_pause`, etc.)

## Font

- Audit: `FONT_LOCALIZATION_AUDIT.md`
- No global font swap; Theme CJK fallbacks kept
- Substitution noted: Arial → system CJK fallback

## Layout Impact

- `PHASE1_LAYOUT_IMPACT.md`
- Home cards only; no page-level Positioned magic

## Tests

`test/localization/`:

| Test | Covers |
|---|---|
| `key_integrity_test.dart` | duplicate / required keys |
| `glossary_consistency_test.dart` | canonical terms + params |
| `home_localization_test.dart` | Home Chinese / no EN residue |
| `shared_chrome_localization_test.dart` | Reset/Play/Pause |
| `accessibility_localization_test.dart` | a11y Chinese |
| `english_residue_scan_test.dart` | scoped FAIL for user-visible EN |

## Regression

- No Physics / Model / Renderer edits
- Sims still use legacy English internally (expected PHASE 1)
- READY sims not re-touched beyond consuming default Reset tooltip (behavior unchanged)

## Remaining English

| Area | Status |
|---|---|
| Home display | Chinese |
| Shared L0 chrome (scoped) | Chinese |
| Simulation internal UI | Still mostly English (NOT STARTED) |
| Legacy `*Strings` | Mostly English bags |
| PhET source / IDs / units | Allowed exceptions |

## Chinese coverage (PHASE 1 scope)

- Infrastructure: **100%** of new keys bilingual (zh default)
- Home UI: **LOCALIZED**
- Shared chrome scoped files: **LOCALIZED**
- Whole product user-visible: still **English-dominant** overall (deferred)

## Status gate

| Gate | Result |
|---|---|
| Architecture | READY |
| Localization tests | PASS (run `flutter test test/localization`) |
| Home | LOCALIZED |
| Shared Chrome | LOCALIZED |
| Full product Chinese | NOT this phase |

**PHASE 1 Final Status: READY CANDIDATE**
