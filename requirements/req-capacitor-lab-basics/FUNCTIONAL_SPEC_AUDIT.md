# FUNCTIONAL_SPEC_AUDIT — Capacitor Lab: Basics

> 对照用户规格「PhET Capacitor Lab: Basics 原版功能规格」§1–§53  
> 行为基准：**本地 PhET 源码**（本规格不能替代源码）  
> 日期：2026-09-14  
> Voltmeter 专项：`VOLTMETER_FINAL_AUDIT.md` → **[源码一致]**（不重复重写）

判定标签：`[源码一致]` `[行为一致]` `[视觉已对齐]` `[视觉近似]` `[有意差异]` `[待确认]` `[BLOCKED]`

---

## 总判

| 域 | 判定 | 说明 |
|----|------|------|
| Capacitance 核心物理链 | **[行为一致]** | Battery / Plate / Switch / C·Q·E·Graphs 接通 Model |
| Light Bulb RC 放电链 | **[源码一致]**～**[行为一致]** | `discharge(R,dt)` + 亮度∝I；Pause 冻结 step |
| Voltmeter | **[源码一致]** | tip→hit→signed V / `?`；见专项审计 |
| View Controls | **[源码一致]** | 仅 visibility，不改物理 |
| Reset | **[源码一致]** | meters → voltmeter → circuit → view/clock |
| 双屏生命周期 | **[行为一致]** | `KratosTabSwitcher` + `TickerMode`；隐藏屏不 step（见 `P0_FIX_REPORT.md`） |
| Capacitance Current | **[行为一致]** | 可见屏 Ticker → `CapacitanceModel.step` → `currentAmplitude` |
| 全量 Visual Diff | **[待确认]** | 若干 UI 自绘近似，需逐项截图 |

**不是**「长得像的 Demo」级别：主链已 Model→Physics→Render。  
**P0: 0**（2026-09-14）。P1 backlog 见 `P0_FIX_REPORT.md` / 下文优先队列。

---

## § 映射表（规格章节 → 现状）

### A. 整体 / 双屏（§1–2, §45）

| 规格 | 状态 | 证据 / 缺口 |
|------|------|-------------|
| Capacitance + Light Bulb 双屏 | **[行为一致]** | `capacitor_lab_basics_home.dart` |
| 共享电池/电容/开关/Voltmeter 模式 | **[行为一致]** | 各自 Model 实例 + `ClbSharedState`（switchUsed） |
| 切屏无残留 Timer/Ticker | **[行为一致]** | 隐藏 Tab：`TickerMode` mute + `_onTick` 守卫；切回单 clock 恢复（`p0_clock_lifecycle_test`） |

### B. Capacitance（§3–14, §47 Cap 部分）

| 规格 | 状态 | 证据 / 缺口 |
|------|------|-------------|
| Battery Slider → Model → Circuit → Cap | **[源码一致]** | `BatteryVoltageSlider` → `Battery.voltage`；min/max/default/snap 对齐 |
| Plate Area → C → Q/V/E/Graphs/VM | **[源码一致]** | `PlateAreaDragHandler` LinearFunction + quantize |
| Plate Separation → 同上 | **[行为一致]** | 公式/quantize 对齐；drag 用 **delta** 而非 PhET 绝对 Y+clickOffset → **[有意差异]** |
| Switch = topology 非 Toggle | **[源码一致]** | `setCircuitConnection` + disconnected Q；两态 BATTERY/OPEN |
| Plate Charges 可视化 | **[源码一致]** | `numberOfCharges`；visibility 仅 view |
| Electric Field | **[源码一致]** | E=V/d + spacing；default hidden |
| Capacitance Bar Graph | **[行为一致]** | live；布局 **[视觉近似]** |
| View panel 不改物理 | **[源码一致]** | `ClbViewControlPanel` |

### C. Voltmeter（§15–29）

| 规格 | 状态 | 备注 |
|------|------|------|
| Toolbox→Body/Probe→tip hit→signed ΔV/`?` | **[源码一致]** | `VOLTMETER_FINAL_AUDIT.md` |
| Body 拖不动 Probe | **[源码一致]** | 已测 |
| Probe 独立 + tip-only | **[源码一致]** | 已测 |
| 非 nearest-widget / 非 abs | **[源码一致]** | 已测 |
| Return eroded(40) | **[源码一致]** | Flutter 额外 `reset()` = 清洁 dock **[有意差异]** vs PhET hide-only |

### D. Light Bulb（§30–42）

