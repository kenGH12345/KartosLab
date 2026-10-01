# Phase 1 — Source Analysis · Vector Addition

> 需求：`req-vector-addition`  
> 本地版本：`package.json` **`1.3.0-dev.0`**（不因官网 latest 替换）  
> 源码根：`phet sourses/vector-addition-main/vector-addition-main`  
> Home 归类（用户确认）：**物理 → 力学 → Vector Addition**（不新建「数学」一级）  
> 范围：仅 `vector-addition` 四屏；**不**迁移独立产品 `vector-addition-equations`  
> 标记：`[已确认]` / `[推测]` / `[待确认]`

---

## 0. 结论摘要

1. **Canonical State 不变**：交互向量的结构 ground truth 仍是 **`tailPositionProperty` + `xyComponentsProperty`**；`tip` / `magnitude` / `angle` 均为 derived。禁止把 tip 升为 canonical。[已确认 `RootVector.ts`]
2. **Equations BaseVector 例外（写入路径）**：Cartesian UI 用 `xComponentProperty`/`yComponentProperty`；Polar UI 用 `magnitudeProperty`/`angleDegreesProperty` —— 它们**写入** `xyComponentsProperty`，不改变 RootVector 结构 canonical。[已确认 `CartesianBaseVector.ts` / `PolarBaseVector.ts` 注释]
3. Snap / drag / isOnGraph / Sum / ComponentStyle / Equations 方程求解 / 箭头几何 / hit-test / 布局锚点均在本地源码**可完整取证**，无需教材补模型。
4. 本阶段**无业务代码**；证据充分 → 默认进入 Phase 2（视觉基线）。

---

## 1. 功能 → 源码证据矩阵

| 功能 | 主文件 | 类/方法 | 状态 | 迁移结论 |
|---|---|---|---|---|
| Screen 注册 | `js/vector-addition-main.ts:26-30` | Sim screens[] | 4 屏 · Explore1D 默认 | Tab 顺序锁定 |
| Canonical vector | `common/model/RootVector.ts` | tail + xyComponents | ground truth | **禁止 tip-canonical** |
| Tip derived | 同文件 | `tip = tail + xy` | DerivedProperty | Render/hit 可用 tip |
| Cartesian tip snap | `Vector.setTipPositionWithInvariants` | closestPoint + roundedSymmetric | 整数格点 | |
| Polar tip snap | 同方法 | mag 整数 · angle×5° | tip≠tail | |
| Tail snap Cartesian | `setTailPositionWithInvariants` | eroded bounds + round | | |
| Tail snap Polar | 同方法 | tip/tail 互吸 `polarSnapDistance=1` | 允许非整数 tail | |
| Body drag | `MoveVectorDragListener` | on-graph → moveTail… | off-graph 自由 | |
| Tip drag | `ScaleRotateVectorDragListener` | moveTip… | `isTipDraggable` | |
| Drop / pop | `dropOntoGraph` / `popOffOfGraph` | isOnGraph + selection | | |
| Sum | `SumVector.computeSum` | Σ on-graph xy | Explore/Lab | |
| Equations 求解 | `EquationsResultantVector.update` | addition/subtraction/negation | 仅 a,b → c | |
| Component styles | `ComponentVector.updateComponent` | 4 styles | 默认 invisible | |
| Arrow 几何 | QP + Constants | headW12 headH14 tailW3.5 | 动态头 | |
| Hit-test | RootVectorNode + VectorTipNode | shape offset dilation | tip 分级 | |
| Graph MVT | `Graph.ts` | inverted-Y · scale 14.5 | 集中 Transform | |
| Layout anchors | ScreenView / SceneNode | 右面板 · toolbox · eraser | NineGrid 外壳内复刻 | |
| Reset / Erase | Model + Scene + ViewProperties | 语义不同 | | |
| Assets | `assets/*.png` | 仅参考截图 | 无 runtime 贴图 | |

---

## 2. Canonical State（强制）

### 2.1 RootVector `[已确认]`

| 字段 | 角色 |
|---|---|
| `tailPositionProperty: Vector2` | **canonical** |
| `xyComponentsProperty: Vector2` | **canonical**（dx, dy） |
| `tipPositionProperty` | **derived** = `tail.plus(xyComponents)` |
| `magnitude` | **derived** |
| `angle` (rad) | **derived**；\|xy\|≈0 → `null`；实现为 `xyComponents.angle` |
| `angleDegrees` | **derived** + `AngleConvention`（signed/unsigned） |

