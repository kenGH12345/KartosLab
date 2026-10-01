# PHASE 4 — Final Visual Matrix

Method: source map + Phase 2/3 visual QA + Phase 4 behavioral regression. Device screenshot pixel-diff = NOT RUN（Android NOT VERIFIED）. Classifications from code + automated invariants.

Severity per cell: **P0** crash/missing · **P1** teaching/layout wrong · **P2** minor chrome · **VERSION_DELTA** known acceptable fidelity gap.

## Model Screen

| Scene | P0 | P1 | P2 | VERSION_DELTA | Verdict |
|---|---|---|---|---|---|
| Initial (2 single bonds) | — | — | — | — | PASS |
| 1 / 2 / 3 bonds | — | — | — | — | PASS |
| Double bond (2 visual lines, 1 domain) | — | — | — | — | PASS |
| Triple bond (3 visual lines, 1 domain) | — | — | — | — | PASS |
| 1 / multiple lone pairs | — | — | — | shell stroke approx | PASS |
| Geometry Name visible | — | — | — | text labels only (source) | PASS |
| Bond angles visible | — | — | minor arc alpha | — | PASS |
| Rotated | — | — | — | — | PASS |
| Dragged atom | — | — | — | — | PASS |
| Options / Remove All / Reset | — | — | — | — | PASS |
| Panel layout (Bonding / Options / Name / Reset) | — | — | spacing chrome | — | PASS |
| Bonding thumbnails | — | — | — | 2D CustomPaint ≠ WebGL capture | PASS |
| Depth / occlusion | — | — | — | CustomPainter sort | PASS |
| Atom size / bond thickness | — | — | shading | — | PASS |

## Real Molecules Screen

| Scene | P0 | P1 | P2 | VERSION_DELTA | Verdict |
|---|---|---|---|---|---|
| Initial H₂O Real | — | — | — | — | PASS |
| H₂O Model 109.5° | — | — | — | — | PASS |
| H₂O Real↔Model↔Real | — | — | — | orientation jump (no Attractor match) | PASS |
| Linear (CO₂ / XeF₂) | — | — | — | — | PASS |
| Bent (H₂O / SO₂) | — | — | — | — | PASS |
| Tetrahedral (CH₄) | — | — | — | — | PASS |
| Multi-domain (PCl₅ / SF₆ / BrF₅) | — | — | — | — | PASS |
| All 13 TAB_2 molecules | — | — | — | — | PASS |
| Rotation | — | — | — | — | PASS |
| Options (LP / angles / outer LP) | — | — | — | — | PASS |
| Name panel labels | — | — | — | — | PASS |
| Reset → H₂O Real | — | — | — | — | PASS |
| Formula subscripts (H₂O ≠ H2O) | — | — | baseline micro | — | PASS |
| CPK element colors (H C N O F Cl P S Br Xe B Be) | — | — | — | nitroglycerin map | PASS |
| Perspective / depth / bond endpoints | — | — | — | — | PASS |

## Cross-screen visual isolation

| Check | Verdict |
|---|---|
| Separate layouts (Bonding vs Molecule ComboBox) | PASS |
| Shared painter projection params | PASS |
| No accidental Material icons for molecule graphics | PASS |
| `KratosResetAllButton` both screens | PASS |

## Labels

- `[布局已对齐]` Model: Bonding+LonePair+RemoveAll / Options / Name / Reset · Real: Molecule+Options / Real|Model / Name / Reset
- `[动态绘制已对齐]` shared camera FOV 50°, position (6,-1.25,40), depth-sorted atoms/bonds/LPs
- `[原版资源一致]` CPK from source element map; subscripts via ChemUtils-style; Substituted = 0
- `[VERSION_DELTA]` lone-pair balloon mesh; bonding thumbnails; Real↔Model orientation continuity; bond A/B half colors

## Overall

```text
Model Screen Visual: PASS (P2 VERSION_DELTA only)
Real Molecules Visual: PASS (P2 VERSION_DELTA only)
PHASE 4 Final Visual: PASS
P0 = 0
P1 = 0
```
