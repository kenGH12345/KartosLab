# Phase 1 — Source Analysis · Energy Skate Park

> 需求：`req-energy-skate-park`  
> 本地版本：`1.6.0-dev.2`（`package.json`）  
> 源码根：`phet sourses/energy-skate-park-main/energy-skate-park-main`  
> 标记：`[已确认]` 有 file:line 证据 · `[推测]` 有依据推断 · `[待确认]` 证据不足

---

## 0. 结论摘要

物理核（Hermite 样条 `numeric.spline` + `SplineEvaluation`、`stepEuler` 顺序、曲率离轨、地面/自由落体重附着、能量守恒修正、摩擦→热）在本地 TS **可完整取证**。四屏各自独立 Model，**不共享**物理状态；仅 `EnergySkateParkPreferencesModel` 跨屏。迁移结论：**原样移植语义**，禁止用教材公式替换 PhET 欧几里得/样条模型。无阻塞 → Phase 2。

---

## 1. 功能 → 源码证据矩阵

| 功能 | 主文件 | 类/方法 | 状态 | 迁移结论 |
|---|---|---|---|---|
| Screen 注册 | `js/energy-skate-park-main.ts:42-47` | Intro→Measure→Graphs→Playground | 4 屏 · Intro 默认 | `[已确认]` 四 Tab |
| Preferences 共享 | 同文件 `:38` + 各 Screen ctor | `EnergySkateParkPreferencesModel` | 非物理 | 跨屏共享外观/单位 |
| Track 样条 | `Track.ts:247-268` | `updateSplines` → `numeric.spline` | 参数 u∈[0,maxPoint] | 禁止 Bezier 替换 |
| Spline 求值 | `SplineEvaluation.ts:37-56` | `atNumber` / `atArray` | 内联 Hermite | 原样移植 |
| Skater 权威态 | `Skater.ts` + `SkaterState.ts` | 见 §4 | SSOT / 步进快照 | Widget 不存速度 |
| 时钟 | `EnergySkateParkModel.ts:71-72,406,542-544` | `EventTimer` + `FRAME_RATE=60` | 无 Clock 类 | EspPhysicsClock 语义对齐 |
| Slow | `:488-491` | `modelIterations % 3 === 0` | 约 1/3 帧 | 禁止改 dt |
| stepEuler | `:1039-1120` | 力→a→u̇→u→v→摩擦热 | 核心 | 见 §6 |
| 摩擦/法向 | `:976-1033` | μ·\|N\| 反向 | 含曲率 | 见 §7 |
| 重力预设 | `EnergySkateParkConstants.ts:23-25,110-112` | Moon 1.6 / Earth 9.8 / Jupiter 24.8 | 幅度正 | Skater 存 magnitude，派生负号 |
| 能量 | `SkaterState.ts:99-115` · `Skater.ts:474-477` | KE/PE/TE/Total | + referenceHeight | 见 §9 |
| 离轨 | `EnergySkateParkModel.ts:1125-1164` | 曲率 vs 向心力 | Stick 可关 | 见 §10 |
| 自由落体/地面 | `:701-942` · `:550-596` | freeFall / ground / reattach | 交叉检测 | 见 §11 |
| Graphs 采样 | `GraphsModel.ts` + `EnergySkateParkSaveSampleModel.ts` | interval 0.01s | position/time | 见 §12 |
| Measure 传感器 | `SkaterPathSensorNode.ts` + `MeasureModel.ts` | probe 阈值 10 view-px | 读 sample | 见 §13 |
| Playground 编辑 | `EnergySkateParkPlaygroundModel.ts` | join/split/delete/toolbox | 全交互 | 见 §14 |
| Skater 拖拽 | `SkaterNode.ts:232-304` | 距轨 <0.5 m 吸附 | 释放记 starting | 见 §15 |
| Reset | `EnergySkateParkModel.ts:416-438` + 子类 | reset / returnSkater / clearThermal | 语义不同 | 见 §17 |
| MVT | `EnergySkateParkScreenView.ts:230-238` | scale=61.40 · y 翻转 | floating | 见 §19 |

---

## 2. Screens & Model ownership `[已确认]`

### 2.1 注册顺序

`energy-skate-park-main.ts:42-47`：

```
IntroScreen → MeasureScreen → GraphsScreen → PlaygroundScreen
```

各 Screen **独立**构造自己的 Model；物理状态（Skater / Track / friction / samples）**不跨屏共享**。

### 2.2 继承与职责

