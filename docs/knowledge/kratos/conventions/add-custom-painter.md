# How-To：新增一个 CustomPainter（Canvas 绘制组件）

> 来源: 从 [frontend/ui-framework.md](../frontend/ui-framework.md) 第三节「CustomPainter 规范」抽取 + 源码核对（circuit_screen.dart 内联 `CircuitPainter` / optics_screen.dart 内联 `_LensPainter` / `_RayPainter`）| 创建时间: 2026-07-17

## 前置条件

- 需要在画布上绘制某种**纯视觉元素**（网格 / 导线 / 光线 / 透镜轮廓 / 元件高亮等）。
- 该绘制**不接收手势**——命中检测由 Screen 层负责（见 [frontend/ui-framework.md](../frontend/ui-framework.md) 第一节「绘制与命中分离」）。
- 已理解坐标系统一约定：所有屏幕坐标必须经 `SceneProjection.toScreen`（统一公共类，`lib/common/geometry/projection.dart`；DropCanvas 经 `projectionFactory` 注入或默认工厂产出）。

## 通用模式

本项目所有 Painter 遵循同一套写法：

```
┌─ XxxPainter extends CustomPainter
│    ├─ 构造注入不可变数据（state / solved / projection）
│    ├─ paint(Canvas, Size)  命令式绘制（坐标经 toScreen 转换）
│    └─ shouldRepaint        引用比较（逐项，非 .length）
└─ 在 Screen 的 Stack 里用 CustomPaint(painter: XxxPainter(...)) 挂载
```

## 步骤

### 1. 定义 Painter 类，构造注入数据

Painter 自身零状态，所有绘制输入从外部传入：

```dart
// 放在 Screen 文件内（与 CircuitPainter / _LensPainter 同模式）
class GridPainter extends CustomPainter {
  GridPainter({required this.projection, required this.color});
  final SceneProjection projection;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1;
    // 坐标一律经 projection.toScreen 转换，绝不手写像素
    final start = projection.toScreen(const Offset(0, 0));
    final end = projection.toScreen(const Offset(10, 0));
    canvas.drawLine(start, end, p);
  }

  @override
  bool shouldRepaint(covariant GridPainter old) => old.color != color;
}
```

### 2. 坐标一律经 `toScreen` 转换

参照 `CircuitPainter._v`（`circuit_screen.dart:340+`）：

```dart
// 正确：世界坐标 → 屏幕坐标
final pos = projection.toScreen(drag ? (state.dragVertexNewPos ?? v.pos) : v.pos);
c.drawCircle(pos, 3.0, Paint()..color = ...);
```

- 长度用 `projection.toScreenLength(w)`（`circuit_screen.dart` 内 `_draw`）。
- 禁止在 painter 里硬编码像素位置——画布可缩放/平移，硬编码会错位。

### 3. `shouldRepaint` 必须逐项引用比较

这是本项目**最高频的坑**（见易错点）：

```dart
// 电路 CircuitPainter：solved / components / ... 逐项比较
@override
bool shouldRepaint(covariant CircuitPainter old) =>
    old.solved != solved ||
    old.state.components != state.components ||
    old.state.selectedId != state.selectedId;

// 光线 _RayPainter：按光线对象引用
@override
bool shouldRepaint(covariant _RayPainter old) => old.ray != ray;

// 透镜 _LensPainter：按形状/颜色字段
@override
bool shouldRepaint(covariant _LensPainter old) =>
    old.convex != convex || old.color != color;
```

### 4. 在 Screen 的 Stack 里挂载

Painter 通常放在 `GestureDetector` 包裹的 `CustomPaint` 上（底层），元件层叠在其上（`circuit_screen.dart:281` `_buildCanvas` 同构）。渲染层用 `IgnorePointer` 包裹，使点击穿透到下层手势。

## 易错点

- ⚠️ **`shouldRepaint` 用 `.length` 比较会漏检位置变化**（注释 `[Fix6a]`，`circuit_screen.dart` 内）。元件移动但数量不变时 `.length` 相等 → 不重绘 → 画面卡死。必须逐项引用比较（`components != old.components` 等）。
- Painter **禁止改状态**：不要在 `paint` 里 `setState`、不要持有可变字段。Painter 是纯函数式绘制。
- 命中检测**不在 Painter 内**：点击/拖拽判定在 Screen 层（`hitTest` / `_hitTestWire`，世界坐标）。Painter 只画。
- 坐标转换用 `toScreen` / `toScreenLength`，不要手算 `world * zoom + origin`——投影类已封装。

## 验证方法

1. `flutter analyze lib/screens/<your_screen>.dart` 无报错。
2. 运行 → 触发该 Painter 绘制的状态变化（如移动元件 / 切换场景）→ 确认画面**立即重绘**（验证 `shouldRepaint` 正确，无卡死）。
3. 缩放 / 平移画布后，确认绘制元素位置正确跟随（验证坐标全经 `toScreen`）。
4. 连续操作多次后 undo/redo，确认绘制与状态一致、无残留。

## 与其他文档关系

- 渲染分层与坐标系统一：[frontend/ui-framework.md](../frontend/ui-framework.md) 第一/二节
- 不可变状态与求解闭环：[conventions/add-interaction.md](add-interaction.md)

## 维护钩子

- 本约定由 `managing-knowledge` Skill 在日常维护中回写：改动任何 `CustomPainter`（如 `CircuitPainter` / `_RayPainter` / `_LensPainter`）的 `shouldRepaint` / `toScreen` 用法时，同步更新本文件对应节。
- 本文件已登记于 [INDEX.md](INDEX.md)，INDEX 同步由 `docs-index-updater` Skill（`.codebuddy/skills/core/docs-index-updater/`）承担。
