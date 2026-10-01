# Membrane Transport · NUMERICAL_MODEL

> PHASE 0/1 · 从源码提取的数学模型  
> 主证据：`MembraneTransportConstants.ts`, `MembraneTransportModel.ts`, `RandomWalkMode.ts`, `DirectionalMovementMode.ts`, `RandomWalkUtils.ts`, `doc/model.md`  
> 标记：`[已确认]` / `[待补全]`（蛋白内部状态机细节 Phase 1 深挖）

---

## 1. Coordinate Systems

### Physics (Model)

| 常量 | 值 | 证据 |
|------|-----|------|
| `MODEL_WIDTH` | 200 | Constants |
| `MODEL_HEIGHT` | `200 * 400/534` ≈ **149.8127** | Constants |
| Origin | 观察窗中心；(0,0) 在膜中心 | MVT single-point scale inverted-Y |
| Outside | `y ≥ 0`（计数用 `y >= 0`） | Model.countSolutes |
| Inside | `y < 0` | 同上 |
| `MEMBRANE_BOUNDS` | x∈[-100,100], y∈[-10,10] | Constants |
| `OUTSIDE_CELL_BOUNDS` | membrane.maxY → +MODEL_HEIGHT/2 | Constants |
| `INSIDE_CELL_BOUNDS` | −MODEL_HEIGHT/2 → membrane.minY | Constants |
| `TRANSPORT_PROTEIN_WIDTH` | 25 | Constants |
| Slot positions | 7 slots；`SLOT_MAX_X=84`；等距 | Model 文件头 |
| `OVERALL_ARTWORK_SCALE` | 0.1 | 蛋白/粒子美术→模型 |

### Layout (View)

| 常量 | 值 |
|------|-----|
| Observation window | **534 × 400** |
| Screen margins | X=8, Y=8 |
| layoutBounds | **768×504 惯例** `[推测 joist DEFAULT]` — Phase 1 核实 |
| MVT (observation) | center → observation center；scale = 534/200 |

**规则：粒子位置 ∈ Physics；面板位置 ∈ Layout。禁止混用。**

---

## 2. Time

| 量 | 定义 |
|----|------|
| `dt` | 帧间隔秒（Joist step） |
| `model.time` | 仅 `isPlaying` 时累加的仿真时间 |
| Speed factor | NORMAL → 1.0；SLOW → **0.5** |
| Effective step | `dt_eff = dt * speedFactor`（在 isPlaying 分支内） |
| Step button | **不存在** |

计数更新：`updateSoluteCounts()` 在 step 末尾**始终**调用（暂停时仍刷新计数）。

---

## 3. Variables & State

### Global Model State

- `solutes: Solute[]`, `ligands: Ligand[]`
- `membraneSlots[7]`
- `soluteProperty`, `isPlayingProperty`, `timeSpeedProperty`
- `membranePotentialProperty ∈ {-70, -50, 30}` mV
- `chargesVisibleProperty`, `areLigandsAddedProperty`
- `crossingHighlightsEnabledProperty`, `crossingSoundsEnabledProperty`
- `fluxEntries[]`（窗口 1.0 s）
- `descriptionEventQueue[]`
- per-type `inside/outsideSoluteCountProperties`

### Particle State

- `position: Vector2`
- `type: ParticleType`
- `mode: BaseParticleMode`（FSM）
- dimensions from artwork metrics
- opacity（代谢等）

---

## 4. Constants (Science / Hollywood)

| 名 | 值 | 含义 |
|----|-----|------|
| `TYPICAL_SPEED` | 30 | 模型单位/秒 |
| `CROSSING_COOLDOWN` | 10 s | 非气体跨膜冷却（防来回穿） |
| `MAX_SOLUTE_COUNT` | 200 / type（双侧合计） | 上限 |
| `LIGAND_COUNT` | 7 / ligand type | 预分配 |
| `BIAS_THRESHOLD` | **0.1** | \|gradient\| 超过才偏置 |
| `GRADIENT_BIAS_STRENGTH` | **0.9** | 逆梯度 veto 概率 |
| Gas near-eq cross P | **0.90** | `\|grad\| ≤ threshold` 时 |
| fineDelta / coarseDelta | 10 / 50 | spinner |
| Random walk straight μ,σ | 0.1, 0.2 → clamp [0.01,1] | boxMuller |
| Capture radius | `MEMBRANE_BOUNDS.height/2 * 4` = **40** | `Particle.ts` CAPTURE_RADIUS_PROPERTY；ATP×2 → 80 |

