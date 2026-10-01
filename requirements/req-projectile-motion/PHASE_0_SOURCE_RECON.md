# PHASE 0 — Source Recon · Projectile Motion

> 源码根：`phet sourses/projectile-motion-main/projectile-motion-main`
> 版本：**projectile-motion 1.1.0-dev.41**（`package.json:3`）
> 侦察日期：2026-09-14 · 所有结论均以本地源码为准（网页仅作交叉验证）

---

## 1. SOURCE MAP

```
projectile-motion-main/
├── js/
│   ├── projectile-motion-main.ts          # 入口（simLauncher.launch）
│   ├── projectileMotion.ts                # namespace
│   ├── ProjectileMotionStrings.ts
│   ├── common/
│   │   ├── ProjectileMotionConstants.ts   # 全部常量（范围/颜色/布局/zoom）
│   │   ├── ProjectileMotionQueryParameters.ts
│   │   ├── StatUtils.ts
│   │   ├── model/
│   │   │   ├── ProjectileMotionModel.ts   # 公共 model 基类
│   │   │   ├── Trajectory.ts              # ★ 物理核心（无独立 Projectile 类）
│   │   │   ├── DataPoint.ts               # 轨迹采样点（t/x/y/vx/vy/ax/ay/Fd/Fg/ρ/apex/grounded）
│   │   │   ├── DataProbe.ts               # 数据探针（tracer）
│   │   │   ├── ProjectileObjectType.ts    # 9+1 种抛体预设
│   │   │   ├── Target.ts                  # 靶心 + 命中/计分
│   │   │   └── ProjectileMotionMeasuringTape.ts
│   │   └── view/
│   │       ├── ProjectileMotionScreenView.ts  # 公共 ScreenView（MVT/图层/组装）
│   │       ├── ProjectileMotionViewProperties.ts
│   │       ├── CannonNode.ts              # 大炮（拖角/拖高/炮口火焰）
│   │       ├── TrajectoryNode.ts          # 轨迹线 + 时间点 + apex 点 + 抛体
│   │       ├── ProjectileNode.ts          # 抛体图 + 速度/加速度箭头 + FBD
│   │       ├── ProjectileObjectViewFactory.ts
│   │       ├── TargetNode.ts / BackgroundNode.ts / DataProbeNode.ts
│   │       ├── ToolboxPanel.ts / FireButton.ts / FreeBodyDiagram.ts
│   │       ├── AirResistanceControl.ts / ArrowlessNumberControl.ts
│   │       └── VectorsDisplayEnumeration.ts
│   ├── intro/   IntroScreen + IntroModel + IntroScreenView + 2 panels + icon
│   ├── vectors/ VectorsScreen + VectorsModel + VectorsScreenView + panels + icon
│   ├── drag/    DragScreen + DragModel + DragScreenView + panels + icon
│   ├── lab/     LabScreen + LabModel + EditableProjectileObjectType + LabScreenView
│   │            + ProjectileObjectTypeControl + CustomProjectileObjectTypeControl
│   │            + KeypadLayer + InitialValuesPanel + icon
│   └── stats/   StatsScreen + StatsModel + StatsScreenView + FireMultipleButton + icon
│                # ★ 源码完整但【未挂入】 projectile-motion-main.ts 的 screens 数组
├── images/    # 15 张 PNG（抛体/背景/人物）+ license.json
├── mipmaps/   # 5 张 PNG（大炮×3、fire 按钮×2）+ license.json
├── assets/    # .ai 设计稿（非 runtime）
└── doc/       # model.md / implementaton-notes.md（部分过时，以现码为准）
```

无 `sounds/` 目录。

## 2. ENTRY MAP

- 入口：`js/projectile-motion-main.ts:21-40` → `Sim(title, [IntroScreen, VectorsScreen, DragScreen, LabScreen])`
- 标题字符串：`"Projectile Motion"`（`projectile-motion-strings_en.json:2-3`）
- **Stats 屏存在但未进默认入口** → 本次迁移范围 = **4 屏（Intro / Vectors / Drag / Lab）**，Stats 不迁移（与原版默认交付一致）。

## 3. SCREEN MAP

