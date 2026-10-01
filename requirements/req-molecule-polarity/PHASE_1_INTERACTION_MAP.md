# PHASE 1 — Interaction Map

格式：Component → Trigger → Input → State → Visual → Model → Reset

---

## 1. Electronegativity Slider

| 项 | 内容 |
|---|---|
| Component | `ElectronegativitySlider` / Panel |
| Trigger | drag / keyboard |
| Input | EN ∈ [2,4]；release snap 到 0.2 |
| State | `atom.electronegativityProperty`；拖时 `molecule.isDraggingProperty=true` |
| Model | EN → bond dipole → molecular dipole → partial charges → surface fill |
| Visual | thumb、偶极长短/方向、δ、2D 表面、Bond Character 指针 |
| Reset | atom EN → 默认 |

## 2. Molecule Rotate (2D)

| 项 | 内容 |
|---|---|
| Component | `MoleculeAngleDragListener` |
| Trigger | pointer on molecule / bond / atom B（Three） |
| Input | 相对中心角，**5° 量化** |
| State | `angleProperty`；`isDraggingProperty` |
| Visual | 原子/键/偶极/表面同步旋转 |
| E-field | 拖拽期间暂停自动对齐 |
| Reset | `angleProperty.reset()` → 0 |

## 3. Bond Angle (Three Atoms)

| 项 | 内容 |
|---|---|
| Component | `BondAngleDragListener` on A / C |
| Trigger | drag atom A or C |
| State | `bondAngleABProperty` / `bondAngleBCProperty` |
| Model | 更新 A/C 位置 → 重算偶极与电荷 |
| Reset | 默认 5π/6 与 π/6 |

## 4. View Checkboxes

| Screen | Property | Default | Visual |
|---|---|---|---|
| Two | `bondDipoleVisible` | true | BondDipoleNode |
| Two | `partialChargesVisible` | false | δ labels |
| Two | `bondCharacterVisible` | false | BondCharacterPanel |
| Three | `bondDipolesVisible` | false | 两键偶极 |
| Three | `molecularDipoleVisible` | true | 黄箭头 |
| Three | `partialChargesVisible` | false | δ |
| Real | bond/molecular/partial/EN/labels | labels true，其余 false | 3D overlays |

Reset → 各 BooleanProperty.reset()

## 5. Surface Radio (Two + Real)

| Value | Visual |
|---|---|
| `none` | 无表面；隐藏 color key |
| `electrostaticPotential` | ESP 云 / mesh + RWB（或 rainbow）色标 |
| `electronDensity` | BW 云 / mesh + BW 色标 |

## 6. Electric Field Toggle (Two + Three)

| 项 | 内容 |
|---|---|
| State | `eFieldEnabledProperty` 默认 false |
| Visual | `PlatesNode.visible` |
| Model | `step(dt)` 驱动角度对齐 |
| Reset | false |

## 7. Real Molecules Combo + Model + 3D Drag

| 项 | 内容 |
|---|---|
| Molecule select | `moleculeProperty` → HF 等；重置 quaternion |
| Basic/Advanced | `isAdvancedProperty` → 电荷/偶极/ESP 数据源切换 |
| 3D drag | `moleculeQuaternionProperty` |
| Reset | 默认分子 HF + Basic + 初始 quaternion + view defaults |

## 8. Preferences (global)

| 项 | 内容 |
|---|---|
| Dipole direction | 立即重算所有 2D（及 Real）偶极方向 |
| Surface color | Real Molecules ESP 色图 |

## 9. Reset All（每屏）

```
model.reset()
viewProperties.reset()
[hints reset]  // Two & Three only
```

不跨屏清 Preferences（除非 Preferences 自己有 Reset）。
