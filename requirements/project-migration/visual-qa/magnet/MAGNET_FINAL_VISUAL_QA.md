# MAGNET M5-FINAL · Visual QA / Acceptance

> 日期：2026-08-31  
> 阶段：**READ-ONLY。0 实现修改。**  
> 对照：A `phet/magnet_and_compass/` `SimulationPage` · target `lib/magnetism/magnet_and_compass/`  
> 截图与矩阵：`requirements/project-migration/visual-qa/magnet/final/`

未接 Home。未删 Legacy。未造 `earth.svg`。未动 Electromagnet。

---

## 1. 环境

与 M5-1 **完全相同**：

| 项 | 值 |
|---|---|
| 设备标签 | Pixel Tablet landscape（WidgetTester 视口仿真，非实机） |
| physical | 2560 × 1600 |
| DPR | 2.0 |
| logical | **1280 × 800** |
| orientation | landscape |
| viewPadding / padding | 全 0 |
| PNG | 2560 × 1600（`toImage(pixelRatio: 2)`） |
| 原版 Theme | `ThemeData.dark()`（对齐 phet `MagnetApp`） |
| Flutter Theme | M3 light · seed `#1177AA` |
| 坐标 | 窗口逻辑 px；canvas-local = 窗口 − NineGrid center origin |
| crop | 同 M5-1：按 rect × DPR 裁切 |

原版与 Flutter **同一 visor、同一 capture 测试**。RGB 可作辅助，**不为 RGB 改代码**。

---

## 2. Original

`phet/magnet_and_compass/lib/main.dart` `SimulationPage`：

- 无 AppBar、无 NineGrid；canvas = 满窗 1280×800
- 位置 = `MediaQuery` 窗口分数；尺寸 = 绝对逻辑 px
- 默认：磁场 + 磁铁 + 罗盘 + ControlPanel + Reset
- Field Meter 默认关；截图 `original_field_meter.png` 勾选 index 4（未点 Earth）
- Debug overflow：`overflowed by 55 pixels` ×2（长标签，Legacy A，未改 phet）

| 元件 | 窗口 rect（逻辑 px） |
|---|---|
| canvas | (0, 0, 1280×800) |
| magnet | (287.6, 336.0, 500×128) 中心 **(537.6, 400)** |
| compass | (692.0, 452.0, 152×152) 中心 **(768, 528)** |
| FieldMeter | (228.4, 144.0, 260×192) 中心 **(358.4, 240)**（源码几何） |
| ControlPanel | (1038, 12, 230×298) |
| Reset | (1210, 730, 52×52) · right/bottom = 18 |
| AppBar | 无 |

Magnet − Meter = **(179.2, 160)**。Compass − Magnet = **(230.4, 128)**。

---

## 3. Flutter

`MagnetAndCompassScreen`（M5-2…M5-4 之后）：

- AppBar 44 · `#1565C0` · 标题「磁铁与罗盘」
- NineGrid center = 场；Reset = `bottomRight`
- 物体位置 = 原版窗口分数 − center origin（平移，不缩放）

| 元件 | 窗口 rect |
|---|---|
| canvas | (104.5, 105.7, 1070.9×632.5) |
| magnet | (287.6, 336.0, 500×128) 中心 **(537.6, 400)** |
| compass | (692.0, 452.0, 152×152) 中心 **(768, 528)** |
| FieldMeter | (228.4, 144.0, 260×192) 中心 **(358.4, 240)** |
| ControlPanel | (933.5, 117.7, 230×298) · canvas-local top 12 / right 12 |
| Reset | (1210.0, 738.3, **52×52**) |
| AppBar | (0, 0, 1280×44) |

Debug overflow：**0**（M5-3 FittedBox）。拖磁铁 `Offset(-140, 70)` → 中心 (397.6, 470)，语义未回归。

Capture 顺序与 M5-1 相同：Field Meter 图是在 **磁铁已拖动** 之后打开测点。测点仍停在 init 窗口分数（探针语义）。叠图时磁铁位置会故意不一致，**不要**当成 FieldMeter 回归。

---

## 4. FINAL_VISUAL_MATRIX