| Screen | Model 类 | 基类链 | 轨道来源 |
|---|---|---|---|
| Intro | `IntroModel` | FullTrackSet → TrackSet → SaveSample → Model | 全套 premade：PARABOLA/RAMP/DOUBLE_WELL/LOOP |
| Measure | `MeasureModel` | 同 Intro | 同上；`tracksConfigurable: true`；无 bar graph |
| Graphs | `GraphsModel` | TrackSet → SaveSample → Model | **仅** PARABOLA + DOUBLE_WELL |
| Playground | `EnergySkateParkPlaygroundModel` | EnergySkateParkModel | 无 premade；toolbox 拖出 3 点轨 |

Premade 类型常量：`PremadeTracks.ts:27` — `TrackTypes = ['PARABOLA','RAMP','DOUBLE_WELL','LOOP']`。

### 2.3 场景切换

`EnergySkateParkTrackSetModel.updateActiveTrack`（`:90-130`）：`sceneProperty` 选中 index 对应 track 设 `physicalProperty=true`；其余非 physical；`skater.resetPosition()`；`trackProperty=null`。

### 2.4 Preferences

`EnergySkateParkPreferencesModel` 在 main 入口单例，注入各 Screen —— 控制外观/加速度单位等，**不是**物理 Model。

**迁移结论**：Flutter 四 Tab 各持一个 ScreenController/Model；preferences 可选全局单例。

---

## 3. Track / ControlPoint / parametricPosition / spline `[已确认]`

### 3.1 ControlPoint

`ControlPoint.ts`：

| 字段 | 含义 |
|---|---|
| `sourcePositionProperty` | 用户拖拽的权威位置 |
| `snapTargetProperty` | 与其他端点临时吸附 |
| `positionProperty` | Derived：有 snap 则跟 snap，否则 source |
| `draggingProperty` | 是否在拖 |
| `limitBounds` | 可选拖拽限位 |

### 3.2 Track 参数化

`Track.updateSplines`（`:247-268`）：

```
parametricPosition[i] = i / controlPoints.length   // 注意：不是 i/(n-1)
x[i], y[i] = controlPoints[i].position
xSpline = numeric.spline(parametricPosition, x)
ySpline = numeric.spline(parametricPosition, y)
```

边界（`updateLinSpace` `:480-492`）：

```
minPoint = 0
maxPoint = (n-1)/n
searchLinSpace = linspace(minPoint-1e-6, maxPoint+1e-6, 20*(n-1))
```

`isParameterInBounds(u)`：`u ∈ [minPoint, maxPoint]`（`:498-500`）。

### 3.3 几何查询

| API | 用途 |
|---|---|
| `getX/getY/getPoint(u)` | 样条求值 |
| `getUnitParallelVector(u)` | 切向单位向量 |
| `getUnitNormalVector(u)` | 法向（左旋切向） |
| `getModelAngleAt` / `getViewAngleAt` | atan2；view 对 y 取负 |
| `getParametricDistance(u0, ds)` | 弧长二分 → Δu（`:623-649`） |
| `getClosestPositionAndParameter` | 粗采样 + 40 次二分（`:300-358`） |
| `getCurvature(u, out)` | 见 §10 |

**弧长细分**：`getArcLength` 用 `numSegments=4`（Java 原版 10，性能折中 `:596-597`）。

**迁移结论**：`parametricPosition` 编码必须与 PhET 一致（`i/n` 非均匀弧长参数）；最近点搜索不可简化为「最近控制点」。

---

## 4. SplineEvaluation & numeric.spline `[已确认]`

### 4.1 numeric.js

`package.json:18-19` preload `numeric-1.2.6.js`。`Track` 调用全局 `numeric.spline` / `numeric.linspace`（Hermite 三次样条，产出 `{x,yl,yr,kl,kr,diff()}`）。

### 4.2 SplineEvaluation（性能特化）

`SplineEvaluation.ts`：从 numeric 抽出并内联 `_at`（`:22-35`）：

```
t = (x1 - x[p]) / (x[p+1] - x[p])
s = t*(1-t)
value = (1-t)*yl[p] + t*yr[p+1] + a*s*(1-t) + b*s*t
```

`atNumber`：二分定位区间 `p`（`:37-56`）。`atArray`：批量求值。

导数：`spline.diff()` 懒加载于 `Track`（角度/法向/曲率）。

**迁移结论**：Flutter 须复刻同一 Hermite 求值（或嵌入等价 numeric.spline）；禁止用 Catmull-Rom / 二次 Bezier「看起来差不多」替代。

---

## 5. Skater / SkaterState：canonical vs derived `[已确认]`

