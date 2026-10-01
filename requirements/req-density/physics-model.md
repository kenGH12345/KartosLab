# Physics Model · Density

> `[已确认]` common 源码 + `[文档]` `doc/model.md`。

## 1. 核心关系

\[
\rho = m / V
\]

实现不是「三个独立滑条」。见 `state-model.md`。质量在引擎内：

```
selfMass = roundToInterval(density * volume, 1e-7)
PhysicsEngine.bodySetMass(body, max(mass, 0.01))
```

`Mass.ts:339-340, 444`。立方体边长：

```
halfSide = volume^(1/3) / 2
```

`Cube.boundsFromVolume`。**视觉尺寸必须来自 volume 状态**，禁止只改 visualScale。

改体积时 cuboid 底面保持：竖直平移 `(newH-oldH)/2`（`Cuboid.ts:70-73`，density#24）。

---

## 2. 力（Density 屏也跑完整引擎）

`[文档] model.md`：

| 力 | 行为 |
|---|---|
| Gravity | 恒定向下，g = 9.8（query 9–10） |
| Buoyancy | 仅向上 = 排水重量 ρ_fluid × V_disp × g |
| Contact | 块-块、块-地。地不可动。**restitution = 0** |
| Friction | 仅水平 |
| Viscosity | 自定义，用于振荡稳定。`viscosityMultiplier` 默认 1；`viscositySubmergedRatio` 默认 0（只要沾水就全额粘滞）；`viscosityMassCutoff` 0.5 kg |
| 空气 | 忽略 |
| 旋转/力矩 | **不考虑** |

速度夹紧 5 m/s。隐形墙 + 天花板限制工作区。液面永远平。

指针抓取：`p2PointerBaseForce = 2500` + `p2PointerMassForce * mass`（默认质量项为 0）。`startDrag` 先上移 `START_DRAG_OFFSET = 0.0001` m 再加 pointer constraint（`Mass.ts:525-533`）。**不是**把 position 写成指针坐标。

p2 内部：模型尺寸 × `p2SizeScale=5`，质量 × `p2MassScale=0.1`，`p2FixedTimeStep=1/120`，最多 30 子步。Flutter **不移植这些缩放黑客的字面实现**，但接触应「几乎不弹、可轻微穿透、可重叠受接触力」。

---

## 3. 池与排水

- 池宽 0.9 m、深 0.4 m、几何体积 0.15 m³。
- 流体 ρ = 1000 kg/m³（水）。Density **不能换液体**。
- 块入水 → 水位上升（瞬时平坦）。
- 无池内秤（`usePoolScale: false`）。Mystery 有地面台秤（kg）。

浮力用于教学：ρ_block < ρ_water 上浮，> 下沉，= 悬浮。Intro 的 Styrofoam 150 / Wood 400 / Ice 919 应浮；PVC 1440 / Brick 2000 / Aluminum 2700 应沉。

---

## 4. Compare 约束（不是四块相加）

同一 BlockSet 下四块 **共享一个锁定变量**，其余由 cubesData 决定。没有 total mass/volume/density 读数。

---

## 5. Mystery 教学逻辑

不是「随机几个方块」。流程：

1. 选 Set 1/2/3 或 Random  
2. 出现带标签、未知材料（Custom + hidden 色）的立方体  
3. 拖到水中看沉浮；拖到秤上看质量（Mystery 默认不显示块上质量标签）  
4. 打开 Density Table 对照 kg/L  
5. 推断材料  

Table 数据来自 `Material.DENSITY_MYSTERY_SCREEN_MATERIALS` **按密度升序**，显示 `density/1000`，2 位小数。

Random 池：Wood, Gasoline, Apple, Ice, Human, Water, Glass, Diamond, Titanium, Steel, Copper, Lead, Gold。

---

## 6. Flutter Solver 建议（最小）

不要机械拆 5 个 Solver 文件。建议：

1. **`DensityRelation`**：ρ=m/V 与材料切换规则（纯函数，单测核心）  
2. **`CompareConstraint`**：按 BlockSet 把锁定量应用到 4 块  
3. **`MysterySets`**：静态数据 + Random 生成（可测 seed）  
4. **`BuoyancyWorld.step(dt)`**：重力+浮力+接触+粘滞+指针约束+屏障；**不**在 Painter 里算

`CustomPainter.paint` 只读 RenderData。
