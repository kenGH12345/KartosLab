# PHASE 1 — Numerical Implementation

Date: 2026-09-28  
Code root: `lib/physics/quantum_wave_interference/`  
Tests: `test/physics/quantum_wave_interference/` (44 PASS)

## Model

Three independent top-level models (no global singleton):

| Model | Backend |
|---|---|
| `ExperimentModel` → `ExperimentSceneModel` ×4 | Fraunhofer closed-form |
| `HighIntensityModel` → `HighIntensitySceneModel` ×4 | Analytical WaveKernel + time-average |
| `SingleParticlesModel` → `SingleParticlesSceneModel` ×4 | Analytical WaveKernel + Gaussian packet + Probe |

## Solver formulas

### Experiment (Fraunhofer)

```text
sinθ = y / sqrt(y² + L²)
envelope = sinc²(π a sinθ / λ)   // sinc = sin(x)/x
bothOpen → cos²(π d sinθ / λ) * envelope
one covered → 0.5 * envelope(centered on open slit)
which-path → envelope only
noBarrier → 1
```

### HI / SP (WaveKernel)

```text
evaluateUndecohered → applyDecoherenceEvent → intensity
Intensity = Σ_g |Σ components in g|²
Slit diffraction via Fresnel aperture transfer (Abramowitz–Stegun C,S)
Plane magnitude fine-tune 0.57 (PhET #152)
```

### Packet

```text
centerX(t) = x0 + v t
sigma(t) = sigma0 * sqrt(1 + (t/τ)²)
normalization = sqrt(σx0/σx * σy0/σy)
chirp = (t/τ) / (2 σ²)
```

### Detection timing (SP)

Weight-curve rejection ∈ [0.30, 0.70] peaking at 0.50 → `inverseStandardNormalCdf` → delay.

## Coordinate systems

| Screen | Hit x | Hit y |
|---|---|---|
| Experiment | ≈[-1,1] | **[-1,1]** |
| HI / SP | [-1,1] | **[0,1]** |

Enforced via `DetectorHitDomain`.

## Randomness

`QwiRandom` injected everywhere. Production: `SystemQwiRandom`. Tests: `SeededQwiRandom`.

## Time

`SimulationClock` — continuous `advance(wallDt)*factor`, `stepOnce=1/60` unscaled.

| Screen | Slow | Normal | Fast |
|---|---|---|---|
| Experiment | 0.25 | 1 | 4 |
| HI | 0.15 | 0.35 | 0.65 |
| SP | 0.15 | 0.7 | 16 |

## Normalization

Detector PDF (HI/SP): **max-normalized** (not sum-to-1), matching PhET `normalizeDetectorDistribution`.

## Tolerance

- Exact algebraic identities: `1e-9` … `1e-15`
- Determinism: bitwise equal digests under same seed on same platform
- Cross-platform goldens deferred to later phases

## Performance

- Wave grid default **120×120** (solver), not 420×385 (render)
- Hit buffer capped at **25000**
- Snapshot max **4** / scene (5th no-op)
- Probe / PDF evaluation O(grid²) — acceptable for Phase 1 headless

## Incomplete vs PhET (documented for Phase 2+)

| Item | Status |
|---|---|
| WaveMeasurementProjection bite after failed probe | Stubbed (Bernoulli + end-on-success implemented) |
| Plane-wave layered FieldSample for renderer | Not needed until render |
| Full BaseWaveSolver amplitude grid cache | On-demand evaluateSample |
| Slit detector event scheduler (HI 5/s) | Hit-rate reduction present; event list API available |
| Display slit layout pixel constants | Approximate fraction mapping |

See `NUMERICAL_DIFFERENCES.md`.

## No Flutter UI

`domain/` / `numerics/` / `models/` import only `dart:math` and each other — no `flutter/*` / `dart:ui`.