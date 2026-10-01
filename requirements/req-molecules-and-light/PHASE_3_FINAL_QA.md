# PHASE_3_FINAL_QA — Molecules and Light

## Overall Status

```text
READY CANDIDATE
```

Home integration: **not started** (explicit Phase 3 boundary).

## Acceptance checklist

| Criterion | Result |
|-----------|--------|
| Full Spectrum complete | PASS |
| 32 combinations verified | PASS |
| Controls verified | PASS |
| Animation verified | PASS (P2 vibration fidelity) |
| Reset verified | PASS |
| State switching verified | PASS |
| Visual P0 | **0** |
| Visual P1 | **0** |
| Tests PASS | **52** |
| Analyze clean | **No issues found** |
| Substituted assets | **0** |
| Phase 1 physics untouched | YES |
| Greenhouse climate screens | NOT present |
| Home | NOT integrated |

## Commands

```bash
flutter test test/molecules_and_light/
# 52 PASS

dart analyze lib/molecules_and_light test/molecules_and_light
# No issues found
```

## Deliverables

| File | Purpose |
|------|---------|
| `PHASE_3_GAP_MATRIX.md` | Gap audit |
| `PHASE_3_SPECTRUM_REPORT.md` | WavelengthSpectrumNode / SpectrumDiagram migration |
| `PHASE_3_BEHAVIORAL_QA.md` | 32-combo + controls + photon regression |
| `PHASE_3_VISUAL_MATRIX.md` | Visual checklist + severity |
| `PHASE_3_FINAL_QA.md` | This summary |

## Code added / changed (Phase 3)

- `lib/molecules_and_light/view/spectrum_diagram_painter.dart` — full spectrum
- `lib/molecules_and_light/view/molecules_and_light_screen.dart` — dialog, molecule order, energy arrow label, button caption
- `test/molecules_and_light/phase3_behavioral_test.dart` — spectrum + 32-combo + lifecycle

## Remaining for later phases

1. Home integration
2. P2 polish (VisibleColor LUT, superscript ticks, per-molecule vibration modes)
3. Device / Android verification

## Decision

Phase 3 goals met with only P2 residuals → **READY CANDIDATE**. Do not wire Home until the next phase explicitly requests it.
