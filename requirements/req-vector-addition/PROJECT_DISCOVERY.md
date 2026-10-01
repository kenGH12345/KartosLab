# Phase 0 — Project Discovery · Vector Addition

> 需求：`req-vector-addition`  
> 日期：2026-09-04  
> 阶段：Phase 0（Discovery）  
> 标记：`[已确认]` 有源码/配置/目录依据 · `[推测]` 有依据的推断 · `[待确认]` 证据不足

---

## 0. 结论摘要

1. **本地版本锁定**：`package.json` → **`1.3.0-dev.0`**；`dependencies.json` 注释为 `1.2.0-dev.11`（2025-11-25）。**以 package.json 为准**，不因官网 latest / GitHub main 替换本地。[已确认]
2. **本包无内嵌 `.git`**，无法 `git rev-parse HEAD`；版本事实以 `package.json` + `dependencies.json` 记录为准。[已确认]
3. **四个 joist Screen**（注册顺序 = 默认首屏）：`Explore1DScreen` → `Explore2DScreen` → `LabScreen` → `EquationsScreen`。[已确认 `js/vector-addition-main.ts:26-30`]
4. **各 Screen 独立 `createModel()`，不跨屏共享 Model**；Reset 在 Screen Model 内（`VectorAdditionModel.reset`）。[已确认]
5. **Vector ground truth（canonical）**：`xyComponentsProperty` + `tailPositionProperty`；**derived**：`tip = tail + xyComponents`、`magnitude`、`angle`。[已确认 `RootVector.ts:76-85,131-137`]
6. **Sum（Explore1D/2D/Lab）**：仅累加 **`isOnGraph === true`** 的向量的 `xyComponents`；Resultant **可平移、不可 tip-drag**。[已确认 `SumVector.ts:55-68` + `ResultantVector.ts`]
7. **Equations 屏的 Resultant** 由方程类型推导（`a+b=c` / `a-b=c` / `a+b+c=0`），**不是**简单 Σ；属于本 sim 第 4 屏，**不是**独立产品 `vector-addition-equations`。[已确认 `doc/model.md` + credits 注释]
8. **坐标系**：model **+y 向上**；view（Scenery/Flutter canvas）**+y 向下**；源码用 `ModelViewTransform2.createRectangleInvertedYMapping`；`MODEL_TO_VIEW_SCALE = 14.5`。[已确认 `Graph.ts:22,89-91` + `doc/implementation-notes.md`]
9. **推荐落点**：`lib/vector_addition/`（与 `collision_lab/` 同级）。工程内 **无** 既有实现。[已确认]
10. **Home 归类**：[待确认] 当前仅有「物理 / 化学」，无「数学」。需用户选定（见 §6）。

---

## 1. 本地源码版本（唯一第一事实来源）

| 项 | 值 | 标记 |
|---|---|---|
| 路径 | `phet sourses/vector-addition-main/vector-addition-main` | [已确认] |
| `package.json` name | `vector-addition` | [已确认] |
| `package.json` version | **`1.3.0-dev.0`** | [已确认] |
| `dependencies.json` comment | `vector-addition 1.2.0-dev.11 Tue Nov 25 2025` | [已确认] |
| Git HEAD | 无内嵌 `.git` | [已确认] |
| 官方 URL（仅对照，不替换） | https://phet.colorado.edu/sims/html/vector-addition/latest/vector-addition_all.html | — |
| 独立产品 | `vector-addition-equations` **不在**本次本地源树；本仓库 `phet sourses` 仅有 `vector-addition-main` | [已确认] |

**冻结策略**：后续所有取证/实现以该本地目录为准；发现与官网行为差异时，记录差异并询问，**不自动升级源码**。

---

## 2. Screen 清单（禁止假定）

### 2.1 数量 / 名称 / 顺序 / 默认

| # | 类 | 字符串 key | 显示名 | 默认？ |
|---|---|---|---|---|
| 0 | `Explore1DScreen` | `screen.explore1D` | Explore 1D | **是**（`screens[0]`） |
| 1 | `Explore2DScreen` | `screen.explore2D` | Explore 2D | 否 |
| 2 | `LabScreen` | `screen.lab` | Lab | 否 |
| 3 | `EquationsScreen` | `screen.equations` | Equations | 否 |

证据：`js/vector-addition-main.ts:26-30`；`package.json` → `phet.screenNameKeys`；`vector-addition-strings_en.json`。

### 2.2 Model ownership / shared state / reset / lifecycle

| 项 | 事实 | 标记 |
|---|---|---|
| Model ownership | 每 Screen `() => new XxxModel(...)` | [已确认] |
| 跨 Screen 共享 Model | **无** | [已确认] |
| 跨 Scene 共享 | Screen 内 `scenes[]` + `sceneProperty`；默认 `scenes[0]` | [已确认 `VectorAdditionModel.ts`] |
| 全局 Preferences | `VectorAdditionPreferences.instance`（含 `angleConventionProperty`）跨屏 | [已确认] |
| Reset | `VectorAdditionModel.reset` → style + 各 scene + sceneProperty | [已确认] |
| Navigation | Joist `Sim` 多 Screen；Flutter 侧拟用 `KratosTabbedScreen`（Collision Lab 先例） | [推测] |

