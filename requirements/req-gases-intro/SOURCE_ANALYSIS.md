# SOURCE_ANALYSIS — Gases Intro（Ideal Gas Law 路径）

**取证基线**
- Preferred worktree：`phet sourses/gas-properties-for-gases-intro` @ **`10c7c08d5866622426ba1969c35465c3269a70df`**
- Fallback：`gas-properties-for-diffusion` @ `7a52c48`（Ideal 模型相同）
- Gases Intro 壳：`phet sourses/gases-intro-main/gases-intro-main/`

**范围**：仅 Ideal / IdealGasLaw 公共路径。禁止 Explore / Energy / Diffusion 专属迁移。

---

## 0. 架构总览

| 层 | 路径 | 说明 | 标记 |
|---|---|---|---|
| IntroScreen | `gases-intro/.../intro/IntroScreen.ts` | IdealScreen，Hold Constant 关 | [已确认] |
| LawsScreen | `gases-intro/.../laws/LawsScreen.ts` | IdealScreen，Hold Constant 开 | [已确认] |
| IdealScreen | `gas-properties/.../ideal/IdealScreen.ts` | `hasHoldConstantControls` | [已确认] |
| IdealModel | `ideal/model/IdealModel.ts` | extends IdealGasLawModel，无附加逻辑 | [已确认] |
| IdealGasLawModel | `common/model/IdealGasLawModel.ts` | PV=NkT 编排 | [已确认] |
| BaseModel | `common/model/BaseModel.ts` | play/pause/speed/MVT | [已确认] |

---

## 1. Screen / Lifecycle / Reset

| 功能 | 源 | 结论 | 标记 |
|---|---|---|---|
| Screen count | `gases-intro-main.ts` | Intro → Laws | [已确认] |
| Independent models | IdealScreen `createModel` | 每屏独立 IdealModel | [已确认] |
| pressureNoise default | `gases-intro-main.ts` L30–32 | 未指定 QP 时强制 **false** | [已确认] |
| Reset All | BaseScreenView → model.reset + view props + pumps | 清空粒子、回默认 width、hold=nothing | [已确认] |

**IdealGasLawModel.reset 顺序** [已确认]：BaseModel → holdConstant / heatCoolFactor / PP collisions → container / particleSystem / temperature / pressure / collisionCounter。

---

## 2. Clock

| 项 | 值 | 标记 |
|---|---|---|
| NORMAL | 2.5 ps / s real | [已确认] `TimeTransform.NORMAL` |
| SLOW | 0.3 ps / s | [已确认] 模型存在 |
| Ideal Slow UI | **无**（`hasSlowMotion: false`） | [已确认] |
| Step | 固定 **0.2** ps 模型时间 | [已确认] `MODEL_TIME_STEP` |
| Pause | `isPlayingProperty=false` → BaseModel.step no-op | [已确认] |

调用链：`Sim → BaseScreenView.step → BaseModel.step → stepRealTime → stepModelTime(ps)`。

---

## 3. IdealGasLawModel 单步顺序

**`stepSystem(dt)`** [已确认]：
1. `particleSystem.heatCool(heatCoolFactor)`
2. `particleSystem.step(dt)` — 积分位置
3. `escapeParticles`
4. `container.step(dt)`
5. `collisionDetector.update()`
6. `removeParticlesOutOfBounds`
7. `collisionCounter.step`（若有）

**`updateModel`** [已确认]：
1. `compensateForHoldConstant()`
2. `temperatureModel.update()`
3. `pressureModel.update(dt, collisions)`
4. `verifyModel()` — 超高温清场

暂停时 N 或 width 变化 → `updateWhenPaused()`。

---

## 4. Temperature

| 项 | 公式 / 行为 | 标记 |
|---|---|---|
| Instantaneous T | `T = (2/3) * ⟨KE⟩ / k`；N=0 → `null` | [已确认] |
| KE | `½ m \|v\|²` | [已确认] |
| k | `BOLTZMANN = 8.316E3` | [已确认] |
| Empty inject T | 300 K | [已确认] |
| Heat/Cool | `v *= 1 + f/800`，`f∈[-1,1]` | [已确认] |
| Hold T + N↓ | `setTemperature` 重标 \|v\| | [已确认] |
| Ideal 用户控初始 T | `controlTemperatureEnabled` 默认 false（Energy 专属） | [已确认] |

**禁止**自行套教材公式替代源码；源码确为 `(2/3)KE/k` 与 `PV=NkT` 体系。

---

## 5. Pressure

