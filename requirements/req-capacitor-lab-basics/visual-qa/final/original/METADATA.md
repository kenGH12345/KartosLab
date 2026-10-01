# Official PhET screenshot metadata

URL: https://phet.colorado.edu/sims/html/capacitor-lab-basics/latest/capacitor-lab-basics_all.html
Capture method: Cursor browser + PhET model API (`phet.joist.sim` / `phet.capacitorLabBasics`)
Query: `?initialScreen=1|2&locale=en`

## Viewport (all 9)

| Field | Value |
|-------|-------|
| viewport | 580 × 421 CSS px |
| DPR | 1.5 |
| device resolution | ~870 × 632 device px (580×1.5 × 421×1.5) |
| design resolution | 1024 × 618 (PhET layoutBounds) |
| note | Browser panel constrained; sim scales to fit. TimeControl/Stopwatch may be partially cropped at this viewport — see FINAL_VISUAL_QA.md |

## Files

| State | Path |
|-------|------|
| Capacitance_Default | `01_Capacitance_Default.png` |
| Capacitance_Modified | `02_Capacitance_Modified.png` |
| Capacitance_Voltmeter | `03_Capacitance_Voltmeter.png` |
| Capacitance_InvalidProbe | `04_Capacitance_InvalidProbe.png` |
| LightBulb_Charging | `05_LightBulb_Charging.png` |
| LightBulb_Discharging | `06_LightBulb_Discharging.png` |
| LightBulb_Paused | `07_LightBulb_Paused.png` |
| LightBulb_Voltmeter | `08_LightBulb_Voltmeter.png` |
| Reset_State | `09_Reset_State.png` |

## State notes

- **Paused**: published model surface did not expose `isPlayingProperty`/`stopwatch` via enumerable keys; Pause button chrome not confirmed in capture → treat TimeControl Pause affordance as `[待确认]` even if circuit is bulb-connected.
- **Reset_State**: captured on Light Bulb tab after `model.reset()` (V=0, VM in toolbox, default geometry).
