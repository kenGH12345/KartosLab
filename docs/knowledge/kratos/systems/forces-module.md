# 力与运动模块（forces/）

> 来源: 首次扫描 | 创建时间: 2026-07-17

## 概述

`ForcesHome`（`lib/forces/screens/forces_home.dart`）是力与运动主页，以 GridView 提供 4 个实验模式，共用一个 1D 牛顿力学引擎 `ForcesSimulation`。

## 入口与模式分发

`ForcesHome._open` 按标题分发：

| 模式 | 目标 Screen | mode 参数 |
|---|---|---|
| 合力 | `NetForceScreen` | — |
| 运动 | `MotionScreen` | `MotionScreenMode.motion` |
| 摩擦 | `MotionScreen` | `MotionScreenMode.friction` |
| 加速度 | `MotionScreen` | `MotionScreenMode.acceleration` |

## 核心引擎 `ForcesSimulation`（`lib/forces/models/forces_simulation.dart`）

1D 力学模拟，纯数值（无 Flutter 依赖，便于测试）。

| 常量 | 值 |
|---|---|
| `maxSpeed` | 40 m/s |
| `maxFriction` | 0.5 |
| `gravity` | 9.8 m/s² |

状态字段：`mass`(kg) / `position` / `velocity` / `appliedForce`(-500~+500 N) / `frictionCoeff`(0~0.5)。

派生 getter：`frictionForce = _calcFriction()`、`netForce`、`acceleration = netForce/mass`、`speed`。

### 摩擦模型 `_calcFriction`（关键）

- 静止（`speed < 1e-12`）：静摩擦大小 = 施加力，反向，直到超过 `μs·mg`（`staticMax`），之后切动摩擦。
- 滑动：动摩擦力 = `μk·mg`（`kineticMax = staticMax*0.8`），方向与速度反向，与施加力无关。

### `tick(dt)`

`a = (appliedForce + friction)/mass`；更新速度（clamp ±maxSpeed）、位置；含防回弹逻辑（速度即将反向且存在摩擦时归零）。

## 目录结构（actual）

```
lib/forces/
├── config/forces_strings.dart      ← 文案字符串
├── models/forces_simulation.dart   ← 引擎（共享）
│         forces_item.dart / forces_simulation / motion_model / netforce_model
├── screens/forces_home.dart / motion_screen.dart / netforce_screen.dart
└── widgets/accelerometer / applied_force_slider / force_arrow_painter / speedometer
```

## 关键文件

| 文件 | 角色 |
|---|---|
| `lib/forces/models/forces_simulation.dart` | 力学引擎（三屏共用） |
| `lib/forces/screens/forces_home.dart` | 主页分发 |
| `lib/forces/screens/motion_screen.dart` | 运动/摩擦/加速度三模式 |
| `lib/forces/screens/netforce_screen.dart` | 合力（拔河） |
| `lib/forces/widgets/*` | 测速表 / 加速度计 / 力箭头绘制 / 施力滑块 |

## 跨引用

- 模块索引: [systems/module-index.md](module-index.md)
- 设计主线: [architecture/design-patterns.md](../architecture/design-patterns.md) —— 本模块体现的四原则：
  - **MVC 分层**：`ForcesSimulation`（`forces_simulation.dart`，Model，@immutable + copyWith）+ `tick(dt)` 物理步进（逻辑层/Controller 行为）+ `force_arrow_painter` 等（View）
  - **组件化**：`ForcesSimulation` 为三屏（`NetForceScreen`/`MotionScreen`/`ForcesHome`）共用的单一引擎；`forces_item`/`motion_model`/`netforce_model` 继承其状态——复用同一份物理内核，不重复实现
  - **通用化**：仅"引擎级"复用（`ForcesSimulation` 被 3 屏共用），**未复用** `DragDropWorkspace` 拖拽组件（本模块用 `GridView` 模式选择，非画布拖拽）；与 optics/circuit 的"拖拽组件通用化"不同层次
  - **配置化**：✅ 已完成迁移（2026-07-21）。`lib/forces/config/` 下 2 个文件 + 5 个场景 JSON + AI 工具链（prompt + schema）构成完整配置体系，达到 §C1-§C3 全合规。`ForcesHome` 的 `useScenarioLoader` 入口已接入 `ForcesScenarioManager`，新增实验仅需写 JSON + 注册 manifest。