| # | 屏 | Model | 默认空气阻力 | 默认抛体 | 特殊默认 |
|---|---|---|---|---|---|
| 1 | Intro | IntroModel | off | PUMPKIN（5kg/0.37m/0.6） | height=10, angle=0, speed=15 |
| 2 | Vectors | VectorsModel | on | COMPANIONLESS（5kg/0.8m/0.47, rotates） | 基类默认 h=0/θ=80°/v=18 |
| 3 | Drag | DragModel | on | COMPANIONLESS | 基类默认；altitude 控件 |
| 4 | Lab | LabModel | off | CANNONBALL（17.6kg/0.18m/0.47） | preciseCannonDelta(1° snap)；gravity/altitude 可调 |

基类默认：`defaultCannonHeight:0, defaultCannonAngle:80, defaultInitialSpeed:18`（`ProjectileMotionModel.ts:99-101`）

## 4. MODEL MAP（ ProjectileMotionModel.ts ）

Properties（初值 / 范围）：

| Property | initial | min | max | 源码 |
|---|---|---|---|---|
| cannonHeight (m) | 0（Intro 10） | 0 | 15 | Model:111-117, Constants:61 |
| cannonAngle (°) | 80（Intro 0） | -90 | 90 | Model:142-149, Constants:62 |
| initialSpeed (m/s) | 18（Intro 15） | 0 | 30 | Model:127-133, Constants:63 |
| gravity (m/s²) | 9.81（PhysicalConstants.GRAVITY_ON_EARTH） | 1 | 20 | Model:180-185, Constants:72 |
| mass (kg) | 随类型 | 0.01 | 5000 | Model:151-156, Constants:67 |
| diameter (m) | 随类型 | 0.01 | 3 | Constants:68 |
| dragCoefficient | 随类型 | 0.04 | 1.2 | Constants:69 |
| altitude (m) | 0 | 0 | 5000 | Model:186-191, Constants:71 |
| zoom | 1 | 0.25 | 2（×2/÷2 步进） | Model:252-258 |
| targetX (m) | 15（Stats 20） | 视口动态 | 视口动态 | Target.ts, Constants:137-138 |
| airResistanceOn | 随屏 | — | — | Model:193-197 |
| timeSpeed | NORMAL | NORMAL/SLOW | — | Model:207-212 |
| isPlaying | true | — | — | Model:214-218 |
| speed/angle σ（Stats） | 0 | 0 | 5 / 10 | Model:119-141 |

派生：`airDensity = f(altitude, airResistanceOn)`；`fireEnabled = !rapidFire && moving < maxProjectiles(10)`。

David 参照人：高 2 m @ (7, 0)（Model:220-221）。

## 5. PHYSICS MAP（★ 已逐行核验 Trajectory.ts ）

**无 Projectile 类**：抛体状态 = `Trajectory.projectileDataPointProperty`（当前 DataPoint）。

### 5.1 发射（fire）

`ProjectileMotionModel.fireNumProjectiles`（Model:359-376）：
- 读 `initialSpeed/angle.getRandomizedValue()`（σ=0 时即原值）
- 创建 `Trajectory(type, m, D, Cd, v0, h=cannonHeight, θ)`
- 初速度 `v = v0·(cosθ, sinθ)`（Trajectory:163，`setPolar`）
- **发射点 = (0, cannonHeight)**（Trajectory:168）——炮管长度 4 m（CannonNode:48）**仅用于视图**，不参与物理

### 5.2 积分方法（常加速度运动学 + 半隐式速度更新，非 RK4 非纯解析）

每步（Trajectory:229-269），使用**上一数据点的加速度**：

```
newY  = y + vy·t + ½·ay·t²        # nextPosition, Trajectory:437-439
newX  = x + vx·t + ½·ax·t²
newVx = vx + ax·t                 # Trajectory:238-240
newVy = vy + ay·t
```

然后用**新速度**重算阻力与加速度（Trajectory:253-254）供下一步使用。

### 5.3 空气阻力（二次阻力 quadratic drag）

```
A   = π·D²/4
Fd⃗  = ½·ρ·A·Cd·|v|·v⃗            # Trajectory:216-221（方向同 v，加速度中取负）
a⃗   = (−Fd.x/m, −g − Fd.y/m)      # Trajectory:209-210
Fg  = −g·m                        # Trajectory:202-203
```

### 5.4 空气密度（NASA 标准大气，Model:406-437）

```
altitude < 11000（对流层）:
  T = 15.04 − 0.00649·h
  P = 101.29·((T+273.1)/288.08)^5.256
ρ = P / (0.2869·(T+273.1))        # 海平面 ≈ 1.225 kg/m³
airResistanceOn=false → ρ = 0
```

