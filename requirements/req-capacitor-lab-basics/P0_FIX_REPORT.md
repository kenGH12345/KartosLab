# P0_FIX_REPORT — Hidden Ticker + Capacitance step

> 日期：2026-09-14  
> 范围：仅 P0-1 / P0-2（不修 P1）  
> 结果：**P0: 0**

---

## P0-1：Tab 切换后停止隐藏屏 Ticker

### Root Cause

`KratosTabSwitcher` 保持双屏挂载（保留仿真状态）。Light Bulb 使用 `createTicker → model.step`。若隐藏屏 ticker 仍调度，RC 放电会在不可见时继续。

### Source Evidence

- PhET：仅 active screen 的 sim loop 推进（Joist screen 生命周期）
- KARTOSLAB：`KratosTabSwitcher` 已对每个 child 包 `TickerMode(enabled: i == _index)`（`kratos_tab_bar.dart`）— **未改 common / Home / Tab 架构**
- Flutter：`TickerMode` 禁用时 mute 后代 `Ticker`，不回调

### Old Behavior

审计认为隐藏 LB 仍 `step`（未用回归测试钉死）。Capacitance 无 sim ticker。

### Correct Behavior

- 可见 Tab：`TickerMode.enabled == true` → ticker 回调 → `model.step(dt)`（且 `isPlaying`）
- 隐藏 Tab：muted → **不**推进 time-dependent state
- 切回：同一 ticker 恢复，不重建、不 double-step
- dispose：`_ticker.dispose()`

### Implementation

- 依赖已有 `TickerMode` 门控（不重构 Tab）
- `LightBulbInteractiveScreenBody._onTick` / `CapacitanceInteractiveScreenBody._onTick` 增加  
  `TickerMode.valuesOf(context).enabled` 守卫（防 double-step）

### Tests

`test/capacitor_lab_basics/p0_clock_lifecycle_test.dart`

- `hidden_tab_does_not_step`
- `tab_switch_does_not_duplicate_ticker`
- `pause_freezes_current_state`（含 Pause 跨 Tab）
- `reenter_restores_clock`
- `dispose_stops_clock`

### Regression

Pause / Resume / Reset / Re-entry / Dispose 覆盖于上述 + 既有 `home_lifecycle_test` / `circuit_model_test`。

---

## P0-2：Capacitance 屏 `model.step()`

### Root Cause

Capacitance 屏无 UI clock → `CapacitanceModel.step` 从未从 View 调用 → `currentAmplitude`（dQ/dt）不更新 → Current 可视化链断。

### Source Evidence

- `CLBModel.js` `step(dt)` → `circuit.step` → `updateCurrentAmplitude`
- `ParallelCircuit.updateCurrentAmplitude`：`I ≈ dQ/dt`
- Flutter Model 已实现；缺的是 **可见屏 clock**

### Old Behavior

仅手动/测试调用 `model.step`；交互屏无 Ticker。

### Correct Behavior

```text
Visible Capacitance
  → Ticker (TickerMode gated)
  → CapacitanceModel.step(dt)
  → circuit.updateCurrentAmplitude
  → CurrentIndicatorsLayer
```

不在 Painter 内推导幅度。

### Implementation

`CapacitanceInteractiveScreenBody`：`SingleTickerProviderStateMixin` + `_ticker` → `model.step`（同 LB 模式，尊重 `isPlaying` + `TickerMode`）。

### Tests

- `capacitance_model_step_updates_current`（unit + widget ticker）
- `pause_freezes_current_state`（`isPlaying=false` 不更新 amplitude）

### Regression

既有 `current_indicator_test` / `circuit_model_test` 仍 PASS。

---

## 门禁

| Check | Result |
|-------|--------|
| P0-1 hidden ticker | **PASS** |
| P0-2 capacitance step | **PASS** |
| Pause / Resume / Reset / Tab / Re-entry / Dispose | **PASS** |
| `flutter test test/capacitor_lab_basics/` | **95 PASS** |
| scoped `dart analyze` | **clean**（`TickerMode.valuesOf`） |

## 未做（P1 backlog）

- Pause 时 current fade 仍跑
- Plate separation clickOffset
- Stopwatch toolbox return

## P0 计数

```text
P0: 0
```
