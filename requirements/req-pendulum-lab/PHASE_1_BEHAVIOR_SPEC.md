# PHASE 1 — Behavioral Specification

Source: 本地 `pendulum-lab-main` 1.1.0-dev.5。未在源码中出现的能力 **不补充**。

---

## STATE MAP

启动（Intro）：

- 1 个可见摆，静止在 θ=0，ω=0
- L=0.70 m，M=1.00 kg，g=9.8（Earth），friction=0
- isPlaying=true，timeSpeed=1
- ruler 可见（左上）；stopwatch 隐藏；period trace 关
- 第二摆存在但 `isVisible=false`（L=1.00 m，M=0.50 kg）

Energy 额外：ruler 默认隐藏；能量盒展开；activeEnergyPendulum = 摆 1。

Lab 额外：能量盒收起；v/a 箭头关；Period Timer 隐藏。

---

## LIFECYCLE MAP

```
open tab → create model + SimulationClock.attach → play if isPlaying
switch tab away → TickerMode disables ticker
switch tab back → ticker resumes（模型状态保留，KratosTabSwitcher 保持挂载）
dispose / pop → clock.dispose()
reopen → 新 model 实例（默认态）
```

---

## PARAMETER TABLE

| Property | Initial | Min | Max | Step / constrain | Unit | Editable | Binding | Reset |
|----------|---------|-----|-----|------------------|------|----------|---------|-------|
| length[0] | 0.7 | 0.1 | 1.0 | slider 0.1；tweaker 0.01 | m | Y | Pendulum.length | 是 |
| mass[0] | 1.0 | 0.1 | 1.50 | slider 0.1；tweaker 0.01 | kg | Y | Pendulum.mass | 是 |
| length[1] | 1.0 | 0.1 | 1.0 | 同上 | m | 当 2 摆 | | 是 |
| mass[1] | 0.5 | 0.1 | 1.50 | 同上 | kg | 当 2 摆 | | 是 |
| gravity | 9.8 | 0 | 25 | slider 0.5 | m/s² | Y | gravityProperty | 是 |
| body | Earth | — | — | combo | — | Y | bodyProperty | 是 |
| friction | 0 | 0 | 0.5115 | slider 整型 0–10 对数映射 | — | Y | frictionProperty | 是 |
| numberOfPendula | 1 | 1 | 2 | radio | — | Y | 控制 isVisible | 是 |
| isPlaying | true | | | | | Y | | 是（回 true） |
| timeSpeed | 1 | 1/8 | 1 | aqua radio | | Y | | 是 |
| energyZoom | 1 | — | — | ×1.3 / ÷1.3 | | Energy/Lab | | 是 |
| angle | 0 | ~−179° | ~179° | 拖拽整度 | rad | 拖拽 | | 是 |
| ω | 0 | | | 拖开始清零 | rad/s | 否（拖清） | | 是 |
| thermal | 0 | | | 拖开始清零；能量图垃圾桶 | J | 部分 | | 是 |

Friction UI：`c = 0.0005·(2^s − 1)`，`s = round(log2(c/0.0005+1))`。

---

## INTERACTION MAP / TRANSITION MAP

### 拖动摆锤

1. start：`isUserControlled=true` → ω=0，thermal=0，tick 可见，`updateDerivedVariables(false)`
2. drag：`dragAngle = viewToModel(p).angle + π/2`；`θ = roundDeg(modAngle(offset+dragAngle))`；若 |deg|=180 → 179·sign
3. 拖期间角度变化立刻更新派生量（不转 thermal）
4. end：`isUserControlled=false`；若 isPlaying 则下一帧 RK4 从当前 θ、ω=0 开始

### 释放后动力学

RK4 连续；过 θ=0 发 `crossing`；ω 变号发 `peak`。无 teleport。

### 改长度

立即 `ω *= L_old/L_new`，保留 thermal。视觉杆长立即变。

### 改质量 / 重力

立即 `updateDerivedVariables(false)`（KE/PE 变，thermal 不变）。质量改 bob 缩放。

### 改摩擦

下一 RK4 子步进入 `frictionTerm`。c=0 时不向 thermal 转移。

### 暂停 / 恢复

暂停：不再 `modelStep`；状态冻结。恢复：同一 θ、ω 继续。Step：仍暂停，前进 0.01 s 模型时间（含 1.007 **不**乘；`stepManual` 直接 0.01）。

### Period Trace（Intro/Energy）

勾选 → 两可见摆 `periodTrace.isVisible`。状态 0 首次近零交叉（|θ|<0.5）开始；峰 1、峰 2、第三次零交叉完成；然后按 `1/(3·T_approx/2)` 淡出；`onFaded` 后 Intro/Energy 立刻再显示（连续描迹）。gravity/length/userControlled/visibility 变化清路径。

### Period Timer（Lab）

Play 清零并显示该摆 trace；`elapsedTime` 绑定 trace；points=4 时自动 stop。切换摆或改 L/g/拖动会 clear。

---

## RESET MAP

| 动作 | 摆运动 | 参数 | 工具 | 播放 |
|------|--------|------|------|------|
| Reset All | θ=ω=0，能量 0，tick 关 | 全部默认 | ruler/stopwatch/timer 回初始位与可见性 | isPlaying=true |
| Return | θ=ω=0，thermal 0，trace 点清 | 不变 | Lab：timer stop | 不变 |
| 拖开始 | ω=0，thermal 0 | 不变 | tick 开 | 不变 |

`Pendulum.reset()` **不**重置 `isVisible`（由 numberOfPendula 控制）。

---

## ENERGY / PERIOD

- 有摩擦：`thermal += (KE_old+PE_old) − (KE_new+PE_new)`
- 无摩擦：thermal 保持（数值 RK4 可有微小 KE+PE 漂移，不转入 thermal）
- 小角周期仅用于淡出：`T≈2π√(L/g)`
- Period Timer 测的是 trace 的 elapsedTime（含 1.007 时间缩放）
