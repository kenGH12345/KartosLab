# PHASE2_INVENTORY

> Mechanics / Gravity / Vector — user-facing string migration snapshot.

## Summary

| Metric | Count (approx) |
|---|---:|
| Simulations in scope | 15 |
| Legacy `*Strings` bags rewritten to Chinese | 14 (+ MASB/Hooke's new bags) |
| Shared `loc.mechanics.*` keys added | ~40 |
| Accessibility (GFL) strings localized | ~35 |
| Hardcoded widget English patches | ~40 call sites |

## Per simulation (primary bag)

| Simulation | File | Type coverage | Status |
|---|---|---|---|
| forces-and-motion-basics | `forces_strings.dart` + screens | title/tab/control/dialog | LOCALIZED |
| collision-lab | `collision_lab_strings.dart` | title/tab/control/tooltip | LOCALIZED |
| vector-addition | `vector_addition_strings.dart` | title/tab/control/tooltip | LOCALIZED |
| projectile-motion | `pm_strings.dart` + panels | title/tab/control | LOCALIZED |
| pendulum-lab | `pl_strings.dart` | title/tab/control/legend | LOCALIZED |
| balancing-act | `ba_strings.dart` + game | title/tab/dialog/status | LOCALIZED |
| friction | `friction_strings.dart` | title | LOCALIZED |
| hookes-law | `hookes_law_strings.dart` + panels | title/control/legend | LOCALIZED |
| masses-and-springs-basics | `masb_strings.dart` + panels | title/control/tooltip | LOCALIZED |
| energy-skate-park | `esp_strings.dart` (already ZH) | title/tab/control | LOCALIZED |
| gravity-force-lab | `gfl_strings.dart` + a11y | title/control/a11y | LOCALIZED |
| gravity-force-lab-basics | `gflb_strings.dart` | title/control | LOCALIZED |
| gravity-and-orbits | `gao_strings.dart` | title/tab/control | LOCALIZED |
| keplers-laws | `keplers_laws_strings.dart` | title/tab/control/status | LOCALIZED |
| my-solar-system | `my_solar_system_strings.dart` | title/tab/control | LOCALIZED |

## Classification notes

- Units (`kg`, `m`, `N`, `m/s²`, `AU`, `KE`/`PE` abbreviations) preserved.
- Asset paths / assert messages / ArgumentError text treated as developer-only.
- Keyboard chord literals (`Enter`, `WASD`, `J+C`) kept as technical input tokens beside Chinese descriptions.

## Sample rows

| Simulation | File | String (was EN) | Type | Key / bag field | Chinese | Status |
|---|---|---|---|---|---|---|
| collision-lab | collision_lab_strings | Mass | control | mass | 质量 | done |
| collision-lab | collision_lab_strings | Reset All tooltip | tooltip | — | 全部重置 | done |
| vector-addition | vector_addition_strings | Components | control | components | 分量 | done |
| projectile-motion | pm_strings | Initial Speed | control | initialSpeed | 初速率 | done |
| gravity-force-lab | gfl_a11y_strings | Increase mass (PDOM) | accessibility | changeMassLabel | 改变质量 | done |
| forces | forces_strings | Go! | control | netForceGo | 开始! | done |
| hookes-law | hookes_law_strings | Spring Constant | control | springConstant | 劲度系数 | done |

Full machine scan of remaining Latin words in PHASE 2 modules should be run via `test/localization/phase2_mechanics_localization_test.dart` + targeted `rg`.
