# PHASE 0 — SOURCE AUDIT · Hooke's Law

> **Behavior Reference** = 本地源码（SOURCE OF TRUTH）  
> **Visual Reference** = 用户提供的官方截图 + published `latest`（交叉验证；冲突时行为以本地为准）  
> 审计日期：2026-09-20  
> 禁止状态：未开始 Flutter 编码 · 未宣布 READY

本地根目录：

`phet sourses/hookes-law-main/hookes-law-main/`

本仓库 **没有** `.git`。SHA 只来自 `dependencies.json`，不是一次可复现的 `git rev-parse`。

---

## 1. 官方 source version

| 项 | 值 | 来源 |
|---|---|---|
| Sim 名称 | Hooke's Law | `hookes-law-strings_en.json` → `hookes-law.title` |
| package.json version | **1.3.0-dev.0** | `package.json:3` |
| dependencies.json 快照注释 | **1.2.0-dev.3** · Wed May 07 2025 | `dependencies.json` 首行 comment |
| 已发布 release notes | **1.2 (2025-05-21)**，其下为 1.1 (2024-07-15)、1.0 (2015-10-21) | `doc/release-notes.md` |
| requirejsNamespace | `HOOKES_LAW` | `package.json` |
| screenNameKeys | `HOOKES_LAW/intro` · `HOOKES_LAW/systems` · `HOOKES_LAW/energy` | `package.json` |
| simFeatures | sound、interactive description、dynamic locale；colorProfiles = `default` | `package.json` |
| 源文件版权年 | `Copyright 2015-2026` | 各 `.ts` 文件头 |

**版本不一致（必须记录，不能自行选边）：**

- `package.json` 写 `1.3.0-dev.0`
- `dependencies.json` 注释仍是 `1.2.0-dev.3`（2025-05-07）
- `doc/release-notes.md` 最新已发布条目是 **1.2 (2025-05-21)**，没有 1.3 发布说明

行为以 **当前这份 TypeScript** 为准，不按 release note 回退，也不按网页截图改公式。

---

## 2. git SHA

| 项 | 值 |
|---|---|
| 本地 `git rev-parse` | **不可用**（该目录不是 git 仓库） |
| `dependencies.json` → `hookes-law.sha` | `66c44cc9c3a8bcccc3446ecd2156dc2b79151cc7` |
| branch（快照声明） | `main` |

该 SHA 是 PhET 构建快照写入的，**没有**用本地 git 复核它是否等于当前文件树。

---

## 3. simulation dependencies version

`dependencies.json` 记录的是 **SHA，不是 semver**。本地快照 **不包含** 这些依赖的源码。Flutter 迁移时 scenery-phet / sun / joist 的像素级细节必须按下列 SHA 回读，不能用当前 `main` 代替。

| Repo | SHA | 本 sim 用到的能力 |
|---|---|---|
| hookes-law | `66c44cc9c3a8bcccc3446ecd2156dc2b79151cc7` | 本仓库 |
| axon | `7339accb2a1a19dc266b48e4d15ea006e88a8754` | NumberProperty / DerivedProperty / Multilink / BooleanProperty / EnumerationProperty |
| dot | `9ab9044515dff4cb3a5dbf51c9f350bb1a4a2fae` | Range / RangeWithValue / toFixedNumber / roundToInterval |
| kite | `e80437357c1393c5f58d6d1fd7b417c54072773c` | Shape（铰链、夹爪弧、能量曲线、力-能量三角形） |
| scenery | `7dcf67a50183ad7422379b5a64991acd489f9ccb` | Node / Path / Rectangle / Text / Line / LinearGradient |
| scenery-phet | `5a91ec98da7266d76e9f6062d8acbb1e985ce3de` | ParametricSpringNode、ArrowNode、LineArrowNode、NumberControl、ResetAllButton、SoundDragListener、ShadedRectangle、BracketNode、PhetFont、PhetColorScheme |
| sun | `8a737a30763f6f099db1763691049abb8c63f0aa` | Panel、Checkbox、AquaRadioButtonGroup、RectangularRadioButtonGroup、ArrowButton、Slider、HSeparator |
| joist | `bb6a94e05e03c82aa75dfb9717459e5be07a4507` | Sim / Screen / ScreenView / 导航栏 / Home |
| phetcommon | `e2d88782c579e34f5d0ed5e728f179a1fc5c4493` | StringUtils |
| twixt | `8e7b76db00f358dffc7fa90e05c753f7a5a8f09c` | Intro 1↔2 系统过渡 Animation + Easing.LINEAR |
| tambo | `bd06610ae80bedbf423c840a837747d503f2f884` | NumberControl / SoundDragListener 的通用音效（本仓库无自定义音频文件） |
| tandem / phet-io* | 见 `dependencies.json` | PhET-iO。Flutter **不移植** instrumentation |

`package.json` `devDependencies` 只有 `grunt ~1.5.3`。`phet.phetLibs` 额外声明 `twixt`。

**PhetColorScheme（scenery-phet 上述 SHA，已核对源文件）：**

