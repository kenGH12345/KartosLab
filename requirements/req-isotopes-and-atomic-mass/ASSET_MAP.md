# ASSET_MAP — Isotopes and Atomic Mass

| Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Transform |
|---|---|---|---|---|---|---|---|
| `mipmaps/scale.png` | AtomScaleNode (Make) | `assets/simulations/isotopes_and_atomic_mass/images/scale.png` | width→275 | 0 | none | 1 | fitWidth |
| `mipmaps/isotopesIcon.png` | Screen / Home icon | `assets/simulations/isotopes_and_atomic_mass/images/isotopesIcon.png` | 1 | 0 | none | 1 | — |
| `mipmaps/mixturesIcon.png` | Mix screen (Phase 5) | `assets/simulations/isotopes_and_atomic_mass/images/mixturesIcon.png` | 1 | 0 | none | 1 | reserved |

## Programmatic (no raster)

| Element | Source | Flutter |
|---|---|---|
| Proton / Neutron | shred ParticleNode | `NucleonBallPainter` |
| Electron cloud | IsotopeElectronCloudView | `ElectronCloudPainter` (simplified radii — P1) |
| Neutron bucket | BucketHole / BucketFront | `NeutronBucketPainter` |
| Periodic table cells | ExpandedPeriodicTableNode | `ExpandedPeriodicTable` |
| Pie chart | TwoItemPieChartNode | `_PiePainter` |
| Reset All | scenery-phet ResetAllButton | `KratosResetAllButton` L0 |

**Substituted Assets: 0** (runtime rasters are original PhET mipmaps)
