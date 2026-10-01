# Phase 0 — Project Discovery · Circuit Construction Kit: AC - Virtual Lab

> 需求：`req-cck-ac-virtual-lab`  
> 日期：2026-09-02  
> 阶段：Phase 0 完成 · 无阻塞决策 · 自动进入 Phase 1  
> 标记：`[已确认]` 有源码/配置/目录依据 · `[推测]` 有依据的推断 · `[待确认]` 证据不足

---

## 0. 结论摘要

1. **KARTOSLAB** 是独立 Flutter App（包名 `kratos`，SDK `^3.11.1`），入口 `lib/main.dart` → `HomeScreen`，无 GoRouter。[已确认]
2. Home 已有「电路搭建」（`lib/circuit/`）。那是 **DC 简化沙盒**（电池/电阻/灯泡/开关/保险丝/接地 + 自研 MNA），**不是** PhET CCK AC Virtual Lab。[已确认 `lib/circuit/` + `docs/knowledge/kratos/systems/circuit-module.md`]
3. 原版是 PhET HTML5/TypeScript **`circuit-construction-kit-ac-virtual-lab` 1.1.0-dev.0**，不是 Java。[已确认 `package.json`]
4. VL 包本身只有入口：`new LabScreen(tandem, false)`。`false` = **不显示非接触安培计**。[已确认 `js/circuit-construction-kit-ac-virtual-lab-main.ts:27-28`]
5. 真正模型/视图在 **`circuit-construction-kit-ac`（LabScreen / LabScreenView）** 与 **`circuit-construction-kit-common`（Circuit / LTA / MNA / CCKCScreenView）**。用户给的本地路径只有薄封装；本阶段已 clone 两个依赖到 `phet sourses/`。[已确认]
6. 默认求解器是 **PhET 自研 MNA + companion 模型（LTACircuit）**。`?solver=spice` 分支在 `LinearTransientAnalysis.ts` **被注释掉**，发布路径走不到 ngspice。[已确认 `LinearTransientAnalysis.ts:43-51`]
7. 单屏 Lab，无 Tab。推荐落点：`lib/cck_ac_virtual_lab/`，Home「物理 → 电学与电路」新增卡片，**不改、不合并**现有 `lib/circuit/`。[已确认不合并 · 类比 Kepler vs 已有 sim]
8. 无 Undo。Reset All 重置整个 `CircuitConstructionKitModel`。[已确认 grep `undo` 无业务命中 + `CircuitConstructionKitModel.reset`]
9. 当前工程 **无** CCK AC 旧实现可归档。`lib/circuit/` 是另一产品，Phase 12 不删除。[已确认]

---

## 1. 当前 KARTOSLAB 工程

### 1.1 根与入口

| 项 | 值 | 证据 |
|---|---|---|
| 工作区 | `KartosLab/`（包名 `kratos`） | `pubspec.yaml:1` |
| SDK | `^3.11.1` | `pubspec.yaml:22` |
| 入口 | `lib/main.dart` → 横屏锁定 → `KratosApp` → `HomeScreen` | `lib/main.dart:7-46` |
| 路由 | `Navigator.push(MaterialPageRoute)`，无命名路由 | `home_screen.dart:440-443` |
| 依赖 | `flutter_svg ^2.3.0` · `audioplayers ^6.7.1` | `pubspec.yaml:36-38` |
| AGENTS.md 路径 | 写 `c:\workspace\kratos`，与本工作区不一致 | 以本仓库为准 [已确认] |

### 1.2 `lib/` 学科目录

```
lib/
  main.dart
  screens/home_screen.dart
  common/                         # L0
  circuit/                        # 既有 DC 沙盒（保留）
  forces/  optics/  color_vision/
  sound/  radio_waves/  wave_interference/
  magnetism/magnet_and_compass/
  astronomy/keplers_laws/  astronomy/my_solar_system/
  density/
  chemistry/molarity/  chemistry/build_a_nucleus/
```

