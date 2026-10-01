# DATA_MAPPING · PhET → Flutter

## 1. Molecule catalog

| PhET | Flutter | 注 |
|---|---|---|
| `CompleteMolecule` | `BamCompleteMolecule` | 含 commonName/formula/cid/atoms/bonds/2d/3d |
| `PubChemAtom` | `BamCatalogAtom` | element + x2d/y2d/x3d/y3d/z3d |
| `PubChemBond` | `BamCatalogBond` | a,b + order |
| `MoleculeStructure` | `BamMoleculeStructure` | play/catalog 共用拓扑 API |
| `Bond` (play) | `BamBond` | 无 order |
| `Atom` / `Atom2` | `BamAtom` | element + position/destination + dragging |
| `StrippedMolecule` | `BamStrippedMolecule` | H-stripped 匹配 |
| `ElementHistogram` | `BamElementHistogram` | hash + equals |
| `MoleculeList` | `BamMoleculeCatalog` | load JSON；`isAllowed` / `findMatch` |
| `COMMON_MOLECULES` | `BamCommonMolecules` | 按名查找缓存 |
| `COLLECTION_BOX_MOLECULES` | `BamCollectionPool` | next-collection 随机池 |

## 2. Structure serial

| PhET serial2 | Flutter |
|---|---|
| CompleteMolecule line | `BamSerialParser.parseComplete(line)` |
| structures line | `BamSerialParser.parseStructure(line)` |
| `collectionMoleculesData` array | `assets/data/build_a_molecule/collection_molecules.json` |
| `otherMoleculesData` | `…/other_molecules.json` |
| `structuresData` | `…/structures.json` |

## 3. Collection / Kit

| PhET | Flutter |
|---|---|
| `CollectionBox` | `BamCollectionBox` |
| `KitCollection` | `BamKitCollection` |
| `Kit` | `BamKit` |
| `BAMBucket` | `BamBucket` |
| `BAMModel` | `BamScreenModel`（+ Single/Multiple/Playground 子类配置） |
| `CollectionLayout` | `BamCollectionLayout`（play bounds） |
| `LewisDotModel` | `BamLewisDotModel` |
| `Direction` | `BamDirection` enum |

## 4. Challenge / Game

| PhET | Flutter |
|---|---|
| 无 Game challenge | **N/A** — 不实现虚假关卡 |
| `GameAudioPlayer.correctAnswer` | 可选 `audioplayers` 短音 / no-op |
| Next Collection 随机 | `BamRandom` 封装（可注入 seed 测） |

## 5. Render / View

| PhET | Flutter |
|---|---|
| `AtomNode` | `BamAtomPainter` / widget |
| `MoleculeBondNode` | bond painter（play 区单线；3D ball-stick 双圆柱近似） |
| `KitPlayAreaNode` | play `CustomPaint` + 局部坐标 |
| `CollectionBoxNode` / Single/Multiple | collection panel widgets |
| `Molecule3DDialog` | `BamMolecule3dDialog`（Canvas） |
| `Molecule3DNode` | `BamMolecule3dPainter` |
| `WarningDialog` | 可选；默认不阻塞 |
| strings JSON | `assets/…/build_a_molecule_strings_en.json` |

## 6. Derived vs Canonical

| Canonical（SSOT） | Derived（只读） |
|---|---|
| atoms, positions, bonds, kit membership, collection quantities | formula, displayName, molecularWeight, bondCount, matched CompleteMolecule, isAllowed, isFull |

禁止 Widget/Painter 自算 formula 或自判 bond 合法性。
