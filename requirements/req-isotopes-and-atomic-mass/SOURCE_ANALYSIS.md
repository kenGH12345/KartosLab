# Isotopes and Atomic Mass — Phase 0 Source Analysis

> Local sim source: `phet sourses/isotopes-and-atomic-mass-main/isotopes-and-atomic-mass-main`  
> Critical shared lib: **`shred`** (`https://github.com/phetsims/shred`) — **not vendored in local zip**; data & nucleus/periodic-table live here  
> Official: https://github.com/phetsims/isotopes-and-atomic-mass  
> Visual: https://phet.colorado.edu/sims/html/isotopes-and-atomic-mass/latest/isotopes-and-atomic-mass_all.html  
> Analyzed: 2026-09-18  
> Sim version (package.json): `1.3.0-dev.0` / dependencies.json note: `1.2.0-dev.2`

---

## Done

- [x] Screen / Model / View architecture mapped from local TypeScript
- [x] Shared `shred` data path traced (`AtomData.ts` → `AtomInfoUtils`)
- [x] Make (Isotopes) + Mix (Mixtures) interaction chains documented
- [x] Nature's Mix / Clear / Reset / mass display / abundance / pie charts documented
- [x] Nucleus layout + mixture packing + canvas performance strategy documented
- [x] Asset inventory (sim mipmaps + program-drawn shred particles)
- [x] Viewport / layout constants extracted
- [x] **「More」澄清**：当前 HTML5 源码**无**名为 More 的控件；大批量添加 = Slider 交互模式
- [x] P0 / P1 / P2 prioritization

## Remaining

- Phase 1+：Shared Element/Isotope data model → Make/Mix models → View → Visual QA → Tests/APK  
- **阻塞依赖**：本地需补齐 `shred` 源码（建议 clone/unzip 到 `phet sourses/shred-main`）后再做数据移植

## P0 / P1 / P2（按源码）

| Priority | Items |
|---|---|
| **P0** | 两 Screen；共享 `AtomData`/`AtomInfoUtils` 数据；元素选择（周期表）；中子拖放；同位素身份；mass number / atomic mass 切换；stable/unstable + nucleus jump；自然丰度饼图；Mix 拖放；Mixture counts；Slider 数值控制（0–100，**即「大批量」入口**）；Percent Composition；Average Atomic Mass；Nature's Mix / My Mix；Clear（橡皮）；Reset All |
| **P1** | layoutBounds `768×464` 对齐；scale.png 秤；电子云；周期表几何/选中色；bucket 位置；黑色 test chamber；pie/average 面板；isotope 颜色表；Canvas 大批量绘制 |
| **P2** | a11y/PDOM；sound；dynamic locale；pan/zoom；accordion 微样式；Projector 色型 |

## Tests / Analyze / APK

N/A at Phase 0（分析 only）。原版仓库**无** sim 级 unit-test 目录。

## Known Differences vs User Brief（以源码为准）

| Brief 假设 | 实际 PhET 源码 |
|---|---|
| Screen 名 Make / Mix Isotopes | 字符串键为 **`isotopes` / `mixtures`**（UI 标题 “Isotopes” / “Mixtures”）；assets 图标文件名才是 make-/mix-isotopes |
| 存在名为 **More** 的控件 | **不存在**。大批量 = `interactivityMode = 'slidersAndSmallAtoms'` + `NumericalIsotopeQuantityControl`（CAPACITY **100**） |
| Viewport 1024×618 | 本 sim **显式** `layoutBounds: Bounds2(0,0,768,464)` |
| 手写 isotope 表 | 必须来自 `shred/js/AtomData.ts` 的 `ISOTOPE_INFO_TABLE` / `stableElementTable` / `standardMassTable` |
| Stable = 半衰期 > 10e9 y（model.md） | 运行时判定是 **`stableElementTable[Z].includes(N)`**（表驱动）；model.md 是设计说明 |
| Nature's Mix 平均质量 = chamber 加权 | Nature's Mix **读出**用 `AtomInfoUtils.getStandardAtomicMass(Z)`，饼图标签用自然丰度 |

---

