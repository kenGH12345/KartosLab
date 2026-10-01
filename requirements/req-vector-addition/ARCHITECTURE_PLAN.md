# Phase 3 — Architecture Plan · Vector Addition

> 日期：2026-09-04  
> 本地源：`1.3.0-dev.0`  
> 依据：`PROJECT_DISCOVERY.md` + `SOURCE_ANALYSIS.md`  
> 原则：**不机械复制 Collision Lab**；按 Vector Addition 源码结构落地；禁止 tip-canonical

---

## 0. 决策摘要（无阻塞）

| 决策 | 选择 | 是否暂停 |
|---|---|---|
| 目录 | `lib/vector_addition/`（本 sim 第 1 用户） | 否 |
| Canonical | **`tailPosition` + `xyComponents`**；tip/mag/angle = derived | 否 |
| MathCoordinateTransform | **sim 内**集中 Y 翻转；不进 common；Painter 禁止散落翻转 | 否 |
| Snap | `SnapPolicy`（Cartesian / Polar）· 非 Painter | 否 |
| Interaction | `VectorInteractionController` · hit-test / drag · 非 Painter 业务 | 否 |
| Sum vs Equations | **两套 Resultant 策略**：`SumVector` vs `EquationsResultant` | 否 |
| 跨 sim framework | **不做** | 否 |
| common / 其他 sim / Home taxonomy | **不改**（仅力学下加卡，Phase 11） | 否 |
| Home | 物理 → 力学 → Vector Addition + 4 Tab | 否（已确认 A） |

**无不可逆架构阻塞 → 自动进入 Phase 4。**

---

## 1. 数据流（与 Collision Lab 的差异）

Collision Lab 是 **墙钟 + CollisionEngine.step**。  
Vector Addition 是 **交互驱动 + 短动画**（无物理主循环）。

```
User pointer / keyboard
  → VectorInteractionController
       → SnapPolicy.applyTip / applyTail
       → Vector.moveTip… / moveTail… / drop / pop
       → VectorSet 通知（active / isOnGraph）
       → ResultantStrategy.recompute()   // Sum 或 Equations，不同实现
  → VectorAdditionScreenModel（notify）
RenderBuilder
  → VaRenderData（纯结构：箭头几何、标签、网格、面板状态）
Painters / Widgets
  → 只读 RenderData + 手势回调回 Controller
  → MathCoordinateTransform 仅由 Builder / Controller 注入，Painter 不做业务运算
```

**禁止**：

- Painter 算 sum / snap / isOnGraph / 方程
- Painter 写 `height - y` / `-dy`（必须走 Transform）
- Widget 持有第二套 tip-canonical 状态
- 把 Equations 塞进 `SumVector.computeSum`

---

## 2. 模块划分

```
lib/vector_addition/
  vector_addition_constants.dart
  vector_addition_colors.dart
  vector_addition_strings.dart
  model/
    va_vec.dart                      # 2D 向量（model 单位 · +y 上）
    va_bounds.dart                   # 可并入 va_vec
    enums.dart                       # CoordinateSnapMode, GraphOrientation,
                                     # ComponentVectorStyle, EquationType, AngleConvention
    root_vector.dart                 # canonical: tail + xyComponents
    vector.dart                      # interactive + invariants API
    component_vector.dart
    resultant_vector.dart            # 基类：可移、无 tip-drag、不可 remove
    sum_vector.dart                  # Σ isOnGraph
    equations_resultant.dart         # addition/subtraction/negation
    equations_vector.dart            # coefficient + base
    base_vector.dart                 # + CartesianBase / PolarBase 写入路径
    graph.dart                       # bounds + origin + 持有 transform 参数
    vector_set.dart                  # allVectors / activeVectors / resultant
    scene.dart                       # graph + vectorSets + selected
    vector_addition_model.dart       # 基类：scenes + componentStyle + reset
    explore1d_model.dart
    explore2d_model.dart
    lab_model.dart
    equations_model.dart
  snap/
    snap_policy.dart                 # Cartesian / Polar tip & tail
  transform/
    math_coordinate_transform.dart   # 唯一 Y 翻转点 · scale 14.5
  interaction/
    hit_tester.dart                  # body/tip dilation · short-vector tip
    vector_interaction_controller.dart
  render/
    va_render_data.dart
    va_render_builder.dart
  painters/
    graph_painter.dart               # grid/axes/ticks · 只用 Transform 输出的 view 点
    vector_arrow_painter.dart        # ArrowNode 语义 · 无 Material Icon
    component_arrow_painter.dart     # dashed
    origin_manipulator_painter.dart
  widgets/
    va_page_shell.dart               # NineGrid + 局部 layoutBounds 缩放
    va_layout.dart                   # graph / toolbox / values / right panel 锚点
    graph_area.dart
    vector_toolbox.dart
    vector_values_accordion.dart
    graph_control_panel.dart
    scene_radio_group.dart
  screens/
    vector_addition_home.dart
    explore1d_screen.dart
    explore2d_screen.dart
    lab_screen.dart
    equations_screen.dart
  animation/
    toolbox_return_animation.dart    # speed 75 model-units/s

test/vector_addition/
  root_vector_test.dart
  snap_policy_test.dart
  sum_vector_test.dart
  equations_resultant_test.dart
  math_coordinate_transform_test.dart
  component_style_test.dart
```

