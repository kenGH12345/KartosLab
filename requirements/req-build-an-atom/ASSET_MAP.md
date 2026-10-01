# Build an Atom — ASSET_MAP (Phase 5)

See also `ASSET_PROVENANCE_FINAL.md`.

| Original Path | Used By | Flutter Path | Scale / Notes |
|---|---|---|---|
| `images/scale.png` | Mass Number; BAASymbolNode; Level2 icon | `assets/build_an_atom/images/scale.png` | 351×189; BAASymbolNode `0.33` then outer `0.41` |
| `images/atomIcon.png` | catalog / future Home | `assets/build_an_atom/images/atomIcon.png` | Home QA still temp Material |
| `images/atomIconSmall.png` | navbar | `assets/build_an_atom/images/atomIconSmall.png` | inventory |
| `images/elementIcon.png` | Atom screen icon | `assets/build_an_atom/images/elementIcon.png` | inventory |
| `images/gameIcon.png` | Game screen icon | `assets/build_an_atom/images/gameIcon.png` | inventory |
| `images/periodicTableIcon.png` | Level 1 selection icon | `assets/build_an_atom/images/periodicTableIcon.png` | `GameLevelIcon` L1 |
| `images/massChargeIcon.png` | Level 2 related | `assets/build_an_atom/images/massChargeIcon.png` | inventory; L2 uses runtime ChargeMeter+scale |
| `images/symbolQuestionIcon.png` | Level 3 related | `assets/build_an_atom/images/symbolQuestionIcon.png` | inventory; L3 uses runtime Symbol box |
| `images/questionMarkIcon.png` | Level 4 related | `assets/build_an_atom/images/questionMarkIcon.png` | inventory; L4 uses runtime `?` box |
| shred ParticleNode geometry | Proton/Neutron/Electron | `ParticleSpherePainter` | radial highlight, no PNG |
| shred ElectronShellView | Shell rings | `_ShellRingsPainter` | dashed circles |
| shred ElectronCloudView | Cloud | RadialGradient circle | radius formula locked |
| scenery-phet BucketHole/Front | Buckets | `BaaBucketPainter` | code rebuild |
| shred PeriodicTableNode | PT accordion | `BaaPeriodicTable` | Z≤10 cells + symbol box |

**Substituted Assets (must justify):** 0 runtime particle/shell/cloud PNGs invented — all geometry from shred. Home QA card icon is temporary Material (remove in Phase 8).