## 1. 原版一共有几个 Screen / Tab

**2 个**（`js/isotopes-and-atomic-mass-main.ts`）：

```
Sim
 ├── IsotopesScreen   → IsotopesModel + IsotopesScreenView   // Make Isotopes
 └── MixturesScreen   → MixturesModel + MixturesScreenView   // Mix Isotopes
```

---

## 2. 每个 Screen 的职责

| Screen | 字符串 | 职责 |
|---|---|---|
| **Isotopes** | `isotopes` | 选元素（Z≤10），往原子核拖中子构造同位素；看质量数/原子质量、符号、自然丰度、Stable/Unstable |
| **Mixtures** | `mixtures` | 选元素（Z≤18），用稳定同位素混合；看百分组成、平均原子质量；My Mix ↔ Nature's Mix |

`doc/model.md`：Screen1 限 **10** 元素；Screen2 限 **18** 元素。

---

## 3. 每个 Screen 的 Model

### IsotopesModel (`js/isotopes/model/IsotopesModel.ts`)

| 字段 | 含义 |
|---|---|
| `selectedElementProtonCountProperty` | 当前元素 Z，默认 **1**（H） |
| `particleAtom: ParticleAtom` | shred：质子/中子/电子粒子管理 |
| `neutrons` / `protons` / `electrons` | ObservableArray\<Particle\> |
| `neutronBucket: SphereBucket` | 桶内中子，默认 **4** 颗 |
| `nucleusStableProperty` | Derived：`AtomInfoUtils.isStable(Z, N)` |
| `step(dt)` | 粒子动画 + 不稳定核 jump |

关键常量：

- `DEFAULT_NUM_NEUTRONS_IN_BUCKET = 4`
- `NUCLEON_CAPTURE_RADIUS = 100`（模型单位 ≈ 像素）
- `NEUTRON_BUCKET_POSITION = (-220, -180)`
- `BUCKET_SIZE = 130×60`
- Jump：`NUCLEUS_JUMP_PERIOD = 0.1s`，`MAX_NUCLEUS_JUMP = NUCLEON_RADIUS * 0.5`

### MixturesModel (`js/mixtures/model/MixturesModel.ts`)

| 字段 | 含义 |
|---|---|
| `selectedElementProtonCountProperty` | Z，range **1–18**，默认 1 |
| `interactivityModeProperty` | `'bucketsAndLargeAtoms'` \| `'slidersAndSmallAtoms'` |
| `showingNaturesMixProperty` | false = My Mix，true = Nature's Mix |
| `possibleIsotopesProperty` | 当前元素**稳定**同位素列表（按原子质量升序） |
| `testChamber: IsotopeTestChamber` | 黑色混合室 + `averageAtomicMassProperty` |
| `bucketList` / `isotopesList` / `numericalControllerList` | 桶 / 可动同位素 / 数值控制器 |
| `naturesMixAtoms` | 预分配 **1000+4** 个小粒子池 |
| `savedParticleStates[Z][mode]` | 按元素+交互模式保存用户混合 |

常量：

- `LARGE_ISOTOPE_RADIUS = 10`，`SMALL_ISOTOPE_RADIUS = 4`
- `NUM_LARGE_ISOTOPES_PER_BUCKET = 10`
- `NUM_NATURES_MIX_ATOMS = 1000`
- Slider 容量：`NumericalIsotopeQuantityControl.CAPACITY = 100`

---

## 4. 每个 Screen 的 View

### IsotopesScreenView — `layoutBounds 768×464`

- MVT：`createSinglePointScaleInvertedYMapping(ZERO, (0.4W, 0.49H), scale=1)`
- `AtomScaleNode`（`scale.png` + Mass Number / Atomic Mass radio）
- `InteractiveIsotopeNode`（原子 + 中子桶 + 名称/Stable 标签）
- `ExpandedPeriodicTableNode(..., interactiveMax=10)` scale 0.65
- `ParticleCountDisplay`（legend）
- Accordion：`SymbolNode`、`TwoItemPieChartNode`（默认 **collapsed**）
- `ResetAllButton` scale 0.85 → `model.reset()` + scale/accordion reset

