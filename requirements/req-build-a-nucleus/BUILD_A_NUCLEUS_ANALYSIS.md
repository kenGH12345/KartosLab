# Build a Nucleus → KARTOSLAB Flutter 迁移分析

> 需求 ID：`req-build-a-nucleus`
> 目标：将 PhET《Build a Nucleus》高保真迁移为当前 Flutter 工程的原生实现
> 阶段：第一阶段 · 仅分析，不实现
> 生成日期：2026-08-28
> 证据标记约定：**[已确认]** 有源码/配置/文档/实际行为依据；**[推测]** 有依据的合理推断（附依据）；**[待确认]** 证据不足

---

## 0. 结论摘要

1. Build a Nucleus 是 **HTML5 / TypeScript** 的 PhET 新世代模拟器，**不是 Java 遗留 sim**。[已确认]（`package.json`、`js/**/*.ts`）
2. 它有 **2 个 Screen**：`Decay`（衰变屏）与 `Chart Intro`（核素图导览屏）。[已确认]（官网 `_all.html` 屏选择页 + `package.json.screenNameKeys` + `js/build-a-nucleus-main.ts`）
3. 核模型**数据驱动**：稳定性、半衰期、衰变模式全部来自 shred 仓库内置的 ENSDF 2022 数据表（`AtomData.ts`），经 `AtomInfoUtils` 查询。[已确认]
4. 核心交互是「**从底部核子生成器拖出 / 点击箭头按钮增减质子中子 → 组装原子核 → 触发衰变动画**」，与当前工程 **circuit / optics 的 `DragTray + DropCanvas` 模式同构**。[已确认]
5. 当前工程可复用：`NineGridLayout`、`DragTray`/`DropCanvas`/`CanvasProjection`、`SimulationClock`、`ScenarioManagerBase`、`KratosSlider/ComboBox/NumberField`、探究抽屉全家桶。**缺口**：圆形核子精灵、画布内已放置粒子再拖动、独立 Reset 按钮、Checkbox、核素数据表。[已确认]
6. 推荐落点：**`lib/chemistry/build_a_nucleus/`**（与 `lib/chemistry/molarity/` 同级，化学学科分组下）。[推测]（依据：HomeScreen 按学科分组 + chemistry 目录已存在；详见 §16）

---

## 1. 当前 KARTOSLAB 工程结构理解

实际仓库根：`d:\OneDrive\Desktop\KartosLab\KartosLab`（包名 `kratos`，Flutter SDK `^3.11.1`）。[已确认]（`pubspec.yaml`）

> 注：`AGENTS.md` 中写的代码路径 `c:\workspace\kratos` 与当前实际工作区不一致；另 `.cursor/rules/80-phet-sim-checklist.mdc` 内容只有一行指向 `C:/workspace/phet/.codebuddy/...` 的**失效路径**。按用户指令"一切以当前仓库实际结构为准"，本分析以实际工作区源码为准。[已确认]

```
lib/
  main.dart                 # MaterialApp + home: HomeScreen（无命名路由）[已确认 lib/main.dart:7-46]
  common/                   # L0 通用层（32 个 Dart 文件）
    simulation_clock.dart   # Ticker 封装时钟
    chart/                  # 时间序列图、散点快照图、GraphSuite
    controls/               # KratosSlider/SpectrumSlider/ComboBox/RadioGroup/NumberField/箭头 Painter/GameTimer
    elements/               # PositionElement（可放置元件基类：id/type/x/y/hitTest）
    scenario/               # ScenarioManagerBase（manifest + JSON 加载）
    widgets/                # NineGridLayout、DragDropWorkspace、TimeControlBar、InquiryDrawer 全家桶等
  circuit/  forces/  optics/  color_vision/  sound/  radio_waves/  wave_interference/
  chemistry/molarity/       # 化学学科唯一已有 sim（显式 Controller + ChangeNotifier）
  screens/                  # home_screen.dart（注册中心）+ scenario_selection_screen.dart（旁路遗留）
assets/
  images/                   # 扁平 SVG（小写下划线命名：battery.svg、lens_convex.svg …）
  sounds/                   # 仅 tap.wav
  scenarios/                # <sim-kebab>/manifest.json + <scenario-id>.json
schemas/                    # 8 个 *_scenario.schema.json（文档级，无运行时校验）
test/                       # *_model_test / *_layout_test / *_scenario_test / common 组件测试
integration_test/           # app_test.dart（含拖拽 E2E）等 4 个
docs/knowledge/             # kratos/（架构约定）+ kratos-java-simulations/（四原则、L0-L2、EDD 模板）
requirements/               # req-*/ 需求产物目录 + _template
```

关键事实：

- **Screen 注册** = `HomeScreen._disciplines` 静态清单（学科 → 科目组 → `_SimEntry{title, subtitle, icon, color, builder}`），点击后 `Navigator.push(MaterialPageRoute(builder: ...))`。[已确认 `lib/screens/home_screen.dart:59-160, 372-375`]
- **状态管理**：工程级**未使用** Provider/Riverpod/Bloc。动力学 sim（sound/wave/radio）= 可变 Model + `SimulationClock` + Screen 内 `setState`；circuit/optics = 不可变 State + Solver + Screen 充当 Controller；molarity = `ChangeNotifier` + 显式 Controller。三种范式并存，新 sim 应选最贴近的一种（见 §8）。[已确认]
- **布局硬性要求**：所有 sim 主屏必须用 `NineGridLayout`，中间格面积占比 ≥ 70%；拖拽类 sim 必须拆 `DropCanvas` + `DragTray`。[已确认 `.codebuddy/rules/80-kratos-sim-checklist.mdc` L0-1~L0-4 + circuit 实测 `lib/circuit/screens/circuit_screen.dart:796-813`]
- **依赖**：`flutter_svg ^2.3.0`、`audioplayers ^6.7.1`、`cupertino_icons`；dev：`flutter_test`、`integration_test`、`flutter_lints ^6.0.0`。[已确认 `pubspec.yaml:30-51`]

---

## 2. 当前工程已有 sim 架构

### 2.1 主流数据流（动力学类，以 sound 为代表）

```
assets/scenarios/<sim>/manifest.json + <id>.json
        │  ScenarioManagerBase.loadScenario(id) → buildInitialState
        ▼
   <Sim>State（可变 Model，含 stepInTime(dt)）
        ▲ step            │ 用户输入（Slider 回调直接改 Model 字段 + setState）
SimulationClock.onTick    │
        └──► setState ──► CustomPaint(<Domain>Painter) / 信息 Widget
```