### 5.5 落地 / 终止（Trajectory:229-278）

- `newY ≤ 0` → `newY = 0`，`reachedGround = true`
- 本步时间截断为精确落地时间（二次方程，Trajectory:441-455）：
  `t = (−√(vy² − 2·ay·y) − vy) / ay`
- 落地后 `numberOfMovingProjectiles--` 并 `checkIfHitTarget(x)`

### 5.6 vx 反向保护（Trajectory:242-248）

若阻力使 `sign(newVx) ≠ sign(vx)`：截断到 vx=0 的时刻重算 newX，令 `newVx = 0`。

### 5.7 Apex 记录（Trajectory:280-302）

`vy` 由正转负时，用 `dtToApex = |vy/ay|` 插值出 apex DataPoint（vy=0）插入 dataPoints，供 DataProbe 读取。

### 5.8 全局参数变化语义

- **airDensity / gravity 变化 → 立即影响空中抛体**（Model:268-277 mark changedInMidAir；Trajectory 每步实时读 gravity/airDensity Property）
- **angle / speed / mass / diameter / Cd / cannonHeight → 仅影响下一次发射**（fire 时快照进 Trajectory 只读字段）
- **selectedProjectileObjectType 变化 → 立即同步 mass/diameter/Cd**（Model:278-284 setProjectileParameters）

### 5.9 Target 命中（Target.ts:65-78）

`TARGET_WIDTH=3m`：|Δx|≤0.5m → 3 星；≤1m → 2 星；≤1.5m → 1 星。

## 6. CLOCK MAP

```
SimulationClock (Flutter 侧复用 lib/common/simulation_clock.dart)
  → model.step(wallDt)                       # Model:314-317, isPlaying 才走
       eventTimer.step( (SLOW?0.33:1) · wallDt )   # SLOW_MOTION_FACTOR=0.33, Constants:82
  → EventTimer(ConstantEventModel(1000/12))  # ≈83.33 Hz
       → stepModelElements( 0.012 )          # ★ 物理恒定 dt = 12ms, Constants:86
            → 每条未落地 Trajectory.step(0.012)
            → muzzleFlashStepper.emit(0.012)
```

Step 按钮：`stepModelElements(0.012)` 单步（ScreenView:382-384）。

**Flutter 映射**：`SimulationClock.onTick` 累积墙钟 dt，按 0.012 s 定额切片调用 `model.stepModelElements(0.012)`（accumulator 模式），慢放 ×0.33。

## 7. VIEW MAP

图层顺序（ScreenView:454-472）：
Background → Target → david → Cannon → trajectoriesLayer → 初速/初角面板 → 右侧面板 → Toolbox → Fire/Eraser/TimeControl/Zoom/ResetAll → MeasuringTape → DataProbe

- **CannonNode**：拖 barrel tip 改角（snap 5°，Lab 1°；height<4 时角度下限 ANGLE_RANGE_MINS=[5,-5,-20,-40]，CannonNode:60）；拖 base/cylinder 改高（snap 1m）；muzzle flash 动画
- **TrajectoryNode**：折线 Path 宽 2px；有阻力洋红 rgb(252,40,252)、无阻力蓝（Constants:75-76）；每 1000ms 大点 r=3.3、每 100ms 小点 r=1.65；apex 绿点；旧轨迹按 rank 降透明度
- **ProjectileNode**：类型贴图（rotates 类型按速度角旋转）+ 速度/加速度箭头（标量 15，无单位）+ FreeBodyDiagram（FORCE_SCALAR=3, 偏移(-40,-40)px）
- **BackgroundNode**：天空渐变 #02ace4→#cfecfc；绿草；灰路黄虚线；Flatirons 彩蛋（altitude 1500–1700 时显示）
- **TargetNode**：红白同心靶，水平拖拽，snap 0.1m，距离读数
- **面板**：右侧控制面板底色 rgb(255,238,218)，初值面板 rgb(235,235,235)

## 8. INTERACTION MAP

| 对象 | 拖拽 | 约束/snap |
|---|---|---|
| Cannon barrel tip | 改角度 | 相对炮基向量夹角；snap 5°（Lab 1°）；h<4 时下限 |
| Cannon base/cylinder/高度标签 | 改高度 | Δy view→model；snap 1m；[0,15] |
| Target | 仅水平 | Δx→model；snap 0.1m；clamp 视口 |
| Measuring tape | base/tip 双拖 | dragBounds=visibleBounds 内缩 20px |
| DataProbe | 全屏拖 | 传感半径 0.2m/zoom；读 apex/地面/整 100ms 点 |
| Projectile | ✗ 不可拖 | TrajectoryNode pickable:false |