---

## 5. Equations / Rules

### 5.1 Concentration & Gradient

```
count(type, side) = #{ solute | type && (side==inside ? y<0 : y>=0) }

signedGradient(type) =
  total==0 ? 0 : (insideCount - outsideCount) / total
  // >0 ⇒ 内侧更高；<0 ⇒ 外侧更高
```

浓度条图直接绑定 count Property；**不是**单独化学浓度公式。`[已确认]`

### 5.2 Gradient Bias (Passive)

```
movingAgainst =
  (location==outside && gradient>0) ||  // 内侧更高，从外向内 = 逆？
  (location==inside  && gradient<0)

# location = 粒子当前侧；穿膜方向朝向对侧

if movingAgainst && |gradient| > BIAS_THRESHOLD:
  allowCrossing = random() > GRADIENT_BIAS_STRENGTH   # 90% veto
else:
  allowCrossing = true
```

证据：`checkGradientForCrossing`。用于被动扩散与被动蛋白运输。

### 5.3 Gas Membrane Encounter

仅 `oxygen` / `carbonDioxide`：

```
if intersects MEMBRANE_BOUNDS:
  if shouldApplyBiasForGasses:   # |grad| > BIAS_THRESHOLD
    shouldCross = checkGradientForCrossing(...)
  else:
    shouldCross = random() < 0.90
  if shouldCross: mode = PassiveDiffusionMode(direction)
  else: bounce off membrane
```

### 5.4 Passive Diffusion Motion

`DirectionalMovementMode.performDirectionalMovement`:

```
y += sign * (TYPICAL_SPEED * 2/3) * dt * U(0.1, 2)
x += U(-2, 2) * (TYPICAL_SPEED * 5/3) * dt
# 穿越 y=0 时 emit SoluteCrossedMembraneEvent
```

### 5.5 Random Walk

```
each step:
  timeUntilNextDirection -= dt
  if <= 0: new unit direction; resample straight duration
  position += direction * TYPICAL_SPEED * dt   # (via moveParticle)
  try protein interaction (cooldown)
  try membrane interaction (gases / bounce)
  wrap X / bounce Y at cell bounds
```

### 5.6 Who Can Cross How

| Solute | Direct bilayer | Passive channel | Active |
|--------|----------------|---------------|--------|
| O₂, CO₂ | yes (probabilistic) | also via passive protein API | — |
| Na⁺, K⁺ | no | leakage / voltage / ligand（选择性） | Na/K pump |
| Glucose | no | — | Na/Glucose cotransporter（向内） |
| ATP | no | — | 泵底物；水解→ADP+Pi |
| ADP, Pi | runtime products | — | — |

`canSoluteTypeMoveThroughPassiveTransport` = O₂|CO₂|Na⁺|K⁺。`[已确认]`

### 5.7 Flux Window

```
if y_sign flips during step:
  fluxEntries.push({ type, time, direction })
prune entries older than 1.0 s
```

用于条图近瞬时通量可视化（`SoluteBarChartNode`）。

---

## 6. Protein State Machines `[已确认 Phase 1]`

离子选择性（被动通道）在 `RandomWalkMode.handleLeakageChannelInteraction`：

```
sodiumGates = [sodiumIonLeakage|LigandGated|VoltageGated]
potassiumGates = [potassiumIonLeakage|LigandGated|VoltageGated]
// O₂/CO₂ 不走此路径（虽 canSoluteTypeMoveThroughPassiveTransport 含气体，但 gates 列表不含匹配）
```

配体匹配：`triangleLigand` → Na ligand-gated；`starLigand` → K ligand-gated。

### 6.1 LeakageChannel

| 项 | 值 |
|----|-----|
| States | `'open'` only |
| Passive | `!busy && checkGradientForCrossing` |
| Selectivity | 由 type（Na vs K）+ RandomWalkMode gates 列表 |

### 6.2 Voltage-Gated

