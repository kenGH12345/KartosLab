# PHASE 0 — Source Audit

本地基准：`phet sourses/molecule-shapes-main/molecule-shapes-main`  
包版本：`package.json` `1.7.0-dev.0`（`dependencies.json` 注释仍写 1.5.0-dev.4 / 2022-10-20，以当前 js 为准，不跟 GitHub main 升级）  
入口：`js/molecule-shapes-main.js`，`isBasicsVersion = false`。

本模拟只有两个 Screen，且不是 Molecules and Light / Molecule Shapes: Basics。

## 1. Source tree

| 路径 | 作用 |
|---|---|
| `js/molecule-shapes-main.js` | Sim 入口。两个 Screen：`ModelMoleculesScreen`、`RealMoleculesScreen` |
| `js/moleculeShapes.js` | Namespace `moleculeShapes` |
| `js/MoleculeShapesStrings.ts` | 字符串键 |
| `js/common/model/` | Molecule、PairGroup、Bond、VSEPR、Real molecule |
| `js/common/view/` | 两屏共用 ScreenView、Options、几何名称、颜色 |
| `js/common/view/3d/` | three.js 分子 / 键 / 孤对 / 键角 |
| `js/common/data/LonePairGeometryData.js` | 孤对电子云网格 |
| `js/model/` | Model Screen |
| `js/real/` | Real Molecules Screen |
| `assets/` | 孤对 OBJ/JSON + 截图 PNG。实现笔记写明 `images/` 是空 stub，没有位图 UI |
| `doc/model.md` | VSEPR 槽位与 Real 数据说明 |
| `molecule-shapes-strings_en.json` | 英文文案 |

没有 `.ts` 模型实现（仅 `MoleculeShapesStrings.ts`）。模型全部是 `.js`。

## 2. Screens

```text
Molecule Shapes (isBasicsVersion = false)
├── Model            ModelMoleculesScreen
└── Real Molecules   RealMoleculesScreen
```

Basics 分子表 `TAB_2_BASIC_MOLECULES` 存在于同一文件，但本入口不使用。

## 3. Model 语义（阻塞结论）

- **Pair group**：一个原子或一个孤对。三键原子仍是一个 PairGroup，不是三个 domain。`doc/implementation-notes.md` 写明 “electron pair 不准确，因为一个 PairGroup 可以代表三键原子”。
- **Bond order**：`0` 孤对，`1` 单键，`2` 双键，`3` 三键。孤对 bond 不是化学键，只是连接。
- **Electron domain**：连在中心原子上的 radial pair group 个数。`wouldAllowBondOrder` **不看** bond order，只看 `radialGroups.length < maxConnections`。
- **maxConnections**：query `maxConnections`，默认 `6`，`Molecule.maxConnectionsProperty` 范围 `0..6`。不要改成“化学上不合理就禁止”。
- **单/双/三键排斥**：`LocalShape.vseprPermutations` 注释写明 double/triple 不优先占高排斥槽，作者建议被明确拒绝。单/双/三键彼此可互换，孤对只与孤对互换。
- **理想槽位**：`VSEPRConfiguration` 把 electron geometry 的 `unitVectors[0 .. e)` 给孤对，其余给键。`doc/model.md`：steric number 5 时先填赤道孤对，再填剩余键，得到 T-shaped 等。
- **分子几何名称**只由 `(x, e)` 查表（`MoleculeGeometry.getConfiguration`），不由当前夹角反推。拖动原子改变键角数值，不改变几何名称。
- **键角数值**是两个径向原子 orientation 的夹角，`Utils.toFixed(angle, 1)` 加 `°`（`BondAngleView`）。不是教材理想角覆盖实时角。
- **旋转**：`moleculeQuaternionProperty` 存在 Model 上，应用到 `MoleculeView.quaternion`。原子坐标留在分子局部坐标系；拖原子时先把指针变回局部球面（`getSphericalMoleculePosition`）。旋转不是只存在 Widget 上的临时 Transform，但也不是改写局部坐标。
- **拖原子**：`PairGroup.dragToPosition` 写 position 并清零 velocity。用户拖拽时 `userControlled` 为 true，吸引/排斥暂停。

## 4. 几何表（source 实际支持）

Electron geometry 只按 domain 总数 `x+e`：

| n | id | 英文 |
|---|---|---|
| 0 | EMPTY | `""` |
| 1 | DIATOMIC | Linear |
| 2 | LINEAR | Linear |
| 3 | TRIGONAL_PLANAR | Trigonal Planar |
| 4 | TETRAHEDRAL | Tetrahedral |
| 5 | TRIGONAL_BIPYRAMIDAL | Trigonal Bipyramidal |
| 6 | OCTAHEDRAL | Octahedral |

Molecule geometry（`x` = 径向原子，`e` = 中心孤对）：

