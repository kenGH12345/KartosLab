# Phase 3 — Architecture Plan · Normal Modes

> 日期：2026-09-03  
> 依据：`PROJECT_DISCOVERY.md` + `SOURCE_ANALYSIS.md` + `visual-qa/BASELINE.md`  
> **无不可逆决策**（不改 common API / Theme / Nav / 其他 sim / 不建跨 sim framework）  
> 自动进入 Phase 4

---

## 1. 目标目录

```
lib/normal_modes/
  normal_modes_constants.dart
  normal_modes_colors.dart
  normal_modes_strings.dart
  model/
    nm_vec.dart
    amplitude_direction.dart
    time_speed.dart
    mass.dart
    spring.dart
    one_dimension_model.dart      # SSOT 1D（可变，对齐 PhET）
    two_dimensions_model.dart     # SSOT 2D
  solver/
    normal_mode_math.dart         # ω(k,m,i,N) / 2D ω / maxAmplitude(N)
    one_dimension_solver.dart     # exact / verlet / decompose（纯函数+写回 mass）
    two_dimensions_solver.dart
  controller/
    one_dimension_controller.dart
    two_dimensions_controller.dart
  render/
    nm_mvt.dart                   # 1024×618 + inverted Y
    nm_render_data.dart           # 只读 DTO
    nm_render_builder.dart
  painters/
    spring_painter.dart
    mass_painter.dart
    wall_painter.dart
    border_painter.dart
    mode_graph_painter.dart
    static_mode_graph_painter.dart
  widgets/
    nm_accordion.dart             # collapse 不销毁 child
    nm_time_control.dart
    nm_control_panel.dart
    spectrum_accordion.dart
    modes_accordion.dart
    amplitudes_accordion.dart
    one_dimension_play_area.dart
    two_dimensions_play_area.dart
    nm_layout.dart                # 逻辑 1024×618 FittedBox
  screens/
    normal_modes_home.dart        # KratosTabbedScreen + 两个 Controller
    one_dimension_screen.dart     # NineGrid + ScreenView
    two_dimensions_screen.dart
```

测试：`test/normal_modes/`  
资源：无新 PNG。  
Home：物理 → 光学与波动 → 「Normal Modes」。只改 `home_screen.dart` 注册行。

---

## 2. 数据流

```
Ticker（墙钟 dt，clamp 0.15）
        │
        ▼
Controller.step(dt)          # 仅当前 Tab
        │
        ▼
Model.step → 累积 FIXED_DT → Solver.singleStep
        │                     非拖拽: exact superposition
        │                     拖拽: Verlet
        ▼
Model（位移 / A / φ / t / flags）  ← 唯一 SSOT
        │
        ▼
RenderBuilder.snapshot() → NmRenderData
        │
        ▼
Painter / Widget（禁止重算 ω 或叠加）
```

交互：Widget → Controller 命令 → Model。Painter 不改 x/y。

---

## 3. State ownership

| 状态 | 所有者 |
|---|---|
| 质量运动学、模态 A/φ/ω、N、playing、speed、方向、弹簧可见、arrows、phasesVisible、dragging index | 各屏 Model |
| accordion expanded | 各屏 Controller（View 状态，Reset 时 reset） |
| 时钟累积 dt | Model.dt |
| 1D / 2D 之间 | **不共享** |
| Flutter AnimationController | **不作为业务状态** |

Tab 切换：Home 持有两个 Controller；只 tick 可见屏（对齐 joist）。Dispose Home = 离开 sim。

---

## 4. 布局

页面：`Scaffold` AppBar（embedded 时由 `KratosTabbedScreen` 提供）+ `NineGridLayout(center: FittedBox 1024×618 ScreenView)`。

内部：PhET 锚点公式，不把面板塞进 8% 边格。

---

## 5. 测试计划（Phase 4 起）

- 默认状态 / reset / initial / zero
- N=1..10 频率与标签比
- 1D/2D exact 叠加数值
- Verlet 一步
- 分解往返（A,φ → positions → compute ≈ A,φ）
- 边界 N=1、N=10；A=0；拖拽 index
- 2D Y 符号（减号）
- 2D maxAmplitude 与 toggle
- widget：滑条、checkbox、tab、reset、collapse 后 frequency 仍在树（`skipOffstage: false`）
- animation：pause 时改 A 立即变位；play 时间推进

---

## 6. 明确不做

- 不改 `SimulationClock` / NineGrid / Theme / 其他 sim
- 不上抽 Accordion/VSlider 到 common（第 1/3）
- 不引入 scenario JSON
- 不把弹簧画成线圈
- 不「修正」2D y 减号或 interrupt 时残留 draggingIndex

**Phase 3 状态：目录与数据流已定。自动进入 Phase 4。**
