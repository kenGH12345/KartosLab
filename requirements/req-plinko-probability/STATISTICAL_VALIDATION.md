# STATISTICAL_VALIDATION · Plinko Probability

## Method

- Seeded `PlinkoRandom`
- Lab `hopperMode = path` (instant land, same Bernoulli path as ball mode)
- n=12, p=0.5 → μ=6, σ=√3≈1.732
- N ≈ 3000 balls
- Tolerance: mean ±0.2, stddev ±0.25

## Result

| Metric | Theoretical | Empirical (seed 999) | Pass |
|---|---|---|---|
| mean | 6.0 | ≈ within ±0.2 | ✅ `statistical_validation_test.dart` |
| stddev | √3 | ≈ within ±0.25 | ✅ |

**Note:** Exact per-ball trajectories are not compared (uncontrollable without shared RNG stream with PhET). Distribution properties are the acceptance criterion.
