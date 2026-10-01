# PHASE 1 — Component Map

## 分层

```
Model          → 化学量 / EN / 偶极 / 电荷 / E 场步进
Interaction    → 分子旋转、键角拖拽、EN 滑块、控件
Renderer       → Atom / Bond / Dipole / Charge / Surface / Plates
UI             → Panel / Checkbox / Radio / Slider / Combo / Reset / ColorKey
Shell          → TabbedScreen / SimulationShell / Transform
```

---

## Model Components

| 组件 | 源码 | Flutter 目标 |
|---|---|---|
| Atom | `common/model/Atom.ts` | `model/atom.dart` |
| Bond + dipole | `Bond.ts` | `model/bond.dart` |
| Molecule | `Molecule.ts` | `model/molecule.dart` |
| DiatomicMolecule | `twoatoms/...` | `model/diatomic_molecule.dart` |
| TriatomicMolecule | `threeatoms/...` | `model/triatomic_molecule.dart` |
| MPModel (E-field) | `MPModel.ts` | `model/mp_model.dart` |
| TwoAtomsModel | | `model/two_atoms_model.dart` |
| ThreeAtomsModel | | `model/three_atoms_model.dart` |
| MPPreferences | | `model/mp_preferences.dart` |
| ViewProperties ×3 | | `model/*_view_properties.dart` |
| RealMolecule* | `realmolecules/model/` | `model/real_molecules/`（后置） |

## Interaction

| 组件 | 源码 | Flutter |
|---|---|---|
| MoleculeAngleDragListener | common/view | `interaction/molecule_angle_drag.dart` |
| BondAngleDragListener | threeatoms | `interaction/bond_angle_drag.dart` |
| ElectronegativitySlider | common | UI + controller setters |
| MoleculeRotationListener (3D) | realmolecules | Real Molecules 阶段 |

## Renderer / Painters

| 组件 | 说明 |
|---|---|
| AtomPainter | 阴影球 + 标签 |
| BondPainter | 灰色矩形/线 |
| DipolePainter | Jmol 风格箭头；键偶极黑 / 分子偶极黄 |
| PartialChargePainter | δ+ / δ− |
| SurfacePainter (2D) | 双圆弧 + LinearGradient |
| PlatesPainter | E 场极板 |
| BondCharacterPainter | Covalent↔Ionic 条 |
| ColorKeyPainter | ESP RWB / Density BW |
| RealMoleculeRenderer | 3D 或投影（后置） |

## UI

| 组件 | 复用策略 |
|---|---|
| `KratosTabbedScreen` | REUSE |
| EN Panel + Slider | PhET 外观包装 `KratosSlider` 或自绘 PointyThumb |
| View checkboxes | 复制 Pl/Pm Checkbox → `MpCheckbox` |
| Surface / Model radio | `KratosRadioGroup` 或 PhET aqua radio 样式 |
| Molecule ComboBox | `KratosComboBox` |
| Reset All | `MpResetAllButton`（参考 Pl/Pm） |
| Control Panel | `MpControlPanel`（灰底 `#eee`） |

## Shell / Transform

| 组件 | 说明 |
|---|---|
| `MpSimulationShell` | FittedBox 1100×700 |
| `MpTransform` | model↔view（本 sim model Y 已向下，与 Flutter 一致时可 identity scale） |
| `mp_constants.dart` / `mp_colors.dart` / `mp_strings.dart` / `mp_assets.dart` |

## 不存在的组件（禁止自造）

- Material Icons 冒充偶极/原子
- 独立“测量尺”工具（源码无）
- Three Atoms 的 Surface 控件
- Real Molecules 的 E 场
