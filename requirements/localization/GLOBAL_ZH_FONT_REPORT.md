# GLOBAL_ZH_FONT_REPORT

> Builds on `FONT_LOCALIZATION_AUDIT.md` · PHASE 7

## Stack

- App fallback (`main.dart`): Microsoft YaHei / PingFang SC / Noto Sans CJK SC / Arial
- Many sims hardcode `fontFamily: 'Arial'` or `Times New Roman` for PhET parity → OS CJK fallback for Chinese glyphs

## Risk

| Topic | Status |
|---|---|
| Glyph availability | CJK via system fallback |
| Baseline / weight shift | possible vs Arial-only EN | P2 |
| Mixed ZH + Latin | common in readouts | OK |
| Mixed ZH + numeric/units | OK |
| Superscripts/subscripts (H₂O, Na⁺) | Unicode preserved | OK |
| Symbols λ θ ψ | Latin/Greek kept | OK |

## Gate

No P0/P1 font breakage identified. Font substitution remains P2 documentation item — no production font package change in PHASE 7.
