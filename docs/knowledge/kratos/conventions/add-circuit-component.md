# How-To：新增一种电路元件类型

> 来源: 首次扫描（基于 `lib/models/circuit_state.dart` 的枚举与 `CircuitScreen._trayItems`）| 创建时间: 2026-07-17

## 前置条件

- 需要新增的元件是电池/电阻/灯泡/开关/保险丝/接地/导线之外的新种类。
- 涉及文件：`circuit_state.dart`（枚举 + 尺寸）、`circuit_screen.dart`（tray + 交互）、`circuit_solver.dart`（求解逻辑）。

## 步骤

### 1. 扩展 `ComponentType` 枚举

```dart
// lib/models/circuit_state.dart:2
enum ComponentType { battery, resistor, lightBulb, switch_, wire, fuse, ground, newKind }
```

### 2. 在扩展方法里补齐元信息

`ComponentTypeLabel` extension（`circuit_state.dart:10-46`）需为 `newKind` 提供 `label` / `unit` / `defaultValue` / `valueMin` / `valueMax` / `valueStep`，否则 `switch` 表达式缺 case → 编译失败。

### 3. `CircuitComponent` 尺寸

`CircuitComponent.width/height` getter（`circuit_state.dart:95-97`）按 type 返回尺寸；新种类需补一个分支。

### 4. 托盘 + 放置

`CircuitScreen._trayItems`（`circuit_screen.dart`）加 `DragItem(data: ComponentType.newKind, ...)`；`_addComponent` 的 `else` 分支已按 `type.defaultValue` 通用创建，通常无需改。

### 5. 求解逻辑

`CircuitSolver.solve`（`circuit_solver.dart`）按 `type` 分支判断通电/亮度。若新元件参与回路（如新型电源），需在"逐电池判断"与"亮度计算"两处补充 `type == ComponentType.newKind` 的处理。

## 易错点

- ⚠️ **`CircuitState.copyWith` 用 `_NullSentinel` 模式**（`circuit_state.dart:230-270`）。新增任何可空字段必须照搬 `Object? xxx = _ns` + `identical(xxx, _ns)` 判断，不可用 `null ?? old`，否则无法清空该字段。
- `ComponentType` 是 `enum`，所有 `switch` 必须 exhaustive，缺 case 编译不过。
- 导线 `wire` 的宽度/高度特殊（100×4），渲染命中区用 `hitRect`(+40 padding)，新元件若需不同命中区要重写 `hitTest`。

## 验证方法

1. `flutter analyze lib/models/circuit_state.dart lib/screens/circuit_screen.dart lib/models/circuit_solver.dart` 无报错。
2. 运行 → 电路搭建 → 从托盘拖出新元件，确认可放置/选中/删除/旋转。
3. 搭建含新元件的简单回路，确认 `CircuitSolver` 通电判定符合预期（可加 `print` 验证 `SolvedCircuit.componentStates`）。
4. 缩放/清空/undo/redo 后状态不残留。
