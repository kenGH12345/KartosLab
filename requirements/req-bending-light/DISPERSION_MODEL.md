# DISPERSION_MODEL.md

Source: `js/common/model/DispersionFunction.ts` + `doc/model.md`

## Equation

Substance characterized by reference index `n_ref` at `λ_ref = 650e-9 m`:

```
n_A(λ) = 1 + 5792105e-8/(238.0185 − (λ·1e6)^(−2))
           + 167917e-8/(57.362 − (λ·1e6)^(−2))

n_G(λ) = √(1 + B1 L²/(L²−C1) + B2 L²/(L²−C2) + B3 L²/(L²−C3))
  L²=λ²
  B1=1.03961212, B2=0.231792344, B3=1.01046945
  C1=6.00069867e-3·1e-12, C2=2.00179144e-2·1e-12, C3=1.03560653e2·1e-12

x = clamp( (n_ref − n_A(λ_ref)) / (n_G(λ_ref) − n_A(λ_ref)), 0, +∞ )
n(λ) = x·n_G(λ) + (1−x)·n_A(λ)
```

## Wavelength range

- Laser UI: 380–700 nm (stored as meters)
- White light samples: `range(400,700,10)` nm → meters

## Units

**Always meters** inside `DispersionFunction`. Converting nm↔m incorrectly breaks n (covered by unit-mix test).

## Color conversion (Phase 1 scope)

- Model stores `wavelengthToArgb` piecewise visible mapping for ray color **state**.
- Full PhET **XYZ / D65 / Bresenham white-light canvas** remains Phase 2/5 view work (`BendingLightConstants` XYZ tables not yet ported to Dart).

## Dart

`lib/bending_light/physics/dispersion_function.dart`