| 项 | 定义 | 标记 |
|---|---|---|
| MODEL P | `(N*k*T/V)*1.66E6` → kPa | [已确认] |
| Gate | 空容器或尚未发生墙碰 → P=0 / 不更新 | [已确认] |
| Blow lid | P > 20000 kPa → `blowLidOff` | [已确认] |
| DISPLAY | PressureGauge 每 **0.75** ps；可选噪声 | [已确认] |
| Noise (本 sim) | 默认 **off** | [已确认] |
| Display units | 默认 atmospheres；`atm = kPa * 0.00986923` | [已确认] |

**不是**仅靠墙冲量估计；**是** Ideal Gas Law 派生（文档与代码一致）。

---

## 6. Volume / Container /「Piston」

| 项 | 值 | 标记 |
|---|---|---|
| V | `width * height * depth` | [已确认] |
| height / depth | 8750 / 4000 pm | [已确认] |
| width | [5000, 15000]，默认 10000 pm | [已确认] |
| leftWallDoesWork | **false**（Ideal） | [已确认] |
| 用户拖宽 | 按下暂停 → 松手 redistribute `x*=scale` | [已确认] |
| Piston | **不存在** | [已确认] |

---

## 7. Particles / Pump

| 项 | Heavy | Light | 标记 |
|---|---|---|---|
| mass | 28 AMU | 4 AMU | [已确认] |
| radius | 125 pm | 87.5 pm | [已确认] |
| N range | 0–1000 | 0–1000 | [已确认] |
| Pump batch | 50 | 50 | [已确认] |
| Inject \|v\| | `√(3 k T / m)` | 同 | [已确认] |
| Angle | `π - π/4 + U*(π/2)`（向左扇形 ±45°） | [已确认] |
| Multi-T | Gaussian(mean, 0.2·mean) 当 n>1 且 PP 开 | [已确认] |

---

## 8. Collisions

| 项 | 结论 | 标记 |
|---|---|---|
| Detector | `CollisionDetector`（非 Diffusion 子类） | [已确认] |
| PP | 完全弹性 e=1；冲量公式见 CollisionDetector | [已确认] |
| Wall | 夹回 + 速度分量取反；Ideal wallVx=0 | [已确认] |
| Regions | `regionLength = height/4` | [已确认] |
| vs Diffusion | PP 同源；墙边界 Diffusion 有 divider 特化 | [已确认] |

**迁移**：不得复制 Collision Lab；可对照 GP 同源算法，实现在 `lib/gases_intro/`。

---

## 9. Hold Constant（仅 Laws 暴露 UI）

| 模式 | 行为摘要 | 标记 |
|---|---|---|
| nothing | 默认；改 N/T/V → P 变 | [已确认] |
| volume | 禁改 V | [已确认] |
| temperature | 禁加热；N↓ 保 T；开盖 oops | [已确认] |
| pressureV | 每步调 V=`NkT/P` + redistribute | [已确认] |
| pressureT | 每步 `setTemperature` | [已确认] |

Intro 屏：`hasHoldConstantControls=false`，模型仍持有 `holdConstant='nothing'`。

---

## 10. Randomness

- `dotRandom`：注入角、噪声、Gaussian
- **无** sim 固定 seed [已确认]
- 测试：统计/公式容差，不要求轨迹像素级一致

---

## 11. Controls 清单

| 控件 | Intro | Laws |
|---|---|---|
| Heavy/Light BicyclePump + type radio | ✓ | ✓ |
| HeaterCooler | ✓ | ✓ |
| 左墙 width handle | ✓ | ✓ |
| Lid / Return Lid | ✓ | ✓ |
| Thermometer + units | ✓ | ✓ |
| Pressure gauge + units | ✓ | ✓ |
| Particles accordion (spinners) | ✓ | ✓ |
| Width / Stopwatch / CollisionCounter checkboxes | ✓ | ✓ |
| Hold Constant | ✗ | ✓ |
| Play / Pause / Step | ✓ | ✓ |
| Normal/Slow | ✗ | ✗ |
| Reset All | ✓ | ✓ |
| Erase particles | ✓ | ✓ |

---

## 12. Assets

泵、加热器、表、温度计、粒子球 = **程序几何**（scenery-phet / ShadedSphere）。  
位图仅截图与品牌图。详见 `visual-qa/ASSET_MAPPING.md`。

---

## 2026-09-06 Interaction repair note

封板撤销。详见 `INTERACTION_GAP_ANALYSIS.md`。

追加确认：

- Pressure **源码**为 `P=(NkT/V)*SCALE`（非墙冲量积分）；Flutter 同算法 = [源码一致]，不是教材偷换。
- 无活塞；体积交互 = 左墙 Handle。
- View 必须以泵拖动 / 左墙拖 / HeaterCooler / Gauge+Thermometer 为因果入口，不得以参数表替代。
