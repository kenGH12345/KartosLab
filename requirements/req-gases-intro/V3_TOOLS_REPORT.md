# V3 验收报告 — Tools / Instrument Interaction Reconstruction

**日期**：2026-09-06  
**阶段**：V3 完成 · **停止，不进入 V4**  
**Model / Physics / Solver**：**零修改**（工具状态在 View `ToolsController`）

---

## A. Stopwatch source mapping

| PhET | Flutter | 状态 |
|---|---|---|
| `GasPropertiesStopwatchNode` ← scenery-phet `StopwatchNode` | `GasPropertiesStopwatchTool` | [行为一致] 结构 |
| `Stopwatch` model: time / isRunning / isVisible / position | `ToolsController` + `model.stopwatchVisible` | [行为一致] |
| Initial position `(240, 15)` | `ToolsController.stopwatchHome` | [源码一致] |
| Default visible `false` | checkbox → `stopwatchVisible` | [源码一致] |
| Display: 1 decimal + `ps` (not mm:ss) | `'${t.toStringAsFixed(1)} ps'` | [源码一致] |
| Play/Pause + Reset buttons | play/pause + u-turn reset | [行为一致] |
| `step(dt)` only if `isRunning` | sync via model step delta | [行为一致] |
| Independent of sim Play (still needs model step) | same — advances on `stepModelTime` while tool running | [行为一致] |
| Drag on background; bounds = visibleBounds | `onPanUpdate` + clamp to layoutBounds | [行为一致] |
| Max 999.99 → auto pause | `maxTimePs` | [源码一致] |
| Chrome color rgb(80,130,230) | `0xFF5082E6` | [源码一致] 色值 |
| Pixel-perfect StopwatchNode geometry | simplified Material chrome | [有意差异] / 非 [视觉已对齐] |

---

## B. CollisionCounter source mapping

| PhET | Flutter | 状态 |
|---|---|---|
| `CollisionCounterNode` | `CollisionCounterTool` | [行为一致] |
| `CollisionCounter` model | `ToolsController` collision fields | [行为一致] |
| Initial `(40, 15)` Ideal | `collisionHome` | [源码一致] |
| Default visible `false` | checkbox | [源码一致] |
| Count += wall collisions while running | `collisionSolver.numberOfParticleContainerCollisions` | [行为一致] |
| Sample periods `[5,10,20]`, default 10 | Dropdown | [源码一致] |
| PlayResetButton toggles `isRunning` → resets count | `setCollisionRunning` | [行为一致] |
| Sample end → stop, preserve count | syncFromModel save/restore | [行为一致] |
| Hide / change sample → stopAndResetCount | visibility + setSamplePeriod | [行为一致] |
| Drag + DragBoundsProperty | pan + clamp | [行为一致] |
| Bezel/panel colors | rgb(90,90,90) / rgb(254,212,131) | [源码一致] 色值 |
| ShadedRectangle bezel exact geometry | Material bezel margin | [有意差异] |

---

## C. Tool interaction mapping

```
Pointer down/pan → ToolsController.drag*(delta) → clamp(layoutBounds − toolSize)
                 → notify → Positioned(left/top)
Bring to front → frontTool reorder in Stack (toolsParent)

Checkbox Stopwatch/CC → IdealGasLawModel.visible flags
                      → ToolsController.sync visibility edges

Tool Play/Pause (SW) → stopwatchRunning (View)
Tool Play/Reset (CC) → collisionRunning + count reset (View)

Sim step (model) → ToolsController.syncFromModel
  dt = Δ(model.stopwatchPs)
  if SW running → stopwatchTimePs += dt
  if CC running → numberOfCollisions += frame wall hits
```

拖动 **不** 修改 Physics / Solver。

---

## D. Reset behavior

| 项 | Reset All (`_resetAll`) | 源码 |
|---|---|---|
| Stopwatch position | → (240,15) | Stopwatch.positionProperty.reset |
| Stopwatch time / running | → 0 / false | time + isRunning reset |
| Collision position | → (40,15) | positionProperty.reset |
| Collision count / running / sample | → 0 / false / 10 | CollisionCounter.reset |
| Visibility | `model.reset()` → checkboxes false | visibleProperty.reset |

---

## E. V1/V2 regression

| 项 | 结果 |
|---|---|
| V2 Stack / IdealScreenAnchors | **未推翻** |
| Pump / Left wall / Heater / Hold / checkboxes / ±1±50 / assets | **保留** |
| tools 层在 panels 之上 | 对齐 `vBox.moveToBack` | [行为一致] |

**功能回退：无**

---

## F. 测试结果

```
flutter test test/gases_intro  → 18 passed
  (15 model + 3 tools_controller)
flutter analyze lib/gases_intro → 0 errors (info-only cleaned)
```

---

## G. 当前剩余问题

| 项 | 状态 |
|---|---|
| Stopwatch/CC 与 scenery-phet 像素级外形 | [待确认] 非 [视觉已对齐] |
| ComboBox listboxParent 置顶层 | [有意差异] 用 Dropdown |
| model.stopwatchPs 仍每步累加（未改 Model） | [有意差异] UI 用独立 time |
| model.collisionCount 仍全局累加 | [有意差异] UI 用独立 sample 计数 |
| V4 ParticleType radio 图标等 | [待实现] |

---

**状态**：`v3_tools_restored` · 等待确认后再开 V4。
