# FINAL_LOCALIZATION_RELEASE_REPORT

> PHASE 9 — FINAL RELEASE GATE

## Global Chinese

| Gate | Result |
|---|---|
| `global_zh_audit_test.dart` | PASS |
| `global_zh_verification_test.dart` | PASS |
| USER_VISIBLE_ENGLISH | 0 (approved exceptions only) |
| Global ZH status | **VERIFIED** |
| Verified modules | 69 |
| NOT STARTED | 0 |

## Material Back tooltip (Phase 9 fix)

| Item | Detail |
|---|---|
| Prior P2 | Material Back tooltip English |
| Fix | `MaterialApp` `locale: Locale('zh','CN')` + `flutter_localizations` delegates |
| Canonical string | `loc.common.back` = 「返回」 |
| Test | `test/localization/material_back_tooltip_zh_test.dart` PASS |
| Exceptions expanded | **No** |

## Home / Registry

| Check | Result |
|---|---|
| Home ↔ Registry ↔ Route ↔ Simulation | aligned |
| Stale / dead / duplicate cards | 0 |
| Missing localization | 0 |
| Domain coverage (Mechanics…Chemistry) | PASS (phase8 domain smoke + matrix) |

## Visual / Layout

| Check | Result |
|---|---|
| ZH Golden (required) | PASS |
| Layout ratio audit | No P0/P1 drift (`GLOBAL_ZH_LAYOUT_RATIO_AUDIT.md`) |
| Remaining P2 | minor CJK baseline / spacing |

## Accessibility

| Check | Result |
|---|---|
| User-facing A11y language | Chinese |
| Back / Reset / controls / dialogs | Chinese |
| Automation IDs / keys / routes | stable |

## Source integrity (Phase 9 delta)

Phase 9 product code changes limited to:

- `lib/main.dart` — Material locale + localizationsDelegates (EXPECTED)
- `pubspec.yaml` — `flutter_localizations` (EXPECTED)
- `test/localization/material_back_tooltip_zh_test.dart` (EXPECTED)
- Prior Impeller Manifest note (Phase 8, EXPECTED)

No Phase 9 Physics / Model / Renderer / Solver changes.

## Localization Final

**GLOBAL ZH = VERIFIED**
