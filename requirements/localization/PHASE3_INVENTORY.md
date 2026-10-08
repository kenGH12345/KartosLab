# PHASE3_INVENTORY — Fluids / Density / Buoyancy / Gases

> User-facing string migration snapshot (PHASE 3).

## Summary

| Metric | Count (approx) |
|---|---:|
| Simulations in scope | 7 |
| Legacy / new `*Strings` bags | 7 |
| Shared `loc.fluids.*` keys | ~70 |
| Hardcoded widget English patches | ~80 call sites |
| Accessibility a11y keys (fluids.*) | 4 (+ bag tooltips) |

## Per simulation

| Simulation | File | Existing Source | Type coverage | Status |
|---|---|---|---|---|
| density | `density_strings.dart` | bag + widgets | title/tab/control/material/a11y | LOCALIZED |
| buoyancy | `buoyancy_strings.dart` + panels/screens | hardcode → bag | title/tab/control/legend | LOCALIZED |
| under-pressure | `under_pressure_strings.dart` + controls | hardcode → bag | title/control/radio | LOCALIZED |
| gases-intro | `gases_intro_strings.dart` + shell | hardcode → bag | title/tab/control/dialog | LOCALIZED |
| gas-properties | `gas_properties_strings.dart` + shells | hardcode → bag | title/tab/control/dialog/a11y | LOCALIZED |
| diffusion | `diffusion_strings.dart` + shell | hardcode → bag | title/control | LOCALIZED |
| membrane-transport | `membrane_transport_strings.dart` + screens | hardcode → bag | title/control/panel | LOCALIZED |

## Sample rows

| Simulation | File | String | Existing Source | User Visible | A11y | Localization Key | Chinese | Status |
|---|---|---|---|---|---|---|---|---|
| density | density_strings | Density | bag | Y | | physics.density / title | 密度 | done |
| density | density_strings | Wood | materialName | Y | | fluids.material.wood | 木材 | done |
| buoyancy | forces_panel | Forces / Gravity / Buoyancy | hardcode | Y | | bag | 力 / 重力 / 浮力 | done |
| buoyancy | sim_host | compare/explore tabs | enum.name | Y | | bag tabs | 比较/探索… | done |
| under-pressure | tools panel | Atmosphere On/Off | hardcode | Y | | bag | 大气 / 开 / 关 | done |
| gas-properties | ideal controls | Hold Constant | hardcode | Y | | fluids.holdConstant | 保持恒定 | done |
| gas-properties | oops | Temperature cannot… | hardcode | Y | dialog | bag | 容器为空时… | done |
| diffusion | shell | Remove Divider | hardcode | Y | | bag | 移除隔板 | done |
| membrane | simple screen | Solutes / Outside | hardcode | Y | | bag | 溶质 / 外侧 | done |
| fluids | fluids_l10n | Increase Pressure | new | | Y | fluids.a11y.* | 增大压强 | done |

## Classification notes

- Units (`kg`, `L`, `kg/L`, `kg/m³`, `Pa`, `atm`, `K`, `AMU`, `pm`, `mV`, chemical formulas) preserved.
- Archaeology / About body PhET URLs kept (LOCALIZATION_EXCEPTIONS).
- Automation keys (`buoyancy_tab_${s.name}`) unchanged — only display label localized.
