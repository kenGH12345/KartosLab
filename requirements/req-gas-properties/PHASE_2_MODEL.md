# PHASE 2 — MODEL · Gas Properties

> **状态**：Model / Solver / Unit Tests 完成；**未进入 Phase 3 UI**  
> **基准**：Phase 1 Forensics + 本地 PhET `gas-properties` 源码  
> **代码落点**：`lib/gas_properties/` · `test/gas_properties/`

---

## 1. Implemented

| 模块 | 状态 |
|------|------|
| Constants | ✅ |
| SimulationClock (NORMAL 2.5 / SLOW 0.3 ps/s) | ✅ |
| Particle + ParticleType (Heavy/Light) | ✅ |
| Particle injection `|v|=√(3kT/m)`, 色散 π/2 | ✅ |
| Heat/Cool `v*=(1+f/800)` | ✅ |
| ContainerState + Ideal resize / Explore 做功墙 | ✅ |
| Collision（spatial regions + impulse e=1 + 壁） | ✅ |
| IdealGasLawModel（Ideal / Explore / Energy profile） | ✅ |
| Temperature / Pressure（0.75 ps 采样 + 噪声） | ✅ |
| Hold Constant ×5 + Oops 边界 | ✅ |
| EnergySamplingState（Avg Speed + 19-bin ×2 + zoom） | ✅ |
| Particle collision toggle / Injection T | ✅ |
| DiffusionModel（独立，divider / COM / flow 300） | ✅ |
| Reset / RandomSource(seed) | ✅ |
| Unit tests（23） | ✅ PASS |

**未实现（刻意留给 Phase 3）**：Screen UI、CustomPainter、泵/温度计视觉、Home 挂载。

---

## 2. Architecture

```
lib/gas_properties/
  gas_properties.dart                 # barrel
  gas_properties_constants.dart
  model/
    particle.dart / particle_type.dart / particle_system.dart
    container_state.dart
    hold_constant.dart
    simulation_clock.dart
    random_source.dart
    ideal_gas_law_model.dart          # Ideal | Explore | Energy
    diffusion_model.dart              # 独立，不继承 IdealGasLaw
  solver/
    gas_law_solver.dart               # 纯函数 PV=NkT
    collision_solver.dart
    temperature_solver.dart
    pressure_solver.dart
    hold_constant_solver.dart
    histogram_solver.dart             # EnergySamplingState
```

数据流：

```
SimulationClock.dt
    → IdealGasLawModel / DiffusionModel
    → ParticleSystem / Collision / Hold / T / P / EnergySampling
    → 可读状态（供 Phase 3 View）
```

- **无** Flutter `Ticker` / `ChangeNotifier`（纯 Dart，可 `dart test`）
- 粒子字段可变（对齐 PhET 性能）；步进边界由 Model 统一驱动
- 与已有 `lib/gases_intro`、`lib/diffusion` **解耦**（不修改、不依赖）

### Step 顺序（强制）

`GasPropertiesConstants.stepOrder`：

1. heat → 2. move → 3. escape → 4. container → 5. collide → 6. holdConstant → 7. temperature → 8. pressure

测试断言 `lastStepPhases`。

---

## 3. Constants（关键）

| 常量 | 值 |
|------|-----|
| BOLTZMANN k | 8.316E3 |
| PRESSURE_CONVERSION_SCALE | 1.66E6 |
| ATM_PER_KPA | 0.00986923 |
| Heavy | 28 AMU, 125 pm |
| Light | 4 AMU, 87.5 pm |
| N max | 1000 / species |
| width | [5000,15000] def 10000；Energy 固定 10000 |
| height / depth | 8750 / 4000 pm |
| heatCool divisor | 800 |
| maxPressure | 20000 kPa |
| maxTemperature | 1e5 K |
| wallSpeedLimit | 800 pm/ps |
| pressure refresh | 0.75 ps |
| energy sample | 1 ps |
| histogram | 19 bins；speed 170；KE 8E5 |
| zoom yMax | 2000…50（7 级），默认 index 5 |
| Diffusion width | 16000；flow samples 300 |
| Time NORMAL / SLOW | 2.5 / 0.3 ps/s |
| Step button | 0.2 ps |

---

## 4. Algorithms

### Particle movement
`position += velocity * dt`（model ps）

### Injection
`|v| = sqrt(3kT/m)`；`angle = π - π/4 + U·(π/2)`；多粒子且 PP 开 → Gaussian T

