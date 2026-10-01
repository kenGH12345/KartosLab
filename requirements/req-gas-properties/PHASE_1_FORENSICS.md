# PHASE 1 — SOURCE FORENSICS · Gas Properties

> **状态**：取证完成，等待确认后进入 Phase 2  
> **唯一基准**：`phet sourses/gas-properties-main/gas-properties-main`  
> **官方 URL**：https://phet.colorado.edu/sims/html/gas-properties/latest/gas-properties_all.html  
> **模型文档**：`doc/model.md`  
> **标记**：`[已确认]` / `[推测]` / `[待确认]`

---

## 0. 执行边界

本阶段**只读**源码与文档，**未修改**任何 Flutter 业务代码。

产出：

| 文件 | 用途 |
|------|------|
| `PHASE_1_FORENSICS.md` | 本文件：功能 / Model / 交互完整取证 |
| `ASSET_MAP.md` | 资源映射（几乎全程序绘制） |
| `VALIDATION.md` | 数值与 UI 容差基线 |

---

## 1. 源码结构

### 1.1 仓库顶层

```
gas-properties-main/
├── js/                          # 全部模拟逻辑（TypeScript）
│   ├── gas-properties-main.ts   # Sim 入口：4 Screen
│   ├── gasProperties.ts         # namespace
│   ├── GasPropertiesStrings.ts
│   ├── common/                  # Ideal/Explore/Energy 共享 + 部分 Diffusion 共用
│   │   ├── GasPropertiesConstants.ts
│   │   ├── GasPropertiesColors.ts
│   │   ├── GasPropertiesQueryParameters.ts
│   │   ├── GasPropertiesUtils.ts
│   │   ├── model/               # BaseModel, IdealGasLaw*, Collision*, Pressure*, Temperature*, Particle*
│   │   └── view/                # IdealGasLawScreenView, pump, gauges, sprites…
│   ├── ideal/
│   ├── explore/
│   ├── energy/
│   └── diffusion/               # 独立模型（不走 Ideal Gas Law）
├── images/
│   └── phetGirlLabCoat_png.ts   # 唯一位图资源（OopsDialog 图标）
├── assets/                      # 空目录
├── doc/model.md                 # 权威模型说明
├── gas-properties_en.html
├── gas-properties-strings_en.json
└── dependencies.json            # 依赖 scenery-phet / joist / axon / dot…
```

**[已确认]** 本仓库**不包含**完整 PhET 公共库源码（`scenery-phet` 的 `BicyclePumpNode` / `HeaterCoolerNode` / `ThermometerNode` / `Stopwatch` 等以外链依赖形式引用）。Flutter 侧需按行为复刻或对照已迁移 sim 的等价组件。

### 1.2 入口与 Screen 注册

`js/gas-properties-main.ts`：

```ts
const screens = [
  new IdealScreen(...),
  new ExploreScreen(...),
  new EnergyScreen(...),
  new DiffusionScreen(...)
];
new Sim(title, screens, { preferencesModel: … });
```

附加全局能力：

- Home / Screen 切换（joist `Sim`）
- Preferences：Projector Mode + **Pressure Noise** 开关（`GasPropertiesPreferencesNode`）
- PhET Menu / keyboard help（各 Screen 自定义 help content）
- Reset All / Pause / Step（各 ScreenView 时间控件）

**[已确认]** Screen 顺序：Ideal → Explore → Energy → Diffusion。

---

## 2. 四个 Screen 功能总览

| Screen | Model | 共享 Ideal Gas Law? | Hold Constant | 左墙做功 | 容器宽度 | Collision Counter | 特有 UI |
|--------|-------|---------------------|---------------|----------|----------|-------------------|---------|
| Ideal | `IdealModel` → `IdealGasLawModel` | ✅ | 全部 5 项，默认 Nothing | ❌（暂停+重分布） | 可变 5000–15000 | ✅ | Hold Constant 面板 |
| Explore | `ExploreModel` → `IdealGasLawModel` | ✅ | 固定 Nothing | ✅ | 可变 | ✅ | Wall Velocity 勾选 |
| Energy | `EnergyModel` → `IdealGasLawModel` | ✅ | 固定 Volume | ❌ | **固定 10000** | ❌ | Avg Speed + 2 Histograms + Injection T + collisions toggle |
| Diffusion | `DiffusionModel` → `BaseModel` | ❌ | N/A | N/A | **固定 16000** | ❌ | Divider / Data / COM / Flow Rate / Normal·Slow |

