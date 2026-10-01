# MAGNET M5-4-AUDIT · FieldMeter + Reset

> 日期：2026-08-31  
> 阶段：**READ-ONLY**。0 实现修改。  
> 对照：A `phet/magnet_and_compass/lib/main.dart` · B `simulations/magnet_and_compass.dart` · target `lib/magnetism/magnet_and_compass/`  
> 量测：Pixel Tablet 1280×800（`m5-3/rects.json` / M5-1 matrix）；九宫格算术用于 1024 / 640。

本阶段禁止改 State / MagneticField / Magnet / Compass / ControlPanel / NineGrid / Theme / Home / Earth。

---

## 0. 结论（先看这里）

| 元件 | 原版语义 | Flutter 现状 | 建议 |
|---|---|---|---|
| **FieldMeter** | 可拖 **测点** · 与 magnet 同一坐标系 · `MagneticField.compute(fieldMeterPos, …)` · 默认隐藏 | **center Stack 内** · center-local · **不是** screen 固定点 · **不是** NineGrid 边格 | **A · 留在 center Stack** |
| **Reset** | 页面 chrome · 满屏 `Positioned(right:18, bottom:18)` · 52×52 橙圆 · 不参与场计算 | `NineGrid.bottomRight` · 视觉同款 · 边格裁高 | **A · 继续 bottomRight** |

FieldMeter 的 C（center + local overlay）与 A **结构相同**：已经是 center `Stack` 里的 `Positioned` 覆盖层。  
B（独立 NineGrid 槽）会毁掉「拖到场点采样」语义，边格也装不下 260×192。[已确认]

Reset 的 B（center 内 overlay）更接近原版相对 play area 的 inset，但 Reset **不是测点**，52px 宽进得了边格；继续 bottomRight 符合 KARTOSLAB 页面级操作进边格。高度裁切是边格几何，属 `[有意差异：NineGrid]`，本审计不修。

---

## 1. FieldMeter 原版几何

A `_buildFieldMeter` 与 B 同构。[已确认]

| 项 | 值 |
|---|---|
| 默认 | `showFieldMeter: false`（勾选才出现） |
| 尺寸 | **260 × 192** 硬编码 |
| Anchor | **面板中心** = `fieldMeterPos` |
| 初始 | `(0.28W, 0.30H)` 的 **当时 canvas**；原版 canvas = 满窗 `MediaQuery.size` |
| Pixel Tablet 中心 | `(358.4, 240)` · 左上 `(228.4, 144)` |
| Parent | 与 magnet / compass / 场箭头 **同一个满屏 Stack** |
| 是否随 canvas 移动 | 位置存在 state 里；canvas 即窗口，没有第二套坐标系 |
| 是否固定在 screen | **否**。可拖；不是 `top/right` chrome |
| 是否可拖测点 | **是**。整块面板是探针 |
| 与 magnet / compass | **同一像素空间**；`compute(p=fieldMeterPos, magnetPos, …)` |
| 采样点 | **面板中心**，不是 `gps_fixed` 图标（图标只是装饰，在卡片底部） |
| ScreenView | **无**。不是 Java PhET `ScreenView`；属于 Flutter `SimulationPage` body |

原版 **没有**独立 probe 与面板分离：拖面板 = 移采样点。

---

## 2. Flutter 当前几何

| 项 | 值 | 判定 |
|---|---|---|
| Parent | `NineGrid.center` → `LayoutBuilder` → `Stack` → `if (showFieldMeter) FieldMeter` | **simulation Stack 内** [已确认] |
| 坐标 | `MagnetState.fieldMeterPos` + `Positioned(left: cx−130, top: cy−96)` | **center-local** [已确认] |
| `screenSize` 实参 | center `LayoutBuilder` size，**不是** `MediaQuery` | 非固定 screen [已确认] |
| NineGrid 槽 | 无独立 slot | [已确认] |
| 尺寸 | 仍 260×192 | `[视觉已对齐]` 尺寸 |
| 初始 | `canvasW×0.28, canvasH×0.30`（**未**走 M5-2 窗口平移） | `[源码一致但布局不同]` |
| Pixel Tablet 中心 | 窗口 `(404.4, 295.5)` · canvas-local `(299.9, 189.8)` | 相对原版 Δ **(+46.0, +55.5)** |
| 默认隐藏 | `showFieldMeter: false` | 与原版同 |

M5-2 故意只映射 magnet / compass。FieldMeter 仍用 **center 分数**，因此：

- 与 magnet 的像素向量 ≠ 原版  
- 默认测点处的 `B` **数值会与 Pixel Tablet 原版不同**（公式未改，输入点距磁铁更近）

