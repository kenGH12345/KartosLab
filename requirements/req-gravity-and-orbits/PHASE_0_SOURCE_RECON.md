# PHASE 0 — Source Recon · Gravity and Orbits

> 源码根：`phet sourses/gravity-and-orbits-main/gravity-and-orbits-main`  
> 版本：**1.7.0-dev.7**（`package.json`）  
> 侦察日期：2026-09-16 · **本地源码为 PRIMARY SOURCE OF TRUTH**

---

## 1. Source Tree

```
gravity-and-orbits-main/
├── package.json
├── assets/                 # .ai / marketing（非 runtime）
├── doc/model.md            # PEFRL 算法说明（Distance:km 已过时，代码用 m）
├── images/                 # iconMass / pathIcon / pathIconProjector + *_png.ts
├── mipmaps/                # sun/earth/moon/moonGeneric/planetGeneric/spaceStation/modelIcon/toScaleIcon
├── js/
│   ├── gravity-and-orbits-main.ts   # 入口
│   ├── GravityAndOrbitsStrings.ts
│   ├── common/
│   │   ├── SceneFactory.ts / GravityAndOrbitsScene.ts / Constants / Colors
│   │   ├── model/  Body, BodyState, BodyConfiguration, ModelState, Clock,
│   │   │          PhysicsEngine, GravityAndOrbitsModel, ModeConfig, RewindableProperty, Pair
│   │   └── view/   ScreenView, SceneView, BodyNode, BodyRenderer, VectorNode,
│   │               DraggableVectorNode, PathsCanvasNode, MassSlider, CheckboxPanel, …
│   ├── model/      ModelScreen / ModelModel / ModelSceneFactory
│   └── toScale/    ToScaleScreen / ToScaleModel / ToScaleSceneFactory
└── sounds/                 # 不存在
```

---

## 2. Entry Point

`js/gravity-and-orbits-main.ts` → `Sim([ModelScreen, ToScaleScreen])`

顺序：**Model → To Scale**。

---

## 3. Screen Map

| # | Screen | Model class | showMass | measuringTape | adjustMoonOrbit | 半径 |
|---|---|---|---|---|---|---|
| 1 | Model | ModelModel + ModelSceneFactory | ❌ | ❌ | ✅ `fudge=10200` | 人工放大 |
| 2 | To Scale | ToScaleModel + ToScaleSceneFactory | ✅ | ✅ | ❌ | 真实半径 |

Model 半径乘数：Sun×50，Earth/Moon(in sun scenes)×800，Earth+Moon×15，ISS planet×0.8 / sat×20000。  
Model 太阳 `isMovable=false`；To Scale 太阳可动。

---

## 4. Model Map

`GravityAndOrbitsModel` 跨场景共享：

| Property | Default |
|---|---|
| showGravityForce / Velocity / Path / Grid / Mass / MeasuringTape | false |
| isPlaying | false |
| timeSpeed | NORMAL |
| gravityEnabled | true |
| sceneProperty | scenes[0] |

每场景自有：`GravityAndOrbitsPhysicsEngine` + `GravityAndOrbitsClock` + bodies + MVT + zoom + measuring tape endpoints。

---

## 5. Physics Map

### 力

```
F = G * m1 * m2 / r² * unit(target - source) * fudgeFactor
```

- `G = PhysicalConstants.GRAVITATIONAL_CONSTANT`（SI ≈ `6.67430e-11`；本树未 vendoring，实现时锁定此值）
- 重合位置 → F=0；exploded → F=0
- Model only：`source=moon && target=planet` → `fudgeFactor=10200`
- `Pair` **不参与**力计算（仅 PhET-iO 距离）

### 积分器：**PEFRL**（非 Euler / Verlet / 椭圆公式）

```
XI     =  0.1786178958448091
LAMBDA = -0.2123418310626054
CHI    = -0.06626458266981849
```

五步位置/速度交替（`ModelState.getNextInteractingState`）。重力 off → 匀速滑行。

### 碰撞

半径重叠 → **质量较小者** `isCollided=true`（爆炸动画，不合并动量）。

---

## 6. Clock Map

| 常量 | 值 |
|---|---|
| CLOCK_FRAME_RATE | 60 |
| DAYS_PER_TICK | 1/(60/25) = 1/2.4 |
| SECONDS_PER_DAY | 86400 |
| DEFAULT_DT | 36000 s |

每帧（running）：

```
smallestTimeStep = baseDTValue * 0.13125
SLOW→1 / NORMAL→4 / FAST→7 子步
elapsed = smallestTimeStep * numberOfSteps
```

场景 baseDT：Sun modes=36000；Earth+Moon=12000；Earth+ISS=32.4。  
暂停步进：`dt = 1/60` wall → 仍走完整 `stepModel` 路径（issue #253）。

---

## 7. Scene / Preset Map（4 预设 × 2 屏）

基类物理常数（`SceneFactory.ts`）：

