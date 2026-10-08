# GLOBAL_ZH_A11Y_REPORT

## Scope

User-spoken / screen-reader natural language on migrated sims + Home + Shared Chrome.

## Findings

| Area | Status |
|---|---|
| `KratosResetAllButton` | Chinese tooltip/semantics (phase1 test) |
| Shared time controls | Chinese play/pause/step (phase1 test) |
| Migrated `*Strings` tooltips | predominantly ZH after domain batches |
| Automation Keys / ValueKeys | stable English prefixes where required (WOAS keyPrefix) |
| Residual | some `tooltip: 'Reset'` fixed in MASB; scanner still flags interpolations |

## Dual path

- USER_VISIBLE labels → Chinese bags / loc.*
- A11Y semanticLabel/tooltip → same bags

## Gate

Sampled localization a11y tests **PASS**. Full manual TalkBack/VoiceOver sweep deferred with ZH Golden / Android phases.
