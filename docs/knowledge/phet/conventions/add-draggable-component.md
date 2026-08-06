# How-To：向拖拽工作区新增一种元件

> 来源: 首次扫描（基于 `lib/screens/optics_screen.dart` 与 `circuit_screen.dart` 的 tray 定义）| 创建时间: 2026-07-17

## 前置条件

- 已有对应 `OpticalElement` / `CircuitComponent` 子类（或 `ComponentType` 枚举值）。
- 目标 Screen 使用 `DragDropWorkspace<T>`（`lib/widgets/drag_drop_workspace.dart`）。

## 步骤（以光学为例，电路同理）

1. 在 Screen 的 `static const _trayItems` 增加一条 `DragItem`：

```dart
// lib/screens/optics_screen.dart
static const _trayItems = [
  // ... 现有项
  DragItem(data: 'newElement', label: '新元件', icon: Icons.star, color: Color(0xFFxxxxxx)),
];
```

2. 在 `_onComponentDrop` 的 `switch (typeId)` 增加分支，创建对应元件并 `addElement` + `_solve`：

```dart
void _onComponentDrop(String typeId, Offset worldPos) {
  // ... 现有 type 解析
  final element = switch (typeId) {
    // ... 现有分支
    'newElement' => NewElement.create(id: 'new_${_world.elements.length + 1}', position: worldPos),
    _ => throw UnsupportedError('Unknown component type: $typeId'),
  };
  setState(() { _world = _world.addElement(element); _selectedElementId = element.id; _solve(); });
}
```

3. 若需运行时约束，在 `ScenarioRuntimePolicy.canAdd` 中登记该 type（`lib/optics/config/scenario_runtime_policy.dart`）。

## 易错点

- `DragItem.data` 的类型必须与 `DragDropWorkspace<T>` 的泛型 `T` 一致（光学 `String`，电路 `ComponentType`）。
- 电路需在 `ComponentType` 枚举 + `label/unit/defaultValue/valueMin/valueMax` 扩展（`lib/models/circuit_state.dart:8-46`），否则 `switch` 缺 case 会编译失败。
- 放置回调拿到的是**世界坐标**，不要再用局部坐标做命中判断。

## 验证方法

1. `flutter analyze lib/screens/optics_screen.dart` 无报错。
2. 运行 app → 主页 → 几何光学 → 从元件库拖出新元件到画布。
3. 确认元件出现、可选中、可移动、求解无异常。
4. 确认 `ScenarioRuntimePolicy.canAdd` 在受限场景下正确拦截。
