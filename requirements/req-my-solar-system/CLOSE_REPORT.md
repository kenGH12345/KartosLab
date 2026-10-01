# My Solar System · Close Report

> Phase 3 · Close · 2026-09-02  
> 前置：Loop 6 验收通过 · 135 module tests · analyze 0 issues

## Status

**done** · `phase: 3.close` · `status: done`

无阻塞级问题。所有 `[TEMPORARY]` / `[BLOCKED]` 已显式记录，未声称为与原版完全一致。

---

## Code Review

### 架构 ✓

```
MySolarSystemController (State + orchestration)
        ↓
NumericalEngine (Solver — 纯 Dart，无 Flutter import)
        ↓
MssRenderData / BodyRenderDot (RenderData DTO)
        ↓
Painters (CustomPainter — 只读 data)
```

- **Painters 不修改 State**：`lib/astronomy/my_solar_system/painters/` 无 `numerical_engine` / `updateForces` / `stepOnce` 引用（Loop 6 审计 + grep 复验）。
- **UI 不直接算物理**：Screen 通过 `_renderData()` 从 controller 读快照；PEFRL 仅在 `NumericalEngine.run`。
- **Solver 不依赖 Flutter UI**：`solver/numerical_engine.dart` 仅 import `dart:math` + model + constants。
- **Controller 职责**：~660 行，含 preset 状态机、drag、visibility、stepOnce 编排。职责偏多但符合 kratos sim 惯例；**非阻塞**，未来可拆 drag/preset mixin。

### L0 / L1 复用 ✓

| 组件 | L0 候选 | MSS 决策 |
|---|---|---|
| SimulationClock | `lib/common/simulation_clock.dart` | **复用** — Screen tick |
| ArrowPainter | `lib/common/controls/arrow_painter.dart` | **复用** — velocity/gravity painters |
| ScenarioManager | `lib/common/scenario/scenario_manager_base.dart` | **复用** — `MssScenarioManager` |
| ComboBox | `lib/common/controls/kratos_combo_box.dart` | **复用** — preset 下拉 |
| NineGridLayout | `lib/common/widgets/nine_grid_layout.dart` | **复用** — Screen 布局 |
| TimeControlBar | `lib/common/widgets/time_control_bar.dart` | **不复用** — 缺 Restart≠Reset、三档速度、Clear；`mss_time_controls.dart` 有意定制 |
| MVT | 无通用 L0 | **自定义 `MssMvt`** — Y-up 单点 scale；`centerOrbitOffset` 父类公式缺失 |
| NumberField / Slider | 无匹配 L0 | **Material + constants** — ValuesPanel 绑定 controller |
| Grid / Tape / CoM | sim 专用 | **MSS Painters/Widgets** — common 在 solar-system-common `[BLOCKED]` |

不为形式主义强行重构。

### Magic Number ✓

用户指定字面量均收口至 `my_solar_system_constants.dart` 并带来源标签：

| 值 | 常量 | 标签 |
|---|---|---|
| 0.05 | `engineTimeScale`, `preventCollisionNudgeAu` | MSS-SOURCE / TEMPORARY |
| 4000 | `pefrlIterationBudget` | MSS-SOURCE |
| 1.055 | `velocityMinMagnitude` | KEPLER-SECONDARY |
| -3 | `initialVectorOffscale` | KEPLER-SECONDARY |
| 50 | `offscreenRadiusAu`, `velocityToView` 分子 | TEMPORARY / KEPLER-SECONDARY |
| 800 | `maxPathPoints` | TEMPORARY |
| 300 | `massUiMax` | TEMPORARY |
| 0.1 | `massUiMin`, `massSliderStep` | MSS-SOURCE / TEMPORARY |
| 3.2 | `gravityOffscaleLogThreshold` | KEPLER-SECONDARY |
| -1.1 | `fourStarBalletGravityScalePower` | MSS-SOURCE |

业务代码（controller/painter/solver）无未归档散落字面量。

### Source Traceability ✓

`PARAMETER_AUDIT.md` + `LOOP6_PHYSICS_AUDIT.md` + `temporary_implementations.dart` 与代码标签一致。  
无冲突需修正。

---

## Architecture

- **Preset**：JSON manifest + `MssScenario` + `loadScenario()` 驱动，无 `if (preset == n)` 硬编码分支。
- **Render 管线**：Physics once → `_renderData()` once → 6 Painters 消费 `MssRenderData`。
- **Reset 语义**：Clear / Return Bodies(=restart) / Reset All / preset 切换 已区分并测试。
- **未引入** Kepler `EllipticalOrbitEngine`（仅 G 常量注释引用）。

---

## Physics

PEFRL 与 `NumericalEngine.ts` 源码级一致（Loop 6）：

