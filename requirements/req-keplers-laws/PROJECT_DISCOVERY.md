# Phase 0 — Project Discovery · Kepler's Laws

> 需求：`req-keplers-laws`  
> 日期：2026-09-01  
> 阶段：Phase 0 完成 · 无阻塞决策 · 自动进入 Phase 1  
> 标记：`[已确认]` 有源码/配置/目录依据 · `[推测]` 有依据的推断 · `[待确认]` 证据不足

---

## 0. 结论摘要

1. **KARTOSLAB** 是独立 Flutter App（包名 `kratos`，SDK `^3.11.1`），入口 `lib/main.dart` → `HomeScreen`，无 GoRouter。[已确认]
2. 已注册 sim：力与运动 / 电路 / 磁铁与罗盘 / 几何光学 / 色觉 / 波的干涉 / 声波 / 电磁波 / 摩尔浓度 / 构建原子核。Home **无** Kepler's Laws。[已确认 `lib/screens/home_screen.dart`]
3. 原版 **Kepler's Laws** 是 PhET HTML5/TypeScript（`keplers-laws` 1.3.0-dev.0），**不是 Java**。[已确认 `package.json`]
4. 四屏：**First Law / Second Law / Third Law / All Laws**，共享 `KeplersLawsModel` + `KeplersLawsScreenView`，靠 `initialLaw` / `isAllLaws` 分流。[已确认 `js/keplers-laws-main.ts` + 四个 `*Screen.ts`]
5. 轨道不是 N-body 积分，而是 **`EllipticalOrbitEngine` 解析椭圆 + Kepler 方程 Newton-Raphson**。[已确认 `doc/implementation-notes.md` + `EllipticalOrbitEngine.ts`]
6. 物理底座在 **`solar-system-common`**（Body / Engine / ScreenView / TimeControl）。本工程没有 My Solar System，**不抽 common**。[已确认]
7. 推荐落点：`lib/astronomy/keplers_laws/` + Home「物理 → 天体力学」。无不可逆决策。[推测 · 类比 magnetism]
8. 当前工程 **无** Kepler 旧实现可归档。`phet/` 下是 magnet / quantum 草稿与通用 widget 实验，**不消费、不修改**。[已确认]

---

## 1. 当前 KARTOSLAB 工程

### 1.1 根与入口

| 项 | 值 | 证据 |
|---|---|---|
| 工作区 | `KartosLab/`（包名 `kratos`） | `pubspec.yaml:1` |
| SDK | `^3.11.1` | `pubspec.yaml:22` |
| 入口 | `lib/main.dart` → 横屏锁定 → `KratosApp` → `HomeScreen` | `lib/main.dart:7-46` |
| 路由 | `Navigator.push(MaterialPageRoute)`，无命名路由 | `home_screen.dart:403-405` |
| 依赖 | `flutter_svg ^2.3.0` · `audioplayers ^6.7.1` | `pubspec.yaml:36-38` |
| AGENTS.md 路径 | 写 `c:\workspace\kratos`，与本工作区不一致 | 以本仓库为准 [已确认] |

### 1.2 `lib/` 学科目录

```
lib/
  main.dart
  screens/home_screen.dart
  common/                    # L0
  circuit/  forces/  optics/  color_vision/
  sound/  radio_waves/  wave_interference/
  magnetism/magnet_and_compass/
  chemistry/molarity/
  chemistry/build_a_nucleus/
```

无 `astronomy/`、无 `keplers*`。[已确认 glob]

### 1.3 Home 注册

`HomeScreen._disciplines`：物理（力学 / 电学与电路 / 电磁学 / 光学与波动）+ 化学（溶液与浓度 / 原子核）。点击卡片 `MaterialPageRoute` 进 Screen。[已确认]

### 1.4 common（L0）与本 sim 相关度

