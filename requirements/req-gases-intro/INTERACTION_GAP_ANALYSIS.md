# INTERACTION_GAP_ANALYSIS — Gases Intro

**日期**：2026-09-06  
**权威**：gases-intro 壳 + gas-properties Ideal @ `10c7c08`  
**状态**：**[迁移功能/交互架构不一致]**（封板撤销）

---

## 总判

当前 Flutter **模型层大体对齐 IdealGasLaw**（P/T/V 公式、泵 +50、heatCool 缩放速度等），但 **View / Interaction 架构偏离原版**：把原版「play-area 直接操纵仪器」收成了「右侧参数表 + 数值条」，导致用户感知为功能/交互错误，而不仅是视觉差异。

| 维度 | 原版 | 当前 Flutter | Gap |
|---|---|---|---|
| 加粒子主路径 | **自行车泵拖动手柄**（50/次） | `ElevatedButton +N` | **[功能差异]** |
| 加/减粒子辅路径 | Particles accordion **Fine/Coarse spinner** | 几乎只有按钮；无 coarse/fine | **[功能差异]** |
| 粒子类型 | 泵下方 **radio**（图标+颜色） | Chip | **[交互近似]** |
| Heat/Cool | 容器下方 **HeaterCooler 桶+滑条**；松手回 0；暂停禁用 | 右侧面板 Slider，可卡住非零 | **[功能差异]** |
| 体积 | **左墙 Handle 拖拽**；Ideal：按下暂停+灰粒子，松手 redistribute | 右侧 **Width Slider** | **[功能差异]** |
| 温度显示 | **Thermometer** 挂在容器上 | 顶部 T 文本条 | **[功能差异]** |
| 压强显示 | **PressureGauge** 挂在容器右上 | 顶部 P 文本条 | **[功能差异]** |
| 右侧面板 | Hold Constant + Width/Stopwatch/CollisionCounter + Particles accordion | Particles/Heat/Width 大杂烩 | **[功能差异]** |
| 活塞 | **不存在**（左墙） | 无活塞（正确）但误用滑条代体积 | **[功能差异]** |

---

## ORIGINAL INTERACTION MODEL

### 布局（IdealGasLawScreenView + IdealScreenView）

```
[ Container + particles + left Handle + lid ]
[ Thermometer ] [ PressureGauge ]
[ HeaterCooler under container ]     [ BicyclePump + type radio ]
[ TimeControl near container ]       [ Erase near container ]
                                     [ Right: HoldConstant? + checkboxes ]
                                     [ Right: Particles accordion ]
```

### 粒子加入/移除 [已确认]

| 动作 | 控件 | Model | 细节 |
|---|---|---|---|
| 主加 | `GasPropertiesBicyclePumpNode` | `numberOfHeavy/LightParticlesProperty +=` | **50/次**；`addParticlesOneAtATime: false`；手柄拖动触发 |
| 类型 | `ParticleTypeRadioButtonGroup` | `particleTypeProperty` | heavy/light 切换泵体颜色 |
| 辅加/减 | `ParticlesAccordionBox` FineCoarseSpinner | 同上 NumberProperty | fine=1，coarse=50 |
| 清空 | `EraseParticlesButton` | `removeAllParticles` | 容器旁 |
| 逃逸 | 开盖 | 出容器 → outside → 库存立即 −1 | |

注入：入口内侧；`|v|=√(3kT/m)`；角 `π±π/4`；多粒子 Gaussian T。

### Heat / Cool [已确认]

```
HeaterCooler slider → heatCoolFactorProperty ∈ [-1,1]
每步: v *= (1 + f/800)
→ ⟨KE⟩ → T=(2/3)⟨KE⟩/k → P=(NkT/V)×SCALE
```

- 暂停：slider **disabled**
- Hold `temperature` / `pressureT`：slider **hidden**
- 松手：scenery-phet HeaterCooler 回落（模型 factor→0）

