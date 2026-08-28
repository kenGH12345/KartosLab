# 模块 / 系统索引

> 来源: 首次扫描 | 创建时间: 2026-07-17
> 变更: 2026-07-17 移除 `circuit_solver_v2.dart` 与 `electron_animator.dart` 两条条目（与删除同步），总文件数 52 → 50。
> 校正: 2026-07-21 磁盘实测 `lib/**/*.dart` 为 54 个（原文误写 55），已同步全文口径。
> 新增: 2026-08-28（req-drag-lesson-editor）登记 `lib/lesson_editor/` 剧本编辑器模块（15 新文件 + 改动 `lesson_sim_host.dart`/`home_screen.dart`），核心口径 54 → 69。

本表为 `lib/` 下全部 **69** 个 Dart 文件（原 54 + lesson_editor 15）的模块归属与职责速查。深度文档见各子文档。

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

## 剧本编辑器模块 `lib/lesson_editor/`

> 来源: req-drag-lesson-editor（`requirements/req-drag-lesson-editor/spec/最终需求.md` D1~D11 + `../notes.md` §8）。作者侧可视化编排器——把已有 `lesson.schema.json` 剧本以拖拽节点图形式编辑/导入/导出。**新增 15 个 Dart 文件 + 1 个 assets 规则表**；改动 2 个既有文件（下表标注）。

| 路径 | 职责 | 状态绑定 |
|---|---|---|
| `lib/lesson_editor/lesson_editor_entry.dart` | 编辑器入口 | 无 |
| `lib/lesson_editor/screens/lesson_editor_screen.dart` | 编辑器主屏（九宫格骨架 + 拖入/拖动/选中/校验/保存/导入/高级 JSON 模式编排 · 含受控 `_ControlledTextField`） | 持 `EditableLessonModel` |
| `lib/lesson_editor/models/editable_lesson_model.dart` | 可编辑态模型（`toLessonPlanJson`/`fromLessonPlanJson` + `LessonEdge` + `EditableNode.copyWith`/`updateNode` + `edges` getter 从 advance 推导单一数据源） | `EditableLessonModel`（可变编辑态，非运行时 @immutable） |
| `lib/lesson_editor/panels/node_tray.dart` | 节点库托盘（`DragTray` 复用） | 无 |
| `lib/lesson_editor/panels/advance_editor.dart` | advance 三型编辑（next/onCompleted/routes · `_withFallbackInvariant()` 末项兜底不变量自愈 D7） | 无 |
| `lib/lesson_editor/panels/condition_tree_editor.dart` | 条件树递归编辑（all/any/not + 3 叶子 · 深度≤4 · `nodeSims`/`ownerSim` 跨 sim 引用标注） | 无 |
| `lib/lesson_editor/panels/scene_selector.dart` | 场景引用选择（sim 下拉 + scenarioId 二级联动 + 手动刷新 · 消费 `loadSceneCatalog()`） | 无 |
| `lib/lesson_editor/canvas/lesson_canvas_view.dart` | 画布视图（`DropCanvas` origin=zero 1:1 坐标 + 网格 + 连线层） | 无 |
| `lib/lesson_editor/canvas/lesson_node_card.dart` | 可拖/可选节点卡片（连线手柄 + `isConflict` ⚠ 角标） | 无 |
| `lib/lesson_editor/canvas/lesson_edge_painter.dart` | 三型连线渲染（next/onCompleted/routes + 兜底虚线 + 冲突边黄虚线 · `CustomPainter`） | 无（详见 [../conventions/add-custom-painter.md](../conventions/add-custom-painter.md)） |
| `lib/lesson_editor/canvas/lesson_auto_layout.dart` | 导入布局兜底（entry 起 BFS 分层 · 已保存坐标优先） | 纯函数（无状态） |
| `lib/lesson_editor/validation/lesson_validator.dart` | 轻量校验 + 复用 `LessonPlan.fromJson` 9 图校验（`scenarioPlayable` 可注入依赖倒置） | 纯函数 |
| `lib/lesson_editor/validation/lesson_saver.dart` | 三件写入（`<id>.json` + `<id>.layout.json` + manifest 增/覆盖） | 纯函数 |
| `lib/lesson_editor/validation/lesson_importer.dart` | 导入回读（listAvailable 读 manifest + importByEntry 校验+布局还原+降级） | 纯函数 |
| `lib/lesson_editor/conflict/conflict_rules.dart` | 冲突规则集加载 + 降级 + 白名单无序匹配 | `ConflictRuleSet` |
| `lib/lesson_editor/conflict/conflict_checker.dart` | 两类冲突（教学语义有向边 / 数据传递条件树叶子跨 sim 引用） | 纯函数 |
| `assets/editor/sim_conflict_rules.json` | 冲突规则表（`allowedCombos` 白名单默认含 circuit↔color_vision · 保 AC-21 混合剧本） | 配置数据 |
| `lib/common/scenario/lesson_sim_host.dart` | **既有文件改动**：新增只读访问器 `loadSceneCatalog()`（复用 `scenarioPlayable` 过滤 · 注册表驱动 · 新增 sim 接线后自动出现，编辑器侧支持动态刷新，无需重启 · 决策 D5） | 无 |
| `lib/screens/home_screen.dart` | **既有文件改动**：新增编辑器作者入口 | 无（StatelessWidget） |

**关键设计决策（单一源在 spec/最终需求.md D1~D11 与 [../frontend/drag-drop-workspace.md](../frontend/drag-drop-workspace.md) Change-2）**：
- **D7 复用 L0 画布承载异构编排**：不改 `DragDropWorkspace` 本体，在其上封装连线层 `LessonCanvasView` + `LessonEdgePainter` 承载节点图（见 drag-drop-workspace.md Change-2）。
- **D8 布局不在 schema**：`lesson.schema.json` 是纯运行时数据契约不含 UI 坐标；节点位置外置 `<id>.layout.json`，运行时忽略。
- **D5 场景引用注册表驱动**：`loadSceneCatalog()` 从注册表读，非硬编码 enum；新增 sim 接线 4 处后自动出现。

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

- 总文件数：69 个 `.dart`（原 54 + `lib/lesson_editor/` 15 · 含 `lib/circuit/config/` 5 个文件 · 2026-07-21 磁盘实测口径 + 2026-08-28 lesson_editor 登记）
  - 其中 3 个已确定为死代码（`battery.dart` / `circuit_element.dart` / `vertex.dart`，共 21.28 KB / 约 750+ 行）——清理方案见 [architecture/refactor-baseline-plan.md §0.6.5](../architecture/refactor-baseline-plan.md)
- 模块文件分布（抽样估算）：optics 约 21、forces 约 12、电路/共享 约 17（不扣除死代码）
- 总行数：约 7849 行（抽样估算，不含删除的 CircuitSolverV2 428 行 + ElectronAnimator 100 行）

## 跨引用

- 项目总览: [architecture/overview.md](../architecture/overview.md)
- 设计主线（四原则 × 三模块详解）: [architecture/design-patterns.md](../architecture/design-patterns.md)
