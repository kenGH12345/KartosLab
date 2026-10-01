# VIEWPORT_REPORT · Molecules and Light

Source: `js/micro/view/MicroScreenView.js`

| Item | Value |
|---|---|
| layoutBounds | `Bounds2(0, 0, 768, 504)` |
| Screen background | `#C5D6E8` |
| Intermediate rendering size | 500 × 300 |
| MVT | `createSinglePointScaleInvertedYMapping` |
| Model origin (0,0) maps to view | `(round(500*0.55), round(300*0.50))` = `(275, 150)` in intermediate space |
| Scale | `0.10` view units per picometer |
| Y axis | inverted |
| Observation window position | `(15, 15)` |
| Frame corner radius | 7 |
| Frame line width | 5 |
| Photon emission (model) | `(-1350, 0)` pm, velocity `3000` pm/s to the right |
| Absorption query distance | 100 pm from molecule center of gravity |
| Model unit | picometers |

Model code must not read `MediaQuery` or view pixels. View (later phases) applies this transform.
