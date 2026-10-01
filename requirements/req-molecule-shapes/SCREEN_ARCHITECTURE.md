# SCREEN_ARCHITECTURE

`isBasicsVersion = false`。两屏都走 `MoleculeShapesScreenView`，分子是 three.js 场景，控件是 Scenery。

## Model Screen

| 项 | 类 |
|---|---|
| Screen | `js/model/ModelMoleculesScreen.js` |
| Model | `ModelMoleculesModel` → `MoleculeShapesModel` |
| Molecule | `VSEPRMolecule`（始终 `isReal = false`） |
| ScreenView | `ModelMoleculesScreenView` → `MoleculeShapesScreenView` |
| 3D | `MoleculeView`（原子球、键圆柱、孤对网格、键角） |

布局（局部坐标，相对 `layoutBounds`）：

- Play area：全屏 three.js canvas（`moleculeNode`），相机在分子局部系之外
- 右上 `AlignBox` margin 10：Bonding 面板、Lone Pair 面板、Remove All、Options 面板
- 左下 margin 10：Name 面板（Electron Geometry | Molecule Geometry）
- 右下：`ResetAllButton`，`right = maxX-10`，`bottom = maxY-10`

Bonding 面板三个 `BondGroupNode`（order 1、2、3），间距 10。缩略图逻辑尺寸：原子键 120×42，孤对 78×55（绘制时 ×3 再缩回）。删除按钮是红色底、白色 X（`RemovePairGroupButton`，kite `Shape`，不是图片）。

交互：

- 点缩略图：`addPairGroup(order, globalBounds)`，从控件位置生成初始 3D 点再 ×1.2
- 点 X：从后往前删第一个匹配 order 的中心键
- 背景拖拽：命中电子对则球面拖动，否则旋转四元数（`scale = 0.007 / activeScale`，欧拉 `XYZ`，`delta.y` 为 x 旋转、`delta.x` 为 y 旋转，左乘旧四元数）

## Real Molecules Screen

| 项 | 类 |
|---|---|
| Screen | `js/real/RealMoleculesScreen.js` |
| Model | `RealMoleculesModel` |
| Molecule | `showRealView ? RealMolecule : VSEPRMolecule` |
| ScreenView | `RealMoleculesScreenView` |

布局：

- 右上：Molecule 面板（`ComboBox`，公式用 `ChemUtils.toSubscript`）+ Options 面板
- 上方居中偏左：Real / Model `AquaRadioButtonGroup`  
  `centerX = layoutBounds.width/2 - 100`，`top = layoutBounds.top + 20`  
  字号 28，radio scale 0.7，间距 30
- 左下 Name、右下 Reset All 与 Model Screen 相同
- 没有 Bonding / Lone Pair / Remove All

ComboBox 顺序 = `TAB_2_MOLECULES`。

## 共用 Model 状态（`MoleculeShapesModel`）

| Property | 默认（完整版） |
|---|---|
| `moleculeProperty` | 各屏初始分子 |
| `electronGeometryProperty` | 由中心 VSEPR 推导，只读 |
| `moleculeGeometryProperty` | 同上 |
| `moleculeQuaternionProperty` | 单位四元数 |
| `showBondAnglesProperty` | false |
| `showLonePairsProperty` | true |
| `showMoleculeGeometryProperty` | false |
| `showElectronGeometryProperty` | false |
| `showOuterLonePairsProperty` | `showLonePairs && MoleculeShapesGlobals.showOuterLonePairs` |

`MoleculeShapesGlobals.showOuterLonePairsProperty` 来自 query `?showOuterLonePairs`，默认 false，挂在 Preferences，不在屏内 Options。

## MVT

```text
Pointer / checkbox / combo
    → ScreenView listener
    → MoleculeShapesModel / Molecule / PairGroup
    → bondChangedEmitter → geometry properties
    → MoleculeView.updateView / Scenery 文本
```

View 不拥有排斥积分。`ScreenView.step` 调 `moleculeView.updateView()`；模型 `step` 调 `molecule.update`。

## 颜色（default profile，`MoleculeShapesColors.js`）

| 角色 | RGB |
|---|---|
| 背景 | 0,0,0 |
| 中心原子（Model） | 159,102,218 |
| 径向原子（Model） | 255,255,255 |
| 键 | 255,255,255 |
| 孤对壳 | 255,255,255, α0.7 |
| 孤对电子 | 255,255,0, α0.8 |
| 分子几何名 | 255,255,140 |
| 电子几何名 | 255,204,102 |
| 键角读数 | 255,255,255 |
| 键角弧 | 255,0,0 |
| Remove All 底 | 255,200,0 |
| 删除 X 底 | `#d00` |

Real 原子颜色来自 nitroglycerin `Element`（依赖，不在本仓库）。Phase 2 必须按元素符号取色，不能改成 Model 屏的紫/白球冒充。

## 3D 绘制参数（View，Phase 2 用）

| 对象 | Source |
|---|---|
| 原子显示半径 | `AtomView.DISPLAY_RADIUS = 2`，触摸半径 3 |
| 键 | 圆柱半径之后在 `BondView` 里按 order 排开，间距 `bondRadius * 12/5`；双键两根偏移，三键中间一根加两侧 |
| 孤对壳 | `LonePairGeometryData` 网格，scale 2.5；两个电子球半径 0.25，局部位置 x=±0.75, y=5 |
| 相机 | `PerspectiveCamera` near 1 far 100，位置 `(0.12*50, -0.025*50, 40)` = `(6, -1.25, 40)` |
| 灯光 | ambient `0x191919`；方向光两盏 |
