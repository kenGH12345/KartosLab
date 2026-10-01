# Phase 7 · Controls / Geometry / Lifecycle

> 完成：2026-09-04 · 源码 `1.3.0-dev.0`  
> **未改**：Canonical / SumVector / EquationsResultant / MathCoordinateTransform / SnapPolicy / Phase 6 交互语义

---

## 0. 结论

1. **Angle 方向已钉死**：`RootVector` 注释 “clockwise” 与实现不符；实现为 `atan2` **逆时针从 +x（model Y-up）**。单测锁定。Flutter canvas（Y-down）弧 sweep = **`-modelAngle`**，对齐 `CurvedArrowNode`（`end = -angle` + anticlockwise flag）。
2. **Base Vector**：Render 层绘制（白填 + stroke `lineWidth=1.5`）；默认隐藏；Equations Cartesian tails `(35,15)/(35,5)` + 初始 xy；不改 Model canonical。
3. **Arrow**：head 12×14、tail 3.5、dynamic + fractional 0.5；短向量缩头；反向由 tip−tail 方向决定。
4. **AC-1**：离开 `VectorAdditionHome` 再进入 → 新 State + 新 Model；无跨访残留。
5. **测试** `flutter test test/vector_addition/` **81 passed** · `analyze` **0 issues**。

---

## 1. Base Vector 几何

| 项 | 源码 | Flutter |
|---|---|---|
| Arrow options | `BASE_VECTOR_ARROW_OPTIONS` + `lineWidth: 1.5` | `strokeWidth: 1.5` |
| Fill / stroke | white / vectorFill | `baseVectorFill` / `effectiveBaseStroke` |
| Visibility | `baseVectorsVisibleProperty` default **false** | `view.baseVectorsVisible` |
| Layer | under main vectors | paint `baseVectors` before vectors |
| Tails (Cartesian) | (35,15), (35,5) | 同（Render 常量） |
| Tip drag | false | 无独立 hit（仅显示） |

系数 NumberPicker / Polar base UI → Phase 8+ 精修（本阶段 visibility + geometry）。

---

## 2. Angle Arc（CurvedArrowNode）

| 常量 | 值 |
|---|---|
| MAX_CURVED_ARROW_RADIUS | 25 |
| MAX_RADIUS_SCALE | 0.79 |
| baseline | min(r/0.60, 55) |
| TEXT_OFFSET | 3.5 |
| ANGLE_UNDER_BASELINE_THRESHOLD | 35° |
| arrowhead | 8×6 |

- 可见：`anglesVisible && isOnGraph && magnitude ≠ 0`
- Label 精度：`VECTOR_VALUE_DECIMAL_PLACES = 1`
- Convention：`signed` [-180,180) / `unsigned` (0,360]；面板 ±180° / 0–360° chips

---

## 3. Vector Values

- Model → `VaSelectedValuesRender` → Panel（**不**在 Panel 重算 tip）
- 折叠 / 展开 / 无选中文案 / \|v\| θ x y
- `angleConvention` 驱动角度读数

---

## 4. Reset / Eraser / Scene

| | Reset | Eraser |
|---|---|---|
| Vectors | 全重置 + active 清空 | 回 toolbox / 离图 |
| Controls | 恢复默认 | **保留** |
| Origin / graph | 恢复 | 不变 |
| Equations | 方程类型 addition | no-op |

Scene：每 Scene 独立 `activeVectors` / graph；Screen 间独立 Model。

---

## 5. AC-1 Home 生命周期

```
Home → VectorAdditionHome(initState → 4 Models)
  → 改 Explore2D
  → dispose（pop）
  → 再 push → 新 Models，activeVectors 空，controls 默认
```

`VaScreenBody.dispose` 停止 toolbox-return `Ticker`。

---

## 6. 测试清单

1. Base / short / reverse arrow geometry  
2. Angle sweep / radius / signed-unsigned / atan2 CCW  
3. Vector Values + convention  
4. Base Vectors toggle + reset  
5. Reset / Eraser / Screen / Scene independence  
6. Home reopen / dispose  

---

## 7. 自动进入 Phase 8

无架构阻塞 → **Phase 8 Visual / Screen Integration**