---

## 3. Model 架构

```
BaseModel                          # 时间、MVT、Stopwatch、isPlaying、timeSpeed
├── IdealGasLawModel               # Ideal / Explore / Energy
│   ├── holdConstantProperty
│   ├── heatCoolAmountProperty
│   ├── IdealGasLawContainer       # V, lid, width, particleEntry
│   ├── IdealGasLawParticleSystem  # N, heavy/light, heat/cool, inject
│   ├── TemperatureModel           # T from KE
│   ├── PressureModel              # P = NkT/V + gauge sampling/noise
│   ├── CollisionDetector
│   └── CollisionCounter?          # Ideal & Explore
│
└── DiffusionModel                 # Diffusion only
    ├── DiffusionContainer         # fixed width + divider
    ├── DiffusionParticleSystem    # particle1/2 settings, COM, flow
    ├── DiffusionCollisionDetector
    ├── leftData / rightData       # DiffusionData
    └── timeSpeed NORMAL | SLOW
```

### 3.1 Ideal Gas Law 子量归属 **[已确认]**

| 符号 | 实现位置 |
|------|----------|
| P | `PressureModel.pressureKilopascalsProperty` |
| V | `BaseContainer.volumeProperty` = width × height × depth |
| N | `IdealGasLawParticleSystem.numberOfParticlesProperty` |
| T | `TemperatureModel.temperatureKelvinProperty`（可 null） |
| k | `GasPropertiesConstants.BOLTZMANN = 8.316E3` |

### 3.2 每步更新顺序 **[已确认]**（`IdealGasLawModel.stepModelTime`）

1. `super.stepModelTime`（stopwatch）
2. `stepSystem(dt)`：
   - heat/cool → particle step → escape → container step → collision → remove OOB → collisionCounter
3. `updateModel`：
   - `compensateForHoldConstant` → `temperatureModel.update` → `pressureModel.update` → `verifyModel`

**禁止**在 View 中打乱该顺序。

---

## 4. 单位、常量、时间

### 4.1 单位 **[已确认]**（`doc/model.md` + Constants）

| 量 | 单位 |
|----|------|
| distance / location | pm |
| time | ps |
| mass | AMU |
| velocity | pm/ps |
| KE | AMU·pm²/ps² |
| T | K（View 可 °C） |
| P | kPa（View 可 atm） |
| V | pm³ |

### 4.2 关键常量 **[已确认]**

| 常量 | 值 | 文件 |
|------|-----|------|
| BOLTZMANN k | 8.316E3 (pm²·AMU)/(ps²·K) | Constants |
| PRESSURE_CONVERSION_SCALE | 1.66E6 | Constants |
| ATM_PER_KPA | 0.00986923 | Constants |
| MODEL_VIEW_SCALE | 0.040 px/pm | BaseModel |
| MODEL_TIME_STEP（Step 按钮） | 0.2 ps | Constants |
| MAX_TIME（秒表） | 999.99 ps | Constants |
| maxPressure（炸盖） | 20000 kPa | QueryParameters |
| maxTemperature | 100000 K | QueryParameters |
| heatCool 因子分母 | 800 | QueryParameters |
| wallSpeedLimit | 800 pm/ps | QueryParameters |

### 4.3 时间变换 **[已确认]**（`TimeTransform.ts`）

| 模式 | ps per real second | 等价（model.md） |
|------|--------------------|------------------|
| NORMAL | 2.5 | 1 ps = 0.4 s real |
| SLOW | 0.3 | 1 ps ≈ 3.33 s real |

- Ideal / Explore / Energy：默认 NORMAL；**无** Slow 单选（`hasTimeSpeedFeature: false`）
- Diffusion：`hasTimeSpeedFeature: true`，UI 提供 Normal / Slow

驱动链：

```
Sim.step(dtRealSeconds)
  → if playing: stepRealTime(dt)
  → stepModelTime(TimeTransform.evaluate(dt))
```

**不是** `Timer.periodic` 直接驱动物理。

---

## 5. Particle 系统

### 5.1 粒子字段 **[已确认]**（`Particle.ts`）

| 字段 | 含义 |
|------|------|
| mass | AMU |
| radius | pm |
| x, y | 中心位置（相对容器右下角原点） |
| previousX/Y | 上一步位置（碰撞用） |
| vx, vy | pm/ps |
| color / highlight | ProfileColorProperty |

