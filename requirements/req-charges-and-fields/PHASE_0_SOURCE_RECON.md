# PHASE 0 — Source Recon · Charges and Fields

> 源码根：`phet sourses/charges-and-fields-main/charges-and-fields-main`
> 版本：**charges-and-fields 1.1.0-dev.12**（`package.json:3`）
> Behavior Reference = **local source**
> Visual Reference = published latest（交叉验证用；冲突时行为以本地为准）
> 侦察日期：2026-09-17

---

## Source Tree

```
charges-and-fields-main/
├── js/
│   ├── charges-and-fields-main.ts          # Entry (simLauncher)
│   ├── chargesAndFields.ts                 # namespace
│   ├── ChargesAndFieldsStrings.ts
│   └── charges-and-fields/
│       ├── ChargesAndFieldsScreen.ts       # 单 Screen
│       ├── ChargesAndFieldsConstants.ts
│       ├── ChargesAndFieldsColors.ts
│       ├── model/
│       │   ├── ChargesAndFieldsModel.ts    # ★ 总模型 + E/V 计算
│       │   ├── ChargedParticle.ts          # ±1 nC 点电荷
│       │   ├── ModelElement.ts             # 可拖拽 + 回 bin 动画
│       │   ├── ElectricFieldSensor.ts
│       │   ├── ElectricPotentialSensor.ts
│       │   ├── ElectricPotentialLine.ts    # ★ 等势线积分（非电场线）
│       │   └── MeasuringTape.ts
│       └── view/
│           ├── ChargesAndFieldsScreenView.ts
│           ├── ChargedParticleNode.ts / ChargedParticleRepresentationNode.ts
│           ├── ElectricFieldCanvasNode.ts / ElectricFieldArrow*.ts
│           ├── ElectricPotentialCanvasNode.ts / *WebGL*
│           ├── ElectricPotentialLinesNode.ts / ElectricPotentialLineView.ts
│           ├── ElectricPotentialSensorNode.ts / PencilButton.ts
│           ├── ElectricFieldSensorNode.ts / ElectricFieldSensorRepresentationNode.ts
│           ├── GridNode.ts
│           ├── ChargesAndFieldsControlPanel.ts
│           ├── ChargesAndFieldsToolboxPanel.ts
│           ├── ChargesAndSensorsPanel.ts
│           └── ChargesAndFieldsMeasuringTapeNode.ts
├── mipmaps/
│   ├── electricPotentialPanelOutline_png.ts
│   └── pencil_png.ts
└── doc/
    ├── model.md
    └── implementation-notes.md
```

无 `sounds/`。无独立「Field Line」类 — 可视化电场用 **箭头网格**；「线」指 **等势线 (Equipotential)**。

---

## Entry Point

- `js/charges-and-fields-main.ts` → `Sim(title, [ChargesAndFieldsScreen])`
- 标题：`Charges and Fields`
- **单屏**（无 Tab）

---

## Screen Map

| # | Screen | Model | View |
|---|---|---|---|
| 1 | ChargesAndFieldsScreen | ChargesAndFieldsModel | ChargesAndFieldsScreenView |

---

## Model Map

| 对象 | 职责 | 关键状态 |
|---|---|---|
| ChargedParticle | ±1 nC 点电荷 | `charge∈{+1,-1}`, position, isActive, isUserControlled, initialPosition |
| ElectricFieldSensor | 拖拽探针测 E | position, electricField (Vector2), isActive |
| ElectricPotentialSensor | 电压表 | position, electricPotential (V, 可 ±∞), isActive |
| MeasuringTape | 卷尺 | base, tip (默认 tip 相对 base `(0.2,0)` m), isActive |
| ElectricPotentialLine | 等势线 | seed position → positionArray, electricPotential |

可见性 Property（默认）：

| Property | Default |
|---|---|
| isElectricFieldVisible | **true** |
| isElectricFieldDirectionOnly | false |
| isElectricPotentialVisible | false |
| areValuesVisible | false |
| isGridVisible | false |
| snapToGrid | false |

Bounds：`WIDTH=8 m`, `HEIGHT=5 m` → nominal `(-4,-2.5)–(4,2.5)`；enlarged `(-6,-2.5)–(6,7.5)`。

---

## Electric Field Map

```
E = Σ_i  K * q_i * r̂ / r²
  = Σ_i  K * q_i * (r_vec) / (r²)^1.5
```

- `K_CONSTANT = 9`（Q 单位 nC，r 单位 m，E 单位 V/m）
- `MIN_DISTANCE_SCALE = 1e-9`：过近时 `E = (10 * MAX_EFIELD_MAGNITUDE, 0)`，`MAX_EFIELD_MAGNITUDE = 1e6`
- 仅对 `activeChargedParticles` 求和
- `isPlayAreaChargedProperty`：净电荷为 0 且共位对等特殊情况可判无场