| | mass | radius | 关键位置/速度 |
|---|---|---|---|
| Sun | 1.989e30 | 6.957e8 | (0,0), v=0 |
| Earth | 5.9724e24 | 6.371e6 | perihelion 1.47098074e11, vy=30300 |
| Moon | 7.346e22 | 1.7274e6 | (perihelion, 3.633e8), vx=-1082, vy=30300（sun scenes） |
| ISS | 419725 | 45.5 | x=347000+R_earth+R_iss, vy=7706 |

构造后 `ModeConfig.center()`：动量中心系修正 vx/vy。

| Scene | zoom | velocityScale | forceScale base | time format |
|---|---|---|---|---|
| starPlanet | 1.25 | 4.48e6 | FORCE_SCALE×120 | Earth Days |
| starPlanetMoon | 1.25 | 4.48e6 | FORCE_SCALE×120 | Earth Days |
| planetMoon | 400 | 4.48e6×0.06 | FORCE_SCALE×45 | Earth Days |
| planetSatellite | 21600 | 4.48e6/10000 | FORCE_SCALE×3e13 | Earth Minutes |

`FORCE_SCALE = 76.0 / 5.179e15`。

Model 额外：SunEarth/SunEarthMoon `forceScale×0.58`；PlanetMoon `×0.79`；Moon `vx×21`、`y=planet.radius*1.7`。

---

## 8. View Map

- Stage：`SCALE=0.8`，`WIDTH=790/0.8`，`HEIGHT=618/0.8`
- MVT：`z = targetScale * 1.5e-9`；`createRectangleInvertedYMapping`；view 高度减 50
- 右：场景选择 + Gravity + checkboxes；下：质量滑条
- 底：时间控制（Fast/Normal/Slow + play/step/rewind）+ TimeCounter + Clear
- 右下：Reset All；左上：Zoom `[0.5, 1.3]`

---

## 9. Interaction Map

| 交互 | 效果 |
|---|---|
| 拖天体 | **只改 position**；清 path；暂停时存 rewind |
| 拖速度箭头 tip | 改 **velocity**（delta/scale）；view 长&lt;10 → v=0 |
| Rewind / Return Objects | rewindable 属性 + clearPath（Return 额外 pause） |
| Clear | **只清仿真时间显示**，不清 path |
| Path checkbox 开 | clearPath 后重记 |

---

## 10. Trajectory Map

- 每子步结束后 `addPathPoint`（非拖动、非爆炸、movable）
- `maxPathLength ≈ 0.85 × 2π × distToCenter`（过近用 options 兜底）
- `pathLengthLimit = 6000`；尾部 15% 淡出；线宽 3

---

## 11. Force / Vector Map

- Physics force → `forceProperty = acceleration * mass`
- Display：`viewTip = modelToView(pos) + force * forceScale`（再经场景系数）
- Velocity 同理 × `velocityVectorScale`
- 颜色：`PhetColorScheme.GRAVITATIONAL_FORCE` / `VELOCITY`；描边 `rgb(64,64,64)`

---

## 12. Reset Map

| 动作 | 范围 |
|---|---|
| Reset All | 全局 UI + 所有 scene.reset（bodies/clock/zoom/tape） |
| Scene 旁路 reset | 该 scene bodies + time；**不**改全局 checkbox |
| Rewind | rewindable state + clearPath |
| Clear | time=0 only |

---

## 13. Asset Map

**mipmaps**：sun, earth, moon, moonGeneric, planetGeneric, spaceStation, modelIcon, toScaleIcon  
**images**：iconMass, pathIcon, pathIconProjector  
质量≠默认 → planet/moon 切到 generic PNG。

---

## 14. Reusable KARTOSLAB Components

| 组件 | 路径 | 用法 |
|---|---|---|
| SimulationClock | `lib/common/simulation_clock.dart` | 60fps 心跳（timeSpeed 在 GAO model 内处理子步） |
| KratosResetAllButton | `lib/common/widgets/kratos_reset_all_button.dart` | Reset All |
| KratosTabbedScreen | `lib/common/widgets/kratos_tab_bar.dart` | Model / To Scale |
| KratosSlider | `lib/common/controls/kratos_slider.dart` | 质量 / zoom |
| KratosRadioGroup | `lib/common/controls/kratos_radio_group.dart` | Gravity / speed |
| ArrowPainter | `lib/common/controls/arrow_painter.dart` | 矢量 |
| Visual QA 管线 | `tool/*` + `requirements/*/visual-qa/` | 复用 projectile 模式 |

**禁止**：复用 `my_solar_system` 的 G/单位/`NumericalEngine`（G=4.45… 非 SI）。仅可参考目录与 UI 骨架。

---

## 15. Risks / Unknowns

1. G 精确值需与 phet-core 锁定（建议 `6.67430e-11`，用轨道回归验证）
2. `center()` 后精确初速需在 Dart 复现相同算法
3. Model 月球三耦合（vx×21 / y抬高 / fudge 10200）缺一即崩轨
4. 时间子步 `0.13125×{1,4,7}` 绑定可复现性
5. doc 写 Distance:km 与代码 m 矛盾 → **以代码为准**
6. Checkbox / Fast-Normal-Slow 无完美 L0，需局部实现
7. Home 在 Final Gate 前禁止接入