**无** `cck_ac*` / `circuit_construction_kit*`。[已确认 glob]

已注册 sim（截至 2026-09-02）：力与运动 / 密度 / 电路搭建 / 磁铁与罗盘 / Kepler's Laws / My Solar System / 几何光学 / 色觉 / 波的干涉 / 声波 / 电磁波 / 摩尔浓度 / 构建原子核。Home **无** CCK AC Virtual Lab。[已确认 `lib/screens/home_screen.dart`]

### 1.3 Home 注册

`HomeScreen._disciplines`：物理（力学 / 密度与浮力 / 电学与电路 / 电磁学 / 天体力学 / 光学与波动）+ 化学。点击卡片 `MaterialPageRoute` 进 Screen。[已确认]

「电学与电路」目前只有一张卡：`电路搭建` → `CircuitScreen`。本 sim 应作为 **第二张卡** 加入该组，不替换第一张。

### 1.4 common（L0）与本 sim 相关度

| L0 | 路径 | 本 sim | 判定 |
|---|---|---|---|
| NineGridLayout | `common/widgets/nine_grid_layout.dart` | 页面级外壳 | **复用**（center ≥70% 放电路画布） |
| KratosTabbedScreen | `common/widgets/kratos_tab_bar.dart` | 单屏 Lab | **不用**（原版只有 1 个 joist Screen） |
| SimulationClock | `common/simulation_clock.dart` | 60 fps step | **复用心跳**；暂停时仍以 `PAUSED_DT=1E-6` 解电路 [已确认 `CCKCConstants.PAUSED_DT`] |
| TimeControlBar | `common/widgets/time_control_bar.dart` | Play/Pause/Step + Stopwatch | **不直接套**。原版是 `TimeControlNode` + 可选秒表，且暂停时物理仍微步进 |
| KratosSlider | `common/controls/kratos_slider.dart` | 元件 NumberControl | **可用语义**，外观按原版 NumberControl / CCKCConstants.SLIDER_* |
| KratosComboBox | `common/controls/kratos_combo_box.dart` | schematic IEEE/IEC | 偏好项，一期可不做 [有意差异] |
| KratosRadioGroup | `common/controls/kratos_radio_group.dart` | Lifelike/Schematic · 电子/常规电流 | **可用语义** |
| PropertyControlPanel | `common/widgets/property_control_panel.dart` | scenario 驱动面板 | **不用**（无 scenario） |
| DragDropWorkspace | `common/widgets/drag_drop_workspace.dart` | 托盘 | **不套卡片托盘**。原版是垂直 Carousel（8 项/页，`AC_CAROUSEL_SCALE=0.85`），视觉语义不同。可复用 Flutter `Draggable`/`DragTarget`，不改 common |
| SnapshotChart / GraphSuite | `common/chart/` | V/I 时序图 | **不套**。原版是 `VoltageChartNode` / `CurrentChartNode`（bamboo + 4 个 time division） |
| ScenarioManagerBase | `common/scenario/` | JSON 场景 | **不用**。原版是空画布沙盒 |

G3：CCK 元件树 / LTA-MNA / ChargeAnimator / Carousel 工具箱均为 **第 1 个 CCK-AC 用户**，留在 sim 内。既有 `lib/circuit` 的 DC MNA **不是** companion 时域求解器（无 C/L/AC），相似度 < 70%，**不上抽、不合并**。

### 1.5 已有 sim 架构范式（选最近邻，不复制 BAN）

| 范式 | 代表 | 数据流 |
|---|---|---|
| 可变 Model + Clock + setState | sound / wave / radio / magnet | tick 改字段 |
| 不可变 State + Solver | 既有 circuit / optics | copyWith |
| ChangeNotifier Controller | molarity / BAN / Kepler | 命令进 Controller |