### 2.3 各 Screen 内部 Scene

| Screen | Scenes（顺序，默认 [0]） | 要点 |
|---|---|---|
| Explore 1D | Horizontal → Vertical | 1D 约束；无 component / angle UI |
| Explore 2D | Cartesian → Polar | 1 vector set；component styles |
| Lab | Cartesian → Polar | **2** vector sets；每 set 最多 10 向量 |
| Equations | Cartesian → Polar | 预置向量；系数/基向量 spinner；方程类型 |

### 2.4 与 `vector-addition-equations` 的边界

| | `vector-addition`（本次） | `vector-addition-equations`（不做） |
|---|---|---|
| 产品 | 完整 4 屏 sim | **另一独立** PhET 产品 |
| Equations | **第 4 屏**（本包内） | 可能是 Equations-only 变体 |
| Credits | 源码注明 credits 与 equations 变体共享 | — |

**结论**：迁移本包全部 4 屏（含 Equations）；**不**去拉/实现独立 `vector-addition-equations` 仓库。[已确认意图 + 源码结构]

---

## 3. Vector Model（canonical vs derived）

### 3.1 类层次（源码）

```
RootVector (abstract)
  Vector (interactive)
    ResultantVector
      SumVector                    // Explore1D/2D/Lab
      EquationsResultantVector     // Equations
    BaseVector / EquationsVector   // Equations
  ComponentVector (non-interactive)
```

证据：`doc/implementation-notes.md` + `js/common/model/*.ts`。

### 3.2 Ground truth

| 字段 | 角色 | 标记 |
|---|---|---|
| `tailPositionProperty: Vector2` | **canonical** | [已确认] |
| `xyComponentsProperty: Vector2` | **canonical**（dx, dy） | [已确认] |
| `tipPositionProperty` | **derived** = `tail + xyComponents` | [已确认] |
| `magnitude` | **derived** = `xyComponents.magnitude` | [已确认] |
| `angle` (radians) | **derived**；零模长 → `null`；来自 `Vector2.angle` | [已确认] |
| `angleDegrees` | **derived**；经 `AngleConvention`（signed/unsigned） | [已确认] |
| `xComponent` / `yComponent` | 标量，来自 xyComponents | [已确认] |
| `symbolProperty` / color palette | 标签与渲染元数据 | [已确认] |
| `isOnGraphProperty` | 是否在图上（影响 sum） | [已确认] |
| `isTipDraggable` / `isRemovableFromGraph` | 交互能力标志 | [已确认] |
| `selected` | 由 Scene 级 `selectedVectorProperty` 持有，非 Vector 内字段 | [已确认] |
| `pinned / fixed` | **无**此命名；Resultant 用 `isTipDraggable:false` + `isRemovableFromGraph:false` | [已确认] |

源码原文（`RootVector.ts`）：

> `xyComponentsProperty` and `tailPositionProperty` are the **"ground truth"** from which other values are derived.

**禁止**改用「position + magnitude + angle」作为 canonical，除非 Equations 的 `PolarBaseVector` 等子类在 spinner 路径另有可变入口——那是 **写入路径**，最终仍落到 RootVector ground truth。[推测：需 Phase 1 对 BaseVector 再取证]

### 3.3 角度约定（风险点）

- `RootVector.get angle` 注释写 “measured **clockwise** from the horizontal”。[已确认注释存在]
- 实际返回 `this.xyComponents.angle`（PhET `dot.Vector2.angle`，通常为 **atan2，逆时针从 +x**）。[待确认：注释 vs 实现是否笔误；Phase 1 必须用运行时/单测钉死符号]
- Preferences：`signed` ∈ [-180,180) · `unsigned` ∈ (0,360]。[已确认 `AngleConvention.ts`]

---

## 4. Vector Addition / Resultant

### 4.1 Explore 1D / 2D / Lab → `SumVector`

```
sum = Σ vector.xyComponents  for all vector in allVectors where isOnGraph === true
```

- Resultant **tail** 可拖（平移整条 resultant）；**tip 不可拖**。
- `isDefinedProperty`：至少一个 on-graph 向量时为 true。
- Lab：每 vector set 一个 sum（如 `s_v`）。

[已确认 `SumVector.ts` + `ResultantVector.ts` + `doc/model.md`]

### 4.2 Equations → 非简单 Σ

| 方程类型 | 关系（Cartesian 例） |
|---|---|
| addition | `a + b = c` |
| subtraction | `a - b = c` |
| negation | `a + b + c = 0` |

Polar 场景对 `d,e,f` 同构。含 **系数** 与 **base vectors**。[已确认 `doc/model.md`]

### 4.3 Component vectors（非标量）

Styles（默认 `invisible`）：

| Style | 语义 |
|---|---|
| `invisible` | 不显示 |
| `triangle` | 直角三角形摆放 |
| `parallelogram` | 共尾平行四边形 |
| `projection` | 投影到轴上（含 offset） |

