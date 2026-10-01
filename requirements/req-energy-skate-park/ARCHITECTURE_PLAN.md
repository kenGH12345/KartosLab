# Phase 3 — Architecture Plan · Energy Skate Park

> 需求：`req-energy-skate-park`  
> 日期：2026-09-03  
> 依据：`PROJECT_DISCOVERY.md` + `SOURCE_ANALYSIS.md`  
> **无阻塞决策**（不改 common API / Theme / Navigation / 跨 sim 物理框架）

---

## 0. 结论

按 **Energy Skate Park 自身模型** 设计，不机械复制 Collision Lab / Normal Modes / Fourier。

核心数据流：

```
Input (drag / slider / play)
  → Controller
  → Screen Model (Intro/Measure/Graphs/Playground)
  → PhysicsSolver.step* (Euler / freeFall / ground / leaveTrack)
  → Skater 写回 + DataSamples
  → RenderData / EspMvt
  → Painters / Widgets
```

Painter **不**算物理/能量。Widget **不**保存 velocity。

---

## 1. 包结构

```
lib/energy_skate_park/
  esp_constants.dart
  esp_colors.dart
  esp_strings.dart
  model/
    esp_vec.dart
    control_point.dart
    track.dart
    skater.dart
    skater_state.dart
    data_sample.dart
    premade_tracks.dart
    esp_model.dart              # EnergySkateParkModel 语义
    save_sample_model.dart
    track_set_model.dart
    full_track_set_model.dart
    intro_model.dart
    measure_model.dart
    graphs_model.dart
    playground_model.dart
    preferences.dart
  solver/
    hermite_spline.dart         # numeric.spline 同语义
    spline_evaluation.dart      # SplineEvaluation.atNumber
    physics_solver.dart         # stepEuler / stepTrack / freeFall / ground
  controller/
    esp_controller.dart         # 基类 · clock · 命令
    intro_controller.dart
    measure_controller.dart
    graphs_controller.dart
    playground_controller.dart
    view_properties.dart
  render/
    esp_mvt.dart
    esp_render_data.dart
    esp_render_builder.dart
  painters/
    track_painter.dart
    skater_painter.dart
    energy_bar_painter.dart
    pie_chart_painter.dart
    graph_painter.dart
    grid_painter.dart
    background_painter.dart
  widgets/
    esp_page_shell.dart
    esp_layout.dart
    play_area.dart
    control_panel.dart
    time_control.dart
    toolbox_panel.dart
    energy_sensor.dart
    measuring_tape.dart
    stopwatch_widget.dart
    reference_height_line.dart
    track_scene_selector.dart
  screens/
    energy_skate_park_home.dart
    intro_screen.dart
    measure_screen.dart
    graphs_screen.dart
    playground_screen.dart

test/energy_skate_park/
  hermite_spline_test.dart
  physics_euler_test.dart
  energy_conservation_test.dart
  leave_track_test.dart
  premade_tracks_test.dart
  …
```

---

## 2. 模块职责

| 模块 | 职责 | 不做 |
|---|---|---|
| `HermiteSpline` | numeric.spline 构造 + diff | UI |
| `SplineEvaluation` | atNumber/atArray | 物理 |
| `Track` | 控制点 · getX/Y · 切线/法线 · 曲率 · 弧长参数映射 | 步进 |
| `SkaterState` | 不可变步进快照 · KE/PE/TE | 可变 UI 状态 |
| `Skater` | 可观察权威态 · 写回 | 积分 |
| `PhysicsSolver` | step / stepEuler / stepTrack / freeFall / ground / correctEnergy | 绘制 |
| `EspModel` | tracks · friction · stick · reset · join/split | 布局像素 |
| `SaveSampleModel` | dataSamples 历史 | Sensor 自算能量 |
| `EspMvt` | 米↔逻辑像素（y 翻转） | 物理 |
| `RenderData` | 纯几何/颜色快照 | 可变 Model 引用写回 |
| `Controller` | Ticker · 用户命令 | 私藏速度 |

---

## 3. 四屏 Model ownership

| Tab | Model | 说明 |
|---|---|---|
| Intro | `IntroModel` | FullTrackSet；默认不存 path；Bar+Pie |
| Measure | `MeasureModel` | FullTrackSet；configurable；Sensor；无 Bar |
| Graphs | `GraphsModel` | PARABOLA+DOUBLE_WELL；采样 0.01s；图 |
| Playground | `PlaygroundModel` | 无 SaveSample；toolbox 全交互 |

各 Controller 独立；切换 Tab 不共享 Skater。Preferences 可单例。

---

## 4. 时钟

```
Ticker(wallDt)
  → if !paused: eventTimer accum → constantStep(1/60)
  → slow: only when modelIterations % 3 == 0
  → manualStep: 单次 1/60
```

**不**用 AnimationController 直接移动 skater。  
**不**修改 `lib/common/simulation_clock.dart`。

---

## 5. 坐标系

- 模型：米，原点 = 地面水平中心，+y 向上
- 视图：`EspMvt` scale ≈ 61.40（对照源码；可用布局自适应微调但保持物理比例）
- NineGrid：仅页面外壳；PlayArea 内为局部坐标

---

## 6. L0 复用决策

| 复用 | 不复用 / 不抽 |
|---|---|
| `KratosTabbedScreen` | SimulationClock 语义（自建） |
| `NineGridLayout` | TimeControlBar 外观 |
| （可选）chart 折线参考 | Track/Spline/Physics 全部 sim 内 |

---

## 7. Home

`物理 → 力学 → Energy Skate Park`  
不改全局导航架构。

---

## 8. 暂停条件检查

| 条件 | 结果 |
|---|---|
| 修改 common API | **否** |
| 跨 sim 物理框架 | **否** |
| 改 Theme / Navigation | **否** |
| Model ownership 不明 | **否**（四屏独立已确认） |
| 核心轨道/物理算法不明 | **否**（Phase 1 已取证） |

→ **不暂停 · 自动进入 Phase 4**
