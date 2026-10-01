# FUNCTIONAL_GAP_CLOSURE — Curve Fitting

## 已闭合（相对 PhET 1.1.0-dev.0 源码）

| 能力 | 状态 | 备注 |
|---|---|---|
| Best / Adjustable 拟合 | ✅ | 数学层既有；UI 切换 + 滑块 |
| Linear / Quadratic / Cubic | ✅ | CurveOrderPanel |
| Residuals 竖线 | ✅ | ResidualPainter + clip |
| Values 坐标 / Δy | ✅ | DataPointWidget |
| Bucket 拖出新点 | ✅ | 单球 Listener；非 bucket 整块 GestureDetector |
| Graph 内拖点 | ✅ | Listener + layoutKey 坐标 |
| 拖出图外回桶并移除 | ✅ | animationSpeed=65 |
| Equation accordion | ✅ | undefined / MAX_DIGITS |
| Deviations χ² / r² | ✅ | 完整气压计刻度 |
| ViewOptions wereResiduals | ✅ | panel.reset() |
| Reset All | ✅ | model + viewOptions |
| Home 物理→力学入口 | ✅ | 不改 taxonomy |
| MVT inverted-Y | ✅ | full-bleed origin + graph-column scale |

## 回归修复（2026-09-05）

### [迁移引入：DataPoint Drag / Hit-Test Regression]

布局改为三列后出现拖点失效。根因（非视觉）：

1. **左侧全高列抢命中** — bucket 模型 x≈−13.5 落在左 gutter，Row 左 `SizedBox` 吃掉 pointer  
2. **Bucket 前脸 CustomPaint 默认全矩形 hitTest** — 挡住装饰球  
3. **拖动中 `notifyListeners` 重建整树** — 取消 Flutter pan / 指针手势  

修复：

- 全屏 interaction layer + 侧栏仅 intrinsic hit bounds  
- Hole/Front `IgnorePointer`；每球独立 `Listener`  
- `paintEpoch`：拖动中只 refit + 重绘，不 structural rebuild  
- `addPoint` microtask 延迟 structural notify  
- Hit = `pointRadius(8) + dilation(5)`（`PointNode`）  
- [已确认] PhET 无 grab offset；位置直接跟指针  

测试：`test/curve_fitting/drag_interaction_test.dart`

## 已知差距 / [视觉近似]

| 项 | 说明 |
|---|---|
| Bucket 外形 | scenery-phet 几何移植；非 PNG |
| Equation KaTeX | Text.rich 近似 |
| bumpOut | 固定模型矩形近似 |
| 原版 runtime 截图 | **[待确认：缺少原版运行截图]** |

## 测试

- `flutter test test/curve_fitting` — 含 drag / hit-test  
- `flutter analyze lib/curve_fitting`