源码注释原文：

> `xyComponentsProperty` and `tailPositionProperty` are the **"ground truth"** from which other values are derived.

`setTipXY` / `setTailXY` 均通过改 canonical 间接改 tip（改 tip 时改 xy、保 tail；改 tail 保 tip 时重算 xy）。

### 2.2 Equations BaseVector UI 写入路径 `[已确认]`

| 场景 | UI Properties（编辑真相） | 写入 |
|---|---|---|
| Cartesian base | `xComponentProperty`, `yComponentProperty`（Integer, [-10,10]） | → `xyComponentsProperty` |
| Polar base | `magnitudeProperty` Integer [-10,10]；`angleDegreesProperty` Integer [-180,180] step 5 | → `Vector2.createPolar` → `xyComponents` |
| EquationsVector | `coefficientProperty` ∈ [-5,5] | `xy = base.xy * coefficient` |

**迁移规则**：Flutter 结构模型仍用 `tail + xyComponents`；Equations 的 NumberPicker 是**控制器写入路径**，不是第二套 canonical 结构。

### 2.3 角度符号 `[待确认 → Phase 4 单测钉死]`

- `RootVector.get angle` 注释写 “clockwise”。
- 实现返回 `Vector2.angle`（PhET dot 通常为 atan2，**逆时针从 +x**）。
- Polar tip snap：`while (roundedAngle < 0) roundedAngle += 2π` 强制非负角再 `setPolar`。
- Preference：`signed` [-180,180) / `unsigned` (0,360]。

**不在 Phase 1 猜测方向**；Phase 4 用已知向量 (1,0)/(0,1)/(-1,0)/(0,-1) 对照源码/运行时。

---

## 3. Snap / Snapping Invariants

### 3.1 CoordinateSnapMode `[已确认]` `CoordinateSnapMode.ts`

| Mode | Tip | Tail（平移） |
|---|---|---|
| `cartesian` | tip ∈ graph ∩ **整数格点** | tail ∈ eroded(bounds,1) ∩ **整数格点** |
| `polar` | \|xy\|→整数；角→`POLAR_ANGLE_INTERVAL=5°` 倍数；tip 须在 bounds（否则 mag−1 循环） | 优先 snap 到其他 active+resultant 的 tip/tail（距离 `< polarSnapDistance` 默认 **1** model unit）；否则整数格点 |

### 3.2 Tip invariants `[已确认]` `Vector.setTipPositionWithInvariants`

**公共**：

- tip **不得**等于 tail（零模长拒绝更新）。
- 水平图：`tip.y = tail.y`；垂直图：`tip.x = tail.x`。

**Cartesian**：

```
tip = graph.bounds.closestPointTo(tip).roundedSymmetric()
```

**Polar**：

```
mag = roundSymmetric(|tip−tail|)
angle = 5° * roundSymmetric(θ / 5°)   // 再规范化到 ≥0
polar = setPolar(mag, angle)
while tip∉bounds: mag -= 1
if tip≠tail: setTip(tip)
```

### 3.3 Tail invariants `[已确认]` `setTailPositionWithInvariants`

```
constrained = graph.bounds.eroded(VECTOR_TAIL_DRAG_MARGIN=1)
tailOnGraph = constrained.closestPointTo(tail)
```

**Polar 吸附顺序**（对 `activeVectors\{self} ∪ {resultant}`）：

1. 本向量 tail ↔ 他向量 tail  
2. 本向量 tail ↔ 他向量 tip  
3. 本向量 tip ↔ 他向量 tail → `tail = other.tail − xyComponents`  
4. 否则 `tail = roundedSymmetric(tailOnGraph)`

### 3.4 Query parameters（默认）`[已确认]`

| QP | Default | 用途 |
|---|---|---|
| `vectorDragThreshold` | 10 | 拖出图判定 |
| `polarSnapDistance` | 1 | Polar 首尾吸附 |
| `headWidth` | 12 | 箭头 |
| `headHeight` | 14 | 箭头 |
| `tailWidth` | 3.5 | 箭杆（须 < headWidth） |
| `angleConvention` | `signed` | Preferences |

