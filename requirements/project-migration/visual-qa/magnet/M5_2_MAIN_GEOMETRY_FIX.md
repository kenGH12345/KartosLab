# MAGNET M5-2 · Main Geometry Fix

> 日期：2026-08-31  
> 范围：**只处理 canvas / magnet / compass 主几何**  
> 未改：ControlPanel / FieldMeter widget / Reset / AppBar / Theme / Slider / Earth / Home / MagneticField / NineGridLayout / 物体宽高

---

## 0. 结论

原版是 **固定物理尺寸 + 非缩放 viewport**。[已确认]

- 无 `LAYOUT_BOUNDS`
- 无 `FittedBox` / `Transform.scale`
- canvas **等于** 满窗 `MediaQuery.size`
- 位置 = 窗口分数；尺寸 = 绝对逻辑 px；1 px = 1 场单位

方案 A（uniform scale）会缩小磁铁/罗盘，禁止。  
方案 B（单一 origin offset）无法同时对齐磁铁和罗盘。

**实际采用：窗口分数 → NineGrid center 平移（非缩放）。**

Pixel Tablet 1280×800 复测（窗口坐标）：

| Component | M5-1 Δ | M5-2 Δ | Classification |
|---|---|---|---|
| canvas | +104.5 / +105.7 / −209.1 / −167.5 | **未变** | `[有意差异：NineGrid]` |
| magnet | +16.7 / +22.0 / 0 / 0 | **0 / 0 / 0 / 0** | `[视觉已对齐]` |
| compass | −20.9 / −4.8 / 0 / 0 | **0 / 0 / 0 / 0** | `[视觉已对齐]` |

磁铁↔罗盘像素向量恢复为原版 `(230.4, 128)`。[已确认]

---

## 1. 原版坐标体系

对照：

- A：`phet/magnet_and_compass/lib/main.dart` `SimulationPage`
- B：`simulations/magnet_and_compass.dart` `MagnetAndCompassPage`

| 问题 | 结论 | 证据 |
|---|---|---|
| canvas 是否等于整个 LAYOUT_BOUNDS？ | **没有 LAYOUT_BOUNDS。** canvas = 满窗 Scaffold body | `MediaQuery.size` + `Stack` `Positioned.fill` 场箭头 |
| magnet position 是 screen 还是 canvas？ | **二者同一件事**：screen = canvas | `_initPositions(s)` 用 `s = MediaQuery.size`；`Positioned(left: cx - 250)` 画在同一 Stack |
| compass 同上？ | 是 | `compassPos = (0.60W, 0.66H)` |
| 额外 transform？ | **无缩放。** 仅磁铁 `Transform.rotate(magnetAngle)` | grep：无 FittedBox / scale |
| viewport / scaling？ | **无** | 1 逻辑 px = 1 `MagneticField` 单位 |
| 控件是否以 canvas 为 reference？ | 面板/Reset 是 **全屏 Stack** 的 `Positioned`，不是独立世界坐标 | `top:12,right:12` / `right:18,bottom:18` |

初始（相对窗口 = 相对 canvas）：

```
magnet      (0.42W, 0.50H)   尺寸 500×128
compass     (0.60W, 0.66H)   半径 76
field meter (0.28W, 0.30H)   260×192
```

Pixel Tablet 1280×800：磁铁中心 `(537.6, 400)`，罗盘 `(768, 528)`。

---

## 2. Flutter 坐标体系（改前 / 改后）

NineGrid 未改。center 仍是：

```
origin_window = (104.5, 105.7)
size          = 1070.9 × 632.5
AppBar        = 44
```

`MagnetState.magnetPos` / `compassPos` **仍然是 center-local**（`Positioned` + `MagneticField.compute` 的同一空间）。本阶段只改 **写入这些字段之前** 的 screen→canvas 映射。

| | M5-1（改前） | M5-2（改后） |
|---|---|---|
| 初始公式 | `canvasSize * 分数` | `windowSize * 分数 − canvasOrigin`，再按原 clamp 夹进 center |
| 物体尺寸 | 500×128 / 152 | **不变** |
| 场公式 | 未改 | 未改 |
| magnet↔compass 向量 | 随 canvas 各向缩放 ≈ (192.8, 101.2) | 平移，保留 **(230.4, 128)** |