**无**可观察 Property per particle（性能）；整系统每帧巡检。

### 5.2 Ideal/Explore/Energy 物种 **[已确认]**

| 类型 | mass | radius | 颜色 default |
|------|------|--------|--------------|
| Heavy | 28 AMU | 125 pm | rgb(119,114,244) + highlight |
| Light | 4 AMU | 87.5 pm | rgb(232,78,32) + highlight |

库存：各 0–1000，默认 0。

数组：`heavyParticles` / `lightParticles`（容器内）+ `*Outside`（逸出后向上漂浮，出视界删除）。

### 5.3 运动 **[已确认]**

```
position += velocity * dt
```

无重力、无旋转。

### 5.4 注入（泵 / spinner）**[已确认]**

- 入口：`container.particleEntryPosition`（容器内侧）
- 角度：`π - (π/2)/2 + random*(π/2)`，即垂直右壁的 `π/2` 色散锥
- 速度：`|v| = sqrt(3 k T / m)`
- 温度来源（`TemperatureModel.getInitialTemperature`）：
  1. Energy：若启用 injection T → 用户设定
  2. 否则容器当前 T
  3. 容器空 → 默认 **300 K**
- 多粒子且启用 particle-particle 碰撞：温度用 Gaussian（mean T，σ=0.2T，容差 1E-3）再算速度；单粒子或关闭碰撞 → 全部用 mean T（波形注入）

### 5.5 Heat / Cool **[已确认]**

```
velocityScale = 1 + heatCoolFactor / 800
particle.scaleVelocity(velocityScale)
```

`heatCoolFactor ∈ [-1, 1]`（HeaterCoolerNode）。**不是** `temperature += 1`。

### 5.6 setTemperature（Hold Constant pressureT / 减 N 保 T）**[已确认]**

```
desiredAverageKE = (3/2) * T * k
ratio = desiredAverageKE / actualAverageKE
每个粒子：desiredSpeed = sqrt(2 * ratio * KE_i / m)
```

### 5.7 逸出 **[已确认]**

盖开且粒子穿过顶部开口（left/right 在 opening 内，top > container.top）→ 移到 outside 数组，N--，立即回库存；outside 粒子无碰撞检测。

---

## 6. Container

### 6.1 Ideal Gas Law 容器 **[已确认]**（`BaseContainer` + `IdealGasLawContainer`）

| 量 | 值 |
|----|-----|
| 原点 | 容器**右下角** |
| width 默认 / 范围 | 10000 / [5000, 15000] pm（Energy 固定 10000） |
| height | 8750 pm |
| depth | 4000 pm |
| wallThickness | 75 pm |
| V | width × height × depth |
| lidThickness | 175 pm |
| openingLeftInset / RightInset | 1250 / 2000 pm |
| OPENING_WIDTH_THRESHOLD | 1500 pm（开口过窄且超压则炸盖） |
| 泵入口 y | `position.y + height/5` |

### 6.2 左墙行为差异 **[已确认]**

| Screen | leftWallDoesWork | 交互 |
|--------|------------------|------|
| Ideal / Energy | false | 拖拽时**暂停**、粒子半透明；松开后 `redistributeParticles(newW/oldW)`，壁**不做功** |
| Explore | true | 拖拽时若 paused 则**自动 play**；壁速参与碰撞：`vx' = -(vx - wallVx)`；缩小时有 `WALL_SPEED_LIMIT` |

### 6.3 Diffusion 容器 **[已确认]**

- 宽度固定 **16000** pm；无盖
- 垂直 divider，厚度 100 pm，居中；`isDividedProperty` 默认 true
- 分侧 `leftBounds` / `rightBounds`（含 divider 半厚偏移）

---

## 7. Collision 系统

### 7.1 总则 **[已确认]**（`CollisionDetector.ts` + model.md）

- 完美弹性，e = 1
- 事后检测（a posteriori）
- 仅容器内；逸出粒子不检测
- Spatial partitioning：region 边长 = `container.height / 4`
- Energy 可关 particle-particle（`collisionsEnabledProperty`）

### 7.2 Particle ↔ Wall **[已确认]**

```
if left:  left = minX;  vx = -(vx - leftWallVelocityX)
if right: right = maxX; vx = -vx
if top:   top = maxY;   vy = -vy
if bottom: bottom = minY; vy = -vy
```