---

## 4. Drag Invariants（Whole / Tip / Tail）

### 4.1 Body（whole vector）`[已确认]` `MoveVectorDragListener`

| 状态 | 行为 |
|---|---|
| `!isOnGraph` | `tailPositionProperty = view→model`（**无** snap invariants） |
| `isOnGraph` | `moveTailToPositionWithInvariants(tail)` |
| 拖动中 cursor 出 graph 且 `isRemovableFromGraph` | `popOffOfGraph()` |
| end：仍 off-graph | cursor∈graph → `dropOntoGraph(shadowTail)`；否则 `animateToToolboxProperty=true` |
| drop 选点 | 用 **shadow** 中心推算 tail（非裸 cursor） |

Shadow 偏移（view）：`SHADOW_X_OFFSET=3.2`, `SHADOW_Y_OFFSET=2.1`，fill black opacity 0.28。

### 4.2 Tip（scale/rotate）`[已确认]` `ScaleRotateVectorDragListener` + `VectorTipNode`

- 仅当 `vector.isTipDraggable === true` 创建 `VectorTipNode`。
- `tipModel = tail + viewToModelDelta(tipView)` → `moveTipToPositionWithInvariants`。
- Resultant / EquationsVector / BaseVector：`isTipDraggable: false`。

### 4.3 Explore 1D

- GraphOrientation `horizontal`/`vertical` 约束 tip 轴。
- 可平移 + tip 缩放；**不可旋转出轴**（由 orientation 强制）。

### 4.4 Equations

- 主向量 / base / resultant：**不可 tip-drag**；只能平移（tail）+ NumberPicker 改分量/模角/系数。
- `isRemovableFromGraph: false`，`isOnGraph: true` 固定。

---

## 5. isOnGraph 规则

| 操作 | 效果 | 标记 |
|---|---|---|
| 初始（Explore/Lab 可拖向量） | `false` | [已确认] |
| `dropOntoGraph(tail)` | `true`；`selected=this`；tail 走 invariants | [已确认] |
| `popOffOfGraph()` | `false`；`selected=null` | [已确认] |
| Body 拖出（threshold） | `moveTail…` 内：`|dragOffset| > vectorDragThreshold` → pop | [已确认] |
| Body 拖中 cursor∉graph | MoveVectorDragListener → pop | [已确认] |
| Resultant | 永为 `true`；不可 remove | [已确认] |
| Equations 全部 | 永为 `true` | [已确认] |
| Sum 贡献 | **仅** `isOnGraph===true` 的 `allVectors` 的 xy | [已确认] |
| activeVectors | 不在 toolbox 的向量（可含 off-graph 拖动中）；**≠** on-graph | [已确认 `VectorSet` 注释] |
| Component 可见 | style≠invisible **且** parent `isOnGraph` | [已确认] |

**Erase**：`scene.erase()` → 清 selection + 各 `vectorSet.erase()`（向量回 toolbox / reset），**不**重置 graph origin / scene 选择。[已确认]

**Reset All**：`model.reset()` + viewProperties.reset（含 scene、component style、graph bounds、所有向量、sumVisible 等）。[已确认]

---

## 6. Resultant 移动 / 锁定

| 属性 | SumVector / ResultantVector | 标记 |
|---|---|---|
| `isTipDraggable` | **false** | [已确认] |
| `isRemovableFromGraph` | **false** | [已确认] |
| `isOnGraph` | **true**（恒） | [已确认] |
| Body drag | **允许**（继承 MoveVectorDragListener → 平移 tail） | [已确认] |
| 可见性 | `resultantVisible ∧ isDefined`；`isDefined` = 至少 1 个 on-graph 贡献向量 | [已确认 `ResultantVectorNode`] |
| Explore sumVisible 默认 | **false** | [已确认 `ExploreViewProperties`] |
| 隐藏时若已选中 | 清 `selectedVectorProperty` | [已确认] |
| 禁止回 toolbox | affirm：`animateToToolbox` 永不应为 true | [已确认] |

**xy 更新（Explore/Lab）**：

```
sum = Σ { v.xyComponents | v ∈ allVectors ∧ v.isOnGraph }
```

监听：每个向量的 `isOnGraphProperty` + `xyComponentsProperty`。[已确认 `SumVector.ts`]