### 5.1 Skater（可变 Axon 模型）`Skater.ts`

**Canonical（权威）**

| Property | 默认/备注 |
|---|---|
| `positionProperty` | `(3.5, 0)` m |
| `velocityProperty` | `(0,0)` |
| `trackProperty` | `null` = 自由/地面 |
| `parametricPositionProperty` / `parametricSpeedProperty` | 在轨时有效 |
| `isOnTopSideOfTrackProperty` | true=轨上侧 |
| `massProperty` | 60 kg（`SkaterMasses.SKATER_1_MASS`） |
| `gravityMagnitudeProperty` | 9.8；派生 `gravity = -magnitude`（`:188-194`） |
| `referenceHeightProperty` | 0；范围 Intro 等 `[0,8]`，Graphs `[0,4.5]` |
| `thermalEnergyProperty` | J，≥0 |
| `userControlledProperty` | 拖拽中 |
| `directionProperty` | `'left'\|'right'` |
| `starting*` | returnSkater 用 |

**Derived / 批量更新**

| 量 | 来源 |
|---|---|
| `kineticEnergy` / `potentialEnergy` / `totalEnergy` | `updateEnergy()` `:474-477` |
| `speedProperty` | `\|v\|` |
| `angleProperty` | 在轨时由 track view angle 写入 |
| `headPositionProperty` | 饼图定位 |
| `hasMovedProperty` | vs startingPosition |
| `allowClearingThermalEnergyProperty` | thermal > `1E-2` |

拖拽时强制 `v=0`（`:316-320`）。

### 5.2 SkaterState（不可变步进快照）`SkaterState.ts`

步进内只改 State，结束一次 `setToSkater`（`:130-155`），避免每小步触发 UI。

快照字段：`gravity, referenceHeight, mass, track, angle, isOnTopSideOfTrack, parametricPosition, parametricSpeed, userControlled, thermalEnergy, positionX/Y, velocityX/Y`。

能量（`:99-115`）：

```
KE = ½ m (vx²+vy²)
PE = -m · gravity · (y - referenceHeight)   // gravity 已为负
Total = KE + PE + thermal
```

**迁移结论**：与 Collision Lab 的 BallState 同构——物理环用不可变快照；Widget/Painter 只读 RenderData。

---

## 6. step / constantStep / EventTimer / FRAME_RATE / slow `[已确认]`

| 符号 | 值/行为 | 证据 |
|---|---|---|
| `FRAME_RATE` | `60` | `EnergySkateParkModel.ts:72` |
| `dt` | `1/60` s 固定 | `:467`, `:447` |
| `eventTimer` | `EventTimer(ConstantEventModel(60), constantStep)` | `:406` |
| `step(dt)` | 墙钟 dt → `eventTimer.step(dt)` | `:542-544` |
| `isPlaying` | false 时 constantStep 不跑物理 | `:473` |
| userControlled | 拖拽中不步进 | `:473`, `stepModel:1496-1500` |
| Slow | `TimeSpeed.SLOW` 时仅当 `modelIterations % 3 === 0` 才 `stepModel` | `:488-491` |
| Normal | 每 tick 都 step | 同上 |
| `manualStep` | 暂停时单帧 1/60 | `:444-458` |

**关键**：Slow **不是** `dt*=1/3`，而是跳过 2/3 的物理帧，使轨迹可复现且与 Normal 同 dt。

`stopwatch.step(dt)` 在 `stepModel` 入口（`:1492`），与物理同节奏。

**迁移结论**：`EspPhysicsClock`：Ticker 墙钟 → 累积 → 固定 1/60 事件；Slow 用帧计数取模，勿改积分步长。

---

## 7. stepEuler 精确顺序 `[已确认]`

`EnergySkateParkModel.stepEuler`（`:1039-1120`），在 `stepTrack` 内 **4 次细分**（`numDivisions=4`，`:1171-1174`）：

1. 取 `netForceX = frictionX`（无重力水平分量）  
2. 取 `netForceY = m·g + frictionY`  
3. `a = |F| · cos(trackAngle − FAngle) / m` —— 沿轨切向加速度  
4. `parametricSpeed += a · dt`  
5. `parametricPosition += getParametricDistance(u, v·dt + ½ a dt²)`  
6. 新点 `(getX(u), getY(u))`；`v = unitParallel · parametricSpeed`  
7. 近零速 + 近平坡（`parallelUnitX/Y > 5` 且 speed&lt;1e-2）→ `v /= 2`（`:1069-1073`）  
8. 若 `friction > 0`：  
   - `therm = |F_friction| · Δs`（位移欧氏距离）  
   - `thermalEnergy += therm`  
   - 无 thrust 且非 `trackChangePending`：用热能补/扣以守恒（`:1091-1110`）  
   - `thermal = max(thermal, 原 thermal)`（禁止本步热能下降 `:1115`）  