左墙速度仅 Explore（`leftWallDoesWork`）非零。

### 7.3 Particle ↔ Particle **[已确认]**（impulse-based）

- 若上一步已接触则忽略（避免泵口粘连）
- 接触点、法向、切向、反射位置调整
- Impulse：

```
vr = relativeVelocity · normal
j = (-vr * (1+e)) / (1/m1 + 1/m2)
v1 += (j/m1) * normal
v2 -= (j/m2) * normal
```

**禁止**简单 `v *= -1`。

### 7.4 Diffusion **[已确认]**

`DiffusionCollisionDetector` 扩展：divider 在位时当作额外墙，容器等效为左右两个。

### 7.5 Collision Counter **[已确认]**（Ideal / Explore）

- 统计 particle-container 碰撞
- Sample period：`[5, 10, 20]` ps，默认 **10**
- 改可见性或 sample period → 停止并清零

---

## 8. Gas Law / Pressure / Temperature

### 8.1 方程 **[已确认]**

```
PV = NkT
P = NkT / V          → × PRESSURE_CONVERSION_SCALE → kPa
T = (2/3) KE_avg / k
KE = (1/2) m |v|²
|v| = sqrt(3kT/m)    // 注入
```

### 8.2 Pressure 特殊行为 **[已确认]**（`PressureModel`）

| 行为 | 细节 |
|------|------|
| 模型压力 | 每步精确 `P = NkT/V`（转换后） |
| 启用条件 | 空容器 P=0；**直到至少 1 次壁碰撞**才开始更新 |
| 表盘刷新 | `REFRESH_PERIOD = 0.75` ps 累加 |
| 噪声 | `noise = pressureNoiseFn(P) * scaleNoiseFn(T) * random`；符号随机但保证结果 >0 |
| pressureNoiseFn | LinearFunction(0→maxP, 50→0 kPa) |
| scaleNoiseFn | LinearFunction(5→50 K, 0→1)，clamp |
| 禁用噪声 | Hold Constant 为 pressureV/pressureT，或 Preferences `pressureNoise=false` |
| 超压 | P > 20000 kPa → `blowLidOff()` |

表盘显示绑定 **noise Property**，不是每帧原始 P。

### 8.3 Temperature **[已确认]**

- 连续更新；**无噪声**
- 空容器 → `null`（温度计映射为 0 显示）
- 默认单位 Kelvin；可切 °C（`T_C = T_K - 273.15`）
- Injection T 范围（Energy）：[50, 1000] K，默认 300

---

## 9. Hold Constant（Ideal）

### 9.1 模式表 **[已确认]**

| Mode | 改 N | 改 T | 改 V |
|------|------|------|------|
| nothing | P 变 | P 变 | P 变 |
| volume | P 变 | P 变 | — |
| temperature | P 变 | — | P 变 |
| pressureV | V 变 | V 变 | — |
| pressureT | T 变 | — | T 变 |

### 9.2 自动回退 + Oops **[已确认]**

| 条件 | 动作 | Dialog 文案 key |
|------|------|-----------------|
| N=0 且 hold T | → nothing | oopsTemperatureEmpty |
| 开盖且 hold T | → nothing | oopsTemperatureOpen |
| N=0 且 hold pressure* | → nothing | oopsPressureEmpty |
| pressureV 算得 V 超宽 | → nothing + clamp | oopsPressureLarge / Small |
| T ≥ maxTemperature | 清粒子、盖盖、必要时 → nothing | oopsMaximumTemperature |

### 9.3 UI 禁用 **[已确认]**（`HoldConstantPanel`）

- Temperature radio：N=0 或 lid open → disabled
- Pressure↕V / Pressure↕T：P=0 → disabled
- Nothing **永不隐藏**（回退落点）

### 9.4 其他 Screen 固定值 **[已确认]**

- Explore：仅 `nothing`
- Energy：仅 `volume`（宽度不可变）

---

## 10. Ideal Screen 控件清单