| 符号 | RGB | 本 sim 用途 |
|---|---|---|
| `RED_COLORBLIND` | `255, 85, 0` | Applied Force 颜色 |
| `ELASTIC_POTENTIAL_ENERGY` | `0, 204, 255` | Energy 柱 / 曲线 / 面积 |
| `RESET_ALL_BUTTON_BASE_COLOR` | `247, 151, 34` | Reset All（`#F79722`） |

---

## 4. 三个 Screen 的结构

入口 `js/hookes-law-main.ts`：`simLauncher` → `Sim`，屏幕顺序固定为 Intro、Systems、Energy。三屏 **模型互不共享**。切屏代码里没有 reset。

背景色三屏都是 `white`（`HookesLawColors.screenBackgroundColorProperty`）。没有 AppBar。PhET 导航栏 / Home / 菜单来自 joist，不在本仓库。

### Intro

| 层 | 类 | 职责 |
|---|---|---|
| Screen | `IntroScreen` | 标题 `Intro`；图标 = 单根蓝弹簧 + 机械臂 |
| Model | `IntroModel` | **两个互不相关** 的 `SingleSpringSystem`（`system1` / `system2`） |
| View | `IntroScreenView` | 右上 visibility panel + 1/2 系统单选；两个 `IntroSystemNode`；Reset All |
| 过渡 | `IntroAnimator` | 1↔2 时先淡出/平移，再平移/淡入。不是弹簧振动 |

默认只显示 system 1，垂直居中。切到 2 套时 system1 移到 `0.25 * layoutBounds.height`，system2 在 `0.75 * layoutBounds.height`。

**不是并联弹簧。** 右上第二个按钮图标是两根弹簧上下叠放（`createTwoSpringsIcon`），物理上仍是两套独立单弹簧，各有自己的 k 和 F。

每套系统：墙 → 蓝弹簧（12 圈）→ 黑色 nib → 机械臂。底部两个 Panel：`Spring Constant {n}`、`Applied Force {n}`。

### Systems

| 层 | 类 | 职责 |
|---|---|---|
| Screen | `SystemsScreen` | 标题 `Systems`；图标 = 并联双弹簧 |
| Model | `SystemsModel` | `seriesSystem` + `parallelSystem`，同时存在，互不影响 |
| View | `SystemsScreenView` | 用 `systemTypeProperty` 切换可见性，默认 **PARALLEL** |
| 并联 | `ParallelSystem` / `ParallelSystemNode` | 上紫、下黄，右端黑桁架 |
| 串联 | `SeriesSystem` / `SeriesSystemNode` | 左紫、右黄，首尾相接 |

右上：Applied Force / Spring Force（Total | Components）/ Displacement / Equilibrium / Values。其下 RectangularRadio：并联图标在左（默认选中），串联图标在右。

### Energy

| 层 | 类 | 职责 |
|---|---|---|
| Screen | `EnergyScreen` | 标题 `Energy` |
| Model | `EnergyModel` | 一个 `SingleSpringSystem`；**指定 displacementRange，不指定 appliedForceRange** |
| View | `EnergyScreenView` | 上方图 + 下方弹簧系统 + 右上面板 |
| 图 | `EnergyBarGraph` / `EnergyPlot` / `ForcePlot` | 三选一，默认 Bar Graph |
| 控件 | `EnergySpringControls` | Spring Constant + **Displacement**（没有 Applied Force 滑条） |

Energy 屏 **没有** Spring Force 勾选。`Energy` 勾选只在 Force Plot 上启用，控制曲线下的能量三角形。

用户截图与上述结构一致：Intro 蓝弹簧、k 刻度 100/500/1000、F 刻度 -100/0/100；Systems 紫+黄、k 刻度 200/400/600；Energy 柱图纵轴 “Potential Energy”、k 刻度 100–400、位移刻度 -1/0/1。Intro 截图里 Applied Force 1 显示 `2.0 N`，那是操作后的状态，不是默认值（默认是 `0`）。

---

## 5. 所有 Model 类

| 类 | 文件 | 说明 |
|---|---|---|
| `Spring` | `js/common/model/Spring.ts` | **模型核心**。一维。左端可动（系统里用断言锁死），右端受力 |
| `SingleSpringSystem` | `js/common/model/SingleSpringSystem.ts` | 1 根 `Spring` + `RoboticArm`。Intro 两套、Energy 一套 |
| `RoboticArm` | `js/common/model/RoboticArm.ts` | 左端可动、右端固定。只有 `leftProperty` |
| `IntroModel` | `js/intro/model/IntroModel.ts` | `system1`、`system2` |
| `SystemsModel` | `js/systems/model/SystemsModel.ts` | `seriesSystem`、`parallelSystem` |
| `SeriesSystem` | `js/systems/model/SeriesSystem.ts` | left / right / equivalent 三根 `Spring` + arm |
| `ParallelSystem` | `js/systems/model/ParallelSystem.ts` | top / bottom / equivalent 三根 `Spring` + arm |
| `EnergyModel` | `js/energy/model/EnergyModel.ts` | 一个 `SingleSpringSystem` |

**没有 Mass / Load 类。** 拉动元件是机械臂，不是砝码。不要建 `mass_model.dart`。

文档：`doc/model.md`、`doc/implementation-notes.md`。模型是 **一维 x 轴，向右为正**。力、位移在模型里是标量，不是 Vector2。

---

