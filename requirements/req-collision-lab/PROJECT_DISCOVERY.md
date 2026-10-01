# Phase 0 — Project Discovery · Collision Lab

> 需求：`req-collision-lab`  
> 日期：2026-09-03  
> 阶段：Phase 0 完成 · 无阻塞决策 · 自动进入 Phase 1  
> 标记：`[已确认]` 有源码/配置/目录依据 · `[推测]` 有依据的推断 · `[待确认]` 证据不足

---

## 0. 结论摘要

1. **KARTOSLAB** 是独立 Flutter App（包名 `kratos`，SDK `^3.11.1`），入口 `lib/main.dart` → `HomeScreen`。[已确认]
2. Home **无** Collision Lab 入口。力学组目前仅有「力与运动」。本 sim 归入 **物理 → 力学**。[已确认 `lib/screens/home_screen.dart`]
3. 原版是 PhET HTML5 **`collision-lab` 1.2.0-dev.0**（`package.json`）。`dependencies.json` 注释写 `1.1.0-dev.13`（2021）——**以 package.json 为准**，不因官网 latest 替换本地。[已确认]
4. **四个 joist Screen**（注册顺序 = 默认首屏）：`IntroScreen` → `Explore1DScreen` → `Explore2DScreen` → `InelasticScreen`。各自 `createModel()`，**不共享 Model**。[已确认 `collision-lab-main.js:32-37`]
5. 碰撞数学在本地源码中**完整可确认**（`CollisionEngine` + 三屏特化 + `RotatingBallCluster`）。**不需要**用教科书补模型，不停自动推进。[已确认]
6. 推荐落点：`lib/collision_lab/`（与 `normal_modes/`、`cck_ac_virtual_lab/` 同级）。**不**使用 `lib/src/simulations/`。
7. 业务 UI 无 SVG/PNG runtime asset：球/箭头/图标为 scenery 矢量绘制；`assets/` 仅有 8 张参考截图。[已确认]
8. 当前工程 **无** Collision Lab 旧实现。Phase 12 无归档对象。
9. **无独立 Clock 类**；时间在 `CollisionLabModel.step/stepManual`。[已确认]
10. **Reverse step ≠ history**：负 `dt` + `elasticity = 1/e`；仅 `elasticity=100%` 时 UI 启用后退。[已确认]

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

已有：`common/` `circuit/` `forces/` `optics/` `color_vision/` `sound/` `radio_waves/` `wave_interference/` `magnetism/` `astronomy/` `density/` `chemistry/` `cck_ac_virtual_lab/` `normal_modes/` `fourier_making_waves/` `screens/`

**无** `collision_lab*`。[已确认 glob]

### 1.3 Home 注册

`HomeScreen._disciplines`：物理（力学 / 密度与浮力 / 电学与电路 / 电磁学 / 天体力学 / 光学与波动）+ 化学。

本 sim 归入 **物理 → 力学** 新卡「Collision Lab」（动量 · 弹性 · 非弹性）。

四屏导航：一张 Home 卡 + `KratosTabbedScreen`（Normal Modes / Kepler 先例）。**不**改 Navigation 架构。

### 1.4 common（L0）与本 sim 相关度

| L0 | 路径 | 本 sim | 判定 |
|---|---|---|---|
| NineGridLayout | `common/widgets/nine_grid_layout.dart` | 页面级外壳 | **复用**。中间格放整个 PhET ScreenView（局部坐标） |
| KratosTabbedScreen | `common/widgets/kratos_tab_bar.dart` | 四 Screen | **复用** |
| SimulationClock | `common/simulation_clock.dart` | 心跳 | **不套**。它按 vsync 固定 `1/60`；原版用墙钟 `dt` × speed factor 再进 `CollisionEngine.step`。不改 common |
| TimeControlBar | `common/widgets/time_control_bar.dart` | Play/Pause/Step | **不套外观**。原版 `CollisionLabTimeControlNode`（含 reverse step 条件、Normal/Slow） |
| KratosSlider / NumberField | `common/controls/` | 质量/弹性/Keypad | **可参考交互**，外观按 PhET 面板；不抽通用 collision API |
| arrow_painter | `common/controls/arrow_painter.dart` | 动量/速度箭头 | **评估后**若语义通用可复用几何；否则 sim 内自绘 |

G3：CollisionEngine / RotatingBallCluster / MomentaDiagram / BallValuesPanel 均为 **第 1 个 Collision Lab 用户**，留在 `lib/collision_lab/`。

### 1.5 已有 sim 架构范式（最近邻）

| 范式 | 代表 | 与本 sim |
|---|---|---|
| 可变 Model + 墙钟 Ticker | CCK / Normal Modes | **最近邻**：可变 Ball 状态 + Engine.step |
| ChangeNotifier Controller | Kepler / Density | Controller 转发命令 |
| 不可变 State + Solver | circuit / optics | BallState 快照可用于测试/Restart |

推荐：

```
ScreenModels（Intro / Explore1D / Explore2D / Inelastic）
  → BallSystem + PlayArea + CollisionEngine(+子类)
  → PhysicsClock（Ticker 墙钟 dt）
  → RenderData（纯数据）
  → Painters / Widgets
Controller 改 Model；Painter 不计算碰撞
```

**禁止**复制 Normal Modes 的 Spectrum/弹簧布局。本 sim 布局是 PlayArea + 右 ControlPanel + 底 BallValues + MomentaDiagram。

### 1.6 既有物理组件