CCK 最近邻：**可变电路图 + 每帧求解 + 拖拽工作区**（既有 circuit 的拖放 + Kepler 的 Controller + Clock）。

**禁止**把 BAN 的核素仓库抄进来。  
**禁止**把既有 `lib/circuit` 的 `ComponentType` 七枚举当成 CCK 元件模型——CCK 有 AC 源、电容、电感、日用品、串联安培计、电压表探头、电荷粒子。

推荐：

```
CckAcState（SSOT 快照，给 Render）
  + Circuit graph（Vertex / CircuitElement 可变运行时，Controller 持有）
  + LtaMnaSolver（纯计算，无 Widget）
  + CckAcController（tick / drag / snap / reset）
  + Render DTO + 分元件 Painter
```

NineGrid：页面外壳。电路对象、探头、电荷 **留在 center Canvas 的局部坐标**，不拆进九宫格边格。

### 1.6 与既有 `lib/circuit` 的关系（硬边界）

| | 既有 `lib/circuit` | 本 sim（CCK AC VL） |
|---|---|---|
| 产品 | 中文 DC 搭建沙盒 + JSON 场景 | PhET CCK AC Lab 单屏 |
| 元件 | battery/resistor/lightBulb/switch/wire/fuse/ground | 另含 AC、C、L、fuse、日用品、series ammeter；**无 ground 独立元件**；无非接触安培计 |
| 求解 | 静态 DC MNA（无 companion） | 时域 LTA + companion C/L + AC `sin` |
| 视图 | 自制 SVG 图标 + 网格 | Lifelike PNG + Schematic 折线 |
| 传感器 | 无电压表探头 | 2 电压表 + 串联安培计 + 可选图表 |
| 时钟 | 无连续时间（除交互） | 60 fps；暂停仍 `PAUSED_DT` |

用户规则：**不修改其他已完成 simulation**；**合并两个行为不同的实现必须先确认**。因此本迁移 **新建独立目录**，零改 `lib/circuit/**`。

### 1.7 tests / assets / schemas / requirements

- `test/`：各 sim 专项 + common。无 cck-ac。`test/circuit_layout_test.dart` 只覆盖既有 DC 屏。
- `integration_test/`：`app_test.dart` 等 4 个。Home 回归时只 **追加** 入口，不改其他 sim 断言语义。
- `assets/`：既有 `assets/images/{battery,bulb,resistor,wire,fuse,ground,switch_*}.svg` 属于 DC 沙盒，**不复用冒充** CCK lifelike PNG。
- `schemas/`：有 `circuit_scenario.schema.json`（既有 DC）。本 sim 原版无 scenario → **不做假 schema** [有意差异，同 Kepler]。
- `requirements/`：本需求新建 `req-cck-ac-virtual-lab/`。

### 1.8 rules / instructions

| 文件 | 对本 sim |
|---|---|
| `80-kratos-sim-checklist.mdc` | NineGrid ≥70%、无溢出、响应式；L0 复用 |
| `00` / `10` / `20` / `60` | 读后改、30min、知识库优先、引用先行 |
| 用户本次指令 | 分阶段、源码保真、NineGrid 不吞模拟对象、不改无关 sim |
| checklist 配置化 JSON | 与原版空沙盒冲突 → **[有意差异] 不做假 scenario**（Kepler 已有先例） |

### 1.9 知识库对照

- `docs/knowledge/kratos/systems/circuit-module.md`：描述的是既有 DC 模块，**不是**本 sim 蓝本。
- `docs/knowledge/kratos-java-simulations/existing-flutter-map.md`：Java CCK 用 Jama；Flutter DC「故意简化」。本任务蓝本是 **HTML5 CCK common**，不是 Java。
- Java CCK **不作为**本迁移源码优先级（用户指定 HTML5 VL）。

---

## 2. 原版 PhET 调查

### 2.1 身份

