# MAGNET M5-1 · First Visual Baseline

> 日期：2026-08-31  
> 阶段：**只建立视觉基线和差异矩阵。0 个实现修改。不进入 Visual Fix。**  
> 原版 reference：`phet/magnet_and_compass/` standalone `SimulationPage`  
> Flutter target：`lib/magnetism/magnet_and_compass/`

本阶段**没有**改 MagneticField / MagnetState / CompassPainter / reset / drag / NineGrid / Theme / Earth 资源。

---

## 0. 结论（先看这里）

原版 **可以运行**（WidgetTester 泵入 `phet/magnet_and_compass/lib/main.dart` 的 `SimulationPage`），已拿到与 Flutter **同一视口**的截图。不是「缺原版运行截图」。

窗口坐标下，P0/P1 没有一行是 `[视觉已对齐]`。原因不是 Painter 画错，而是 M4-2 把 canvas 从满屏改成了 NineGrid 中间格：

- 物体 **硬编码尺寸**仍与原版相同（磁铁 500×128、罗盘 152、磁场计 260×192、面板 230×298）
- 初始中心仍是 **当前 canvas 的同一比例**（0.42/0.50、0.60/0.66、0.28/0.30）
- 因此窗口位置必然漂移；磁铁在更小的 play area 里 **相对更大**

这是 `[源码一致但布局不同]`，不是业务回归，本阶段不修。

---

## 1. 固定环境

| 项 | 值 |
|---|---|
| 设备标签 | **Pixel Tablet landscape**（视口仿真，不是物理平板实机） |
| 宿主 | `flutter_test` WidgetTester |
| physical | 2560 × 1600 |
| DPR | 2.0 |
| logical | **1280 × 800** |
| orientation | landscape |
| viewPadding / padding | 全 0 |
| PNG | 2560 × 1600（`toImage(pixelRatio: 2)`） |

**不要**拿其它分辨率/DPR 的图做像素比较。本目录 overlay/diff 只比较这一对。

| | Original (`SimulationPage`) | Flutter (`MagnetAndCompassScreen`) |
|---|---|---|
| Theme | `ThemeData.dark()`（对齐 phet `MagnetApp`） | KratosApp Material 3 light · seed `#1177AA` |
| Chrome | 无 AppBar、无 NineGrid | AppBar 44px `#1565C0` + NineGrid |
| Play area | = 满窗 canvas 1280×800 | = center slot **1070.9 × 632.5** @ window (104.5, 105.7) |
| 截图模式 | debug（可见 overflow 黄黑条） | 同左 |

Flutter 本次按 `MaterialApp.home` 捕获：路由不能 pop，**AppBar leading 返回箭头未出现**。Home 仍未接入。这不是 Visual Fix 项，只记录。

---

## 2. 坐标系统映射

### Original coordinate system

```
origin  = window 左上 = Scaffold.body 左上
canvas  = window = 1280 × 800
chrome  = 无
play    = canvas
单位    = 1 逻辑 px = 1 MagneticField 单位
```

默认中心（相对 canvas）：

| 元件 | 公式 | 本视口中心 |
|---|---|---|
| magnet | (0.42W, 0.50H) | (537.6, 400.0) |
| compass | (0.60W, 0.66H) | (768.0, 528.0) |
| field meter | (0.28W, 0.30H) | (358.4, 240.0) |
| control panel | `Positioned(top:12, right:12)` 宽 230 | (1038, 12) 左上 |
| reset | `Positioned(right:18, bottom:18)` 52×52 | (1210, 730) 左上 |

### Flutter center slot coordinate system

```
window          = 1280 × 800（含 AppBar）
AppBar          = y=0, h=44
NineGrid body   = (0, 44) 1280 × 756
center / canvas origin in window = (104.5, 105.7)
canvas size     = 1070.9 × 632.5
单位            = 1 canvas 逻辑 px = 1 MagneticField 单位（公式未改）

window = canvas_origin + canvas_local
```

同一比例在更小 canvas 上的中心（canvas-local → window）：

| 元件 | canvas-local 中心 | window 中心 |
|---|---|---|
| magnet | (449.8, 316.3) = 0.42 / 0.50 | (554.3, 422.0) |
| compass | (642.6, 417.5) = 0.60 / 0.66 | (747.1, 523.2) |
| field meter | (299.9, 189.8) = 0.28 / 0.30 | (404.4, 295.5) |
| control panel | 相对 canvas `top:12, right:12` | window (933.5, 117.7) |
| reset | NineGrid `bottomRight`，不在 canvas 坐标系里 | window (1201.7, 746.3) |

