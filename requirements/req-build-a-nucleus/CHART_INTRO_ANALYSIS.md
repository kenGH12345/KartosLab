# Chart Intro Screen 分析

> 需求：`req-build-a-nucleus` · Phase 2  
> 日期：2026-08-31  
> 范围：只分析，不写 Flutter Chart Intro 代码  
> 诚实标记：`[已确认]` / `[推测]` / `[待确认]` / `[原版已知问题]`

---

## 0. 结论先行

1. Chart Intro **不是** Decay Screen 的第二份拷贝。两屏共享 `BANModel` / `BANScreenView` / 核素表 / 核子生成器，但 **主核模型、捕获区、衰变动画、图表、上限、UI 壳** 全部不同。[已确认]
2. Chart Intro 的主核是 `ShellModelNucleus`（`ParticleAtom` 子类），核子落在 3 条能级上；顶部还有一个 **不可交互的 mini-atom**（普通 `ParticleAtom`）。Decay 的圆形簇核只出现在这个 mini-atom 上。[已确认 `ChartIntroModel.ts`、`doc/model.md`]
3. 核素图 **X = 中子数，Y = 质子数**。格子不是满矩形 11×13，而是稀疏表 `BANModel.POPULATED_CELLS`。格子颜色来自 shred 核素表的 **最可能衰变**（现已按百分比降序）。[已确认]
4. 核素图 **不能点击、没有 hover**。当前核素只由壳层里的 p/n 计数驱动。[已确认 `NuclideChartCell.ts` 无输入监听]
5. 壳层衰变 **不是** Decay 的飞出粒子：壳层核子 1 秒淡入/淡出；飞出只发生在 mini-atom。[已确认 `ChartIntroScreenView.emitNucleon` / `fadeOutShellNucleon`]
6. 原版 CT 在 Chart Intro 上反复出现 **listener dispose / Property 重入**。Flutter **只保持可观察行为，不复制这套双 ParticleAtom 同步与 dispose 路径**。[已确认 issue #220]

**实现状态（2026-08-31）：** Chart Intro 已落地（2A–2H-3）。§21 为 Phase 2I-1 最终视觉差异，不以「完全一模一样」作结。

---

## 1. Chart Intro Screen 总览

### 1.1 原项目是什么

PhET `build-a-nucleus` 的 **第 2 个 joist Screen**。

| 项 | 内容 | 标记 |
|---|---|---|
| 入口 | `new Sim(..., [new DecayScreen(), new ChartIntroScreen()])` | [已确认 `js/build-a-nucleus-main.ts`] |
| 屏名 | `BuildANucleusStrings.screen.chartIntro` → "Chart Intro" | [已确认 `ChartIntroScreen.ts`] |
| 图标 | `CompleteNuclideChartIconNode`（迷你核素图） | [已确认] |
| 上限 | **10 质子 / 12 中子**（Ne-22） | [已确认 `BANConstants.CHART_MAX_*`] |
| 主交互 | 在核壳层能级上增减核子，观察部分核素图、周期表、衰变方程 | [已确认 `doc/model.md`] |
| 完整核素图 | 按钮打开 Dialog，显示 `images/fullNuclideChart.png` + Calgary 外链 | [已确认 `FullChartTextButton.ts`] |

官方教学定义：在核壳层模型里改核子数，在部分核素图上看核素位置与最可能衰变；可 zoom 后按 Decay 按钮走一步。[已确认教师指南 + `doc/model.md`]

### 1.2 当前 KARTOSLAB 现状

| 项 | 现状 | 标记 |
|---|---|---|
| Decay Screen | `lib/chemistry/build_a_nucleus/` 已完成并挂到 Home | [已确认] |
| Chart Intro 代码 | `lib/chemistry/build_a_nucleus/chart_intro/` + `screens/chart_intro_screen.dart` | [已确认] |
| Home 入口 | 化学 → 原子核 →「构建原子核」→ `BuildANucleusScreen`（仅 Decay） | [已确认 `home_screen.dart`] |
| 核素数据 | `NuclideRepository` + `assets/data/nuclide_table.json`（shred ENSDF 2022） | [已确认] |
| 多屏先例 | `ColorVisionHome` / `ForcesHome` 用 `KratosTabbedScreen` | [已确认] |

### 1.3 不要默认套用的 Decay 假设

| Decay 已有能力 | Chart Intro 是否同样用 | 依据 |
|---|---|---|
| 圆形核 + `NucleusLayout` | **否**。主核是能级阵列；圆形核只在 mini-atom | `ShellModelNucleus` vs `ParticleAtom` |
| 捕获半径 100 圆 | **否**。矩形捕获区 = 质子能级 **或** 中子能级 bounds | `ChartIntroScreenView.isNucleonInCaptureArea` |
| 五种衰变按钮面板 | **否**。zoom 场景只有一个「Decay」按钮，只打最可能衰变 | `NuclideChartAccordionBox` |
| 飞出 `MovingParticle` | **壳层不用。** 壳层淡入淡出；飞出只在 mini-atom | `fadeAnimation` 1s |
| Be-6 Hollywood 强制再射 2p | **Chart Intro 无此 override** | `ChartIntroScreenView.emitAlphaParticle` 只 fade 2p2n |
| 半衰期数轴 / 电子云 checkbox | **本屏没有这些控件** | `ChartIntroScreenView` 未添加 |
| `lib/common/chart` 折线/快照图 | **不能当核素图用** | 语义完全不同 |

---

## 2. Screen 结构

### 2.1 原版入口与构造

```
ChartIntroScreen
  model factory: () => new ChartIntroModel()
  view factory:  model => new ChartIntroScreenView(model)
```

[已确认 `ChartIntroScreen.ts`]

`ChartIntroModel` 调用：

```ts
super(CHART_MAX_NUMBER_OF_PROTONS, CHART_MAX_NUMBER_OF_NEUTRONS, new ShellModelNucleus())
```

即：共用 `BANModel`，但把 `particleAtom` 换成 `ShellModelNucleus`。[已确认]

### 2.2 原版布局（经验坐标，单位 CSS px）

`ChartIntroScreenView` 在 `BANScreenView` 之上叠加，不是 NineGrid。[已确认]

大致分区（坐标来自源码字面量，属原版固定布局）：

| 区域 | 内容 | 源码 |
|---|---|---|
| 顶部偏左 | mini-atom（`particleAtomNode` 缩放 0.75，中心约 `(SCREEN_VIEW_ATOM_CENTER_X, 87)`） | `ChartIntroScreenView` ctor |
| 顶部偏右 | 周期表 + 同位素符号 | `PeriodicTableAndIsotopeSymbol` |
| 顶部中 | 元素名 `elementNameText`（继承 BANScreenView） | 定位在生成器 `centerX` |
| 左上 | 核子计数面板 | `nucleonNumberPanel.left = layoutBounds.left + 20` |
| 中左 | 「Energy」竖排字 + 竖箭头；虚线连到 mini-atom | `energyText` / `ArrowNode` / dashed `Line` |
| 中部 | 质子能级（左）+ 中子能级（右，x 偏移 `LAYOUT_BOUNDS.width/4`） | `NucleonShellView`，原点 `(135, 245)` |
| 底部 | 核子生成器（继承 `NucleonCreatorsNode`） | `BANScreenView` |
| 右中 | Partial Nuclide Chart 手风琴 | 周期表下方 |
| 手风琴下 | partial/zoom Radio + Magic Numbers Checkbox + Full Chart 按钮 | 同上 |
| 右下 | Reset All（继承） | `BANScreenView` |

键盘帮助：`BasicActionsKeyboardHelpSection({ withCheckboxContent: true })`。没有自定义快捷键表。[已确认] 具体按键行为 [待确认 joist 默认]

### 2.3 生命周期

| 阶段 | 行为 | 标记 |
|---|---|---|
| 构造 | 两个 Screen 在 Sim 启动时都创建，**常驻**，切屏不销毁 | [已确认 joist 惯例 + implementation-notes「除粒子外不 dispose」] |
| 初次填充 | `phet.joist.sim.isConstructionCompleteProperty` 为 true 后 `populateAtom(chartIntroScreenProtons, chartIntroScreenNeutrons)` | [已确认] |
| step | joist `Sim.step` → `ChartIntroModel.step(dt)` | [已确认] |
| Reset | 清 magic / accordion / `BANModel.reset` / mini-atom / 再 populate 默认（含 query） | [已确认 `reset()`] |
| 切屏 | 模型不停；另一屏的 Undo 曾互相影响 | [已确认 issue「Undo button disappears on one screen when pressing buttons on the other」] |

**Flutter 差异（必须处理，不要学原版常驻）：**

当前工程一个 sim 是 `Navigator.push` 出的一个 Widget。弹出即 `dispose`。Decay 已用 `SimulationClock` + `State.dispose`。[已确认 `build_a_nucleus_screen.dart`]

Chart Intro 进入/退出会真正销毁 Ticker、Controller、粒子。这比原版更干净，也是应走的路。

### 2.4 SimulationClock / 持续 step

| 问题 | 结论 | 标记 |
|---|---|---|
| 原版有无连续 step | **有。** `BANModel.step` 推进所有 `particles`；`ChartIntroModel.step` 再推进 mini-atom 核子，以及「已离开 mini-atom、但不在 `particles` 里」的 outgoing | [已确认] |
| 有无播放/暂停 UI | **无** TimeControlBar | [已确认 全 view 清单] |
| 是否物理仿真 | **否。** 事件驱动补间 + 1 秒「does not form」计时（继承 `BANScreenView.step`） | [已确认] |
| Flutter 要不要 Clock | **要。** 飞入、归位、能级重排、淡入淡出、mini-atom 飞出、1 秒纠正都需要 dt | [推测：对标 Decay 已落地的 Clock 用法] |

淡入淡出是 twixt `Animation`（1s，LINEAR），挂到 `model.particleAnimations` 以便 Reset 取消。[已确认] twixt 由谁 step [推测：joist/sim 全局 stepper；`particleAnimations` 主要用于取消]

### 2.5 Screen dispose

原版：粒子 `disposeEmitter` → 删 `particleViewMap` → `particleView.dispose()`。其余 Node/Property **不 unlink**。[已确认 `implementation-notes.md`]

CT 在 Chart Intro 上炸的就是这条链，见 §11。

---

## 3. Model / State

### 3.1 类图（原版）

```
BANModel<ShellModelNucleus>
  particleAtom: ShellModelNucleus          // 主核 = 能级
  particles / incoming* / outgoing / userControlled*
  particleAnimations
  isStableProperty / nuclideExistsProperty
  protonNumberRange [0,10] / neutronNumberRange [0,12]

ChartIntroModel extends BANModel
  miniParticleAtom: ParticleAtom           // 顶部小核，不进 particles
  selectedNuclideChartProperty: 'partial' | 'zoom'
  decayEquationModel: DecayEquationModel
  static cellModelArray                    // 由 POPULATED_CELLS 生成

DecayEquationModel
  currentCellModelProperty
  finalProtonNumberProperty
  finalMassNumberProperty
```

[已确认 全部 model 文件]

### 3.2 字段分类

**业务状态（用户能改变、Reset 要清）：**

| 字段 | 含义 | 标记 |
|---|---|---|
| 壳层质子/中子计数 | `ShellModelNucleus` 内已入核核子 | [已确认] |
| 壳层座位占用 | `protonShellPositions` / `neutronShellPositions`（incoming 也会占座） | [已确认] |
| `selectedNuclideChartProperty` | `'partial'` \| `'zoom'` | [已确认] |
| `showMagicNumbersProperty` | 视图层 Boolean，Reset 要 reset | [已确认 在 View 不在 Model] |
| Accordion 展开状态 | sun AccordionBox，`nuclideChartAccordionBox.reset()` | [已确认] |
| Undo 快照 | zoom 场景 Decay 前的 `(oldProton, oldNeutron)` | [已确认 View 局部变量] |

**临时渲染 / 动画状态：**

| 字段 | 含义 | 标记 |
|---|---|---|
| incoming / userControlled / outgoing | 与 Decay 同族数组 | [已确认 BANModel] |
| 核子 x/y、destination、inputEnabled | 能级绑定后 `inputEnabled=false` | [已确认 `updateNucleonPositions`] |
| ParticleView.opacity | 淡入淡出 | [已确认] |
| `isMiniAtomConnected` | 衰变时断开双核同步 | [已确认 View 字段] |
| mini-atom 粒子 | **不在** `particles` | [已确认] |

**计算结果（派生，不要另存一份真值）：**

| 量 | 来源 | 标记 |
|---|---|---|
| 稳定 / 存在 | shred `AtomInfoUtils` ← 现有 `NuclideRepository` | [已确认] |
| 最可能衰变 + % | `getAvailableDecaysAndPercents` 排序后第一项 | [已确认] |
| 格子颜色 | stable / unknown / decayType.color | [已确认 `NuclideChartCellModel`] |
| 衰变方程 daughter | `p - decay.protonNumber`，`A - decay.massNumber` | [已确认 `DecayEquationModel`] |
| 周期表高亮 / 符号 | protonCount / massNumber | [已确认] |
| 核素图高亮格 | 当前 (n, p) 若 `doesExist` | [已确认 `NuclideChartNode`] |
| 能级填充色/线宽 | 该层核子数 / 容量 | [已确认 `NucleonShellView`] |
| 能级「绑定」 | `protonsLevelProperty` / `neutronsLevelProperty` | [已确认] |

### 3.3 DecayEquationModel 监听缺口

只 `massNumberProperty.link(...)`，**没有**监听 `protonCountProperty`。[已确认 `DecayEquationModel.ts`]

β 衰变质量数不变、质子数变。若 Property 同值不通知，方程会停在旧格子上。

- 记为 `[原版可疑行为]`：源码如此，运行时是否被别的质量数抖动掩盖 [待确认]
- Flutter：**同时监听 proton + neutron（或 proton + mass）**，不要复制这个缺口

### 3.4 Query 初始核

`chartIntroScreenProtons` / `chartIntroScreenNeutrons`，默认 0/0；必须是存在核素，否则回退 0/0。[已确认 `BANQueryParameters.ts`]

Flutter 无 query-string 先例。[推测] 默认空核即可；不要为对齐 URL 参数新做一套。

---

## 4. Chart 数据模型

### 4.1 核素图是什么

**稀疏格子图**，不是连续热图，也不是 `lib/common/chart` 那种折线/快照图。

每个格子 = 一个 **地球上存在的核素** `(protonNumber, neutronNumber)`，带：

- `isStable`
- `decayType`：最可能衰变，或 `null`（稳定 **或** 未知衰变）
- `decayTypeLikelihoodPercent`：`number | null`
- `colorProperty`

[已确认 `NuclideChartCellModel.ts`]

### 4.2 坐标轴（不要靠物理常识猜）

`NuclideChartAccordionBox.getChartTransform`：

```ts
modelXRange = [0, 12]  // CHART_MAX_NUMBER_OF_NEUTRONS
modelYRange = [0, 10]  // CHART_MAX_NUMBER_OF_PROTONS
```

格子放置：

```ts
// 行 = 质子，列 = 该行的中子
cell.translation = (modelToViewX(neutronNumber), viewPosition_of_proton)
高亮中心 = modelToViewXY(neutronNumber + 0.5, protonNumber - 0.5)
```

`NucleonNumberLine`：水平轴标签 `axis.neutronNumber`，竖直轴 `axis.protonNumber`。当前值用质子橙 / 中子灰高亮。

**结论：X = 中子数，Y = 质子数。** [已确认]

bamboo `ChartTransform` 的 Y 是否向上增加：zoom clip 用 `modelToViewY(clampedCellY + 2)` 作矩形顶。[推测] 模型 Y 向上为质子增大，与常见核素图一致。像素方向以 Flutter 实现时用同一 transform 测一次为准。

### 4.3 稀疏表 `POPULATED_CELLS`

行下标 = 质子数 0…10，行内数字 = 该质子数下 **画出的中子数**。[已确认 `BANModel.ts`]

```
p=0:  1, 4, 6
p=1:  0,1,2,3,4,5,6
p=2:  1..8
p=3:  1..9
p=4:  2..12
p=5:  2..12
p=6:  2..12
p=7:  3..12
p=8:  3..12
p=9:  4..12
p=10: 5..12
```

0p0n **没有格子**（空核可玩，但图画不了高亮）。[已确认] 与 Decay「0p0n 可接受」一致。

`ChartIntroModel.cellModelArray[p][columnIndex]` 与 `POPULATED_CELLS[p][columnIndex]` 对齐，**不是** `cellModelArray[p][n]`。[已确认] `DecayEquationModel.getCurrentCellModel` 用 `find(neutronNumber === mass - proton)`。

### 4.4 稳定 / 不稳定 / 颜色

| 状态 | 颜色 | 标记 |
|---|---|---|
| `isStable` | `BANColors.stableColorProperty` | [已确认] |
| 不稳定且 `decayType==null` | `unknownColorProperty` | [已确认] |
| 不稳定且有衰变 | 该 `BANDecayType.colorProperty` | [已确认] |

颜色用的衰变 = `getAvailableDecaysAndPercents` **排序后第一项**（百分比降序，null 最后）。[已确认 2026 版工具函数] 旧 issue #1368「不该用表内第一项」已被排序修复。

当前 Flutter `NuclideRepository.availableDecays` **已经是同一套排序**。格子颜色应复用 `availableDecays.first`，不要第二份表。

### 4.5 数据来源

仍是 shred `AtomData` / `AtomInfoUtils`（ENSDF Relational 2022）。[已确认 `implementation-notes.md` Data 节 + `NuclideChartCellModel`]

Flutter：继续用 `assets/data/nuclide_table.json` + `NuclideRepository`。Chart Intro **不需要**新 JSON 核素表。

`POPULATED_CELLS` 是 **视图/教学用白名单**，不是「表里存在的全部 0–10p 核素」。是否与 `doesExist` 全集一致：[待确认] 实现前用仓库扫一遍 0–10 × 0–12，列出存在但不在 POPULATED_CELLS 的格子。

### 4.6 三种图

| 节点 | 范围 | 格子边长 scale | 箭头 | 额外 |
|---|---|---|---|---|
| `NuclideChartNode`（partial） | 全 10×12 稀疏图 | 18 | 默认关（partial 场景） | 两侧数轴 |
| `ZoomInNuclideChartNode` | 同数据，clip 成约 5×5 | 30 | 开 | 当前格周围 clamp |
| `FocusedNuclideChartNode` | 全图 | 10 | 关 | 5×5 黑框；框外格子 opacity 0.65 |

[已确认] `ZOOM_IN_CHART_SQUARE_LENGTH = 5`。  
Focused 变灰条件：`|Δp|>2 || |Δn|>2`。[已确认 `NuclideChartCell.makeOpaque`]

Zoom clip 中心 clamp：`cellX ∈ [2,10]`，`cellY ∈ [2,8]`。[已确认 `ZoomInNuclideChartNode`]

---

## 5. Nucleus 模型

### 5.1 两套核，职责不同

| | 壳层主核 | mini-atom |
|---|---|---|
| 类型 | `ShellModelNucleus extends ParticleAtom` | `ParticleAtom` |
| 交互 | 可拖（未绑定的核子） | **不可交互** `inputEnabled: false` |
| 外观 | 能级横线 + 大核子 | Decay 那种圆形簇，scale 0.75 |
| 是否计入 `particles` | 是 | **否** |
| 衰变 | 淡入淡出 | 飞出（复用 `BANScreenView.emit*`） |

[已确认]

### 5.2 能级（Hollywood）

| n | 真实壳模型容量 | 本屏容量 | y |
|---|---|---|---|
| 0 | 2 | 2 | 0 |
| 1 | 6 | 6 | 1 |
| 2 | 12 | **6**（空间不够，Hollywood） | 2 |

[已确认 `EnergyLevelType.ts` + `doc/model.md` Hollywood]

座位 `ALLOWED_PARTICLE_POSITIONS`：

```
n0: x = 2, 3          // 居中两座
n1: x = 0..5
n2: x = 0..5
```

[已确认 `ShellModelNucleus.ts`]

质子能级在左；中子能级整体 **+ `X_DISTANCE_BETWEEN_ENERGY_LEVELS`（屏宽/4）**。[已确认]

填充顺序：按该种类已入核数组下标，从低能级到高、从左到右（`getLocalXIndex`）。[已确认]

**绑定：** 该种类「当前最高占用能级」之下的整层核子靠拢到层中心，`inputEnabled=false`。n2 永不绑定。[已确认 `updateNucleonPositions` + model.md]  
issue #8749：绑定「应只在下一层已有粒子时发生」——原版是否已改 [待确认，实现时对照 `protonsLevelProperty` 现逻辑]

Magic numbers 在本屏只高亮 **2 和 8**（= n0 容量，n0+n1 容量）。[已确认 `MAGIC_NUMBERS`]

### 5.3 与 Decay `ParticleAtom` 的关系

Chart Intro **复用类型层级**（`ParticleAtom` API：`addParticle` / `extractParticle` / `reconfigureNucleus`），**不复用 Decay 的圆形排布**。

`reconfigureNucleus` 在 `ShellModelNucleus` 里 override 成「重新填能级座位」，不是圆形簇。[已确认]

Decay Flutter 的 `NucleusLayout` / `NucleusPainter` **不能**当 Chart Intro 主核渲染。mini-atom 可以缩小复用 `NucleusPainter`。[推测：外观同类；半径/电子云是否显示见 §6]

### 5.4 核子创建 / 删除

与 Decay **共用** `BANScreenView` 生成器：上箭头飞入、下箭头取「该种类最外层座位」核子飞回、拖出、双箭头。[已确认 继承 + `ChartIntroModel.getParticleToReturn` override]

关键差异：

| 点 | Chart Intro | Decay |
|---|---|---|
| 飞入目的地 | `getParticleDestination` = 下一个空座位，**先占座** | 核中心 |
| 取消飞入 | `clearIncomingParticle` 还要 `removeParticleFromShell` | 只移出 incoming |
| 下箭头取哪个 | `getLastParticleInShell`（最高层最右） | 离生成器最近 |
| 捕获 | 能级矩形（含上方多扩一个粒径，issue #194） | 半径 100 圆 |
| 绑定核子 | 不能拖 | 核内都可拖 |

incoming 占座但尚未 `addParticle` 进 atom：`updateNucleonPositions` 必须保留这些占位，否则飞入会丢座位。[已确认 注释 + 实现]

### 5.5 核素变化如何传到图

壳层计数 → `protonCountProperty` / `neutronCountProperty` / `massNumberProperty` → 周期表、符号、元素名、核素图高亮、衰变方程。[已确认 model.md + 各 View multilink]

---

## 6. UI

### 6.1 原版控件 → Flutter 候选

| 原版 | 作用 | Flutter 候选 | 复用？ |
|---|---|---|---|
| `NucleonCreatorsNode` | p/n 球 + 上下箭头 + 双箭头 | Decay footer 已有 | **复用控件，改捕获/目的地** |
| `NucleonNumberPanel` | Protons / Neutrons 读数 | `NuclideStatus` 计数 | 复用只读派生 |
| `ElementNameText` | 元素名 / does not form | `NuclideStatus.elementCaption` | 复用文案逻辑 |
| mini-atom `ParticleAtomNode` | 缩小圆形核 + 电子云 | `NucleusPainter` 缩小 | 视觉可复用；**不要**接 Decay 拖核 |
| 虚线 zoom | 连 mini-atom 与能级 | CustomPainter / `CustomPaint` | 新画 |
| `NucleonShellView` | 3 条能级线，颜色随填充 | 新 Painter | **新** |
| `NuclearShellModelText` | "Nuclear Shell Model" | `Text` | 新文案 |
| 「Energy」+ 竖箭头 | 能级轴标签 | `Text` + `CustomPaint` | 新 |
| `PeriodicTableAndIsotopeSymbol` | 周期表高亮 + `SymbolNode` | **工程无周期表** | **新组件**；符号可参考 Decay `NuclideStatus` 符号 |
| `NuclideChartAccordionBox` | 「Partial Nuclide Chart」 | `ExpansionTile` / 自绘面板 | 新；不要用折线图 |
| `NuclideChartNode` 三态 | 格子图 | 新 Painter + 数据层 | 新 |
| `NucleonNumberLine` | p/n 数轴 | 新（与半衰期对数轴不同） | 新 |
| `NuclideChartLegendNode` | 稳定 + 5 衰变色块 | `Wrap` + 色块 | 新，色值跟 Decay 按钮色对齐 |
| `DecayEquationNode` | Most likely decay + 方程 | 新 Widget | 新 |
| Decay `TextPushButton` | 只在 zoom | `FilledButton` | 新，**不是** AvailableDecays 五键 |
| `ReturnButton` | zoom 旁 Undo | Decay 已有 Undo 语义 | 复用命令，换位置 |
| Radio partial/zoom | 两枚图标按钮 | `KratosRadioGroup` 或 `ToggleButtons` | 复用 common 单选 |
| Magic Numbers `Checkbox` | 高亮 2、8 | Decay 电子云 checkbox 同类 | 新状态，可仿现有 checkbox 样式 |
| `FullChartTextButton` + Dialog | PNG + 外链 | `AlertDialog` + `Image.asset` | 新；外链用 `url_launcher` 是否已有 [待确认] |
| `ResetAllButton` | 右下 | Decay 已有 Reset | 复用命令 |
| 半衰期数轴 / 5 衰变面板 / 电子云勾选 | Decay 专用 | **不要画到本屏** | — |
| Slider / Combo / 折线 | 无 | — | [已确认 无] |

### 6.2 Flutter 布局硬约束

工程要求 sim 主屏 `NineGridLayout`、中间格 ≥70%。[已确认 checklist]

原版是自由绝对定位。映射建议（实现阶段可微调，此处为分析）：

| NineGrid | Chart Intro 内容 |
|---|---|
| topLeft | 计数 + 元素名 |
| topCenter | mini-atom + 虚线起点 |
| topRight | 周期表 + 符号 |
| center（≥70%） | 能级 + Energy 轴（主操作面） |
| right | 核素图手风琴（可叠在中右，窄屏改为折叠） |
| footer | 生成器 + Reset |
| bottomRight | Radio / Magic / Full Chart |

窄屏溢出是原版已知问题（issue「Items in Partial Nuclide Chart panel can shift」）。Flutter 用 `FittedBox` / 折叠，**保持可观察内容，不复制溢出**。

---

## 7. Interaction

| 交互 | 行为 | 标记 |
|---|---|---|
| 上箭头 | 从生成器创建核子，飞向下一空座位（先占座） | [已确认 继承 + destination override] |
| 下箭头 | 取最高层最右同类核子，飞回栈并销座 | [已确认 `getLastParticleInShell`] |
| 双箭头 | 同时 ±1p±1n | [已确认 共用] |
| 箭头 enable | 与 Decay 同类：越界 1 个不存在核素、范围顶、incoming/拖拽中禁用 | [已确认 `BANScreenView` / `NucleonCreatorsNode`] |
| 从生成器拖出 | 按下即创建；松手在 **能级矩形内** 入座，否则飞回 | [已确认] |
| 拖壳层核子 | 未绑定可拖；绑定不可。松手规则同上。会造成不存在核素则收回 | [已确认 model.md + BAN 共用 dragEnded] |
| 点核素图 | **无** | [已确认 Cell 无 listener] |
| 核素图 hover | **无** | [已确认] |
| 选同位素 | **只能改 p/n 计数**，不能点格子 | [已确认] |
| partial / zoom Radio | 切手风琴内部场景；方程/Decay 键只在 zoom | [已确认] |
| Magic Numbers | 2 或 8 的行/列格子加粗描边并置顶 | [已确认] |
| Full Chart | 开 Dialog（PNG + 说明 + 可选超链 `https://energyeducation.ca/simulations/nuclear/nuclidechart.html`） | [已确认] |
| zoom Decay 按钮 | `currentCell.decayType` 且无 incoming 时可用；调用 `decayAtom`；然后显示 Undo | [已确认] |
| Undo | 恢复 Decay 前 p/n（`undoDecay(oldP, oldN)`）；`hideUndoButtonEmitter` 会藏按钮 | [已确认] |
| Reset All | magic、accordion、全部粒子/动画、mini-atom、再 populate 默认 | [已确认] |
| 不存在核素 | 显示 does not form **1 秒**再纠正（继承 BANScreenView.step） | [已确认] |
| 键盘 | 仅 joist 基础帮助 + PDOM 顺序 | [已确认 帮助节点；快捷键细节待确认] |
| Slider | 无 | [已确认] |

壳层衰变可见效果（与 Decay **不同**）：

| 衰变 | mini-atom | 壳层 |
|---|---|---|
| p/n 发射 | `emitNucleon` 飞出 | `fadeOut` 1s 后 `removeParticle` |
| α | 组成 α 飞出 | fade 2p + 2n |
| β | 换型 + 电子/正电子飞出 | 旧核子 fade out，新核子立刻入座再 fade in |

`isMiniAtomConnected=false` 期间禁止计数监听去增删 mini 粒子，避免和衰变动画抢同一套核子。[已确认]

**Chart Intro 没有** DecayScreenView 的 Be-6 强制再射。Be-6 仍可在 10/12 上限内搭出；α 后剩 2p0n，走通用「不存在 → 1 秒纠正」。[已确认 无 override] 可观察结果是否与 Decay 一样 Hollywood [待确认 应对原版 Chart Intro 点一次 Be-6 α]

---

## 8. Animation / Clock

| 动画 | 有？ | 机制 | 用不用 Decay `MovingParticle` |
|---|---|---|---|
| 箭头飞入座位 | 有 | 定时长 0.6s（BANParticle consistentTime） | 可用同一运动模型，**目的地是座位不是核心** |
| 飞回生成器 | 有 | 300 px/s | 可 |
| 能级重排 / 绑定靠拢 | 有 | `setAnimationDestination` 默认 200 px/s | 可 |
| 壳层衰变 | 有 | **opacity 1s LINEAR**，不是位移 | **不要**用飞出粒子 |
| mini-atom 衰变飞出 | 有 | 与 Decay 相同，逃逸点用 `miniAtomMVT` | 可，仅 mini-atom |
| β 壳层 | 有 | 旧 fade out + 新 fade in；**不是** 0.5s 换色 | **不要**套 Decay β 换色当主效果 |
| 核素图高亮移动 | 有 | 格子标签/箭头/clip **立刻**跟计数走，无缓动 | 不是粒子运动 |
| Focused 框 | 有 | 中心 DerivedProperty，无 Tween | 同上 |
| 自动播放衰变链 | **无** | — | — |
| 半衰期指针 | **本屏无** | — | — |

持续 step：**需要**，原因见 §2.4。不要因为 Decay 有 Clock 就共用 **同一个** Controller/State。

---

## 9. Assets

| 原 PhET | 用途 | Flutter | 使用位置 |
|---|---|---|---|
| `images/fullNuclideChart.png`（约 335KB） | Full Chart Dialog | `assets/images/build_a_nucleus/full_nuclide_chart.png`（建议路径，实现时按现有 `assets/images/` 规范落地） | Full Chart Dialog |
| `images/license.json` | 版权 | 随图保留 | 文档 |
| 无自有 sounds/ | — | 不迁音频 | [已确认 git tree] |
| 无 SVG 核素图 | 格子全是 Rectangle | 不造 SVG | [已确认] |
| `build-a-nucleus-strings_en.json` | 屏名、轴名、方程、Magic Numbers、Full Chart、Stable、Unknown… | 先英文常量/现有文案风格；中文本地化 [待确认] | UI |
| shred 周期表是代码画的 | 不是位图 | 代码画 | Periodic table |
| 核子球 | 渐变圆 | 复用 Decay 核子绘制 | 能级 + mini-atom |

**只迁实际用到的位图：`fullNuclideChart.png`。** 核素格、周期表、能级都不要做成图。

外链：`https://energyeducation.ca/simulations/nuclear/nuclidechart.html`。issue「Broken link to Full chart」仍开着。[原版已知问题] Flutter Dialog 应显示图；链接能开则开，打不开只留 URL 文本。

---

## 10. 当前 KARTOSLAB 可复用组件

### 10.1 应该复用

| 组件 | 用法 | 不要误用 |
|---|---|---|
| `NuclideRepository` / `NucleusDecayType` / JSON 表 | 存在、稳定、衰变%、符号、元素名 | 不要为 Chart 再抽一份表 |
| `Nucleon` / `NucleonType` | 类型、颜色、id | 座位/绑定是 Chart 新字段，可组合不要改坏 Decay |
| `MovingParticle` | 飞入、归位、mini-atom 飞出 | 不要用于壳层 fade |
| Decay 生成器 Widget | 外观与箭头语义 | 捕获区与目的地换 Chart 规则 |
| `NuclideStatus` 元素名/计数 | 只读派生 | 半衰期数轴不要搬来 |
| Reset / Undo **命令语义** | 清粒子；Undo 恢复 p/n | Undo **只在 zoom Decay 后**出现 |
| `SimulationClock` | dt | 每屏自己的 Clock，dispose 在 State |
| `NineGridLayout` | 主屏骨架 | 不要为 Chart 新建布局体系 |
| `DragTray` / `CanvasProjection` | 生成器拖到画布 | 命中测试改能级矩形 |
| `KratosTabbedScreen` | Decay \| Chart Intro 切屏 | 见 §12 |
| `KratosRadioGroup` | partial / zoom | — |
| Decay 符号绘制思路 | 方程里的 ^A_Z X | 方程还要衰变符号 α/β/p/n |

### 10.2 不要复用（行为不匹配）

| 组件 | 原因 |
|---|---|
| `BuildANucleusState` / `BuildANucleusController` | 圆形核、捕获 100、五衰变、Be-6、半衰期指针 |
| `NucleusLayout` 作主核 | 能级不是圆簇 |
| `NucleusPainter` 作主画布 | 可画 mini-atom，不能画能级 |
| `lib/common/chart/*` | 时间序列，不是核素格子 |
| `TimeControlBar` | 本屏无播放暂停 |
| Half-life 全套 Widget | 本屏没有 |
| Available Decays 五键 | zoom 单键 |
| 电子云 checkbox | 本屏没有该控件（mini-atom 是否带云见下） |

mini-atom 电子云：原版 `ParticleAtomNode` 自带蓝云，**没有** Chart Intro checkbox。[已确认] Flutter mini-atom 是否画云：[推测] 画，与原版默认外观一致；不要把 Decay 的勾选状态共享过来。

### 10.3 common 缺口（Chart 需要、工程没有）

- 周期表
- 核素格子图
- 能级条
- 衰变方程排版
- Full Chart 大图资源

**禁止**为这些去改 `lib/common`（用户本阶段也未要求改 common）。放在 `lib/chemistry/build_a_nucleus/chart_intro/`。

---

## 11. Decay → Chart Intro 映射表

| 项 | Decay | Chart Intro | 共用？ | 依据 |
|---|---|---|---|---|
| Model | `BuildANucleusState`（圆核） | 新 Chart 状态 + `ShellModelNucleus` 语义 | **数据层共用，状态机不共用** | `BANModel` 共用，`particleAtom` 类型不同 |
| Nucleon | `Nucleon` + 圆簇坐标 | 同类型 + 能级座位 + bound | **类型共用，布局不共用** | `ShellModelNucleus` vs `NucleusLayout` |
| 粒子渲染 | `NucleusPainter` | 能级 Painter + 缩小 `NucleusPainter` | **部分** | ScreenView 两套 layer |
| SimulationClock | 有 | 有，独立实例 | **类复用，实例不共享** | 两屏独立 step |
| Chart | 半衰期对数轴 | 核素格子图 | **不共用** | 完全不同数据 |
| Controls | 五衰变 + 半衰期 info + 电子云 | Radio + Magic + Full Chart + 单 Decay | **生成器共用，其余不共用** | 两个 ScreenView |
| Reset | 清圆核到 0p0n | 清壳层 + mini-atom + 图选择 + magic | **语义同类，目标不同** | 各自 `reset()` |
| Undo | 任意衰变后 | 仅 zoom Decay 按钮后 | **不共用按钮位置** | Accordion vs AvailableDecays |
| Layout | NineGrid + 圆核居中 | NineGrid 映射能级+图 | **布局组件共用** | 工程硬性要求 |
| 核素表 | Repository | 同一 Repository | **是** | shred 同一份 |
| 上限 | 94 / 146 | 10 / 12 | 常量不同 | `BANConstants` |
| Be-6 Hollywood | 有 | 无专用路径 | **不共用** | 仅 `DecayScreenView` override |

---

## 12. 目录建议及依据

先看现有组织，再决定。

| 现有 | 结构 |
|---|---|
| `lib/chemistry/build_a_nucleus/` | 扁平：`data/` `model/` `screens/` `painters/` `widgets/` `controller/` |
| `lib/chemistry/molarity/` | 少数派 MVC 嵌套 |
| `lib/color_vision/screens/` | `color_vision_home.dart` + 两屏，`KratosTabbedScreen` |
| `lib/forces/screens/` | `forces_home.dart` + 多 Tab |
| Home | **一张卡进一个 Widget**，无 named route |

**建议（实现阶段再改代码）：**

```
lib/chemistry/build_a_nucleus/
  data/                          # 不动，两屏共用
  model/                         # Decay 专用状态保留
  screens/
    build_a_nucleus_home.dart    # 新：KratosTabbedScreen（Decay | Chart Intro）
    build_a_nucleus_screen.dart  # 现有 Decay，尽量不改逻辑
    chart_intro_screen.dart      # 新 Screen
  chart_intro/
    model/                       # 壳层、格子、方程
    painters/
    widgets/
  # Decay 的 painters/widgets/controller 不搬进 chart_intro
```

**依据：**

1. 不平行搞 `lib/src/simulations/`。[已确认 工程规范]
2. Chart Intro 文件量约 20+ TS，塞进现有 `model/` 会和 Decay 状态搅在一起。
3. 多屏 sim 的工程先例是 **一张 Home 卡 + 页内 Tab**，不是第二张 Home 卡。[已确认 color_vision / forces]
4. Home 已有「构建原子核」卡。Phase 2 接线应改 `builder` → Home，而不是再注册一张卡、也不要新 Navigator。

`assets/images/` 是否已有 chemistry 子目录：实现时按现有 assets 规范放 `full_nuclide_chart.png`。[待确认 精确子路径]

测试：`test/chemistry/build_a_nucleus/chart_intro/`，与 Decay 测试并列。

---

## 13. 测试计划

不新建测试框架。对齐现有 `test/chemistry/build_a_nucleus/*`。

| 层 | 用例（最小集） |
|---|---|
| 数据 | `POPULATED_CELLS` 每个 (p,n) → `doesExist`；格子最可能衰变 = `availableDecays.first` |
| 壳层 | 填座顺序；n2 容量 6；绑定后 `inputEnabled`；incoming 占座；clear 清座位 |
| 捕获 | 能级矩形内松手入座；外则归位；绑定核子不可拖 |
| 计数 | 箭头 / 双箭头上下限 10/12；越界 1 个不存在 |
| 图 | (p,n) 高亮正确格；不存在则无标签；X/Y 轴高亮；Magic 2/8 |
| zoom | Radio 切换；方程 daughter；稳定显示 Stable；未知衰变 Unknown |
| 衰变 | zoom Decay：壳层 fade 后计数变；mini-atom 计数同步；Undo 恢复 |
| β | 质量不变时方程仍更新（覆盖原版只听 mass 的缺口） |
| Reset | 空核、partial、magic off、无 Undo |
| 生命周期 | 进屏 → 操作 → 返回 Home → 再进：无 Ticker 泄漏、粒子列表空、Clock dispose |
| 导航 | Home → 构建原子核 → Chart Intro Tab → Back |
| 回归 | 全部现有 Decay 测试保持通过 |

**不要**测原版 CT 断言（reentry / removeListener）。测 Flutter 的 dispose 是否干净。

---

## 14. 风险

| 风险 | 级别 | 说明 |
|---|---|---|
| 双核同步 / dispose | 高 | 见 §11 原版 CT。Flutter 应用派生 mini-atom，避免 step 里 dispose |
| 误复用 Decay State | 高 | 会把圆核、五衰变、Be-6 带进本屏 |
| 误用 `kratos_chart` | 中 | 画不出核素图 |
| 周期表工作量 | 中 | 工程没有现成表；只需高亮 Z≤10，可画到 Ne |
| 能级绑定手感 | 中 | Hollywood + 多层 issue（#194/#3608/#9193/#8749） |
| NineGrid vs 原版绝对定位 | 中 | 保内容不保像素 |
| Full Chart 外链失效 | 低 | 图仍可用 |
| DecayEquation 只听 mass | 中 | 不要复制 |
| 两屏 Undo 串扰 | 中 | 原版 issue；Flutter 两屏独立 State 可消除 |
| POPULATED_CELLS ≠ doesExist 全集 | 低 | 实现前扫表 |

---

## 15. [已确认]

- Chart Intro 是独立 joist Screen，与 Decay 并列启动。
- 上限 10p / 12n；主核 `ShellModelNucleus`；另有 mini `ParticleAtom`。
- 核素图 X=中子、Y=质子；稀疏 `POPULATED_CELLS`；数据仍来自 shred / 现有 JSON。
- 格子不可点、无 hover。
- 壳层衰变 fade 1s；飞出只在 mini-atom。
- Chart Intro α **没有** Be-6 强制再射。
- 本屏无半衰期数轴、无五衰变面板、无电子云勾选、无 Slider。
- 唯一位图 `fullNuclideChart.png`。
- CT issue #220：ChartIntroScreen 上 `removeListener` / `reentry`，栈穿过 `ChartIntroModel.step`、`createMiniParticleView.dispose`、`nucleonNumberListener`。
- 工程多屏先例 = `KratosTabbedScreen`；Home 无稳定 sim ID 字段。
- Decay 已复用的 `availableDecays` 排序与格子「最可能衰变」一致。

---

## 16. [推测]

- Flutter 用独立 Chart 状态 + 由壳层计数 **派生** mini-atom，而不是第二套可 step 的粒子世界。
- Home 一张卡 + Tab（Decay / Chart Intro），不新开导航体系。
- mini-atom 默认画电子云，但不共享 Decay checkbox。
- 1 秒 does-not-form 纠正在 Chart Intro 同样生效（继承 BANScreenView.step）。
- twixt Animation 由 sim 全局 step；Flutter 用 Clock 或 `AnimationController` 做 1s fade。
- 理论工时未加经验系数；壳层与核素图标探索任务。

---

## 17. [待确认]

- bamboo Y 轴像素方向（实现时测一次）。
- `POPULATED_CELLS` 是否覆盖 0–10p、0–12n 内全部 `doesExist`。
- 原版 Chart Intro 对 Be-6 α 的可观察结果（1 秒纠正 vs 停在 2p0n）。
- `protonsLevelProperty` 是否已实现 issue #8749 的「下层锁定条件」。
- DecayEquation 在纯 β 后是否真的不刷新（运行原版 zoom）。
- joist 基础键盘具体键位。
- 工程是否已有 `url_launcher` / 外链控件。
- `fullNuclideChart.png` 版权条款全文（`images/license.json`）落地时再读。
- 中文本地化策略（与 Decay 已有中英混排一致还是全英）。
- 原版 Reset 未重置项清单（issue #7699）——Flutter 以「用户能看见的默认态」为准。

---

## 18. 理论工时拆分

只报理论小时，**不加**经验系数。探索任务已标明。

| 任务 | 小时 | 备注 |
|---|---|---|
| 本分析（已完） | 3 | 源码 + CT + 工程映射 |
| Chart 数据 / POPULATED_CELLS / 格子着色 | 2 | 复用 Repository |
| ShellModelNucleus + 座位 + 绑定 | 8 | **探索任务** |
| 能级 View + Energy 轴 + 虚线 | 4 | |
| 生成器接入（新捕获区 / 占座飞入） | 4 | 复用控件 |
| Mini-atom 派生渲染 | 3 | 避免双世界；探索风险在生命周期 |
| 淡入淡出衰变（含 β 换型） | 4 | 不要抄 MovingParticle 飞出 |
| Partial 核素图 + 数轴 + 图例 | 8 | **探索任务** |
| Zoom + Focused + 衰变箭头 | 4 | |
| 衰变方程 + zoom Decay/Undo | 3 | |
| 周期表 + 符号 | 6 | **探索任务**（无现成组件） |
| Full Chart Dialog + PNG | 1.5 | |
| Radio / Magic / Accordion / Reset | 2 | |
| Home Tab 接线（不改 Decay 逻辑） | 1 | |
| 生命周期 / dispose / 回归 | 3 | |
| 测试 | 8 | 含导航 + Decay 回归 |
| **合计** | **64.5** | Chart Intro 单屏；不含再改 Decay 业务 |

对照 Phase 1 Decay 实际远低于理论：本表仍只给理论值。

---

## 19. 生命周期专节（对应任务 §11）

### 19.1 原版怎么活

- Sim 级两个 Screen **不销毁**。
- 动态对象几乎只有 Particle + ParticleView。
- `implementation-notes` 写明：除粒子外不需要 unlink。[已确认]
- mini-atom 粒子 **不进** `particles`，Reset 要单独 `miniParticleAtom.clear()`，step 要单独 step。[已确认 `ChartIntroModel`]

### 19.2 `[原版已知问题]`（CT / issue）

| Issue | 现象 | 栈落点 | Flutter 策略 |
|---|---|---|---|
| [#220](https://github.com/phetsims/build-a-nucleus/issues/220) 仍 open | `reentry detected`；`tried to removeListener on something that wasn't a listener` | `ChartIntroModel.step` → 粒子到达 `addParticle` 重入；`ChartIntroScreenView` dispose / `nucleonNumberListener` 抽粒子 | **不复制。** mini-atom 用计数派生；dispose 只在 Widget `dispose`；step 不在 listener 里销粒子 |
| #202（源码注释） | step 已 dispose 的粒子 | `BANModel.step` | 列表与对象生命周期同一所有权 |
| Memory leak α Animation | `particleAnimations` 握着动画 | BANModel | Clock/AnimationController 在 Reset 与 State.dispose 停止 |
| Undo 跨屏消失 | 两屏共享 emitter | 两 Screen 常驻 | 两屏独立 State |
| Reset 第二屏漏项 | #7699 | Chart Intro reset 不全 | 以可观察默认态写测试，不盲抄 |
| 第三能级难放置 | #194/#3608/#9193 | 捕获 bounds 不含线上粒子 | 捕获区向上扩一个粒径（源码已 dilated+offset） |

### 19.3 Flutter 生命周期（建议，待实现阶段执行）

1. `ChartIntroScreen` State 持有自己的 Controller + `SimulationClock`。
2. `dispose`：停 Clock、清动画、不把 listener 挂到已 dispose 的对象。
3. 重复进入：`pump` 新 State，默认空核（或与 Decay 一样异步 load 表）。
4. 不在 `addListener` 回调里同步 dispose 另一套粒子。
5. 可观察行为对齐原版；内部资源管理按 Flutter 所有权做对。

---

## 20. 建议实现顺序（仅规划，现在不写代码）

1. `POPULATED_CELLS` + 格子模型（纯 Dart + 测色/衰变）
2. 壳层座位 + 绑定（纯 Dart）
3. 能级绘制 + 生成器接入
4. 核素图 partial
5. zoom / 方程 / Decay+Undo
6. 周期表 + mini-atom
7. Full Chart + Magic + Radio
8. Home Tab 接线
9. 生命周期测试 + Decay 回归

完成分析。**停止。等待下一阶段指令。**

---

## 21. Phase 2I-1 · 最终视觉与布局差异（2026-08-31）

本阶段**不新增功能**，只对齐已实现组件的尺寸 / 间距 / 字体 / 面板 / 小屏。NineGrid 未改。未改 `ChartIntroState` / `ChartIntroController` / `NuclideRepository` / Decay Screen / Home 业务 / `lib/common`。

禁止结论：「完全一模一样」。无 golden，无像素级截图对照。

### 21.1 模块对照

| 模块 | 原版 | 当前 Flutter | 类型 | 处理 |
|---|---|---|---|---|
| 主布局 | `ScreenView` 绝对坐标（1024×618） | `NineGridLayout` 中心格 ≥70% | [有意差异] | 不改 NineGrid；边格 FittedBox |
| mini-atom 落位 | 顶左，scale 0.75，中心约 (width/3, 87) | NineGrid `topCenter` + 180×180 画布 × 0.75 粒子 | [有意差异] | 缩放参数源码一致；坐标跟格子 |
| 虚线连 mini-atom↔能级 | `Line` dashed | 无（跨格无法绝对定位） | [有意差异] | 不画跨 NineGrid 线 |
| Energy 竖字 + 箭头 | 能级左侧 | 未画标签（能级线本身在） | [有意差异] | 本阶段不加新控件 |
| Nuclear Shell Model 标题 | `REGULAR_FONT` 20 | 无 | [有意差异] | 同上 |
| 壳层几何 | 半径 10、X 间距 = 半径、Y = 4 直径、列距 width/4 | 同左 | [源码一致] | 已有常量，未改语义 |
| 核子球 | shred `ParticleNode` 渐变 | 同色径向渐变 | [视觉近似] | 无 PhET 材质球资源 |
| 计数面板 | `NucleonNumberPanel` 英「Protons:」字号 18、球 r=7、翻页数字 | 中「质子:」字号 18、球 r=7、Panel 铬、无翻页 | [行为一致] 读数；[有意差异] 中文 / 无翻页 | 2I-1 补 Panel + 字号 + 半径 |
| 元素名 | `PhetFont(20)` `Color.RED` | 字号 20、`#FF0000` | [视觉近似] | 无 PhetFont 文件 |
| 周期表格 | 25×25、scale 0.75、90 格、描边 1 | 同左 | [源码一致] | 2G |
| 同位素符号盒 | 275×325 × 0.15，PhetFont 150/70 | 同几何；Flutter TextStyle | [源码一致] 几何；[视觉近似] 字体 |
| 符号叠层 | centerX 7.5/18 列，表 top = symbol.bottom − h/7×2.5 | `PeriodicTablePanelGeometry` | [源码一致] | |
| Partial 格 | `getChartTransform(18)` | 18px | [源码一致] | |
| Zoom-in 格 | 30px + 5×5 clip，中心夹紧 n∈[2,10] p∈[2,8] | 同左 | [源码一致] | 未改 state |
| Focused 格 | 10px + 5×5 框 + 窗外 0.65 | 同左 | [源码一致] | |
| selectedChart | `partial` \| `zoom` | 同左 | [行为一致] | 未改 |
| focus memory | 独立 Derived | `ChartFocusMemory` | [行为一致] | 未改 |
| 手风琴 | `AccordionBox` 可折叠，标题 Partial Nuclide Chart，底白 | 白底描边面板 + 同标题，**不可折叠** | [视觉近似] 铬；[有意差异] 无折叠 | 2I-1 补标题/底/图例 |
| 图例 | 2 列 Grid，色块 14，x80 y5，LEGEND 12 | 同参数 Wrap 两列 | [行为一致] | 2I-1 接入面板 |
| 方程位置 | 仅 zoom，accordion 内、图上方 | 同左 | [行为一致] | |
| 方程内容 | `availableDecays[0]`，不可点 | 同左 | [行为一致] | 未改 |
| 方程符号 | 150/100 × 0.15，V 距 15、H 距 20 | 22.5 / 15 / 2.25 / 3 | [源码一致] 缩放算术 | 2I-1 改字号间距 |
| 方程箭头 | 长 25，白填黑描，尾宽 3 | 同参数 CustomPaint | [视觉近似] | 非 scenery ArrowNode |
| 方程加号 | PlusNode 9×2 黑 | 同尺寸 | [源码一致] | 2I-1 |
| Decay / Undo | zoom 内一键 + ReturnButton | FilledButton + Material Undo | [行为一致]；[视觉近似] 皮肤 | 不是五键 |
| Radio | 核素图图标按钮 | 文字 Partial / Zoom | [有意差异] | 无图标资源 |
| Full Chart 按钮 | 手风琴外，Magic Numbers 下 | 手风琴外，与 Radio 同行 | [行为一致] 始终在、只开 Dialog；[有意差异] 落位（无 Magic） | |
| Full Chart Dialog | 静态 PNG 481.5、黑框 +5、标题 32、说明 19 | 同左 | [源码一致] 资源与限宽 | |
| Dialog 生命周期 | Screen 常驻，Reset 不关 | Reset 不关；Tab dispose 关 | [行为一致] Reset；[有意差异] Tab | |
| Magic Numbers | Checkbox 高亮 2/8 | 未做 | [有意差异] | 非本阶段功能 |
| Typography | PhetFont (Gotham) | Flutter 默认 | [视觉近似] | 无原版字体文件 |
| 小屏 | 原版已知溢出 | FittedBox + Dialog 可滚；不整体缩小实验 | [有意差异] | 测 1024×768 / 1280×800 / 1366×1024 / 640×360 |
| Decay / Home / Tab | 独立 Screen 常驻 | `KratosTabbedScreen` 无 KeepAlive | [有意差异] | 未改业务 |

### 21.2 已达到源码一致

- 壳层座位间距、能级线宽、列距 `LAYOUT_BOUNDS.width/4`
- 核素图 18 / 30 / 10、Focused 窗外 0.65、zoom clip 夹紧范围
- 周期表 25×0.75、符号盒 275×325×0.15、叠层公式
- 衰变色、格描边、方程 Z 色 `#FF5500`
- 方程符号缩放算术、加号 9×2、箭头长 25
- Full Chart PNG、`setMaxWidth(481.5)`、黑框 dilated 5
- 计数球半径 `PARTICLE_RADIUS * 0.7`、字号 18、Panel xMargin 10 / 圆角 6
- 图例色块 14、Grid 间距 80 / 5
- 手风琴标题文案、白底、内容 spacing 10

### 21.3 已达到行为一致

- 格子不可点；当前核素只跟 p/n
- `selectedChart` 仅 partial / zoom；focus memory 独立
- 方程仅 Zoom、只画 `availableDecays[0]`、一 Decay + 一 Undo、不可点
- Full Chart 始终有按钮；Dialog 不改 chart / focus / cell / zoom
- Reset 不关 Dialog
- 壳层 fade 1s；mini-atom 派生、不可交互
- Tab 无 KeepAlive：再进入新实例

### 21.4 视觉近似

- Flutter 默认字体 vs PhetFont（字号已对齐，字重/基线/上标不能声称一致）
- 核子球 / 方程箭头为自绘，不是 scenery `ParticleNode` / `ArrowNode`
- 手风琴铬（无折叠三角、无 sun AccordionBox 阴影）
- Material Radio / Decay / Undo / Reset 皮肤
- Dialog 关闭钮为 Material X，不是 sun Dialog 默认铬

### 21.5 有意差异

- **NineGrid vs 绝对定位**：分区映射见 §6.2；不声称像素级一致
- 无 Energy 轴字、无 Nuclear Shell Model 标题、无 mini-atom 虚线
- 计数 / 部分控件中英混排（对标 Decay FINAL-1）
- 无 Magic Numbers checkbox
- Radio 用文字而非迷你核素图图标
- Full Chart 与 Radio 同行（原版在 Magic 下方）
- 手风琴不可折叠
- Tab dispose 关闭 Dialog（防泄漏）
- 小屏 FittedBox / Dialog 滚动，不复制原版溢出

### 21.6 待确认

- bamboo Y 轴与截图像素是否还要微调（逻辑已按 transform）
- 原版 Chart Intro Be-6 α 可观察结果
- 中文本地化是否要把「质子 / 中子 / Reset」改成全英
- PhetFont 文件若日后接入，再升格 typography 标记

### 21.7 验证

- `flutter analyze`（BAN lib + test）：No issues found
- BAN：**404/404**（2H-3 的 400 + 本阶段 4；2I-2 另 +1 → 见完成报告 405）
- 未建 Golden 基础设施

---

## 22. Phase 2I-2 · 最终回归（2026-08-31）

一期收口。**未改**业务代码。新增 Chart Intro 进/出 ×5 生命周期测试。

完整清单、构建、全仓、工时见：

`requirements/req-build-a-nucleus/BUILD_A_NUCLEUS_COMPLETION_REPORT.md`

§21 视觉分类仍有效。2I-2 未消灭任何 [待确认] 项。