### MixturesScreenView — 同 `768×464`

- MVT 中心：`(0.32W, 0.33H)`
- 黑色 `Rectangle` = test chamber
- BucketHole / BucketFront + `BucketDragListener`；大同位素 `ParticleView`
- 小同位素 / Nature's Mix：`IsotopeCanvasNode`（Canvas 性能路径）
- `ExpandedPeriodicTableNode(..., MAX_ATOMIC_NUMBER=18)` scale 0.55
- Accordion：Percent Composition / Average Atomic Mass
- `EraserButton` → `clearTestChamber()`（Nature's Mix 时隐藏）
- Radio：My Mix / Nature's Mix；矩形 radio：桶模式 / Slider 模式
- `step()`：每帧最多更新一次 pie chart（`updatePieChart` 标志）

---

## 5. Screen 之间的共享 Model / Component

| 共享层 | 内容 |
|---|---|
| **shred 数据** | `AtomData` / `AtomInfoUtils` / `AtomNameUtils` / `AtomConfig` / `Particle` / `ParticleAtom` |
| **shred 视图** | `ExpandedPeriodicTableNode`、`ParticleView`、`SymbolNode`、`ParticleCountDisplay`、`BucketDragListener`、电子云等 |
| **本 sim common** | `IAAMConstants.ACCORDION_BOX_OPTIONS`、`PieChartNode` |
| **运行时状态** | **不共享** — 两 Screen 独立 Model 实例 |

---

## 6–10. 数据从哪里来（全部在 shred）

### Element

- 符号/名称：`AtomNameUtils.getSymbol(Z)` / `getName(Z)`
- 可选范围：Screen1 `interactiveMax=10`；Screen2 `MAX_ATOMIC_NUMBER=18`
- 默认同位素中子数：`numNeutronsInMostStableIsotope[Z]`（H→**0** → Hydrogen-1）

### Isotope / Atomic Mass / Abundance / Stable

权威文件：`shred/js/AtomData.ts`

| 表 | 用途 |
|---|---|
| `ISOTOPE_INFO_TABLE` | `Map<Z, Map<massNumber, {atomicMass, abundance}>>`；注释：NIST + 手工后处理；**仅前 18 元素**完整同位素表 |
| `stableElementTable[Z]` | 稳定中子数列表 → `AtomInfoUtils.isStable(Z,N)` |
| `numNeutronsInMostStableIsotope[Z]` | 选元素后默认核中子数 |
| `standardMassTable[Z]` | Nature's Mix 平均原子质量读出 |
| `TRACE_ABUNDANCE = 1e-12` | 丰度标为 “trace” |

示例（Hydrogen，源码原值）：

| A | atomicMass | abundance |
|---|---|---|
| 1 | 1.00782503207 | 0.999885 |
| 2 | 2.0141017778 | 0.000115 |
| 3 | 3.0160492777 | TRACE |

`getNaturalAbundance(isotope, numDecimalPlaces)`：从表读 abundance，再 `toFixedNumber(..., places)`。

不稳定同位素：`getIsotopeAtomicMass` 对不在表内的配置返回 **-1**（UI 显示 `--`）。

---

## 11. Make Isotopes 完整交互链

```
用户点周期表格子
  → selectedElementProtonCountProperty = Z
  → initializeParticles(Z):
       clear atom/bucket
       protons = Z, electrons = Z
       neutrons_in_nucleus = getNumNeutronsInMostCommonIsotope(Z)
       bucket += 4 neutrons
       moveAllParticlesToDestination()  // 无飞入动画
  → particleAtom 派生 massNumber / 名称 / stable / abundance / Symbol

用户拖中子（仅 neutron pickable）
  → isDragging=true → 从 container(atom|bucket) removeParticle
  → isDragging=false → placeNucleon:
       dist(atom) < 100 → addParticle(atom) → reconfigureNucleus
       else → bucket.addParticleNearestOpen(animate=true)

不稳定
  → nucleusStableProperty=false
  → step: 每 0.1s 在预设角度/距离间切换 nucleusOffset（shake）
  → 标签 Stable / Unstable（shred 字符串）

Reset
  → selectedElement 复位；若中子数≠默认最常见同位素则 re-init
  → AtomScaleNode.displayMode 复位；accordion expanded 复位
```

