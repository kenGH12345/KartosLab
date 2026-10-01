# Phase 3 — Architecture Plan · Collision Lab

> 日期：2026-09-03  
> 原则：不机械复制 CCK / Normal Modes / Fourier；按 Collision Lab 源码结构落地

---

## 0. 决策摘要（无阻塞）

| 决策 | 选择 | 是否暂停 |
|---|---|---|
| 目录 | `lib/collision_lab/` | 否 |
| CollisionEngine | **stateful solver**（持有 Collision 列表，对齐源码） | 否 |
| 跨 sim physics framework | **不做** | 否 |
| common API / Theme / Nav | **不改** | 否 |
| Reverse step | 负 dt + `e←1/e`（非 history） | 否 |
| Home | 物理 → 力学 → Collision Lab + 4 Tab | 否 |

**无不可逆架构阻塞 → 自动进入 Phase 4。**

---

## 1. 数据流

```
PhysicsTicker (墙钟 dt)
  → ScreenModel.step(dt)           // CollisionLabModel 语义
      → elapsed += dt*speed
      → CollisionEngine.step(dt, prevElapsed)
           → detect → earliest → progressBalls → handle → loop
  → notifyListeners
Controller (ChangeNotifier)
  → drag / sliders / keypad / checkboxes / reset / restart / step
RenderBuilder
  → ClRenderData（纯结构）
Painters / Widgets
  → 只读 RenderData + 手势回调回 Controller
```

**禁止**：Painter 算碰撞；Widget 存 velocity；Graph 重算 KE（KE 来自 Model/BallUtils）。

---

## 2. 模块划分

```
lib/collision_lab/
  collision_lab_constants.dart
  collision_lab_colors.dart
  collision_lab_strings.dart
  model/
    cl_vec.dart                 # 2D 向量（米制）
    ball_state.dart
    ball.dart
    play_area.dart              # + Intro/Explore1D/2D/Inelastic 配置
    ball_system.dart
    center_of_mass.dart
    collision.dart
    momenta_diagram.dart
    collision_lab_model.dart    # 基类时间/reset/restart
    intro_model.dart
    explore1d_model.dart
    explore2d_model.dart
    inelastic_model.dart
    rotating_ball_cluster.dart
    inelastic_preset.dart
  solver/
    ball_utils.dart
    collision_lab_utils.dart
    collision_engine.dart
    intro_collision_engine.dart
    explore1d_collision_engine.dart
    inelastic_collision_engine.dart
  controller/
    intro_controller.dart
    explore1d_controller.dart
    explore2d_controller.dart
    inelastic_controller.dart
  render/
    cl_mvt.dart                  # scale=152, inverted Y
    cl_render_data.dart
    cl_render_builder.dart
  painters/
    play_area_painter.dart
    ball_painter.dart
    vector_painter.dart
    momenta_diagram_painter.dart
  widgets/
    cl_page_shell.dart           # NineGrid + 局部 1024×618 风格布局
    cl_layout.dart               # SimulationViewport / ControlColumn / BottomPanel
    play_area_widget.dart
    control_panel.dart
    ball_values_panel.dart
    momenta_diagram_panel.dart
    time_control.dart
    keypad_dialog.dart
  screens/
    collision_lab_home.dart
    intro_screen.dart
    explore1d_screen.dart
    explore2d_screen.dart
    inelastic_screen.dart
```

---

## 3. CollisionEngine 形态

对齐源码：

- **Stateful**：`List<Collision>` 缓存；状态变更 `invalidate` / `reset`
- 对外主入口：`step(dt, elapsedTime)`
- 子类 override：`handleBallToBallCollision` / `handleBallToBorderCollision` / `progressBalls` / `detectAllCollisions`
- 纯函数部分抽到 `ball_utils` / `collision_lab_utils` 便于单测（半径、二次根、KE、snap）

**不是**全局单例 physics framework。

---

## 4. 布局模型（禁止 magic Stack 抢空间）

页面级：`KratosTabbedScreen` + `NineGridLayout` 中格。

模拟内部 `ClLayout`（局部坐标，对齐 PhET ScreenView）：

```
┌─────────────────────────────────────────────┬──────────┐
│  KE / Scale / PlayArea / Balls / Return     │ Control  │
│                                             │ Panel    │
│                                             │ (218)    │
├─────────────────────────────────────────────┤          │
│  BallValuesPanel + MoreData                 │ Momenta  │
│  TimeControl + Restart + Reset              │ Diagram  │
└─────────────────────────────────────────────┴──────────┘
```

- `SimulationViewport`：PlayArea + overlays（局部 MVT）
- `ControlColumn`：右栏固定内容宽
- `BottomPanel`：BallValues + time row
- **不**复制 Normal Modes Spectrum 底栏

---

## 5. Screen 特化策略

| Screen | Model 特化 | Engine | UI 特化 |
|---|---|---|---|
| Intro | 1D · 无 border · Δp | IntroCollisionEngine | Change in Momentum · 无 Balls picker · 无 Reflecting |
| Explore1D | 1D · border | Explore1DCollisionEngine | Balls 1–5 |
| Explore2D | 2D · e≥5% | CollisionEngine | Paths · Grid checkbox |
| Inelastic | 2D · e=0 · Stick/Slip | InelasticCollisionEngine | Presets · StickSlip · 无弹性滑条 |

四 Controller 独立生命周期；Tab 切换不共享状态（对齐 joist 各 Screen 自有 Model）。

---

## 6. 测试金字塔

1. **Unit**：`calculateBallRadius`、球-球公式、球-边、1D e=0 分组、stick ω、cluster step、KE、COM、snap、负 dt `1/e`
2. **Model**：reset vs restart、step/pause、ball count、presets
3. **Widget smoke**：四屏 mount（轻量）
4. **守恒**：球-球动量；e=100% 动能；球-边动量**不**要求守恒

---

## 7. Phase 3 状态

架构确认完毕 · **无 BLOCKED** → Phase 4 实现 Model/State/Solver。
