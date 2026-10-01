# FINAL_BEHAVIOR_MATRIX — Capacitor Lab: Basics

> Final Behavioral Acceptance · 2026-09-14  
> 基准：本地 PhET `capacitor-lab-basics` + 已落地 Flutter  
> **不以测试数量单独判定完成。**  
> P0 = 0 · P1 = 0 · suite **107 PASS** · scoped analyze **clean**

判定标签：`[源码一致]` `[行为一致]` `[视觉已对齐]` `[视觉近似]` `[有意差异]` `[待确认]` `[BLOCKED]`

列说明：

| 列 | 含义 |
|----|------|
| Source | 对照本地 PhET 源码的实现/常量/公式 |
| Runtime | 组合状态 / 跨 Tab / Pause / Reset 下的逻辑（自动化 + 既有审计） |
| Test | 本仓自动化覆盖 |
| Visual | 原图 / 布局 / tip=hit 等视觉 |
| Final | 综合终态 |

---

## 总表

| Feature | Source | Runtime | Test | Visual | Final |
| ------- | ------ | ------- | ---- | ------ | ----- |
| Battery | `[源码一致]` min/max/default/snap | `[行为一致]` V→circuit→C→VM | unit + interaction | `[视觉近似]` thumb 细节 | **`[行为一致]`** |
| Plate Area | `[源码一致]` LinearFunction + quantize | `[行为一致]` →C/Q/E/graphs | plate area handler tests | `[待确认]` 手测 grab 手感 | **`[行为一致]`** |
| Plate Separation | `[源码一致]` clickYOffset 绝对 Y（P1） | `[行为一致]` | `plate_distance_drag_test` | `[待确认]` 手测 handle=pointer | **`[源码一致]`** |
| Switch | `[源码一致]` topology + Q store | `[行为一致]` open/closed↔V/I/VM | circuit_model_test | `[视觉近似]` tip/cue | **`[行为一致]`** |
| Voltmeter | `[源码一致]` tip→hit→signed/`?` | `[行为一致]` live refresh | voltmeter_* + audit | `[源码一致]` body/probes 原图 | **`[源码一致]`** |
| Probe | `[源码一致]` 独立 tip；默认绝对坐标 | `[行为一致]` body 不拖走 probe | interaction audit tests | tip≈hit `[源码一致]` | **`[源码一致]`** |
| Electric Field | `[源码一致]` E=V/d + spacing | `[行为一致]` view-only flag | physics + render path | `[行为一致]` | **`[源码一致]`** |
| Plate Charges | `[源码一致]` numberOfCharges | `[行为一致]` view-only | plate charge tests | `[行为一致]` | **`[源码一致]`** |
| Current | `[源码一致]` dQ/dt + fade via stepEmitter | `[行为一致]` Cap step + Pause 冻 fade | current_* + pause test | `[行为一致]` | **`[源码一致]`** |
| Light Bulb | `[源码一致]` RC discharge | `[行为一致]` I→brightness | circuit + LB tests | halo 动态 `[视觉已对齐]` · glass Bezier `[视觉近似]` | **`[行为一致]`** |
| Time Control | `[源码一致]` play/pause/step/slow | `[行为一致]` Pause 冻放电 | circuit + p0 pause | 圆钮+Normal/Slow `[视觉已对齐]` | **`[行为一致]`** |
| Stopwatch | `[行为一致]` clock 绑定；回库 reset | `[行为一致]` ∩toolbox→reset | `stopwatch_toolbox_test` | 阴影体+读数 `[视觉已对齐]`~`[视觉近似]` | **`[行为一致]`** |
| Reset | `[源码一致]` meters→VM→circuit→view | `[行为一致]` | model reset + lifecycle | — | **`[源码一致]`** |
| Tab Lifecycle | `[行为一致]` TickerMode + 守卫 | `[行为一致]` 隐藏不 step | `p0_clock_lifecycle_test` | — | **`[行为一致]`** |
| Home lifecycle | `[行为一致]` enter/back/reopen | `[行为一致]` | `home_lifecycle_test` | Home icon `[有意差异]` | **`[行为一致]`** |
| View Controls | `[源码一致]` visibility only | `[行为一致]` 不改物理 | code review + model | `[视觉近似]` checkbox | **`[源码一致]`** |
| Bar Graphs | `[源码一致]` C/Q/U meters | `[行为一致]` live | model values | `[视觉近似]` 布局 | **`[行为一致]`** |

---

## 验收场景覆盖（对照用户清单）

### Capacitance