| | 原版窗口 | Flutter 窗口（M5-3 实测） |
|---|---|---|
| Meter 中心 | (358.4, 240.0) | (404.4, 295.5) |
| Magnet 中心 | (537.6, 400.0) | (537.6, 400.0) |
| Meter→Magnet 向量 | **(179.2, 160.0)** | **(133.2, 104.5)** |

若下一阶段用与 magnet 相同的 `windowToCanvas(0.28W, 0.30H)`，窗口中心会对回 `(358.4, 240)`，向量恢复。本审计 **不实施**。[待确认] 实施阶段是否做。

---

## 3. FieldMeter 拖拽 / 采样

原版与 Flutter **同一套手势**（A/B/target）：

| 阶段 | 实现 |
|---|---|
| pointer down | `GestureDetector` 默认 pan 竞争；**无**显式 `onPanDown` / `onPanStart` |
| move | `onPanUpdate`：`fieldMeterPos += delta` |
| release | 手势结束；**无** `onPanEnd` 钩子（松手即停） |
| clamp | 中心夹在 `[w/2, canvasW−w/2] × [h/2, canvasH−h/2]`（半板 130×96） |
| sampling | **每个 build**：`MagneticField.compute(state.fieldMeterPos, state.magnetPos, …)` |

拖 magnet、不拖 meter 时，meter 停在原地，读数随场变。这是探针语义。[已确认]

`behavior: HitTestBehavior.opaque`：点在 260×192 整板上都能拖。

未改、也不应改 `MagneticField.compute()`。

缺口（记录，不修）：没有单独的 down/up 视觉态；与原版一致。

---

## 4. Reset 原版几何

A `SimulationPage` 与 B `MagnetAndCompassPage` 同为满屏 Stack 右下 chrome。[已确认]

| 项 | 值 |
|---|---|
| 控件 | `GestureDetector` + `Container` 52×52 圆 · `#e65100` · `Icons.refresh` 28 白 |
| Anchor | **窗口右下** `Positioned(right: 18, bottom: 18)` |
| Pixel Tablet | 左上 **(1210, 730)** · 中心 (1236, 756) · 完整 52×52 |
| 是否 ScreenView | **否**（无 Java ScreenView） |
| 是否随 canvas / 磁铁动 | **否**。纯页面 Reset |
| 语义 | `_reset()`：位置回到分数默认、strength 0.75、开关默认、罗盘角速度清零 |

B 另有左上 44 圆返回；A 无。Flutter 用 AppBar，返回不在本审计。

---

## 5. Reset Flutter 当前几何

| 项 | 值 |
|---|---|
| Parent | `NineGridLayout(bottomRight: …)` |
| 内部 | `Center` + `Padding(all: 8)` + **同一** 52×52 橙圆 + refresh 28 |
| 为什么在这 | M4-2：Reset 是 **页面级操作**，52px 宽可进 ~105px 边格；实验物体留在 center |
| Pixel Tablet 实测 | **(1201.7, 746.3) 52×45.7** |

差异来源：[已确认]

```
原版：相对窗口 bottom/right = 18
Flutter：边格居中 + padding 8

1280×800 body 756 · sideH ≈ 61.7
52 + 8+8 = 68 > 61.7  → 量到高度 45.7（底部被裁）
```

| | Δx | Δy | Δw | Δh |
|---|---:|---:|---:|---:|
| Reset vs 原版 | −8.3 | +16.3 | 0 | −6.3 |

分类：`[有意差异：NineGrid]`。按钮语义（点一下 reset）未变。

---

## 6. Layout mapping

| Element | Original | Flutter | Difference | Parent |
|---|---|---|---|---|
| FieldMeter | 满屏 Stack · 中心 (0.28W, 0.30H) 窗口 · 260×192 · 可拖测点 | center Stack · 中心 (0.28, 0.30) **canvas** · 260×192 · 可拖 | 尺寸 0；窗口中心 Δ(+46.0,+55.5)；向量被 canvas 分数压扁 | 实验 Stack（原版=窗口，Flutter=NineGrid center） |
| Reset | 满屏 `right:18, bottom:18` · 52×52 | `bottomRight` 居中+pad 8 · 量到 52×45.7 | chrome 槽位 + 边格裁高 | 原版实验 Stack 兄弟；Flutter NineGrid 边格 |

---

## 7. NineGrid 建议（本审计的决定）

### FieldMeter → **A. 留在 center Stack**