命名前缀 `Va` / `vector_addition_` 避免与 `collision_lab` 的 `Cl*` 混淆；**不**抽跨 sim 基类。

---

## 3. VectorModel（Canonical）

```dart
class RootVector {
  VaVec tailPosition;      // canonical
  VaVec xyComponents;      // canonical (dx, dy)

  VaVec get tip => tailPosition + xyComponents;           // derived
  double get magnitude => xyComponents.magnitude;        // derived
  double? get angleRadians; // null if ~zero               // derived
  double? angleDegrees(AngleConvention c);               // derived
}
```

- `setTip` → 改 `xyComponents`，保 `tail`
- `setTail`（保 tip）→ 改 `tail` + 重算 `xyComponents`
- **禁止**存储 tip 作为 SSOT

Equations BaseVector：

- Cartesian：`xComponentProperty` / `yComponentProperty` → 写入 `xyComponents`
- Polar：`magnitudeProperty` / `angleDegreesProperty` → `createPolar` → 写入 `xyComponents`  
  仍是**写入路径**，不是第二套结构 canonical。

---

## 4. VectorSet / active / isOnGraph / Resultant

```
VectorSet
  allVectors[]          // 启动时分配，生命周期 = Screen
  activeVectors[]       // 不在 toolbox（可含 isOnGraph=false 的拖动中向量）
  resultantVector       // SumVector | EquationsResultant
```

| 概念 | 定义 |
|---|---|
| `isOnGraph` | 向量是否已 drop 到图上 |
| Sum 贡献 | `allVectors.where((v) => v.isOnGraph)` 的 xy 之和 |
| `activeVectors` | ≠ on-graph；Explore 从 toolbox 拖出后加入 |
| Equations | `activeVectors = [a,b]` 恒定；resultant = c/f |

`erase`：可移除向量移出 active + reset；不清 origin。  
`reset`：resultant + allVectors + erase + graph（scene 级）。

---

## 5. MathCoordinateTransform

对齐 `Graph.modelViewTransformProperty`：

```
viewBounds = Rect(
  bottomLeft.x,
  bottomLeft.y - scale * modelHeight,
  width: scale * modelWidth,
  height: scale * modelHeight,
)
// createRectangleInvertedYMapping(modelBounds, viewBounds)
```

API（唯一入口）：

| 方法 | 语义 |
|---|---|
| `modelToView(VaVec)` | 含 Y 翻转 |
| `viewToModel(Offset)` | 含 Y 翻转 |
| `modelToViewDelta` / `viewToModelDelta` | 增量；Y 符号相反 |
| `modelToViewRect(VaBounds)` | 图背景/网格 |

常量：`MODEL_TO_VIEW_SCALE = 14.5`。  
Origin 拖动 → 更新 `modelBounds`（shifted）→ **重建** Transform（与源码 DerivedProperty 一致）。

Painter 只接收 **已经是 view 坐标** 的 `VaRenderData` 点/路径，或显式注入的 Transform 只读引用且**不得**在 Painter 内重算业务。

---

## 6. SnapPolicy

```dart
abstract class SnapPolicy {
  VaVec snapTip({required VaVec tail, required VaVec proposedTip, ...});
  VaVec snapTail({required VaVec proposedTail, required VaVec xy, ...});
}
class CartesianSnapPolicy implements SnapPolicy { /* integer grid */ }
class PolarSnapPolicy implements SnapPolicy { /* mag int + 5° + tip/tail attract */ }
```

- `VECTOR_TAIL_DRAG_MARGIN = 1`
- `polarSnapDistance = 1`
- `vectorDragThreshold = 10`（出图 pop，属 Interaction，但阈值常量与 Snap 同文件区）
- GraphOrientation：horizontal 锁 tip.y；vertical 锁 tip.x
- **零模长 tip 更新拒绝**

---

## 7. VectorInteractionController

职责（对标 `MoveVectorDragListener` + `ScaleRotateVectorDragListener` + tip hit）：