### Heat/Cool
`scale = 1 + factor/800`；`velocity *= scale`

### Wall collision
静态：对应分量取反；Explore 左墙：`vx' = -(vx - wallVx)`；壁速限幅动画宽度

### Particle-particle
Impulse e=1；跳过上一步已接触对；空间分区 `height/4`

### Gas law
`P_kPa = (NkT/V)*1.66E6`；`T = (2/3)⟨KE⟩/k`

### Pressure gauge
累加 dt；≥0.75 ps 刷新；噪声 = Linear(0→maxP, 50→0) × Linear(5→50K, 0→1) × U；Hold pressure* 时禁噪声

### Hold Constant
- nothing / volume / temperature：补偿见源码表  
- pressureV：调宽度 + redistribute；越界 → Nothing + Oops  
- pressureT：`setTemperature(T_ideal)`  
- N=0 / 开盖 / maxT：回退 Nothing

### Energy sampling
1 ps 窗口累加 bin counts / 平均速度后输出；zoom 改 yMax 不改 binWidth

### Diffusion
独立步进：move → flow（无隔板）→ collide（隔板当墙）→ COM → Data；SLOW 改 `psPerSecond`

---

## 5. Tests

命令：

```bash
flutter test test/gas_properties/gas_properties_model_test.dart
```

**结果：23 passed（2026-09-06）**

覆盖：常量、注入、壁/动壁、PP 动量与动能、Gas Law 比例、Heat/Cool、Clock、step 顺序、Hold、Pressure 采样、Histogram/AvgSpeed、collision toggle、Diffusion 隔板/SLOW/reset、Ideal reset、Explore 墙速。

---

## 6. Known Differences

| 项 | 说明 |
|----|------|
| 粒子可变 | 非每帧深拷贝 immutable list；与 PhET 一致偏性能 |
| Ideal 逸出 outside | 有 outside 数组；出界删除需 View 提供 modelBounds（Phase 3） |
| Collision Counter UI | 仅累加 `collisionCount`；采样周期字段预留，完整计数器逻辑 Phase 3 |
| pressureV Oops dialog | Model 记录 `HoldConstantOops`；Dialog UI Phase 3 |
| Diffusion 坐标 | 左下原点简化（宽高不变）；与 PhET 右下原点等价平移 |
| Diffusion PP 跨种 | 开放隔板后交叉碰撞为 O(n²) 简化；N≤200 可接受 |
| 未挂 Home | 无 Screen 注册（Phase 3） |
| 未改 gases_intro/diffusion | 并存；Gas Properties 自包含 |

---

## 7. Phase 3 Preparation — View 应读取的状态

### IdealGasLawModel
- `particleSystem.heavyParticles / lightParticles`（x,y,radius,type）
- `container`：left/right/top/bottom/width/lid/isOpen/opening
- `temperatureKelvin`、`displayedPressureKpa`、`volume`
- `holdConstant`、`holdConstantSolver.lastOops`
- `heatCoolFactor`、`clock.isPlaying`、`clock.simulationTimePs`
- `energySampling?`：bins、averageSpeed、zoomLevelIndex
- `particleCollisionsEnabled`、injection T flags
- `profile` → 决定面板集合

### DiffusionModel
- `particles1/2`、`container.hasDivider`、`left/rightData`
- `centerOfMass1/2`、`flowRate1/2`
- `leftSettings/rightSettings`、`clock`

### 驱动
View 用 `Ticker` 调 `stepRealTime(dt)`；禁止在 Painter 内改 Model。

---

## 验收清单

```
[x] Constants migrated
[x] SimulationClock
[x] Particle Model
[x] Particle injection
[x] Heat/Cool
[x] Container
[x] Wall collision
[x] Explore moving wall
[x] Particle collision
[x] Spatial partition
[x] Ideal Gas Law
[x] Temperature
[x] Pressure sampling
[x] Hold Constant
[x] Energy sampling
[x] Average Speed
[x] Speed Histogram
[x] KE Histogram
[x] Histogram Zoom
[x] Collision toggle
[x] Diffusion Model
[x] Partition
[x] Flow Rate
[x] Center of Mass
[x] Slow mode
[x] Reset
[x] Deterministic randomness
[x] Unit tests
```

**Phase 2 完成。等待确认后进入 Phase 3 — Flutter Implementation。**