| L0 | 路径 | 本 sim | 判定 |
|---|---|---|---|
| NineGridLayout | `common/widgets/nine_grid_layout.dart` | 页面级外壳 | **复用** |
| KratosTabbedScreen | `common/widgets/kratos_tab_bar.dart` | 四屏入口 | **复用**（BAN 先例） |
| SimulationClock | `common/simulation_clock.dart` | 轨道步进 | **复用心跳**；速度档位在 sim 内（原版 FAST=7/4 NORMAL=1 SLOW=1/4） |
| TimeControlBar | `common/widgets/time_control_bar.dart` | 播放/步进/重置 | **不直接套**。原版有 Restart（回到上次交互）≠ Reset All，且有 Slow/Normal/Fast 三档。[已确认 `SolarSystemCommonTimeControlNode.ts`] |
| KratosSlider | `common/controls/kratos_slider.dart` | 恒星质量 | **可用语义**，外观按原版 NumberControl |
| KratosComboBox | `common/controls/kratos_combo_box.dart` | Target Orbit | **可用语义** |
| KratosRadioGroup | `common/controls/kratos_radio_group.dart` | 定律选择 / 速度档 | **可用语义** |
| PropertyControlPanel | `common/widgets/property_control_panel.dart` | scenario 驱动面板 | **不用**（无 scenario） |
| DragDropWorkspace | `common/widgets/drag_drop_workspace.dart` | 托盘拖放 | **不用**（原版是画布内拖行星/速度矢） |
| SnapshotChart / GraphSuite | `common/chart/` | T vs a 图 | **不套**。第三定律图是竹笛式散点+幂次按钮，语义不是时间序列图。[已确认 `ThirdLawGraph.ts` 存在] |
| ScenarioManagerBase | `common/scenario/` | JSON 场景 | **不用**。原版无 scenario 文件 |

G3：Body / 椭圆引擎 / 天体 TimeControl 均为第 1 用户，留在 sim 内。

### 1.5 已有 sim 架构范式（选最近邻，不复制 BAN）

| 范式 | 代表 | 数据流 |
|---|---|---|
| 可变 Model + Clock + setState | sound / wave / radio / magnet | tick 改字段 |
| 不可变 State + Solver | circuit / optics | copyWith |
| ChangeNotifier Controller | molarity / BAN | 命令进 Controller |

Kepler 最近邻：**动力学 + 解析引擎**（sound/magnet 心跳 + BAN 的显式 Controller 编排）。  
推荐：`KeplersLawsState`（SSOT）+ `EllipticalOrbitEngine`（纯计算）+ `KeplersLawsController`（tick / drag / reset）+ Render DTO + Painters。  
**禁止**把 BAN 的核素仓库 / tray drag / 半衰期轴抄进来。

磁铁屏先例（页面级 NineGrid + 画布内 Stack/Positioned）：`magnet_and_compass_screen.dart:20-32`。[已确认] Kepler 同样：NineGrid 包外壳，中心格是模型坐标 Canvas。

### 1.6 tests / assets / schemas / requirements

- `test/`：各 sim 专项 + common + visual_qa capture。无 kepler。
- `integration_test/`：`app_test.dart` 等 4 个。
- `assets/`：images SVG、sounds/`tap.wav`、scenarios 按 sim 分目录、`data/nuclide_table.json`。无 kepler。
- `schemas/`：8 个 `*_scenario.schema.json` + nuclide。
- `requirements/`：`req-build-a-nucleus/`、`project-migration/`（magnet）。本需求新建 `req-keplers-laws/`。

### 1.7 rules / instructions

| 文件 | 对本 sim |
|---|---|
| `80-kratos-sim-checklist.mdc` | NineGrid ≥70%、无溢出、响应式；L0 复用 |
| `00` / `10` / `20` / `60` | 读后改、30min、知识库优先、引用先行 |
| 用户本次指令 | 分阶段、源码保真、NineGrid 不吞模拟对象、不改无关 sim |
| checklist 配置化 JSON | 与原版冲突 → **[有意差异] 不做假 scenario** |

### 1.8 `phet/` 目录（非本 sim 源码）

`phet/magnet_and_compass/`、`phet/quantum_*`、`phet/widgets/`。无 keplers-laws。  
本机 `git clone` / zip 下载 GitHub 失败；源码取证走 raw.githubusercontent.com + GitHub Trees API。[已确认]

---

## 2. 原版 PhET 调查

### 2.1 身份

| 项 | 值 |
|---|---|
| 官网 | https://phet.colorado.edu/en/simulations/keplers-laws |
| 源码 | https://github.com/phetsims/keplers-laws |
| 版本 | `1.3.0-dev.0` · GPL-3.0 |
| 栈 | TypeScript + joist Screen + axon Properties + scenery |
| phetLibs | bamboo · my-solar-system · solar-system-common |
| 屏名 | `screen.firstLaw` / `secondLaw` / `thirdLaw` / `allLaws` |