- XI / LAMBDA / CHI / `engineTimeScale=0.05` / `4000/N` iterations
- 每 k 子步 force/acceleration **只算一次**，五步复用
- collision：小体失活 + 动量并入，不合并质量
- G = 4.45669 `[KEPLER-SECONDARY]`（见 `G-SOURCE-OF-TRUTH.md`）

Sun+Planet golden regression 锁定 Dart 端口行为（非「物理理论正确」证明）。

---

## Tests

```
flutter analyze lib/astronomy/my_solar_system test/astronomy/my_solar_system
→ No issues found!

flutter test test/astronomy/my_solar_system
→ 135 passed
```

| 套件 | 覆盖 |
|---|---|
| `engine_test.dart` | PEFRL、G、collision |
| `numerical_regression_test.dart` | PEFRL 常数、Sun+Planet golden、gravity/velocity vector |
| `loop6_physics_audit_test.dart` | 8 preset 长跑、碰撞、path cap、Stopwatch、管线、offscreen、drag、reset |
| `loop4_lab_state_test.dart` | preset 状态机、Reset 语义 |
| `loop5_state_regression_test.dart` | Flow A–E、响应式 |
| `screen_test.dart` | widget + overflow + 截图 capture |
| `mvt_and_drag_test.dart` | MVT、drag 约束 |

测试验证**模拟器行为**（position/velocity/time/reset/preset/vector），非仅实现细节。

---

## Visual

- **Overflow 回归**：375 / 1024 / 1920 × intro/lab — `screen_test.dart` 无 layout overflow。
- **截图索引**（测试运行时写入 `requirements/req-my-solar-system/screenshots/`）：
  - Loop 3：`loop3-intro-*.png`, `loop3-lab-*.png`
  - Loop 4：`loop4-lab-1024x768.png`
  - Loop 5：`loop5-intro-default-*.png`, `loop5-lab-*.png`, `loop5-intro-moredata-1024x768.png`
- Canvas / TimePanel / More Data / Lab controls：Loop 5 截图 + overflow 测试覆盖。

---

## Known Differences

**不得声称为与原版完全一致。**

| 项 | 分类 | 说明 |
|---|---|---|
| `centerOrbitOffset (100,100)` | BLOCKED | MSS 传入父类；Flutter `MssMvt` 显式忽略 |
| `MAX_PATH_DISTANCE` | TEMPORARY | Flutter 用 `maxPathPoints=800` 点数 cap |
| `constrainDragPoint` | TEMPORARY | AABB 夹取，非 closest-point |
| `isOffscreen` | TEMPORARY | \|r\|>50；仅 UI Return Bodies；**仍参与 physics** |
| `preventCollision` | TEMPORARY | overlap +x nudge |
| VectorNode offscale 几何 | INFERRED/BLOCKED | 指示器尺寸近似；predicate 来自 Kepler 二次证据 |
| overlay 窄屏 breakpoint | INFERRED | 600px 响应式，非 MSS 一手 |
| `solar-system-common` 全文 | BLOCKED | 本机缺失，未在 Close 阶段猜测补齐 |

---

## TEMPORARY

见 `lib/astronomy/my_solar_system/config/temporary_implementations.dart` + `PARAMETER_AUDIT.md` §TEMPORARY。

---

## BLOCKED

- `solar-system-common` 本地树缺失（`meta.yaml` · `solar_system_common.status: BLOCKED`）
- 父类 MVT `centerOrbitOffset` 映射
- `MAX_PATH_DISTANCE` / `MASS_SLIDER_STEP` / closest-point drag / VectorNode 精确几何

---

## Knowledge Updated

- `docs/knowledge/kratos-java-simulations/edd/my-solar-system-migration.md` — 新建
- `docs/knowledge/kratos-java-simulations/existing-flutter-map.md` — 追加 astronomy/MSS 节
- `docs/knowledge/kratos-java-simulations/INDEX.md` — 索引更新

---

## Final Files

| 路径 | 用途 |
|---|---|
| `lib/astronomy/my_solar_system/` | 完整 sim 实现 |
| `assets/scenarios/my-solar-system/` | 15 preset JSON |
| `test/astronomy/my_solar_system/` | 135 模块测试 |
| `requirements/req-my-solar-system/` | 需求 / 审计 / Close |
| `requirements/req-my-solar-system/CLOSE_REPORT.md` | 本文件 |
| `requirements/req-my-solar-system/LOOP6_PHYSICS_AUDIT.md` | Loop 6 物理审计 |
| `requirements/req-my-solar-system/PARAMETER_AUDIT.md` | 参数溯源 |
| `requirements/req-my-solar-system/process.txt` | 全阶段追溯链 |

---

## Traceability Chain

Intake → Loop 1 → Loop 2 → Loop 3 → Loop 4 → Loop 5 → Loop 6 → **Close (done)**
