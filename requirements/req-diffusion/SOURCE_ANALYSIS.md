# SOURCE_ANALYSIS — Diffusion

**取证**：diffusion `1.2.0-dev.0` + gas-properties **`7a52c48a`**

---

## 总表

| 功能 | Source | Class / API | 算法要点 | 迁移结论 |
|---|---|---|---|---|
| Screen | diffusion-main.ts | `DiffusionScreen` ×1 | 单屏 | [源码一致] 单 Screen |
| Top model | DiffusionModel.ts | extends `BaseModel` | 非 IdealGasLaw | [源码一致] |
| Clock | BaseModel.ts | `step`→`stepRealTime`→`timeTransform`→`stepModelTime` | 见下 | [源码一致] |
| Normal/Slow | TimeTransform.ts | NORMAL **2.5** ps/s；SLOW **0.3** ps/s | `LinearFunction` s→ps | [源码一致] |
| Step | BaseScreenView.ts | `timeTransform.inverse(MODEL_TIME_STEP)` 再 `stepRealTime` | MODEL_TIME_STEP=**0.2** ps | [源码一致] |
| Container | DiffusionContainer.ts | width=**16000** pm 固定；height=**8750**（BaseContainer）；dividerThickness=**100** | hasDivider | [源码一致] |
| Settings L/R | DiffusionSettings.ts | N∈[0,200] Δ10；m∈[4,32] AMU Δ1；r∈[50,250] pm Δ5；T₀∈[50,500] K Δ50；defaults N=0,m=28,r=125,T=300 | left/right 独立 | [源码一致] |
| Init velocity | DiffusionModel addParticles | \|v\|=√(3kT/m)；θ~U[0,2π) | k=BOLTZMANN **8.316E3** | [源码一致] |
| Position init | addParticles | uniform in bounds inset by radius | `dotRandom` | [源码一致] 非固定 seed |
| Particles | DiffusionParticle1/2 | cyan `rgb(0,230,255)` / red `rgb(232,78,32)` + highlights | mass/radius mutable | [源码一致] |
| Step particles | ParticleUtils.stepParticles | 保存 previous；x+=vx·dt | 单位 ps | [源码一致] |
| Collision | CollisionDetector + DiffusionCollisionDetector | PP elastic e=1；wall reflect；divider→两套 bounds | regions grid | [源码一致] 独立于 Collision Lab |
| Divider remove | hasDividerProperty | false→两侧连通；true→restart 粒子 | | [源码一致] |
| Data | DiffusionData | count by bounds.contains；T=(2/3)⟨KE⟩/k | derived | [源码一致] |
| COM | ParticleUtils.getCenterXOfMass | | | [源码一致] |
| Flow rate | ParticleFlowRate | divider 移除后 step | | [源码一致] |
| MVT | BaseModel | scale **0.040** px/pm；y 翻转；origin offset (670,520) view | | [源码一致] |
| Random | dotRandom | 无固定 seed（默认） | 测试用统计/边界 | [已确认] |
| Ideal Gas | — | **不使用** | | [有意差异/禁止迁入] |

---

## Clock 细节

```
real dt (s)
  → if playing: stepRealTime(dt)
  → modelDt_ps = timeTransform.evaluate(dt)   // NORMAL: ×2.5, SLOW: ×0.3
  → stepModelTime(modelDt_ps):
       ParticleUtils.stepParticles
       flowRate.step (若无 divider)
       collisionDetector.update
       updateCenterOfMass / updateData
```

Step 按钮：

```
seconds = timeTransform.inverse(0.2)  // 使模型步进正好 0.2 ps
stepRealTime(seconds)
```

→ Step **不受** Slow 改变模型步进长度（0.2 ps 固定）；`inverse` 抵消当前 transform。

---

## Collision 语义（摘要）

**PP**：当前重叠且上一步未接触 → 接触点、反射位置、冲量 j（e=1）。  
**Wall**：越界夹回 + 对应速度分量取反（左墙可含 wall velocity；Diffusion 固定壁用 0）。  
**Divider 在位**：particle1 只对 leftBounds，particle2 只对 rightBounds。  
**Divider 移除**：整容器 `container.bounds`。

---

## Controls（DiffusionControlPanel / ViewProperties）

至少：[已确认]  
- 左/右：Number of Particles、Mass、Radius、Initial Temperature  
- Remove/Restore Divider  
- Data accordion（N1,N2,⟨T⟩ 左右）  
- Center of Mass checkbox  
- Particle Flow Rate checkbox  
- Scale checkbox  
- Play / Pause / Step / Normal / Slow / Reset All  
- Stopwatch（BaseModel）

**无** particle drag（Diffusion 屏）— [已确认] 不自行添加。

---

## 标记

本分析全部基于 lock SHA 源码 → **[源码一致]** 取证完成，实现须对齐。
