# ASSET_MAP · States of Matter

> Substituted Assets target: **0**  
> Source version: 1.3.0-dev.3  
> Updated: 2026-09-16

| Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Transform notes |
|---|---|---|---|---|---|---|---|
| `images/pushPin.png` | AtomicInteractionsScreen | `assets/states_of_matter/images/pushPin.png` | width→20 | 0 | none | 1.0 | right/bottom = atom − 0.5×radius |
| `scenery-phet/images/hand.png` | AtomicInteractionsScreen HandNode | `assets/states_of_matter/images/hand.png` | width→80 | 0 | none | 1.0 | left=atomX, top=atomY; hint until first drag |
| `mipmaps/pointingHand.png` | PointingHandLidControl | `assets/states_of_matter/mipmaps/pointingHand.png` | width→150 | 0 | none | 1.0 | fingertip on lid; centerX = area.centerX+30 |
| `mipmaps/solidIcon.png` | StatesPhaseControl | `assets/states_of_matter/mipmaps/solidIcon.png` | 1.0 | 0 | none | 1.0 | Phase button |
| `mipmaps/liquidIcon.png` | StatesPhaseControl | `assets/states_of_matter/mipmaps/liquidIcon.png` | 1.0 | 0 | none | 1.0 | Phase button |
| `mipmaps/gasIcon.png` | StatesPhaseControl | `assets/states_of_matter/mipmaps/gasIcon.png` | 1.0 | 0 | none | 1.0 | Phase button |
| Particle sprites | ParticleImageCanvasNode | **Runtime Canvas** (`paintShadedSphere`) | MVT | 0 | none | 1.0 | Not a static PNG in PhET |
| Container / lid | ParticleContainerNode Path | CustomPainter | MVT | 0 | none | 1.0 | Geometry rebuild |
| Thermometer | CompositeThermometerNode | CustomPainter | layout | 0 | none | 1.0 | Geometry rebuild |
| Dial gauge | DialGaugeNode | CustomPainter | layout | 0 | none | 1.0 | Geometry rebuild |
| Heater/Cooler | HeaterCoolerNode | `heater_cooler_control.dart` (+ flame/ice assets) | ~0.79 | RotatedBox | none | 1.0 | Match Gases Intro; track colors UX-swapped |
| Bicycle pump | BicyclePumpNode | `bicycle_pump_button.dart` painter | ~100×130 | 0 | none | 1.0 | Red barrel + ticks; inject on drag |
| Phase/potential diagrams | Scenery Path | `LjPotentialGraphPainter` / `PhaseDiagramPainter` + `SomGraphAxes` | — | 0 | none | 1.0 | Shared L-arrow axis chrome |
| ResetAllButton | All SoM screens | L0 `KratosResetAllButton` via `SomResetButton` | r=20.5 | 0 | none | 1.0 | `#F79722` · ResetShape · no Material icons |

## Substituted Assets

**Count: 0** (no Material Icons / emoji / third-party images used as PhET stand-ins for listed originals).

## pubspec

```yaml
- assets/states_of_matter/mipmaps/
- assets/states_of_matter/images/
```
