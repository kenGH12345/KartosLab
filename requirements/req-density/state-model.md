# State Model · Density

> 源码：`density-buoyancy-common` · `[已确认]` 除非另标。

## 0. 单一事实源原则

原版把 `mass` 做成 `GuardedNumberProperty`，但由 multilink **从 density × volume 派生**：

```
mass = roundToInterval(density * volume, 1e-7) + containedMass
```

`Mass.ts:333-341`。`containedMass` 对 Density 立方体恒为 0。

**Intrinsic（可独立调）取决于材料是否 Custom：**

| 材料 | 改质量 | 改体积 | 改材料 |
|---|---|---|---|
| 具名材料（Wood 等） | 体积跟着变（`setVolume(mass/density)`） | 质量跟着变（density 固定） | 新 density，质量重算；体积保持 |
| Custom | 密度跟着变（`density = mass/volume`） | 密度跟着变（`density = mass/volume`） | 进入 Custom 后 mass 与 volume 解耦，density 为派生 |

证据：`MaterialMassVolumeControlNode.ts:224-278`。Intro 的 Custom 注释 `densityPropertyOptions.phetioReadOnly: true // Controlled by mass and volume`（`DensityIntroModel.ts:58-61`）。

Flutter：State 存 `materialId` + `mass` + `volume`（Custom）或 `materialId` + 其中一个自由量（具名）。**禁止无限制三字段同时当 SSOT。** Display density = solver(mass, volume)。

体积范围立方体：`Cuboid.MIN_VOLUME = 0.001`，`MAX_VOLUME = 0.01` m³（1–10 L）。`Cube.ts:77-78`。

材料 density 默认 Range：`0.8 – 27000` kg/m³（`Material.ts:95`）。

---

## 1. 共享世界状态（每屏一份 Model）

`DensityBuoyancyModel`：

| 量 | 值 | 证据 |
|---|---|---|
| gravity | Earth，`gEarth` 默认 **9.8** m/s² | QueryParameters + Gravity.EARTH |
| fluid | 仅水 `justWater`，ρ = **1000** kg/m³，μ = 8.9e-4 | Intro/Compare/Mystery options |
| poolBounds | 宽 0.9 m，深 0.4 m，体积 0.15 m³ → 高 ≈ 0.417 m | Model:35-43 |
| 期望初始池体积 | 0.1 m³（含排水） | Constants.DESIRED_STARTING_POOL_VOLUME |
| usePoolScale | **false**（三屏都关） | 各 Density*Model |
| 隐形屏障 | 默认 `Bounds3(-0.875, -4, …)` 随右侧面板左沿调整 | Model + ScreenView |
| 地面 | y=0，不可移动 | model.md + groundBody |
| velocity 上限 | 5 m/s | model.md |
| 空气浮力 | 忽略 | model.md |
| 液面 | 永远水平，瞬时让开 | model.md |

`availableMasses` vs `visibleMasses`：所有块预创建；不可见块 `internalVisibleProperty=false`，不进渲染。

---

## 2. Intro 状态

`DensityIntroModel.ts`

| 字段 | 默认 | 说明 |
|---|---|---|
| `modeProperty` | `TwoBlockMode.ONE_BLOCK` | 切 TWO_BLOCKS 时 B.`internalVisibleProperty=true` |
| `blockA` | Wood，mass **2** kg，pos **(-0.2, 0.2)**，tag OBJECT_A（标签 "A"） | `Cube.createWithMass` → V = 2/400 = **0.005 m³** |
| `blockB` | Aluminum，mass **13.5** kg，pos **(0.2, 0.2)**，tag OBJECT_B（"B"），初始 visible=false | V = 13.5/2700 = **0.005 m³** |
| 可选材料 | `SIMPLE_MASS_MATERIALS` + CUSTOM | Styrofoam, Wood, Ice, PVC, Brick, Aluminum, Custom |

两块 **各自独立材料**。Two Blocks 不是质量和体积相加，也没有 total density。密度数轴同时画 A 与（若可见）B。

Reset：`modeProperty.reset()` 然后 `super.reset()`（块回默认）。`DensityIntroModel.ts:87-92`。

Intro 右侧 `maxCustomMass: 10`（`DensityIntroScreenView.ts:47`）。默认 NumberControl：minMass 0.1，maxMass 27，体积 1–10 L，Custom minMass 0.5。具名材料质量范围 = clamp(ρ×Vrange, minMass, maxMass)。

---

## 3. Compare 状态

`CompareBlockSetModel` + `DensityCompareModel`。

### 3.1 模式

`BlockSet`：`SAME_MASS` | `SAME_VOLUME` | `SAME_DENSITY`。默认 **SAME_MASS**。  
三套立方体全部预创建在 `blockSetToMassesMap`，切模式只改 visibility。**切模式保留各套内部状态**（直到 Reset）。

### 3.2 锁定控件（作用到当前套全部 4 块）

| 属性 | 默认 | 范围 | 单位 |
|---|---|---|---|
| `massProperty`（Same Mass） | **5** | 1–10 | kg |
| `volumeProperty`（Same Volume） | **0.005** | 0.001–0.01 | m³ |
| `densityProperty`（Same Density） | **500**（Density 覆盖；基类默认 400） | **100–2000** | kg/m³ |

Density 覆盖：`sameDensityValue: 500`, `sameDensityRange: new Range(100, 2000)`（`DensityCompareModel.ts:31-32`）。

### 3.3 四块配置 `cubesData`（按数组下标 0–3）