[已确认：`lib/sound/screens/sound_screen.dart:47-53, 284-335`；`lib/sound/model/sound_state.dart:50-75`；`lib/common/simulation_clock.dart:12-45`]

### 2.2 拖拽组装类（circuit，与 Build a Nucleus 最相关）

```
DragTray（底部托盘，Draggable 元件卡片）
   │ onItemDropped（世界坐标经 CanvasProjection.toWorld 换算）
   ▼
CircuitState（含 PositionElement 列表）→ CircuitSolver → setState → CustomPainter
```

[已确认：`lib/circuit/screens/circuit_screen.dart:12-19, 796-813`；`lib/common/widgets/drag_drop_workspace.dart`]

### 2.3 标准文件骨架（按现网惯例归纳）

```
lib/<sim_snake>/
  screens/<sim>_screen.dart           # StatefulWidget + NineGridLayout (+ SimulationClock 若动力学)
  model/<sim>_state.dart / *_engine.dart
  painters/<domain>_painter.dart      # CustomPainter（L2，不上抽）
  config/<sim>_scenario.dart          # fromJson 数据模型
  config/<sim>_scenario_manager.dart  # extends ScenarioManagerBase
  widgets/…                           # 可选
assets/scenarios/<sim-kebab>/manifest.json + default.json …
schemas/<sim>_scenario.schema.json
test/<sim>_model_test.dart (+ _layout_test.dart + scenario 测试)
# home_screen.dart 注册 _SimEntry；pubspec.yaml 声明 assets 子目录
```

[已确认：sound / wave_interference / circuit / molarity 四个 sim 均符合此骨架]

### 2.4 明确回答"各角色在哪"

| 角色 | 当前工程实际 | 证据 |
|---|---|---|
| 入口 | `lib/<sim>/screens/<sim>_screen.dart` | sound_screen.dart:24 |
| Model/State | `lib/<sim>/model/`（可变类或不可变 State） | sound_state.dart:7 |
| State 通知 | `setState`（主流）/ `ChangeNotifier`（molarity） | molarity/model/solution.dart:15 |
| Controller | **多数 sim 无独立 Controller**，Screen 兼任；molarity 有显式 Controller | molarity/controller/ |
| Solver | 连续场类内嵌 Model.step（sound/wave）；离散求解独立 Solver 类（circuit MNA、optics） | wave_engine.dart:117 |
| Painter | `lib/<sim>/painters/`，`CustomPainter` 子类 | spherical_view_painter.dart:10 |
| Assets | `assets/images/*.svg`、`assets/scenarios/<sim-kebab>/` | §11 |
| Screen 注册 | `HomeScreen._disciplines` 静态表 | home_screen.dart:59-160 |
| Test | `test/<sim>_model_test.dart` 等 + `integration_test/` | test/ 实测约 32 文件 |

---

## 3. 参考 sim 选择及依据

| 选择 | 角色 | 依据 |
|---|---|---|
| **circuit（首选）** | 交互骨架蓝本 | 托盘离散零件 → 拖入画布组装 → 放置后求解，与"拖核子搭核"交互同构；集成测试已覆盖拖放（`integration_test/app_test.dart`）[已确认] |
| **sound（次选）** | 时钟 + Painter + 信息面板范式 | SimulationClock 用法、九宫格布局、InquiryDrawer 接法 [已确认] |
| **molarity（领域参考）** | 化学学科目录归属 + ChangeNotifier 范式 | 同学科分组；有显式 Controller 可借鉴；但无核物理领域模型，不能当蓝本 [已确认] |
| **optics（备选）** | DragDropWorkspace 第二使用点 | 验证拖拽组件的可复用性 [已确认] |

不选 color_vision / radio_waves / wave_interference / forces：无"离散粒子拖拽组装"语义。[推测，依据：各 sim 交互实测]

---

## 4. Build a Nucleus 原项目技术栈

| 项 | 结论 | 证据 |
|---|---|---|
| 官方 URL | https://phet.colorado.edu/sims/html/build-a-nucleus/latest/build-a-nucleus_all.html | [已确认] |
| 官方仓库 | https://github.com/phetsims/build-a-nucleus （GPL-3.0，版本 1.2.0-dev.1，published） | [已确认 `package.json`] |
| 实际技术栈 | **HTML5 + TypeScript**，PhET 自有栈：scenery（渲染/输入）、joist（Sim/Screen 框架）、axon（Property 响应式）、sun（UI 控件）、scenery-phet、twixt（动画）、bamboo（图表）、**shred**（原子/核领域模型与数据）、dot/kite/phet-core | [已确认 `package.json` phetLibs + 全部 `.ts` 源码 import] |
| 是否 Java | **否**。虽然本工程代号含 "java-simulations"，该 sim 无 Java 版本蓝本；它是为 HTML5 原生开发的（2021 起） | [已确认：仓库 2021 版权头 + 全 TS 代码] |
| 源码结构 | `js/common/`（BANModel/BANScreenView/常量/颜色）+ `js/decay/{model,view}` + `js/chart-intro/{model,view}` + `build-a-nucleus-main.ts` | [已确认：git tree API 全量文件列表] |
| 共享依赖（核数据） | `shred/js/AtomData.ts`：ENSDF Relational 数据库 2022 版**人工硬编码**为 TS 表（`stableElementTable`、`HalfLifeConstants`、`DECAYS_INFO_TABLE`、`ISOTOPE_INFO_TABLE`、`mapElectronCountToRadius` 等）；查询层 `shred/js/AtomInfoUtils.ts` | [已确认 `doc/implementation-notes.md` "Data" 节 + `AtomInfoUtils.ts` 源码 import] |
| 自有 assets | `images/fullNuclideChart.png`（完整核素图，唯一位图）；**无 sounds/ 目录**（仓库无自有音频） | [已确认 git tree] |
| 字符串 | `build-a-nucleus-strings_en.json`（约 70 条，含全部 UI 文案） | [已确认] |
| 构建 | grunt + requirejs 命名空间 `BUILD_A_NUCLEUS` | [已确认 package.json / Gruntfile.cjs] |

---

## 5. Screen

| Screen | 名称字符串 key | 内容 | 证据 |
|---|---|---|---|
| Screen 1 | `screen.decay` → "Decay" | 自由搭建原子核（上限 **94 质子 / 146 中子**，即 Pu-240），显示半衰期、稳定性、可用衰变；电子云可选 | [已确认 `DecayScreen.ts`、`BANConstants.DECAY_MAX_*`、`doc/model.md`] |
| Screen 2 | `screen.chartIntro` → "Chart Intro" | 核壳层模型搭建（上限 **10 质子 / 12 中子**，即 Ne-22）+ 部分核素图 + 衰变方程；附完整核素图链接 | [已确认 `ChartIntroScreen.ts`、`BANConstants.CHART_MAX_*`、`doc/model.md`] |

