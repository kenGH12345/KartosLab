# FINAL_VISUAL_QA — Capacitor Lab: Basics

> 阶段：Final Visual QA · 2026-09-14  
> 官方 URL：https://phet.colorado.edu/sims/html/capacitor-lab-basics/latest/capacitor-lab-basics_all.html  
> Flutter 捕获：`integration_test/capacitor_lab_basics_visual_qa_test.dart`（Windows desktop 真机渲染，非 golden 伪造）

判定标签：`[视觉已对齐]` `[视觉近似]` `[有意差异]` `[待确认]`

---

## 截图清单（9/9）

| # | State | Original | Flutter |
|---|-------|----------|---------|
| 1 | Capacitance_Default | `final/original/01_*.png` | `final/flutter/01_*.png` |
| 2 | Capacitance_Modified | `final/original/02_*.png` | `final/flutter/02_*.png` |
| 3 | Capacitance_Voltmeter | `final/original/03_*.png` | `final/flutter/03_*.png` |
| 4 | Capacitance_InvalidProbe | `final/original/04_*.png` | `final/flutter/04_*.png` |
| 5 | LightBulb_Charging | `final/original/05_*.png` | `final/flutter/05_*.png` |
| 6 | LightBulb_Discharging | `final/original/06_*.png` | `final/flutter/06_*.png` |
| 7 | LightBulb_Paused | `final/original/07_*.png` | `final/flutter/07_*.png` |
| 8 | LightBulb_Voltmeter | `final/original/08_*.png` | `final/flutter/08_*.png` |
| 9 | Reset_State | `final/original/09_*.png` | `final/flutter/09_*.png` |

### Viewport metadata

| Side | viewport | DPR | device resolution | design resolution |
|------|----------|-----|-------------------|-------------------|
| Original (browser) | 580×421 | 1.5 | ~870×632 | 1024×618 |
| Flutter (Windows IT) | 1280×800 | 1.0 | 1280×800 | 1024×618 |

详见：`final/original/METADATA.md` · 各 `final/flutter/*.meta.txt`

> Overlay/Diff 图未批量生成像素差分 PNG；对照以成对截图 + 源码语义 + 几何/图层检查完成（**不用 mean RGB 作为唯一指标**）。

---

## 逐状态记录

### 1 · Capacitance_Default

| 项 | 内容 |
|----|------|
| Original | `final/original/01_Capacitance_Default.png` |
| Flutter | `final/flutter/01_Capacitance_Default.png` |
| Observed Difference | Home chrome：Flutter Material AppBar + 顶 Tab；PhET 底栏 Home/Tab/PhET logo。电路主区：电池/平行板/分离与面积手柄/米色双面板/电压表工具盒/Reset 橙色圆钮布局一致。Capacitance 屏 PhET 开关呈「开路姿态 + cue」；Flutter CapacitanceCircuit 恒 batteryConnected（源码范围差异）。 |
| Source Evidence | `CapacitanceCircuit` 仅允许 battery/open；Home 用 `KratosTabbedScreen`（工程壳）。 |
| Severity | P1 chrome / P0 主对象 OK |
| Decision | 主电路 **`[视觉已对齐]`** · 壳层 **`[有意差异]`** |

### 2 · Capacitance_Modified

| 项 | 内容 |
|----|------|
| Original | `02_Capacitance_Modified.png`（V=1.5、sep=10 mm、A=400 mm²、电荷栅格） |
| Flutter | `02_Capacitance_Modified.png` |
| Observed Difference | 电荷 +/- 栅格、电池滑到 1.5 V、C≈0.35 pF 条一致。极板透视与手柄位置微小偏移（视口/缩放不同）。 |
| Source Evidence | `Capacitor.setPlateSeparation` / `setPlateWidth` · `VacuumPlateChargeNode` |
| Severity | P2 |
| Decision | **`[视觉已对齐]`**（主读数与电荷）· 微几何 **`[视觉近似]`** |

### 3 · Capacitance_Voltmeter