**禁止**按钮加减中子冒充拖放。

---

## 12. Mix Isotopes 完整交互链

```
选元素 Z
  → updatePossibleIsotopesList = getStableIsotopesOfElement(Z) 按质量排序
  → 若 My Mix：save 旧状态 → clear → restore 该 Z+mode 保存态 → setControllers → fillBuckets
  → 若 Nature's Mix：showNaturesMix

【桶模式 bucketsAndLargeAtoms】默认
  → 每同位素一个 MonoIsotopeBucket；总数目标 = 10/同位素（室+桶合计逻辑见 fillBuckets）
  → 拖 PositionableAtom：over chamber → addParticle + adjustForOverlap；否则回桶
  → ParticleView 独立 Node

【Slider 模式 slidersAndSmallAtoms】← Brief「More」对应能力
  → NumericalIsotopeQuantityControl per isotope；quantity 0..100
  → ControlIsotope：HSlider + ±箭头 + 数字读出 → setIsotopeQuantity
  → 粒子用 IsotopeCanvasNode 聚合绘制（非每粒子 Widget）

Clear（橡皮）
  → 仅 My Mix；桶模式 refill；Slider 置 0；删 saved state

Nature's Mix / My Mix radio
  → 见 §13
```

---

## 13. Nature's Mix 的实现

`MixturesModel.showNaturesMix`：

1. Clear chamber + deactivate pool  
2. 稳定同位素按自然丰度**降序**排序（保证痕量后画、可见）  
3. `numberToActivate = roundSymmetric(1000 * abundance_5digits)`；若为 0 → **强制 1**（设计要求）  
4. 从 `naturesMixAtoms` 池取粒子，随机位置，`bulkAddIsotopesToChamber`  
5. `naturesMixAtomsUpdated.emit()` → Canvas 刷新  
6. 仍显示空桶（仅作同位素图例，不可用橡皮 / 交互模式切换）

切换回 My Mix：deactivate natures atoms → restore 保存的用户混合。

Average Atomic Mass **显示**在 Nature's Mix：`getStandardAtomicMass(Z)`（非 chamber 瞬时平均）。

Percent 标签在 Nature's Mix：`getNaturalAbundance(..., NUMBER_DECIMALS+2)`，小数位 **4**；My Mix 用 chamber 比例，小数位 **1**。

---

## 14. 「More」的实现（源码澄清）

| 结论 | 说明 |
|---|---|
| **无 More 按钮 / More dialog** | 全仓库字符串与代码无 “More” UI |
| 等价能力 | `interactivityModeProperty → 'slidersAndSmallAtoms'` |
| UI | `ControlIsotope`：读出 + 左右箭头 + HSlider(0..100) |
| Model | `quantityProperty` → `setIsotopeQuantity` 写入 **同一** `testChamber` / `isotopesList` |
| 上限 | **100** / 同位素（`CAPACITY`） |

迁移时：**不要自创 MoreDialog**；实现桶/滑块双模式即可。

---

## 15. Percent Composition 计算

Model：`IsotopeTestChamber.getIsotopeProportion(config) = count_i / total`（total=0 → 0）。

View（`IsotopeProportionsPieChart`）：

- My Mix：proportion = chamber；百分比 `toFixedNumber(..., 1)`  
- Nature's Mix：proportion = natural abundance；`toFixedNumber(..., 4)`  
- 空室：虚线空圆；有粒子：按 `possibleIsotopes` 切片着色 `getIsotopeColor`  
- 起始角：`Math.PI - (lightestProportion * Math.PI)`  
- 每帧最多 `update()` 一次（性能）

Make 屏丰度饼图（`TwoItemPieChartNode`）是 **This vs Other** 两片，不是 Mix 的多同位素饼。

---

## 16. Average Atomic Mass 计算