| Voltage (mV) | Na channel state | K channel state |
|--------------|------------------|-----------------|
| −70 | `closedNegative70mV` | `closedNegative70mV` |
| −50 | **`openNegative50mV`** | `closedNegative50mV` |
| +30 | `closed30mV` | **`open30mV`** |

- 电位变化后延迟 **0.25 s** 才切换 state（`timeSinceVoltageChanged`）
- 关闭时 `clearSolutes` 踢出通道内粒子
- Passive：`isStateOpen && !busy && checkGradientForCrossing`

### 6.3 Ligand-Gated

常量：`REBINDING_DELAY=5`，`BINDING_DURATION=15`，`STATE_TRANSITION_INTERVAL=0.5`

```
closed ──bind──► ligandBoundClosed ──0.5s──► ligandBoundOpen
                      │                         │
                      │                    after 15s (+ no solutes in flight)
                      │                         ▼
                      │              unbind → ligandUnboundOpen ──0.5s──► closed
```

注：源码 type 注释有两处写反；以 `step()` / `bindLigand` / `unbindLigand` 为准。  
`openStates = [ligandBoundOpen, ligandUnboundOpen]`。  
Paused 时 bind 可直接 `ligandBoundOpen`；unbind 可直接 `closed`。  
Passive：仅 `ligandBoundOpen` 且 `timeSinceStateTransition < 15` 且梯度允许。

### 6.4 Sodium-Potassium Pump（主动）

`isAvailableForPassiveTransport = false`。  
`STATE_TRANSITION_INTERVAL = 0.5`。

```
openToInsideEmpty
  ── 3× Na⁺ bound (from inside) ──► openToInsideSodiumBound
  ── ATP binds (inside) ──► openToInsideSodiumAndATPBound
  ── 0.5s ──► splitATP() → ADP released, phosphate stays
              openToInsideSodiumAndPhosphateBound
  ── 0.5s ──► openUpward(): 3 Na⁺ outward
              openToOutsideAwaitingPotassium
  ── 2× K⁺ bound (from outside) ──► openToOutsidePotassiumBound
  ── 0.5s ──► openDownward(): 2 K⁺ inward + phosphate release
              → openToInsideEmpty
```

缺绑定粒子时回退到前态（用户 Eraser/移除）。  
接近条件：Na/ATP 仅 y<0；K 仅 y>0。

### 6.5 Sodium-Glucose Cotransporter（次级主动）

`isAvailableForPassiveTransport = false`。  
需 **outside Na count > inside Na count**；粒子仅从 **外侧**接近。  
位点：left/right = Na⁺；center = glucose。

```
openToOutsideAwaitingParticles
  ── left Na + glucose + right Na all waiting ──► openToOutsideAllParticlesBound
  ── 0.5s ──► openToInside；三者 inward MovingThrough…
  ── all cleared ──► openToOutsideAwaitingParticles

若 lessSodiumOutsideThanInside：释放粒子并重置 awaiting
```

### 6.6 Binding sites

全部经 `MembraneTransportConstants.IMAGE_METRICS` + `getBindingSiteOffset(dimension, site)`  
→ view delta × `OVERALL_ARTWORK_SCALE(0.1)` → model offset。

---

## 7. Randomness Contract (Flutter)

```dart
abstract class MembraneTransportRandom {
  double nextDouble();
  double nextDoubleBetween(double min, double max);
  List<T> shuffle<T>(List<T> list);
  T sample<T>(List<T> items);
}
// Production: seeded or crypto-backed injectable
// Tests: fixed seed → deterministic trajectories
```

禁止：`Random()` 无种子参与核心 step；禁止 `DateTime.now()` 作种子。

---

## 8. Boundary Conditions

- 左右：水平 wrap（非配体）
- 上下：bounce 于 inside/outside bounds
- 配体 focused：限制在 `LIGAND_COLLISION_BOUNDS`
- 膜：非穿透气体则推回；蛋白捕获优先于穿膜判定（同 step 顺序）

---

## 9. Pedagogy Note (from doc/model.md)

数值为教学可视化调参，**非**真实生化速率常数。温度、离子强度、拥挤效应未建模。Flutter 必须忠实当前 Hollywood 参数，不得“修正”成更真实的生化模型。
