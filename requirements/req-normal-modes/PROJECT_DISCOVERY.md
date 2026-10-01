# Phase 0 — Project Discovery · Normal Modes

> 需求：`req-normal-modes`  
> 日期：2026-09-03  
> 阶段：Phase 0 完成 · 无阻塞决策 · 自动进入 Phase 1  
> 标记：`[已确认]` 有源码/配置/目录依据 · `[推测]` 有依据的推断 · `[待确认]` 证据不足

---

## 0. 结论摘要

1. **KARTOSLAB** 是独立 Flutter App（包名 `kratos`，SDK `^3.11.1`），入口 `lib/main.dart` → `HomeScreen`，无 GoRouter。[已确认]
2. Home **无** Normal Modes 入口。光学与波动组已有几何光学 / 色觉 / 波的干涉 / 声波 / 电磁波。[已确认 `lib/screens/home_screen.dart`]
3. 原版是 PhET HTML5 **`normal-modes` 1.1.0-dev.0**（README 写明尚未正式发布），不是 Java。[已确认 `package.json` + `README.md`]
4. **两个 joist Screen**：`OneDimensionScreen`、`TwoDimensionsScreen`。各自 `() => new Model()`，**不共享 Model**。[已确认 `normal-modes-main.js:31-34` + 两个 `*Screen.js`]
5. 数学模型在本地源码中**完整可确认**：解析叠加 `setExactPositions` + 拖拽时 Velocity Verlet。**不需要**用教科书公式补模型，不停自动推进。[已确认 `OneDimensionModel.js` / `TwoDimensionsModel.js`]
6. 推荐落点：`lib/normal_modes/`（与 `cck_ac_virtual_lab/`、`density/` 同级顶层目录）。**不**使用 `lib/src/simulations/`（工程无此约定）。
7. 无 PNG/SVG 业务资源：质量、墙、弹簧、图标全是 scenery 矢量。[已确认 glob `js/` 无 images 目录]
8. 当前工程 **无** Normal Modes 旧实现。Phase 12 无归档对象。

---

## 1. 当前 KARTOSLAB 工程

### 1.1 根与入口

| 项 | 值 | 证据 |
|---|---|---|
| 工作区 | `KartosLab/`（包名 `kratos`） | `pubspec.yaml:1` |
| SDK | `^3.11.1` | `pubspec.yaml:22` |
| 入口 | `lib/main.dart` → 横屏锁定 → `KratosApp` → `HomeScreen` | `lib/main.dart` |
| 路由 | `Navigator.push(MaterialPageRoute)` | `home_screen.dart` |
| 依赖 | `flutter_svg ^2.3.0` · `audioplayers ^6.7.1` | `pubspec.yaml` |
| AGENTS.md 路径 | 写 `c:\workspace\kratos`，与本工作区不一致 | 以本仓库为准 [已确认] |

### 1.2 `lib/` 学科目录

已有：`common/` `circuit/` `forces/` `optics/` `color_vision/` `sound/` `radio_waves/` `wave_interference/` `magnetism/magnet_and_compass/` `astronomy/keplers_laws/` `astronomy/my_solar_system/` `density/` `chemistry/molarity/` `chemistry/build_a_nucleus/` `cck_ac_virtual_lab/`

**无** `normal_modes*`。[已确认 glob]

### 1.3 Home 注册

`HomeScreen._disciplines`：物理（力学 / 密度与浮力 / 电学与电路 / 电磁学 / 天体力学 / 光学与波动）+ 化学。

本 sim 归入 **物理 → 光学与波动** 新卡「Normal Modes」（耦合振子 / 简正模），不替换声波或波的干涉。

双屏导航：一张 Home 卡 + `KratosTabbedScreen`（Kepler / Density / BAN 先例）。**不**改 Navigation 架构。

### 1.4 common（L0）与本 sim 相关度

