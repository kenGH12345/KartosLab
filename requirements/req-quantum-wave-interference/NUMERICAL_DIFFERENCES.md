# NUMERICAL_DIFFERENCES — Phase 1

| Source | Difference | Magnitude | Cause | Acceptable? |
|---|---|---|---|---|
| HI/SP slit display geometry | Pixel `DISPLAY_SLIT_*` → approximate fraction of regionHeight | Visual scale | Phase 1 focuses on kernel math; full `getDisplaySlitLayout` port deferred | Yes for Phase 1; tighten in Phase 3–4 |
| Failed probe measurement projection | No persistent bite / renormScale advection | Functional gap for post-fail packet shape | Complexity; Bernoulli + success path covered | Phase 4 must complete |
| HI slit-detector decoherence event scheduling | Rate constant known; continuous event generator not fully wired in scene.step | Pattern under which-path may under-decohere in long runs | Time-box | Phase 3 |
| Experiment fullScreenHalfWidthM | Proxy `0.15 * L` vs Experiment zoom/scale tables | Hit x physical scale | Needs `DetectorScreenScale` port | Phase 2 |
| Floating point | Platform FP differences possible on digest | typically ulp | expected | Use tolerances for cross-device |

No silent clamps beyond PhET-documented behavior (invCDF clamp, max-normalize, rejection fallback to center).