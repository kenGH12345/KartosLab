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

- **坐标系统一**：所有绘制与定位都经 `SceneProjection`（公共类，`lib/common/geometry/projection.dart`；2026-08-24 起两套旧投影 CanvasProjection/SceneProjection 已合并统一）的 `toScreen/toWorld` 转换。Widget 用 `Positioned(left: sp.dx - w/2, top: sp.dy - h/2)` 按屏幕坐标定位；Painter 用 `proj.toScreen` 画路径。
- **绘制与命中分离**：命中检测在 Screen 层（`hitTest` / `_hitTestWire`，世界坐标），不在 Painter 内。Painter 只负责画，不判断点中与否。线段距离几何用公共纯函数 `pointToSegmentDistance`（`lib/common/geometry/hit_test.dart`）。

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

## 三、共享通用组件（`lib/common/`）

除画布屏原语外，项目在 `lib/common/` 沉淀了跨模块复用的通用组件（L0 通用层）。新增共享组件时优先放此目录并登记 `shared-abstraction-plan.md`。

| 组件 | 文件 | 职责与关键参数 | 备注 |
|---|---|---|---|
| `NineGridLayout` | `common/widgets/nine_grid_layout.dart` | 3×3 九宫格布局（中间格面积≥70%），新增 **footer 参数**：横跨整行的底部控件条，高 = `min(96, 屏高×0.16)`，且 `centerH` 显式扣除 `footerH`（footer 默认 null 不波及其他屏）。**footer 迁移模式（10 屏统一范式）**：footer + `SingleChildScrollView(horizontal)` + `Row` 横排，每控件用 `Wrap` 包 `SizedBox` **限宽**；**不用 FittedBox 包 Slider 类**（无界约束爆炸）。矮视口降级：边格 <48px 时压缩 center（320×480 下 center 面积可 <70%，正常视口不变） | 9宫格决策见 `../notes.md`（2026-08-07 / 2026-08-11 / 2026-08-12） |
| `ExperimentIntroPanel` | `common/widgets/experiment_intro_panel.dart` | 通用实验引导组件：description 常驻一行 + 点击弹 Dialog 复用 `InquiryTaskPanel`；desc/task 均空不渲染；已接入 10 屏 | 已登记 `shared-abstraction-plan.md` L1 候选第 7 |
| `KratosSlider` | `common/controls/kratos_slider.dart` | 滑块控件，新增 **compact 参数**：隐藏 label 行的紧凑滑块，用于顶部/底部窄条控件栏（如 circuit 选中工具条） | |

> **踩坑引用**（单一源在 `../notes.md`）：布局按比例分配时新增底部/横向占用块必须从主体容器高度扣除（footer 案例）；顶部行布局空间不足（~51px 放不下 compact Slider ~60px）是独立评估项；footer 横排内**固定宽子控件（`SizedBox(width:)` / 固定宽渐变条）在 320px 下必溢出**（改 Expanded 自适应）；FittedBox `scaleDown` 只对单一可缩放根节点有效，AppBar 多按钮（>8）窄屏溢出需布局层方案。

## 四、CustomPainter 规范（本项目约定）

所有 Painter 遵循同一套写法（从 `CircuitPainter`/`_LensPainter`/`_RayPainter` 归纳）：

1. **构造注入不可变数据**：`painter: XxxPainter(state: _state, solved: pw, projection: proj)`——数据从外部传入，Painter 自身无状态。
2. **`paint(Canvas, Size)` 命令式绘制**：用 `Paint()` + `canvas.drawLine/drawPath/drawCircle` 等，坐标一律经 `projection.toScreen` 转换。
3. **`shouldRepaint` 必须引用比较**：
   - `CircuitPainter`：`solved != old.solved || state.components != old.state.components || ...`（注释 `[Fix6a]`：`.length` 无法检测位置变化，故逐项比较，`circuit_screen.dart` 内）。
   - `_RayPainter`：`o.ray != ray`（按光线对象引用）。
   - `_LensPainter`：`o.convex != convex || o.color != color`。
4. **绘制与交互分离**：Painter 不处理手势，命中检测在 Screen 层（见第一节）。

> 完整可复用模板（构造注入 / `toScreen` 坐标 / `shouldRepaint` 逐项比较 / 挂载方式 / 验证清单）已沉淀为 How-To：**[conventions/add-custom-painter.md](../conventions/add-custom-painter.md)**。新增 Painter 时直接按该约定执行。

## 五、主题与全局样式

主题集中在 `KratosApp.build` 的 `MaterialApp(theme:)`（`lib/main.dart:31-49`）：`useMaterial3:true`、`seedColor:0xFF1177AA`、背景 `0xFFF6FAFC`、中文回退字体链。各模块 Screen 的 `FilledButton`/`AppBar` 用**硬编码** `backgroundColor`（光学 `0xFF1177AA`、电路 `0xFF0B2B3D`、力与运动 `0xFF166534`），与 seedColor 同源但不走主题 token。

## 六、与其他文档关系

- 拖放事件完整链路：[frontend/drag-drop-workspace.md](drag-drop-workspace.md)「事件」节
- 电路组件清单：[systems/circuit-module.md](../../systems/circuit-module.md)「功能组件清单」节
- 光学组件清单：[systems/optics-module.md](../../systems/optics-module.md)「功能组件清单」节
- 设计主线（通用化/组件化）：[architecture/design-patterns.md](../architecture/design-patterns.md)