页面切换：joist 标准 Screen 机制（底部/顶部屏切换控件 + 主屏图标）。[推测：joist 标准行为；依据 `new Sim(title, [new DecayScreen(), new ChartIntroScreen()])`（build-a-nucleus-main.ts），未逐行读 joist]

---

## 6. UI

### 6.1 Decay 屏（证据：`js/decay/view/DecayScreenView.ts`、`js/common/view/BANScreenView.ts`、`build-a-nucleus-strings_en.json`）

| 控件 | 说明 | 标记 |
|---|---|---|
| 核子生成器托盘（底部居中） | 质子球 + 中子球（可拖出），左右各有上/下箭头按钮（Spinner 语义），中间双箭头按钮同时增减一对 p+n | [已确认 `NucleonCreatorsNode.ts`] |
| 核子计数面板 `NucleonNumberPanel` | "Protons: n"、"Neutrons: n" 读数 | [已确认] |
| 元素名文本 `ElementNameText` | 如 "Helium-5"；不存在时显示 "{{name}} does not form"；0p0n 特例显示 "Cluster of N neutrons" 等 | [已确认 strings] |
| 稳定性文本 `StabilityIndicatorText` | "Stable" / "Unstable" | [已确认] |
| 半衰期信息 `HalfLifeInformationNode` | "Half-life:" 读数 + 对数刻度数轴（10^-24 ~ 10^24 s）+ info 按钮 | [已确认 `BANConstants.HALF_LIFE_NUMBER_LINE_*`] |
| 半衰期 Dialog `HalfLifeInfoDialog` | 展开时间轴，标注参照物（光穿过核的时间、眨眼、一年、宇宙年龄…A~J 标号） | [已确认 strings] |
| 化学符号 AccordionBox | shred `SymbolNode`：^A_Z X 符号，可折叠，标题 "Symbol" | [已确认] |
| 可用衰变面板 `AvailableDecaysPanel` | 标题 "Available Decays"，5 个衰变按钮（α / β- / β+ / 质子发射 / 中子发射），按当前核素可用性 enable/disable；附说明文案 | [已确认] |
| 撤销衰变按钮 `ReturnButton` | 衰变后出现，回到衰变前核子数；任何核变化后隐藏 | [已确认 DecayScreenView] |
| 电子云 Checkbox | "Electron Cloud"，控制蓝色电子云显示；云大小随质子数变化 | [已确认 `ShowElectronCloudCheckbox`、`updateCloudSize`] |
| ResetAllButton | 右下角标准复位 | [已确认 BANScreenView:121] |
| 标题栏 / PhET 菜单 / Preferences / Keyboard Shortcuts | joist 标准外壳（屏名 "Decay"/"Chart Intro"，支持动态语言、交互式描述） | [推测：joist 标准；`package.json.simFeatures` 确认 supportsInteractiveDescription/supportsDynamicLocale] |

### 6.2 Chart Intro 屏（证据：`doc/model.md`、`doc/implementation-notes.md`、`js/chart-intro/**` 文件树与 `ChartIntroModel.ts`）

| 控件 | 说明 | 标记 |
|---|---|---|
| 迷你原子（顶部，不可交互） | 主核的镜像显示，带虚线"放大"引导线指向壳层区 | [已确认 model.md] |
| 核壳层能级区 | 3 条能级线（n=0 容 2、n=1 容 6、n=2 名义 12 实际按 6 建模），核子落在能级上；能级颜色随填充程度渐深；核子"绑定"后不可拖 | [已确认 model.md + implementation-notes] |
| "Energy" / "Nuclear Shell Model" 文本 | 坐标轴/标题 | [已确认 strings] |
| 部分核素图 AccordionBox（"Partial Nuclide Chart"） | 10×12 核素格子图 + 质子/中子数轴高亮（`NucleonNumberLine`），格子按最可能衰变类型着色 | [已确认 implementation-notes] |
| Zoom 场景 | Radio 切换 partial / zoom；zoom 场景 = 5×5 `ZoomInNuclideChartNode` + `FocusedNuclideChartNode`（远处格子灰化） | [已确认 implementation-notes + ChartIntroModel.SelectedChartType] |
| 衰变方程 `DecayEquationNode` | 最可能衰变 + 百分比 "(xx%)"；旁边衰变按钮可演示（壳层中粒子淡入淡出）；图上有白色方向箭头 | [已确认 model.md] |
| 元素周期表 + 同位素符号 `PeriodicTableAndIsotopeSymbol` | 元素周期表中高亮当前元素 | [已确认 文件树] |
| "Magic Numbers" Checkbox | 高亮核素图中 2、8 核子行 | [已确认 model.md + strings] |
| "Full Chart" 按钮 + Dialog | 展示 `fullNuclideChart.png` 完整核素图；文案含 Calgary 大学外链 | [已确认 strings + images/] |
| ResetAllButton | 同上 | [已确认] |

无 Slider、无 ComboBox、无图表折线（图表只有核素格子图与数轴）。[已确认：全部 view 文件清单中无此类控件]

---

## 7. 交互

证据：`BANScreenView.ts`（661 行全文已读）、`NucleonCreatorsNode.ts`、`DecayScreenView.ts`、`doc/model.md`。

