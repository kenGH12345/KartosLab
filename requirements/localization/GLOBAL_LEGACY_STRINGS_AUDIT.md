# GLOBAL_LEGACY_STRINGS_AUDIT

| Legacy Bag | Domain | Consumers | User-facing EN remaining | Status |
|---|---|---|---|---|
| EspStrings (+ titleEn dual) | mechanics | ESP home/tabs | EN dual keys exist; UI uses ZH | LOCALIZED / dual retained |
| HookesLawStrings | mechanics | Hooke's Law | tabs fixed ZH in PHASE 7 | LOCALIZED |
| Density/Buoyancy/… | fluids | phase3 | ZH bags | LOCALIZED |
| OhmsLaw/Riaw/Cck/… | electricity | phase4 | ZH bags | LOCALIZED |
| Bl/Woas/WavesIntro/… | optics/waves | phase5 | ZH bags | LOCALIZED |
| Qm/Qwi | quantum | phase5 | ZH bags | LOCALIZED |
| Bce/Mp/Som/Baa/Phs/Abs/… | chemistry | phase6 | ZH bags + strings_zh.json | LOCALIZED |
| BamStrings | chemistry | BAM | loads strings_zh.json | LOCALIZED |
| Unmigrated bags (blackbody, curve-fitting, plinko, efac…) | other | home entries | EN possible | NOT STARTED |

## Rule

Legacy bags **retained**. Migrated sims must not show EN via bags. Dual EN constants (e.g. `titleEn`) allowed only if unused in product UI.