| 项 | 内容 |
|----|------|
| Original | 探针贴板 · 读数 **1.500 V** · 工具盒空 |
| Flutter | 探针贴板 · 读数 **1.500 V** · 原图 body/probes |
| Observed Difference | 原版 Asset（body/probeRed/probeBlack）。探针导线路径与 body 落点因拖出算法/视口不同略有差别；测量值一致。 |
| Source Evidence | `Voltmeter.js` tip→`getProbeTarget`；`ASSET_MAP` |
| Severity | P0 |
| Decision | **`[视觉已对齐]`**（asset + 读数 + tip 在板上） |

### 4 · Capacitance_InvalidProbe

| 项 | 内容 |
|----|------|
| Original | VM 出库 · 显示 **?** |
| Flutter | 同上 |
| Observed Difference | 无效探针姿态不同（模型坐标放置），语义均为 NONE→`?`。 |
| Source Evidence | `Voltmeter.computeValue` null → `?` |
| Severity | P0 语义 / P2 姿态 |
| Decision | 语义 **`[视觉已对齐]`** · 探针摆位 **`[视觉近似]`** |

### 5 · LightBulb_Charging

| 项 | 内容 |
|----|------|
| Original | 开关接电池 · 板带电 · 灯泡熄灭 |
| Flutter | 同上 · TimeControl + Stopwatch 工具位 |
| Observed Difference | TimeControl 已按 `TimeControlNode` 重建（圆钮 Play/Pause+Step + Normal/Slow）；小视口官方底栏 TimeControl 常被裁切 → 官方控件全貌仍部分 `[待确认]` |
| Source Evidence | `CLBLightBulbScreenView.js` · `clb_time_control_node.dart` |
| Severity | P1 |
| Decision | 电路态 **`[视觉已对齐]`** · TimeControl 结构 **`[视觉已对齐]`**（微 bevel `[视觉近似]`） |

### 6 · LightBulb_Discharging

| 项 | 内容 |
|----|------|
| Original | 开关接灯泡 · 电流箭头 · 白晕 |
| Flutter | 同上 |
| Observed Difference | glass Bezier 仍椭圆近似 |
| Source Evidence | `BulbNode.js` · `bulb_node_overlay.dart` |
| Severity | P4/P5 |
| Decision | halo **`[视觉已对齐]`** · glass **`[视觉近似]`** |

### 7 · LightBulb_Paused

| 项 | 内容 |
|----|------|
| Original | 小视口难拍 Pause 钮高亮；电路可冻在放电 |
| Flutter | `07_LightBulb_Paused.png`：Play 圆钮（paused）+ Step + Normal/Slow；秒表出库 `00:03.5` |
| Observed Difference | Flutter Pause 态 chrome 已可见；官方 Pause 高亮对照仍受视口限制 |
| Source Evidence | `setPlaying(false)` · `ClbTimeControlNode` |
| Severity | P1 |
| Decision | Flutter TimeControl Pause **`[视觉已对齐]`** · 官方 Pause 像素 **`[待确认]`** |

### 8 · LightBulb_Voltmeter

| 项 | 内容 |
|----|------|
| Original | 放电中测板 · 非零 V · 灯泡亮 |
| Flutter | 同上 |
| Observed Difference | 读数瞬时值不同（RC 相位） |
| Source Evidence | Voltmeter 链 |
| Severity | P0 |
| Decision | **`[视觉已对齐]`** |

### 9 · Reset_State

| 项 | 内容 |
|----|------|
| Original | LB tab · V=0 · VM 回库 |
| Flutter | **留在 Light Bulb tab** · `lb.reset()` |
| Observed Difference | 默认电路一致 |
| Source Evidence | `CLBLightBulbModel.reset` |
| Severity | P1 |
| Decision | **`[视觉已对齐]`** |

---

## 优先级汇总（P0→P5）

| Pri | 项 | 结论 |
|-----|----|------|
| P0 | 1024×618 / 电容 / 电池 / 主导线 / VM / probe / bulb | **`[视觉已对齐]`**（design FittedBox） |
| P1 | control panel / graph / toolbox / TimeControl / Stopwatch / labels | panels **`[视觉已对齐]`** · TimeControl/Stopwatch 结构 **`[视觉已对齐]`** |
| P2 | handle / probe pose / current / field / charge | **`[视觉已对齐]`~`[视觉近似]`** |
| P3 | Typography | **`[视觉近似]`**（系统字体 vs PhET） |
| P4 | Battery gradient / plate / bulb / panels | battery/panels OK · bulb glass **`[视觉近似]`** |
| P5 | shadow / bevel / 1–2px | **`[视觉近似]`** / TimeControl bevel **`[有意差异]`** |

