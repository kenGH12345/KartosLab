# PHASE4_INVENTORY — Electricity / Circuits / EM

## Summary

| Metric | Count (approx) |
|---|---:|
| Simulations in scope | 9 |
| String bags rewritten / created | 9 |
| `loc.electricity.*` keys | ~45 |
| Hardcoded UI patches | ~50 call sites |

## Per simulation

| Simulation | File | Type coverage | Status |
|---|---|---|---|
| ohms-law | `ohms_law_strings.dart` + controls | title/control/a11y/units | LOCALIZED |
| resistance-in-a-wire | `riaw_strings.dart` + panel | title/control/a11y/readout | LOCALIZED |
| cck-ac-virtual-lab | `cck_strings.dart` + panels | palette/control/dialog | LOCALIZED |
| capacitor-lab-basics | `clb_strings.dart` | title/tab/control | LOCALIZED |
| charges-and-fields | `caf_strings.dart` | title/control/legend | LOCALIZED |
| faradays-law | `faradays_law_strings.dart` | title/control/a11y | LOCALIZED |
| john-travoltage | `jt_strings.dart` | title | LOCALIZED |
| balloons-and-static-electricity | `base_strings.dart` | title/control/a11y | LOCALIZED |
| magnet-and-compass | `mac_strings.dart` + panel | title/control | LOCALIZED |

## Sample rows

| Simulation | File | String | Type | User Visible | A11y | Existing Key | Proposed Key | Chinese | Status |
|---|---|---|---|---|---|---|---|---|---|
| ohms-law | control_panel | Voltage | control | Y | Y | physics.voltage | bag | 电压 | done |
| ohms-law | wire_box | current | readout | Y | Y | physics.current | bag | 电流 | done |
| riaw | control_panel | resistivity | control | Y | Y | electricity.resistivity | bag | 电阻率 | done |
| cck | cck_strings | Resistor | control | Y | | electricity.resistor | bag | 电阻器 | done |
| clb | clb_strings | Capacitance | tab | Y | | electricity.capacitance | bag | 电容 | done |
| caf | caf_strings | Electric Field | control | Y | | physics.electricField | bag | 电场 | done |
| faradays | control_panel | Field Lines | control | Y | | electricity.fieldLines | bag | 磁场线 | done |
| BASE | control_panel | Show all charges | control | Y | | — | bag | 显示全部电荷 | done |
| magnet | control_panel | Flip Polarity | control | Y | | electricity.flipPolarity | bag | 翻转极性 | done |

## Preserved

- Units: V, A, mA, Ω, Ωcm, cm, cm², nC, V/m, deg, pF, pC, pJ, Hz, N/S poles
- Formulas: R = ρL/A, V=IR (symbol glyphs)
- Automation keys unchanged