```
My Mix:
  average = Σ(isotope.getAtomicMass()) / n     // IsotopeTestChamber lengthProperty link
  n=0 → 0；读出隐藏

Nature's Mix 读出:
  AtomInfoUtils.getStandardAtomicMass(Z)

显示精度: toFixed(..., 5) + " amu"
刻度: 轻/重同位素 tick；span = max(2, Δm)*1.2
```

`AtomConfig.getAtomicMass()` → 查 `ISOTOPE_INFO_TABLE`。

---

## 17–19. Mass Number / Atomic Mass 切换

`AtomScaleNode.displayModeProperty: 'massNumber' | 'atomicMass'`（默认 massNumber）。

| 模式 | 显示 |
|---|---|
| massNumber | 整数 `atom.massNumberProperty` |
| atomicMass | `toFixedNumber(getIsotopeAtomicMass(), 5)`；≤0 显示 `--` |

**同一** `displayModeProperty` 驱动读出 formatter；不是两个独立数字变量。Reset 时 `displayModeProperty.reset()`。

---

## 18. Neutron Drag 行为

| 项 | 源码 |
|---|---|
| 可拖 | 仅 neutron（proton/electron 不可 pick） |
| 抓取 | `isDraggingProperty` → 离开 atom 或 bucket |
| 放置 | `dist < NUCLEON_CAPTURE_RADIUS(100)` → 核；否则回桶 `addParticleNearestOpen(..., true)` |
| 桶拖整桶 | `BucketDragListener`（shred） |
| 空桶 | `pickable = particleCount > 0` |
| 动画 | Particle destination 插值（`Particle.step`） |

---

## 19. Isotope Drag 行为（Mix）

| 项 | 源码 |
|---|---|
| 大同位素 | `PositionableAtom` + `ParticleView`；拖入 chamber 矩形则留下，否则回对应 MonoIsotopeBucket |
| 重叠 | `adjustForOverlap()` 力推算法；assert total ≤ **100**（大同位素路径） |
| 小同位素 | Slider 增减；Canvas 画圆；随机位置 `generateRandomPosition` |
| multitouch | 切换元素/模式/Nature 时 `interruptSubtreeInput` |

---

## 20. Nucleus 排布算法

`ParticleAtom.reconfigureNucleus()`（shred）：

1. 质子/中子交错排进 `nucleons[]`  
2. n=1 居中；n=2 对称；n=3 三角；n=4 钻石叠层  
3. n≥5：螺旋层 `placementRadius += nucleonRadius * scaleFactor / level`，`zLayer` 递增  
4. 不稳定时整体加 `nucleusOffsetProperty`（IsotopesModel.step 驱动）

半径：`ShredConstants.NUCLEON_RADIUS = 10`。

电子：`IsotopeElectronCloudView`（程序绘制云，非 PNG）。

---

## 21. Mixture particle 排布算法

| 模式 | 策略 |
|---|---|
| 大同位素 drop | 边界夹紧 BUFFER=1；`adjustForOverlap` 斥力迭代 ≤10000 |
| Nature's / Slider 小粒子 | 随机撒点；**不做**大规模 overlap 调整；Canvas 批量画 |

Test chamber 模型矩形：`Dimension2(450, 280)` 中心原点 → `Rectangle(-225,-140,450,280)`。

---

## 22. Reset 生命周期

### Isotopes

`IsotopesModel.reset`：`selectedElementProtonCountProperty.reset()`；若当前中子数≠最常见同位素则 `initializeParticles`。  
View：scale displayMode、Symbol/Abundance accordion expanded reset。

### Mixtures

`MixturesModel.reset`：清空 `savedParticleStates`；清 chamber；`interactivityMode` / `showingNaturesMix` reset；`selectedElement` reset；必要时 refill buckets。  
View：composition / average accordion reset。

两 Screen **互不影响**。

---

## 23. Screen 生命周期

- Joist `Screen`：各 Screen 自有 model factory + view factory  
- `MixturesScreenView.step` / `IsotopesModel.step`：由 Sim 时钟驱动  
- 切换 Screen：状态保留在各自 Model（标准 Joist 行为）  
- 无跨 Screen 同步

---

## 24. Asset 清单

