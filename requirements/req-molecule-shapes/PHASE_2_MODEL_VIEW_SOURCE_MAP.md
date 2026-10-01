# PHASE 2 — Model View Source Map

基准：本地 `molecule-shapes-main`，`isBasicsVersion = false`。  
Phase 1 的 domain / 几何命名 / 理想角语义 **不改**。本文件只映射 View + 排斥积分。

## 1. 类对照

| Source | Flutter Phase 2 |
|---|---|
| `ModelMoleculesScreen` | `ModelMoleculesScreen` widget |
| `ModelMoleculesScreenView` | `ModelMoleculesScreen` layout + controls |
| `MoleculeShapesScreenView` | shared layout chrome + projection host |
| `MoleculeView` | `MoleculePainter` + depth-sorted drawables |
| `AtomView` | painted sphere, radius 2 |
| `BondView` | painted cylinders / lines, order 1–3, radius 0.5 |
| `LonePairView` | shell + two electrons (geometry-driven, not Material icons) |
| `BondAngleView` | arc + `toFixed(1)°` label from current orientations |
| `GeometryNamePanel` | **name text + checkboxes only** — not a 3D polyhedron overlay |
| `OptionsNode` | Show Lone Pairs, Show Bond Angles |
| `BondGroupNode` | Bonding / Lone Pair add+remove rows |
| `RemovePairGroupButton` | red X, kite cross |
| `ResetAllButton` | `KratosResetAllButton` radius 20.5 |
| `AttractorModel` | `attractor_model.dart` |
| `VSEPRMolecule.update` | `VseprMolecule.update` + `ModelMoleculesModel.step` |

## 2. 重要纠偏：Geometry “visualization”

Source 里 `showMoleculeGeometry` / `showElectronGeometry` 只控制 Name 面板里的**文字标签可见性**（`GeometryNamePanel`）。

**没有**把 tetrahedron / octahedron 画进 three.js 场景的 geometry guide mesh。

因此 Phase 2：

```text
Show Molecule Geometry  → 显示 molecule geometry 名称字符串
Show Electron Geometry  → 显示 electron geometry 名称字符串
```

禁止自造 3D 几何框线冒充 source。

## 3. 3D 与相机

| 项 | Source |
|---|---|
| 引擎 | three.js r71 WebGL，Canvas fallback |
| Flutter 策略 | CustomPainter + perspective projection + depth sort（不引入 Flutter GPU 3D） |
| 相机位置 | `(6, -1.25, 40)` |
| near / far | 1 / 100 |
| FOV | PerspectiveCamera 默认 50° |
| 分子旋转 | `moleculeQuaternionProperty` 应用到 MoleculeView；局部坐标不变 |
| 灯光（视觉近似） | ambient + 两盏 directional，用简单球高光近似 |

## 4. 交互

| 输入 | Target | 效果 |
|---|---|---|
| 指针按下在径向 atom / lone pair | pair drag | `userControlled=true`，球面 `dragToPosition` |
| 指针按下在背景 | model rotate | 左乘 XYZ 欧拉增量到 quaternion |
| 二者互斥 | 有粒子在拖则不旋转 | 同 ScreenView |
| 缩略图点击 | add | `addGroupAndBond` |
| 红色 X | remove | 从后往前删匹配 order |
| Remove All | 清 radial | 保留中心原子 |
| Options / Name checkboxes | model flags | 立刻影响绘制 / 文案 |

## 5. 排斥积分（本阶段必须迁）

每帧 `dt = min(dt, 0.2)`：

1. 每个非中心 group：`stepForward`（切向速度 + 阻尼）+ `attractToIdealDistance`
2. 中心有邻居时：`LocalShape.applyAttraction` → `AttractorModel.applyAttractorForces`
3. 径向两两 `repulseFrom`（Coulomb-like），`trueLengthsRatioOverride` 由吸引误差调制
4. 吸引子：对允许的 permutation 做 SVD 刚体旋转匹配，推速度与位置朝理想槽

Lone pairs 与 bonds 在 permutation 内各自互换；**单/双/三键彼此可互换**（source 明确拒绝“多重键优先高排斥槽”）。

## 6. 布局（1024×618）

| 区域 | 锚点 |
|---|---|
| 3D play area | 全屏黑色背景 |
| 右上控制栈 | Bonding · Lone Pair · Remove All · Options，margin 10 |
| 左下 Name | Electron / Molecule 复选框 + 名称 |
| 右下 Reset | max−10 |

## 7. 资源

| 视觉 | 处理 |
|---|---|
| 孤对壳 | `LonePairGeometryData` / 程序近似壳（同色同尺度）；最终不得用 Material icon |
| 原子 / 键 | CustomPainter |
| Substituted | 目标 0 |

## 8. 本阶段不做

- Real Molecules Screen UI
- Home 接入
- 改 Phase 1 测试语义
- 其他 simulation
