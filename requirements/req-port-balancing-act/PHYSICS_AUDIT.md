# Balancing Act — Physics Audit

> Phase 0 · Source-only · 2026-09-23  
> **禁止**用教科书公式替代源码。下列公式均来自 `Plank.ts` / `MassForceVector.ts`。

---

## 1. Units & coordinate system

| Item | Value |
|------|-------|
| Length | meters |
| Mass | kilograms |
| Model origin | 地面、支点正下方中心 `(0,0)` |
| Model Y | 向上为正 |
| View Y | 倒置（`createSinglePointScaleInvertedYMapping`） |
| Tilt sign | 0=水平；**正=左倾**；负=右倾 |

---

## 2. Lever geometry

| Symbol | Value | Source |
|--------|-------|--------|
| `PLANK_LENGTH` | **4.5 m** | `Plank.ts` L28 |
| `PLANK_THICKNESS` | **0.05 m** | L29 |
| `PLANK_MASS` | **75 kg** | L30 |
| `INTER_SNAP_TO_MARKER_DISTANCE` | **0.25 m** | L31 |
| `NUM_SNAP_TO_POSITIONS` | `floor(4.5/0.25 - 1)` = **17** | L32 |
| `MOMENT_OF_INERTIA` | `75 * (4.5² + 0.05²) / 12` | L33 |
| Max mass distance from center | `(17-1)*0.25/2` = **2.0 m** | L536 |
| `PLANK_HEIGHT` | **0.75 m** | `BalanceModel.ts` L24 |
| `FULCRUM_HEIGHT` (pivot Y) | **0.85 m** | L23 |
| Pivot position | `(0, 0.85)` | L49 |
| Plank bottom position | `(0, 0.75)` | L48 |
| Attachment bar length | 0.10 m（pivot − plank bottom） | 几何差 |
| Fulcrum size | width 1 m, height 0.85 m | `Dimension2(1, FULCRUM_HEIGHT)` |
| `LEG_THICKNESS_FACTOR` | 0.09 | `Fulcrum.ts` |
| Support column width | 0.35 m | `LevelSupportColumn.ts` |
| Support column x | **±1.625 m** | `BalanceModel.ts` L55–57 |
| `maxTiltAngle` | `asin(0.75 / 2.25) = asin(1/3) ≈ 0.3398 rad` | `Plank.ts` L123 |

**支点固定**：用户不可拖动 pivot / fulcrum。

---

## 3. Gravity

**唯一重力常量** — `MassForceVector.ts` L15：

```typescript
const ACCELERATION_DUE_TO_GRAVITY = -9.8; // meters per second squared.
```

显示力矢量：

```typescript
vector: new Vector2( 0, mass.massValue * ACCELERATION_DUE_TO_GRAVITY )
```

**结论**：g **只用于力箭头显示**，**不进入** `updateNetTorque` / 角加速度。

---

## 4. Torque

### 4.1 Dynamics net torque (`updateNetTorque`, L494–503)

仅当 `columnState === NO_COLUMNS`；否则 `currentNetTorque = 0`。

```typescript
this.currentNetTorque += this.getTorqueDueToMasses();
this.currentNetTorque += ( this.pivotPoint.x - this.bottomCenterPositionProperty.get().x ) * PLANK_MASS;
```

Plank 自矩：`(pivotX − bottomCenterX) × 75` — **无 g**。

### 4.2 Mass torque (`getTorqueDueToMasses`, L506–511) — 字面源码

```typescript
torque += this.pivotPoint.x - mass.positionProperty.get().x * mass.massValue;
```

因 `*` 优先于 `-`，等价于：

\[
\tau_{\text{masses}} = \sum_i \big( x_{\text{pivot}} - x_i \cdot m_i \big)
\]

`pivotX = 0` 时：\(\tau = -\sum m_i x_i\)。

**迁移硬性要求**：按字面复刻，不要“修正”为 `(pivotX - x) * m`。

### 4.3 Tip direction (Game)

`BalanceGameModel.getTipDirection`：
- `getTorqueDueToMasses() < 0` → 右侧下倾
- `> 0` → 左侧下倾
- `=== 0` → 保持平衡

---

## 5. Balance conditions

### 5.1 `Plank.isBalanced()` (L484–491)

```typescript
unCompensatedTorque += mass.massValue * this.getMassDistanceFromCenter( mass );
return Math.abs( unCompensatedTorque ) < BASharedConstants.COMPARISON_TOLERANCE; // 1E-6
```

- 使用 **表面有符号距离**（落板时存储），非瞬时笛卡尔 `x`
- **不**考虑支撑柱
- 与动力学力矩公式不同 — 可能在倾斜时不一致（源码 quirk）

### 5.2 Game tilt-prediction “balanced”

`getTorqueDueToMasses() === 0` — **精确浮点相等**，非 tolerance。

### 5.3 Visual level snap