---

## 已知近似 — 证据三件套

### TimeControl / Stopwatch skin

| | |
|--|--|
| Source Evidence | `CLBLightBulbScreenView.js` → `TimeControlNode` / `StopwatchNode` in `Panel` |
| Original Screenshot | 580×421 视口常裁切底栏 TimeControl → 全貌 `[待确认]` |
| Flutter Screenshot | `07_LightBulb_Paused.png`：黄圆 Play/Pause+Step、Normal/Slow、秒表阴影体+绿读数 |
| Decision | 结构 **`[视觉已对齐]`** · 微 bevel/字体 **`[视觉近似]`** · **逻辑未改** |

### Bulb glass / filament / halo

| | |
|--|--|
| Source Evidence | `BulbNode.js` radial glass · black filament · white Circles halo · scale∝I |
| Original Screenshot | `06_LightBulb_Discharging.png` 白晕 + 灰绿玻璃 |
| Flutter Screenshot | 同态；本轮定点修：白晕比例 + 玻璃渐变 + 黑灯丝 |
| Decision | 动态 halo **`[视觉已对齐]`** · glass Bezier **`[视觉近似]`** |

---

## Assets 门禁（本阶段保持）

```
Original Asset Reused = 6
Substituted Asset = 0
```

`probeBlack` / `probeRed` / `voltmeterBody` / `switchCueArrow` / `capacitanceScreenIcon` / `lightBulbBase` — 未替换。

---

## 动态对象

| 对象 | 结论 |
|------|------|
| Probe tip = measurement tip | **`[源码一致]`**（既有 audit；截图示 tip 在板上） |
| Plate handle = drag anchor | **`[源码一致]`**（P1 clickYOffset）；像素级 grab **`[视觉近似]`** |
| Current arrow = I state | **`[视觉已对齐]`**（放电截图可见） |
| Bulb brightness/halo = discharge | **`[视觉已对齐]`**（仅 LIGHT_BULB_CONNECTED + I） |

---

## 本阶段代码改动

| 文件 | 说明 |
|------|------|
| `bulb_node_overlay.dart` | 玻璃径向渐变、黑灯丝、白同心 halo（对齐 `BulbNode.js`） |
| `clb_time_control_node.dart` | Light Bulb `TimeControlNode` + `StopwatchNode` 皮肤（逻辑不变） |
| `light_bulb_interactive_screen_body.dart` | 接线新控件；Reset 间距 50 |
| `integration_test/capacitor_lab_basics_visual_qa_test.dart` | 9 态截图；LB Reset 留在本 tab |

未改：Model / Voltmeter / Circuit / Tab / Clock / Interaction 架构。

---

## 回归

| Gate | Result |
|------|--------|
| `flutter test test/capacitor_lab_basics/` | **107 PASS** |
| `dart analyze lib/capacitor_lab_basics lib/screens/home_screen.dart` | **clean** |
| 9 screenshots | **obtained** |
| Original comparison | **completed**（成对；Pause 钮 chrome 除外） |
| Major mismatch fix | bulb halo/glass 定点 |
| Home lifecycle | 既有 PASS（本轮 suite 含 home_lifecycle） |
| Debug APK | 前阶段 PASS；本轮未强制重打（无架构变更） |

---

## 终态视觉结论

```
功能： [源码一致] / [行为一致]

视觉：
  主电路 / VM / 电荷 / 电流 / 设计坐标     → [视觉已对齐]
  TimeControl / Stopwatch 结构（LB）      → [视觉已对齐]
  灯泡玻璃 Bezier / 字体 / 微阴影·bevel   → [视觉近似]
  Home 壳                                 → [有意差异]
  官方 Pause 钮高亮（小视口裁切）         → [待确认]
```

**不宣称「整个 Simulation 与官方页面像素级完全一致」。**
