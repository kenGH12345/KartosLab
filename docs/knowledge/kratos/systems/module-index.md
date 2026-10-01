# 模块 / 系统索引

> 来源: 首次扫描 | 创建时间: 2026-07-17
> 变更: 2026-07-17 移除 `circuit_solver_v2.dart` 与 `electron_animator.dart` 两条条目（与删除同步），总文件数 52 → 50。
> 校正: 2026-07-21 磁盘实测 `lib/**/*.dart` 为 54 个（原文误写 55），已同步全文口径。

本表为 `lib/` 下全部 **54** 个 Dart 文件的模块归属与职责速查。深度文档见各子文档。

## 顶层共享（非模块专属）

| 路径 | 职责 | 归属文档 | 状态绑定 |
|---|---|---|---|
| `lib/main.dart` | 入口、强制横屏、主题 | [architecture/app-entry.md](../architecture/app-entry.md) | 无（仅构建 MaterialApp） |
| `lib/screens/home_screen.dart` | 三模块入口 | 同上 | 无（StatelessWidget） |
| `lib/screens/circuit_screen.dart` | 电路主屏 + 投影 + 绘制 | [circuit-module.md](circuit-module.md) | 持 `CircuitState` |
| `lib/screens/optics_screen.dart` | 光学主屏 + 场景渲染 | [optics-module.md](optics-module.md) | 持 `OpticsWorld` + `ScenarioManager` |
| `lib/screens/scenario_selection_screen.dart` | 场景选择页 | [optics-module.md](optics-module.md) | 持 `ScenarioManager`（optics 模块内） |
| `lib/models/circuit_state.dart` | 电路不可变状态 + 辅助类 | [circuit-module.md](circuit-module.md) | `CircuitState`（@immutable + copyWith） |
| `lib/models/circuit_solver.dart` | 电路求解（连通图 + 亮度） | 同上 | 纯函数（无状态） |
| `lib/models/circuit_history.dart` | undo/redo | 同上 | `CircuitHistory` 栈 |
| `lib/models/optics_state.dart` | 简化版光学状态（@immutable 单透镜/镜面） | [optics-module.md](optics-module.md#opticsstate) | `OpticsState`（@immutable，**活代码**：`lib/widgets/optics_scene.dart:7` + `lib/widgets/control_panel.dart:3` 引用） |
| `lib/models/optics_solver.dart` | 简化版光学求解（委托 OpticsMath） | [optics-module.md](optics-module.md#opticssolver) | 纯函数（**活代码**：`lib/widgets/optics_scene.dart:6` 引用） |
| ~~`lib/models/battery.dart`~~ | ⚠️ **确定死代码**（zero-ref，见 [architecture/refactor-baseline-plan.md §0.6](../architecture/refactor-baseline-plan.md)） | 同上 | 无（3.60 KB · `class Battery extends CircuitElement`） |
| ~~`lib/models/circuit_element.dart`~~ | ⚠️ **确定死代码**（zero-ref，14.98 KB / 606 行 `abstract class CircuitElement` + `CircuitElementType` 枚举） | 同上 | 无（`CircuitElementType` **不是**生产 `ComponentType`，勿混用） |
| ~~`lib/models/vertex.dart`~~ | ⚠️ **确定死代码**（zero-ref，独立 `Vertex` 类；生产用的是 `circuit_state.dart:48` 内嵌版本） | 同上 | 无 || `lib/widgets/drag_drop_workspace.dart` | 共享拖拽+投影基础设施 | [frontend/drag-drop-workspace.md](../frontend/drag-drop-workspace.md) | 持 `items` + 投影（瞬态） |
| `lib/widgets/circuit_*.dart` | 电路画布/控件/图标/托盘 | [circuit-module.md](circuit-module.md) | 无（渲染 `CircuitState`） |
| `lib/circuit/config/circuit_scenario.dart` | 电路场景数据模型（3 层拓扑） | [circuit-module.md](circuit-module.md) | 无（JSON 反序列化目标） |
| `lib/circuit/config/scenario_manager.dart` | 电路场景加载/校验/目标判定 | [circuit-module.md](circuit-module.md) | `CircuitScenarioManager`（场景级状态） |
| `lib/circuit/config/circuit_constraint.dart` | 3 种约束 | [circuit-module.md](circuit-module.md) | `CircuitConstraint.validate(CircuitState)` |
| `lib/circuit/config/circuit_inventory.dart` | 元件库存（maxCount/locked/defaultParams） | [circuit-module.md](circuit-module.md) | `CircuitComponentInventory.canAdd` |
| `lib/circuit/config/circuit_learning_objective.dart` | 教学目标 + hint trigger 求值器 | [circuit-module.md](circuit-module.md) | `CircuitLearningObjective.checkAchieved` |
| `lib/widgets/component_icon.dart` / `component_tray.dart` / `constraint_indicator.dart` / `control_panel.dart` / `drag_drop_workspace.dart` / `objective_panel.dart` / `optics_scene.dart` | 共享/光学组件 | [optics-module.md](optics-module.md) / [frontend/drag-drop-workspace.md](../frontend/drag-drop-workspace.md) | 无（渲染 `OpticsWorld`） |

## 光学模块 `lib/optics/`

| 路径 | 职责 | 状态绑定 |
|---|---|---|
| `config/component_inventory.dart` | 元件规格 + defaultParams | 无（数据定义） |
| `config/constraint.dart` | 约束 + 违反 | `Constraint.validate(OpticsWorld)` |
| `config/game_rules.dart` | 计分规则 | 无（固定公式） |
| `config/lab_scenario.dart` | 场景数据模型 | 无（JSON 反序列化目标） |
| `config/learning_objective.dart` | 教学目标 | `LearningObjective.checkAchieved` |
| `config/scenario_manager.dart` | 场景加载/校验/目标判定 | `ScenarioManager`（场景级状态） |
| `config/scenario_runtime_policy.dart` | 运行时编辑约束 | `ScenarioRuntimePolicy.canAdd/Remove/Move` |
| `models/optical_element.dart` | 元件抽象 + 枚举 | `OpticalElement`（@immutable） |
| `models/lens_element.dart` / `mirror_element.dart` / `light_source_element.dart` / `screen_element.dart` | 具体元件 | 继承自 `OpticalElement` |
| `models/optics_world.dart` | 光学世界状态 | `OpticsWorld`（@immutable + copyWith） |
| `physics/optics_math.dart` | 几何底层（`OpticsMath`，详见 optics-module.md 简化版段） | 纯静态工具（无状态） |
| `solvers/optics_solver.dart` | 光线追迹 | 纯函数 `solve(OpticsWorld)` |

## 力与运动模块 `lib/forces/`

| 路径 | 职责 | 状态绑定 |
|---|---|---|
| `config/forces_strings.dart` | 文案 | 无（常量） |
| `models/forces_simulation.dart` | 力学引擎（三屏共用） | `ForcesSimulation`（@immutable + copyWith） |
| `models/forces_item.dart` / `motion_model.dart` / `netforce_model.dart` | 模型 | 继承自 `ForcesSimulation` 状态 |
| `screens/forces_home.dart` / `motion_screen.dart` / `netforce_screen.dart` | 屏幕 | 持 `ForcesSimulation` |
| `widgets/accelerometer.dart` / `applied_force_slider.dart` / `force_arrow_painter.dart` / `speedometer.dart` | 可视化控件 | 渲染 `ForcesSimulation` |

## 设计原则对照总表（速查）

四条统一设计原则在三个模块的落地现状（主线详解见 [architecture/design-patterns.md](../architecture/design-patterns.md)）：

| 原则 | 光学模块 | 电路模块 | 力与运动模块 |
|---|---|---|---|
| **MVC 分层** | `OpticsWorld`(M)+`OpticalSolver`(C)+`_OpticsScene`(V) | `CircuitState`(M)+`CircuitSolver`(C)+`CircuitPainter`(V) | `ForcesSimulation`(M)+`tick`(C)+`force_arrow_painter`(V) |
| **组件化** | `OpticalElement` 抽象基类 + 4 子类（`optical_element.dart:103`） | `CircuitComponent` + `CircuitElementType` 枚举（枚举 vs 继承同构） | `ForcesSimulation` 被 3 屏共用的单一引擎 |
| **通用化** | `DragDropWorkspace<String>` 复用 | `DragDropWorkspace<ComponentType>` 复用 + `_addComponent` else 通用分支 | 仅引擎级复用（`DragDropWorkspace` 未复用，用 GridView） |
| **配置化** | ✅ 全量 JSON（`assets/scenarios/*.json` 驱动） | ✅ 全量 JSON（`assets/scenarios/circuit/*.json` 驱动 · 7 samples + AI toolchain） | ✅ 全量 JSON（`assets/scenarios/forces/*.json` 驱动 · 5 samples + AI toolchain） |

> 三模块对照说明：光学、电路、力与运动三个模块均为四原则的**完整样板**（2026-07-21 电路 + 力与运动均完成配置化迁移）。

## 统计

- 总文件数：54 个 `.dart`（仅 `lib/`，含 `lib/circuit/config/` 5 个文件 · 2026-07-21 磁盘实测口径）
  - 其中 3 个已确定为死代码（`battery.dart` / `circuit_element.dart` / `vertex.dart`，共 21.28 KB / 约 750+ 行）——清理方案见 [architecture/refactor-baseline-plan.md §0.6.5](../architecture/refactor-baseline-plan.md)
- 模块文件分布（抽样估算）：optics 约 21、forces 约 12、电路/共享 约 17（不扣除死代码）
- 总行数：约 7849 行（抽样估算，不含删除的 CircuitSolverV2 428 行 + ElectronAnimator 100 行）

## 跨引用

- 项目总览: [architecture/overview.md](../architecture/overview.md)
- 设计主线（四原则 × 三模块详解）: [architecture/design-patterns.md](../architecture/design-patterns.md)