**网格箭头显示**：长度固定；透明度 `α = clamp(|E|/5, 0, 1)`；Direction Only 时 `|E|>1e-9 → α=1`。

---

## Potential Map

```
V = Σ_i  K * q_i / r     （同点电荷则 ±∞）
```

- 与 E **独立计算**，禁止由 E 反推
- Voltage 色场饱和：`±40 V`
- Canvas 采样间距：`0.1 m`

---

## Field Line Map（澄清）

| 用户口语 | 源码实义 | 实现类 |
|---|---|---|
| 「电场线」 | **不存在**传统电场线 | — |
| 电场可视化 | 固定长度箭头网格 | ElectricFieldCanvasNode |
| 「画线」 | **等势线** | ElectricPotentialLine + Pencil |

等势线：双头搜索 + 电势校正（失败则 RK4）；`ε∈[0.01,0.05] m`；`MAX_STEPS=5000`；距电荷 `<0.03 m` 禁画。

---

## Measurement Map

| 工具 | 测量点 | 读数 |
|---|---|---|
| Electric Field Sensor | 圆心 = model position | E (V/m), angle (deg) |
| Electric Potential Sensor | 十字丝中心 = model position | V (V) |
| Measuring Tape | base↔tip | cm（multiplier 100） |
| Grid scale arrow | 模型 1 m @ `(2, -2.20)` | 「1 meter」（Values 开） |

---

## Clock Map

- **无**物理时间推进（静态静电场）
- `ANIMATION_VELOCITY = 2 m/s`：仅电荷/传感器回 bin 的 Tween
- Flutter：回 bin 用 `SimulationClock` 或 AnimationController；**禁止**为场计算开 Timer

---

## View Map（z-order 底→顶）

1. electricPotentialGridNode  
2. gridNode  
3. electricFieldGridNode  
4. electricPotentialLinesNode  
5. toolboxPanel（右上，control 下方）  
6. controlPanel（右上 top=30）  
7. resetAllButton（右下）  
8. chargesAndSensorsPanel（底中）  
9. draggableElementsLayer  
10. electricPotentialSensorNode  
11. measuringTapeNode  

MVT：`createSinglePointScaleInvertedYMapping(ZERO → layoutCenter, scale = layoutWidth/8)`。

ResetAll：**未指定 radius** → scenery-phet 默认 **20.8** → Flutter 用 `KratosResetAllButton(radius: 20.8)`。

---

## Interaction Map

- 从 bin 按下 → 创建（isActive=false）→ 移交 drag
- 松手不在 enclosure → isActive=true（开始贡献场）
- 松手在 enclosure → isActive=false → animate → dispose
- Snap：`snapToGrid && gridVisible` → 次网格 `0.1 m`
- 电荷移动 → clear 等势线 + updateAllSensors + chargeConfigurationChanged

---

## Reset Map

`model.reset()`：全部 visibility Property、charges、E-sensors、等势线、potential sensor、measuring tape。  
**不**重置 `availableModelBoundsProperty`。

---

## Asset Map

| Original | Flutter Path | Used By |
|---|---|---|
| mipmaps/electricPotentialPanelOutline | `assets/simulations/charges_and_fields/electricPotentialPanelOutline.png` | 电压表面板 / toolbox icon |
| mipmaps/pencil | `assets/simulations/charges_and_fields/pencil.png` | PencilButton |

其余：电荷/传感器/箭头/网格/卷尺 = Canvas 等价重建（源码 Path/Node，非位图）。

---

## Reusable KARTOSLAB Components

| 能力 | 复用 |
|---|---|
| Reset All | `KratosResetAllButton` |
| Clock（回 bin） | `SimulationClock` |
| 箭头（传感器） | `ArrowPainter` / 定制场箭头 painter |
| 卷尺参考 | GAO / Projectile measuring tape 模式 |
| 拖放 | `DragDropWorkspace` 或自管 Listener（本 sim bin 语义更贴近 PhET） |
| Visual QA | `tool/diff_visual_qa.py` + ORIGINAL/FLUTTER/DIFF |
| 单屏 Home 壳 | 可不用 Tab；独立 `ChargesAndFieldsHome` |

不复用 CLB `EFieldPainter`（平行板场线 ≠ 本 sim 点电荷箭头网格）。

---

## Risks / Unknowns

1. **Joist layoutBounds** 默认尺寸需与 published 截图对齐（通常 1024×618）— M6 几何门禁验证。  
2. WebGL 电势 → Flutter 用 Canvas 色场（源码已有 Canvas fallback）。  
3. 等势线 RK4/自适应步进数值敏感 — 需与源码同 seed 数值对比。  
4. 电荷回 bin Tween 曲线（Cubic.InOut）需视觉对齐。  
5. `isPlayAreaCharged` 特殊共位逻辑易漏。  
6. Touch 偏移 `(0, -2·radius)` 桌面可简化但需保留。