## 6. 所有核心公式

单弹簧（`Spring.ts` 与 `doc/model.md`）：

```
F = k * x
E = (k * x * x) / 2
springForce = -F
equilibriumX = left + equilibriumLength
right = equilibriumX + displacement
length = abs(right - left)
```

必须二选一指定范围，另一个由公式推出：

| 屏 | 指定 | k 改变时保持 | k 改变时重算 |
|---|---|---|---|
| Intro、Systems | `appliedForceRange` | F | `x = F / k` |
| Energy | `displacementRange` | x | `F = k * x` |

双向关系（`reentrant: true`，见 implementation notes）：

- 改 F → `x = F / k`（保持 k）
- 改 x → `F = k * x`，再 `appliedForceRange.constrainValue`，再 **`toFixedNumber(appliedForce, 10)`**
- 改机械臂 left → `x = left - equilibriumX`

串联（`SeriesSystem.ts`）：

```
Feq = F1 = F2
keq = 1 / (1/k1 + 1/k2)
xeq 由 equivalentSpring 的位移表示；右弹簧 left = 左弹簧 right
Eeq = E1 + E2   （两根弹簧各自的 potentialEnergy 相加；代码不另存 Eeq 字段）
```

并联（`ParallelSystem.ts`）：

```
xeq = x1 = x2          // equivalent.displacement 写入 top 与 bottom
keq = k1 + k2
Feq 由 equivalentSpring 自己的 F = keq * x 计算
F1 = k1 * x1，F2 = k2 * x2   // 各弹簧 Spring 监听器自己算，不是 View 手写
Eeq = E1 + E2
```

并联的 `appliedForceRange` 仍是 `[-100, 100]`，和单根弹簧相同，**不是**两力之和的范围。等效弹簧的 F 被钳在这个范围内。分力来自各弹簧的 `appliedForceProperty` / `springForceProperty`。

浮点：`displacementProperty` 与 `appliedForceProperty`、`RoboticArm.leftProperty`、`rightProperty` 都是 `reentrant: true`。位移改力时四舍五入到 **10 位小数**，用来打断 F↔x 循环（axon#447 / hookes-law#63）。

---

## 7. 所有 Property

### Spring（每根弹簧）

| Property | 类型 | 单位 | 备注 |
|---|---|---|---|
| `appliedForceProperty` | NumberProperty | N | reentrant；range = `appliedForceRange` |
| `springConstantProperty` | NumberProperty | N/m | 等效弹簧 phetioReadOnly |
| `displacementProperty` | NumberProperty | m | reentrant；Energy 屏可写，其余屏 phetioReadOnly 但 UI 仍通过臂/滑条改它 |
| `leftProperty` | NumberProperty | m | 单弹簧/墙端被 lazyLink 断言锁死 |
| `springForceProperty` | Derived | N | `-appliedForce` |
| `equilibriumXProperty` | Derived | m | `left + equilibriumLength` |
| `rightProperty` | Derived | m | reentrant |
| `rightRangeProperty` | Derived | m | Intro/Systems 随 k 变；Energy 随 equilibriumX 平移固定位移区间 |
| `lengthProperty` | Derived | m | `abs(right-left)` |
| `potentialEnergyProperty` | Derived | J | `(k * x * x) / 2` |

### RoboticArm

| Property | 说明 |
|---|---|
| `right` | 常量，构造时固定 |
| `leftProperty` | reentrant；`isValidValue: value < right` |

Intro 的 `SingleSpringSystem` **没有** `ignoreUpdates`。Systems 的串联/并联在臂↔等效弹簧之间用 `ignoreUpdates` 打断一次写入环。

### 数值范围（构造默认）

| 屏 | k range (min, max, default) | 力或位移 range | equilibriumLength |
|---|---|---|---|
| Intro 每套 | 100 … 1000，默认 **200** N/m | F: -100 … 100，默认 **0** N | 1.5 m（Spring 默认） |
| Intro 推出的 x | — | x: -1 … 1 m（`F/k_min`），默认 0 | — |
| Systems 左/右或上/下 | 200 … 600，默认 **200** | F: -100 … 100，默认 0 | 串联每根 **0.75** m；并联每根 **1.5** m |
| Systems 串联 keq | 100 … 300，默认 **100** | 同 F 范围 | 等效长度 **1.5** m |
| Systems 并联 keq | 400 … 1200，默认 **400** | 同 F 范围 | 等效长度 **1.5** m |
| Energy | 100 … 400，默认 **100** | x: **-1 … 1**，默认 **0** m | 1.5 m |
| Energy 推出的 F | — | F: -400 … 400 N（`k_max * x`），默认 0 | — |

### View properties（不进物理公式）

公共 `ViewProperties`，默认全 `false`（query `checkAll` 才全开）：

- `appliedForceVectorVisibleProperty`
- `displacementVectorVisibleProperty`
- `equilibriumPositionVisibleProperty`
- `valuesVisibleProperty`

Intro 额外：`numberOfSystemsProperty` 默认 **1**，合法值 `[1, 2]`；`springForceVectorVisibleProperty` 默认 false。

Systems 额外：`systemTypeProperty` 默认 **PARALLEL**；`springForceVectorVisibleProperty` 默认 false；`springForceRepresentationProperty` 默认 **TOTAL**。