| 项 | 值 |
|---|---|
| 官网运行 | https://phet.colorado.edu/sims/html/circuit-construction-kit-ac-virtual-lab/latest/circuit-construction-kit-ac-virtual-lab_all.html |
| 源码（薄封装） | https://github.com/phetsims/circuit-construction-kit-ac-virtual-lab |
| 版本 | `1.1.0-dev.0` · GPL-3.0 |
| 本地 VL | `phet sourses/circuit-construction-kit-ac-virtual-lab-main/...` |
| 本地 AC | `phet sourses/circuit-construction-kit-ac/`（本阶段 clone） |
| 本地 common | `phet sourses/circuit-construction-kit-common/`（本阶段 clone） |
| 作者 | Sam Reid（入口注释） |
| 标题字符串 | `"Circuit Construction Kit: AC - Virtual Lab"` [已确认 `circuit-construction-kit-ac-virtual-lab-strings_en.json`] |

官方说明：*This simulation consists of the Lab screen from Circuit Construction Kit: AC and excludes non-contact ammeters.* [已确认 VL `doc/model.md`]

### 2.2 启动图

```
simLauncher.launch
  → CCKCSim(title, [ LabScreen(labScreen, showNoncontactAmmeters=false) ])
       → CircuitConstructionKitModel(includeAC=true, includeLab=true, { showNoncontactAmmeters:false })
       → LabScreenView(model, view, false)
  → soundManager.setOutputLevelForCategory('user-interface', 0)
```

证据：`circuit-construction-kit-ac-virtual-lab-main.ts:26-42` + `LabScreen.ts:23-41`。

`CCKCSim` 只是 `joist.Sim` 子类，无额外逻辑。[已确认 `CCKCSim.ts`]

完整 AC 仿真有三屏（AC Voltage / RLC / Lab）。**VL 只实例化 Lab**。[已确认 `circuit-construction-kit-ac/package.json` `screenNameKeys` vs VL 入口数组长度 1]

### 2.3 Lab 工具箱（Carousel · 垂直 · 8/页）

`LabScreenView.ts:31-67` [已确认]：

**第 1 页：** Wire, Battery, AC Voltage, LightBulb, Resistor, Capacitor, Inductor, Switch  
**第 2 页：** Wire, Fuse, DollarBill, PaperClip, Coin, Eraser, Pencil, ThinPencil  

Lab 选项：

| 选项 | 值 |
|---|---|
| toolboxOrientation | `'vertical'` |
| showCharts | `true` |
| showTimeControls | `true` |
| showStopwatchCheckbox | `true` |
| showSeriesAmmeters | `true` |
| carouselScale | `CCKCConstants.AC_CAROUSEL_SCALE` = **0.85** |
| itemsPerPage | **8** |
| showPhaseShiftControl | `true` |
| hasACandDCVoltageSources | `true` |
| showAdvancedControls | `true` |

### 2.4 Model 层（common）

`CircuitConstructionKitModel` 持有：

- `circuit: Circuit`
- `voltmeters[2]`、`ammeters[2]`（VL 下非接触安培计 tandem OPT_OUT）
- `viewTypeProperty` 默认 **LIFELIKE**
- `showLabelsProperty` 默认 true；`showValuesProperty` 默认 false
- `zoomLevelProperty` 索引进 `ZOOM_SCALES = [0.5, 1, 1.6]`，默认 1
- `animatedZoomScaleProperty` + `ZoomAnimation`（0.35s cubic-in-out）
- `isPlayingProperty` 默认 true（仅 AC 构建 tandem）
- `stopwatch`
- `addRealBulbsProperty`（Lab 才 tandem）
- `step(dt)`：若 `dt >= MAX_DT(0.5)` 忽略；播放则 `stepOnce(1/60)`，暂停则 `stepOnce(PAUSED_DT)`；脏电路暂停也解

`Circuit.step`：若 dirty 或存在动态元件 → `LinearTransientAnalysis.solveModifiedNodalAnalysis`。