| 交互 | 行为细节 | 标记 |
|---|---|---|
| 点击上箭头 | 从对应生成器栈创建粒子 → 以**固定 0.6s** 动画飞入核中心（速度=距离/0.6，`setAnimationDestination(consistentTime: true)`；1F-2A 前误记为 300px/s 定速，已按 `BANParticle.ts` 修正）→ 到达后计入 ParticleAtom 并可被点击 | [已确认 `createParticleFromStack` + `BANParticle.setAnimationDestination`] |
| 点击下箭头 | 取离生成器最近的同类粒子 → 从核中移除 → 动画飞回栈 → 销毁 | [已确认 `returnParticleToStack`/`getParticleToReturn`] |
| 双箭头 | 同时增减 1p + 1n | [已确认 `DoubleArrowButton` 逻辑] |
| 按钮 enable 规则 | 目标核素不存在时禁用（`doesExist`/`doesNextIsotopeExist`/`doesNextIsotoneExist`/`doesNextNuclideExist`）；上箭头允许**越界 1 个**进入"不存在"态用于教学；到 94/146 等范围边界禁用；核内有用户拖拽中粒子时禁用 | [已确认 `createArrowEnabledProperty`] |
| 拖拽核子 | 从生成器按下即创建粒子并发起拖拽（`addAndDragParticle`）；松手判定：在**捕获区**内（Decay 屏为核中心半径 100 CSS px 圆）→ 加入核；在捕获区外 → 动画返回生成器并销毁；若移除会造成不存在核素则强制收回核内 | [已确认 `dragEndedListener`、`NUCLEON_CAPTURE_RADIUS=100`] |
| 拖核内已有粒子 | 粒子从核中取出进入 userControlled 数组并置顶 z 层；松手同上判定 | [已确认 BANModel userControlledListener] |
| "does not form" 纠正 | 核素不存在且非 0p0n：显示 "X does not form" **1 秒**（`TIME_TO_SHOW_DOES_NOT_EXIST`），随后自动补/退核子回到上一个存在的核素；用户拖拽中不触发 | [已确认 `BANScreenView.step()` 362-417] |
| 衰变按钮 | 触发对应衰变动画：α = 核中心最近 2p2n 组成 α 粒子飞出随机方向；p/n 发射 = 同类粒子飞出；β- = 核内一中子变质子并发射电子；β+ = 质子变中子并发射正电子（均向屏外随机点） | [已确认 `decayAtom`/`emitAlphaParticle`/`betaDecay`/`emitNucleon`] |
| 撤销衰变 | 恢复衰变前 p/n 数，清 outgoing 与飞出/换色动画；**不清** incoming/拖拽/归位，不回到空核。与 Reset 不是同一套逻辑。详见 notes 1G-1 | [已确认 `undoDecay`] |
| Reset | 销毁全部粒子数组与动画 + 清 invalid 计时/标志 + populate 默认 0p0n。拖拽中 Reset 后松手不得回核 | [已确认 `BANModel.reset`、`DecayScreenView.reset`] |
| 衰变后读数联动 | 符号、半衰期、核子计数、可用衰变全部随 protonCount/neutronCount 派生更新 | [已确认 implementation-notes 首段] |
| 时间控制 | **无播放/暂停/步进**（粒子动画为事件驱动的补间，非连续物理仿真）；ScreenView.step(dt) 仅用于粒子移动与"1 秒纠正"计时 | [已确认 BANScreenView.step / BANModel.step] |
| 特例（Hollywood） | Be-6 α **不是另一种衰变**：先跑完整普通 α，若剩余恰好 (2p,0n) 再附加强制射出。详见 §7.1 | [已确认 model.md + DecayScreenView.emitAlphaParticle override] |
| 键盘/无障碍 | 支持交互式描述（PDOM 顺序已定义：生成器 → 半衰期 → 衰变按钮等） | [已确认 pdomOrder 代码；具体快捷键 [待确认]] |

### 7.1 Be-6 α vs 普通 α（Phase 1F-2B-2 取证）

证据：`BANScreenView.emitAlphaParticle`（普通路径全文）+ `DecayScreenView.emitAlphaParticle`（override 附加分支全文）+ `doc/model.md` Hollywood 段。表内唯 Be-6(4p,2n) 在 α 后剩余 (2p,0n)。

**触发条件 [已确认]**：不是 `if (Be-6)`，而是普通 α extract 2p2n **之后** `protonCount===2 && neutronCount===0`。

| 行为 | 普通 α（Be-8 → He-4） | Be-6 特例（4p2n → 2p0n → 0p0n） | 标记 |
|---|---|---|---|
| 按钮 / `decayAtom` 分支 | `ALPHA_DECAY` → `emitAlphaParticle()` | 同一个 | [已确认] |
| 取出核子 | 离中心最近 2p+2n | 同左，然后 **1s 行程后再取剩余 2p** | [已确认] |
| α 创建 / 起点 / 速度 | 核中心组装，300 px/s 飞向随机屏外点 | 同左（先跑 `super`） | [已确认] |
| 点击后核素 | He-4 (2p2n) 存在 | **2p0n 不存在**（"does not form"） | [已确认] |
| 是否立即改计数 | 是 | 是（2p0n 立即出现；0p0n **不是**点击时） | [已确认] |
| 重排 | 质量数变化 → `reconfigureNucleus` | 同左（6→2 并排；2→0 空核） | [已确认] |
| `correctingNonexistentNuclide` | 保持 true | **false**，直到 α dispose | [已确认] |
| 剩余核子输入 | 可拖 | 剩余 2 质子 `inputEnabled=false` | [已确认] |
| α 飞满 `1s × velocity`（300px） | 无 | `emitNucleon(PROTON)×2`，从质子当时位置飞出 | [已确认] |
| α animation end / dispose | 移除 α 核子 | 额外恢复 `correctingNonexistentNuclide=true` | [已确认] |
| 终态 | He-4 留核内 | **0p0n 空核** | [已确认] |
| Undo | 恢复 parent | 射出前恢复 Be-6；射出后 massNumber 变化隐藏 undo | [已确认] |
| Reset | 清粒子 + 标志 true | 同左，且必须关掉特例窗口 | [已确认] |

时序 [已确认]：点击衰变 → 普通 α 状态变化（2p0n）+ α outgoing → α 飞行 → 距离达 300px 再射出 2p → 0p0n → α 到达后恢复自动回退标志。不要为了与普通 α 统一而把 2 质子并进点击瞬间。

---

## 8. 核模型（重点）

### 8.1 PhET 侧类关系（全部 [已确认]，证据：implementation-notes + BANModel.ts + AtomInfoUtils.ts）

```
BANParticle extends shred.Particle        # 单个核子：type/id/position/destination/zLayer/isDragging
AlphaParticle extends ParticleAtom        # 2p+2n 子结构，衰变时整体飞出
ParticleAtom (shred)                      # 核：protons[]/neutrons[]、protonCountProperty、
                                          #   neutronCountProperty、massNumberProperty、
                                          #   reconfigureNucleus()（质量数变化时重排核内粒子位置）
ShellModelNucleus extends ParticleAtom    # Chart Intro 专用：protonShellPositions[]/neutronShellPositions[]、
                                          #   ALLOWED_PARTICLE_POSITIONS（网格化能级占位）
BANModel<T extends ParticleAtom>          # 屏级模型基类：particles（全量）、incomingProtons/Neutrons、
                                          #   userControlledProtons/Neutrons、outgoingParticles、
                                          #   particleAnimations、isStableProperty、nuclideExistsProperty
DecayModel extends BANModel<ParticleAtom>       # + halfLifeNumberProperty、decayEnabledPropertyMap
ChartIntroModel extends BANModel<ShellModelNucleus>  # + miniParticleAtom、decayEquationModel、
                                                     #   cellModelArray（POPULATED_CELLS 派生）
```