颜色：黄 / 蓝 / 绿 / 红（`compareYellow/Blue/Green/RedColorProperty`）。

**Same Mass（全 5 kg）**

| 下标 | tag | volume m³ | 派生 density |
|---|---|---|---|
| 0 黄 | B | 0.01 | 500 |
| 1 蓝 | A | 0.005 | 1000 |
| 2 绿 | C | 0.0025 | 2000 |
| 3 红 | D | 0.00125 | 4000 |

摆放：左 [0,1]，右 [2,3]。

**Same Volume（全 0.005 m³）**

| 下标 | tag | mass kg | 派生 density |
|---|---|---|---|
| 0 黄 | A | 8 | 1600 |
| 1 蓝 | C | 6 | 1200 |
| 2 绿 | D | 4 | 800 |
| 3 红 | B | 2 | 400 |

摆放：左 [3,0]，右 [1,2]。

**Same Density（全 500 kg/m³）**

| 下标 | tag | volume m³ | 派生 mass kg |
|---|---|---|---|
| 0 黄 | B | 0.006 | 3.0 |
| 1 蓝 | A | 0.004 | 2.0 |
| 2 绿 | C | 0.002 | 1.0 |
| 3 红 | D | 0.001 | 0.5 |

摆放：左 [0,1]，右 [2,3]。

约束联动（`CompareBlockSetModel.ts`）：

- Same Mass：改锁定 mass → 每块 `customMaterial.density = mass / 该块volume`（体积不变）。
- Same Volume：改锁定 volume → `updateSize` + `density = cubeData.sameVolumeMass / volume`（**各块质量保持 cubesData 初值**）。
- Same Density：改锁定 density → 每块 `customMaterial.density = density`（体积不变 → 质量变）。

Density 的 `initialMaterials: []`，故 Compare 块走 Custom 着色（底色随密度明暗）。材料 Property `phetioReadOnly: true`。

用户 **不能** 在 Compare 为单块选不同具名材料。四块始终受当前 BlockSet 约束。

Reset：三个锁定 Property + 所有块 + 模式回 SAME_MASS + 重新摆放。

---

## 4. Mystery 状态

`DensityMysteryModel`。`initialMode = SET_1`。

### 4.1 公共块选项

`adjustVolumeOnMassChanged: true`（改质量时体积变）。可选材料含 SIMPLE + Steel + Copper + Platinum + Custom。学生 UI **不开放这些编辑**（Mystery 无材料面板）；mass 标签默认隐藏。

### 4.2 Set 1（createWithVolume）

| tag | volume m³ | density | 颜色 |
|---|---|---|---|
| 1D | 0.005 | WATER 1000 | red |
| 1B | 0.001 | WOOD 400 | blue |
| 1E | 0.007 | WOOD 400 | green |
| 1C | 0.001 | GOLD 19320 | yellow |
| 1A | 0.0055 | DIAMOND 3510 | purple |

堆叠：左 [1B, 1A] = masses[1], masses[4]；右 [1E, 1C, 1D] = [2,3,0]。

### 4.3 Set 2

| tag | 创建方式 | mass 或 volume | density | 颜色 |
|---|---|---|---|---|
| 2D | mass 18 | 18 kg | **4500**（Ti） | pink |
| 2A | mass 18 | 18 kg | **11340**（≠ LEAD 11342） | orange |
| 2E | volume 0.005 | — | COPPER 8960 | light purple |
| 2C | mass 2.7 | 2.7 kg | **2700** | light green |
| 2B | mass 10.8 | 10.8 kg | **2700** | brown |

堆叠同 Set 1 模式：左 [1,4]，右 [2,3,0]。

### 4.4 Set 3

| tag | mass kg | density | 颜色 |
|---|---|---|---|
| 3E | 6 | 950 HUMAN | white |
| 3B | 6 | 1000 WATER | gray |
| 3D | 2 | 400 WOOD | mustard |
| 3C | 23.4 | 7800 STEEL | peach |
| 3A | 2.85 | 950 HUMAN | maroon |

### 4.5 Random

- 从 `Material.DENSITY_MYSTERY_SCREEN_MATERIALS`（13 种）洗牌取 5 个密度。
- 从 15 个 ColorProperty 洗牌取 5 色。
- 体积：从 {1,2,3,4,5,6} L 抽 3 个 + 从 {7,8,9,10} L 抽 2 个，再 `sort()`。
- tag 顺序 `[C, D, E, A, B]`。
- 堆叠：左 [A,B] = masses[3,4]；右 [C,D,E] = [0,1,2]。
- Refresh：`regenerate(RANDOM)` 重新随机密度/颜色/体积并重摆。
- **Reset All 也会 `regenerate(RANDOM)`**，即使当前不在 Random（`DensityMysteryModel.ts:320-325`）。

### 4.6 Scale

固定台秤，`DisplayType.KILOGRAMS`，`canMove: false`，位置随隐形屏障：`(-0.75 + bounds.minX + 0.875, -SCALE_BASE_BOUNDS.minY)`。

### 4.7 Density Table 可见性

Accordion `expandedDefaultValue: false`。Reset 时 `densityTableAccordionBox.reset()` → 回到折叠。

---

## 5. Preferences（全局）

| 键 | 默认 | Density 是否露出 |
|---|---|---|
| `volumeUnits` | `'liters'`（也可 `'decimetersCubed'`） | 是 |
| `percentSubmergedVisible` | query 默认 true | **否**（`packageJSON.name !== 'density'` 才 instrument） |

无独立 sound / 无障碍开关（sound 由 joist 通用 Preferences 管）。
