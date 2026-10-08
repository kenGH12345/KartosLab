# GLOBAL_ZH_EXCEPTION_AUDIT

> Source: `LOCALIZATION_EXCEPTIONS.md` · PHASE 7 review

| Term | User-visible? | Keep? | Action |
|---|---|---|---|
| PhET | credits/about | **keep** | brand |
| KartosLab / Kratos | product | **keep** | brand |
| pH | chemistry UI | **keep** | scientific symbol |
| RGB | color-vision | **keep** | channel abbrev; labels already ZH |
| VSEPR | molecule-shapes subtitle | **keep** | theory acronym |
| Planck / Wien | blackbody (if shown) | **keep** | proper nouns |
| χ² | curve-fitting | **keep** | symbol |
| Units (kg, nm, Hz, mol, M, atm…) | yes | **keep** | UNIT class |
| Chemical formulas (H₂O, Na⁺…) | yes | **keep** | FORMULA class |
| Registry IDs (`bending-light`) | no | **keep** | INTERNAL |
| Font family `Times New Roman` / `Arial` | no (glyph request) | **keep** | not UI language |
| `N-body` | if still shown | **translate** | prefer 多体 |
| `OK` / `Go!` | if still shown | **translate** | prefer 确定 / 开始 |

## Whitelist expansion

**None** in PHASE 7. Residual English must be translated or classified as UNIT/FORMULA/INTERNAL — not added to exceptions to pass the gate.

## Not exceptions (still FAIL if present)

Simulation titles, tabs, Reset All, tooltips, semantic labels, game feedback, Home englishName.