### 运行时 mipmaps（必须迁入 Flutter）

| Source | 用途 |
|---|---|
| `mipmaps/scale.png` | Make 屏天平 |
| `mipmaps/isotopesIcon.png` | Home / Screen 图标 |
| `mipmaps/mixturesIcon.png` | Home / Screen 图标 |

### assets/（设计源 / 截图，非运行时必须）

- `*.ai`：图标与秤源文件  
- `*-screenshot*.png`：宣传/对照截图  

### 程序绘制（Substituted 允许 = 0 的「原版即绘制」）

- Proton / Neutron / Electron 球体（shred `ParticleView` / 径向高光）  
- Electron cloud、Buckets（BucketFront/Hole）、Pie charts、周期表按钮、同位素色球（Canvas）  
- Reset All → Flutter 侧统一 `KratosResetAllButton`

**禁止** Material Icons / 网图替代 scale.png 或粒子。

---

## 25. 原版 Simulation viewport

```ts
// IsotopesScreenView & MixturesScreenView
layoutBounds: new Bounds2( 0, 0, 768, 464 )
```

注释明确：**不要改**（phet-io 兼容）。

Flutter Visual QA 基准应优先 **768×464**（或同比例 letterbox），**不要**默认套 1024×618，除非工程外壳强制再缩放。

---

## 26. 原版 layout constants（摘要）

| 常量 | 值 |
|---|---|
| layoutBounds | 768 × 464 |
| Make MVT center | (0.4W, 0.49H) |
| Mix MVT center | (0.32W, 0.33H) |
| Neutron bucket model pos | (−220, −180)，size 130×60 |
| Mix bucket y | −250；slider y −238 |
| Test chamber | 450×280 model units |
| Scale image width | WEIGH_SCALE_WIDTH = 275 |
| Periodic Make scale | 0.65；Mix 0.55 |
| Reset All | right/bottom −10，scale 0.85 |
| Accordion fill | `rgb(254,255,153)` |
| Selected cell | `#FA8072` |
| Isotope colors | purple / green / orangered / teal 循环 |

---

## 27. 动画 / Emitter / Timer

| 机制 | 用途 |
|---|---|
| `Particle.step` / `PositionableAtom.step` | 飞向 destination |
| `IsotopesModel.step` | 不稳定核 jump |
| `MixturesModel.naturesMixAtomsUpdated` Emitter | 批量通知 Canvas |
| View `step` + `updatePieChart` flag | 饼图节流 |
| 无独立 setInterval UI timer | 走 Sim 帧步进 |

---

## 28. 已有 PhET 测试

- 本地 `isotopes-and-atomic-mass`：**无** `test/` / qunit 用例  
- 依赖库 shred 可能有独立测试，本 Phase 未克隆  
- Flutter 侧需自建 `test/isotopes_and_atomic_mass/`（见任务书 §44–51）

---

## 推荐 Flutter 工程映射（Phase 1+，尚未编码）

```
lib/isotopes_and_atomic_mass/
  data/          ← 从 shred AtomData 移植（禁止手写简化表）
  model/         ← make_isotopes_model / mixtures_model / isotope_test_chamber ...
  view/          ← home + 两 screen
  widgets/       ← periodic_table / buckets / panels ...
  painter/       ← nucleons / canvas isotopes / pie ...
```

共享数据层必须被 Make + Mix **共同引用**。

---

## Phase 0 验收结论

| 项 | 状态 |
|---|---|
| 架构与双 Screen | ✅ |
| 数据源定位到 shred AtomData | ✅（本地缺 shred 副本 → Phase1 前补齐） |
| 交互链 / Nature / Clear / Reset | ✅ |
| 「More」澄清 | ✅ = Slider 模式，非独立控件 |
| Viewport 768×464 | ✅ |
| Assets | ✅ 3 运行时 PNG + 程序绘制 |
| P0 清单 | ✅ 见上表 |
| READY | ❌ 禁止（尚未实现） |

**下一步（Phase 1）**：补齐本地 `shred`，移植 `AtomData`/`AtomInfoUtils` 为共享 Dart 数据层；**仍不搭完整 UI**。