9. 无摩擦则直接返回新位置状态  

之后 `stepTrack` 调用 `correctEnergy`（启发式速度/位置/热能修正 `:1341-1457`）。

**迁移结论**：顺序与 4 细分、`correctEnergy` 必须保留；不可改成单步 Verlet「更稳」。

---

## 8. Friction / Normal / Thermal `[已确认]`

### 8.1 法向力 `getNormalForce`（`:1014-1033`）

```
curvature → r = min(|r|, 1e5)
netForceRadial ← gravity (0, m g)
curvatureDirection ← normalize(center − skaterPos)
N_mag = m v²/|r| − netForceRadial·curvatureDirection
N = polar(N_mag, curvatureDirection.angle)
```

平坦（方向 NaN）时用重力径向方向代替（`:1022-1025`）。

### 8.2 摩擦力（`:976-1008`）

- `friction===0` 或 `speed < 1e-2` → 0（避免静止被摩擦拉动）  
- 否则 `|F_f| = μ · |N|`，方向 `velocity.angle + π`（与运动相反）  
- 分量：`cos/sin` 分解到 X/Y  

μ 范围：`[0, 0.1]`，默认 **0**（`EnergySkateParkConstants.ts:28-29,102-103`）。

### 8.3 热能

- 在轨：`ΔE_thermal += |F_f|·Δs`（stepEuler）  
- 地面：`stepGround` 类似摩擦减速 + 能量差进热能（`:550-596`）  
- `clearThermal()`：置 0（`Skater.ts:376-378`）  
- Clear 按钮阈值：`thermal > 1E-2`（`THERMAL_ENERGY_CLEAR_THRESHOLD`）

**迁移结论**：N 依赖曲率；μ 无量纲；热能只增不减（Euler 步内 clamp）。

---

## 9. Gravity Moon / Earth / Jupiter / custom `[已确认]`

| 预设 | 幅度 (m/s²) | 证据 |
|---|---|---|
| Moon | 1.6 | `EnergySkateParkConstants.ts:24,111` · `GravityComboBox.ts:33-34` |
| Earth | 9.8 | `:23,110` · `:38-39` |
| Jupiter | 24.8 | `:25,112` · `:43-44` |
| Custom 滑条 | `[1, 26]` magnitude | `MIN/MAX_GRAVITY` 存为 −1/−26，UI 用绝对值 `:106-107` |

`Skater.gravityProperty`（Derived）：`−gravityMagnitude`（始终 ≤0）。物理公式一律用带符号 `gravity`。

### 9.1 状态字段与范围 `[已确认]`

| # | 问题 | 答案 | 证据 |
|---|---|---|---|
| 1 | 真实状态字段 | `skater.gravityMagnitudeProperty`（正值）→ 派生 `gravityProperty = −magnitude` | `Skater.ts:179-194` |
| 2 | slider min/max | magnitude **1 … 26** | `Range(abs(MIN_GRAVITY), abs(MAX_GRAVITY))` · `GravitySlider.ts:28` |
| 3 | 步进 | 普通 **1.0**；Shift **0.1**；page = 5×interval | `GravitySlider.ts:19-23,37-43` · `GravityNumberControl.ts:19-47` |
| 4 | 显示精度 | **1 位小数** `toFixed(g, 1)` | `GravityNumberControl` decimalPlaces:1 · `EnergySkateParkGravityControls.ts:146` |
| 5 | preset vs custom | Combo 项 Moon/Earth/Jupiter + **Custom(null)**；`supportCustom: true` | `PhysicalComboBox.ts:62-99` |
| 6 | 拖 slider → custom？ | 是：physicalValue ∉ presets → adapter=`null`（显示 Custom） | `PhysicalComboBox.ts:126-138`（`===` 精确匹配） |
| 7 | 切 preset 覆盖 custom？ | 是：选 Moon/Earth/Jupiter → `physicalProperty.set(value)` | `PhysicalComboBox.ts:118-121` |
| 8 | custom 即时进物理？ | 是：同一 `gravityMagnitudeProperty` 驱动 solver / PE | `Skater.ts` + `EnergySkateParkModel.stepEuler` |
| 9 | reset | `gravityMagnitudeProperty.reset()` → **9.8**；adapter 同步 reset | `Skater.ts:389` · `PhysicalComboBox.ts:145-147` |
| 10 | Graph/Energy/Skater | 下一步物理立即用新 `gravity`；`updateEnergy` 刷新 PE | 模型链路 |
| 11 | preset 选中表现 | adapter 等于该 preset 值则显示该标签；否则 **Custom** | `PhysicalComboBox.ts:132-138` |
| — | 选 Custom 菜单项 | **不改** physicalProperty（`if (value)` 跳过 null） | `PhysicalComboBox.ts:120` |

