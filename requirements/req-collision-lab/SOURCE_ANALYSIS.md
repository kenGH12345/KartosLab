# Phase 1 — Source Analysis · Collision Lab

> 需求：`req-collision-lab`  
> 本地版本：`1.2.0-dev.0`  
> 源码根：`phet sourses/collision-lab-main/collision-lab-main`  
> 标记：`[已确认]` / `[推测]` / `[待确认]`

---

## 0. 结论摘要

碰撞响应、半径-质量关系、非弹性 stick 旋转、1D e=0 粘连、边界反射、负步进 `1/e`、网格吸附、Momenta 布局均在本地源码中**可完整取证**。迁移结论：**原样移植语义**，禁止教材替换。

---

## 1. 功能 → 源码证据矩阵

| 功能 | 主文件 | 类/方法 | 状态 | 迁移结论 |
|---|---|---|---|---|
| Screen 注册 | `js/collision-lab-main.js:32-37` | Sim 数组顺序 | 4 屏 · Intro 默认 | `[源码一致]` 四 Tab |
| PlayArea bounds | `PlayArea.js:206` | `DEFAULT_BOUNDS=(-2,-1)-(2,1)` | 2D 默认 | 局部米制坐标 |
| 1D 高度 | `CollisionLabConstants.js:38` | `PLAY_AREA_1D_HEIGHT=1.1` | Intro/Explore1D | 独立 1D bounds |
| Intro 无反射边 | `IntroPlayArea.js` | reflecting=false | 球可离开 | Return Balls=restart |
| 摩擦 | `doc/model.md` + PlayArea | 无摩擦字段 | friction-less | 不实现摩擦 |
| Ball canonical | `Ball.js` | p,v,m,rotation,restartState | SSOT | Widget 不存速度 |
| radius derived | `BallUtils.calculateBallRadius` | 球体体积+密度35 或 0.15 | Constant Size | 禁止 ∝mass 直觉 |
| 球-球检测 | `CollisionEngine.detectBallToBallCollisions` | 二次根 | 预测式 | 见 §2 |
| 球-球响应 | `handleBallToBallCollision` | 法向 e 公式 | 核心 | 见 §2 |
| 球-边 | `handleBallToBorderCollision` | ±v·e | 系统动量不守恒 | 测试须区分 |
| 1D e=0 | `Explore1DCollisionEngine` | findGroupedBalls | 共速 / 贴墙停 | 专用分支 |
| Stick 旋转 | `InelasticCollisionEngine` + `RotatingBallCluster` | L/(I1+I2)=ω | 非正碰旋转 | 禁止简化直线运动 |
| Slip | 同 Inelastic · type=SLIP | 仅 super e=0 | 不建 cluster | |
| Clock | `CollisionLabModel` | step/stepManual | 无 Clock 类 | Ticker→stepManual |
| Step fwd/back | `stepForwards/Backwards` | ±0.01s；back 用 −dt | 非 history | 见 §3 |
| Drag+snap | `Ball.dragToPosition` | grid→0.1 round | 1D y=0 | Model snap |
| Keypad/More Data | BallValuesPanel + KeypadDialog | 位置/速度/质量 | 须迁移 | |
| Momenta | `MomentaDiagram.updateVectors` | 1D 堆叠 / 2D tip-tail | | |
| Δp Intro | IntroCollisionEngine + IntroBallSystem | 0.5+0.5s | QP 默认 | 禁止猜 0.3s |
| Paths | CollisionLabPath | Explore2D/Inelastic | lifetime 3s | |
| Reset vs Restart | CollisionLabModel | 见 §3 | 语义不同 | |

---

## 2. 碰撞算法（源码公式）

### 2.1 step 循环 `[已确认]` `CollisionEngine.js:116-198`

检测所有潜在 Collision → 取本步**最早**碰撞 → `progressBalls(timeUntil)` → `handleCollision` → 缩短剩余 `dt` → 重复（max 2000）。无碰撞则整步匀速推进。

### 2.2 球-球检测 `[已确认]` `:336-355`

```
ΔR = p2−p1
ΔV = (v2−v1)*velocityMultiplier
a=|ΔV|², b=2 ΔV·ΔR, c=clampDown(|ΔR|²−(r1+r2)²)
root = min(quadraticRoots); collisionTime = elapsed + root*multiplier (若有效)
```

### 2.3 球-球响应 `[已确认]` `:391-443`

