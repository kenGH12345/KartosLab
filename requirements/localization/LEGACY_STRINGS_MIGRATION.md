# LEGACY_STRINGS_MIGRATION

> PHASE 1 · Adapter strategy — **do not delete** legacy `*Strings` yet.

## Pattern

```
Legacy XxxStrings  →  LegacyStringsAdapter  →  KartosLocalization (loc.*)
```

Shared chrome fields should call `CommonLegacyStringsAdapter` or `loc.common` / `loc.shared` directly.

## Registry

| Legacy file | Consumers (approx) | Replacement namespace | Status |
|---|---|---|---|
| `lib/forces/config/forces_strings.dart` | forces screens | `common.*` + `physics.*` + forces domain | PARTIAL (already Chinese hardcode) |
| `lib/energy_skate_park/esp_strings.dart` | ESP | `sim.energy-skate-park.*` + physics | PARTIAL |
| `lib/density/density_strings.dart` | density | `physics.*` + `fluids.*` | LOCALIZED (PHASE 3) |
| `lib/buoyancy/buoyancy_strings.dart` | buoyancy | `fluids.*` | LOCALIZED (PHASE 3) |
| `lib/under_pressure/under_pressure_strings.dart` | under-pressure | `fluids.*` | LOCALIZED (PHASE 3) |
| `lib/gases_intro/gases_intro_strings.dart` | gases-intro | `fluids.*` | LOCALIZED (PHASE 3) |
| `lib/gas_properties/gas_properties_strings.dart` | gas-properties | `fluids.*` | LOCALIZED (PHASE 3) |
| `lib/diffusion/diffusion_strings.dart` | diffusion | `fluids.*` | LOCALIZED (PHASE 3) |
| `lib/membrane_transport/membrane_transport_strings.dart` | membrane-transport | `fluids.*` | LOCALIZED (PHASE 3) |
| `lib/collision_lab/collision_lab_strings.dart` | collision-lab | `mechanics.*` | NOT STARTED |
| `lib/vector_addition/vector_addition_strings.dart` | vector-addition | `mechanics.*` | NOT STARTED |
| `lib/projectile_motion/pm_strings.dart` | projectile | `mechanics.*` | NOT STARTED |
| `lib/pendulum_lab/pl_strings.dart` | pendulum | `mechanics.*` | NOT STARTED |
| `lib/balancing_act/ba_strings.dart` | balancing-act | `mechanics.*` | NOT STARTED |
| `lib/friction/friction_strings.dart` | friction | `physics.friction*` | NOT STARTED |
| `lib/gravity_force_lab/gfl_strings.dart` | GFL | `physics.gravityForce` | NOT STARTED |
| `lib/gravity_force_lab/a11y/gfl_a11y_strings.dart` | GFL a11y | `accessibility.*` | NOT STARTED |
| `lib/gravity_force_lab_basics/gflb_strings.dart` | GFLB | `physics.gravityForce` | NOT STARTED |
| `lib/astronomy/gravity_and_orbits/gao_strings.dart` | GAO | astronomy domain | NOT STARTED |
| `lib/astronomy/keplers_laws/keplers_laws_strings.dart` | Kepler | astronomy domain | NOT STARTED |
| `lib/astronomy/my_solar_system/my_solar_system_strings.dart` | MSS | astronomy domain | NOT STARTED |
| `lib/charges_and_fields/caf_strings.dart` | CAF | electricity | NOT STARTED |
| `lib/capacitor_lab_basics/clb_strings.dart` | CLB | electricity | NOT STARTED |
| `lib/cck_ac_virtual_lab/cck_strings.dart` | CCK | electricity | NOT STARTED |
| `lib/energy_forms_and_changes/efac_strings.dart` | EFAC | energy domain | NOT STARTED |
| `lib/blackbody_spectrum/blackbody_spectrum_strings.dart` | blackbody | heat | NOT STARTED |
| `lib/normal_modes/normal_modes_strings.dart` | normal-modes | waves | NOT STARTED |
| `lib/fourier_making_waves/fmw_strings.dart` | fourier | waves | NOT STARTED |
| `lib/plinko_probability/plinko_strings.dart` | plinko | math | NOT STARTED |
| `lib/curve_fitting/curve_fitting_strings.dart` | curve-fitting | math | NOT STARTED |
| `lib/rutherford_scattering/rs_strings.dart` | RS | chemistry/nucleus | NOT STARTED |
| `lib/chemistry/molecule_polarity/mp_strings.dart` | polarity | chemistry | NOT STARTED |
| `lib/molecule_shapes/molecule_shapes_strings.dart` | shapes | chemistry | NOT STARTED |
| `lib/chemistry/states_of_matter/som_strings.dart` | SOM | chemistry | NOT STARTED |
| `lib/chemistry/build_a_molecule/data/bam_strings.dart` | BAM | chemistry | NOT STARTED |
| `lib/balancing_chemical_equations/bce_strings.dart` | BCE | chemistry | NOT STARTED |
| `lib/reactants_products_and_leftovers/rpal_strings.dart` | RPAL | chemistry | NOT STARTED |
| `lib/quantum_coin_toss/common/quantum_measurement_strings.dart` | QM / coin | quantum | NOT STARTED |

## Adapter entry points

- `lib/l10n/legacy/legacy_strings_adapter.dart`
- `lib/l10n/legacy/migration_status.dart`
- `resources/localization/migration_status.json`

## Rules

1. Never delete a `*Strings` file in the same PR that only adds adapters.
2. Prefer redirecting `resetAll` / play-pause to `loc.common` first (highest reuse).
3. When a sim reaches LOCALIZED, mark status and then remove the bag in a dedicated PR.
