# How-To：为 Screen 新增一种交互（修改状态）

> 来源: 首次扫描（基于 `CircuitScreen._update` 与 `OpticsScreen._solve` 的闭环）| 创建时间: 2026-07-17

## 前置条件

- 已有目标 Screen（`CircuitScreen` 或 `OpticsScreen`）。
- 已理解 [flows/state-update-loop.md](../flows/state-update-loop.md) 的"状态→求解→重绘"闭环。

## 通用模式

**电路**——所有修改必须经 `_update`，禁止直接 `setState` 改 `_state` 而不入历史/不求解：

```dart
// 正确：走闭环
void _myEdit() {
  _update(_state.copyWith(components: [...]), sound: true);
}

// 错误：跳过了 history.push 与 solve
void _myEditBad() {
  setState(() { _state = _state.copyWith(...); });
}
```

**光学**——放置/移动/删除后调用 `_solve()`，且放置/删除/移动前经 `ScenarioRuntimePolicy` 校验：

```dart
void _myEdit() {
  final el = _world.getElementById(id);
  if (el != null && !_policy.canMove(el)) return;   // 运行时约束
  setState(() { _world = _world.moveElement(id, pos); _solve(); });
}
```

## 不可变修改原则

- 永远用 `copyWith` 返回新实例；不要对 `CircuitComponent` / `OpticsWorld` 字段直接赋值（它们是 `@immutable`）。
- 批量改列表用展开运算符：`[...list, newItem]` 或 `list.map(...).toList()`，再包进 `copyWith`。

## 易错点

- 电路 `_update` 会 `history.push(_state)`——**不要在 `_update` 之外单独改 `_history`**，否则 undo/redo 错乱。
- 光学坐标来自 `CanvasProjection.toWorld`；手势回调里的 `localPosition` 必须先 `proj.toWorld` 再使用。
- 渲染层（`_OpticsScene` / `CircuitPainter`）是 `StatelessWidget`/`CustomPainter`，**不要在里面改状态**——只画。

## 验证方法

1. `flutter analyze` 无报错。
2. 触发新交互 → 确认 UI 即时反映新状态（光线/通电重绘）。
3. 电路：连续操作 3 次后 undo 2 次 redo 1 次，状态与预期一致。
4. 光学：受限场景下（如 policy 禁止移动）交互被正确拦截。
