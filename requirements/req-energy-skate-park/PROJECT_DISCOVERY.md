# Phase 0 — Project Discovery · Energy Skate Park

> 需求：`req-energy-skate-park`  
> 日期：2026-09-03  
> 阶段：Phase 0 完成 · 无阻塞决策 · 自动进入 Phase 1  
> 标记：`[已确认]` 有源码/配置/目录依据 · `[推测]` 有依据的推断 · `[待确认]` 证据不足

---

## 0. 结论摘要

1. **KARTOSLAB** 是独立 Flutter App（包名 `kratos`，SDK `^3.11.1`），入口 `lib/main.dart` → `HomeScreen`。[已确认]
2. Home **无** Energy Skate Park 入口。本 sim 归入 **物理 → 力学**（与 Collision Lab / 力与运动并列）。[已确认 `lib/screens/home_screen.dart`]
3. 原版是 PhET HTML5/TS **`energy-skate-park` 1.6.0-dev.2**（`package.json`）。`dependencies.json` 注释写 `1.5.0-rc.0`——**以 package.json 为准**，不因官网 latest 替换本地。[已确认]
4. **四个 joist Screen**（注册顺序 = 默认首屏 Intro）：`IntroScreen` → `MeasureScreen` → `GraphsScreen` → `PlaygroundScreen`。各自独立 Model，**不共享物理状态**。[已确认 `energy-skate-park-main.ts:42-47`]
5. 共享 preferences：`EnergySkateParkPreferencesModel` 跨屏共享（外观/区域文化等），**非**物理 Model。[已确认]
6. 物理核心完整可确认：`EnergySkateParkModel.stepEuler` / 曲率离轨 / Hermite 样条（numeric.js + `SplineEvaluation`）/ 能量公式。**不需要**用教材补模型，不停自动推进。[已确认]
7. 推荐落点：`lib/energy_skate_park/`（与 `collision_lab/`、`normal_modes/` 同级）。**不**使用 `lib/src/simulations/`。
8. 当前工程 **无** ESP 旧实现。Phase 12 无归档对象。
9. **无独立 Clock 类**；`EventTimer` + 固定 `FRAME_RATE=60` → `constantStep` → 物理。[已确认]
10. 视觉资产：多区域 skater PNG（usa/africa/…）+ mountains/cement 纹理；工程内尚无拷贝。[已确认]

---

## 1. 当前 KARTOSLAB 工程

### 1.1 根与入口

| 项 | 值 | 证据 |
|---|---|---|
| 工作区 | `KartosLab/`（包名 `kratos`） | `pubspec.yaml:1` |
| SDK | `^3.11.1` | `pubspec.yaml:22` |
| 入口 | `lib/main.dart` → 横屏锁定 → `HomeScreen` | `lib/main.dart` |
| 路由 | `Navigator.push(MaterialPageRoute)` | `home_screen.dart` |
| 依赖 | `flutter_svg ^2.3.0` · `audioplayers ^6.7.1` | `pubspec.yaml` |
| AGENTS.md 路径 | 写 `c:\workspace\kratos`，与本工作区不一致 | 以本仓库为准 [已确认] |

### 1.2 `lib/` 顶层学科目录

已有：`astronomy/` `cck_ac_virtual_lab/` `chemistry/` `circuit/` `collision_lab/` `color_vision/` `common/` `density/` `forces/` `fourier_making_waves/` `magnetism/` `normal_modes/` `optics/` `radio_waves/` `screens/` `sound/` `wave_interference/`

**无** `energy_skate_park*`。[已确认]

### 1.3 Home 注册

`HomeScreen._disciplines`：物理（力学 / 密度与浮力 / 电学与电路 / 电磁学 / 天体力学 / 光学与波动）+ 化学。

本 sim 归入 **物理 → 力学** 新卡「Energy Skate Park」（能量 · 轨道 · 滑板）。

四屏导航：一张 Home 卡 + `KratosTabbedScreen`（Collision Lab / Normal Modes 先例）。**不**改 Navigation 架构。

### 1.4 common（L0）与本 sim 相关度

