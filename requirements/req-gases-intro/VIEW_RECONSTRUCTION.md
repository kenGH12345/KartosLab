# VIEW_RECONSTRUCTION — Gases Intro

**日期**：2026-09-06  
**约束**：**不修改** `lib/gases_intro/model/`；仅 View / painters / widgets / assets / layout。

---

## P0 Layout Bug（已修）

| | |
|---|---|
| 症状 | `RIGHT OVERFLOWED BY 11 PIXELS` |
| 分类 | **[迁移布局 bug]** |
| 根因 | `SizedBox(225)` 内再叠 `margin`+`padding`，Particles spinner 行固有宽 ≈206px > 可用 ≈197px |
| 修复 | Panel 宽 = `rightPanelWidth`（225）= 内容宽；外边距用 Row gap；spinner 用 28×28 shrinkWrap；Home 用 `AspectRatio(1008/618)` 替代 FixedBox→FittedBox |
| 滚动 | Laws 面板 `ListView`（Hold Constant 增高时） |

详见 `VIEW_ASSET_AUDIT.md` §0。

---

## View 结构

```
AspectRatio(1008/618)
  GasesIntroShell
    Row(
      Expanded(SimulationViewport),
      gap 8,
      SizedBox(225, ControlPanel ListView),
    )
```

SimulationViewport：
1. instruments row（thermometer / gauge / eraser / return lid）
2. Expanded(Row(play canvas + bicycle pump))
3. heater + time bar

ControlPanel：Hold Constant（Laws）→ Width / Stopwatch / Collision Counter → Particles ±1/±50

**禁止**：整体 scale 修 overflow；clip 右缘；缩小字体当主修复；发明活塞。

---

## 组件 / Asset

| 区域 | 实现 |
|---|---|
| Gauge | `GaugePainter`（源码几何，非假圆） |
| Thermometer | `ThermometerPainter`（非 Slider） |
| Left-wall Handle | painter + drag（**非活塞**） |
| Pump | `BicyclePumpPainter` + `model.pump` |
| Heater | 炉体 + `flame.png` / `iceCubeStack.png` |
| Particles | shaded sphere geometry |
| Eraser / Reset | svg / png assets |

审计：`VIEW_ASSET_AUDIT.md`

## 绑定（Model API 未改）

`pump` · `setHeatCool` · `beginWidthAdjust` / `setWidth` / `endWidthAdjust` · `eraseParticles` · `reset` · `renderData`

## 验证

```
flutter test test/gases_intro     → 15 passed
flutter analyze lib/gases_intro   → 0 issues
flutter build apk --debug / --release
```
