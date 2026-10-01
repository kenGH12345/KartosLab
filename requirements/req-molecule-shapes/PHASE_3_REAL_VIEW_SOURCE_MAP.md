# PHASE 3 — Real Molecules View Source Map

基准：本地 `js/real/` + `js/common/model/RealMolecule*.js`，`isBasicsVersion = false`。

## 1. 类对照

| Source | Flutter |
|---|---|
| `RealMoleculesScreen` | `RealMoleculesScreen` |
| `RealMoleculesScreenView` | same widget layout |
| `RealMoleculesModel` | `RealMoleculesModel`（Phase 1，已有） |
| `RealMoleculeShape` / `TAB_2_MOLECULES` | `tab2Molecules`（13，H2O 第一） |
| `RealMolecule` | `RealMolecule` |
| Model 半屏 `VSEPRMolecule` rebuild | `vseprMoleculeFromShape` |
| `MoleculeView` | shared `MoleculePainter` |
| ComboBox + `ChemUtils.toSubscript` | molecule dropdown + subscript RichText |
| Real / Model `AquaRadioButtonGroup` | Real / Model radio row |
| `OptionsNode` | Show Lone Pairs / Show Bond Angles |
| `GeometryNamePanel` | shared Name panel（名称文字） |
| Preferences `showOuterLonePairs` | `MoleculeShapesPreferences` |
| Reset All | `KratosResetAllButton` |

## 2. Screen 层级（source）

```text
RealMoleculesScreenView
├── three.js MoleculeView (play area)
├── Real | Model radios   top, centerX = width/2 - 100
├── right: Molecule panel (ComboBox) + Options
├── left-bottom: Name (electron / molecule geometry labels)
└── right-bottom: Reset All
```

**没有** Bonding / Lone Pair / Remove All。不可编辑原子。

## 3. Real / Model

| | Real (`showRealView=true`) | Model (`false`) |
|---|---|---|
| Molecule class | `RealMolecule` | `VSEPRMolecule` |
| Coordinates | shape 实测方向 + 简化键长 | ElectronGeometry 理想槽 |
| Angles | 从当前径向 orientation | 理想槽夹角 |
| Selected shape | 不变 | 不变 |
| Switch molecule | rebuild + reset quaternion | same |

两 Screen 的 model **不共享**（各自构造）。

## 4. 13 分子顺序

见 `REAL_MOLECULE_MATRIX.md`：H2O → … → SF6。Basics 的 BeCl2 不进菜单。

## 5. 交互

| 操作 | 支持 |
|---|---|
| 选分子 | ComboBox |
| Real / Model | radios |
| 背景旋转 | 同 ScreenView（改 quaternion，不改坐标） |
| 拖原子 | source 仍支持命中径向对；Real 屏以观察为主，source 同样挂着 multiDragListener |
| Options | lone pairs / bond angles |
| Outer lone pairs | Preferences，且需 Show Lone Pairs |
| Reset | H2O + Real + 默认 options + 单位四元数 |

## 6. 共享 3D

复用 Phase 2：`MoleculeCamera`、`MoleculePainter`、depth sort。  
Real 原子：有 `element` 时用 nitroglycerin/PhET 元素色；Model Screen 无 element 时仍用紫/白。

## 7. 不做

- Home
- 改 Model Screen 业务
- 改 Phase 1 domain / 角度语义
- 自造编辑控件