```
e = elasticity; if dt<0: e = 1/e
n̂ = normalize(p2−p1); t̂ = (−ny, nx)
v1n'=((m1−m2 e)v1n + m2(1+e)v2n)/(m1+m2)
v2n'=((m2−m1 e)v2n + m1(1+e)v1n)/(m1+m2)
切向分量不变；|v*| < 1e-8 → 0
```

### 2.4 球-边 `[已确认]` `:564-590`

朝向边运动时：`vx ← −vx·e` 或 `vy ← −vy·e`（负 dt 同样 `e←1/e`）。

### 2.5 Explore1D e=0 `[已确认]`

组内接触且相对速度≈0 的球：`v ← (Σpx/Σm, 0)`；撞边则组内 `v=0`。

### 2.6 Inelastic STICK `[已确认]`

先跑 e=0 法向响应，再：

```
I_i = |r_i − r_com|² · m_i
ω = L_total / (I1+I2)
L_total = Σ (r−r_com) × m(v−v_com)   // 2D 标量叉积
```

`RotatingBallCluster`：相对 COM 旋转 `Δθ=ω dt`，`v_rel=(−ω y, ω x)`，再加 `v_com`。

---

## 3. 时间 / Reset `[已确认]`

| API | 行为 |
|---|---|
| `step(dt)` | playing 时 `stepManual(dt * {1\|0.33})` |
| `stepForwards` | `+TIME_STEP_DURATION` (0.01) |
| `stepBackwards` | `−min(0.01, elapsed)` |
| `reset` | 全量子模型 reset（含球数、checkbox、弹性等） |
| `restart` / `returnBalls` | pause；elapsed=0；球回 `restartState`；engine.reset |

UI：后退步进仅在 **暂停 ∧ elasticity=100% ∧ elapsed≠0**（`CollisionLabTimeControlNode`）。

---

## 4. Ball / Radius / Drag

| 项 | 源码 |
|---|---|
| Canonical | position, velocity, mass, rotation, restartState |
| Derived | speed, momentum, radius, insidePlayArea |
| radius | `r=(3/4·m/35/π)^(1/3)` 或 `0.15` |
| drag 无 grid | `bounds.eroded(r).closestPointTo` |
| drag + grid | grid-safe bounds + `roundVectorToNearest(·, 0.1)` |
| 1D | `y=0` 强制 |

---

## 5. 默认 BallState（迁移初始条件）

### Intro
| # | p | v | m |
|---|---|---|---|
| 1 | (−1,0) | (1,0) | 0.5 |
| 2 | (1,0) | (−0.5,0) | 1.5 |

### Explore1D（预填 5，默认显示 2）
见 `Explore1DBallSystem.js:21-27`（Phase 0 探索已录）。

### Explore2D（预填 4，默认 2）
见 `Explore2DBallSystem.js:45-50`。

### Inelastic
初始 = Explore2D 前两球；Presets：CRISS_CROSS / HEAD_ON / GLANCING / CUSTOM。

---

## 6. PlayArea 差异

| Screen | Dim | Reflecting | Elasticity | Grid |
|---|---|---|---|---|
| Intro | 1D · h=1.1 | **关**（无 checkbox） | 0–100 | tick 常显 · snap |
| Explore1D | 1D · h=1.1 | 默认开 | 0–100 | tick 常显 |
| Explore2D | 2D · 4×2 | 默认开 | **5–100** | checkbox |
| Inelastic | 2D · 4×2 | 默认开 | **固定 0** | checkbox |

---

## 7. UI / Controls（必须迁移清单）

- Balls NumberPicker（Explore1D/2D）
- Mass sliders / Constant Size
- Elasticity（Intro/Explore*；Inelastic 无滑条、有 Stick/Slip）
- Reflecting Border（非 Intro）
- Velocity / Momentum / Center of Mass / Kinetic Energy / Values / Paths / Change in Momentum（按屏）
- More Data → BallValuesPanel 扩展列 + Keypad
- Momenta Diagram accordion + zoom
- Time：Play/Pause · Step · Reverse Step · Normal/Slow
- Restart · Reset · Return Balls
- Inelastic Presets

---

## 8. 坐标与视图

- Model：米，+x 右，**+y 上**
- View：标准 Flutter +y 下 → 需 ModelViewTransform 翻转 y
- ScreenView margins：`SCREEN_VIEW_X_MARGIN=15`, `Y=10.5`
- Control panel content width：218

---

## 9. Phase 1 状态

证据矩阵完整；关键公式已摘录。**无 BLOCKED** → 进入 Phase 2 Visual Baseline。