[已确认 `ComponentVectorStyle.ts` + `ComponentVector.updateComponent`]

### 4.4 非本 sim 的“教材加法”

以下 **不是** 本包 Explore/Lab 的 UI 构造模式名称（源码用语是 toolbox → graph + sum checkbox）：

- 显式 “head-to-tail construction tool” / “parallelogram construction tool” 作为独立交互模式 → **未在 model 层发现**。[已确认：无对应枚举；parallelogram 仅指 **component style**]

用户拖向量首尾对齐是交互结果，不是单独 solver 模式。[推测]

---

## 5. Graph / Coordinate Transform

| 项 | 值 | 标记 |
|---|---|---|
| 默认 model bounds | `Bounds2(-5, -5, 45, 25)` → width 50, height 30 | [已确认] |
| Explore1D 特例 | origin 居中：`±width/2, ±height/2` | [已确认 `Explore1DModel.ts`] |
| View scale | `MODEL_TO_VIEW_SCALE = 14.5` | [已确认 `Graph.ts`] |
| View bounds | 由 `bottomLeft` + scale × model size 计算；**view Y 向下** | [已确认] |
| MVT | `createRectangleInvertedYMapping(modelBounds, viewBounds)` | [已确认] |
| Origin 拖动 | `moveOriginToPoint` → `bounds.shiftedXY(-x,-y)`，整数圆整 | [已确认] |
| Model 轴向向 | **x→右，y→上** | [已确认 notes] |
| Flutter 要求 | **集中** `MathCoordinateTransform`；禁止 Painter 散落 `-height` / `h-y` | [工程约束] |

Polar snap：`POLAR_ANGLE_INTERVAL = 5°`；Cartesian：分量整数 snap。[已确认 constants + model.md]

---

## 6. 当前 KARTOSLAB 工程

| 项 | 值 |
|---|---|
| 包名 | `kratos` · SDK `^3.11.1` |
| 入口 | `lib/main.dart` → `HomeScreen` |
| 已有近邻范式 | `collision_lab/`（多 Screen + Tab + NineGrid + 局部坐标） |
| 本 sim 目录 | **无** `vector_addition*` |
| Home 入口 | **无** |
| common 相关 | `NineGridLayout` **复用**；`KratosTabbedScreen` **复用**；`arrow_painter` **评估后**再定（可能语义不够用，sim 内自绘 PhET ArrowNode 几何） |
| MathCoordinateTransform | common **无**现成类 → 落在 `lib/vector_addition/`（第 1 用户） |

### Home 归类选项（需用户选）

| 选项 | 说明 |
|---|---|
| A | **物理 → 力学** 新卡「Vector Addition」（与 Collision Lab 同组） |
| B | **新建一级「数学」** → 向量 / 线性代数 |
| C | **物理 → 光学与波动**（不推荐，语义弱） |

[待确认]

---

## 7. 推荐架构方向（尚未编码 · 仅 Discovery）

```
lib/vector_addition/
  model/
    root_vector.dart          # ground truth: tail + xyComponents
    vector.dart
    sum_vector.dart
    resultant_vector.dart
    component_vector.dart
    graph.dart
    vector_set.dart
    math_coordinate_transform.dart   # 唯一 model↔view
  screens/  explore1d / explore2d / lab / equations
  widgets/  painters（Arrow 几何按 PhET，不用 Material Icon）
```

分层：State / VectorModel / Sum / InteractionController / RenderData / Painter / Widget。  
页面壳：NineGrid；图内：局部 model 坐标。

---

## 8. 动画 / Clock

- Toolbox 回弹：`twixt.Animation`，`ANIMATION_SPEED = 75` model-units/s。[已确认 `Vector.ts`]
- **无** 物理仿真主循环 Clock（与 Collision Lab 不同）；主要为交互驱动 + 短动画。[已确认]

---

## 9. 资源

- `assets/`：参考截图（screen1–4 等），**非** runtime 业务贴图。
- UI 箭头 / 图标：scenery 矢量绘制（`ArrowNode` / `VectorAdditionIconFactory`）。
- Flutter：**禁止** Material Icon 冒充；需移植箭头几何。

---

## 10. Phase 0 阻塞项

| ID | 项 | 状态 |
|---|---|---|
| B1 | Home 学科归类 A/B/C | **待用户确认** |
| B2 | `RootVector.angle` 注释 “clockwise” vs `Vector2.angle` 实际方向 | Phase 1 钉死（不阻塞 Discovery 结束） |
| B3 | Equations BaseVector 写入路径细节 | Phase 1 SOURCE_ANALYSIS |

无数学公式缺口 → **不需要**用教材补模型。

---

## 11. 建议下一步

1. 用户确认 **Home 归类**（A/B/C）。
2. 进入 **Phase 1 · SOURCE_ANALYSIS**：按 Screen 深挖 snap / drag invariants / Equations 方程求解 / 箭头几何常量 / 布局锚点。
3. 同步建立 `visual-qa/ref/` 基线截图（本地 assets 四屏）。

---

*Phase 0 · 2026-09-04 · 本地源 `1.3.0-dev.0`*