| 场景 | 自动化/证据 | 人工手测 |
|------|-------------|----------|
| Battery 默认→中→min→max→Reset | snap/constrain/reset 测试 | **建议**：滑条手感 |
| Plate Area 三 grab 点 | Area handler 无跳位（源码） | **建议**：偏上/偏下手测 |
| Plate Separation clickYOffset | `plate_distance_drag_test` PASS | **建议**：快速拖动手感 |
| Switch open/closed/Reset | circuit_model PASS | 建议：连点 snap |
| View toggles view-only | ClbViewControlPanel 仅 flag | 建议：关 E-field 后改 V 仍变 Q |
| Voltmeter 全链 | `VOLTMETER_FINAL_AUDIT` + 20+ tests | **建议**：真机 tip 对板 |
| Capacitance Current | Capacitance ticker + amp tests | 建议：开 Current 后拧电压 |

### Light Bulb

| 场景 | 自动化/证据 | 人工手测 |
|------|-------------|----------|
| 充电→接灯泡→放电 | LightBulbCircuit.step tests | **建议**：亮度衰减 |
| Pause 冻 charge/current/fade | pause + current_indicator_pause | **建议**：Pause 看箭头 |
| Stopwatch 拖出/回库 | stopwatch_toolbox_test | **建议**：拖回米色盒 |
| Voltmeter on LB | 同 computeValue + remap | 建议：放电中测板 |

### 跨状态

| 场景 | 自动化 | 人工 |
|------|--------|------|
| LB running → Cap（隐藏不 step） | p0 hidden_tab PASS | 建议再肉眼确认 Q |
| Cap → LB single clock | duplicate ticker test PASS | — |
| Pause → Tab → back | p0 pause round-trip PASS | — |
| Reset + Tab + re-entry | home + reset tests | 建议：改态后 Reset |
| Home enter×2 / back×2 | home_lifecycle PASS | — |

---

## Probe tip = hit（视觉/功能）

| 项 | 结论 |
|----|------|
| Probe 图顶 = `probePosition` | `[源码一致]` |
| Hit = `probe + PROBE_TIP_OFFSET` 多边形 | `[源码一致]` |
| Body 不参与测量 | `[源码一致]` |

## Plate handle = drag

| 项 | 结论 |
|----|------|
| Separation 绝对 Y + clickYOffset | `[源码一致]`（P1） |
| Area LinearFunction + clickXOffset | `[源码一致]` |
| 像素级 handle 对齐官方截图 | `[待确认]` |

---

## Assets 门禁

| 项 | 值 |
|----|-----|
| Original Asset Reused（强制 6） | **6**（voltmeterBody / probeRed / probeBlack / switchCueArrow / capacitanceScreenIcon / lightBulbBase） |
| Substituted Assets | **0** |
| 证据 | `ASSET_MAP.md` · `ClbConstants.asset*` · `Image.asset` |

---

## 截图矩阵

| ID | 状态 |
|----|------|
| Capacitance_Default … Reset_State（9 张） | **已获得** — `visual-qa/final/original/` + `visual-qa/final/flutter/`（详见 `visual-qa/FINAL_VISUAL_QA.md`） |
| Original vs Flutter 成对对照 | **已完成**（源码语义 + 截图；非 mean-RGB） |
| 官方 Pause 钮高亮 / 大视口像素 Diff PNG | **`[待确认]`** |
| 主电路 / VM / 电荷 / 电流 | **`[视觉已对齐]`** |
| TimeControl / Stopwatch 皮 | 结构 **`[视觉已对齐]`** · 微 bevel **`[视觉近似]`** |
| Bulb glass Bezier | **`[视觉近似]`** |

---

## 门禁结果（Final Acceptance）

| Gate | Result |
|------|--------|
| P0 | **0** |
| P1 | **0** |
| `flutter test test/capacitor_lab_basics/` | **107 PASS** |
| `dart analyze lib/capacitor_lab_basics lib/screens/home_screen.dart` | **clean** |
| Home lifecycle | **PASS**（自动化） |
| Debug APK | 见构建日志（本轮触发） |
| Original=6 / Substituted=0 | **PASS** |
| BLOCKED | **无** |

---

## 终态结论

- **功能主链**（Model / Circuit / VM / RC / Clock / Tab / Reset）：**`[源码一致]` / `[行为一致]`**，P0/P1 = 0。  
- **视觉**（Final Visual QA · 9 对截图）：主电路/VM/电荷/电流 **`[视觉已对齐]`**；TimeControl/Stopwatch/Home 壳 **`[有意差异]`**；bulb glass Bezier / 字体 **`[视觉近似]`**；官方 Pause 高亮与大视口 Diff PNG **`[待确认]`**。  
- 详表：`visual-qa/FINAL_VISUAL_QA.md`

**不宣称「整个 Simulation 与官方页面像素级完全一致」。**  
**宣称：功能闭环已闭合；视觉已按截图证据分级判定，非笼统 Visual PASS。**
