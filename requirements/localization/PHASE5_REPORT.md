# PHASE5_REPORT — Optics / Waves / Quantum

## Scope

Optics / Waves / Quantum — **11** simulations (`PHASE5_SCOPE.md`).

Excluded: chemistry; legacy `wave-interference` (0 EN, not Batch 6).

## Simulation Count

**11**

## Strings

| Metric | Approx |
|---|---:|
| total | ~320 |
| visible | ~290 |
| accessibility | ~30 |
| translated | ~300 |
| remaining | units (nm/Hz), symbols (λ/θ/ψ), RGB channel letters, SG axis tags |

## Accessibility

semanticLabel / tooltip / spoken labels migrated with UI bags (Reset All, Play/Pause/Step, Normal/Slow, Intensity, Probe, …). Automation Keys kept stable via `keyPrefix` / `keyIds` where titles went ZH.

## Chinese Coverage

User-facing natural language for PHASE 5 sims → Chinese string bags + `optics_waves` / `quantum` namespaces. Prior ZH sims (`sound`, `radio-waves`) retained.

## Remaining English

LOCALIZATION_EXCEPTIONS: scientific symbols, units, formula fragments, debug mains.

## Glossary / Conflicts / Term Consistency

| Doc | |
|---|---|
| Update | `PHASE5_GLOSSARY_UPDATE.md` |
| Conflicts | `PHASE5_GLOSSARY_CONFLICTS.md` (Normal 法线 vs 正常; phase 相位) |
| Cross-domain | `PHASE5_TERM_CONSISTENCY.md` |

## Keys / Legacy Adapters

| | |
|---|---:|
| new namespaces | `optics_waves_l10n.dart`, `quantum_l10n.dart` |
| reused | `physics.wavelength/frequency/amplitude`, `common.*` |
| legacy bags | BlStrings / WoasStrings / WavesIntroStrings / NormalModesStrings / FmwStrings / ColorVisionStrings / QmStrings / QwiStrings / QuantumMeasurementStrings (ZH, not deleted) |

## Layout

P0=0 P1=0 P2=QWI config dropdown / QM tab width / ZH Golden capture

## Golden

| | |
|---|---|
| completed | EN baselines retained |
| pending | `test/goldens/zh/phase5/` capture |
| pass | EN files not deleted |

## Behavior / Regression / Analyze

Localization Phase 2–5 tests **PASS**. Scoped analyze **CLEAN** (1 pre-existing unused_import warning outside scope). No Physics/Model/Renderer equation edits; display-name fields on Substance localized; WOAS automation keyPrefix only.

## Per Simulation

| Sim | Status |
|---|---|
| bending-light | LOCALIZED |
| color-vision | LOCALIZED |
| wave-on-a-string | LOCALIZED |
| waves-intro | LOCALIZED |
| normal-modes | LOCALIZED |
| fourier-making-waves | LOCALIZED |
| sound | LOCALIZED |
| radio-waves | LOCALIZED |
| quantum-measurement | LOCALIZED |
| quantum-wave-interference | LOCALIZED |
| quantum-coin-toss | LOCALIZED |

VERIFIED deferred pending full ZH Golden + exhaustive residue pass.

## Final Status

**READY CANDIDATE**
