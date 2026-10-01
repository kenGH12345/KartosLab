# Parameter Audit · Loop 3

> 扫描 `lib/astronomy/my_solar_system/` · 2026-09-01  
> 标签：`[MSS-SOURCE]` / `[KEPLER-SECONDARY]` / `[TEMPORARY]` / `[INFERRED]` / `[BLOCKED]`

## 统一链路

```
MySolarSystemConstants  （唯一字面量）
        ↓
SimulationConfig        （运行时读口，可替换）
        ↓
State / Solver / Render / UI
```

禁止在 controller / painter / solver 中重复写魔法数。

---

## [MSS-SOURCE]

| 参数 | 值 | 源 |
|---|---|---|
| `engineTimeScale` | 0.05 | `MySolarSystemModel.ts` |
| `pefrlIterationBudget` | 4000 | `NumericalEngine.ts` |
| PEFRL XI/LAMBDA/CHI | 见 constants | `NumericalEngine.ts` |
| `desiredStepsPerSecond` | 30 | `stepOnce` |
| `stepButtonDt` | 1/8 | `TimePanel.ts` |
| zoomLevel | 1..6 default 4 | `MySolarSystemModel.ts` zoomLevelRange |
| zoomScale | linear 25..125 | `Utils.linear(..., 25, 125, zoomLevel)` |
| default scale @4 | 85 | 同上线性插值 |
| position X/Y range | ±14 / ±8 | `ValuesColumnNode.ts` |
| velocity component range | ±100 | `ValuesColumnNode.ts` |
| mass/pos/vel decimal places | 2 | `ValuesColumnNode.ts` |
| mass UI min | 0.1 | `ValuesColumnNode` MASS_RANGE |
| moreData default | false | `MySolarSystemVisibleProperties.ts` |
| CoM visible default | false | 同上 |
| Follow CoM 条件 | `\|r\|<1 && \|v\|<0.01` → following；按钮 = NOT following | `MySolarSystemModel.ts` |
| CoM 公式 | Σ(m r)/M , Σ(m v)/M | `CenterOfMass.ts` |
| Gravity vector 数据 | `body.gravityForceProperty`（力，非加速度） | `MySolarSystemScreenView.ts` VectorNode |
| Four Star Ballet scale | -1.1 | `LabModel.ts` |
| path strokeWidth | 3 | `PathsCanvasNode` |
| centerOrbitOffset | (100,100) 传入 | `MySolarSystemScreenView.ts`（父类公式 BLOCKED） |

## [KEPLER-SECONDARY]

| 参数 | 值 | 备注 |
|---|---|---|
| `G` | 4.45669 | 见 `G-SOURCE-OF-TRUTH.md` |
| `modelToViewTime` | 1000/12.6 | |
| timeSpeed Fast/Normal/Slow | 7/4, 1, 1/4 | |
| `massToRadius` | max(0.03, 0.023 m^(1/3)) | |
| velocity defaults | velocity=true, path=true, gravity=false, grid=false, tape=false | SolarSystemCommonVisibleProperties |
| `VELOCITY_TO_VIEW_MULTIPLIER` | 50 * 0.01 / VELOCITY_MULTIPLIER | |
| `velocityMinMagnitude` | 1.055 | |
| `INITIAL_VECTOR_OFFSCALE` | -3 | gravity 视口倍率 |
| gravityForceScalePower range | -2..8 default 0 | |
| `GRID_SPACING` | 1 AU | |
| grid lines half-count | 30（共约 60） | Kepler GridPainter |
| measuring tape default | (0,1)→(1,1) AU | |
| tape display | AU, 2 decimals | |
| screen/panel margins | 10 / corner 5 | |
| body hit dilation | 10 view px | |
| velocity grab r | 18 | |
| MVT | Y-up single-point scale | |
| vector arrow | tailWidth 5, head 15 | |

## [TEMPORARY]

| 参数 | 当前值 | 原因 |
|---|---|---|
| `maxPathPoints` | 800 | common 有 MAX_PATH_DISTANCE（view 长度），本机无 |
| `massUiMax` | 300 | Body.massProperty.range.max 在 common；文档 1.5×200 |
| `massSliderStep` | 0.1 | `MASS_SLIDER_STEP` 在 common `[BLOCKED]` |
| `constrainDragPoint` | AABB | closest-point 在父类 `[BLOCKED]` |
| body overlap | \|Δr\|≤r1+r2 | `isOverlapping` 在 common |
| body view radius clamp | 4..80 px | Loop1 绘制安全夹；非源码字面量 |

## [INFERRED]

| 参数 | 值 | 说明 |
|---|---|---|
| overlayMaxW ratio | 0.42 / 160..320 | Loop2 响应式，非原版 |
| Gravity arrow tip model | force × 10^(power-3) × VELOCITY_TO_VIEW | 由 Kepler VectorNode 公式二次推出 |
| CoM marker | red X | MSS `CenterOfMassNode.ts` 一手；尺寸用 XNode 默认 |

## [BLOCKED]（本轮不猜）

- `solar-system-common` 全文：MASS_SLIDER_STEP、MAX_PATH_DISTANCE、Body.mass range.max、VectorNode 精确实现、GridNode、MeasuringTapeNode、constrainDragPoint closest-point、centerOrbitOffset 父类映射
- 本轮保持接口，不编造 closest-point

---

## 散落字面量清理目标（Loop 3）

| 原位置 | 字面量 | 收口到 |
|---|---|---|
| bodies_painter / body_hit_test / controller | `4.0, 80.0` | `bodyViewRadiusMin/Max` |
| path_painter | stroke `3` | `pathStrokeWidth` |
| velocity_vectors_painter | head 15 / tail 5 | constants |
| screen overlay | 0.42 / 160 / 320 | constants `[INFERRED]` |

---

## Loop 5 增量（2026-09-02）

### 新增常量（`my_solar_system_constants.dart`）

| 参数 | 标签 | 说明 |
|---|---|---|
| `overlayMaxWidth()` / `overlayBottomMaxHeight()` | INFERRED | 窄屏 breakpoint 600 |
| `preventCollisionNudgeAu` / `preventCollisionMaxIterations` | TEMPORARY | 替代 common |
| `velocityOffscaleIndicator*` | INFERRED/BLOCKED | VectorNode 几何 |
| `valuesSliderTrackMin/Max` | INFERRED | ValuesPanel |
| `TemporaryImplementations` | — | `config/temporary_implementations.dart` 审计索引 |

### Reset All 恢复项（Flow E 测试）

| 恢复 | 不恢复（preset 切换时保留） |
|---|---|
| preset → sun_planet | — |
| zoom / grid / CoM / tape / gravity visibility | preset 切换保留 zoom、grid 等 |
| velocity + path visibility → 默认 on | — |
| timeSpeed → normal | preset 切换保留 speed |
| tape 默认端点 | — |
| gravityForceScalePower → 0（非 Ballet 特例） | Ballet 加载时再设 -1.1 |

