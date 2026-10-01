# Loop 6 · Physics & Performance Audit

> 2026-09-02 · `NumericalEngine.ts` vs Flutter port · 不修改 TEMPORARY 实现

## PEFRL 逐项对照 [MSS-SOURCE]

| 项 | MSS `NumericalEngine.ts` | Flutter `numerical_engine.dart` | 一致 |
|---|---|---|---|
| XI | 0.1786178958448091 | `pefrlXi` | ✓ |
| LAMBDA | -0.2123418310626054 | `pefrlLambda` | ✓ |
| CHI | -0.06626458266981849 | `pefrlChi` | ✓ |
| iterationCount | 4000 / N | `pefrlIterationBudget / active.length` | ✓ |
| 每 k 子步 | 先清零 F → N(N-1)/2 对 → a=F/m → PEFRL 五步共用同一 `accelerations[i]` | 同结构 L74–130 | ✓ |
| notifyPropertyListeners | 仅最后子步 true | `stepOnce` 最后一步 `notify=true` | ✓ |
| collision | 小体失活 + 动量并入大质量 | `checkCollisions()` 同语义 | ✓ |
| getGravityForce d=0 | 返回 0 | 同 | ✓ |

**acceleration reuse**：每个 PEFRL 外层迭代 `k` 内，力/acceleration 只计算一次，五步位置/速度更新均读取同一 `accelerations[i]` 数组——与 TS 注释 *"Same a for all five steps"* 一致。未做跨子步缓存优化。

## stepOnce 链路 [MSS-SOURCE]

```
dt *= timeSpeed
numberOfSteps = ceil(dt * 30)
dt /= numberOfSteps
dt *= engineTimeScale (0.05)
for each sub-step:
  engine.run(dt, notify last only)
  checkCollisions()
  time += dt * modelToViewTime
  optional path points
```

## Reference Regression

SUN_PLANET 固定初值，`stepOnce(1/8)` ×100 后 planet 位置 golden（见 `numerical_regression_test.dart`）。

机械能：双计数 PE 已修正；100 步相对漂移 < 5%。

## 长时间稳定性（200 × stepOnce(1/60)）

8 preset：无 NaN/Inf、body 数不变、path ≤ maxPathPoints(800)。

## 碰撞 [TEMPORARY overlap]

- 小撞大 / 大撞小：小体失活，无 NaN
- d=0 力为 0
- 碰撞后 stepOnce 仍 finite

## Path 性能 [TEMPORARY]

- Flutter：`maxPathPoints = 800` 点数上限
- 原版：`MAX_PATH_DISTANCE` 视口长度语义 — **不等价 [BLOCKED]**

## N² Solver / Render 管线

- `engine.run` 内每 k 迭代：N(N-1)/2 力对
- Painters **不** import `numerical_engine` / 不调用 `updateForces`
- Screen `_renderData()` 读 controller 状态 → `MssRenderData` → 多 Painter 消费

## 性能（Stopwatch，桌面 CI 宽容阈值）

| 配置 | stepOnce(1/60) 均值 |
|---|---|
| 2 bodies Intro | < 200 ms |
| 3 bodies Lab | < 250 ms |
| 4 bodies Lab | < 300 ms |
| Four Star Ballet | < 300 ms |

**60 FPS**：单步 < 200 ms 留有 headroom；未做 Windows profile 采样（无 `感觉流畅` 结论）。

## centerOrbitOffset [BLOCKED]

- MSS `MySolarSystemScreenView.ts:70` 传入 `SolarSystemCommonScreenView` `(100,100)`
- 父类 `SolarSystemCommonScreenView` 不在本树 → MVT 映射公式 **未知**
- Flutter `MssMvt` **显式忽略** offset — **不得声称与原版视觉一致**

## constrainDragPoint [TEMPORARY AABB]

- 轴对齐画布夹取；非 closest-point
- zoom 25/85/125 约束点仍 finite
- 不保证 panel 挖空

## isOffscreen [TEMPORARY |r|>50]

影响：
- `bodiesAreReturnable` → Return Bodies UI
- **不**影响 `isActive`、**不**从 engine 剔除
- offscreen body **仍参与** PEFRL

不影响：velocity/gravity painter 过滤（仅 `isActive` + visibility）

## Gravity / Velocity Vector

- Gravity：`BodyRenderDot.gravityForce`（力，非 acceleration）
- Scale：`10^(power + INITIAL_VECTOR_OFFSCALE) * VELOCITY_TO_VIEW`
- Four Star Ballet：load 后 scalePower = -1.1；改 power 后 `gravityArrowScale` 变化
- Velocity：`tip = position + velocity * VELOCITY_TO_VIEW_MULTIPLIER`

## Reset 数值

- `restart`：恢复 `_starting` 快照，time=0，paths 空
- `clearSimulation`：time=0 + paths 空，body 保持 step 后状态
- preset 切换：不 reset zoom/visibility