| 控件 | 初始 / 范围 | 行为要点 |
|------|-------------|----------|
| Container + lid handle | 盖上，宽 10000 | 可拉开开口；超压炸盖；Return Lid |
| Resize handle | width [5000,15000] | 暂停+重分布（见 §6.2） |
| Bicycle pump | Heavy/Light 切换 | 增加对应 N，动画注入 |
| Particles accordion | 0–1000 spinner | 增减粒子 |
| Erase particles | — | 清空 |
| Thermometer | null→空 | K/°C |
| Pressure gauge | 0 | kPa/atm；噪声采样 |
| Heat/Cool | 0 | [-1,1] |
| Hold Constant | Nothing | 见 §9 |
| Width checkbox | — | 显示尺寸箭头 |
| Stopwatch | hidden | max 999.99 ps |
| Collision Counter | hidden | sample 5/10/20 |
| Pause / Step / Reset | playing | Step = 0.2 ps model |

---

## 11. Explore Screen

- **共享** `IdealGasLawModel`（同一物理核心）
- 差异：**左墙做功**；Hold Constant 锁 Nothing；Tools 增加 **Wall Velocity** 矢量显示
- 其余：泵、热冷、测量、碰撞计数、暂停步进与 Ideal 同类

---

## 12. Energy Screen — 数据系统

### 12.1 扩展 Model **[已确认]**

- `HistogramsModel` + `AverageSpeedModel`
- `SAMPLE_PERIOD = 1` ps
- 固定 V（宽 10000）；hold volume；无 collision counter
- `hasInjectionTemperatureFeature: true`
- `collisionsEnabledProperty` 可切换（Particles accordion）

### 12.2 Average Speed **[已确认]**

- 分 Heavy / Light
- 在 1 ps 窗口内对瞬时平均速度再平均
- 空物种 → null

### 12.3 Histograms **[已确认]**

| Histogram | bins | binWidth | 单位 |
|-----------|------|----------|------|
| Speed | **19** | **170** | pm/ps |
| Kinetic Energy | **19** | **8E5** | AMU·pm²/ps² |

- 每样本累加 bin counts，周期结束 `/ numberOfSamples`
- 另有 total = heavy + light
- bin index = `floor(value / binWidth)`，落在 [0,19)

### 12.4 Zoom **[已确认]**（共享 index）

`ZOOM_LEVELS`（yMax 从大到小）：2000, 1500, 1000, 500, 200, 100, 50  
默认 index = `length - 2`（即 yMax=100）

### 12.5 UI 布局

- 左侧：Average Speed / Speed / Kinetic Energy accordion（宽 ~205）
- 右侧：Particles（含 collisions 勾选）/ Injection Temperature / Tools

---

## 13. Diffusion Screen

### 13.1 独立性 **[已确认]**

不使用 Ideal Gas Law / Pressure / Hold Constant / Pump / HeatCool。

### 13.2 Settings（左右两侧各一套）**[已确认]**

| 量 | range | 默认 | step（必须整除） |
|----|-------|------|------------------|
| N | 0–200 | 0 | 10 |
| mass | 4–32 AMU | 28 | 1 |
| radius | 50–250 pm | 125 | 5 |
| initial T | 50–500 K | 300 | 50 |

粒子颜色：type1 cyan / type2 red（见 Colors）。

### 13.3 行为 **[已确认]**

- Divider 在位：两侧独立初始化 / 碰撞
- Remove Divider：粒子可穿越；`ParticleFlowRateModel` 监控穿越
- Reset Divider：`isDivided=true` → `particleSystem.restart()`（同设置重生粒子）
- Center of Mass：连续更新（`getCenterXOfMass`）
- Flow rate：300 样本滑动平均，单位 particles/ps
- Data accordion：左右两侧 N1/N2 + T_avg
- Time：Normal / Slow（§4.3）
- Scale checkbox：容器下方刻度

### 13.4 温度（半侧）**[已确认]**

同 Ideal：`T = (2/3) KE_avg / k`，无粒子 → null。

---

## 14. View / 渲染

### 14.1 坐标 **[已确认]**

```
modelViewTransform = offsetXYScale(modelOriginOffset, 0.040, -0.040)
```

Ideal 系默认 origin offset view：(645, 475)；Diffusion：(670, 520)。

Flutter：**Logical sim coords → Scale → Screen**；禁止按设备重排控件相对关系。

### 14.2 粒子渲染 **[已确认]**

`ParticlesNode extends Sprites`：每种粒子预渲染高分辨率 canvas → Sprite；**禁止**每粒子一个 Widget。

Flutter 对应：`CustomPainter` / 合批绘制 shaded sphere。

### 14.3 共享 IdealGasLaw UI（Ideal/Explore/Energy）