Energy 额外：`graphProperty` 默认 **BAR_GRAPH**；`energyOnForcePlotVisibleProperty` 默认 false。

`Values` 勾选：Intro / Systems 仅当 Applied Force、Spring Force、Displacement 至少一个为 true 时 `enabled`。Energy **没有**这条约束，Values 始终可点，并同时控制图上的数值。

---

## 8. 所有用户交互

| 交互 | 屏 | 写入的模型 |
|---|---|---|
| 拖机械手（鼠标/触摸） | 三屏 | `roboticArm.leftProperty` → 弹簧 `displacement` |
| 键盘拖机械手 | 三屏 | 同上，步进见下节 |
| Applied Force NumberControl（滑条 + 左右箭头） | Intro、Systems | `appliedForceProperty`（Systems 写的是 **equivalent**） |
| Spring Constant NumberControl | 三屏 | 对应弹簧 `springConstantProperty`。等效 k **没有**滑条 |
| Displacement NumberControl | 仅 Energy | `displacementProperty` |
| 1 / 2 系统单选 | Intro | 只改 view `numberOfSystemsProperty`，不改已有弹簧数值 |
| 并联 / 串联单选 | Systems | 只切换可见节点。两套模型都留着 |
| Total / Components | Systems | 只切换力箭头可见性。分力仍读各弹簧 Property |
| 向量 / 平衡位置 / Values 勾选 | 三屏 | 纯 view |
| Bar Graph / Energy Plot / Force Plot | Energy | 纯 view `graphProperty` |
| Energy 勾选 | Energy | 仅 Force Plot 下填充三角形 |
| Reset All | 三屏 | `model.reset()` + `viewProperties.reset()` |

滑条步进（必须保留，不能改成“手感合适”的步长）：

| 控件 | 滑块吸附 | 箭头 delta | 键盘 step | shift | page |
|---|---|---|---|---|---|
| Applied Force | 5 N | 1 N | 10 N | 1 N | 25 N |
| Spring Constant | 10 N/m | 1 N/m | 20 N/m | 1 N/m | 100 N/m |
| Displacement | 0.05 m | 0.01 m | 0.10 m | 0.01 m | 0.20 m |

Applied Force 主刻度：min、min/2（无标签）、0、max/2（无标签）、max。次刻度间距 10 N。  
Intro 的 k 主刻度：min、max/2、max（即 100、500、1000），次刻度 100。  
Systems 的 k 主刻度：min、center、max（200、400、600），轨道宽 120（不是默认 180），次刻度 100。  
Energy 的 k 主刻度：从 min 到 max **每 100**（100、200、300、400），次刻度 50。  
Energy 位移主刻度：-1、0、1；次刻度 = 全长/10 = 0.2 m。

显示小数位：力 1 位；并联分力 **2** 位；k 0 位；位移 3 位；能量 **2** 位。力箭头上的数字用 **绝对值**，方向靠箭头。

`numberOfInteractionsInProgressProperty`（每套系统 view 本地，默认 0）：滑条 start/end、拖曳 start/end 时 ±1。夹爪张开条件：

```
interactions === 0 && toFixedNumber(displacement, 3) === 0
```

---

## 9. 所有 drag interaction

唯一拖曳目标：`RoboticHandNode`（`RoboticArmNode.ts`）。

鼠标 / 触摸（`SoundDragListener`，`allowTouchSnag: true`）：

1. start：interaction +1；记录指针相对当前臂长的 offset
2. drag：`length = (parentX - startOffsetX) / UNIT_DISPLACEMENT_X`；`left = right + length`；`rightRange.constrainValue`；再 `roundToInterval(left, 0.01)` m
3. end：interaction -1

键盘（`SoundKeyboardDragListener`）：当前所有调用点都使用默认 `displacementInterval = 0.01`，因此走 **步进分支**，不是文件后半段那套连续 `dragSpeed`。

- `moveOnHoldInterval = 100` ms
- `dragDelta = 0.01` m
- `shiftDragDelta = 0.01` m（与普通拖相同）
- 方向：`modelDelta.x` 非 0 用 x，否则用 y（方向键和 WASD）
- 同样 `constrainValue` 到 `rightRangeProperty`

`0.01` m 间隔是 1.2 release note 的行为（hookes-law#131）：三屏机械手都按 0.01 m 吸附。连续速度分支在当前调用图里到不了。

拖的是模型坐标，不是直接改弹簧 Path。弹簧长度由 `lengthProperty` 驱动 `xScale`。

---

## 10. 所有 control widgets

全部是 scenery-phet / sun，不是 Material。

