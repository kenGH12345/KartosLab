# ARCHITECTURE_PLAN — Gases Intro

## 原则

- 包根：`lib/gases_intro/`（sim-local）
- **不**创建跨 simulation Gas framework
- **不**复制 `lib/diffusion` Ideal 无关逻辑；CollisionDetector 可对照同源 GP 算法重写
- **不**迁 Explore/Energy/Diffusion 屏
- NineGrid 只做页面级；物理坐标 pm，View 用 MVT

## 双屏

| Screen | Widget | Model | Hold Constant UI |
|---|---|---|---|
| Intro | `IntroScreenPage` | `IdealGasLawModel` | 隐藏 |
| Laws | `LawsScreenPage` | 独立 `IdealGasLawModel` | 显示 |
| Shell | `GasesIntroHome` Tab/Segment | — | — |

`pressureNoiseEnabled` 默认 **false**。

## 分层

```
IdealGasLawModel
  ├─ ContainerModel (IdealGasLawContainer)
  ├─ ParticleSystem (Heavy/Light Particle)
  ├─ TemperatureSolver
  ├─ PressureSolver + PressureGaugeDisplay
  ├─ CollisionSolver
  ├─ HoldConstantController
  ├─ ClockController (play/pause/step；无 Slow UI)
  └─ Statistics (N, ⟨T⟩, P, V, collisions)
        ↓
  RenderData (只读快照)
        ↓
  GasPainter / InstrumentPainters
        ↓
  Widgets (pump, heater, handle, panels) → Controller → Model
```

Painter **不**计算 P/T；Widget **不**保存第二套物理状态。

## 目录

```
lib/gases_intro/
  gases_intro_constants.dart
  model/
    particle.dart
    particle_system.dart
    container_model.dart
    collision_solver.dart
    temperature_solver.dart
    pressure_solver.dart
    hold_constant.dart
    time_transform.dart
    ideal_gas_law_model.dart
    random_source.dart
  render/
    render_data.dart
  painters/
    play_area_painter.dart
    gauge_painter.dart
    thermometer_painter.dart
  widgets/
    gases_intro_shell.dart
    control_panel.dart
    particles_panel.dart
    bicycle_pump.dart
    heater_cooler.dart
    time_controls.dart
  screens/
    gases_intro_home.dart
```

## Home 集成

物理 → 热学与气体 → Gases Intro（与 Diffusion 并列）。

## 暂停条件对照

| 条件 | 本方案 |
|---|---|
| 改 common API | 否 |
| 跨 sim Gas framework | 否 |
| P/T/V/Pump 未确认 | 已确认 |
| 无活塞 | 已确认用左墙 |