### 9.2 分屏 UI `[已确认]`

| Screen | 重力控件 |
|---|---|
| Intro | **仅 Slider**（`sliderOnly`，刻度 Tiny/Lots）`IntroScreenView.ts:21-24` |
| Measure / Graphs / Playground | **NumberControl（数值+滑条）+ ComboBox**（`includeGravityComboBox: true`，默认仍含 NumberControl） |

### 9.3 Flutter 对齐（2026-09-04）

| 项 | Flutter | Tag |
|---|---|---|
| 状态 | `Skater.gravityMagnitude` → `gravity = −magnitude` | **[源码一致]** |
| 范围 clamp | `GravityMagnitude.clamp` → [1,26] | **[源码一致]** |
| Intro | `GravityControls(sliderOnly)` | **[行为一致]** |
| Measure/Graphs/Playground | slider + 1-decimal readout + Combo（含 Custom） | **[行为一致]** |
| preset→custom→preset | Combo adapter exact match；不再把 10 显示成 Earth | **[行为一致]**（此前为 **[迁移功能缺口]**） |
| PE 即时更新 | `EspModel.gravityMagnitude` setter → `updateEnergy()` | **[行为一致]** |

**迁移结论**：Intro 不要只塞星球下拉；幅度正、符号在派生层；Custom 为合法状态，不得标成有意差异。

---

## 10. 能量公式 PE / KE / TE / Total + referenceHeight `[已确认]`

统一公式（`SkaterState` / `Skater.updateEnergy`）：

```
KE     = ½ · m · |v|²
PE     = -m · g · (y - h_ref)     // g≤0 ⇒ PE = m|g|(y−h_ref)
Thermal = thermalEnergy           // 状态变量，非派生
Total  = KE + PE + Thermal
```

`referenceHeight`：

- 默认 0；拖参考线改 `skater.referenceHeightProperty`  
- 范围：常规 `[0,8]` m；Graphs `[0,4.5]`（`GraphsModel.ts:101-103`）  
- Measure：改参考高度时 **重算所有 dataSamples 的 PE/Total**（`MeasureModel.ts:51-55`）  
- 可见性：独立左下 `VisibilityControlsPanel` 含 Reference Height checkbox（`VisibilityControlsPanel.ts:39`）

`barGraphScaleProperty` 默认 `1/30`（`:301`）。

**迁移结论**：禁止 `PE=mgy` 忽略 `h_ref` 或忽略 g 符号约定；Total 必须含 Thermal。

---

## 11. Curvature + leaveTrack（jump / loop）`[已确认]`

### 11.1 曲率 `Track.getCurvature`（`:660-691`）

```
k = (x' y'' − y' x'') / (x'² + y'²)^{3/2}
center = position + n̂/k
r = 1/k
```

### 11.2 离轨判定 `stepTrack`（`:1127-1164`）

```
outsideCircle = sideVector · curvatureDirection < 0
centripetal = m · parametricSpeed² / |r|
netForceRadial = F_without_N · curvatureDirection
leaveTrack = (netForceRadial < centripetal && outsideCircle)
          || (netForceRadial > centripetal && !outsideCircle)
```

仅当 `!isStickingToTrackProperty` 时真正离轨（`:1153`）。Stick 默认 **true**（`:340-343`）。

离轨后：`leaveTrack()` → `nudge`（位置沿法向 ±1e-6，速度向「上」掺 1% `:1256-1279`）→ `stepFreeFall(..., justLeft=true)`（本帧不碰轨 `#142`）。

出轨端：`parametricPosition` 越界 → 自由落体或 `slopeToGround` 特殊落地（RAMP `:1199-1222`）。

**迁移结论**：Loop 顶飞出依赖曲率符号与 Stick 开关；不可改成「y 阈值」启发式。

---

## 12. Free fall / ground / reattach `[已确认]`

### 12.1 `stepModel` 分支（`:1489-1514`）