| 组件 | PhET 类型 | 用途 |
|---|---|---|
| `SpringConstantControl` | `NumberControl` | k。自定义 `springControlLayoutFunction`：标题+读数一行，箭头+滑条一行 |
| `AppliedForceControl` | `NumberControl` | F |
| `DisplacementControl` | `NumberControl` | x，仅 Energy |
| `IntroVisibilityPanel` 等 | `Panel` + `VBox` | 右上。fill `rgb(243,243,243)`，stroke `rgb(125,125,125)`，margin 15 |
| 弹簧控制 Panel | `Panel` | xMargin 20，yMargin 5，align center |
| `VectorCheckbox` | `Checkbox` | 文字 + 箭头图标。boxWidth 18，spacing 8 |
| `EquilibriumPositionCheckbox` | `Checkbox` | 文字 + 绿色虚线段 |
| `ValuesCheckbox` | `Checkbox` | 只有文字 |
| `EnergyCheckbox` | `Checkbox` | 文字 + 青色三角形。仅 Force Plot 时 enabled |
| `NumberOfSystemsRadioButtonGroup` | `RectangularRadioButtonGroup` | 1 或 2。spacing 10，xMargin 20，yMargin 5，选中线宽 2 |
| `SystemTypeRadioButtonGroup` | 同上 | PARALLEL / SERIES。xMargin 5 |
| `SpringForceRadioButtonGroup` | `AquaRadioButtonGroup` | TOTAL / COMPONENTS。半径 8。Spring Force 未勾选时 disabled |
| `EnergyGraphRadioButtonGroup` | `AquaRadioButtonGroup` | BAR_GRAPH / ENERGY_PLOT / FORCE_PLOT |
| `ResetAllButton` | scenery-phet | 右下，距 layoutBounds 右/下各 15 |

滑条尺寸常量：thumb `17×34`，track `180×3`（Systems 的 k 轨道改为 `120×3`），主刻度长 20。箭头按钮 touch dilation 10。

Intro 控件标题是 `Spring Constant {n}:` / `Applied Force {n}:`。Systems 是 `Top Spring:` / `Bottom Spring:` 或 `Left Spring:` / `Right Spring:`，力标题是不带编号的 `Applied Force:`。

---

## 11. 所有 graph / chart

只在 Energy 屏。不是图表库。`XYPointPlot` + `XYAxes` 手绘。

坐标：模型 y 向上对应 scenery **负 y**。原点放在平衡位置的 view x 上：

```
plot.x = systemNode.x + UNIT_DISPLACEMENT_X * equilibriumX
```

`UNIT_DISPLACEMENT_X = 225`（1 m 的 view 长度）。

### Bar Graph（默认）

- 类：`EnergyBarGraph`
- 纵轴：`ArrowNode`，长 `ENERGY_Y_AXIS_LENGTH = 250`，head 10×10，tailWidth 1
- 横轴：长度 `1.65 * 20` 的细线，lineWidth 0.25
- 柱宽 20，fill = `ELASTIC_POTENTIAL_ENERGY`
- 高度 `max(1, E * UNIT_ENERGY_Y)`，`UNIT_ENERGY_Y = 1.1`；柱从 0 向上长
- `E <= 0` 时柱隐藏（零高度矩形画不出来）
- 数值：2 位小数 + `J`；柱太矮时贴在轴上，否则垂直居中在柱顶
- 位置：若当前就是 Bar Graph，x 对齐平衡位置；若同时显示 Energy/Force Plot，柱改到 `layoutBounds.left + 15`
- 柱底：`systemNode.top - 35`

### Energy Plot

- x：位移，范围 `225 * 1.1 * displacementRange` → 约 **±247.5**
- y：0 … 250（view），单位长度 1.1 view/J
- 曲线：`E = kx²/2` 的 **两段 quadraticCurveTo**，不是采样折线。控制点用 x、x/2、0 三点近似
- 断言位移范围关于 0 对称
- stroke 能量色，lineWidth **3**
- 点：半径 5，fill = 单弹簧中蓝 `rgb(0,0,255)`
- 数值在半透明白底上（能量值 `rgba(255,255,255,0.7)`，因为会压到曲线）

### Force Plot

- x 与 Energy Plot 相同
- y：`± FORCE_Y_AXIS_LENGTH/2` = **±125** view
- y 单位长度 `UNIT_FORCE_Y = 0.25` view/N（**不是**场景里力箭头的 `UNIT_FORCE_X = 1.45`）
- 直线 `F = kx`，lineWidth 3，颜色 = applied force
- 能量 = 原点、`(x,0)`、`(x,F)` 的三角形，fill 能量色
- 三角形仅当 `toFixedNumber(x, 3) !== 0` 且 Energy 勾选为 true
- 点颜色同样是单弹簧蓝

### 共用 XY 装饰

- 轴箭头只画正方向
- 引导线 dash `[3,3]`，lineWidth 1
- 刻度线长 12
- 位移向量在图上是 lineWidth 3 的绿线，不是场景里那支带箭头的位移向量
- 数值避让轴：见 `XYPointPlot.ts` 的 X_SPACING / Y_SPACING。不要换成通用 chart 的 label 策略

图 **没有** 采样动画、没有缩放交互、没有用户改坐标范围。k 一变就整段重画。

---

## 12. 所有 assets

本快照 **没有** `images/`、`mipmaps/`、`sounds/`，也没有 png / svg / jpg / webp / gif。

弹簧、墙、机械臂、铰链、夹爪、nib、箭头、图标全部是 scenery / kite 几何或 `ParametricSpringNode`（prolate cycloid，实现在 scenery-phet，不在本仓库）。

`HingeNode` 注释里有 “dependent on image file”，但当前实现是 Path + Circle，没有图片。