完整 JSON：`final/matrix.json`。

| Component | Original | Flutter | Δx | Δy | Δw | Δh | Classification |
|---|---|---|---:|---:|---:|---:|---|
| canvas | 1280×800 @ (0,0) | 1070.9×632.5 @ (104.5, 105.7) | 104.5 | 105.7 | −209.1 | −167.5 | SOURCE-ALIGNED / LAYOUT-DIFFERENT |
| **magnet** | (287.6, 336, 500×128) | **同** | **0** | **0** | **0** | **0** | **VISUALLY ALIGNED** |
| **compass** | (692, 452, 152×152) | **同** | **0** | **0** | **0** | **0** | **VISUALLY ALIGNED** |
| **FieldMeter** | (228.4, 144, 260×192) | **同** | **0** | **0** | **0** | **0** | **VISUALLY ALIGNED** |
| ControlPanel | (1038, 12, 230×298) | (933.5, 117.7, 230×298) | −104.5 | 105.7 | 0 | 0 | SOURCE-ALIGNED / LAYOUT-DIFFERENT |
| Reset | (1210, 730, 52×52) | (1210, 738.3, 52×52) | 0 | 8.3 | 0 | 0 | SOURCE-ALIGNED / LAYOUT-DIFFERENT |
| AppBar | 无 | 1280×44 | — | — | 1280 | 44 | SOURCE-ALIGNED / LAYOUT-DIFFERENT |
| Flip Polarity | 208×48 | 208×48 | −104.5 | 105.7 | 0 | 0 | VISUALLY ALIGNED（随面板） |
| Slider | 164×14 | 164×14 | −104.5 | 105.7 | 0 | 0 | VISUALLY ALIGNED（盒） |
| Magnetic Field (B) 标签 | 238.5×19 | 184×14.7 | — | — | −54.5 | −4.3 | SOURCE-ALIGNED / LAYOUT-DIFFERENT |
| Bar Magnet 标题 | 142.5×20 | 142.5×20 | 随面板 | 随面板 | 0 | 0 | VISUALLY ALIGNED |
| Checkbox | 20×20 | 20×20 | 随面板 | 随面板 | 0 | 0 | MATERIAL DIFFERENCE |
| AppBar 中文 | — | 平台 fallback | — | — | — | — | FONT DIFFERENCE |
| Earth | — | — | — | — | — | — | **BLOCKED** |

未发现 Magnet / Compass / FieldMeter / ControlPanel 几何 / Reset 语义回归。

---

## 5. Overlay / diff

全部在 `final/screenshots/`（与 M5-1 同算法：50% blend；差图亮度×3；canvas-normalized 为辅助拉伸，**不是**像素验收）。

| 文件 | 用途 |
|---|---|
| `original_default.png` / `flutter_default.png` | 默认 |
| `flutter_magnet_moved.png` | 磁铁拖动 |
| `original_field_meter.png` / `flutter_field_meter.png` | FieldMeter 开 |
| `original_*` / `flutter_*` magnet · compass · control_panel · reset | 元件裁切 |
| `overlay_default.png` / `diff_default.png` | 同视口叠图 |
| `overlay_field_meter.png` / `diff_field_meter.png` | 测点态（Flutter 磁铁已拖） |
| `overlay_canvas_normalized.png` / `diff_canvas_normalized.png` | center 拉伸到满窗（辅助） |
| `overlay_annotated_rects.png` | rect 描边 |

全帧 diff 的主能量来自 **AppBar 蓝带 + NineGrid 边格无场箭头**，不是磁铁/罗盘错位。

---

## 6. Resolved（相对 M5-1，不重开）

| 项 | M5-1 | M5-FINAL |
|---|---|---|
| Magnet 窗口中心 | Δ (16.7, 22) | **0** · M5-2 |
| Compass 窗口中心 | Δ (−20.9, −4.8) | **0** · M5-2 |
| 磁铁↔罗盘向量 | 被 canvas 分数压扁 | **(230.4, 128)** |
| FieldMeter 向量 | ≈ (133, 105) | **(179.2, 160)** · M5-4 |
| ControlPanel overflow | 双方 55px | Flutter **0** · M5-3；原版仍 55 |
| Reset 圆高 | 45.7 裁切 | **52×52** · M5-4；槽位仍边格 |