映射实现：`lib/magnetism/magnet_and_compass/model/magnet_canvas_mapping.dart`  
center origin 用 LayoutBuilder `RenderBox.localToGlobal`，不复制 NineGrid 算术（800×600 会触发 `minSideH=48`）。

---

## 3. 当前差异（改前，M5-1）

窗口坐标：

| Component | Δx | Δy | Δw | Δh |
|---|---:|---:|---:|---:|
| canvas | +104.5 | +105.7 | −209.1 | −167.5 |
| magnet | +16.7 | +22.0 | 0 | 0 |
| compass | −20.9 | −4.8 | 0 | 0 |

根因：把原版「窗口分数」误用成「center 分数」，间距被 `(1070.9/1280, 632.5/800)` 压扁。磁铁变近 → 即使公式不变，罗盘处的场输入也变了。

---

## 4. 方案 A / B

### A · uniform / aspect-preserving scale

```
sx = 1070.9/1280 ≈ 0.8367
sy = 632.5/800  ≈ 0.7906   ← 非均匀
uniform = min(sx,sy) ≈ 0.7906
```

若缩放整个实验：磁铁 500→~395，违反「尺寸不变」。  
若只缩放位置、不缩放尺寸：间距缩短，场采样点改变，且相对磁铁更大——这正是 M5-1 的现状。

原版是 **固定物理尺寸 + 非缩放 viewport**。[已确认]  
**A 不可行。**

### B · 保持尺寸，只修 origin

磁铁需要的平移 `(-16.7, -22.0)` 与罗盘需要的 `(+20.9, +4.8)` **不是同一个 offset**。  
单一 origin 无法同时对齐两者。[已确认]  
**B 不够。**

### 采用 · 窗口分数平移进 center（非 A、非 B）

源码语义：`pos = frac * MediaQuery.size`（无缩放）。  
Flutter：同一窗口点减去 NineGrid center origin，得到 center-local。平移保持像素间距与窗口位置。

小视口若窗口点落到 center 外：沿用原有 drag clamp（半宽/半径），不改 clamp 语义。Pixel Tablet **不触发** clamp。[已确认]

---

## 5. 实际采用方案

**窗口分数 → center-local 平移。**

禁止：`left = 截图像素`。分数仍是源码 `0.42 / 0.50 / 0.60 / 0.66`，视口来自 `MediaQuery.sizeOf`。

未改 `MagnetState` 字段含义：仍为 canvas-local `Offset`。

---

## 6. 修改前后坐标（Pixel Tablet 1280×800）

### Magnet（窗口）

| | x | y | w | h | cx | cy |
|---|---:|---:|---:|---:|---:|---:|
| 原版 | 287.6 | 336.0 | 500 | 128 | 537.6 | 400.0 |
| M5-1 Flutter | 304.3 | 358.0 | 500 | 128 | 554.3 | 422.0 |
| M5-2 Flutter | 287.6 | 336.0 | 500 | 128 | 537.6 | 400.0 |

M5-2 canvas-local 中心：`(433.1, 294.3)` = `(537.6−104.5, 400−105.7)`

### Compass（窗口）

| | x | y | w | h | cx | cy |
|---|---:|---:|---:|---:|---:|---:|
| 原版 | 692.0 | 452.0 | 152 | 152 | 768.0 | 528.0 |
| M5-1 Flutter | 671.1 | 447.2 | 152 | 152 | 747.1 | 523.2 |
| M5-2 Flutter | 692.0 | 452.0 | 152 | 152 | 768.0 | 528.0 |

M5-2 canvas-local 中心：`(663.5, 422.3)`

### Canvas（未改）

| | x | y | w | h |
|---|---:|---:|---:|---:|
| 原版 | 0 | 0 | 1280 | 800 |
| Flutter | 104.5 | 105.7 | 1070.9 | 632.5 |