因此：**禁止**下载“弹簧图片”或把弹簧栅格化当交互对象。Flutter 应按 `HookesLawSpringNode` 的参数驱动等价的参数弹簧；`ParametricSpringNode` 的曲线方程必须按 scenery-phet SHA `5a91ec98…` 回读后再画。

本仓库传给 `ParametricSpringNode` 的参数：

| 参数 | 值 |
|---|---|
| loops | 单弹簧 12；串联/并联每根 8；图标 3 |
| pointsPerLoop | 40 |
| radius | 10 |
| aspectRatio | 4（y:x） |
| leftEndLength / rightEndLength | 15 / 25 |
| minLineWidth | 3 |
| deltaLineWidth | 0.005 × (k − kMin) |
| 线圈 view 长度 | `length * 225 - (15+25)`，再 `xScale = coilLength / (loops * radius)` |

颜色（弹簧）：

| 角色 | front | middle（主色） | back |
|---|---|---|---|
| 单弹簧（Intro、Energy） | `150,150,255` | `0,0,255` | `0,0,200` |
| 弹簧 1（串联左 / 并联上） | `221,191,255` | `146,64,255` | `124,54,217` |
| 弹簧 2（串联右 / 并联下） | `255,223,127` | `255,191,0` | `217,163,0` |
| 场景选择图标 | `100,100,100` | `50,50,50` | black |

机械臂 fill `210,210,210`，铰链/红盒 `236,35,23`，墙 `180,180,180`，位移/平衡位置 `0,180,0`。

字符串：仅 `hookes-law-strings_en.json`（见第 4 节控件文案）。无中文包。KartosLab 若要中文，Phase 2 再按现有 sim 的本地化方式处理，不能在审计阶段发明译文。

---

## 13. 所有 scenery-phet 原生组件

必须按组件迁移，不能用 Material 顶替：

| 组件 | 使用处 |
|---|---|
| `ParametricSpringNode` | 弹簧与全部弹簧图标 |
| `NumberControl` | k / F / x |
| `ResetAllButton` | 三屏 |
| `SoundDragListener` / `SoundKeyboardDragListener` | 机械手 |
| `ArrowNode` | 力箭头、能量纵轴、XY 轴 |
| `LineArrowNode` | 位移箭头、位移勾选图标 |
| `ShadedRectangle` | 墙（cornerRadius 6，baseColor 墙灰） |
| `BracketNode` | Components 单选图标 |
| `PhetFont` | 见常量：控制 18，刻度 14，柱/图轴 16 |
| `ScreenIcon` | 三屏 Home 图标（几何，不是 png） |
| Keyboard help sections | `MoveDraggableItems` + `SliderControls` + `BasicActions(withCheckboxContent)` |

sun：`Panel`、`Checkbox`、`AquaRadioButton` / `AquaRadioButtonGroup`、`RectangularRadioButtonGroup`、`ArrowButton`、`Slider`（包在 NumberControl 里）、`HSeparator` / `VSeparator`。

---

## 14. 所有重要 layout constants

集中在 `HookesLawConstants.ts`。Flutter 必须收进一个 constants 文件，禁止散落 `Offset(123, 456)`。

**模型→view（不是 ModelViewTransform2）。** implementation notes 写明：一维，用单位长度，不用 `ModelViewTransform2`。

| 常量 | 值 | 含义 |
|---|---|---|
| `UNIT_DISPLACEMENT_X` | 225 | 1 m 位移的 view 长度。三屏弹簧、位移箭头、图的 x 都用它 |
| `UNIT_FORCE_X` | 1.45 | 场景力箭头：1 N 的 view 长度 |
| `ENERGY_UNIT_FORCE_X` | 0.4 | **仅 Energy 屏**场景里的施力箭头 |
| `UNIT_FORCE_Y` | 0.25 | Force Plot 的 1 N |
| `UNIT_ENERGY_Y` | 1.1 | 1 J 的 view 高度 |
| `WALL_SIZE` | 25 × 170 | 墙 |
| `VECTOR_HEAD_SIZE` | 20 × 10 | 力箭头头 |
| `ROBOTIC_ARM_DISPLACEMENT_INTERVAL` | 0.01 m | 拖曳吸附 |
| `ARM_HEIGHT` | 14 | 伸缩臂矩形高 |
| 红盒 | 7 × 30 | 臂右端，颜色同铰链 |
| 渐变盒 | 20 × 60 | 红盒右侧，竖直白-灰渐变 |
| 铰链 | body 9×40，pivot 26×25，螺钉半径 3 | `HingeNode` |
| 夹爪 | 半径 35，线宽 6，overlap 2 | 开/合是两套弧的 visible 切换，没有补间 |
| nib | 10 × 8，cornerRadius 2 | Intro/Energy/串联右端跟弹簧中色；并联黑色 |
| 并联桁架 | lineWidth 4，黑色，上下各伸出弹簧 10 | 跟 equivalent.right 走 |

场景原点：弹簧与墙的连接点，y = 0。墙的 **右中** 贴在 `left * 225`。

经验间距（源码写了 empirically，迁移时保留这些数，不要为了“好看”改）：