| L0 | 路径 | 本 sim | 判定 |
|---|---|---|---|
| NineGridLayout | `common/widgets/nine_grid_layout.dart` | 页面级外壳 | **复用**。中间格放整个 PhET ScreenView（局部 1024×618）。边格留空——侧格宽度约 8% 放不下原版右栏面板 |
| KratosTabbedScreen | `common/widgets/kratos_tab_bar.dart` | 双 Screen | **复用** |
| SimulationClock | `common/simulation_clock.dart` | 心跳 | **不套**。它按 vsync 固定 `1/60` 且忽略墙钟 dt；原版 `step(dt)` 用墙钟 dt 累积再 `FIXED_DT`。不改 common，本 sim 用 Ticker 传墙钟 dt（同 CCK） |
| TimeControlBar | `common/widgets/time_control_bar.dart` | Play/Pause/Step + 倍速 | **不套**。原版是 `TimeControlNode`（蓝 Play + Normal/Slow，无秒表、无 restart） |
| KratosSlider | `common/controls/kratos_slider.dart` | 质量数 / 振幅 / 相位 | **不套外观**。原版 NumberControl + VSlider 尺寸（3×100 / 26×15）不同 |
| KratosRadioGroup | `common/controls/kratos_radio_group.dart` | 轴向 | **不套**。原版是带双箭头图标的 RectangularRadioButtonGroup |
| PropertyControlPanel / ScenarioManager / Chart | | | **不用**（无 scenario、无 SnapshotChart） |

G3：质量-弹簧、模态分解、Spectrum accordion、2D 振幅格均为 **第 1 个 Normal Modes 用户**，留在 sim 内。

### 1.5 已有 sim 架构范式（选最近邻）

| 范式 | 代表 | 数据流 |
|---|---|---|
| 可变 Model + 墙钟 Ticker | CCK AC | tick 改可变图 |
| ChangeNotifier Controller | Kepler / Density | 命令进 Controller |
| 不可变 State + Solver | 既有 circuit / optics | copyWith |

最近邻：**可变 Model（质量位移/模态振幅）+ 定步长解析/Verlet + Controller + RenderData**。  
Kepler 提供双/多 Screen Tab 先例。  
**禁止**把声波的场方程或波干涉 heatmap 抄进来。

推荐：

```
OneDimensionModel / TwoDimensionsModel（SSOT，可变，对齐 PhET）
  + solver 纯函数（频率 / 精确叠加 / Verlet / 模态分解）——供单测，Model 调用
  + Controller（Ticker / drag / reset / notify）
  + Render DTO + 分元件 Painter
```

NineGrid：页面外壳。质量、弹簧、墙、Spectrum、控制面板 **全部留在 center 的局部坐标**（对齐 PhET 单个 ScreenView），不拆进 8% 宽边格。

### 1.6 tests / assets / schemas

- `test/`：无 normal-modes。
- `assets/`：无需新 PNG；矢量自绘。
- `schemas/`：**不做假 scenario schema** [有意差异，同 Kepler / CCK]。
- `requirements/`：本需求 `req-normal-modes/`。

### 1.7 知识库对照

- `docs/knowledge/kratos-java-simulations/overview.md`：Java 蓝本总览。本任务蓝本是 **HTML5 normal-modes**，Java 不作为源码优先级。
- checklist 配置化 JSON：与原版无场景冲突 → **[有意差异] 不做假 scenario**。

---

## 2. 原版 PhET 调查

### 2.1 身份

| 项 | 值 |
|---|---|
| 官网 | https://phet.colorado.edu/sims/html/normal-modes/latest/normal-modes_all.html |
| 本地 | `phet sourses/normal-modes-main/normal-modes-main` |
| name / version | `normal-modes` / `1.1.0-dev.0` [已确认 `package.json`] |
| 入口 | `js/normal-modes-main.js` |
| 文档 | `doc/model.md` · `doc/implementation-notes.md` |
| 字符串 | `normal-modes-strings_en.json` |
| 依赖快照 | `dependencies.json`（2021-11-01 注释写 1.0.0-dev.5；以本地树为准，不替换） |

