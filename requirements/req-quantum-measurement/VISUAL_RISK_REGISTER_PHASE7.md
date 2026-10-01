# VISUAL_RISK_REGISTER_PHASE7

| Item | Severity | Evidence | Current status |
| --- | --- | --- | --- |
| Root scale | P0 if diverges | `global_scale_geometry_test` four composers | PASS |
| Global frame | P0 | 1024×618 centered | PASS |
| Typography | P1 residual | not every TextStyle migrated | PARTIAL — primitives + key titles PASS |
| Button chrome | P1 | ChoiceChip still Material | PARTIAL |
| SVG rendering | P1 | flutter_svg vs Scenery | Coins SVG in use; watch crop |
| PNG scaling | P0 | photon 50→10 | PASS formula |
| 10k canvas | P0 | 100×100 sampleGridColors | PASS geometry; Golden raster |
| Photon trajectory | P1 | MVT 640 Y-inv | PHASE 4 tests; Golden default static |
| Spin apparatus | P1 | shared SG | Exp 1–6 goldens |
| Bloch projection | P0 | ±X±Y±Z geometry tests | PASS |
| Measurement area | P1 | CONTENT_DRIVEN Observe XY | relations HIGH |
| Z-order | P1 | audit table | PASS |
| Golden determinism | P0 | seed + ×3 transform | PASS geometry; raster ×3 on canonical coins |
| Responsive viewport | P1 | 1280 / 800 goldens | PASS tests |
| Platform raster G9 | P2 | font AA | documented |