| 规格 | 状态 | 证据 / 缺口 |
|------|------|-------------|
| 充电→接灯泡→RC 放电 | **[源码一致]** | `LightBulbCircuit.step` → `capacitor.discharge` |
| 亮度随放电（非仅 Switch） | **[行为一致]** | halo ∝ \|V/R\| LinearFunction 0…5e-13→0…225；绘制 **[视觉近似]** |
| Capacitance / Plate Charge / Stored Energy | **[行为一致]** | live bars |
| Current Indicators | **[行为一致]** | 触发+方向+淡出；**Pause 时淡出仍跑** → **[待确认]** P1 |
| TimeControl Play/Pause/Step | **[源码一致]** | Pause 不 `circuit.step`；step dt=0.2；slow=0.125 |
| Stopwatch ↔ sim clock | **[行为一致]** | 同 step gate；无拖拽回收 toolbox → **[有意差异]** |

### E. Reset / View / 数据流（§43–50）

| 规格 | 状态 | 备注 |
|------|------|------|
| View 不改物理 | **[源码一致]** | — |
| Reset 全状态 | **[源码一致]** | — |
| Interaction→Model→Physics→Render | **[行为一致]** | 主链闭合 |
| Visual+Functional 同时正确 | **[待确认]** | 功能主链 OK；像素级 Visual Diff 未全过 |

---

## §48 易错清单对账

| 易错项 | 当前 |
|--------|------|
| Slider 只改 UI | ✅ 否 — 写 Model |
| Plate 只改位置 | ✅ 否 — 改 separation/area + C |
| Switch 只有视觉 | ✅ 否 — topology |
| Wire 只绘图 | ✅ 否 — tip hit 用 stroked path |
| VM 直接 batteryVoltage | ✅ 否 |
| nearest Widget 猜读数 | ✅ 否 |
| probe body 测量 | ✅ 否 — tip |
| Probe 不能独立 | ✅ 否 |
| Body 拖带走 Probe | ✅ 否 |
| 无效区显示 0 | ✅ 否 — `?` |
| abs 丢符号 | ✅ 否 |
| 读数仅 drag end | ✅ 否 — 实时 |
| Toolbox/Scene 生命周期分裂 | ✅ 基本统一 |
| Bulb 只看 Switch | ✅ 否 — 看 I(V) |
| Current 静态箭头 | ⚠️ Capacitance 无 step → **可能失效** |
| Pause 后仍放电 | ✅ LB Pause 停 step；⚠️ 电流淡出仍动 |
| Stopwatch 脱节 | ✅ 绑 clock；UI 简化 |
| View 改 Model | ✅ 否 |
| Reset 只恢复 UI | ✅ 否 |

---

## §51 验收操作清单（自动化 + 人工）

### Capacitance（1–21）

| # | 操作 | 自动化/证据 | 人工 |
|---|------|-------------|------|
| 1–3 | V / Area / Sep | model + physics tests | 建议手测手感 |
| 4 | Switch | circuit tests | 手测 snap |
| 5–7 | View toggles | code review view-only | 手测 |
| 8–18 | Voltmeter | **20 PASS** audit tests | 手测 grab |
| 19–20 | 改 V 读数变 | live_reading_refresh | 手测 |
| 21 | Reset | reset 顺序对齐源码 | 手测 |

### Light Bulb（1–18）

| # | 操作 | 自动化/证据 | 人工 |
|---|------|-------------|------|
| 1–6 | 充放电亮灯 | discharge 源码对齐 | **必手测** 亮度衰减 |
| 7–12 | Graphs / Current | live ListenableBuilder | 手测淡出 |
| 13–16 | Pause/Resume | step gate | **必手测** + 切屏 |
| 17 | Voltmeter | 同链 | 手测 |
| 18 | Reset | 源码对齐 | 手测 |

---

## 优先修复队列（不重写架构）

### P0 — **已清零**（2026-09-14）

见 `P0_FIX_REPORT.md`：隐藏屏不 step；Capacitance 接入 `model.step`。

### P1 — **已清零**（2026-09-14）

见 `P1_FIX_REPORT.md`：

1. Plate separation `clickYOffset`（非 delta）  
2. Pause 冻结 current fade（`stepEmitter` 语义）`[源码一致]`  
3. Stopwatch toolbox 拖出 / 全 bounds 回库 `reset`

### P2（Visual）

4. TimeControl / Reset 按钮 / Bulb halo 视觉 Diff。  
5. 三视口截图对照官方 URL。

---

## 相关文档

| 文档 | 用途 |
|------|------|
| `VOLTMETER_FINAL_AUDIT.md` | 电表交互验收 |
| `VOLTMETER_INTERACTION.md` | tip / switch / wire 基准 |
| `SOURCE_BEHAVIOR_MATRIX.md` | 早期行为矩阵 |
| `COMPLETION_REPORT.md` | Phase 10 交付（本审计为其功能复核层） |

---

## 结论句

> 核心仿真闭环（电容关系、开关拓扑、RC 放电、有符号电表、View/Reset）已达到「真实 Simulation」标准；  
> 要达到规格 §53「感觉就是原版 PhET」的最终声明，须完成 §51 人工验收 + P1 backlog；**P0 生命周期/电流时钟已关闭**（`P0_FIX_REPORT.md`）。
