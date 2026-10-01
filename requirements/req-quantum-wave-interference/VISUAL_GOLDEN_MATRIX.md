# VISUAL_GOLDEN_MATRIX — Phase 5

Layout lock: **768 × 504** for all three screens.  
Goldens remain Model → Solver → RenderData → Interaction driven (no static backdrop substitution).

## Experiment

| State | Golden / test | Notes |
|---|---|---|
| initial | experiment_default | white bg + panel chrome |
| single slit | experiment_* | Fraunhofer unchanged |
| double slit | experiment_* | |
| detector intensity/hits | experiment_* | |
| graph | experiment_* | |
| ruler | experiment_* | display-only |
| snapshot | experiment_* | + audio hook |
| time / reset | experiment_* | |

Existing: **16 / 16** (regenerated in Phase 5).

## High Intensity

| State | Golden | Notes |
|---|---|---|
| initial / photon / electron / neutron / helium | high_* | SVG particle icons |
| electricField / amplitude / realPart | high_* | mode semantics unchanged |
| no barrier / single / double / detectors | high_* | |
| hits / graph / zoom / snapshot / pause / reset | high_* | measuring tape PNG |
| measuring tape visible | covered via screen tests | |

Existing: **22 / 22** (regenerated).

## Single Particles

| State | Golden | Notes |
|---|---|---|
| initial / slits / detectors / probe | sp_* | DetectorProbeNode chrome |
| hits / graph / zoom / snapshot / pause / speed / reset | sp_* | |
| measuring tape | screen + visual tests | original PNG + μm/nm |

Existing: **20 / 20** (regenerated).

## Pixel diff categories (vs PhET screenshot)

| Category | Status |
|---|---|
| Geometry (768×504 panels) | Aligned to Joist margins |
| Typography | Arial ≈ PhetFont — platform P2 |
| Color | QwiColors from QuantumWaveInterferenceColors |
| Asset | Original SVG/PNG/MP3 reused |
| Chrome | Panel #f4f4f4 / stroke #c1c1c1 / r=6 |
| Dynamic State | Wave/hits from real solvers |
| Platform Difference | Font metrics, audio plugin |

## Determinism

Goldens use seeded RNG + `autoStartClock: false` + explicit `stepOnce` warm-up.
