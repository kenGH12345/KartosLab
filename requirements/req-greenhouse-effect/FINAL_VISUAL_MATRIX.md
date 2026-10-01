# FINAL_VISUAL_MATRIX · Greenhouse Effect

> Date: 2026-09-21 · P2 close-out · source `@ 6c84ad0f`

| Screen | State | Arrow | Thermometer | Screen Shell | Status |
|---|---|---|---|---|---|
| Waves | Initial | Energy balance hidden; no flux on Waves | Surface `ThermometerNode` (bulb 40, tube 150×20) + formatted readout | Selector bar, Waves underlined | PASS |
| Waves | Playing | TOA In/Out/Net vertical ArrowShape when balance on | Same surface thermometer, fill from Kelvin | Same shell | PASS |
| Photons | Initial | Flux meter off | Surface thermometer | Photons selected | PASS |
| Photons | Playing | Sunlight and Infrared wells, up/down ArrowNode 16/16/8 | Surface thermometer | Same shell | PASS |
| Layer Model | Initial | Flux + energy balance available | Smaller surface thermometer (bulb 25, tube 80×14) | Layer Model selected | PASS |
| Layer Model | 1 layer | Unchanged flux geometry | Layer readout stays numeric (`NumberDisplay` in source) | Same | PASS |
| Layer Model | 3 layers | Unchanged | Three numeric layer labels | Same | PASS |
| Layer Model | thermometer | N/A | Surface thermometer uses Layer Model geometry | Same | PASS |

Arrow geometry is scenery-phet `ArrowShape` (shaft + head), not a line plus a triangle.

Layer atmosphere nodes in source are number readouts, not thermometer bodies.