| 手势 | 行为 |
|---|---|
| Body drag · on-graph | `moveTailWithInvariants` |
| Body drag · off-graph | 自由 tail；end → drop(shadow) 或 animateToToolbox |
| Tip drag | 仅 `isTipDraggable`；`moveTipWithInvariants` |
| Resultant / Equations / Base | **无 tip-drag** |
| Hit body | arrow shape dilation 3 |
| Hit tip | dilation mouse6/touch8；\|xy\|≤3 用中/小 tip 区 |

Controller 改 Model；不写 RenderData 计算。

---

## 8. Resultant 双策略

```dart
abstract class ResultantVector extends Vector { /* tipDraggable=false, removable=false, onGraph=true */ }

class SumVector extends ResultantVector {
  // recompute: Σ xy where isOnGraph
}

class EquationsResultant extends ResultantVector {
  EquationType type;
  // addition: Σ active
  // subtraction: first − rest
  // negation: −Σ active
  // active = [a,b] only — NEVER SumVector path
}
```

可见性：`sumVisible && isDefined`；`isDefined = onGraphCount > 0`（Equations 恒有贡献向量）。

---

## 9. Component rendering

`ComponentVector` 监听 parent tail/tip + `ComponentVectorStyle`：

| Style | 布局（见 SOURCE_ANALYSIS §7） |
|---|---|
| invisible | 不进 RenderData.visible |
| triangle | x 共尾；y 共 tip |
| parallelogram | x/y 共尾 |
| projection | 轴上 + offsets（VectorSet 按 active 索引算） |

RenderBuilder 输出 dashed arrow 几何；Painter 不分支业务。

---

## 10. 四 Screen · 独立 Model

| Screen | Model | Scenes[0], [1] | VectorSets |
|---|---|---|---|
| Explore 1D | `Explore1DModel` | Horizontal, Vertical | 各 1 |
| Explore 2D | `Explore2DModel` | Cartesian, Polar | 各 1 |
| Lab | `LabModel` | Cartesian, Polar | 各 **2**（每 set ≤10） |
| Equations | `EquationsModel` | Cartesian, Polar | 各 1（a,b→c / d,e→f） |

Flutter：`KratosTabbedScreen` 四 Tab；每 Tab 自有 Model/Controller（对齐源码每 Screen `createModel`）。

---

## 11. Page-level layout

```
Scaffold / AppBar（KARTOSLAB）
  → KratosTabbedScreen
       → VaPageShell
            NineGridLayout
              center: FittedBox/Aspect 缩放「PhET layoutBounds 1024×618 局部坐标系」
                VaLayout:
                  GraphArea（含 origin manipulator）
                  VectorValuesAccordion（centerX=graph, top≈35）
                  GraphControlPanel（右上）
                  SceneRadio + Toolbox（右下/左下锚点链）
                  Eraser（graph 下方；Equations 无）
                  ResetAll（右下）
```

- NineGrid **只做外壳**；不把 graph 拆到边格。
- 模拟内部坐标 = PhET model + MathCoordinateTransform。
- 锚点用相对关系（SOURCE_ANALYSIS §11），不为截图写死绝对像素。

---

## 12. Assets / Painters / Widgets / Tests

| 层 | 约定 |
|---|---|
| Assets | 无 runtime 贴图；ref 截图仅 visual-qa |
| Arrow painter | 移植 headW12/headH14/tailW3.5 + dynamic head；禁 Material Icon |
| Colors | `vector_addition_colors.dart` 移植 Profile 默认值 |
| Strings | 英文字符串先对齐 `vector-addition-strings_en.json`；中文可后续 |
| Tests | snap / sum / equations / transform / component / root_vector 先于 UI |

---

## 13. Phase 4 范围（自动进入）

Phase 4 = **Model + Snap + Transform + Resultant 双策略 + 专项测试**。

不含：Flutter Screen UI、Home 注册、Painter 精修、visual capture（后续 Phase）。

验收：

- `flutter test test/vector_addition/` 通过
- `flutter analyze lib/vector_addition` 无 issues
- Canonical / Sum 过滤 / Equations 三分支 / Transform Y 翻转有断言

---

## 14. 禁令核对表

| 禁令 | 架构对策 |
|---|---|
| tip → canonical | RootVector 无 tip 字段存储 |
| 对所有向量求和 | Sum 仅 `isOnGraph` |
| Equations = Sum | 独立 `EquationsResultant` |
| snap/hit/transform 进 Painter | 分属 snap/ / interaction/ / transform/ |
| 跨 sim framework | 仅 `lib/vector_addition/` |
| 改 common / 其他 sim | 不引用修改 |
| 机械复制 Collision Lab | 无 Engine/Clock；交互驱动数据流 |

---

*Phase 3 · 2026-09-04 · 无阻塞 → Phase 4*
