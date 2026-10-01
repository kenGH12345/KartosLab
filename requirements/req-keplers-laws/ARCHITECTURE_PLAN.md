# Phase 3 — Architecture Plan · Kepler's Laws

> 日期：2026-09-01  
> 依据：`PROJECT_DISCOVERY.md` + `SOURCE_ANALYSIS.md` + `visual-qa/BASELINE.md`  
> 无不可逆决策 · 自动进入 Phase 4

---

## 1. 目标目录

不复制 BAN 的 `chart_intro/` 树。Kepler 是 **单画布 + 四定律配置**，不是核素表。

```
lib/astronomy/keplers_laws/
  keplers_laws_constants.dart
  keplers_laws_strings.dart
  keplers_laws_colors.dart
  model/
    law_mode.dart
    orbit_types.dart
    target_orbit.dart
    body.dart
    orbital_area.dart
    elliptical_orbit_engine.dart   # 纯逻辑 Solver
    period_tracker.dart
    keplers_laws_visible.dart
    keplers_laws_state.dart        # SSOT 快照（给 Render）
  controller/
    keplers_laws_controller.dart   # tick / drag / reset / restart
  render/
    keplers_mvt.dart               # 模型↔视图，Y 向上
    orbit_render_data.dart         # 只读绘制 DTO，禁止在 Painter 重算 a/e
  painters/
    orbit_painter.dart
    bodies_painter.dart
    swept_area_painter.dart
    vectors_painter.dart
    grid_painter.dart
  widgets/
    keplers_time_control.dart      # 不改 L0 TimeControlBar API
    visibility_panel.dart
    first_law_panels.dart
    second_law_panels.dart
    third_law_panels.dart
    target_orbit_panel.dart
    orbital_warning.dart
    zoom_buttons.dart
    laws_radio_group.dart
  screens/
    keplers_laws_home.dart         # KratosTabbedScreen 四 Tab
    keplers_laws_screen.dart       # NineGrid + 中心 Canvas
```

测试：`test/astronomy/keplers_laws/`  
资源：`assets/images/keplers_laws/`、`assets/sounds/keplers_laws/`（仅复制原版存在的文件）

Home：物理 → 新组「天体力学」→ Kepler's Laws。只改 `home_screen.dart` 注册，不改其他 sim。

---

## 2. 数据流

```
用户手势 / Clock.dt
        │
        ▼
KeplersLawsController  (ChangeNotifier)
        │  改 Body / 调用 Engine.update|run / 改 visible
        ▼
EllipticalOrbitEngine  (纯计算，无 Widget)
        │
        ▼
KeplersLawsState.toRenderData(mvt) → OrbitRenderData
        │
        ▼
CustomPainters + Overlay Widgets     禁止再算 vis viva / Kepler
```

Single Source of Truth：Controller 持有 `sun/planet/engine/visible/time`。Painter 只读 DTO。

---

## 3. 层职责

| 层 | 做 | 不做 |
|---|---|---|
| Engine | 公式、invalid、面积分割 | Flutter、颜色 |
| State/Visible | 定律、checkbox、目标轨道 | 像素 |
| Controller | dt 缩放、drag 夹逼、reset/restart | 画椭圆 |
| MVT | ZERO→canvasCenter，Y 翻转，scale | 业务 |
| RenderData | 椭圆参数、扇区 path 输入、焦点 | 手势 |
| Painter | Path/Circle | 改 a/e |
| Screen | NineGrid、手势命中、面板 | 公式 |

---

## 4. 屏结构

原版四 `Screen` 四 `KeplersLawsModel`。本工程：

- `KeplersLawsHome`：Tab First / Second / Third / All Laws
- 每 Tab 一个 `KeplersLawsScreen(initialLaw:, isAllLaws:)`，**独立 Controller**（对齐原版实例隔离）
- Tab 无 KeepAlive → 切走 dispose。[有意差异，同 BAN]
- `embedded: true` 避免双 AppBar

NineGrid：

- `center`：黑底 Stack（轨道 Canvas + 警告 + 日/星手势层）
- `topLeft`：定律专用面板
- `topRight`：zoom + 可见性（窄时允许滚动）
- `footer`：TimeControl（Restart/Play/Step + Fast/Normal/Slow）
- Reset：中心格右下 Positioned，**不进** NineGrid 边格（与磁铁 FieldMeter 同理）

模拟对象 **不** 拆进九宫格格子。

---

## 5. 复用 / 不抽 common

**复用：** NineGridLayout、KratosTabbedScreen、SimulationClock（心跳）、KratosSlider/ComboBox/RadioGroup 语义。

**不抽 / 不套：**

- 不改 `TimeControlBar`（缺 Restart≠Reset、缺三档速度）
- 不把 Engine/Body 抽到 `lib/common`（第 1 个天体用户）
- 不用 `GraphSuite` 画 T vs a（幂次按钮语义不同）
- 不做 scenario JSON

---

## 6. 有意差异（开工即锁定）

| 项 | 原版 | 本工程 |
|---|---|---|
| 导航 | joist 四 Screen + 底栏 | AppBar + Tab |
| 多语言 / PDOM / PhET-iO | 有 | 不做 |
| Projector 色表 | 有 | 只 default 黑底 |
| 键盘拖 | 有 | 指针拖优先；键盘 [待确认] 一期可不做 |
| 天体循环音 / 离心率 loop | 有 | 一期做碰撞/逃逸/Success；其余若缺资源则记录 |
| Tab KeepAlive | joist 常驻 | dispose |

---

## 7. 测试计划（按阶段）

- Phase 4：`engine_test`（a/e/T/trueAnomaly/crash/escape/circular）、`state_reset_test`
- Phase 5：widget 静态 pump（太阳在中心格、面板存在）
- Phase 6：拖拽夹逼、Always Circular、播放门闩
- Phase 7：zoom 0.5s、period fade 3s
- Phase 10：analyze + 专项 + 回归；debug APK
- Phase 11：Home 进出

---

## 8. 决策

无需要用户拍板的不可逆项。目录、独立 Controller、不抽 common 均有先例。