```
userControlled → 原样返回
else track ≠ null → stepTrack
else y ≤ 0 → stepGround
else y > 0 → stepFreeFall(..., justLeft=false)
```

### 12.2 自由落体 `stepFreeFall`（`:701-741`）

```
a = (0, g)
v' = v + a dt
p' = p + v' dt
```

若有 physical tracks 且非 justLeft → `interactWithTracksWhileFalling`；否则 `continueFreeFall`。若提议点 y&lt;0 且未附着 → `switchToGround`。

### 12.3 重附着 `interactWithTracksWhileFalling`（`:820-918`）

- 对 start / mid / end 三点各求最近点，取距轨迹段最近者（缓解高曲率 `#212`）  
- `crossedTrack`：轨点切向 ±100 的线段与 skater 位移线段求交（`:788-814`）  
- 相交则：速度投影到切向；能量守恒定热能；`attachToTrack`；必要时反转 `parametricSpeed`（`#172`）

### 12.4 地面

- `stepGround`：1D 摩擦滑行，y≡0（`:550-596`）  
- `switchToGround` / `strikeGround`：落地能量校正；竖直落下可 KE→Thermal 并 v=0（`continueFreeFall` `:934-937`）  
- 地面朝向：constantStep 末若在地面按 vx 设 direction（`:526-536`）

**迁移结论**：重附着靠线段相交而非距离阈值；离轨当帧 `justLeft` 防瞬接。

---

## 13. Graphs 采样 `[已确认]`

`GraphsModel` 构造选项（`:111-122`）：

| 参数 | 值 |
|---|---|
| `saveSampleInterval` | **0.01** s |
| `sampleFadeDecay` | 0.5 |
| `maxNumberOfSamples` | 1000 |
| `showBarGraph` | false（用能量图） |

基类 `EnergySkateParkSaveSampleModel.stepModel`（`:188-230`）：`pathVisible`（Graphs 下用于采样开关语义）且间隔到达 → `EnergySkateParkDataSample`；超时 fade 批量删除。

独立变量（`:149-154`）：

- `'position'`（默认）：方向变 → fade；拖拽清数据；return 清数据；限制样本数  
- `'time'`：最多显示 `MAX_PLOTTED_TIME=20` s（`GraphsConstants.ts:20`）；cursor 回放 `setFromSample`（`GraphsModel.stepModel:317-340`）

Y 轴缩放：`PLOT_RANGES` 20 档，默认 index **11** → `[-3000,3000]` J（`GraphsModel.ts:142` · `GraphsConstants.ts:27-48`）。

拖拽且 playing 时 Graphs **额外** `stepModel` 更新能量点（`:301-308`）。

**迁移结论**：采样间隔 0.01 非 1/60；position/time 两模式行为分叉必须保留。

---

## 14. Measure Energy Sensor `[已确认]`

### 14.1 Model

`MeasureModel.ts`：

- `sensorProbePositionProperty` 默认 `(-4, 1.5)` m（`SENSOR_PROBE_HOME_POSITION`）  
- `sensorBodyPositionProperty`：由 layout 设，**reset 不复位 body**（仅 reset probe `:70-74`）  
- `tracksConfigurable: true`；`showBarGraph: false`  
- `speedValueVisibleProperty = true`  
- 控制点拖拽时 `preventSampleSave`（`:60-64`）  
- Intro 同系：`defaultSaveSamples` 对 Intro 为 false，Measure 用基类默认 **true**（路径点默认存）

### 14.2 View `SkaterPathSensorNode`

- Probe 可拖；body 固定显示 KE/PE/Thermal/Total + height/speed  
- 命中：view 坐标距离样本 &lt; **`PROBE_THRESHOLD_DISTANCE = 10`**（`:85`）取最近  
- Halo：`InspectedSampleHaloNode`  
- Layout：legend 左上；body 在 legend 下（`MeasureScreenView.ts:64-68`）

**迁移结论**：传感器读的是 **path samples**，不是实时 skater 射线检测；阈值单位是 view px。

---

## 15. Playground track editing `[已确认]`

`EnergySkateParkPlaygroundModel`：

| API | 行为 |
|---|---|
| `createDraggableTrack` | 3 点 (−1,0)(0,0)(1,0)，`FULLY_INTERACTIVE` |
| `clearTracks` | 清空 tracks/groups；skater 离轨 |
| `reset` | super + clearTracks |
| Model 基类 | `joinTracks` / `splitControlPoint` / `deleteControlPoint` / `trackModified` |

交互标志（`Track.FULLY_INTERACTIVE_OPTIONS`）：`draggable, configurable, splittable, attachable`。

