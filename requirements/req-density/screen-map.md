# Screen Map · Density

官方当前页与源码一致，共 **3** 个 Screen。证据：`package.json` `screenNameKeys` + `density-main.ts:41-44`。

字符串：屏名在 `density-strings_en.json`（Intro / Compare / Mystery）。控件文案在 common strings。

---

## 1. Intro（`screen.intro` = "Intro"）

**教学**：固定密度材料；改质量则体积变，反之亦然；Custom 则质量体积独立、密度派生。与水比较沉浮。

**Play Area**

- 3D/等距地面 + 水池 + 天空（`skyBottomProperty`）
- 立方块 A（及可选 B），可抓取
- 块标签 A / B（`massLabel.primary/secondary`）
- 块旁质量读数（Intro 默认 `massValuesInitiallyDisplayed: true`）
- 无台秤、无力矢量、无换液

**Control Area**

- 顶部居中 Accordion：**Density** 数轴（0–10000 kg/m³），标记 A 与可见时的 B，2 位 kg/L
- 右上：A 面板（材料 Combo + Mass + Volume）；Two Blocks 时叠加 B 面板
- 左下 Reset All；其左侧 One/Two Blocks **图标** Radio（无 "One Block" 文案，图标 `singleCuboidIcon` / `doubleCuboidIcon`）

**材料表（Intro 下拉）** — `SIMPLE_MASS_MATERIALS` + Custom：

| materialId | 英文 | density kg/m³ |
|---|---|---|
| styrofoam | Styrofoam | 150 |
| wood | Wood | 400 |
| ice | Ice | 919 |
| pvc | PVC | 1440 |
| brick | Brick | 2000 |
| aluminum | Aluminum | 2700 |
| custom | Custom | 由 m/V 派生；无纹理时灰度随密度 |

---

## 2. Compare（`screen.compare` = "Compare"）

**Play Area**：水池 + 4 个彩色立方体（标签 A–D 随模式重映射，见 state-model）。

**Control Area**

- 右上 `BlocksPanel`：Same Mass / Same Volume / Same Density
- 地面前沿下方偏右 `BlocksValuePanel`：当前模式的 **一条** NumberControl（Mass 或 Volume 或 Density）
- Reset All

无材料下拉。无 One/Two Blocks。质量标签默认显示。

---

## 3. Mystery（`screen.mystery` = "Mystery"）

**Play Area**：水池 + 5 个神秘块 + **左侧固定台秤（kg）**。

**Control Area**

- 顶部居中 Accordion **Density Table**（默认折叠）
- 右上 Blocks 面板：Set 1 / Set 2 / Set 3 / Random；Random 时出现 Refresh（a11y "Random Block Refresh"）
- Reset All

`massValuesInitiallyDisplayed: false`：块上不显示 kg，除非用户打开 Mass Values（若 ScreenView 基类提供该勾选——需在 `DensityBuoyancyScreenView` 确认）。基类默认 true，Mystery 显式 false。

键盘帮助：Intro 含 Grab+Combo；Compare 含 Grab 不含 Combo；Mystery 两者皆无（`KeyboardHelpNode` 两布尔参数）。