### 2.2 启动与导航

`keplers-laws-main.ts`：`simLauncher.launch` → `new Sim(title, [First, Second, Third, AllLaws], options)`。  
joist Home 选屏。本工程用一张 Home 卡 + `KratosTabbedScreen` 四 Tab，与 BAN「一张卡 + Tab」同构。[已确认入口] [有意差异：无 joist 多语言 / PhET-iO / Projector]

### 2.3 Model

```
SolarSystemCommonModel          # 时间、播放、zoom、measuring tape、bodies
  └── KeplersLawsModel          # law、target orbit、alwaysCircular、stopwatch、第三定律幂次
        └── EllipticalOrbitEngine  # 解析轨道（Engine 子类）
Body × 2：sun（固定原点）、planet
PeriodTracker / OrbitalArea / TargetOrbit / OrbitTypes / LawMode
```

默认体（`KeplersLawsModel.ts:151-179`）[已确认]：

| | mass | position | velocity |
|---|---|---|---|
| sun | 200（`MASS_OF_OUR_SUN`） | (0,0) 只读 | (0,0) 只读 |
| planet | 50 | (2.00, 0) | (0, 17.2358) |

`engineTimeScale: 0.002`；`modelToViewTime: 1000/12.6`；`zoomLevelRange: 1..2 default 2`。  
时间倍率：FAST 7/4、NORMAL 1、SLOW 1/4。[已确认 `SolarSystemCommonModel.ts:81-85`]

### 2.4 Solver（EllipticalOrbitEngine）

| 步骤 | 方法 | 公式要点 |
|---|---|---|
| 半长轴 | `calculate_a` | vis viva：`a = r μ / (2μ − r v²)` |
| 离心率 | `calculate_e` | 比能量：`e = √\|1 − (r v sin(θv−θr))² / (a μ)\|` |
| 角 | `calculateAngles` | 真近点角、近日点幅角、逆行、`W = −500 / T` |
| 第三定律 | `thirdLaw` | `T = (a³ · INITIAL_MU / μ)^{1/2}` |
| 推进 | `run` | `M += dt·W` → Newton-Raphson → 位置/速度，保角动量 L |
| 面积 | `calculateOrbitalDivisions` | 等时分割 2–6 份（默认 4） |

常量：`INITIAL_G = 4.45669`，`INITIAL_MU = 891.34`，逃逸 ε=0.99。[已确认]

Invalid：

- `CRASH_ORBIT`：近日点 `a(1−e) < sunRadius`（`Body.massToRadius`）
- `ESCAPE_ORBIT`：速度 ≥ 逃逸 × ε；速度被夹到逃逸以下，显示近抛物线椭圆
- `allowedOrbitProperty=false` 时 **禁止播放**（`playingAllowedProperty: model.engine.allowedOrbitProperty`）

### 2.5 View / 图层

`SolarSystemCommonScreenView` 五层：`bottomLayer` / `bodiesLayer` / `componentsLayer` / `interfaceLayer` / `topLayer`。  
MVT：`createSinglePointScaleInvertedYMapping(ZERO, layoutCenter, zoomScale)`，Y 轴向上。[已确认]

`KeplersLawsScreenView` 挂载：不可拖太阳、可拖行星、可拖速度矢、重力矢、目标轨道、椭圆节点、警告条、左上面板、右上 checkbox+zoom、底部 TimeControl、Reset All、秒表、周期计时器。

### 2.6 四屏差异

| 屏 | Model 选项 | View |
|---|---|---|
| First | `initialLaw=FIRST_LAW` | 轴/焦点/弦/离心率 |
| Second | `SECOND_LAW` | 面积分割、节拍器、无 Target Orbit tandem |
| Third | `THIRD_LAW` | T vs a、恒星质量、周期测量 |
| All Laws | `isAllLaws=true` + FIRST | `allowLawSelection` + LawsRadioButtonGroup |

切定律：`saveAndDisableVisibilityState(last)` → `resetVisibilityState(new)`。[已确认 `KeplersLawsVisibleProperties.ts`]

### 2.7 交互

