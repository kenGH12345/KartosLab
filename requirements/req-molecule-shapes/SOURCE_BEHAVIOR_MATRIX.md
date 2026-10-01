# SOURCE_BEHAVIOR_MATRIX

基准：本地 `js/`，`isBasicsVersion = false`。Basics 分支只记录“本 sim 不走”，不实现。

## 全局

| 行为 | Source | 默认 |
|---|---|---|
| Screen 列表 | `molecule-shapes-main.js`：Model，然后 Real Molecules | Model 在前 |
| max radial domains | `MoleculeShapesQueryParameters.maxConnections`，范围 0–6 | 6 |
| 单/双/三键是否各算 1 个 domain | 是。`wouldAllowBondOrder` 忽略 order | — |
| 非物理结构 | 只要 domain ≤ maxConnections 就允许 | 不额外禁止 |
| 几何名称 | `(径向原子数, 中心孤对数)` | 随键变化 |
| 键角 | 径向原子对的 orientation 夹角，显示 `toFixed(1)°`，不足 5 字符左侧补 `0` | 关 |
| 旋转状态 | `moleculeQuaternionProperty`（THREE.Quaternion） | 单位四元数 |
| 拖动 | 命中 pair → 球面上 `dragToPosition`；否则左乘欧拉增量旋转整分子 | — |
| 拖动与旋转互斥 | 有粒子被拖时不能旋转 | — |
| dt | `min(dt, 0.2)` | — |

## Model Screen

| 行为 | Source 实现 | 结果 |
|---|---|---|
| 初始分子 | 中心原子 + 两个 order=1 键 | x=2,e=0，Linear / Linear |
| 添加单/双/三键 | `addGroupAndBond(..., order, 10)` | radial +1，名称重算 |
| 删除某阶键 | 从中心键列表末尾找第一个 `order` 匹配并 `removeGroup` | radial −1 |
| 添加孤对 | order 0，距离 7；视图还要求 `showLonePairs` | e+1 |
| 删除孤对 | 删除最后一个 order 0 的中心连接 | e−1 |
| 改键序 | 没有原地 `setOrder`。删掉该阶再加另一阶 | domain 数先减后加 |
| 拖原子 | 局部坐标改变，速度清零 | 键角变，几何名不变 |
| 旋转分子 | 四元数更新，局部坐标不变 | 世界方向变 |
| Remove All | `removeAllGroups` | 只留中心原子，名称空 |
| Show Lone Pairs | `showLonePairsProperty` | 默认 true |
| Show Bond Angles | `showBondAnglesProperty` | 默认 false |
| Molecule Geometry | `showMoleculeGeometryProperty` | 默认 false |
| Electron Geometry | `showElectronGeometryProperty` | 默认 false |
| Reset | 选项与四元数复位，删光再放回两个单键 | 回到初始 |

键角可见度（有 3 个以上键时按相机方向衰减）属于 View，不改变角度数值。≤2 个键时亮度恒为 1。

## Real Molecules Screen

| 行为 | Source | 默认 |
|---|---|---|
| 分子列表 | `TAB_2_MOLECULES` 13 个，见矩阵 | 第一项 H2O |
| Real / Model | `showRealViewProperty` | true（Real） |
| 切换 Real/Model | `rebuildMolecule(false)`，**不换**选中分子；尽量把新坐标转到旧朝向 | — |
| 切换分子 | `rebuildMolecule(true)` 并 `moleculeQuaternionProperty.reset()` | — |
| Real 坐标 | `RealMolecule` + `RealAtomPosition`，键方向来自 shape | 实测角 |
| Model 坐标 | `VSEPRMolecule`，理想 `unitVectors`，键序与外层孤对数量从原分子拷贝 | VSEPR 角 |
| 键长简化 | `USE_SIMPLIFIED_BOND_LENGTH = true`，全部径向键长 = `overrideÅ * 5.5` | 角不变 |
| Options | 与 Model 相同的两个复选框 | 同默认 |
| 外层孤对 | Preferences `showOuterLonePairs`，且必须同时 Show Lone Pairs | false |
| Reset | 形状、Real/Model、选项、四元数，并强制 rebuild | H2O + Real |

## 明确不做

| 项 | 原因 |
|---|---|
| Photon / 波长 / 吸收 | 不属于本 source |
| Basics 五分子菜单 | `isBasicsVersion === false` |
| 按教材删掉“不存在”的 Model 结构 | source 只限制 domain ≤ 6 |
| 把双键算成两个 domain | 与 `PairGroup` / `wouldAllowBondOrder` 相反 |
