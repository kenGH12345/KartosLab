# MAGNET M5-4-FIX · FieldMeter 初始映射 + Reset 边格适配

> 日期：2026-08-31  
> 范围：**只处理** FieldMeter **初始 Position / mapping**，以及 Reset 在 `NineGrid.bottomRight` **内部**的局部视觉适配  
> 未改：`MagneticField.compute` / FieldMeter 渲染 / 拖拽语义 / Magnet / Compass / ControlPanel / NineGridLayout / Theme / Home / Earth

对照：A `phet/magnet_and_compass/lib/main.dart` `SimulationPage`

---

## 0. 结论

FieldMeter 原版初始是 **独立 screen fraction**（方案 **A**），不是相对 magnet 的 offset，也不是固定 world px。[已确认]

```text
fieldMeterPos = Offset(s.width * 0.28, s.height * 0.30)
s = MediaQuery.size   // 原版 canvas = 满窗
```

Flutter 现与 magnet / compass 同一套 **窗口分数 → NineGrid center 平移**（非缩放、非写死 px）。

Pixel Tablet 1280×800：

| | 修前（canvas 分数） | 修后（窗口分数平移） | 原版 |
|---|---|---|---|
| Meter 窗口中心 | ≈ (404, 296) | **(358.4, 240)** | (358.4, 240) |
| Magnet − Meter | ≈ (133, 105) | **(179.2, 160)** | (179.2, 160) |

Reset **仍在 `bottomRight`**。去掉 `Center + Padding(8)` 的裁高；边格够高时贴右下，inset 尽量 18；边格 &lt; 52 时 `FittedBox` 完整显示圆。[已确认]

---

## 1. 原版取证（FieldMeter 初始）

| 问题 | 结论 | 证据 |
|---|---|---|
| 初始值 | `(0.28W, 0.30H)` | `_initPositions` / `_reset` |
| 与 magnet 关系 | **独立分数**。magnet 是 `(0.42W, 0.50H)`。向量 = `(0.14W, 0.20H)`，随窗口变，**不是**固定 (179, 160) px | 两行并列的 `Offset(s.width * …)` |
| canvas / screen | **同一空间**：canvas = 满窗 | 无 LAYOUT_BOUNDS / 无 scale |
| resize 是否重算 | **init 一次**（`_initialized`）。Reset 用**当时** `MediaQuery.size` 重算 | `_initPositions` early-return；`_reset` 读新 `s` |
| 是否固定比例 | **是**：窗口宽高分数。1280×800 恰好得到 (179.2, 160) | `0.14*1280=179.2`，`0.20*800=160` |
| clamp | 中心夹在 canvas 半板内：`[130, W−130] × [96, H−96]` | `onPanUpdate`；init **不**单独 clamp，但点若出界会在首次拖时夹住 |
| 采样点 | 面板中心 = `fieldMeterPos` | `MagneticField.compute(_state.fieldMeterPos, …)` |
| 手势 | 仅 `onPanUpdate` + clamp | 未改 |

判定：**A. 独立 screen fraction**。禁止 `fieldMeterX/Y = N px`。

1280×800 算术：meter (358.4, 240)，magnet (537.6, 400)，差 **(179.2, 160)**。

---

## 2. Flutter FieldMeter 映射

保持：center Stack · center-local · `onPanUpdate` · clamp · `MagneticField.compute`。

只改 `MagnetCanvasMapping`：

- `fieldMeterWindowFrac = (0.28, 0.30)`（与原版同一分数）
- `fieldMeterCanvasPos = clampFieldMeter(windowToCanvas(windowPos))`
- 半板尺寸 260×192 只用于 clamp，**未改** `field_meter.dart` 字面量

Screen 的 init / Reset 本来就读 `m.fieldMeterCanvasPos`，映射一换即生效。

平移不缩放 → 未 clamp 时 **Magnet − Meter 窗口向量 = 原版窗口向量**。

### 1280×800

未 clamp。窗口中心与向量与原版一致。[已确认 单测 + widget]

### 1024×768

同一分数：向量 `(0.14×1024, 0.20×768) = (143.36, 153.6)`。未 clamp。[已确认]

### 640×360

分数点落到 center 外（尤其 Y）。`clampFieldMeter` 把测点留在 canvas 内。向量 **不再**等于 `(0.14W, 0.20H)` —— 与 magnet 在小屏 clamp 同类，属固定 px + NineGrid 的已知代价。[已确认 单测]

ControlPanel 高 298 &gt; center 220，Field Meter 勾选在屏外，widget 层无法点开测点；不在本阶段修面板。[已确认]

---

## 3. Reset 局部适配（仍 bottomRight）

原版：满屏 `Positioned(right: 18, bottom: 18)`，52×52 `#e65100`。

修前：`Center + Padding(all: 8)` + 52 → 边格高 ≈61.7 时装不下 68，量到高 **45.7**。

修后（不改 NineGrid、不进 center）：

| 视口 | 边格 | inset | 圆 |
|---|---|---|---|
| 1280×800 | 宽够、高 ≈61.7 | right **18**；bottom `min(18, cell−52)` ≈ **9.7** | **完整 52×52** |
| 1024×768 | 高 ≈59 | 同公式，底 inset 略小于 18 | **完整 52×52** |
| 640×360 | `minSideH=48` &lt; 52 | inset 0 + `FittedBox` | 完整显示，略缩小 |

分类：槽位仍 `[有意差异：NineGrid]`；1280 高度裁切已消除 `[视觉已对齐]` 圆尺寸。底 inset 18 在边格高度不够时让给圆，无法同时满足原版 bottom=18 与完整 52。[已确认]

---

## 4. 测试

```text
flutter test test/magnetism
flutter analyze lib/magnetism/magnet_and_compass test/magnetism
flutter test test/chemistry/build_a_nucleus
```

- `magnet_canvas_mapping_test`：窗口分数；(179.2, 160)；Pixel Tablet 不 clamp；1024 比例向量；640 clamp
- `magnet_screen_test` Pixel Tablet：Checkbox.at(4) 打开 Field Meter；`magnet.center − meter.center ≈ (179.2, 160)`；Reset 圆 52×52
- 1024 widget：同一窗口分数；640 widget：Reset 完整可见（测点 clamp 走 mapping 单测）

未改 `test/chemistry/build_a_nucleus`。回归计数应仍为 **407**。

---

## 5. 分类

| 项 | 标签 |
|---|---|
| 原版 FieldMeter 初始 = 独立 screen fraction 0.28/0.30 | `[已确认]` |
| 1280 Magnet−Meter 向量 (179.2, 160) | `[视觉已对齐]` |
| 1024 / 未 clamp 视口走同一窗口比例 | `[已确认]` |
| 640 clamp | `[有意差异：NineGrid]` + 固定物体尺寸 |
| Meter 仍在 center Stack，采样/拖拽未改 | `[已确认]` |
| Reset 仍 bottomRight | `[有意差异：NineGrid]` 槽位 |
| Reset 1280 圆完整 52px | `[视觉已对齐]` 尺寸；底 inset &lt; 18 `[有意差异：NineGrid]` |
| Earth | `[无法验证：missing earth.svg]` |

---

## 6. 明确没做

- 未改 FieldMeter 外观 / `MagneticField` / 拖拽
- 未把 Meter 或 Reset 换 parent
- 未写死 `fieldMeterX/Y = N px`
- 未接 Home、未删 Legacy、未造 earth.svg
