# visual-qa/ASSET_MAPPING.md

| PhET | Flutter | 状态 |
|---|---|---|
| collectionMoleculesData.ts | assets/data/build_a_molecule/collection_molecules.json | `[数据一致]` |
| otherMoleculesData.ts | …/other_molecules.json | `[数据一致]` |
| structuresData.ts | …/structures.json | `[数据一致]` |
| build-a-molecule-strings_en.json | …/strings_en.json | `[数据一致]` |
| images/scissors*.png | assets/images/build_a_molecule/ | `[数据一致]` 已复制 |
| images/splitBlue.png | 同上 | `[数据一致]`（UI 未用） |
| assets/*screenshot*.png | visual-qa/ref/ | 基线参考 |
| nitroglycerin Element 色/半径 | BamElement + _ref_Element.ts | `[数据一致]`（外部依赖取证） |
| three-r104 / mobius meshes | — | `[有意差异]` Canvas 替代 |
| nitroglycerin *Node 伪3D图标 | Canvas 圆球 | `[视觉近似]` |