## 9. MEASUREMENT MAP

| 工具 | 功能 |
|---|---|
| MeasuringTape | 米尺，2 位有效数字，base (0,0) / tip (1,0) 初始，isActive 默认 false |
| DataProbe (tracer) | 显示 time / range(x) / height(y)；优先 apex；仅吸附 apex、地面点、整 100ms 时刻点 |
| 速度/加速度向量 | Intro 仅速度；Vectors 全套；Drag 速度+力（无加速度）；Lab 可配 |
| FreeBodyDiagram | Vectors/Drag/Lab：重力+阻力箭头 |

## 10. ASSET MAP（详表见 ASSET_MAP.md）

**mipmaps/**：`cannonBarrel.png`、`cannonBaseBottom.png`、`cannonBaseTop.png`（CannonNode）、`fireButton.png`（FireButton）、`fireMultipleButton.png`（Stats，不迁移）

**images/**：`cannonBarrelTop.png`（CannonNode 抓手层）、`david.png`（参照人）、`flatirons.png`（背景彩蛋）、抛体图 `baseball / car1·car2 / football / human1·human2 / piano1·piano2 / pumpkin1·pumpkin2 / tankShell`；`uncenteredHuman1.png`（Intro 屏图标）
**无图自绘**：Cannonball、GolfBall（Circle）

## 11. COORDINATE MAP（★ 关键）

| 项 | 值 | 源码 |
|---|---|---|
| Model 坐标 | mks，x 向右，**y 向上**，原点 (0,0) = 地面炮枢轴 | Trajectory.ts:8 |
| View origin | **(70, 510)** 屏坐标 | Constants:44 |
| Scale | **30 px/m** × zoom | ScreenView:55, 310-312 |
| 变换 | `createSinglePointScaleInvertedYMapping(ZERO, VIEW_ORIGIN, 30·zoom)` —— y 翻转 | ScreenView:116 |
| model→view | `vx = 70 + 30z·x`；`vy = 510 − 30z·y` | 推导 |

## 12. RESET MAP（Model:287-312 + ScreenView:327-334）

eraseTrajectories（清空+计数归零）→ target / measuringTape / dataProbe / zoom → cannonHeight / cannonAngle / σ / initialSpeed / selectedType / mass / diameter / Cd / gravity / altitude / airResistance / timeSpeed / isPlaying / rapidFire 全部 `.reset()` → muzzleFlash emit(0)；View 额外 reset viewProperties / targetNode / cannonNode；Lab 额外 reset 各 EditableProjectileObjectType。

## 13. KARTOSLAB 复用清单（已扫描 lib/common + pendulum_lab）

| 复用 | 来源 |
|---|---|
| SimulationClock | `lib/common/simulation_clock.dart` |
| KratosTabbedScreen（4 屏） | `lib/common/widgets/kratos_tab_bar.dart` |
| Controller + Clock 接入模式 | 仿 `lib/pendulum_lab/controller/pendulum_lab_controller.dart` |
| Shell（固定 layoutBounds + FittedBox） | 仿 `PlSimulationShell` |
| MVT | 仿 `lib/pendulum_lab/transform/pendulum_lab_transform.dart` |
| 测试结构 | `test/projectile_motion/`：physics / interaction / widget / lifecycle / visual_qa |
| Home 注册 | `lib/screens/home_screen.dart` 力学组 `_SimEntry` |
| 素材落位 | `assets/simulations/projectile_motion/` + pubspec 声明 + `pm_assets.dart` |

## 14. 侦察结论与风险

1. **物理不是解析公式**：必须按 §5.2 的逐步积分 + 恒定 dt=0.012s 实现，否则轨迹/落点会与原版漂移。
2. **发射点在枢轴高度 (0,h)**，不做炮口偏移——视角上炮弹从炮管口出来是视图层的视觉对齐，Model 不偏移。
3. **Stats 屏不迁移**（原版默认入口不含）。
4. `doc/model.md` 与 `implementaton-notes.md` 部分过时，一律以 `.ts` 现码为准。
5. 阻力为**二次**且依赖海拔 → Lab/Drag 屏的 altitude 控件必须实现 NASA 公式。
6. 角度 snap 与高度联动下限是 Intro 体验关键，拖拽实现时必须照搬。