---

## 7. Component Style

默认：`componentVectorStyleProperty = 'invisible'`。[已确认 `VectorAdditionModel`]

对 parent `(tail, tip)`：

### xComponent

| Style | Tail | Tip |
|---|---|---|
| `triangle` / `parallelogram` | parent.tail | `(parentTip.x, parentTail.y)` |
| `projection` | `(parentTail.x, projectionYOffset)` | `(parentTip.x, projectionYOffset)` |
| `invisible` | （不显示；仍可更新） | |

### yComponent

| Style | Tail | Tip |
|---|---|---|
| `triangle` | `(parentTip.x, parentTail.y)` | parent.tip |
| `parallelogram` | parent.tail | `(parentTail.x, parentTip.y)` |
| `projection` | `(projectionXOffset, parentTail.y)` | `(projectionXOffset, parentTip.y)` |

标签：显示 **标量** x 或 y（可负）；values 关或分量为 0 → 不显示数值；无 symbol。[已确认]

Projection offsets 由 `VectorSet` 管理（多向量错开）。[已确认 issue #225]

箭头：`COMPONENT_VECTOR_ARROW_OPTIONS` = 共享 head + `tailWidth:3` + `tailDash:[6,3]`（DashedArrowNode）。

---

## 8. Equations Screen 求解逻辑

### 8.1 结构 `[已确认]`

- Cartesian：非 resultant = **a, b**；resultant = **c**。  
  初始：`a` base (0,5) @ (35,15)；`b` base (5,5) @ (35,5)；主向量 tail (5,5)/(15,5)；resultantTail (25,5)。
- Polar：d, e → f（同构）。
- `activeVectors` = 全部非 resultant（a,b），启动后**禁止**增删。
- `EquationsResultantVector.update(activeVectors)` —— **只吃 a,b，不含 c**。

### 8.2 三种方程 `[已确认]` `EquationsResultantVector.update` + `EquationType`

| equationType | UI 语义 | 源码计算（vectors = [a,b]） |
|---|---|---|
| `addition` | a + b = c | `c.xy = a.xy + b.xy` |
| `subtraction` | a − b = c | `c.xy = a.xy − b.xy`（从首项依次 subtract） |
| `negation` | a + b + c = 0（即 a+b=−c） | `c.xy = −(a.xy + b.xy)` |

**禁止**改写成「教材 head-to-tail 几何构造器」；必须移植上述分量代数。

### 8.3 系数

`EquationsVector.xy = base.xy * coefficient`，coefficient ∈ [-5,5] 整数，默认 1。  
标签可含 coefficient。[已确认]

### 8.4 交互差异 vs Explore

| | Explore/Lab | Equations |
|---|---|---|
| Toolbox | 有 | **无** |
| Eraser | 有 | **无**（`includeEraserButton` 默认在 Scene；Equations 覆盖为无 toolbox） |
| Tip drag | 有（非 sum） | **无** |
| 改大小/方向 | tip drag / snap | NumberPicker（base + coefficient） |
| Resultant defined | 依赖 on-graph | 恒有向量 → `isDefinedProperty` 不 instrument |

Equations graph `bottomLeft.y = DEFAULT_BOTTOM_LEFT.y + 40`（为方程 UI 让位）。[已确认 `EquationsScene.ts`]

---

## 9. Arrow Geometry

### 9.1 默认参数 `[已确认]`

来自 `VectorAdditionQueryParameters` → `VECTOR_ARROW_OPTIONS`：

| 参数 | 值 |
|---|---|
| headWidth | 12 |
| headHeight | 14 |
| tailWidth | 3.5 |
| stroke | null |
| isHeadDynamic | **true** |
| fractionalHeadHeight | **0.5** |

Resultant：同 VECTOR_ARROW_OPTIONS。  
BaseVector：+ `lineWidth: 1.5`。  
Component：tailWidth 3 + dash [6,3]。

### 9.2 渲染模型 `[已确认]` `RootVectorNode`

- 节点 local：tail 在 (0,0)；`setTip(viewΔx, viewΔy)`；外层 `translation = modelToView(tail)`。
- `magnitude < ZERO_THRESHOLD(1e-10)` → **隐藏** arrow（label 仍可居中）。
- **禁止** Material Icons；移植 PhET `ArrowNode` / `DashedArrowNode` 语义（含动态头）。

### 9.3 Shadow（仅 off-graph）

黑、opacity 0.28；相对 arrow 偏移 (+3.2, +2.1) view。[已确认]

---

## 10. Hit-test

### 10.1 Body（arrow）`[已确认]` `RootVectorNode.updateVector`

```
mouseArea = arrowShape.getOffsetShape(VECTOR_MOUSE_AREA_DILATION=3)
touchArea = arrowShape.getOffsetShape(VECTOR_TOUCH_AREA_DILATION=3)
```

### 10.2 Tip `[已确认]` `VectorTipNode`

- 不可见 Path（dev 时红描边）；形状：指向局部 +x 的三角头，再 `rotation = -xy.angle`，`translation = modelToViewDelta(xy)`。
- Dilation：mouse **6** / touch **8**。
- 短向量（`|xy| ≤ 3`）：中/小 tip hit 区，避免挡住 tail grab；头被 fractional 缩放时用 `SMALL_HEAD_SCALE=0.65`。

### 10.3 图背景

`GraphNode` background `down` → `selectedVector = null`（raw down，避免抢 touch-snag）。[已确认]

### 10.4 Toolbox slot

`mouseArea`/`touchArea` = localBounds dilated（Explore 具体 dilation 在子类）。[已确认基类]

### 10.5 动画回 toolbox

`animateToToolbox` → body/tip `pickable=false`。[已确认]

---

## 11. Graph / Panel / Major Anchors

### 11.1 Layout bounds `[已确认]`

- `SCREEN_VIEW_BOUNDS = ScreenView.DEFAULT_LAYOUT_BOUNDS` → **典型 1024×618**（Joist；本仓库未 vendoring joist，数值以运行时/截图校核）`[待确认精确像素，Phase 2 用截图钉]`
- Margins：`SCREEN_VIEW_X_MARGIN=20`, `Y_MARGIN=16`

### 11.2 Graph `[已确认]`

| 项 | 值 |
|---|---|
| DEFAULT_GRAPH_BOUNDS | `(-5,-5)-(45,25)` · w=50 h=30（须偶数） |
| Explore1D | origin 居中 ±25 / ±15 |
| MODEL_TO_VIEW_SCALE | **14.5** |
| view 宽高 | 50×14.5=**725** · 30×14.5=**435** |
| DEFAULT_BOTTOM_LEFT | `(minX+20+10, maxY−15−45)` ≈ **(30, 558)** @ 1024×618 |
| MVT | `createRectangleInvertedYMapping(modelBounds, viewBounds)` |
| Origin drag | `moveOriginToPoint` → bounds shift，坐标**对称圆整** |
| Major grid | 每 **5** model units · lineWidth 1.5 |
| Minor grid | 每 **1** · lineWidth 1 |
| Tick labels | 每 **10** model units |
| Axes | orientation 决定画 X/Y；双头 ArrowNode |

### 11.3 控件锚点（Explore2D 原型）`[已确认]`

| 控件 | 锚点 |
|---|---|
| GraphControlPanel | `right = layout.right−20`, `top = layout.top+16` |
| Scene radio | `left = panel.left`, `bottom = resetAll.bottom` |
| VectorToolbox | `left = radio.left`, `bottom = radio.top − 15` |
| VectorValues accordion | `centerX = graph.viewBounds.centerX`, `top = 35` |
| Eraser | `right = graph.viewBounds.maxX`, `top = graph.viewBounds.maxY + 15` |
| ResetAll | `right = layout.maxX−20`, `bottom = layout.maxY−16` |

Lab：双 vector set → 双 sum checkbox / 双色板；每 set 10 向量（`LAB_VECTORS_PER_VECTOR_SET=10`）。

### 11.4 ViewProperties 默认 `[已确认]`

| Property | Default |
|---|---|
| valuesVisible | false |
| anglesVisible | false（Explore1D 不 instrument UI） |
| gridVisible | **true** |
| vectorValuesAccordionBoxExpanded | **true** |
| sumVisible (Explore) | **false** |
| componentVectorStyle | **invisible** |

---

## 12. Responsive Layout

- PhET 使用固定 `layoutBounds` + Joist 缩放适配视口；**不是** Flutter 流式 reflow。[已确认]
- KARTOSLAB：**页面级 NineGrid**；中间格放入整个 PhET ScreenView 局部坐标系（等比缩放/letterbox）。[工程约束]
- **不为截图写死 pixel**；锚点用相对 `layoutBounds` / `graph.viewBounds` 的关系复刻。[工程约束]
- 矮视口：遵循既有 NineGrid footer/边格压缩规则；不改 common API。[工程约束]

---

## 13. Reset / Lifecycle

| API | 行为 | 标记 |
|---|---|---|
| `VectorAdditionModel.reset` | componentStyle + 各 scene.reset + sceneProperty | [已确认] |
| `VectorAdditionScene.reset` | graph + selected + 各 vectorSet.reset | [已确认] |
| `scene.erase` | selected + vectorSet.erase（不清 origin/scene） | [已确认] |
| `Vector.reset` | super + 停动画 + isOnGraph + animateToToolbox | [已确认] |
| `returnToToolbox` | 移出 activeVectors + reset + 清选中 | [已确认] |
| `animateToPoint` | twixt Animation · speed **75** model-units/s · LINEAR · 同时动画 tail 与 xy | [已确认] |
| ViewProperties.reset | values/angles/grid/accordion（+ sumVisible） | [已确认] |
| Screen 切换 | 各 Screen 独立 Model；Joist 保活 | [已确认] |
| Scene 切换 | `interruptSubtreeInput`；sceneNode `visibleProperty` | [已确认] |
| 向量实例 | **启动时全部创建**，生命周期 = sim；view Node 动态 create/dispose | [已确认 notes] |

无物理主循环 Clock；仅短动画。[已确认]

---

## 14. Assets

| 路径 | 用途 |
|---|---|
| `assets/vector-addition-screenshot-screen{1..4}.png` | 四屏参考（Explore1D/2D/Lab/Equations） |
| `assets/vector-addition-screenshot*.png` + alt* | 额外参考 |
| Runtime SVG/PNG 业务贴图 | **无**；箭头/图标矢量绘制 |

颜色：`VectorAdditionColors` ProfileColorProperty 分屏分 scene 色板（vectorFill / sumFill 等）。Phase 2 从截图 + colors 文件提取，不用 mean RGB 作为唯一指标。

---

## 15. 完整测试报告清单（Phase 1 门禁）

| # | 主题 | 证据完整？ | 缺口 |
|---|---|---|---|
| 1 | Snap invariants | ✅ | — |
| 2 | Drag whole/tip/tail | ✅ | — |
| 3 | isOnGraph | ✅ | — |
| 4 | Resultant 移动/锁定 | ✅ | — |
| 5 | Component 4 styles | ✅ | projection offset 数值表 → Phase 4 对照 VectorSet 初始化 |
| 6 | Equations 三方程 | ✅ | — |
| 7 | Arrow geometry | ✅ | ArrowNode 动态头精确算法在 scenery-phet（未 vendoring）→ Phase 2/4 视觉+单测 |
| 8 | Hit-test | ✅ | — |
| 9 | Graph/panel anchors | ✅ | layoutBounds 精确 1024×618 → Phase 2 截图确认 |
| 10 | Responsive | ✅（策略） | Flutter NineGrid 映射在 Architecture |
| 11 | Reset/lifecycle | ✅ | — |
| 12 | Assets | ✅ | — |
| — | angle 顺/逆时针 | ⚠️ | Phase 4 单测钉死 |
| — | Home A | ✅ | 用户已确认 |

**门禁结论：Phase 1 PASS → 默认进入 Phase 2。**

无 BLOCKED 数学缺口；不使用教材替换任何 solver。

---

## 16. 迁移禁令（重申）

1. 不得把 `tip` 设为 canonical state。  
2. 不得自创 parallelogram/head-to-tail「构造模式」（component style ≠ 构造器）。  
3. Equations 必须用 `addition` / `subtraction` / `negation` 源码分支。  
4. Sum 必须过滤 `isOnGraph`。  
5. Y 翻转只进 `MathCoordinateTransform`。  
6. 不修改 common / 其他 sim / Home taxonomy 结构（仅在力学下加卡）。

---

*Phase 1 · 2026-09-04 · 本地 `1.3.0-dev.0`*
