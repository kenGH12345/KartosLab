# BLOCH_MEASUREMENT_SPEC_PHASE6

## Flow

```
User Observe/Start
  → BlochSphereModel.initiateObservation()
  → (B off) _observe() OR (B on) TIMING_OBSERVATION + step until delay
  → ComplexBlochSphere.measure(axis, rng)  // P via (2U-1)<n̂·r̂
  → collapse to ± eigenstate
  → measurementState = OBSERVED
  → View reads new (θ,φ) → projection → tip
```

## Rules

- View **must not** call `Random()` for outcomes.
- Repeated Observe after Reprepare uses preparation state; second Observe without Reprepare blocked until Reprepare (button switches).
- ×10 mode measures all 10 spheres independently with same axis.

## Visual sync

Post-measure: Model angles == projected tip == painted arrow. No delayed visual state.

## Determinism

Same seed + same prep state + same axis → same outcome + same collapsed tip.