### 8.2 领域概念 → 程序实现映射

| 概念 | PhET 实现 | 标记 |
|---|---|---|
| Proton / Neutron / Nucleon | `ParticleTypeEnum`（PROTON/NEUTRON/ELECTRON/POSITRON），`BANParticle.type` | [已确认] |
| Nucleus | `ParticleAtom` 的核内粒子集合 + `reconfigureNucleus()` 位置重排（位置为视觉近似，非物理精确——官方自述 "particles are not at all to scale"） | [已确认 model.md caveats] |
| Nuclide | 由 (protonCount, neutronCount) 二元组隐式定义，无独立 Nuclide 实体类 | [已确认 implementation-notes] |
| Element | `AtomInfoUtils` 经质子数查元素符号/名称（shred 数据） | [已确认 import 与用法] |
| Isotope | `ISOTOPE_INFO_TABLE[Z][A]`（原子质量、丰度） | [已确认 AtomInfoUtils.getIsotopeAtomicMass] |
| Atomic Number | `protonCountProperty` | [已确认] |
| Mass Number | `massNumberProperty`（派生 = p+n） | [已确认] |
| Stability | `stableElementTable[Z].contains(N)` 查表 | [已确认 isStable] |
| 存在性 | `doesExist = isStable ∨ HalfLifeConstants[Z][N] ≠ null` | [已确认] |
| Half-life | `HalfLifeConstants[Z][N]`（秒；null=无数据，-1=未知；稳定核取数轴最大值 10^24） | [已确认 DecayModel.halfLifeNumberProperty] |
| Radioactive Decay | `DECAYS_INFO_TABLE[Z][N]`（ENSDF 衰变模式 + 分支比）→ 映射为 5 种 `BANDecayType`；同类型多条取第一条非 null；按百分比降序，null 排后 | [已确认 getAvailableDecaysAndPercents] |
| 电子云半径 | `mapElectronCountToRadius[Z]`（实验原子半径，经美术调整） | [已确认] |
| 幻数 | 2, 8, 20…（能级容量 2/6/12 累计）；Chart Intro 屏仅高亮 2 和 8 | [已确认 model.md] |

### 8.3 衰变类型参数

`BANDecayType(label, color, massNumber, protonNumber, symbol)`：

| 类型 | massNumber | protonNumber | 符号 |
|---|---|---|---|
| α | 4 | 2 | α |
| β- | 0 | -1 | β |
| β+ | 0 | 1 | β |
| 质子发射 | 1 | 1 | p |
| 中子发射 | 1 | 0 | n |

[已确认数值本身（BANDecayType.ts）；语义 [推测]：这两个数值描述**被发射粒子**的质量数/电荷数（电子 -1、正电子 +1 与之吻合），用于衰变方程渲染；具体消费点在 `DecayEquationModel.ts`（3.5KB，未逐行读）→ 方程排版细节 [待确认]]

### 8.4 数据表规模

`DECAYS_INFO_TABLE` / `HalfLifeConstants` / `stableElementTable` 覆盖至 94p/146n（Pu-240 区间），条目量级为**数千个核素**。[推测，依据：ENSDF 全量 + Decay 屏上限；`AtomData.ts` 文件本体未读取（shred 仓库大文件），准确行数 [待确认]]

---

## 9. State → Solver → Render（按当前工程架构落地）

当前工程**并不存在统一的** `State→Controller→Solver→Painter` 四层（§2.4）：主流是"Screen 兼任 Controller + Model 内嵌 step + setState + CustomPainter"。Build a Nucleus 应按此落地，不新造架构：

| 角色 | 规划类（落地方案） | 对标 |
|---|---|---|
| State（保存状态） | `BuildANucleusState`（可变 Model）：质子/中子计数、粒子列表（核内/incoming/outgoing/userControlled）、稳定与存在性派生 | 对标 `SoundState`；[推测] |
| 输入处理 | Screen 直接处理（拖拽回调、按钮回调），**不设独立 Controller**——与 sound/circuit 一致 | [推测，依据工程主流] |
| 求解 | 无连续物理求解。衰变/存在性/半衰期 = **纯查表函数**（`NuclideData` 工具类，对标 `AtomInfoUtils`）；粒子移动 = 简单补间（速度 300px/s 匀速），由 Clock 驱动 | [已确认原项目即为查表+补间] |
| 渲染 | `NucleusPainter`（CustomPainter，核子圆点渐变 + 电子云径向渐变）+ Flutter Widget（面板/按钮/读数） | 对标 sound 的 painter 组合；[推测] |
| 时钟 | 复用 `SimulationClock`（仅驱动画粒子补间与"1 秒纠正"计时；无需高 fps 物理） | [推测] |

---

## 10. 已有 sim → Build a Nucleus 映射表

