# REAL_MOLECULE_MATRIX

来源：`js/common/model/RealMoleculeShape.js`。  
`USE_SIMPLIFIED_BOND_LENGTH = true`：径向位置被归一化后乘 `bondLengthOverride * 5.5`，**键角与方向保持构造时的角度**。  
完整版 ComboBox = `TAB_2_MOLECULES`（13）。`TAB_2_BASIC_MOLECULES` 仅 Basics，本 sim 不列出。

中心几何由中心原子的成键数 `x` 与 `lonePairCount` `e` 决定，与 Model 屏同一张 `MoleculeGeometry` / `ElectronGeometry` 表。  
Real 键角来自坐标；Model 键角是孤对占前 `e` 个理想槽之后，成键原子之间的夹角（1 位小数显示）。

## 完整版（界面顺序）

| # | 代码名 | 显示式 | 中心 | x | e | 键序 | 分子几何 | 电子几何 | Real 键角 | Model 键角（理想槽） | 径向原子外层孤对 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | WATER | H2O | O | 2 | 2 | 1,1 | Bent | Tetrahedral | 104.5° | 109.5° | H: 0 |
| 2 | CARBON_DIOXIDE | CO2 | C | 2 | 0 | 2,2 | Linear | Linear | 180.0° | 180.0° | O: 2, 2 |
| 3 | SULFUR_DIOXIDE | SO2 | S | 2 | 1 | 2,2 | Bent | Trigonal Planar | 119.0° | 120.0° | O: 2, 2 |
| 4 | XENON_DIFLUORIDE | XeF2 | Xe | 2 | 3 | 1,1 | Linear | Trigonal Bipyramidal | 180.0° | 180.0° | F: 3, 3 |
| 5 | BORON_TRIFLUORIDE | BF3 | B | 3 | 0 | 1,1,1 | Trigonal Planar | Trigonal Planar | 120.0° | 120.0° | F: 3 |
| 6 | CHLORINE_TRIFLUORIDE | ClF3 | Cl | 3 | 2 | 1,1,1 | T-shaped | Trigonal Bipyramidal | 87.5°（轴-赤道），175.0°（两赤道） | 90.0°，180.0° | F: 3 |
| 7 | AMMONIA | NH3 | N | 3 | 1 | 1,1,1 | Trigonal Pyramidal | Tetrahedral | 107.8° | 109.5° | H: 0 |
| 8 | METHANE | CH4 | C | 4 | 0 | 1×4 | Tetrahedral | Tetrahedral | 109.5° | 109.5° | H: 0 |
| 9 | SULFUR_TETRAFLUORIDE | SF4 | S | 4 | 1 | 1×4 | Seesaw | Trigonal Bipyramidal | 173.1°，101.6° | 180.0°，120.0°，90.0° | F: 3 |
| 10 | XENON_TETRAFLUORIDE | XeF4 | Xe | 4 | 2 | 1×4 | Square Planar | Octahedral | 90.0°，180.0° | 90.0°，180.0° | F: 3 |
| 11 | BROMINE_PENTAFLUORIDE | BrF5 | Br | 5 | 1 | 1×5 | Square Pyramidal | Octahedral | 轴-赤道 84.8°；相邻赤道 89.5°；对位赤道 169.6° | 90.0°，180.0° | F: 3 |
| 12 | PHOSPHORUS_PENTACHLORIDE | PCl5 | P | 5 | 0 | 1×5 | Trigonal Bipyramidal | Trigonal Bipyramidal | 90.0°，120.0°，180.0° | 同 Real | Cl: 3 |
| 13 | SULFUR_HEXAFLUORIDE | SF6 | S | 6 | 0 | 1×6 | Octahedral | Octahedral | 90.0°，180.0° | 同 Real | F: 3 |

初始选中第 1 项，`showRealView = true`。

## 构造细节（避免和教材坐标搞混）

- H2O：键长参数 0.957 Å，半角 `104.5°/2`，两个 H 在 xy 平面、关于 −y 对称。中心 O 的 `lonePairCount = 2`。
- CO2：1.163 Å，O 在 ±x，键序 2，每个 O `lonePairCount = 2`。
- SO2：1.431 Å，半角 `119°/2`，键序 2，中心 S 有 1 个孤对。
- XeF2：1.977 Å，F 在 ±x，中心 Xe 有 3 个孤对。分子几何因此是 Linear（`e = 3`），不是 Bent。
- BF3：1.313 Å，三个 F 间隔 120°。
- ClF3：轴向 F 沿 −y、键长 1.598（简化后仍用 1.698 Å 的统一长度），两个赤道 F 相对 −y 偏 87.5°。中心 Cl 有 2 个孤对。
- NH3：轴向角常数 `1.202623030417028` rad（源码由键角反解，不在文件里再写一遍 β）。由该常数重建的 H-N-H 角是 **107.8°**。
- CH4：1.087 Å，方向 = `ElectronGeometry.getConfiguration(4).unitVectors`。
- SF4：大角 173.1°、小角 101.6° 是成对氟的夹角（代码用半角）。统一长度参数 1.595 Å。
- XeF4：1.953 Å，四个 F 在 ±x、±z。中心 2 个孤对。
- BrF5：赤道键长 1.774 Å，相对轴向偏 84.8°；轴向键原始长度 1.689 Å，简化后方向不变、长度改成 1.774。中心 Br 有 1 个孤对。
- PCl5：轴向原始 2.14 Å、赤道 2.02 Å，简化后都变成 2.02 Å 的模型长度；赤道间隔 120°，轴在 ±x。
- SF6：1.564 Å，方向 = octahedral `unitVectors`。

## 只定义、不出现在本 sim 菜单

| 代码名 | 式 | 属于 | 备注 |
|---|---|---|---|
| BERYLLIUM_CHLORIDE | BeCl2 | 仅 Basics | 线性，两个 Cl，各 3 个外层孤对，键长参数 1.8 |
| （Basics 其余） | BF3, CH4, PCl5, SF6 | Basics 也列出 | 完整版已经包含这四个，只是菜单顺序不同 |

## Real 与 Model 不能混用的例子

| 分子 | Real | Model |
|---|---|---|
| H2O | 104.5° Bent | 109.5° Bent（四面体电子几何） |
| SO2 | 119.0° | 120.0° |
| NH3 | 107.8° | 109.5° |
| ClF3 | 87.5° / 175.0° | 90.0° / 180.0° |
| SF4 | 173.1° / 101.6° | 180° / 120° / 90° |
| BrF5 | 84.8° 等 | 90° / 180° |
| CO2, BF3, CH4, PCl5, SF6, XeF2, XeF4 | 与理想角相同或只差显示舍入 | 同几何名称；XeF2/XeF4 的电子几何仍含孤对 |

切换 Real ↔ Model 只换坐标和角度表现，`realMoleculeShape` 保持不变。