| 位置 | 值 |
|---|---|
| 右上控件 | `layoutBounds.right - 10`，`top + 10`，VBox spacing 10 |
| Reset All | `maxX - 15`，`maxY - 15` |
| Intro 系统 left | `layoutBounds.left + 15` |
| Systems 系统 left | `layoutBounds.left + 30`，centerY = layoutBounds.centerY |
| Energy 系统 | left `+ 35`，bottom `layoutBounds.bottom - 10` |
| 控制面板 top | 墙底 + 25（Intro/Systems）；Energy 为墙底 + 10 |
| 力箭头 | Intro/Energy 大约在弹簧 y 上 50；Systems 并联在上弹簧 y - 80 |
| 位移箭头 | 弹簧 y + 50 |
| visibility 勾选 spacing | 20，minContentWidth 150 |
| Components 单选缩进 | leftMargin 25 |

Intro 动画目标（变量名 `system1CenterXForTwoSystems` 实际是 **Y**）：

- 1 套：system1.centerY = layoutBounds.centerY；system2.visible = false
- 2 套：system1.centerY = layoutBounds.minY + 0.25 * height；system2.centerY = 0.75 * height

---

## 15. viewport / layoutBounds

三屏 `ScreenView` 构造只传了 `tandem`，**没有**覆盖 `layoutBounds`。本快照不含 joist 源码。

PhET 自 2014-12（joist#542）起，`ScreenView` 默认 layoutBounds 是 **1024 × 618**。Home 屏仍是 **768 × 504**（`HomeScreenView.LAYOUT_BOUNDS`）。导航栏高度由 joist `NavigationBar` 决定，sim 内容区在导航栏上方。

本次审计 **没能** 从 joist SHA `bb6a94e0…` 把 `ScreenView.ts` 下载下来再核对该常量（网络中断）。Phase 2 布局前必须用该 SHA 确认：

- `ScreenView.DEFAULT_LAYOUT_BOUNDS`
- `NavigationBar` 高度
- `visibleBounds` 与 `layoutBounds` 的 letterbox 方式

在确认前，不要把 Flutter `SafeArea` / `AppBar` / `Scaffold` 当成原版视口。原版没有 AppBar。

---

## 16. reset 行为

每屏 Reset All：

```
model.reset()
viewProperties.reset()
```

| 对象 | reset 恢复 |
|---|---|
| `Spring` | F、k、x、left 回到各自 range 的 defaultValue |
| `RoboticArm` | `leftProperty` |
| `IntroModel` | system1 与 system2 |
| `SystemsModel` | 串联与并联 **都** reset，包括当前不可见的那套 |
| `EnergyModel` | 唯一的 system |
| Intro view | 系统数回到 1；弹簧力勾选 false；公共勾选 false |
| Systems view | 回到 PARALLEL、TOTAL、勾选全 false |
| Energy view | 回到 BAR_GRAPH；`valuesVisibleProperty` 被 reset 两次（子类一次、`super` 一次）；能量勾选 false |

派生量（springForce、right、energy、keq）没有独立状态，随主 Property 重算。

`numberOfInteractionsInProgressProperty` **不在** model.reset 里。它靠指针 start/end 配对。Reset 是否会打断正在进行的拖曳，取决于 scenery-phet `ResetAllButton`（不在本仓库）。Phase 5 必须核对：reset 之后 interaction 计数为 0，夹爪状态与位移一致。

Intro 的 1↔2 动画：`numberOfSystemsProperty.reset()` 会再走一遍 animator。PhET-iO 设状态时跳过动画直接到终态；普通 Reset 会播放 0.5 s + 0.5 s。

切屏不 reset。

---

## 17. keyboard / accessibility 行为

`package.json`：`supportsInteractiveDescription: true`。

三屏都提供 `HookesLawKeyboardHelpContent`：左栏可拖对象 + 滑条，右栏基本操作（含 checkbox）。

机械手：`tagName: 'div'`，`focusable: true`，`AccessibleDraggableOptions`，`InteractiveHighlighting`。PDOM 顺序：

- Intro play：system1，system2；control：右上控件，Reset
- Systems play：series，parallel；control：右上控件，Reset
- Energy play：system；control：visibility panel，Reset

滑条键盘步进见第 8 节。方向键 / WASD 驱动机械手，步进 0.01 m。

Flutter 第一阶段不必做完整 PhET PDOM，但键盘步进和拖曳步进是 **行为**，Phase 5 不能丢。

---

## 18. audio 行为

`supportsSound: true`。本仓库 **没有** 声音文件。

发声点：

- `NumberControl.valueChangeSoundGeneratorOptions.numberOfMiddleThresholds` = 范围长度 / 键盘 step（取整）
- `SoundDragListener` / `SoundKeyboardDragListener` 的 scenery-phet 默认拖曳声

没有弹簧振动声、没有自定义增益曲线。不要自己加一套物理音效。

---

## 19. source 中已有的测试

**没有** `tests/` 或 `*.spec.*` / `*.test.*`。本 sim 不带自动化测试。

Flutter 的 `test/hookes_law/` 要从本审计的公式和边界新写，不能对照一个不存在的 PhET test suite。

---

## 20. Flutter 迁移风险点

按优先级：