| 当前已有实现 | Build a Nucleus 对应内容 | 复用方式 | 依据 |
|---|---|---|---|
| `DragTray` + `DropCanvas` + `DragItem`（common/widgets/drag_drop_workspace.dart） | 底部质子/中子生成器托盘 → 拖入核区 | **直接复用**，但需扩展：原 sim 是"无限供应的生成器"（拖出即新建粒子，托盘不消耗）；现有 DragItem 是离散元件语义，需要定制 feedback 与 drop 判定（捕获半径） | circuit_screen.dart:798-813；[已确认组件存在，适配方式 [推测]] |
| `CanvasProjection`（world↔screen） | 核子坐标换算、捕获半径判定 | 直接复用 | drag_drop_workspace.dart [已确认] |
| 画布内已放置元件再拖动 | 拖动核内已有核子（拖出核即移除） | **部分复用**：common 无通用封装，circuit/optics 各自用 GestureDetector 本地实现；本 sim 同样本地实现，若第 3 个 sim 出现同类需求则按 3-Time Rule 上抽 | explore 实测 [已确认] |
| `NineGridLayout` | 全屏布局（center=核画布，bottomCenter=核子托盘，右上=符号/衰变面板） | 直接复用（强制） | checklist L0-4 [已确认] |
| `SimulationClock` | 粒子飞入/飞出补间、"does not form" 1 秒计时 | 直接复用；**不需要** TimeControlBar（原 sim 无播放暂停） | BANScreenView.step [已确认] |
| `PositionElement` | 核子 id/位置/命中基类 | 可参考，但核子需要 destination/zLayer/动画态，预计自建 `Nucleon` 模型更合适 | [推测] |
| `ScenarioManagerBase` + manifest JSON | 教学场景（如"搭出稳定氦核"任务）初始 p/n 数、探究任务 | 直接复用；scenarios/build-a-nucleus/ | scenario_manager_base.dart:79-120 [已确认] |
| `InquiryDrawer`/`ExperimentLogger`/`KnowledgePanel` 等 | 探究式学习任务面板 | 可选复用（取决于是否做探究版） | [推测] |
| `ResetAllButton` | 右下角复位 | **无现成独立组件**：common 无 Reset 按钮；仿各 sim 用 `IconButton(Icons.restart_alt)` 或 TimeControlBar 模式 | explore 实测 [已确认缺口] |
| Checkbox（电子云 / 幻数） | "Electron Cloud"、"Magic Numbers" | **common 无 Checkbox**，用 Flutter 原生 `Checkbox`/`Switch` | [已确认缺口] |
| AccordionBox（符号面板 / 核素图折叠面板） | "Symbol"、"Partial Nuclide Chart" | **无现成组件**，Flutter `ExpansionTile` 或自建 | [已确认缺口，[推测]替代方案] |
| 图表（chart/） | 无折线图需求；核素图为**格子矩阵**，不属于 chart 体系 | 不复用，自建 `NuclideChartPainter` | [已确认] |
| 音效（audioplayers + tap.wav） | 原 sim 无自有音效 | 不需要 | git tree 无 sounds/ [已确认] |
| `fullNuclideChart.png` | "Full Chart" 对话框 | **需从 PhET 仓库获取**（GPL-3.0，注意 license.json 署名要求）；当前 assets 无对应资源 | [待确认：资源引入与授权处理流程] |
| 核素数据（ENSDF 表） | 稳定表/半衰期/衰变模式 | 当前工程**无任何对应物**，需从 shred `AtomData.ts` 提取转换 | [已确认缺口] |

---

## 11. Assets

当前规范 [已确认]：`assets/images/` 扁平小写下划线 SVG；`assets/sounds/`（仅 tap.wav）；`assets/scenarios/<sim-kebab>/`；pubspec 逐目录声明。

| PhET Asset | KARTOSLAB Asset（规划） | Flutter 使用位置 | 标记 |
|---|---|---|---|
| fullNuclideChart.png（335KB） | `assets/images/full_nuclide_chart.png` | Full Chart 对话框 | [待确认] 需从原仓库获取并处理 GPL/署名 |
| 质子/中子球（scenery RadialGradient 程序绘制，非图片） | **无需资源**：`NucleusPainter` 用 RadialGradient 绘制 | 核子渲染 | [已确认 BANConstants 梯度函数] |
| 电子云（径向渐变白/蓝） | **无需资源**：Painter 绘制 | 电子云 | [已确认 ELECTRON_CLOUD_FILL_GRADIENT] |
| 屏图标 / UI 图标（IconFactory.ts 程序绘制） | Painter/IconData 自绘 | Home 入口图标等 | [推测] |
| 字符串（70 条英文） | 硬编码中文/英文文案或 arb（当前工程无 i18n 体系，各 sim 均为硬编码中文） | 全部 UI | [推测，依据现有 sim 实测无 arb] |
| 音效 | 无（原 sim 无自有音频） | — | [已确认] |
| scenarios | `assets/scenarios/build-a-nucleus/manifest.json` + `default.json` + 教学场景 | ScenarioManager | [推测] |

---

## 12. 配置化（schemas / JSON）

现状 [已确认]：`schemas/` 8 个 scenario schema（文档级，**无运行时校验**）；场景数据为 manifest + 每场景一个 JSON。

规划（只外置真正适合的数据）：

| 数据 | 外置？ | 说明 | 标记 |
|---|---|---|---|
| 场景（初始 p/n、任务目标、探究步骤） | ✅ `assets/scenarios/build-a-nucleus/*.json` + `schemas/build_a_nucleus_scenario.schema.json` | 与现有 sim 完全一致的模式 | [推测] |
| 核素数据表（稳定表、半衰期、衰变模式、同位素质量） | ✅ **建议外置**为 `assets/data/nuclide_table.json`（或按 Z 分片） | 数千条目，属"数据表"而非算法；Dart 侧提供 `NuclideData` 查询类。注意：现有工程 assets 无 data/ 先例，属新目录规范 | [推测；目录规范 [待确认]] |
| 常量（捕获半径 100、动画速度 300px/s、上限 94/146 与 10/12、能级容量 2/6/6） | ❌ Dart `BANConstants` 等价类 | 与原项目一致（BANConstants.ts 也是硬编码） | [已确认原项目做法] |
| 衰变/纠正/重排算法 | ❌ Dart 实现 | 物理逻辑不数据驱动 | [已确认原则] |
| 测试 fixture | ✅ test 内 JSON 或 Dart 常量 | 参照现有 scenario 测试 | [推测] |

---

## 13. 测试规划（参照现有结构）

| 层 | 测试文件（规划） | 内容 | 对标 |
|---|---|---|---|
| Model | `test/build_a_nucleus_model_test.dart` | 增减核子 → 计数/质量数/存在性/稳定性派生；衰变后 p/n 变化；"does not form" 回退；0p0n 特例 | sound_model_test |
| 数据/求解 | `test/build_a_nucleus_nuclide_data_test.dart` | 查表：稳定判定、半衰期、可用衰变排序、边界（94/146、10/12） | circuit_solver_mna_test |
| Config | `test/build_a_nucleus_scenario_test.dart` | manifest/场景 JSON → Dart model | forces_scenario_test |
| Widget/布局 | `test/build_a_nucleus_layout_test.dart` | 窄/宽视口无溢出（375×667 等） | sound_layout_test |
| 交互 | `integration_test/build_a_nucleus_test.dart` | 拖核子入核（timedDragFrom）、点衰变按钮、Reset | app_test.dart 拖拽 E2E |
| Rendering | Painter 金样测试 [待确认：当前工程无 golden test 先例] | — | — |
| Navigation/Lifecycle | 进/出屏、Reset 后状态干净 | integration_test 内 | [推测] |

---

## 14. 诚实机制汇总

### [已确认]（关键项）

- 原项目为 HTML5/TypeScript（非 Java）；2 屏；上限 94p/146n 与 10p/12n；5 种衰变；ENSDF 2022 数据硬编码于 shred AtomData；核心交互（生成器托盘+箭头+捕获半径 100+1 秒纠正+衰变动画+撤销+Reset）；无自有音频；唯一位图 fullNuclideChart.png。
- 当前工程：Screen 静态注册 + Navigator.push；无全局状态库；NineGridLayout 强制（中心 ≥70%）；DragTray/DropCanvas 已存在；ScenarioManagerBase 与 scenarios 规范；测试组织方式；lib/common 全部能力与缺口。

