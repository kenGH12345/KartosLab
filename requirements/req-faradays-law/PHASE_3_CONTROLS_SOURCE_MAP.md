# PHASE 3 — CONTROLS SOURCE MAP · Faraday's Law

| PhET control | Flutter | Model property | Handler |
|--------------|---------|----------------|---------|
| `Checkbox` Voltmeter | `FlLabeledCheckbox` | `voltmeterVisible` | `setVoltmeterVisible` |
| `Checkbox` Field Lines | `FlLabeledCheckbox` | `magnet.fieldLinesVisible` | `setFieldLinesVisible` |
| `RectangularRadioButtonGroup` single | `CoilRadioGroup` single | `topCoilVisible=false` | `setTopCoilVisible(false)` |
| `RectangularRadioButtonGroup` double | `CoilRadioGroup` double | `topCoilVisible=true` | `setTopCoilVisible(true)` |
| `FlipMagnetButton` | `FlipMagnetButton` | `magnet.orientation` | `flipPolarity()` |
| `ResetAllButton` scale 0.75 | `KratosResetAllButton` r=20.5×0.75 | full model | `reset()` |

## Layout (ControlPanelNode.js)

| Item | Source | Flutter |
|------|--------|---------|
| Strip bottom | `bounds.maxY - 10` | y bottom margin 10 in 504 |
| Checkbox x | 174 | `left: 174` |
| Voltmeter centerY | coilCenter − 20 | approx |
| Field Lines centerY | coilCenter + 20 | approx |
| Coil radios left | 377 | `left: 377` |
| Flip right | maxX − 110 | `right: 110` |
| Reset right | maxX − 10 | `right: 10` |
| Coil radio baseColor | `#cdd5f6` | same |
| Flip baseColor | `rgb(205,254,195)` | same |
| Labels | "Voltmeter" / "Field Lines" | same (en strings) |

## Defaults

| Control | Default |
|---------|---------|
| Voltmeter | OFF |
| Field Lines | OFF |
| Circuit mode | 1 coil (`topCoilVisible=false`) |
| Polarity | NS |
| Magnet arrows | ON |