| L0 | 路径 | 本 sim | 判定 |
|---|---|---|---|
| NineGridLayout | `common/widgets/nine_grid_layout.dart` | 页面级外壳 | **复用**。中间格放整个 PhET ScreenView（局部坐标） |
| KratosTabbedScreen | `common/widgets/kratos_tab_bar.dart` | 四 Screen | **复用** |
| SimulationClock | `common/simulation_clock.dart` | 心跳 | **评估后不套语义**。原版用墙钟 dt → EventTimer → 固定 1/60。Sim 内自建 `EspPhysicsClock`；不改 common |
| TimeControlBar | `common/widgets/time_control_bar.dart` | Play/Pause/Step/Slow | **不套外观**。原版有 Normal/Slow；sim 内自绘 |
| chart/* | `common/chart/` | Graphs 屏 | **可参考**折线绘制；能量图坐标系与采样按源码，不抽 ESP-specific API |
| KratosSlider 等 | `common/controls/` | 质量/摩擦/重力 | **可参考交互**，外观按 PhET 面板 |

G3：Track/Spline/Skater/Euler/离轨/Playground 编辑均为 **第 1 个 ESP 用户**，留在 `lib/energy_skate_park/`。

### 1.5 已有 sim 架构范式（最近邻）

| 范式 | 代表 | 与本 sim |
|---|---|---|
| 可变 Model + 墙钟 Ticker | Collision Lab / CCK | **最近邻**：可变 Skater + Physics.step |
| ChangeNotifier Controller | Collision Lab / Normal Modes | Controller 转发命令 |
| 不可变快照 | Collision Lab BallState | **SkaterState** 同构：步进中不可变快照，结束写回 Skater |

推荐：

```
ScreenModels（Intro / Measure / Graphs / Playground）
  → Track[] + Skater + PhysicsSolver(+stepEuler)
  → EspPhysicsClock（Ticker 墙钟 → EventTimer 语义）
  → DataSamples / GraphHistory
  → RenderData（纯数据）
    → Painters / Widgets
Controller 改 Model；Painter 不计算物理/能量
```

**禁止**复制 Normal Modes Spectrum 布局或 Collision Lab 球碰引擎。本 sim 布局是 PlayArea（轨道+滑板）+ 右 ControlPanel + 底 TimeControl + 可选 Graph/Bar/Pie/Toolbox。

### 1.6 既有物理组件

工程内 **无** 可复用 cubic-spline track / skater energy 引擎。[已确认]  
`forces/` 是 1D 力与运动，语义不同，不复用。  
`collision_lab/solver/` 球碰，不复用。

---

## 2. 本地 Energy Skate Park 源码

### 2.1 版本与根

| 项 | 值 |
|---|---|
| 路径 | `phet sourses/energy-skate-park-main/energy-skate-park-main` |
| `package.json` version | **`1.6.0-dev.2`** [已确认] |
| `dependencies.json` 注释 | `1.5.0-rc.0` / branch `1.5` — 仅作依赖快照，**不以之覆盖 package.json** |
| `phet.screenNameKeys` | intro / measure / graphs / playground |
| `phetLibs` | `griddle`, `bamboo` |
| `preload` | `../sherpa/lib/numeric-1.2.6.js`（样条构造） |
| 官方文档 | `doc/model.md` · `doc/implementation-notes.md` · `doc/release-notes.md` |
| `.git` | 不存在于本地拷贝 [推测：zip 导出] |

### 2.2 Screen 矩阵

| # | 类 | 英文名 | Model | 基类链要点 | 默认特殊 |
|---|---|---|---|---|---|
| 1 | IntroScreen | Intro | IntroModel | FullTrackSet → TrackSet → **SaveSample** → Model | `defaultSaveSamples: false`；完整 4 轨；BarGraph 默认开 |
| 2 | MeasureScreen | Measure | MeasureModel | 同上 FullTrackSet | `tracksConfigurable: true`；`showBarGraph: false`；Energy Sensor；强制速度数值可见 |
| 3 | GraphsScreen | Graphs | GraphsModel | TrackSet → SaveSample → Model | 仅 PARABOLA + DOUBLE_WELL；`saveSampleInterval: 0.01`；无 FullTrackSet |
| 4 | PlaygroundScreen | Playground | EnergySkateParkPlaygroundModel | **直接 EnergySkateParkModel** | 全交互轨；无 SaveSample；Toolbox 加轨/擦除 |

**默认屏**：Intro。[已确认]  
**Screen 切换**：各 Screen 独立 Model 实例；preferences 共享。[已确认]

**预置轨道类型**（`PremadeTracks.TrackTypes`）：`PARABOLA` · `RAMP` · `DOUBLE_WELL` · `LOOP`。[已确认]  
Intro/Measure 使用 FullTrackSet（四轨全集，默认顺序以 TrackSet 默认 `trackTypes` 为准）。Graphs 仅抛物线 + 双阱。

### 2.3 源码树（业务）

```
js/
  energy-skate-park-main.ts     # 入口 · 四屏注册
  common/
    EnergySkateParkConstants.ts
    EnergySkateParkColors.ts
    SplineEvaluation.ts         # Hermite 求值（numeric 加速版）
    model/
      EnergySkateParkModel.ts   # ★ step / stepEuler / 离轨 / 地面 / 自由落体
      Skater.ts / SkaterState.ts
      Track.ts / ControlPoint.ts
      PremadeTracks.ts
      EnergySkateParkTrackSetModel.ts
      EnergySkateParkFullTrackSetModel.ts
      EnergySkateParkSaveSampleModel.ts
      EnergySkateParkDataSample.ts
      EnergySkateParkPlaygroundModel.ts  # 在 playground/model/
      EnergySkateParkPreferencesModel.ts
    view/                       # ScreenView · TrackNode · SkaterNode · Bar/Pie · Toolbox …
  intro/ / measure/ / graphs/ / playground/
images/                         # 区域 skater + 背景纹理 + screen icons
doc/model.md
```

### 2.4 物理 / 轨道关键事实（Phase 0 摘要）

详见 Phase 1 `SOURCE_ANALYSIS.md`。此处只锁风险点：

| 主题 | 事实 | 标记 |
|---|---|---|
| 位置参数 | `parametricPosition u ∈ [0, (n-1)/n]`，**非弧长参数**；控制点均匀分布 | [已确认] |
| 样条 | `numeric.spline` Hermite + `SplineEvaluation.atNumber` | [已确认] |
| 积分 | 先 `v += a·dt`，再位移（轨上含 `½a dt²` + 弧长映射）；轨上 **4×(dt/4)** | [已确认] |
| 时钟 | `FRAME_RATE=60`；慢速每 3 帧一步 | [已确认] |
| 能量 | `KE=½mv²`；`PE=−m·g·(y−h_ref)`（g 为负）；`TE+=|Ff|·Δs`；`T=KE+PE+TE` | [已确认] |
| 离轨 | `(F_r < mv²/r ∧ outside) ∨ (F_r > mv²/r ∧ ¬outside)`，stick 可覆盖 | [已确认] |
| Measure Sensor | 读 `dataSamples` 最近点，**不**实时重算能量 | [已确认] |
| Graphs | Model history `dataSamples`，间隔 0.01 s | [已确认] |

### 2.5 资产

| 类 | 内容 |
|---|---|
| Skater | 多文化目录 `images/{usa,africa,…}/`：Left/Right/Headshot PNG（skater1–6, dog, cat） |
| 环境 | `mountains.png` · `cementTextureDark.jpg` |
| UI | attach/detach.png · 四屏 icon |
| 声音 | 源码树无独立 `sounds/`（依赖 scenery-phet / tambo 公共库）[已确认本地无] |
| 工程 Flutter assets | **尚无** ESP 拷贝 |

迁移策略：优先拷贝 `usa` 默认 skater + mountains；矢量轨/能量条自绘；不使用 Material icon 冒充。

### 2.6 依赖（运行时相关）

| 依赖 | 用途 | Flutter 策略 |
|---|---|---|
| numeric-1.2.6 | `numeric.spline` 构造 Hermite | 纯 Dart 同语义实现（构造 + `SplineEvaluation`） |
| EventTimer (dot/axon 生态) | 固定帧物理 | Dart `EspEventTimer` |
| ModelViewTransform2 | 模型→视图（y 倒置） | `EspMvt` |
| griddle / bamboo | 图表 | Graphs 用自绘 / 参考 `common/chart` |
| joist Screen | 多屏 | `KratosTabbedScreen` |

---

## 3. 风险与非阻塞项

| 风险 | 级别 | 处置 |
|---|---|---|
| stepEuler + 4 子步进 + correctEnergy 启发式 | P0 | 逐行移植 + 数值测试 |
| 曲率离轨 / loop / jump | P0 | 逐行移植条件；禁止教材改写 |
| numeric.spline 构造细节 | P0 | 对照 numeric-1.2.6 + SplineEvaluation 测直线/抛物/loop |
| Playground 连接/分裂/控制点上限 15 | P1 | 按 Model API 移植 |
| Graphs 回放游标 | P1 | 按 GraphsModel.stepModel |
| 多文化 skater 图 | P2 | MVP 用 usa；preferences 区域切换可后置 |
| 原版 runtime 截图 | P2 | Phase 2 标 `[待确认：缺少原版运行截图]`，不伪造 |
| 键盘连接 ComboBox（a11y） | P3 | Flutter 暂标 `[有意差异]` 若无法完整复刻 a11y |

**无阻塞架构决策**：不改 common API、不建跨 sim 物理框架、不改 Theme/Navigation。自动进入 Phase 1。

---

## 4. 输出与下一阶段

| 产物 | 状态 |
|---|---|
| `PROJECT_DISCOVERY.md` | ✅ 本文件 |
| `meta.yaml` / `process.txt` | ✅ 已初始化 |
| Phase 1 `SOURCE_ANALYSIS.md` | → 自动开始 |

落点确认：`lib/energy_skate_park/` + `test/energy_skate_park/` + Home **力学** 卡。