约束：

- `MAX_NUMBER_CONTROL_POINTS = 15`（Constants `:91`）  
- 合并后 `bumpAboveGround`；光滑 `smooth` / `smoothPointOfHighestCurvature`（曲率半径 ≥ 0.03）  
- 编辑当帧 `trackChangePending=true` → **本帧不强制能量守恒**（`#127`）

View：`TrackToolboxPanel` + Eraser；ctor 末 `model.reset()` 清掉 toolbox 创建时的杂轨（`PlaygroundScreenView.ts:122`）。

**迁移结论**：Playground 是完整轨道 CAD；编辑时能量可不守恒是故意设计。

---

## 16. Skater drag `[已确认]`

`SkaterNode.ts` `dragSkater`（`:232-304`）：

1. 指针 → model 坐标；clamp 到 `availableModelBounds`  
2. `getClosestTrackAndPositionAndParameter`；若 `distance < 0.5` m 且 u in bounds → 吸附到轨，设 normal 朝上侧、angle  
3. 否则自由位置，angle=0，up=true  
4. `start`：`userControlled=true`，**清 thermal**（`#32`）  
5. `end`：`skater.released(targetTrack, targetU)` 记录 starting*，v=0  

键盘：`GrabDragInteraction` + `SoundKeyboardDragListener`（dragSpeed 300 view units/s）。

**迁移结论**：吸附阈值 0.5 m 硬编码；释放才写入 return 点。

---

## 17. UI per screen（Intro / Measure / Graphs / Playground）`[已确认]`

公共（`EnergySkateParkScreenView` + `EnergySkateParkControlPanel` 默认）：

- 右栏：Visibility（可配置）· Friction · Gravity · Mass/Skater ·（TrackSet 时）场景轨按钮  
- 左：Bar graph（若 `showBarGraph`）· Pie legend  
- 底中：TimeControl（Play/Pause/Step + Normal/Slow）  
- 左下独立面板：Grid + Reference Height（`VisibilityControlsPanel`）  
- Measuring tape / Stopwatch toolbox（`instrumentToolProperties`）  
- Stick-to-track、Speedometer、Reset All、Return Skater  

| 控件 | Intro | Measure | Graphs | Playground |
|---|---|---|---|---|
| Track 场景按钮 | ✅ 4 轨 | ✅ 4 轨 | ✅ 2 轨 | ❌（toolbox） |
| Bar graph | ✅ | ❌ | ❌（Energy accordion） | ✅（默认 showBarGraph） |
| Pie checkbox | ✅ 默认 | ✅ | ❌ | ✅ |
| Path checkbox | ✅ | （path 常显采样） | — | — |
| Stick to track | ✅ | ✅ | ✅ | ✅ |
| Grid（左下） | ✅ | ✅ | Graphs 主面板关 grid checkbox；左下仍可能有 | Playground 主面板 `showGridCheckbox:false` |
| Speed | ✅ | ✅（值常显） | ✅ | ✅ |
| Gravity Combo | ❌ Slider only | ✅ | ✅ | ✅ |
| Mass | ✅ | ✅（默认） | ✅ | ✅ |
| Friction | ✅ | ✅ | ✅ | ✅ |
| Energy Sensor | ❌ | ✅ | ❌ | ❌ |
| Energy Graph accordion | ❌ | ❌ | ✅ | ❌ |
| Track toolbox / Eraser | ❌ | ❌ | ❌ | ✅ |
| 控制点可配 | 默认 false* | **true** | **true** | **true** |

\*Intro/FullTrackSet 默认 `tracksConfigurable` 来自 options；IntroModel 未开 → premade 通常不可拉形。Measure/Graphs 显式 `true`。

Graphs 额外：独立变量 Position/Time、能量曲线显隐、zoom、橡皮檫清数据；speedometer 特殊锚点（`GraphsScreenView.ts:76-77`）。

---

## 18. Reset behavior `[已确认]`

| API | 行为 | 证据 |
|---|---|---|
| `EnergySkateParkModel.reset` | 可见性/摩擦/Stick/播放/speed/stopwatch/tape；**保留** availableModelBounds；`skater.reset()`（含 mass/g/h_ref）；emit `resetEmitter` | `:416-438` |
| `Skater.reset` | 全属性含 mass/g/referenceHeight | `Skater.ts:384-395` |
| `Skater.resetPosition` | 位置回初始，**保留** mass/g/h_ref | `:401-407` |
| `returnSkater` | 回 starting；清 thermal；同轨同形则保留 parametric | `Skater.ts:444-468` · Model `:1520-1534` |
| `clearThermal` | thermal→0 | Model `:1539-1541` |
| TrackSet.reset | super + configurable tracks.reset + sceneProperty.reset + updateActiveTrack | TrackSet `:231-241` |
| Graphs.reset | + 图 Properties + clearEnergyData | GraphsModel `:282-296` |
| Measure.reset | + sensorProbe reset（body 不 reset） | MeasureModel `:70-74` |
| Playground.reset | super + clearTracks | PlaygroundModel `:73-76` |
| SaveSample.reset | clearEnergyData + pathVisible | SaveSample `:233-238` |

