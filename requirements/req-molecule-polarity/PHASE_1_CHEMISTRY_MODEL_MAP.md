# PHASE 1 — Chemistry / Model Map

> 全部公式摘自本地源码；**禁止**用教材“更正确”的模型替换。

---

## 1. 坐标系

- Model：`(0,0)` 左上，**+x 右，+y 下**
- 正旋转：**顺时针**（`angleProperty` 文档明确）
- Layout bounds：`1100 × 700`（`MPConstants.LAYOUT_BOUNDS`）

## 2. 常量（`MPConstants.ts`）

| 常量 | 值 |
|---|---|
| `ELECTRONEGATIVITY_RANGE` | [2, 4]，默认 2 |
| `ELECTRONEGATIVITY_TICK_SPACING` | 0.2 |
| `ATOM_DIAMETER` | 100 |
| `BOND_LENGTH` | 150 |
| `ANGLE_RANGE` | [-π, π] |
| `SURFACE_GRADIENT_WIDTH_MULTIPLIER` | 5 |
| E 场 `MAX_RADIANS_PER_STEP` | 0.17（`MPModel.ts`） |

## 3. Atom（`common/model/Atom.ts`）

| 字段 | 说明 |
|---|---|
| `label` | `'A' \| 'B' \| 'C'` |
| `diameter` | 默认 100 |
| `color` | A 黄 / B 绿 / C 粉 |
| `positionProperty` | 由分子结构约束 |
| `electronegativityProperty` | [2,4] |
| `partialChargeProperty` | 只读派生，默认 0 |

`reset()`：只 reset EN（位置/电荷由分子重置）。

## 4. Bond 偶极（`Bond.ts`）

```
deltaEN = EN(atom2) - EN(atom1)
magnitude = |deltaEN|
angle = atan2(atom2 - center) ; 若 deltaEN < 0 则 +π
dipole = polar(magnitude, angle)
若 dipoleDirection == negativeToPositive → dipole.rotate(π)
```

源码注释：**现实中 magnitude 还依赖许多因素；此处刻意简化。**

## 5. Molecule 分子偶极（`Molecule.ts`）

```
molecularDipole = Σ bond.dipole
若 |y| < 1e-10 → y = 0
```

## 6. DiatomicMolecule（Two Atoms）

| 项 | 值 |
|---|---|
| 默认 EN | A=2.0，B=3.0（`min + length/2`） |
| 几何 | 半径 `BOND_LENGTH/2`；A 在 `angle+π`，B 在 `angle` |
| 部分电荷 | `A = deltaEN`，`B = -deltaEN`（deltaEN = EN_B − EN_A） |
| 分子位置 | ScreenView 约 `(380, 280)` |

## 7. TriatomicMolecule（Three Atoms）

| 项 | 值 |
|---|---|
| 默认 EN | A=2，B=3，C=2 |
| B | 固定在分子 `position` |
| `bondAngleAB` | 默认 `5π/6`（约 8 点） |
| `bondAngleBC` | 默认 `π/6`（约 4 点） |
| 部分电荷 | `A = -deltaAB`，`C = -deltaCB`，`B = deltaAB+deltaCB`  
|  | 其中 `deltaAB = EN_A−EN_B`，`deltaCB = EN_C−EN_B` |
| `deltaENProperty` | **= molecularDipole.magnitude**（非简单 EN 差） |
| 分子位置 | 约 `(400, 280)` |

## 8. E 场对齐（`MPModel.step`）

条件：`eFieldEnabled && !isDragging`

1. 取 molecular dipole；若 preference 为 `negativeToPositive` 则先旋转 π  
2. `deltaDipoleAngle = |linear(0, EN_range_length, 0, 0.17, |dipole|)|`  
3. 按偶极当前角象限逐步转到 0（对齐 E 场）  
4. 将偶极角变化映射到 `molecule.angleProperty`  
5. 接近对齐时 snap `angle → 0`

## 9. Real Molecules（摘要）

| 项 | 源码行为 |
|---|---|
| 19 分子 | H2 N2 O2 F2 HF · H2O CO2 HCN O3 · NH3 BH3 BF3 CH2O · CH4 CH3F CH2F2 CHF3 CF4 CHCl3 |
| 默认 | HF · Basic · quaternion 来自 `RealMoleculeCustomization` |
| Display EN | H=2.2 B=2.0 C=2.6 N=3.0 O=3.4 F=4.0 Cl=3.2 |
| Basic 键偶极 | ≈ \|EN2−EN1\| |
| Advanced 键偶极 | Debye：`((c1−c2)/2)*(dist/0.208194)` |
| Basic ESP | 点电荷 Coulomb 叠加 |
| Advanced | 预计算顶点 ESP / density（`RealMoleculeData.ts`） |

## 10. Flutter Model 包结构（拟）

```
lib/chemistry/molecule_polarity/model/
  mp_vector2.dart
  normalize_angle.dart
  mp_preferences.dart
  atom.dart
  bond.dart
  molecule.dart
  diatomic_molecule.dart
  triatomic_molecule.dart
  mp_model.dart                 # E-field step
  two_atoms_model.dart
  three_atoms_model.dart
  view_properties.dart
  real_molecules/ …            # 后续
```

Model **不依赖** Flutter Widget。