| x | e | id | 英文 |
|---|---|---|---|
| 0 | any | EMPTY | `""` |
| 1 | 0–5 | DIATOMIC | Linear |
| 2 | 0, 3, 4 | LINEAR | Linear |
| 2 | 1, 2 | BENT | Bent |
| 3 | 0 | TRIGONAL_PLANAR | Trigonal Planar |
| 3 | 1 | TRIGONAL_PYRAMIDAL | Trigonal Pyramidal |
| 3 | 2, 3 | T_SHAPED | T-shaped |
| 4 | 0 | TETRAHEDRAL | Tetrahedral |
| 4 | 1 | SEESAW | Seesaw |
| 4 | 2 | SQUARE_PLANAR | Square Planar |
| 5 | 0 | TRIGONAL_BIPYRAMIDAL | Trigonal Bipyramidal |
| 5 | 1 | SQUARE_PYRAMIDAL | Square Pyramidal |
| 6 | 0 | OCTAHEDRAL | Octahedral |

`x+e <= 6` 时上表覆盖全部可达组合。超出查表的 `(x,e)` 在 source 里 `throw`。

注意：`geometry.diatomic` 与 `shape.diatomic` 的英文都是 **Linear**，界面不显示 “Diatomic”。

理想键角来自 `ElectronGeometry` 单位向量（孤对占前 `e` 个槽），不是另写一张角度表。四面体常数 `TETRA_CONST = π * -19.471220333 / 180`，相邻向量夹角 `109.471…°`，显示 `109.5°`。

## 5. Model Screen 初始与操作

`ModelMoleculesModel.setupInitialMoleculeState`：

- 中心原子在原点，非孤对
- 两个 **单键**，位置分别为 `Vector3(8,0,3)` 与 `Vector3(2,8,-5)`，再 `setMagnitude(BONDED_PAIR_DISTANCE)`
- `BONDED_PAIR_DISTANCE = 10`，`LONE_PAIR_DISTANCE = 7`

因此初始几何是 2 bonding domains、0 lone pairs：**molecule Linear，electron Linear**。

右侧控件（完整版）：

- Bonding：single / double / triple 缩略图，点击添加，红色 X 删除该 order 的最后一个键
- Lone Pair：同样添加/删除，且 `showLonePairs === false` 时添加按钮禁用
- Remove All：删掉全部 radial groups，**保留中心原子**
- Options：Show Lone Pairs（默认 true）、Show Bond Angles（默认 false）
- 左下 Name：Molecule Geometry / Electron Geometry 复选框，默认都 false，名称仍随分子更新
- Reset All：恢复选项、四元数，并重建上述两个单键

添加时键长：孤对 7，成键原子 10。初始位置来自控件的屏幕点反投影（`addPairGroup`），再被吸引到球面上。

## 6. Real Molecules

完整版列表是 `RealMoleculeShape.TAB_2_MOLECULES`，顺序即 ComboBox 顺序，第一项 **H2O** 为初始分子。`showRealViewProperty` 默认 `true`。

切换 Real/Model **不改变** `realMoleculeShapeProperty`。切换分子种类时重置 `moleculeQuaternionProperty`。Real 使用实测/重建坐标与键角；Model 视图重建为 `VSEPRMolecule`，孤对占高排斥槽，键序从原分子按 permutation 取回。`USE_SIMPLIFIED_BOND_LENGTH = true`：径向键长统一成 `bondLengthOverride * 5.5`（模型单位；注释写 1 模型单位约等于 5.5 Å 的放大），方向保留，所以键角不变。

外层孤对：Preferences 的 `showOuterLonePairs`（query flag，默认 false）。显示条件是 `showLonePairs && showOuterLonePairs`。中心孤对只看 `showLonePairs`。

## 7. 物理（Phase 1 边界）

`VSEPRMolecule.update`：径向库仑排斥 + `AttractorModel` 把 pair group 拉向最近的理想槽位（SVD 最小二乘旋转 + 允许的 permutation）。原子被约束在以中心为球心的固定距离上。`step` 把 dt 限制在 0.2 s。

几何**名称**不依赖这套积分。键角**数值**依赖当前位置。Phase 1 迁移查表、单位向量、真实分子坐标和键角公式；吸引子 SVD 积分留到行为对齐，不另造一套角度表。

## 8. 完成条件对照

| 项 | 结论 |
|---|---|
| Screens | Model + Real Molecules |
| Model | `Molecule` / `VSEPRMolecule` / `RealMolecule` |
| VSEPR | AXE，孤对先占 `unitVectors` |
| Bond | order 0–3，每个 radial group 一个 domain |
| Lone pair | 中心孤对是 domain；外层孤对挂在径向原子上 |
| Geometry | 上表，名称来自 `(x,e)` |
| Bond angle | 径向原子 orientation 夹角，1 位小数 |
| Real molecules | 13 个（完整版），另有 2 个只属于 Basics |
| Interactions | 见 `SOURCE_BEHAVIOR_MATRIX.md` |
| Viewport | 见 `VIEWPORT_REPORT.md` |
| Assets | 见 `ASSET_AUDIT.md` |