**尺寸不随 canvas 缩放**：磁铁 / 罗盘 / 磁场计 / 面板宽度仍是硬编码 px。  
**位置随 canvas 比例走**。这是 M4-2 的直接几何后果。

比例映射（仅对「按 canvas 分数定位」的物体）：

```
x_fl_local = x_orig * (1070.9 / 1280)
y_fl_local = y_orig * (632.5 / 800)
```

该式 **不能**用来缩放磁铁宽高。

---

## 3. 截图清单

全部在 `screenshots/`。

| 文件 | 内容 |
|---|---|
| `original_default.png` | 原版默认（磁场 + 磁铁 + 罗盘 + 面板 + reset） |
| `original_field_meter.png` | 原版打开 Field Meter |
| `flutter_default.png` | Flutter 默认 |
| `flutter_magnet_moved.png` | Flutter 磁铁拖离默认点 |
| `flutter_field_meter.png` | Flutter 打开 Field Meter |
| `flutter_control_panel.png` / `original_control_panel.png` | 面板裁切 |
| `flutter_reset.png` / `original_reset.png` | Reset 裁切 |
| `flutter_compass.png` / `original_compass.png` | 罗盘裁切（默认可观察针向） |
| `flutter_magnet.png` / `original_magnet.png` | 磁铁裁切 |
| `overlay_default.png` | 同视口 50% 叠图 |
| `diff_default.png` | 同视口差图（亮度×3） |
| `overlay_field_meter.png` / `diff_field_meter.png` | Field Meter 状态 |
| `overlay_canvas_normalized.png` / `diff_canvas_normalized.png` | 把 Flutter center 拉伸到原版 canvas 再比（辅助，不是像素验收） |
| `overlay_annotated_rects.png` | 叠图 + 双方 rect 描边 |

Earth：**无截图**。`[无法验证：missing earth.svg]`。未点 Earth 勾选，未生成替代资源。

截图为 **debug** 构建：Slider 行右侧有黄黑 overflow 条。Release 不会画这条，但 **55px overflow 本身仍在**。

---

## 4. Visual Matrix

窗口坐标，单位逻辑 px。完整数字见 `matrix.json`。

| Component | Original Rect | Flutter Rect | Δx | Δy | Δw | Δh | Classification |
|---|---|---|---:|---:|---:|---:|---|
| **P0 simulation canvas** | (0, 0, 1280×800) | (104.5, 105.7, 1070.9×632.5) | 104.5 | 105.7 | −209.1 | −167.5 | `[有意差异：NineGrid]` |
| **P0 magnet** | (287.6, 336.0, 500×128) | (304.3, 358.0, 500×128) | 16.7 | 22.0 | 0 | 0 | `[源码一致但布局不同]` |
| **P0 compass** | (692.0, 452.0, 152×152) | (671.1, 447.2, 152×152) | −20.9 | −4.8 | 0 | 0 | `[源码一致但布局不同]` |
| **P1 control panel** | (1038.0, 12.0, 230×298) | (933.5, 117.7, 230×298) | −104.5 | 105.7 | 0 | 0 | `[源码一致但布局不同]` |
| **P1 field meter** | (228.4, 144.0, 260×192)¹ | (274.4, 199.5, 260×192) | 46.0 | 55.5 | 0 | 0 | `[源码一致但布局不同]` |
| **P1 reset** | (1210.0, 730.0, 52×52) | (1201.7, 746.3, 52×45.7) | −8.3 | 16.3 | 0 | −6.3 | `[有意差异：NineGrid]` |
| **P1 AppBar** | 无 | (0, 0, 1280×44) | 0 | 0 | 1280 | 44 | `[有意差异：NineGrid]` |
| **P2 Flip Polarity** | (1049, 177, 208×48) | (944.5, 282.7, 208×48) | −104.5 | 105.7 | 0 | 0 | `[源码一致但布局不同]` |
| **P2 slider** | (1071, 91, 164×14) | (966.5, 196.7, 164×14) | −104.5 | 105.7 | 0 | 0 | `[已有问题：Legacy implementation]` |
| **P2 Strength 标签** | 随面板 | 随面板 | −104.5 | 105.7 | 0 | 0 | `[源码一致但布局不同]` |
| **P2 Bar Magnet 标题** | 随面板 | 随面板 | −104.5 | 105.7 | 0 | 0 | `[源码一致但布局不同]` |
| **P2 Magnetic Field checkbox** | (1049, 111, 20×20) | (944.5, 216.7, 20×20) | −104.5 | 105.7 | 0 | 0 | `[有意差异：Material]` |
| **P2 arrow buttons** | (1050, 88, 20×20) | (945.5, 193.7, 20×20) | −104.5 | 105.7 | 0 | 0 | `[源码一致但布局不同]` |
| **P2 Earth** | — | — | — | — | — | — | `[无法验证：missing earth.svg]` |