1. **参数弹簧。** 外观在 scenery-phet `ParametricSpringNode`，本仓库只有 loops / scale / 线宽。不回读该 SHA 就会画出“差不多的螺旋”。这是 P0/P1 视觉风险，不是模型风险。
2. **F↔x↔arm 的重入与 10 位小数。** 物理课本上的 `F=kx` 不够。必须复现 `toFixedNumber(..., 10)`、range constrain、以及 Systems 的 `ignoreUpdates`。否则拖曳会振荡或钳位不一致。
3. **Intro/Systems 与 Energy 的自变量不同。** 改 k 时谁变，由构造时传了 force range 还是 displacement range 决定。两套逻辑必须留在同一个 `Spring`，不能拆成两个“更清晰”的类后丢掉分支。
4. **没有质量、没有阻尼、没有弹簧动画。** 松手后停在当前位移。唯一动画是 Intro 1↔2 的 0.5 s 线性平移 + 0.5 s 线性透明度。不要加振荡“让它更像弹簧”。
5. **拖曳吸附 0.01 m。** 三屏都有。看起来像“不够顺”是源行为。
6. **力箭头有三套比例：** 场景 1.45、Energy 场景 0.4、Force Plot 0.25。混用会让 Energy 的箭头或图立刻错。
7. **图是二次贝塞尔近似 + 三角形面积**，不是 fl_chart。控制点公式在 `EnergyPlot.ts`。
8. **Total / Components 只改可见性。** 并联分力小数是 2 位，串联分力是 1 位。串联 Components 时，左弹簧施力箭头用的是 **弹簧 2 的黄色**，左弹簧力是紫色，右弹簧力是黄色。不要“纠正”成对称配色。
9. **Values 的 enabled 规则** Intro/Systems 与 Energy 不同。
10. **layoutBounds 未在本仓库钉死。** Phase 2 前用 joist SHA 确认 1024×618 是否仍是该提交的默认值。
11. **joist Home / 导航栏** 不在本 sim 里。KartosLab Home 接入是 Phase 9，本审计不设计导航。
12. **依赖源码不在本地。** Reset 按钮球面高光、NumberControl 滑块皮、Checkbox 皮、拖曳声，都要对照已有 KartosLab L0（例如 `KratosResetAllButton`）或按 SHA 补读。不能用 `Icons.refresh`。
13. **三屏模型独立、切屏不 reset、Reset 会重置不可见的那套系统。**
14. **截图不是默认态。** Intro 截图 F = 2.0 N，说明有人拖过或拨过滑条。默认 F = 0，夹爪张开。
15. **版本号三处不一致**（1.3.0-dev.0 / 1.2.0-dev.3 注释 / release 1.2）。行为以 ts 为准。若 published `latest` 与这份 ts 不一致，记 VERSION_DELTA，禁止用 latest 覆盖本地公式。
16. **无测试、无栅格资源。** 测试从公式写；资源从几何重建。

---

## 文件树（本仓库全部行为代码）

```
js/hookes-law-main.ts
js/common/model/Spring.ts
js/common/model/SingleSpringSystem.ts
js/common/model/RoboticArm.ts
js/common/HookesLawConstants.ts
js/common/HookesLawColors.ts
js/common/HookesLawUtils.ts          # springControlLayoutFunction
js/common/HookesLawQueryParameters.ts # 仅 checkAll
js/common/view/…                     # 弹簧、臂、墙、力/位移箭头、三个 NumberControl
js/intro/…
js/systems/…
js/energy/…
doc/model.md
doc/implementation-notes.md
doc/release-notes.md
hookes-law-strings_en.json
package.json
dependencies.json
```

70 个 `.ts`。没有 tests，没有图片，没有音频。

---

## Phase 1 允许迁移的模型面（预告，本阶段不写代码）

只迁移 `Spring` + `RoboticArm` + `SingleSpringSystem` + `SeriesSystem` + `ParallelSystem` + 三个 Screen model 的 reset/范围。

不要建 mass。不要在 Phase 1 画弹簧。View 层禁止自己算 F、k、x、E；Systems 的分力必须读各 `Spring` 的 Property。

建议测试（行为，不是凑数量）：

- 默认：F=0，x=0，E=0，夹爪条件用的位移显示为 0.000
- Intro：F=100、k=200 → x=0.5；k 改为 100 时 F 仍为 100、x 变为 1；k=1000、F=100 → x=0.1
- Energy：x=1、k=100 → F=100、E=50；k 改为 400 时 x 仍为 1、F=400、E=200
- 力钳位与 10 位小数往返（先设 x 再读 F，再设 F 再读 x）不发散
- 串联：F 相同；keq = 调和；右弹簧 left 跟左弹簧 right；x1+x2 与等效位移一致（在浮点容差内）
- 并联：x 相同；keq = k1+k2；F1+F2 与 Feq 一致（在浮点容差内）
- 负位移：F 为负，E 仍非负，springForce = -F
- 边界：F=±100、k 最小/最大、Energy x=±1
- reset 回到上表默认，包括当前不可见的 Systems 配置

---

## 本阶段结论

SOURCE AUDIT：**完成**。  
Flutter 实现：**未开始**。  
状态：**NOT READY**（预期；Phase 0 不应是 READY）。

下一步只允许 Phase 1 Model。进入 Phase 1 之前，不写 UI。