---

## 7. Visual aligned

- Magnet 尺寸、窗口中心、N/S 色与字  
- Compass 尺寸、窗口中心、针盘 Painter  
- FieldMeter 尺寸、窗口中心、采样点 = 面板中心  
- 面板 230×298、相对 canvas `top:12, right:12`  
- Slider 盒 164×14、Flip 208×48、短标签量测 0  
- Reset **圆形 52×52**、色 `#e65100`、icon 28  

---

## 8. Engineering differences

`SOURCE-ALIGNED / LAYOUT-DIFFERENT`

- AppBar + NineGrid（KARTOSLAB 页面壳）  
- 场箭头只画在 center（格距随 canvas 变密；公式未改）  
- ControlPanel 窗口坐标随 center origin 平移  
- Reset 在 `bottomRight`：right=18，bottom 受边格高限制 ≈9.7（Δy +8.3 vs 满窗 bottom 18）  
- `Magnetic Field (B)` FittedBox（避免 overflow）  

**不要**为叠图里的边格/AppBar 去改 NineGrid 或回退 FittedBox。

---

## 9. Material differences

- 宿主：原版 `ThemeData.dark()` vs Flutter M3 light  
- 未选中 Checkbox 边框 / InkWell 涟漪  
- 不重写 Slider / Card / Button / Icon 体系  

---

## 10. Font differences

- 面板/磁铁/测点拉丁文：双方未设 `fontFamily` → Roboto  
- AppBar「磁铁与罗盘」：Kratos `fontFamilyFallback`（微软雅黑等）  
- 无法也不应复原某一特定 CJK 文件  

---

## 11. Blocked

**`BLOCKED: missing earth.svg`**

- 未勾选 Earth  
- 未生成替代资源  
- `EarthGlowPainter` / 垂直磁铁仅源码对齐，无法对屏  

**Electromagnet：仍 BLOCKED**（非本 sim 范围）。

---

## 12. RGB metrics（辅助，不优化）

同环境 2560×1600 PNG：

| 区域 | Original | Flutter |
|---|---|---|
| Full screen | `#1A1518` (26.45, 20.99, 23.97) | `#1C1B23` (28.25, 27.16, 35.14) |
| Play area | 同满屏（canvas=window） | `#282025` (40.09, 32.26, 37.03) |

Flutter 满屏偏蓝 = AppBar。Play area 均值更高 = 固定尺寸磁铁占更小 center。**禁止为降低 RGB 改色或改布局。**

---

## 13. Tests

本阶段 **未改** `lib/` 实现。Capture 测试的 `_outDir` 仅临时指向 `final/`，已恢复为 M5-1 路径。

| 命令 | 结果 |
|---|---|
| `flutter analyze lib/magnetism/magnet_and_compass test/magnetism` | **No issues** |
| `flutter test test/magnetism` | **36/36 passed** |
| `flutter test test/chemistry/build_a_nucleus` | **407/407 passed** |
| `flutter test test/visual_qa/magnet_m5_1_capture_test.dart` | passed（写入 `final/`） |

---

## 14. Final assessment

**Pixel Tablet 1280×800 视觉验收通过（附带已记录的工程/Material/字体/Blocked 项）。**

实验物体（磁铁、罗盘、FieldMeter、面板内容、Reset 圆）在窗口关系上已恢复原版分数语义。剩余差来自 KARTOSLAB chrome（AppBar / NineGrid）、Material 皮肤、CJK 标题字体，以及 **earth.svg 缺失**。

**验收结论：接受。不再打开已解决的几何问题。不进入新的 Visual Fix。**

再生：

```
# 将 capture _outDir 临时改为 magnet/final 后：
flutter test test/visual_qa/magnet_m5_1_capture_test.dart
python requirements/project-migration/visual-qa/magnet/_m5_final_overlay.py
```

---

## 停止

**M5-FINAL 完成。**

不修代码。不接 Home。不删 Legacy。不修 Earth。不修 Electromagnet。
