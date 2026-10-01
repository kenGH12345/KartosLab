# PHASE_3_GAP_MATRIX — Molecules and Light

**Date:** 2026-03-21  
**Source of truth:** `phet sourses/molecules-and-light-main` + `greenhouse-effect/js/micro` (SHA `6c84ad0f`) + `scenery-phet/WavelengthSpectrumNode.ts`

## Summary

| Area | Phase 2 | Phase 3 | Notes |
|------|---------|---------|-------|
| Behavior (8×4) | Model PASS | View+Model PASS | 32 combo regression tests |
| Animation | Partial | PASS (P2 residual) | Radial stretch vs per-atom source modes |
| Spectrum | **P1 gap** | **PASS** | Full `SpectrumDiagram` CustomPainter |
| Controls | PASS | PASS | Slow=0.5 source-confirmed |
| Visual | P1 spectrum | P0=0 P1=0 | Remaining P2 chrome |
| Lifecycle | PASS | PASS | Clock dispose tested |
| Home | Not done | **Not done** | Explicitly deferred |

## Behavior

| Item | Status |
|------|--------|
| Photon emit / absorb / re-emit | PASS |
| 32 molecule×light strategies | PASS |
| Absorbed wavelength persistence | PASS |
| Light switch clears flying only | PASS |
| Molecule switch installs fresh molecule | PASS |
| Pause freezes model (clock→canvas) | PASS |
| Step = manualStep(1/60) while paused | PASS |
| Slow factor 0.5 | PASS (source `SLOW_SPEED_FACTOR`) |
| Reset → IR / OFF / CO / running / normal | PASS |

## Spectrum

| Item | Status |
|------|--------|
| Log frequency 10³…10²¹ Hz over 657 px | PASS |
| Wavelength ticks via c=299792458 | PASS |
| Bands Radio…Gamma | PASS |
| Visible = WavelengthSpectrumNode 400–790 THz | PASS |
| Frequency / wavelength arrows | PASS |
| ChirpNode decreasing wavelength | PASS |
| Dialog open/close preserves state | PASS |
| Substituted assets | **0** (CustomPainter only) |

## Visual residual (P2 only)

| Item | Severity |
|------|----------|
| Vibration = uniform radial stretch (source has per-molecule modes) | P2 |
| Tick labels use `10^n` ASCII, not RichText superscript | P2 |
| Visible rainbow approximate vs `VisibleColor` LUT | P2 |
| Dialog chrome vs scenery-phet Dialog exact padding | P2 |

## Forbidden / deferred

- Home integration — next phase
- Greenhouse Effect climate screens/models — not present
- Phase 1 physics redesign — not touched
