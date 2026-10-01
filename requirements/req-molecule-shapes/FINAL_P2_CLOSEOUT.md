# FINAL P2 Close-out

Source audit + view-only fixes. No VSEPR / real-data / Home redesign.

| P2 | Source | Previous | Final | Status |
|---|---|---|---|---|
| Lone Pair Shell | `LonePairView` + `LonePairGeometryData` / `balloon2-low-res.obj` | stroke approximate | Balloon mesh from original OBJ (`lone_pair_geometry_data.dart`), scale 2.5, electrons at (±0.75, 5) | **CLOSED** |
| Bonding Thumbnail | `BondGroupNode.getBondDataURL` (three.js snapshot) | flat 2D lines | Shared `MoleculePainter` + front camera (same renderer as scene; no new 3D stack) | **CLOSED** |
| Real/Model Orientation | `RealMoleculesModel.rebuildMolecule(false)` + Attractor SVD | no match | `rebuildRealMoleculesView` with `findClosestMatchingConfiguration` / `getIdealGroupRotationToPositions` | **CLOSED** |
| Bond Half Color | `BondView` a/b halves use **same** `bondProperty` (not atom CPK) | “unsplit” misread as missing CPK halves | Two half-segments, both `MoleculeShapesColors.bond` — source-equivalent | **CLOSED** (source does **not** require adjacent-atom half colors) |

## Negligible VERSION_DELTA (not blocking READY)

1. Balloon shading: flat translucent fill vs three.js `MeshLambertMaterial` lighting.
2. Thumbnail camera: perspective FOV 28° vs exact orthographic WebGL snapshot.

Neither affects teaching semantics, angles, or molecule data.

## Assets

| Asset | Path | Notes |
|---|---|---|
| Balloon low-res OBJ | PhET `assets/balloon2-low-res.obj` → Dart vertices/tris | Original geometry port |
| Substituted | **0** | No third-party icons/meshes |

## Regression

```text
flutter test test/molecule_shapes/
→ 66 PASS

dart analyze lib/molecule_shapes test/molecule_shapes
→ No issues found
```

H₂O Real 104.5° / Model 109.5° preserved through Attractor remap.