### 2.5 Solver

文档仍写 `DynamicCircuit.js`；代码已重构为：

```
Circuit.step
  → LinearTransientAnalysis.solveModifiedNodalAnalysis
       → solveWithPhetMNA   // spice 分支被注释
            → 过滤 isInLoop
            → 建 LTACircuit（电阻/电池/电容/电感 companion）
            → TimestepSubdivisions
            → 写回电流/电压
```

目录：`js/model/analysis/`（LTA*）+ `analysis/mna/`（MNACircuit QR）+ `analysis/spice/`（未接入主路径）。

Query：`batteryMinimumResistance=1E-4`，`wireResistivity=1E-10`，`capacitorResistance=1E-4`，`inductorResistance=1E-4`。[已确认 `CCKCQueryParameters.ts`]

**日用品电阻（源码优先于 model.md）**：`ResistorType.ts` 用 `LARGE_RESISTANCE = 1E6`（不是文档写的 1E9），Coin/PaperClip = 0，Pencil = 25，ThinPencil = 50。[已确认；model.md 过时]

### 2.6 AC 电压公式

`ACVoltage.step` [已确认 `ACVoltage.ts:120-123`]：

```
V = -maximumVoltage * sin(2π f t + phase° · π/180)
```

- `maximumVoltage` 默认 9.0，范围 0–120
- `frequency` 默认 0.5 Hz，范围 0.1–2.0
- `phase` 默认 0，范围 -180–180°
- 每步 `circuit.dirty = true`

### 2.7 View / 交互 / 时钟 / Reset / Undo

| 主题 | 事实 | 证据 |
|---|---|---|
| 坐标 | Scenery ScreenView + CircuitNode 局部电路坐标 | `CCKCScreenView` |
| 拖放 | 工具箱 `CircuitElementToolNode` 拖出；Vertex/Wire/FixedElement DragListener；松手回工具箱 hit box 比例 0.2 | `CCKCConstants.RETURN_ITEM_HIT_BOX_RATIO` |
| 点击阈值 | 15 px 内算 tap 不算 drag | `TAP_THRESHOLD` |
| 键盘拖 | `KEYBOARD_DRAG_SPEED=400`，Shift=50 | constants |
| 电流可视化 | ChargeAnimator，电荷间距 28 | `CHARGE_SEPARATION` |
| 保险丝 | 过流熔断 + `FuseTripAnimation` + 修复音 | view + sounds |
| Reset | `ResetAllButton` → `model.reset()` | CCKCScreenView + Model.reset |
| Undo | **无** | grep 无业务 undo |
| 音效 | cut / breakFuse / repairFuse；VL 关闭 UI 音 | sounds + 入口 |
| 偏好 | `CCKCSimulationPreferencesContentNode` | 入口 |

右侧面板（CCKCScreenView 组装）：ViewRadioButtonGroup（lifelike/schematic）、DisplayOptionsPanel（电流/标签/数值/秒表）、AdvancedAccordionBox（电池内阻、导线电阻率）、SensorToolbox（电压表；VL 无非接触安培计）、Zoom、图表、时间控制、Reset 右下。

### 2.8 Assets

**VL `images/license.json` 为空对象** `{}`，VL 包自身无运行时图。[已确认]

**common/images**（lifelike PNG 模块）：battery, batteryHigh, resistor, resistorHigh, fuse, lightBulbFront/Back/Real/High, wireIcon, coin, paperClip, pencil, thinPencil, eraser, dollar, hand, fire, ammeterBody。

**common/mipmaps**：voltmeterBody, probeRed, probeBlack, lightBulbMiddle*。

**common/sounds**：cut, breakFuse, repairFuse（mp3.js 模块）。

**ac/images**：screenIconLab（Home 卡可用）。

复制到 Flutter 时只拷贝原版存在的文件，**不自制替代**。

### 2.9 生命周期 / 导航 / 数据