### Volume /「Piston」[已确认]

- **无 piston**。`IdealGasLawContainer` **左墙** + `HandleNode` + `ContainerResizeDragListener`
- Ideal：`leftWallDoesWork=false` → 按下暂停、粒子 opacity 0.6、松手 `redistributeParticles(new/old)`
- V = width × 8750 × 4000

### Pressure [已确认]

**源码就是 Ideal Gas Law 派生，不是墙冲量积分：**

```
MODEL:  P_kPa = (N * k * T / V) * 1.66E6
GATE:   空容器或尚未发生墙碰 → 不更新 / 0
DISPLAY: PressureGauge 每 0.75 ps；噪声本 sim 默认关
BLOW:   P > 20000 → lid off
```

→ Flutter 用 `P=NkT/V` **不是简化替代**，是 **[源码一致]**。  
缺口在于：**必须保证** Heat/泵/改宽改变的是粒子/体积，再驱动 T→P，而不是只改数字控件。

### Controls 全表

| Control | State | Model effect | Visual |
|---|---|---|---|
| Bicycle pump | N↑ | addParticles | 泵柄动画 + 粒子出现 |
| Type radio | heavy/light | 选泵 | 泵颜色 |
| Particles spinner | N | set count | 粒子增减 |
| Erase | N=0 | erase | 清空 |
| HeaterCooler | heatCoolFactor | scale v | 火焰/冰 + 粒子加速/减速 |
| Left handle | width | V + redistribute | 墙移动 |
| Lid handle | open | escape | 盖移动 |
| Thermometer | T display | 只读 | 水银柱 |
| Pressure gauge | P display | 只读 | 指针 |
| Hold Constant | mode | 补偿 V/T | Laws 面板 |
| Width checkbox | widthVisible | — | 尺寸箭头 |
| Stopwatch / CollisionCounter | tool visibility | — | 工具 |
| Play/Pause/Step | clock | stepSystem | — |
| Reset All | all | reset | — |

---

## CURRENT FLUTTER INTERACTION MODEL

`GasesIntroShell`：

- Play area：`CustomPaint` 画容器+粒子（**无**可拖左墙 hit target、无表、无泵、无加热桶）
- 顶栏：T/P/N **文本条**
- 底栏：Play/Pause/Step/Reset icons
- 右栏：Type chips + **Pump 按钮** + Heat **Slider** + Width **Slider** + HoldConstant dropdown + checkboxes

时钟：`IdealGasLawModel` 内 `Ticker` → `tick` → `stepSystem`（heatCool→move→collide→T→P）— 模型链 **存在**。

---

## GAP → 修复优先级

### P0（必须先修交互语义）

1. **恢复自行车泵拖动**为加粒子主路径（50/次）；radio 选 Heavy/Light  
2. **左墙 Handle 拖拽**改体积；移除「右侧 Width Slider 作为主操纵」  
3. **HeaterCooler** 放到容器下方；松手 factor→0；暂停禁用；绑定 `heatCoolFactor`→速度缩放（已有模型，修 UI）  
4. **Thermometer + PressureGauge** 绑 MODEL/DISPLAY pressure，挂在容器侧（禁止仅顶栏数字冒充仪器）  
5. 右侧只保留：Hold Constant（Laws）+ checkboxes + Particles Fine/Coarse accordion  
6. 文档明确：P=NkT/V 为源码算法；验证 Heat→KE→T→P 测试

### P1

- Macro↔Micro 双向：泵/加热/拖墙后读出与粒子运动同时变化  
- 去掉「像参数表」的多余结构

### P2–P3

- 泵/表/加热器几何与资产对齐（在功能正确后）

---

## 不会改

- Canonical 物理公式（除非测出迁移错误）
- common API / 跨 sim framework
- Diffusion / Collision Lab

## 封板

`meta.yaml`：`status: interaction_fix`（非 done）