- 拖行星：`mapPosition` 限制在逃逸半径与 UI 挖空区；`dragSpeed 150` / `shiftDragSpeed 50`
- 拖速度：`minimumMagnitude 1.055`、`snapToZero false`、`maxMagnitude=escapeSpeed`；Always Circular 时不可交互
- 用户一改位置/速度/质量：`isPlaying=false`，rewind 失效，松手 `saveStartingBodyInfo`
- Restart：回到上次松手状态；Reset All：默认体 + 可见性 hard reset
- 无 Undo 栈。[已确认 Model.reset / restart，无 undo]

### 2.8 动画 / Clock

- joist `step(dt)`：仅 `isPlaying` 时 `engine.run`
- Zoom：`animatedZoomScale` 45↔100，duration **0.5s**，`Easing.CUBIC_IN_OUT` [已确认]
- PeriodTracker FADING：**3s** [已确认 `PeriodTracker.ts:50`]
- 无粒子飞入类动画

### 2.9 坐标与单位

| 量 | 单位 |
|---|---|
| 距离 | AU（模型×`POSITION_MULTIPLIER=0.01`） |
| 质量 | 模型单位；太阳 200 ×10^28 kg |
| 时间 | years |
| 速度 | km/s |
| 显示半径 | 夸张：`max(0.03, 0.023·m^{1/3})`，太阳约 0.15 AU vs 真实 0.004 |

### 2.10 Assets

**images/**：`focalDistance`、`infoSemiMajorAxis/Minor`、`periodTimerBackground/Icon`、`planetPosition/Velocity`、`rvAngle`（Info 对话框插图 + 周期计时器）。  
**sounds/**：碰撞、逃逸、节拍器×4、周期分割 2–6、Success、离心率 loop。  
**strings**：`keplers-laws-strings_en.json`。  
官方截图在仓库 `assets/keplers-laws-screenshot-screen{1-4}.png`。[已确认 tree] 本机尚未落地文件 → Phase 2 下载。

### 2.11 明确不做（与 BAN/magnet 同类有意差异）

- joist 多语言 / PDOM / 键盘帮助全文 / PhET-iO Studio 目标轨道 1–4
- Projector 色表（只实现 default 黑底）
- `&dev` 拖拽调试 Path

---

## 3. 迁移含义（供后续阶段，本阶段不编码）

### 3.1 目标目录（推荐，非拍板阻塞）

```
lib/astronomy/keplers_laws/
  keplers_laws_constants.dart
  model/          # state, body, engine, orbital_area, period_tracker, target_orbit, law_mode
  controller/
  render/         # MVT + 只读绘制 DTO
  painters/
  widgets/        # 面板、时间条、秒表（sim 内）
  screens/        # home + 四屏或一屏+law 参数
assets/images/keplers_laws/   # 仅复制原版存在的 PNG
assets/sounds/keplers_laws/   # 原版 mp3/wav
test/astronomy/keplers_laws/
requirements/req-keplers-laws/visual-qa/
```

### 3.2 不抽 common 的理由

`solar-system-common` 为 Kepler + My Solar System 共享。本仓库无后者 → 第 1 用户，引擎留在 sim 内。

### 3.3 风险（非阻塞）

| 风险 | 处理 |
|---|---|
| 引擎公式多、浮点敏感 | Phase 4 对 `calculate_a/e/angles/trueAnomaly` 做数值单测，对照源码常量 |
| 原版截图未在本机 | Phase 2 下载官方 PNG；下不下来标 `[待确认：缺少原版运行截图]`，不伪造 |
| TimeControlBar 语义不足 | sim 内实现，不改 L0 API |
| 声音资源 GPL | 原样复制并记录来源；不自制替代音 |

### 3.4 阻塞决策

**无。** 目录、Tab、不抽 common、不做假 scenario 均有先例或源码依据。

---

## 4. Phase 0 清单勾销

| 检查项 | 状态 |
|---|---|
| KARTOSLAB 架构 | 完成 |
| common | 完成 |
| 已有 simulation | 完成 |
| Home | 完成 |
| tests | 完成 |
| assets | 完成 |
| requirements | 完成 |
| rules | 完成 |
| 原版 model/view/controller/screens/constants/assets/strings/animations/lifecycle/navigation/data | 完成（源码级；运行截图 Phase 2） |

**测试 / analyze：** 本阶段无代码变更。  
**Blocked：** 无。  
**视觉：** 尚未建立基线。  
**下一阶段：** Phase 1 Source Analysis。