- joist 单 Screen，无场景 JSON，无持久化（除 PhET-iO，本工程不做）。
- 离开即销毁；再进应 `reset` 等价的新 Controller。
- 响应式：`visibleBoundsProperty` 驱动 Reset/TimeControl 贴边；探头 `DRAG_BOUNDS_EROSION=20`。
- 无多语言一期（[有意差异]）。

### 2.10 规模（风险，非阻塞）

common：~190 ts/js + images/mipmaps/sounds；`Circuit.ts` ~84 KB；view 层 50+ Node。  
这是本仓库迄今最大的单 sim。架构仍可确定（独立目录 + 移植 LTA/MNA）。实现按 Phase 4→11 切片，不在 Phase 0 缩小范围。

---

## 3. 80-kratos-sim-checklist 预检（Phase 0 级）

### 原则 1 MVC

- Model：`lib/cck_ac_virtual_lab/model/`  
- Solver：`solver/`（LTA + MNA）  
- Controller：`controller/`  
- View：`view/` `painters/` `screens/`  
- View 不改求解状态；tick / 拖拽只进 Controller。

### 原则 2 元件化

每类元件独立 Painter（Wire / Battery / AC / Bulb / Resistor / C / L / Switch / Fuse / 日用品 / SeriesAmmeter / Vertex / Charge / Voltmeter）。禁止 God Painter。

### 原则 3 L0

见 §1.4。不抽 CCK 专用类型到 common。

### 原则 4 配置化

原版无 scenario。[有意差异] 不做假 JSON。EDD §9 将显式声明「不适用」。

### 布局 L0-1…L0-4

NineGrid 页面级；center 电路 Canvas + LayoutBuilder；禁止硬编码主画布像素。Reset 可贴 center 右下 Positioned（磁铁 FieldMeter / Kepler 先例），不进边格。

---

## 4. 不需要用户拍板的架构选择（≥95%）

| 选择 | 理由 |
|---|---|
| 新建 `lib/cck_ac_virtual_lab/`，不改 `lib/circuit/` | 行为不同；合并需确认 → 我们选择不合并 |
| 移植 PhET MNA/LTA，不嵌 ngspice | spice 分支被注释；默认 `solver=phet` |
| 单屏，不用 KratosTabbedScreen | VL 只有 LabScreen |
| 不做 scenario JSON | 原版是空沙盒 |
| 不做 Undo | 原版无 Undo |
| 不抽 common | 第 1 个 CCK-AC 用户 |

无不可逆冲突。进入 Phase 1。

---

## 5. 已知缺口（记录，不阻塞 Discovery）

| ID | 项 | 标记 |
|---|---|---|
| G-1 | 原版运行时视口截图（DPR/play area 测量） | [待确认：缺少原版运行截图] · Phase 2 |
| G-2 | `ACVoltage` 构造用 `BATTERY_LENGTH` 而非 `AC_VOLTAGE_LENGTH` | [待确认] Phase 1 核对 Node 缩放 |
| G-3 | model.md 日用品电阻与 `ResistorType.ts` 不一致 | [已确认以源码为准] |
| G-4 | ThinPencil=50Ω 未写入 model.md | [已确认源码] |
| G-5 | 键盘拖 / PDOM / PhET-iO / 多语言 | [有意差异] 一期可不做 |
| G-6 | `hand` 电阻类型存在但 Lab 工具箱未列出 | [已确认] 不实现未列出工具 |
| G-7 | Extreme resistor / real bulbs 由 Lab `addRealBulbs` 控制 | Phase 1 核对是否出现在工具箱 |

---

## 6. 下一阶段

**Phase 1 — Source Analysis**：对 `Circuit.ts` / `LTACircuit.ts` / `MNACircuit.ts` / `TimestepSubdivisions.ts` / 拖拽监听 / ChargeAnimator / CCKCScreenView 布局 / 图表采样 给出源码证据级解密。
