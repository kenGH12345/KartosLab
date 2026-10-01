# PHASE 5 REPORT — Golden + Behavioral Acceptance + Source Convergence

## Phase 3 baseline

READY CANDIDATE: five Composers, LayoutSpec→MVT→mesh painter, FOV 50, Compare lookAt/viewOffset, Duck/Boat/Bottle source geometry, textures substituted=0, pointer ray, Reset All L0.

## Phase 4 baseline

PRELIMINARY READY CANDIDATE: PlayArea ticker, drag surfaces, per-screen controls. Tests: Buoyancy 138 / Density 81. Frozen P1 open.

## This phase

### Fixes (root cause)

1. **Host cross-screen model dispose (P0)**  
   Screens disposed injected Models on unmount → A→B→A destroyed state.  
   Fix: dispose only when Screen owns Model (`widget.model == null`).  
   Host already keeps persistent Models + pause inactive / resume active.

2. PHASE 5 behavioral + golden test suites + reports.

### Golden

| Metric | Value |
|--------|-------|
| Count | 13 |
| Flutter golden PASS | 13 |
| Flutter golden FAIL | 0 |
| vs PhET source screenshot | PENDING (no user captures this turn) |

See `PHASE_5_GOLDEN_MATRIX.md`.

### Behavior

Automated paths: **PASS** — see `PHASE_5_BEHAVIORAL_REPORT.md`.

### Regression

| Suite | Result |
|-------|--------|
| `flutter test test/buoyancy` | **180 PASS** (was 138; +42 PHASE5) |
| `flutter test test/density` | **81 PASS** |
| `dart analyze lib/buoyancy` | **0 errors** (info-only deprecations) |

### Defects

| ID | Severity | Status |
|----|----------|--------|
| Host Screen dispose of shared Model | P0 | **FIXED** |
| p2 integration equivalence | P1 FROZEN | APPROXIMATE |
| Boat cabin basin coupling | P1 FROZEN | DEFERRED |
| Provenance SHA | P1 FROZEN | OPEN |
| No THREE materials / depth / lighting fidelity | P1 | RENDERER LIMITATION |
| PhET pixel Source Δ | P1 | OPEN (screenshots not provided) |
| Material RadioListTile chrome vs PhET controls | P2 | OPEN |

### Renderer

Perspective camera + triangle mesh painter — **ADAPTABLE**, not THREE.  
**P1 RENDERER LIMITATION** documented; not bypassed by fake screenshots or geometry edits.

### Applications caveat

Boat cabin basin dynamic coupling remains **DEFERRED**. Flag: `ApplicationsComposer.cabinBasinCoupling = DEFERRED`.

### Provenance

| Item | Value |
|------|-------|
| Buoyancy package | 1.3.0-dev.2 |
| LOCAL density-buoyancy-common HEAD | `0c835c642c0603531c3b9f0844fcb8b196abe003` |
| Lockfile pin | `0295f8f62bff7f345185fbf11a9e42c08206e4c5` |
| Exact revision match | **OPEN** (do not forge) |

### Out of scope

- Android = **NOT STARTED**
- Home = **NOT STARTED**
- No MegaComposer
- No other sims modified

## Final status

**READY CANDIDATE**

Cannot declare READY while frozen P1s remain, Source screenshot Δ pending, and RENDERER LIMITATION open.
