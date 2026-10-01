# P1_FIX_REPORT — Plate Separation / Current Fade / Stopwatch

> 日期：2026-09-14  
> 范围：仅 P1-1 / P1-2 / P1-3（未动 P0 Tab/Ticker、Voltmeter 测量链、`lib/common`、其他 sim）  
> 结果：**P1: 0**

---

## P1-1 Plate Distance Drag clickOffset

### Source Evidence

`PlateSeparationDragHandler.js`：

- `start`: `clickYOffset = pMouse.y - modelToViewXYZ(0, -sep/2, 0).y`
- `drag`: `yView = pMouse.y - clickYOffset`；`sep = clamp(2 * viewToModelDeltaXY(0, -yView).y)`；quantize `round(5e3·s)/5e3`
- **非** delta 累加；**非** pointer 瞬移到 handle 中心

### Old Behavior

`PlateHandleGestureLayer` 用 `d.delta.dy` 累加 separation。

### Correct Behavior

绝对 pointer Y + `clickYOffset` → model separation。

### Implementation

- 新增 `plate_separation_drag_handler.dart`
- `PlateHandleGestureLayer` 对 separation 使用与 Area 相同的 panStart/Update 绝对坐标模式

### Tests

`plate_distance_drag_test.dart`：click offset 无跳位、绝对映射、bounds、reset

### Regression

Area drag 仍用 `PlateAreaDragHandler`（未改算法）

---

## P1-2 Pause 时 Current Indicator Fade

### Source Evidence

`CurrentIndicatorNode.js`：`animation.step(dt)` 经 `model.stepEmitter`  
`CLBModel.js`：`stepEmitter.emit` **仅**在 `isPlaying || isManual`  

→ **Pause 冻结 fade opacity**（非 wall-clock）——判定 **[源码一致]**

### Old Behavior

`CurrentIndicatorsLayer` 自有 Ticker 用墙钟推进 fade，Pause 后仍淡出。

### Correct Behavior

`_tick`：`TickerMode` + `model.isPlaying` 门控后才推进 `_fadeElapsed`。

### Implementation

`current_indicators_layer.dart` — Pause/hidden tab 不推进 fade；Resume 继续。

### Tests

`current_indicator_pause_test.dart`：pause / resume / reset

---

## P1-3 Stopwatch Return to Toolbox

### Source Evidence

`CLBLightBulbScreenView.js:61-67`：

```js
end: () => {
  if (toolboxPanel.bounds.intersectsBounds(stopwatchNode.bounds)) {
    model.stopwatch.reset();
  }
}
```

- **全 bounds 相交**（非 voltmeter 的 eroded(40)）
- `reset()` → 隐藏 + 清时间 + 停表（无 snap 动画）
- Toolbox 拖出：pointer − (w/2, h/2) 居中（`ToolboxPanel.js`）

### Old Behavior

仅 tap 显示固定位置；无拖动；无回库。

### Correct Behavior

Toolbox 拖出/点出 → 场景拖 body → ∩ toolbox → `returnStopwatchToToolbox()`。

### Implementation

- `ClbModel`：`stopwatchX/Y`、`placeStopwatchAt`、`returnStopwatchToToolbox`
- `stopwatch_interaction.dart`：`maybeReturnStopwatchToToolbox`
- `ToolboxPanel`：timer 槽位 pan 抽出
- Light Bulb：`_StopwatchPanel` 可拖 + panEnd 回库

### Tests

`stopwatch_toolbox_test.dart`：drag place / return bounds / return state / reset

---

## 门禁

| Check | Result |
|-------|--------|
| P1-1 clickOffset | **PASS** |
| P1-2 Pause freeze fade | **PASS** `[源码一致]` |
| P1-3 Stopwatch return | **PASS** |
| P0 回归 | **PASS** |
| scoped analyze | **clean** |
| `flutter test test/capacitor_lab_basics/` | 见下 → **107 PASS** |

## 计数

```text
P0: 0
P1: 0
```