场景切换：`resetPosition` + 离轨，**不是** full reset。

**迁移结论**：Reset All ≠ Return Skater ≠ Clear Thermal ≠ 换轨；勿合并按钮语义。

---

## 19. Clock / animation `[已确认]`

- Joist 每帧调 `model.step(wallClockDt)`  
- 无独立 Clock 类；动画即物理 `constantStep` + View 监听 `skater.updatedEmitter` / Properties  
- `TimeControlNode` 绑定 `isPlayingProperty` + `timeSpeedProperty` + `manualStep`（`EnergySkateParkScreenView.ts:641-662`）  
- Stopwatch：工具箱拖出；`ZERO_TO_ALMOST_SIXTY`；随 `stepModel` 走时  

**迁移结论**：Flutter 用 Ticker；物理与 UI 帧解耦靠固定 1/60 事件。

---

## 20. MVT / layout floating `[已确认]`

`EnergySkateParkScreenView.ts:230-238`：

```
modelOrigin (0,0) → view (layoutBounds.width/2, layoutBounds.height - earthHeight)
scale = 61.40
ModelViewTransform2.createSinglePointScaleInvertedYMapping(...)
```

单位：**米**；+x 右，**model +y 上**（view Y 翻转）。

Floating layout（`:780-834`）：

- `visibleBounds` / `fixedLeft` / `fixedRight`（`EXTRA_FLOAT` 扩展）  
- 右栏、Reset 贴 `fixedRight`；bar/pie/左工具贴 `fixedLeft`  
- `availableModelBoundsProperty` 由可见 play area 反算，限制控制点与 skater 拖拽  

Graphs：能量图右缘对齐 `modelToViewX(5)`（轨右缘，`POSITION_PLOT_OFFSET` 相关坐标系）。

**迁移结论**：NineGrid 中格放整个 ScreenView 局部坐标；scale 61.40 与地面锚点勿随意改，否则轨/图错位。

---

## 21. Migration conclusions & risk ranking

### 21.1 总体

| 项 | 结论 |
|---|---|
| 物理 | **原样移植** stepEuler / 样条 / 离轨 / 能量修正 |
| 结构 | 四独立 Model + 可选共享 Preferences |
| 落点 | `lib/energy_skate_park/`（与 collision_lab 并列） |
| L0 | NineGrid / TabBar 复用；Clock/TimeBar **不**硬套 common 语义 |
| 禁止 | 教材解析解、简化无摩擦无离轨、用 dt 缩放代替 Slow 取模 |

### 21.2 风险排序（高→低）

| 等级 | 风险 | 缓解 |
|---|---|---|
| **P0** | Hermite 样条 + `i/n` 参数 + `SplineEvaluation` 数值偏差 → 轨迹/能量漂 | 对照 numeric 单测；固定种子轨黄金数据 |
| **P0** | `stepEuler` 顺序 / 4 细分 / `correctEnergy` 漏移植 → 能量不守恒、卡轨 | 逐行对齐；能量回归断言 1e-6 |
| **P0** | 离轨/重附着（曲率、crossedTrack、nudge、justLeft） | Loop + Jump 场景黄金用例 |
| **P1** | Slow=`%3` 误实现为 dt/3 | 时钟单测 |
| **P1** | Graphs position/time 双模式 + 回放 cursor | 分模式 AC |
| **P1** | Playground join/split/15 点上限/光滑 | 交互录屏对照 |
| **P2** | Measure probe view 阈值 / floating layout | 多视口截图 |
| **P2** | Intro 无重力 Combo 等分屏 UI 差异 | 对照表 §17 |
| **P3** | a11y / PhET-iO / 区域 skater 图集 | 可后置 |

### 21.3 Phase 1 状态

矩阵完整；核心公式均有 file:line。无待确认阻塞项（样条依赖 numeric 行为已由 `SplineEvaluation` 求值路径钉死）。

**无阻塞 · 自动进入 Phase 2**
