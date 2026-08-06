# UI 渲染框架

> 来源: 源码核对（circuit_screen.dart / optics_screen.dart / drag_drop_workspace.dart / circuit_controls.dart / component_icon.dart） | 创建时间: 2026-07-17

本项目是 Flutter/Dart 纯本地 App，**无第三方 UI 框架**（仅依赖 `flutter_svg` 渲染 SVG 图标/图像）。UI 由 Flutter 原语（StatelessWidget / CustomPainter / Stack / GestureDetector / Draggable-DragTarget）组合而成，遵循"**状态上提、绘制与交互分离**"的统一范式。

## 一、渲染分层模型

每个画布屏（电路/光学）都是三层叠合，由 `CanvasProjection` 坐标系统一：

```
┌─────────────────────────────────────────────┐
│  Stack（绝对定位叠层）                          │
│  ├─ 底层：CustomPaint（Canvas 命令式绘制）       │
│  │     · 网格 / 导线 / 光线 / 透镜轮廓          │
│  │     · 纯绘制，不接收手势                     │
│  ├─ 中层：元件 Widget（Positioned + IgnorePointer）│
│  │     · ComponentIconWidget / _LensIcon 等     │
│  │     · 只显示，点击穿透到下层的 GestureDetector │
│  └─ 顶层（光学）：IgnorePointer 光线层           │
│        · _RayPainter / _imageWidget 等          │
└─────────────────────────────────────────────┘
        ↑ GestureDetector（最底层，接收所有手势）
```

- **坐标系统一**：所有绘制与定位都经 `CanvasProjection`（光学，`drag_drop_workspace.dart:18`）或 `SceneProjection`（电路，`circuit_screen.dart:312`）的 `toScreen/toWorld` 转换。Widget 用 `Positioned(left: sp.dx - w/2, top: sp.dy - h/2)` 按屏幕坐标定位；Painter 用 `proj.toScreen` 画路径。
- **绘制与命中分离**：命中检测在 Screen 层（`hitTest` / `_hitTestWire`，世界坐标），不在 Painter 内。Painter 只负责画，不判断点中与否。

## 二、核心原语与实例

| 原语 | 角色 | 本项目实例（真实行号） |
|---|---|---|
| `StatelessWidget` | 纯展示组件，零内部状态 | `DragDropWorkspace`/`_Card`/`_DropCanvas`（`drag_drop_workspace.dart`）、`_OpticsScene`/`_LensIcon`/`_RayPainter`/`_RightPanel`（`optics_screen.dart`）、`ComponentIconWidget`（`component_icon.dart`）、`CircuitControls`（`circuit_controls.dart`）。**所有组件无内部状态，状态上提到 Screen 的 `State`** |
| `LayoutBuilder` | 取父约束尺寸 | `_DropCanvas.build`：`c.maxWidth/maxHeight` 建 `CanvasProjection`（`drag_drop_workspace.dart:_DropCanvas`） |
| `Stack` + `Positioned` | 绝对叠层 | 电路 `_buildCanvas`（`circuit_screen.dart:281`）：`GestureDetector` 包 `CustomPaint`，外层 `...components.map(Positioned + IgnorePointer(ComponentIconWidget))`；光学 `_OpticsScene` 同构 |
| `CustomPainter` + `CustomPaint` | 命令式 Canvas 绘制 | `CircuitPainter`（网格/导线/顶点，`circuit_screen.dart`）、`_LensPainter`（贝塞尔画透镜）、`_RayPainter`（实线/虚线光线，`optics_screen.dart`）。均实现 `shouldRepaint` 引用比较 |
| `GestureDetector` | tap/scale/drag | 电路 `onTapUp/onScaleStart-Update-End`（`circuit_screen.dart:258-268`）；光学 `_OpticsScene.onTapUp/onScaleUpdate` |
| `Draggable` / `DragTarget` | 拖放 | `_Card`（Draggable）/ `_DropCanvas`（DragTarget，`drag_drop_workspace.dart`） |
| `SvgPicture.asset` | SVG 图像 | 光学 `_SourceIcon`/`_imageWidget`：`assets/images/pencil.svg`，按 `objectHeight*10` 动态缩放（`optics_screen.dart`） |

## 三、CustomPainter 规范（本项目约定）

所有 Painter 遵循同一套写法（从 `CircuitPainter`/`_LensPainter`/`_RayPainter` 归纳）：

1. **构造注入不可变数据**：`painter: XxxPainter(state: _state, solved: pw, projection: proj)`——数据从外部传入，Painter 自身无状态。
2. **`paint(Canvas, Size)` 命令式绘制**：用 `Paint()` + `canvas.drawLine/drawPath/drawCircle` 等，坐标一律经 `projection.toScreen` 转换。
3. **`shouldRepaint` 必须引用比较**：
   - `CircuitPainter`：`solved != old.solved || state.components != old.state.components || ...`（注释 `[Fix6a]`：`.length` 无法检测位置变化，故逐项比较，`circuit_screen.dart` 内）。
   - `_RayPainter`：`o.ray != ray`（按光线对象引用）。
   - `_LensPainter`：`o.convex != convex || o.color != color`。
4. **绘制与交互分离**：Painter 不处理手势，命中检测在 Screen 层（见第一节）。

> 完整可复用模板（构造注入 / `toScreen` 坐标 / `shouldRepaint` 逐项比较 / 挂载方式 / 验证清单）已沉淀为 How-To：**[conventions/add-custom-painter.md](../conventions/add-custom-painter.md)**。新增 Painter 时直接按该约定执行。

## 四、主题与全局样式

主题集中在 `GeometricOpticsApp.build` 的 `MaterialApp(theme:)`（`lib/main.dart:31-49`）：`useMaterial3:true`、`seedColor:0xFF1177AA`、背景 `0xFFF6FAFC`、中文回退字体链。各模块 Screen 的 `FilledButton`/`AppBar` 用**硬编码** `backgroundColor`（光学 `0xFF1177AA`、电路 `0xFF0B2B3D`、力与运动 `0xFF166534`），与 seedColor 同源但不走主题 token。

## 五、与其他文档关系

- 拖放事件完整链路：[frontend/drag-drop-workspace.md](drag-drop-workspace.md)「事件」节
- 电路组件清单：[systems/circuit-module.md](../../systems/circuit-module.md)「功能组件清单」节
- 光学组件清单：[systems/optics-module.md](../../systems/optics-module.md)「功能组件清单」节
- 设计主线（通用化/组件化）：[architecture/design-patterns.md](../architecture/design-patterns.md)