| 准则 | 理由 |
|---|---|
| 原版语义 | 测点必须与 magnet **同一 canvas 空间**；拖到箭头网格上的点 |
| NineGrid | 边格 1280 约 **105×62**，260×192 **装不下**；也不是贴边 chrome |
| 交互 | clamp / `compute` 都相对 canvas；放边格会变成固定 HUD，失去探针 |

**B 独立 NineGrid：否。**  
**C center + local overlay：即现状 A**（`Positioned` 已在 center Stack）。不必再套一层 Overlay。

后续若做 Visual Fix（非本阶段）：只应对齐 **初始映射**（`windowToCanvas`），不要换 parent。

### Reset → **A. 继续 bottomRight**

| 准则 | 理由 |
|---|---|
| 原版语义 | **页面 Reset**，不是场里的物体；不进 `MagneticField` |
| NineGrid | 页面级操作进边格；宽 52 < 边格宽（1280/1024） |
| 交互 | 单击即可；不必叠在磁铁/罗盘上 |

**B center 内 overlay：** 能复原相对 play area 的 `right:18, bottom:18`，并避开边格裁高。但会把 chrome 塞回实验 Stack（ControlPanel 已因 230 太宽成为例外）。Reset **够窄**，应留在边格，与 AppBar「页面壳」一致。

边格高度裁切：若以后要修，只动 bottomRight **内部** padding/对齐，**不要**把 Reset 拖进 center。本审计不修。

---

## 8. Responsive（FieldMeter vs ControlPanel / Magnet）

符号：Meter 260×192 · Panel 230×298 · Magnet 500×128。  
Flutter Meter 初始 = canvas 分数；Magnet = 窗口平移。

### 1280×800 [已确认 量测 + 算术]

| 对 | 重叠？ |
|---|---|
| Meter × ControlPanel | **否**（meter 右 534 < panel 左 933） |
| Meter × Magnet | **是** · y 交叠约 336–391（~55px）；原版是 **底边相切**（meter 底 336 = magnet 顶 336） |
| Meter × Compass | 基本不叠（罗盘中心 768,528） |

重叠加重来自 Meter 仍用 canvas 分数，不来自「放错槽」。

### 1024×768 [已确认 算术]

center ≈ 857×606 @ origin (84, 103)。  
Meter 右 ≈ 370（local）< Panel 左 ≈ 615 → **不挡面板**。  
Meter 与 Magnet 仍有一块交叠（固定尺寸 + 分数初始）。

Reset 边格高 ≈ 59，52+16=68 → **仍略裁高**。

### 640×360 [已确认 算术 · 允许紧张]

`minSideH=48` → centerH=220、centerW≈535。  
Magnet clamp 后几乎铺满宽。Meter 192 高在 220 里很挤；**init 不 clamp**，top 可为负。  
Panel 298 高 **画出 center**。Meter 右与 Panel 左约差十几 px，水平几乎不相交，但二者都压在磁铁上。

**不要为此重排 NineGrid / 把 Meter 送进边格。** 小屏是固定 px 的已知代价。[待确认] 产品是否要单独做小屏策略。

---

## 9. 分类

| 项 | 标签 |
|---|---|
| Meter 在 center Stack、center-local、用 `compute`、可拖、非边格 | `[已确认]` |
| Meter 尺寸 260×192 与原版相同 | `[视觉已对齐]` 尺寸 |
| Meter 初始仍为 canvas 分数 → 窗口 Δ 与向量变了 | `[源码一致但布局不同]` |
| Reset 为页面 chrome、非测点 | `[已确认]` |
| Reset 在 `bottomRight`、视觉同款橙圆 | `[有意差异：NineGrid]` 槽位；`[视觉近似]` 图标 |
| Reset 高被裁到 45.7 | `[有意差异：NineGrid]` |
| 1280 Meter 与 Magnet 重叠多于原版 | `[已确认]` 几何；修映射可接近原版相切 `[待确认]` 是否做 |
| 640 挤叠 | `[待确认]` 产品策略 |
| Earth | `[无法验证：missing earth.svg]` · 与本审计无关 |

无 PhET Java `ScreenView` 可对；本 sim 原版就是 Flutter 满屏 Stack。[已确认]

---

## 10. 明确不建议

- 不要把 FieldMeter 放进 `midLeft` / `topLeft` / footer  
- 不要为 Reset 改 NineGridLayout  
- 不要改 `MagneticField`  
- 不要把 Reset 语义并进 ControlPanel  

---

## 停止

**M5-4-AUDIT 完成。未改任何代码。**

不开始 FieldMeter Visual Fix，不开始 Reset 微调，不接 Home，不删 Legacy。