### [推测]（主要项，附依据）

- 落点 `lib/chemistry/build_a_nucleus/`（依据：学科分组 + chemistry 已存在；但最终归属需与用户对齐）。
- BANDecayType 两个数值参数 = 发射粒子的质量数/电荷数（依据：与电子 -1/正电子 +1/α(4,2) 吻合）。
- joist 外壳自带 Preferences/Keyboard Shortcuts/PhET 菜单（依据：joist 标准行为 + simFeatures 声明，未读 joist 源码）。
- 核素数据条目量级数千（依据：ENSDF 覆盖范围 + Decay 屏上限）。
- 文案采用硬编码中文（依据：现有 sim 无 i18n 体系）。

### [待确认]（主要项）

1. `AtomData.ts` 的精确规模与提取方式（shred 仓库大文件未读取）。
2. `ShellModelNucleus.ALLOWED_PARTICLE_POSITIONS` 的具体网格坐标与能级视觉参数（16KB 文件未逐行读）。
3. `DecayEquationModel` 的衰变方程排版细节（BANDecayType 参数消费点）。
4. 键盘快捷键清单（原 sim 的 keyboard help 内容）。
5. `fullNuclideChart.png` 的引入与 GPL/署名处理流程。
6. 是否做"探究式"版本（InquiryDrawer 体系）还是纯高保真复刻。
7. Chart Intro 屏是否纳入本期范围（工作量占比大，见 §19/§21）。
8. HomeScreen 中 Build a Nucleus 的学科分组与入口文案/图标。
9. `assets/data/` 新目录规范是否被接受。

---

## 15. 风险

| 风险 | 等级 | 说明 | 缓解 |
|---|---|---|---|
| 核素数据表提取 | **高** | `AtomData.ts` 是 ENSDF 2022 人工硬编码大表，需忠实转成 JSON/Dart，错一行即物理错误 | 写一次性转换脚本 + 抽样核对（如 H-1、C-14、U-238 已知半衰期）；单元测试锚定 |
| 核内粒子排布视觉 | 中 | PhET 用 `reconfigureNucleus()` 随机摆放 + 22 层 z 层；"高保真"需接近其观感但**官方自述不按比例、不求精确** | 先实现同心层填充近似，截图对比迭代；[待确认] 排布算法细节 |
| Chart Intro 屏复杂度 | **高** | 壳层能级定位 + 3 种核素图 + ChartTransform 对数/网格映射 + 衰变方程，是本期最大工程量 | 建议拆分里程碑，或先只做 Decay 屏 MVP（§20） |
| 拖拽语义差异 | 中 | 现有 DragTray 是"离散元件"语义，原 sim 是"无限生成器"语义；Flutter Draggable 的 feedback/命中需定制 | 以 DropCanvas 的 onItemDropped 扩展 + 自写生成器卡片 |
| 授权合规 | 中 | PhET 为 GPL-3.0；图片与数据表引入需署名（images/license.json） | 引入时附 license 说明；文案自写不复制字符串文件 |
| 双范式混用 | 低 | 本 sim 是"事件驱动补间"而非"连续物理"，接入 SimulationClock 时不要照搬 sound 的物理 step 语义 | 仅用 clock 做补间推进 |

---

## 16. 当前工程目录映射（推荐）

```
lib/chemistry/build_a_nucleus/
  screens/build_a_nucleus_screen.dart        # 屏容器（Decay / Chart Intro 两个内部 Tab 或两段式）
  screens/decay_view.dart                    # Decay 屏主体
  screens/chart_intro_view.dart              # Chart Intro 屏主体（若纳入范围）
  model/nucleon.dart                         # 核子（type/position/destination/zLayer/拖拽态）
  model/nucleus_state.dart                   # 核状态 + 粒子数组（对标 BANModel）
  model/decay_type.dart                      # 5 种衰变枚举（对标 BANDecayType）
  model/shell_model_nucleus.dart             # 壳层模型（Chart Intro，可后做）
  data/nuclide_data.dart                     # 查表工具（对标 AtomInfoUtils）
  painters/nucleus_painter.dart              # 核子团 + 电子云
  painters/nuclide_chart_painter.dart        # 核素格子图（Chart Intro）
  widgets/nucleon_creator_tray.dart          # 底部生成器托盘（箭头 + 可拖核子）
  widgets/available_decays_panel.dart
  widgets/half_life_number_line.dart
  config/build_a_nucleus_scenario.dart
  config/build_a_nucleus_scenario_manager.dart
assets/scenarios/build-a-nucleus/manifest.json + default.json
assets/images/full_nuclide_chart.png         # [待确认] 授权后引入
assets/data/nuclide_table.json               # [待确认] 新目录规范
schemas/build_a_nucleus_scenario.schema.json
test/build_a_nucleus_model_test.dart 等
# home_screen.dart：化学学科组下新增 _SimEntry
# pubspec.yaml：声明新 assets 目录
```

落点为 `lib/chemistry/build_a_nucleus/` 属 [推测]（依据 §0.6）；备选 `lib/build_a_nucleus/`（与 forces/optics 平级）——需用户拍板。[待确认]

---

## 17. PhET → Flutter 映射总表

| PhET（TS） | KARTOSLAB Flutter（规划） | 复用/新建 |
|---|---|---|
| joist Sim + Screen | HomeScreen `_SimEntry` + 单 Screen 内两视图 | 复用工程机制 |
| axon Property / DerivedProperty | 可变 Model + setState 派生计算（或 ChangeNotifier） | 工程主流范式 |
| shred Particle / ParticleAtom | `Nucleon` / `NucleusState` | 新建（L2） |
| shred AtomInfoUtils + AtomData | `NuclideData` + `assets/data/nuclide_table.json` | 新建 + 数据提取 |
| NucleonCreatorsNode（托盘+箭头） | `NucleonCreatorTray`（基于 DragTray 扩展） | 复用改造 |
| ParticleAtomNode（核渲染+电子云） | `NucleusPainter` | 新建（L2） |
| scenery RadialGradient 核子球 | Painter 内 RadialGradient | 新建 |
| HalfLifeNumberLineNode（对数数轴） | `HalfLifeNumberLine`（Painter） | 新建 |
| NuclideChartNode 系列 + bamboo | `NuclideChartPainter` | 新建（L2） |
| sun AccordionBox / Checkbox / ResetAllButton / ArrowButton | ExpansionTile / Checkbox / IconButton(restart_alt) / 自绘箭头按钮 | Flutter 原生/自绘 |
| twixt Animation（300px/s 匀速补间） | SimulationClock 驱动的 position lerp | 复用 |
| SymbolNode（^A_ZX） | `IsotopeSymbolText`（RichText 上下标） | 新建 |
| 字符串 JSON | 硬编码文案（工程惯例） | 工程惯例 |
| fullNuclideChart.png | assets/images/ | 引入 [待确认] |

