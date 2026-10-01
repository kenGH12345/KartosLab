# ASSET_MAP — Molecule Polarity

| Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Transform | Notes |
|---|---|---|---|---|---|---|---|---|
| `images/realMoleculesScreenIcon.png` | Real Molecules tab icon | `assets/simulations/molecule_polarity/realMoleculesScreenIcon.png` | 1 | 0 | none | 1 | identity | Only PNG in sim |
| `assets/generated-data/all-molecules.json` | RealMoleculeData (atoms+mesh) | `assets/simulations/molecule_polarity/all_molecules.json` | n/a | n/a | none | n/a | originOffset per `RealMolecule.computeOriginOffset` | **Full mesh** vertices/normals/faces/ESP/density |
| (legacy slim) | — | `real_molecules_slim.json` | — | — | — | — | — | Superseded by all_molecules; may remain unused |

## Substituted Assets

**0** visual substitutes. Surface mesh is original JSON geometry rendered via Canvas (no fake PNG/emoji/Material icons).

## Rendering note

PhET Real Molecules uses Three.js `SurfaceMesh` (WebGL). Flutter uses CustomPainter projection of the **same face/vertex data** with FrontSide cull + dual-pass alpha matching `moleculeSurfaceBack/FrontAlpha`.