---

## 7. Magnet Δ（相对原版，窗口）

| | Δx | Δy | Δw | Δh |
|---|---:|---:|---:|---:|
| M5-1 | +16.7 | +22.0 | 0 | 0 |
| **M5-2** | **0.0** | **0.0** | **0** | **0** |

---

## 8. Compass Δ（相对原版，窗口）

| | Δx | Δy | Δw | Δh |
|---|---:|---:|---:|---:|
| M5-1 | −20.9 | −4.8 | 0 | 0 |
| **M5-2** | **0.0** | **0.0** | **0** | **0** |

---

## 9. 测试结果

```
flutter test test/magnetism
  26 passed
  （原 M3 19 条全部通过；新增 mapping 6 + Pixel Tablet widget 1）

flutter test test/chemistry/build_a_nucleus
  407 passed

flutter analyze lib/magnetism/magnet_and_compass test/magnetism
  No issues found
```

新增：

- `test/magnetism/magnet_canvas_mapping_test.dart`
- `magnet_screen_test.dart`：Reset 后位置改为断言 **窗口分数**；Pixel Tablet 中心 + 向量

拖拽 clamp 仍相对 **canvas**，语义未改。

---

## 10. 是否影响 Field Meter

**本阶段不处理 FieldMeter。** widget / 颜色 / 尺寸未改。

初始仍是 **center 分数** `(0.28, 0.30)`，不是窗口分数。因此磁场计窗口位置与 M5-1 相同，相对原版仍有 Δ。

若下一阶段用同一平移，窗口中心会到 `(358.4, 240)`。现在故意不动。

ControlPanel / Reset 未改，窗口位置与 M5-1 相同。

---

## 11–14. 分类

| 项 | 标签 |
|---|---|
| 原版无缩放、canvas=窗口 | `[已确认]` |
| A 不可行、B 不够 | `[已确认]` |
| Pixel Tablet 磁铁/罗盘窗口 rect 与原版重合 | `[视觉已对齐]` |
| 磁铁↔罗盘像素向量 (230.4, 128) | `[视觉已对齐]` |
| 磁铁/罗盘硬编码尺寸 | `[视觉已对齐]` |
| NineGrid center 小于满窗；场箭头 34×19 铺在更小 canvas 上更密 | `[有意差异：NineGrid]` |
| AppBar / 边格 / Reset 槽 | `[有意差异：NineGrid]`（本阶段不修） |
| ControlPanel / FieldMeter 窗口位置 | 仍为 M5-1 差异；**本阶段不修** |
| Earth | `[无法验证：missing earth.svg]` · BLOCKED |
| 非 Pixel 视口的 clamp 是否可接受 | 小屏可能把窗口点夹进 center；Pixel Tablet 不夹。[已确认] 行为；其它机型观感 `[待确认]`（超出本视口） |

磁场网格更密是 canvas 变小的后果，不是 `MagneticField.compute` 被改。

---

## 改动文件

| 文件 | 内容 |
|---|---|
| `model/magnet_canvas_mapping.dart` | **新建** · 窗口→canvas 平移 + 原 clamp |
| `screens/magnet_and_compass_screen.dart` | init / reset 走 mapping；origin 来自 center RenderBox |
| `test/magnetism/magnet_canvas_mapping_test.dart` | 新建 |
| `test/magnetism/magnet_screen_test.dart` | 窗口分数断言 + Pixel Tablet |

未改：painters、MagneticField、MagnetState、ControlPanel、FieldMeter、NineGrid、constants 宽高。

---

## 截图

M5-1 基线 PNG **保留**在 `screenshots/`。  
本阶段新图：`m5-2/screenshots/`（`original_default` / `flutter_default` / overlay / diff / annotated P0）。

再生本阶段量测：把 capture 输出目录临时指到 `.../magnet/m5-2` 再跑 `test/visual_qa/magnet_m5_1_capture_test.dart`。

---

## 停止

**M5-2 完成。停止。**

不处理 ControlPanel、FieldMeter、Reset、Slider overflow、Earth、Home、Legacy。