---

## 18. 布局对照（NineGrid 落位规划）

| 九宫格位置 | Decay 屏 | Chart Intro 屏 |
|---|---|---|
| center（≥70%） | 核画布（电子云 + 核子团，含拖放捕获区） | 壳层能级画布 + 迷你原子 |
| topLeft / leftCenter | 半衰期读数 + 数轴 + info | 衰变方程 + 百分比 |
| topRight / rightCenter | Symbol 折叠面板、Available Decays 面板、Electron Cloud 勾选 | Partial Nuclide Chart 折叠面板、Magic Numbers 勾选、Full Chart 按钮 |
| bottomCenter | 核子生成器托盘（DragTray） | 核子生成器托盘 |
| bottomRight | Reset 按钮 | Reset 按钮 |

[推测：依据原 sim 绝对定位坐标（BANConstants.SCREEN_VIEW_*）映射到九宫格语义]

---

## 19. 范围建议

- **MVP（建议本期）**：Decay 屏全量（搭建 + 半衰期 + 5 衰变动画 + 撤销 + Reset + 电子云 + 符号面板）。[推测：占原 sim 约 55-65% 体验价值]
- **第二期**：Chart Intro 屏（壳层 + 核素图 + 衰变方程 + 幻数 + Full Chart）。
- 是否接入探究体系（InquiryDrawer）：[待确认]。

---

## 20. 实现顺序（建议）

1. 数据层：从 shred `AtomData.ts` 提取核素表 → JSON + `NuclideData` 查表类 + 锚定单测（H-1/He-4/C-14/Fe-56/U-238/Pu-240 边界）。
2. Model：`Nucleon`、`NucleusState`（增减核子、存在性/稳定性派生、does-not-form 回退、reset）。
3. 渲染：`NucleusPainter`（核子渐变球 + 同心层排布 + 电子云）。
4. 交互：生成器托盘（箭头增减）→ 拖拽入核（捕获半径）→ 拖出移除。
5. 衰变：5 种衰变动画 + 可用衰变面板 + 撤销。
6. 周边 UI：半衰期数轴 + info dialog、符号面板、稳定性/元素名文本、Reset。
7. 注册与集成：HomeScreen 入口、pubspec assets、布局测试、E2E。
8. （二期）Chart Intro：壳层模型 → 核素图 → 衰变方程 → 幻数/全图。

每步均满足"小步快跑 + 可视反馈"（10-vibecoding 协议）。

---

## 21. 理论工时（小时，不含经验系数）

| 任务 | 工时 | 备注 |
|---|---|---|
| 原项目分析 | 4 | 本文档主体（已大部分完成） |
| 工程映射 | 2 | 本文档 §10/§16/§17（已大部分完成） |
| 数据表提取转换（AtomData→JSON + 校验脚本 + 锚定测试） | 8 | **探索任务**（AtomData 规模未实测，可能翻倍） |
| Model（Nucleon/NucleusState/DecayType/回退逻辑） | 8 | 衰变状态机较复杂 |
| State 接入（setState 范式 + Scenario） | 3 | |
| Controller | 0.5 | Screen 兼任，无独立层 |
| Solver（查表类 NuclideData） | 3 | 纯函数，依赖数据表任务 |
| Painter（NucleusPainter 核子团+电子云；排布近似） | 8 | **探索任务**（视觉保真迭代轮次不可预估） |
| Widget/UI（托盘、衰变面板、半衰期数轴、符号面板、读数） | 12 | 对数数轴与上下标符号较费时 |
| Interaction（生成器拖拽、捕获判定、画布内再拖） | 8 | 拖拽语义改造有风险 |
| Animation（飞入/飞出/衰变发射/1 秒纠正） | 6 | |
| Assets（全图引入、图标自绘） | 2 | [待确认] 授权流程不计入 |
| Config（scenario + schema） | 3 | |
| Testing（model/data/layout/E2E） | 10 | |
| Integration（HomeScreen 注册、三视口验证、收尾） | 4 | |
| **Decay 屏小计** | **约 78–86 h** | 含探索任务上浮 |
| Chart Intro 屏（壳层模型/核素图×3/衰变方程/幻数/全图） | 40–56 | **探索任务**（壳层定位与 ChartTransform 映射未完全解密） |
| **全量合计** | **约 118–142 h** | 纯理论拆分，无经验系数 |

---

## 附：主要证据索引

**PhET 侧（均已实际读取）**

- 官网屏选择页：`build-a-nucleus_all.html` → "It has 2 interactive screens: Decay / Chart Intro"
- 仓库文件树：GitHub API `git/trees/main?recursive=1`（全量）
- `package.json`（phetLibs/screenNameKeys/simFeatures）
- `doc/model.md`、`doc/implementation-notes.md`（官方模型与实现说明）
- `js/build-a-nucleus-main.ts`、`js/common/BANConstants.ts`、`js/common/model/BANModel.ts`、`js/common/model/BANDecayType.ts`、`js/common/model/getAvailableDecaysAndPercents.ts`、`js/decay/model/DecayModel.ts`、`js/decay/view/DecayScreenView.ts`、`js/common/view/BANScreenView.ts`（661 行全文）、`js/common/view/NucleonCreatorsNode.ts`、`js/chart-intro/model/ChartIntroModel.ts`
- shred：`js/AtomInfoUtils.ts`（全部查表 API 与 DECAYS_INFO_TABLE 字段映射）
- `build-a-nucleus-strings_en.json`（全部 UI 文案）

**本工程侧（均已实际勘察）**

- `lib/main.dart`、`lib/screens/home_screen.dart`、`lib/common/` 全 32 文件、`lib/sound/`、`lib/wave_interference/`、`lib/circuit/`、`lib/chemistry/molarity/`、`test/`、`integration_test/`、`assets/`、`schemas/`、`pubspec.yaml`、`docs/knowledge/`、`.cursor/rules/`、`.codebuddy/rules/80-kratos-sim-checklist.mdc`