¹ 原版磁场计整板 260×192 来自源码几何（finder 只打到 `B =` 文字 `(239.9, 155.5, 134.8×17)`）。Flutter 量到的是整个 `FieldMeter` widget。

面板内 P2 控件的窗口 Δ 几乎都等于面板 Δ `(−104.5, +105.7)` = `(−canvas.x, +canvas.y)`。它们相对面板没有再漂。

---

## 5. 分类说明（不用「像/不像」）

| 标签 | 本基线里指什么 |
|---|---|
| `[视觉已对齐]` | **无**。NineGrid 后窗口 rect 对不齐是预期。 |
| `[源码一致但布局不同]` | 常量、比例、Painter 未改；父坐标系从满屏变成 center slot。磁铁/罗盘/面板/磁场计/P2 标签。 |
| `[视觉近似]` | 本表未用。针盘/磁铁外观同源 Painter，但未做像素验收。 |
| `[有意差异：NineGrid]` | AppBar、center 缩小、边格、Reset 进 `bottomRight`。 |
| `[有意差异：Material]` | 原版 dark theme vs Kratos Material 3 light（Checkbox / Slider 主题）。 |
| `[待确认]` | 无（原版已跑到截图）。 |
| `[已有问题：Legacy implementation]` | Slider **overflowed by 55 pixels**（原版与 Flutter 都抛）。 |
| `[无法验证：missing earth.svg]` | Earth 路径。 |

磁场箭头网格：仍是未改的 `FieldNeedlePainter` 34×19，画在更小的 canvas 上，格距变密。归入 canvas 的 NineGrid 差异，**不要**回头改 MagneticField。

---

## 6. Slider overflow

```
RenderFlex overflowed by 55 pixels
卡片内宽 208 − 箭头 44 = 164 留给 Slider；Slider 最小需求约 219
```

原版 debug 异常：`overflowed by 55 pixels`（默认 + Field Meter 各一次）  
Flutter debug 异常：`overflowed by 55 pixels`

**`[已有问题：Legacy implementation]`**

本阶段不修。不改面板宽、不用自定义 track、不 FittedBox。

---

## 7. Earth

**`[无法验证：missing earth.svg]`**

- 全仓库仍无该文件
- 截图流程未勾选 Earth
- 未生成替代 SVG / PNG

---

## 8. Reset 高度

原版 52×52 完整圆。  
Flutter 量到 **52 × 45.7**：`bottomRight` 格高 ≈ 61.7，外加 `Padding(8)` 后 52+16=68 > 61.7，底部被裁。

这是 NineGrid 边格的几何，**不是** Reset 语义变化。本阶段不修。

---

## 9. Mean RGB（辅助，不优化）

debug overflow 条在画面内，数字只作记录。

| 区域 | Original | Flutter |
|---|---|---|
| Full screen | `#1A1518` (26.45, 20.99, 23.97) | `#1B1A22` (27.04, 26.42, 34.42) |
| Play area | 同满屏（canvas=window） | `#261F24` (38.42, 31.19, 35.93) |

Flutter 满屏略偏蓝：AppBar `#1565C0`。Play area 均值更高：同一块 500×128 磁铁占更小 canvas。**不要为这些数字改色。**

---

## 10. 未改动的业务（禁止因截图差异回改）

- `MagneticField`
- `MagnetState`
- compass physics / `CompassPainter`
- reset 语义
- drag 语义
- Home 未接
- Legacy `simulations/magnet_and_compass.dart` 未删
- Electromagnet 仍 BLOCKED

---

## 11. 产物

| 路径 | 角色 |
|---|---|
| `FIRST_VISUAL_BASELINE.md` | 本报告 |
| `rects.json` | WidgetTester 实测窗口/canvas-local rect + overflow + environment |
| `matrix.json` | 差异矩阵 + 坐标映射 + Mean RGB |
| `mean_rgb.json` | RGB 摘录 |
| `screenshots/` | 原版 / Flutter / overlay / diff / 裁切 |
| `test/visual_qa/magnet_m5_1_capture_test.dart` | 再生截图（不改 sim） |
| `_m5_1_overlay.py` | overlay / matrix 再生 |

再生：

```
flutter test test/visual_qa/magnet_m5_1_capture_test.dart
python requirements/project-migration/visual-qa/magnet/_m5_1_overlay.py
```

---

## 12. 停止

**M5-1 完成。停止。**

不开始 Visual Fix。不接 Home。不删除 Legacy。不造 `earth.svg`。不修 Slider overflow。