Particles、Container、Thermometer、PressureGauge、HeaterCooler、BicyclePump、TimeControls、ResetAll、Stopwatch、（可选）CollisionCounter、ReturnLid、Erase。

### 14.4 Preferences

- Projector color profile
- Pressure Noise on/off（默认 on）

---

## 15. Screen 切换与 Reset

**[已确认]** joist `Screen`：各 Screen **独立 Model 实例**；切换不销毁他屏状态（标准 PhET 行为）。

**Reset All** 必须重置（IdealGasLaw 例）：

- holdConstant、heatCool、container、particleSystem、temperature、pressure、collisionCounter
- Energy 另：histograms + averageSpeed
- Diffusion：container + particleSystem（含 settings）+ BaseModel 时间/秒表
- ViewProperties（accordion 展开等）

不能只换 `initialState` 而遗留采样累加器 / 动画 / outside 粒子。

---

## 16. Assets 摘要

详见 `ASSET_MAP.md`。

结论：**几乎全部程序绘制**；唯一 PNG：`phetGirlLabCoat`（OopsDialog）。泵 / 温度计 / 加热器依赖 scenery-phet 几何，Flutter 需自绘复刻。

---

## 17. Flutter 对应架构（建议 · 服从现有工程）

对齐 `req-curve-fitting` 落点风格：

```
lib/gas_properties/
├── gas_properties_{constants,colors,strings}.dart
├── model/          # particle, container, gas_state, hold_constant, diffusion_*
├── solver/         # collision, pressure, temperature, gas_step, histogram, flow_rate
├── transform/      # model_view_transform, time_transform
├── render/         # render_data + builders（Painter 只读）
├── painters/       # particles, container, histograms, gauges overlays
├── widgets/        # pump, heat_cool, panels, stopwatch, collision_counter
├── screens/        # home entry, ideal, explore, energy, diffusion, shell
└── controller/     # clock / screen nav（若需）
```

核心数据流：

```
GasState → GasSolver.step(dt) → GasState → RenderBuilder → Painter
```

---

## 18. 预计实现难点

1. **Impulse 碰撞 + 空间分区** 在 2000 粒子下的性能与稳定性  
2. **Ideal 与 Explore 左墙语义分叉**（暂停重分布 vs 做功 + 壁速限制）  
3. **Hold Constant pressureV/T** 的边界 Oops 与宽度浮点修正（`toFixedNumber(5)`）  
4. **PressureGauge 噪声** 必须复刻采样周期与双线性映射，禁止每帧乱跳  
5. **Energy histogram** 时间平均 + zoom 网格，非 Flutter Chart 默认行为  
6. **scenery-phet 控件外观**（泵、加热器、温度计、压力表柱）几何取证工作量大  
7. **Diffusion** 独立生命周期与 divider restart  
8. **Sprites 合批绘制** 达到 ~60 FPS  

---

## 19. Phase 2 实施计划（待确认后执行）

1. 移植常量 / 单位 / TimeTransform / MVT  
2. Particle + Container + CollisionSolver（单测：壁反弹、双粒子冲量）  
3. IdealGasLaw 步进管线 + T/P 计算 + HeatCool + Inject  
4. Hold Constant + Oops 条件表  
5. Pressure sampling/noise 纯函数测试  
6. Energy：AverageSpeed + HistogramsModel  
7. Diffusion：Settings / Divider / COM / FlowRate  
8. **暂缓完整 UI**；仅需最小 harness 验证物理  

---

## 20. 取证证据索引（关键文件）

| 主题 | 路径 |
|------|------|
| 模型说明 | `doc/model.md` |
| 常量 | `js/common/GasPropertiesConstants.ts` |
| 入口 | `js/gas-properties-main.ts` |
| Ideal Gas 步进 | `js/common/model/IdealGasLawModel.ts` |
| 碰撞 | `js/common/model/CollisionDetector.ts` |
| 压力 | `js/common/model/PressureModel.ts` |
| 温度 | `js/common/model/TemperatureModel.ts` |
| 粒子系统 | `js/common/model/IdealGasLawParticleSystem.ts` |
| 时间 | `js/common/model/TimeTransform.ts` |
| Histogram | `js/energy/model/HistogramsModel.ts` |
| Diffusion | `js/diffusion/model/DiffusionModel.ts` |
| 字符串 | `gas-properties-strings_en.json` |

---

**PHASE 1 完成。等待确认后进入 Phase 2 — Model。**
