# ASSET INVENTORY — Friction

| Asset | PhET source | Flutter | Notes |
|-------|-------------|---------|-------|
| Chemistry / Physics book | `CoverNode.js` Path geometry | `book_cover_painter.dart` | No PNG; procedural |
| Magnifier frame | `MagnifierNode.js` Rectangle | `magnifier_node.dart` | ROUND=30, stroke=5 |
| Magnifier target + dashes | `MagnifierTargetNode.js` | `magnifier_target_painter.dart` | |
| Atoms | `ShadedSphereNode` → Canvas | `atoms_painter.dart` | cyan / green |
| Thermometer | scenery-phet `ThermometerNode` | `friction_thermometer.dart` | fluid rgb(237,28,36) |
| Cue arrows | `CueArrow` / ArrowNode | `cue_arrow_painter.dart` | white L/R in magnifier |
| Reset All | scenery-phet ResetAllButton | `KratosResetAllButton` L0 | radius 22 |
| simplePickup.mp3 | sounds/ | assets/simulations/friction/sounds/ | macro grab |
| simpleDrop.mp3 | sounds/ | same | macro release |
| harpPickup.mp3 | sounds/ | same | magnifier grab |
| harpDrop.mp3 | sounds/ | same | magnifier release |
| contactLower.mp3 | sounds/ | same | contact |
| breakOffAutosinfonieSpatialized.mp3 | sounds/ | same | shear (every 4th) |
| Rub / molecule / cooling noise | Tambo NoiseGenerator | P2 procedural stub | pink-noise not ported |

**Substituted Assets: 0** (no image substitutions; geometry + original mp3s)
