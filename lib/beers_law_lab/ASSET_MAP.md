# Beer's Law Lab — ASSET MAP (Phase 2)

| Asset | Original Path | Used By | Flutter Path | Screen | Notes |
|-------|---------------|---------|--------------|--------|-------|
| concentrationScreenIcon.jpg | images/concentrationScreenIcon.jpg | ConcentrationScreen home icon | (existing concentration assets) | Concentration | Runtime |
| beersLawScreenIcon.jpg | images/beersLawScreenIcon.jpg | BeersLaw screen icon (tab/screen) | deferred — Home card uses concentrationScreenIcon (product entry) | Beer's Law | Runtime |
| concentrationScreenIcon.jpg | images/concentrationScreenIcon.jpg | Home product card icon for Beer's Law Lab | assets/simulations/concentration/images/concentrationScreenIcon.jpg | Concentration / Home | Runtime |
| shaker.png | images/shaker.png | ShakerNode | lib/concentration assets | Concentration | Runtime |
| shakerIcon.png | images/shakerIcon.png | SoluteForm radio | lib/concentration assets | Concentration | Runtime |
| dropperIcon.png | images/dropperIcon.png | SoluteForm radio | lib/concentration assets | Concentration | Runtime |
| README screenshots | assets/*.png | docs only | NOT USED | — | Not runtime |

## Programmatic (no image asset)

| Element | Source class | Flutter |
|---------|--------------|---------|
| Light | LightNode / LaserPointerNode | beers_law_light_node.dart CustomPainter |
| Beam | BeamNode | beers_law_beam_node.dart CustomPainter |
| Cuvette | CuvetteNode | beers_law_cuvette_node.dart |
| Detector | DetectorNode / ProbeNode | beers_law_detector_node.dart |
| Ruler | BLLRulerNode / RulerNode | beers_law_ruler_node.dart |
| Faucets / beaker / meter / particles | Concentration views | existing lib/concentration/ |

## Substituted Assets

**0** — no Material icons substituted for PhET runtime assets.