工程内 **无** 可复用球碰球引擎。[已确认]  
`forces/` 是力与运动，语义不同，不复用。

---

## 2. 本地 Collision Lab 源码

### 2.1 版本与根

| 项 | 值 |
|---|---|
| 路径 | `phet sourses/collision-lab-main/collision-lab-main` |
| `package.json` version | **`1.2.0-dev.0`** [已确认] |
| `phet.screenNameKeys` | intro / explore1D / explore2D / inelastic |
| `phetLibs` | `griddle` |
| `.git` | 不存在 |
| 官方文档 | `doc/model.md` · `doc/implementation-notes.md` · `doc/algorithms/ball-to-ball-collision-detection.md` |

### 2.2 Screen 矩阵

| # | 类 | 英文名 | Model | Engine | 维度 | 默认球数 | 特殊 |
|---|---|---|---|---|---|---|---|
| 1 | IntroScreen | Intro | IntroModel | IntroCollisionEngine | 1D | 2 固定 | 无反射边；Change in Momentum；grid 强制 tick |
| 2 | Explore1DScreen | Explore 1D | Explore1DModel | Explore1DCollisionEngine | 1D | 1–5，默认 2 | e=0 分组粘连；Reflecting Border |
| 3 | Explore2DScreen | Explore 2D | Explore2DModel | CollisionEngine（基类） | 2D | 1–4，默认 2 | 弹性 ≥5%（禁止 0）；Paths |
| 4 | InelasticScreen | Inelastic | InelasticModel | InelasticCollisionEngine | 2D | 2 固定 | e=0；Stick/Slip；Presets；RotatingBallCluster |

**默认屏**：Intro。[已确认]  
**Screen 切换**：各 Screen 独立 Model；joist 生命周期内 Ball 对象预创建、不 dispose。[已确认 `implementation-notes.md`]

### 2.3 源码树（业务）

```
js/
  collision-lab-main.js
  common/{model,view}/     # PlayArea, Ball, BallSystem, CollisionEngine, MomentaDiagram, …
  intro/{model,view}/
  explore1D/{model,view}/
  explore2D/{model,view}/
  inelastic/{model,view}/
doc/
assets/                    # 仅 PNG 截图 ×8
collision-lab-strings_en.json
```

**无** `tests/`、**无** `images/`、**无** SVG。[已确认]

### 2.4 关键常量（预览）

| 常量 | 值 | 证据 |
|---|---|---|
| PlayArea 默认 | (−2,−1)–(2,1) m | `PlayArea.DEFAULT_BOUNDS` |
| 1D 高度 | 1.1 m | `PLAY_AREA_1D_HEIGHT` |
| 密度 | 35 kg/m³ | `BALL_DEFAULT_DENSITY` |
| Constant radius | 0.15 m | `BALL_CONSTANT_RADIUS` |
| Mass / Velocity range | 0.1–3 / −3–3 | Constants |
| TIME_STEP_DURATION | 0.01 s | QueryParameters |
| SLOW_SPEED | 0.33 | Constants |
| Change-in-p visible/fade | 0.5 / 0.5 s | QueryParameters |
| Grid minor | 0.1 m | Constants |

### 2.5 高风险区（Phase 1 必深挖）

1. `CollisionEngine.handleBallToBallCollision` — 法向公式 + 负 dt 的 `1/e`
2. `InelasticCollisionEngine` + `RotatingBallCluster` — 角动量 → ω → 均匀圆周
3. `Explore1DCollisionEngine` — e=0 分组共速 / 贴墙停
4. Intro 无 border；球可离开 play area（Return Balls）
5. Reverse step 条件与物理可逆语义
6. Constant Radius + tint（密度着色）
7. MomentaDiagram 1D 堆叠 vs 2D tip-to-tail
8. Keypad / More Data / BallValuesPanel

### 2.6 参考截图（非运行基线）

`assets/collision-lab-screenshot-screen{1..4}.png` 等 8 张 PNG 可作为 Phase 2 布局锚点参考。  
**[待确认：缺少本机原版运行截图]** —— 不以伪造运行截图冒充；用本地 assets + 源码 layout 常量推进。

---

## 3. Migration 落点决策（无阻塞）

| 决策 | 选择 | 理由 |
|---|---|---|
| 目录 | `lib/collision_lab/` | 与现有顶层 sim 一致 |
| Home | 物理 → 力学 | 动量/碰撞属力学 |
| Tab | `KratosTabbedScreen` 四 Tab | 对齐四 Screen |
| Clock | sim 内 Ticker | 不改 common SimulationClock |
| CollisionEngine | sim 内 pure-ish stateful solver | 对齐源码：保存 Collision 池、可 invalidate |
| common 抽取 | **不做**跨 sim physics engine | 第 1 用户；禁止为统一目录造 abstraction |
| 修改其他 sim | **禁止** | 用户硬性规则 |

**无**「修改 common API / 全局 Theme / Navigation / 跨 sim physics framework」类阻塞项 → **自动进入 Phase 1**。

---

## 4. Phase 0 产出清单

| 文件 | 状态 |
|---|---|
| `requirements/req-collision-lab/meta.yaml` | ✅ |
| `requirements/req-collision-lab/process.txt` | ✅ |
| `requirements/req-collision-lab/PROJECT_DISCOVERY.md` | ✅（本文件） |

下一阶段：`SOURCE_ANALYSIS.md`（证据矩阵 + 公式摘录）。