### 2.2 Screen 数量与导航 [已确认]

```javascript
new Sim( title, [
  new OneDimensionScreen( tandem.oneDimensionScreen ),
  new TwoDimensionsScreen( tandem.twoDimensionsScreen )
], simOptions );
```

| # | Screen | 名称字符串 | Model | View |
|---|---|---|---|---|
| 0 | One Dimension | `screen.oneDimension` = "One Dimension" | `OneDimensionModel` | `OneDimensionScreenView` |
| 1 | Two Dimensions | `screen.twoDimensions` = "Two Dimensions" | `TwoDimensionsModel` | `TwoDimensionsScreenView` |

- joist 默认选中 index 0。
- 每个 Screen 工厂 `() => new XxxModel()`：**切换 Screen 不销毁已创建 Model**；仅活动 Screen 被 `step`。[已确认 joist 惯例 + 各自独立 constructor]
- **无共享全局状态**（无单例 store）。`arrowsVisible` 等均在各 Model 实例上。
- Flutter 对应：Home 持有两个 Controller，只 tick 当前 Tab；离开 sim 再进则重新创建。

### 2.3 默认状态 [已确认 `NormalModesModel` + 子类]

| 属性 | 默认 |
|---|---|
| numberOfMasses | 3（2D 为每行 3，显示 9） |
| playing | **true** |
| timeSpeed | NORMAL（×1） |
| time | 0 |
| springsVisible | true |
| arrowsVisible | true |
| amplitudeDirection | VERTICAL |
| phasesVisible（仅 1D） | false |
| 各 mode 振幅 | 0 |
| 各 mode 相位 | 0 |
| 质量位移 | 0（静止在平衡位置） |

因此默认画面是**静止的**质量排（振幅全 0），尽管时钟在走。

### 2.4 资源

无位图。颜色见 `NormalModesColors.js`。弹簧色 `PhetColorScheme.RED_COLORBLIND` = `#FF5500`（工程 BAN 审计已确认）。

### 2.5 Clock / 动画 [已确认]

| 项 | 值 |
|---|---|
| FIXED_DT | 1/60 |
| 墙钟 dt 上限 | min(dt, 0.15) |
| 累积 | `this.dt += dt; while (dt>=FIXED_DT) singleStep(FIXED_DT)` |
| 倍速 | NORMAL=1 · SLOW=0.2，乘在 **singleStep 内部** |
| 非拖拽 | `setExactPositions()` 解析叠加 |
| 拖拽中 | Velocity Verlet |
| 暂停且未拖拽 | 每帧仍 `setExactPositions()`（滑条改振幅立即生效） |
| Step | `singleStep(FIXED_DT)` |

**不是** AnimationController + Tween。必须 Clock → Model.update → Render。

### 2.6 与既有 sim 的边界

不修改 sound / wave_interference / 任何其他 sim。Normal Modes 的「弹簧」是 **直线 Path lineWidth=5**，不是线圈。

---

## 3. 开工自检（80-kratos-sim-checklist）摘录

- MVC：`lib/normal_modes/model|solver|controller|render|painters|widgets|screens`
- 元件：Mass / Spring / Wall / ModeGraph / AmplitudeSelector —— 分 Painter
- G1：NineGrid + Tab；其余 L0 因语义/外观不等价不套
- G2/G3：新控件留 sim 内，第 1/3 用户
- 配置化：无 scenario → 有意差异
- L0-4：NineGrid 外壳，center ≥70% 放 ScreenView

---

## 4. Phase 0 状态

| 项 | 状态 |
|---|---|
| 核心数学模型 | [源码一致] 可实现，不暂停 |
| State ownership | [已确认] 每屏独立 Model |
| 改 common / Theme / Nav / 其他 sim | 不需要 |
| 原版运行截图 | [待确认] 本阶段无浏览器实拍（见 Phase 2） |

**无重大架构决策。自动进入 Phase 1。**
