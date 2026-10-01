# Model Risk Register

物理真源是 `DensityBuoyancyModel` 的 postStep 与 `PhysicsEngine`，不是中学公式的独立实现。`doc/model.md` 是概述，和代码冲突时以代码为准。当前读到的公式与文档一致。

## Integration

| Item | Source value |
| --- | --- |
| 外层 | `model.step(dt)` 一次对应一帧。谁传入 `dt`、是否限幅、如何 pause：在 joist，**UNKNOWN** |
| 内层 | `world.step(1/120, dt, 30)`。`interpolationRatio = (accumulator % fixed) / fixed` |
| p2 单位 | 长度 × `p2SizeScale` 默认 5，质量 × `p2MassScale` 默认 0.1。模型侧保持 SI |
| 旋转 | `fixedRotation = true`。无转矩 |
| 引擎重力 | `world.applyGravity = false`。重力由 postStep 自己加 |
| 速度钳制 | 速率 > 5 m/s 时设回 5 m/s |
| 弹性 | restitution 0 |
| 摩擦 | 只保留切向 x 非 0 的摩擦方程。竖直摩擦被关掉 |
| 接触刚度 | ground / barrier / dynamic 默认 1e6。ground relaxation 2.5，其余 4 |
| solver | iterations 40，frictionIterations 500，tolerance 1e-10 |

显示用 `interpolatedPosition`，模型力用 step 内的当前值再写入 `*InterpolatedProperty`。视图读插值，避免子步和帧 `dt` 错位。

## Forces (SI, +y up)

在 `engine.addPostStepListener` 里，对每个 visible mass：

1. 读接触力。非有限则当 0。然后 `resetContactForces`。
2. 若在某个 basin 里：`displaced = mass.getDisplacedVolume(fluidY)`，再 `submerged = min(displaced, basin.fluidVolume)`。
3. Applications 可改写 `getUpdatedSubmergedVolume` 与 `getUpdatedMassValue`（船、瓶）。
4. 若 `submerged != 0`：
   - `displacedMass = submerged * pool.fluidDensity`
   - `acceleration = g + getAdditionalVerticalAcceleration(basin)`（基类额外加速度是 0；船的竖直加速度会改浮力）
   - `buoyantForce = (0, displacedMass * acceleration)`
   - 这就是 `F_b = ρ_liquid * V_submerged * g`，方向 +y。`g` 是 `gravityValue`（m/s²），密度 kg/m³，体积 m³，力是牛顿。
5. 粘滞：`ratioSubmerged` 在 `viscositySubmergedRatio = 0` 时恒为 1。`hackedViscosity = 0.03 * (μ/0.03)^0.8`。`F_v = -v * hackedViscosity * max(0.5, m) * ratio * 3000 * viscosityMultiplier`。大小再被 `m * |v| / dt` 封顶，避免反向。小于 1e-6 不加。
6. 无论是否浸没：`gravityForce = (0, -m * g)`。
7. 浸没百分比：`100 * |F_b| / (V * g * ρ_fluid)`，再夹到 0..100。Lab 的排开体积用这个百分比，而不是再算一遍几何。`doc/model.md` 写 `V_disp = F_b / (ρ g)`，与该式一致。

未浸没时浮力向量写 0。空气浮力不做。液面不倾斜。

## Equilibrium

漂浮、下沉、上浮都是同一套力加 p2 积分，没有单独的 “floating state machine”。平衡是接触力 + 浮力 + 重力 + 粘滞在子步里收敛。速度上限和粘滞是数值稳定手段。

## Applications overrides（必须单独移植）

`BuoyancyApplicationsModel` **不**调用 `super.updateFluid()`。船舱是第二个 basin：

- 舱水溢出加回池
- 船被拖出池，舱水回到池
- `FILL_EMPTY_MULTIPLIER = 0.3`
- `BOAT_READY_TO_SPILL_OUT_THRESHOLD = 0.9`
- `BOAT_FULL_THRESHOLD = 0.01`
- 船的竖直加速度会改浮力（`getAdditionalVerticalAcceleration`）
- 若液体密度大于铝，满载船仍可浮（`doc/model.md`）。铝密度 2700，船体材料就是这个密度

瓶子：系统质量含塑料、内部材料和空气。显示密度用总质量除以瓶体积。排水用预计算曲线，不是实时网格布尔。

## Model risks

| ID | Risk | Severity |
| --- | --- | --- |
| MR1 | 用 `F=ρgV` 直接改 y，跳过 p2 子步、接触和粘滞 | HIGH |
| MR2 | 拖拽写成设置坐标。源码是力约束，且拖拽中重力浮力仍在加 | HIGH |
| MR3 | 百分比用几何浸没体积，而源码用当前浮力反推 | HIGH |
| MR4 | 船瓶照立方体排水 | HIGH |
| MR5 | Duck 用鸭子网格算排水。源码池排水是椭球 | MEDIUM |
| MR6 | 粘滞用真实蜂蜜 2.5 Pa·s。源码蜂蜜是 0.03 | MEDIUM |
| MR7 | 外层 `dt` 策略未知，固定 16 ms 可能和 joist 不一致 | MEDIUM |
| MR8 | common SHA 与 lockfile 不一致，公式可能和 2025-02 的 buoyancy 有差 | MEDIUM |