`|newTiltAngle| < 0.0001` → 强制 `θ = 0`（`Plank.step` L181–184）。

---

## 6. Angular dynamics (`Plank.step`)

```text
updateNetTorque()
α = τ / I
if |α| ≤ 1e-5 → α = 0
ω += α                    // 注意：无 × dt
if |ω| ≤ 1e-5 → ω = 0
θ_new = θ + ω · dt
if |θ_new| > maxTiltAngle → clamp, ω = 0   // 触地
else if |θ_new| < 1e-4 → θ = 0
if θ changed → updatePlank() + updateMassPositions()
ω *= 0.91                 // 每 step 阻尼（非 ×dt）
update activeDropPositions
```

| Quantity | Formula / value |
|----------|-----------------|
| \(I\) | `PLANK_MASS * (L² + T²) / 12` |
| \(\alpha\) | `τ / I` |
| \(\omega\) update | `ω += α`（无 dt） |
| \(\theta\) update | `θ += ω·dt` |
| Damping | `ω *= 0.91` per step |
| Ground | clamp to ±maxTiltAngle |

**帧率敏感**：α 累加无 dt、阻尼按帧 — Flutter 实现时需记录为已知 quirks（P1/实现决策，非 P0）。

---

## 7. Column / stand semantics

| `ColumnState` | Physics | Typical UI |
|---------------|---------|------------|
| `DOUBLE_COLUMNS`（默认） | `forceToLevelAndStill()`：θ=0, ω=0；τ=0 | Intro/Lab 两灰柱可见 |
| `NO_COLUMNS` | 自由动力学 | 柱隐藏 |
| `SINGLE_COLUMN` | `forceToMaxAndStill()`：θ=+maxTiltAngle, ω=0 | Game 倾斜支撑柱 |

Intro/Lab `ColumnOnOffController`：仅 **DOUBLE ↔ NO**。  
柱不产生冲量；通过 **强制角度 + 力矩归零** 模拟支撑。

---

## 8. Mass placement (snap)

**离散吸附，非连续滑动。**

算法 `getOpenMassDroppedPosition`：
1. 沿 plank 顶面生成 17 个 snap 点，间距 0.25 m，绕 pivot 旋转
2. 奇数槽 → **去掉中心槽**（不能放在 fulcrum）
3. 占用判定：与已有质量距离 `< 0.025 m`（INTER_SNAP/10）
4. 候选：`|Δx| ≤ 0.25 m`；取最近

成功 `addMassToSurface`：设位置、存有符号距离、`onPlank=true`、更新力矢量。

---

## 9. Mass catalog (exact kg from source)

### Image / human

| Class | kg | Visual asset (typical) |
|-------|---:|------------------------|
| SodaBottle | 2 | sodaBottle.svg |
| SmallBucket | 3 | yellowBucket / blueBucket |
| TinyRock | 4 | tinyRock.svg |
| FireExtinguisher | 5 | fireExtinguisher.svg |
| FlowerPot | 5 | flowerPot.svg |
| Puppy | 6 | puppy.svg |
| Television | 10 | oldTelevision.svg |
| SmallTrashCan | 10 | trashCan.svg |
| PottedPlant | 10 | pottedPlant.svg |
| CinderBlock | 12 | cinderBlock.svg |
| Tire | 15 | tire.svg |
| LargeBucket | 15 | metalBucket.svg |
| Boy | 20 | regional boy SVG |
| MediumBucket | 20 | (bucket) |
| SmallRock | 30 | rock*.svg |
| Girl | 30 | regional girl SVG |
| MediumRock | 40 | rock*.svg |
| LargeTrashCan | 40 | trashCan.svg |
| Crate | 45 | woodCrateTall.svg |
| BigRock | 45 | rock*.svg |
| Woman | 60 | regional woman SVG |
| FireHydrant | 60 | fireHydrant.svg |
| Man | 80 | regional man SVG |
| Barrel | 90 | barrel.svg |

### BrickStack
- `BRICK_MASS = 5` kg/砖；stack mass = `numBricks × 5`
- 尺寸：宽 0.2 m，高 `0.2/3` m/砖
- Lab 提供 1–4 砖 → 5/10/15/20 kg

### MysteryMass
默认（非 stanford）：`[20, 5, 15, 10, 3, 50, 25, 7.5]` kg → A–H  
Stanford：`[15, 50, 2, 7, 32, 23, 18, 54]` kg

---

## 10. Attachment bar

**无 Model 类。**  
几何由 `Plank.updatePlank` 旋转 pivot→bottomCenter 向量驱动。  
View：`AttachmentBarNode`（程序绘制）。

---

## 11. Migration implications

1. 不要引入真实物理引擎替換 Plank.step。
2. 不要把 g 乘进动力学力矩。
3. 严格复刻 `getTorqueDueToMasses` 运算符优先级。
4. Snap 必须 0.25 m 离散网格。
5. DOUBLE_COLUMNS 时禁止自由旋转。
