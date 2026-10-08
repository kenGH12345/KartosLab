# GLOBAL LOCALIZATION PHASE 0 — STATUS

Generated: 2026-10-08

## Counts

| Item | Value |
|---|---:|
| Files Scanned | 2221 |
| User-visible Strings | 2341 |
| English | 1337 |
| Chinese | 765 |
| Mixed | 70 |
| Accessibility | 55 |
| Home hits | 71 (EN 10 / ZH 50 / MIX 11) |
| Simulation (rest of lib) | see inventory module table |
| Hard-coded (non-strings-file) | see inventory §10 |
| Existing localization infrastructure | 32 `*Strings` bags; **no** `lib/l10n`, **no** `.arb` |

## Files Modified (PHASE 0)

| File | Action |
|---|---|
| `requirements/localization/LOCALIZATION_INVENTORY.md` | **created** |
| `requirements/localization/LOCALIZATION_GLOSSARY.md` | **created** |
| `requirements/localization/LOCALIZATION_EXCEPTIONS.md` | **created** |
| `requirements/localization/_phase0_raw.json` | audit artifact |
| `requirements/localization/_phase0_summary.json` | audit artifact |
| `requirements/localization/_phase0_modules.json` | audit artifact |
| `tooling/phase0_localization_audit.py` | scanner (dev tooling) |
| `tooling/phase0_generate_docs.py` | doc generator (dev tooling) |

**Simulation Model / Physics / Renderer: 0 files modified.**

## Final Status

**NOT READY**

Reason: English-dominant UI; no unified localization layer; Home/Sim mixed language; no zh goldens yet.
