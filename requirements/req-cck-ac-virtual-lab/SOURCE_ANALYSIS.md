# Phase 1 — Source Analysis · Circuit Construction Kit: AC - Virtual Lab

> 日期：2026-09-02  
> 蓝本：HTML5 `circuit-construction-kit-common` + `circuit-construction-kit-ac` Lab + VL 入口  
> 标记：`[已确认]` 有行号证据 · `[推测]` 有依据推断 · `[待确认]` 证据不足  
> 路径前缀：`phet sourses/circuit-construction-kit-common/` 简写 **common/**；`circuit-construction-kit-ac/` 简写 **ac/**；VL 入口简写 **vl/**

---

## 0. 结论

1. VL 是 **单屏 Lab**：`CircuitConstructionKitModel(true, true, {showNoncontactAmmeters:false})` + `LabScreenView`。[已确认]
2. 求解器是 **LTA companion + MNA QR**，不是 ngspice。spice 分支在 `LinearTransientAnalysis` **整段注释**。[已确认]
3. 无 Undo。Reset = `model.reset()` + `view.reset()`。[已确认]
4. 时钟：播放 `dt=1/60`；暂停仍以 `PAUSED_DT=1E-6` 求解；`dt>=0.5` 丢弃。[已确认]
5. 交互核心：顶点 **SNAP_RADIUS=30** 合并；工具箱回投 hit box 比例 **0.2**；导线电阻 `R=ρL/A`。[已确认]
6. 日用品电阻以 `ResistorType.ts` 为准（1E6 / 0 / 25 / 50），**不以**过时 `model.md` 为准。[已确认]

---

## 1. State（Single Source of Truth）

运行时 SSOT 是可变对象图，不是不可变 `copyWith` 快照。

### 1.1 `CircuitConstructionKitModel` — common/js/model/CircuitConstructionKitModel.ts

| 字段 | 默认 | 证据 |
|---|---|---|
| `circuit` | `new Circuit(..., includeAC, includeLab)` | ctor |
| `voltmeters` | 2 个 | L144–147 |
| `ammeters` | 2 个；VL 时 tandem OPT_OUT | L140–142 + VL `false` |
| `viewTypeProperty` | `LIFELIKE` | L113 |
| `showLabelsProperty` | `true` | L161 |
| `showValuesProperty` | `false` | L165 |
| `zoomLevelProperty` | index of `1` in `[0.5,1,1.6]` | L174 |
| `animatedZoomScaleProperty` | 跟 zoomScale | L195 |
| `isPlayingProperty` | `true`（仅 AC tandem） | L213 |
| `stopwatch` | 新建 | L298 |
| `addRealBulbsProperty` | query `addRealBulbs` flag | L118 |
| `isShowNoncontactAmmeters` | VL=`false` | LabScreen + options |

### 1.2 `Circuit` — common/js/model/Circuit.ts

| 字段 | 默认 | 证据 |
|---|---|---|
| `circuitElements` | ObservableArray | 元件集合 |
| `vertexGroup` | PhetioGroup | 顶点 |
| `charges` | ObservableArray | 电荷粒子 |
| `selectionProperty` | null | 选中元件/顶点 |
| `dirty` | bool | 需重解 |
| `timeProperty` | 累计秒 | `step` 里 `+= dt` |
| `wireResistivityProperty` | `WIRE_RESISTIVITY_RANGE.min` = **1E-10** | L250 + constants |
| `sourceResistanceProperty` | `DEFAULT_BATTERY_RESISTANCE` = **1E-4** | L256 + query |
| `showCurrentProperty` | query `showCurrent` 默认 **true** | L289 |
| `currentTypeProperty` | query 默认 **electrons** | L280 |
| `chargeAnimator` | ChargeAnimator | |

元件按 Group 创建：`wireGroup` / `batteryGroup` / `acVoltageGroup` / `resistorGroup` / `householdObjectGroup` / `capacitorGroup` / `inductorGroup` / `switchGroup` / `fuseGroup` / `lightBulbGroup` / `seriesAmmeterGroup` 等。[已确认 Circuit ctor 后半]

### 1.3 元件状态（每类关键量）

| 类型 | 关键 Property | 默认 |
|---|---|---|
| Vertex | `position` / `unsnappedPosition` / `voltage` | 放置点；电压求解后写入，符号取反 `vertex.voltage = -mnaNodeVoltage` [LTA L249] |
| Wire | `resistance` 由长度算 | `R=max(1E-14, ρ L / 5E-4)`，`L_m = viewDist * 0.0005` [Wire.ts:25,107–110] |
| Battery | `voltage=9`，范围 0–120，1 位小数 | Battery.ts:27–29 |
| ACVoltage | `V=-Vmax sin(2πft+φ)` | 见 §3 |
| Resistor | 10 Ω，范围 0–120 | ResistorType.RESISTOR |
| LightBulb | 默认电阻 10 Ω；亮度公式见 §3 | |
| Capacitor | C=0.1 F，范围 0.05–0.2；`mnaVoltageDrop`/`mnaCurrent` | query |
| Inductor | L=5 H，范围 0.1–10 | query |
| Switch | 默认 **断开**；闭=0Ω 开=`MAX_RESISTANCE=1e9` | Switch.ts:53,60–61 |
| Fuse | rating=4 A，范围 0.5–20；未熔断 `R=0.06/I_rating` | Fuse.ts:146–148,168 |
| 日用品 | Coin/PaperClip=0；Pencil=25；ThinPencil=50；Eraser/Dollar=**1E6** | ResistorType.ts |
| SeriesAmmeter | 当电阻 0 处理（MINIMUM_RESISTANCE 兜底） | LTA L106–109 |
| Voltmeter | 体+红黑探头位置；`isActive` | Meter.ts |
| Stopwatch | 可见性由 checkbox | |

**Render 禁止重算**：电流/电压/亮度/电荷位置必须来自 Model。Painter 只读 DTO。

---

## 2. Model 拓扑

### 2.1 图结构

- 元件 = 两端点 `startVertex` / `endVertex`（FixedCircuitElement 定长；Wire 可变长）。
- 连接 = **顶点合并** `Circuit.connect(target, old)`：把 old 上的元件改挂到 target，dispose old。[Circuit.ts:999+]
- 断开 = 在顶点处拆出新 Vertex。[Circuit.ts:846+]
- `isTraversableProperty`：开路开关 / 熔断保险丝 **不参与** MNA 导通，但仍可 DFS 传播电压。[LTA L81–84, L268]

### 2.2 `isInLoop`

不在含电源回路中的元件：电流置 0，不进 MNA。开路支路电压用 DFS 从已解顶点传播。[LTA L64–66, L231–320]

这是已知 PhET 限制（issue #1133 桥接拓扑）；我们 **原样移植**，不自行“修物理”。[已确认]

### 2.3 库存上限（同时拖出数量）

| 元件 | count | 证据 |
|---|---|---|
| Wire | 50 | `NUMBER_OF_WIRES` |
| Battery / AC / Bulb / Resistor / Capacitor / Fuse / Switch | **10** | ToolFactory 默认 |
| Inductor | 1（`?moreInductors`→10） | ToolFactory L410 |
| 每种日用品 | **1** | count:1 |
| Extreme resistor | 4 | Lab 的 `addRealBulbs` 相关；VL `hasACandDCVoltageSources=true` → Advanced 里 **不显示** real bulbs checkbox [CCKCScreenView L291] |

Extreme 电池/电阻/灯泡 **不在** LabScreenView 工具箱列表，一期不实现。[已确认 LabScreenView.ts 工具数组]

---

## 3. Solver / Repository

### 3.1 调用链

```
Model.step(dt)
  if dt >= 0.5: return                    // CCKCConstants.MAX_DT
  zoomAnimation.step(dt)
  if playing || circuit.dirty:
    stepOnce(playing ? 1/60 : 1e-6)
      circuit.step(dt)
        time += dt
        ACVoltage.step / Fuse.step / Wire.step
        if dirty || 有 DynamicCircuitElement:
          LinearTransientAnalysis.solveModifiedNodalAnalysis(circuit, dt)
        inductor 孤立则 clear()
        determineSenses()
        updateSeriesAmmeterReadouts()
        chargeAnimator.step(dt)
  layoutChargesInDirtyCircuitElements()
```

证据：`CircuitConstructionKitModel.ts` step / stepOnce；`Circuit.ts:1074–1118`。

单步按钮：`stepSingleStep` = **6 次** `stepOnce(1/60)` = 0.1 s。[Model L309–312]

### 3.2 AC 源

```
voltage = -maximumVoltage * sin(2 * π * f * t + phaseDeg * π/180)
circuit.dirty = true
```

`ACVoltage.ts:120–123`。[已确认]  
默认：Vmax=9，f=0.5 Hz，phase=0。范围：Vmax 0–120，f 0.1–2，phase ±180°。

### 3.3 Companion 模型（梯形积分）

`LTACircuit.solvePropagate` [已确认 L75–143]：

**电容（trapezoidal，非 backward Euler）**：

```
Req = dt / (2 C)
Veq = Req * I - V          // companionVoltage = companionResistance * current - voltage
串联：battery(Veq) + resistor(Req) + resistor(capacitorResistance=1E-4)
```

**电感**：

```
Req = 2 L / dt
Veq = V + -Req * I
串联：battery + resistor(Req) + resistor(inductorResistance=1E-4)
```

**电阻性电池**：理想电池 + 内阻串联，中间 synthetic node。

### 3.4 自适应子步

`TimestepSubdivisions`：比较一步 `h` 与两步 `h/2` 的欧氏距离；阈值 `ERROR_THRESHOLD=1E-5`；`MIN_DT=1E-3`；暂停时直接 `PAUSED_DT` 不检误差。[TimestepSubdivisions.ts]

### 3.5 MNA 线性系统

`MNACircuit.solve()`：组方程后 **`QRDecomposition(A).solve(z)`**。[MNACircuit.ts:281,307]  
未知量 = 节点电压 + 电池/零阻支路电流。  
0 电阻用 `MINIMUM_RESISTANCE=1.1E-10` 代替（灯泡真实电阻除外）。[LTA L106–109]

### 3.6 写回约定

- 电阻/电池电流：时间平均 `getTimeAverageCurrent*`
- C/L：`currentProperty`=平均；`mnaCurrent`/`mnaVoltageDrop`=瞬时并 `clampMagnitude(..., 1E20)`
- 节点电压：`vertex.voltage = -mnaVoltage`（符号翻转）[LTA L249]
- 非回路元件电流 = 0

### 3.7 保险丝

```
exceeded = |I| > rating + 1E-6
if exceeded: timeExceeded += dt else timeExceeded = 0
if timeExceeded > 0: trip          // 即超过即熔，阈值时间 0
R_tripped = 1e9
R_ok = 0.06 / rating               // 20A → 3 mΩ
isTraversable = !isTripped
```

[Fuse.ts:126–158] 熔断播放 `breakFuse`；修复音被注释。

### 3.8 灯泡亮度

```
P = |I² R|
b = clamp( ln(1 + 0.35 P) / ln(1 + 0.35 * 2000), 0, 1 )
< 1e-6 → 显示为 0
```

[LightBulb.ts:254–260] + CCKCLightBulbNode L77–78。

真实灯泡（VL Advanced 默认不提供入口）用 10 次迭代 `R = 10 + 3 V / log2(V+2)`。[LTA L163–200] 一期可不实现 real bulbs。[有意差异若 UI 无入口]

### 3.9 电感孤立清零

邻居 `|I|>1E-4` 皆无 → `inductor.clear()` 清 `mnaVoltageDrop/mnaCurrent`。[Circuit.ts:1091–1104]

### 3.10 既有 Flutter `CircuitSolver`

`lib/circuit/models/circuit_solver.dart` 是 **静态 DC MNA**，无 companion、无 AC、无 C/L。禁止复用其方程组装。本 sim 独立移植 LTA/MNA。

---

## 4. Render

### 4.1 坐标系

- Joist `ScreenView` 布局坐标；`CircuitNode` 是电路世界。
- Y **向下**（Scenery 惯例）。[已确认 scenery]
- 导线模型长度：`meters = viewPixels * 0.0005`。[Wire.ts:25]
- Zoom：缩放 `CircuitNode`，档位 0.5 / 1 / 1.6，动画 0.35 s cubic-in-out。[ZoomAnimation.ts]
- 背景 `#99c1ff`；面板 `#f1f1f2`；高亮 `#000070`。[CCKCColors.ts]

### 4.2 布局锚点（相对 `visibleBounds`）

`CCKCScreenView.ts:415–458` [已确认]：

| 控件 | 锚 |
|---|---|
| 元件 Carousel | `left = bounds.left+10`，`top = bounds.top+5` |
| Reset All | `right-10`，`bottom-5` |
| TimeControl | `bottom-5`；优先与右侧面板左对齐 |
| Zoom | 与 toolbox **右对齐**，`bottom-5` |
| 电荷限速读数 | toolbox 右与面板左之间水平居中，`bottom-100` |
| 右侧 VBox | 视图类型 / DisplayOptions / Advanced / SensorToolbox |

Lab：`toolboxOrientation:'vertical'`，carousel scale **0.85**，8/页。

### 4.3 分元件视图（禁止 God Painter）

common/js/view：`WireNode` `BatteryNode` `ACVoltageNode` `ResistorNode` `CCKCLightBulbNode` `CapacitorCircuitElementNode` `InductorNode` `SwitchNode` `FuseNode` `VertexNode` `SolderNode` `ChargeNode` `VoltmeterNode` `SeriesAmmeterNode` `ValueNode`。

Lifelike 用 PNG；Schematic 用折线 `SCHEMATIC_LINE_WIDTH=4`。

### 4.4 图表

Lab `showCharts:true`：各 2 个 VoltageChart + CurrentChart。  
横轴 `modelXRange = [0, 4.25]` 秒。[CCKCChartNode.ts:150]  
`NUMBER_OF_TIME_DIVISIONS=4`。电压图默认 Y `[-10,10]`。[VoltageChartNode.ts:40]  
采样：探头全局→电路局部 → `getVoltageBetweenConnections`。[VoltageChartNode.ts:52–58]

### 4.5 仪表精度

`METER_PRECISION=2`。安培计默认 **magnitude**（绝对值）。超量程 `> 10^10`。[CCKCUtils.ts:31–56]

---

## 5. Interaction

### 5.1 从工具箱拖出

`CircuitElementToolNode`：拖出创建元件；放置时两顶点距离必须 **>50**（> SNAP_RADIUS 30）防误吸。[CircuitElementToolNode.ts:239]  
拖回工具箱：`getDropItemHitBoxForBounds` 腐蚀到宽高的 20%。[CCKCUtils.ts:101–104]

### 5.2 顶点拖 / 合并

`Circuit.getDropTarget` 规则 [Circuit.ts:1625–1770]：

1. 不可与相邻顶点连  
2. 不可连自己  
2.5 不可连正在拖的对象  
3. `unsnappedPos.distance(candidate.pos) < 30`  
4–5. 不可多顶点同时吸同一点  
6. 不可连自己的定长子图（无线）  
7. 导线顶点邻居若已在 propose 则不可  
8. 导线不可对同一物体双连造成微型短路  
9. Black box 规则（VL 无 black box）

松手 `connect`。太近但未合并则 **bump** `BUMP_AWAY_RADIUS=20`。[L64–66]

`TAP_THRESHOLD=15`：小于此位移算点击。[constants]

### 5.3 点击 / 编辑

选中元件 → 底部 `CircuitElementEditContainerNode`（电压/电阻/C/L/频率/相位/保险丝额定/反转电池/Clear C·L/删除）。  
开关：点击拨杆区域 `SWITCH_START=1/3`–`SWITCH_END=2/3` 且断开时可拨。[Switch.ts:86]  
默认开关 **开路**。

### 5.4 传感器

- 电压表：从 SensorToolbox 拖出，两探头点电路 → 开路电压。理想无穷阻。  
- 串联安培计：Lab `showSeriesAmmeters:true`，作为电路元件接入。理想 0 阻。两端都接到其他元件才显示读数。[Circuit.ts:1351]  
- **非接触安培计：VL 关闭**。

### 5.5 键盘

`KEYBOARD_DRAG_SPEED=400`，Shift=50。一期指针优先；键盘 [待确认] 可标有意差异。

### 5.6 多点触控

源码拖听是 scenery `DragListener`（单指针为主）。[待确认] 未发现专用 multi-touch 手势；双指缩放不是 CCK 交互（zoom 用按钮）。

---

## 6. Animation

| 对象 | from→to | duration | easing | 并发/中断 | reset |
|---|---|---|---|---|---|
| Zoom | 当前档→目标档 `ZOOM_SCALES` | **0.35 s** | cubic-in-out | 新 zoom 替换 `zoomAnimation`；reset 取消 | `zoomAnimation=null` |
| 电荷 | 沿 charge path 按 I 移动 | 连续；`SPEED_SCALE=25`；单帧位移 cap `0.43*28`；过速则 `timeScale` 降到 (0,1] | 无缓动，欧拉步进 | 与求解同帧，求解后移动 | ChargeAnimator.reset 清 timescale |
| 保险丝火花 | scale 0.75→2，opacity 1→0（后 20%） | **0.3 s** | quadratic-in-out | 独立 Animation，ended dispose | 无持久状态 |
| 电荷均衡 | `NUMBER_OF_EQUALIZE_STEPS=2` 每帧 | — | — | — | — |

电荷：`|I|<1E-10` 不移动。[ChargeAnimator.ts:26]  
`MAX_DT` 电荷积分 1/30。[L39]

**无** 元件放置弹跳、无 undo 动画。

---

## 7. Clock

| 项 | 值 |
|---|---|
| 帧意图 | 60 fps，`stepOnce(1/60)` **固定**，不用墙钟 dt（大 dt 丢弃） |
| 播放 | `isPlaying=true` 用 1/60 |
| 暂停 | 仍 step `1E-6` 以便改电路立刻更新 C/L/电子 |
| 隐藏页 | `dt>=0.5` 整帧忽略 |
| 秒表 | `stopwatch.step(dt)` 仅在 `stepOnce` 内，与电路时间同源 |
| AC 时间 | `circuit.timeProperty` 暂停几乎不走（1e-6），故 AC 波形在暂停时冻结 |

---

## 8. Reset / Undo

**Reset All** [CCKCScreenView L302–304]：

```
model.reset()  // 见 Model.ts:350–369
this.reset()   // 视图：图表/秒表位置等
```

`model.reset`：value depiction、labels、values、mode、**circuit.reset()**、电压表/安培计、viewType、zoom、animatedZoom、stopwatch、isPlaying、addRealBulbs；`zoomAnimation=null`。

`circuit.reset`：`clear()` 删全部元件+顶点，reset 电流显示/类型/电阻率/内阻/chargeAnimator/selection。[Circuit.ts:1906–1914]

**Undo：不存在。** 不得发明 Ctrl+Z。

---

## 9. Boundary / Invalid

| 情况 | 行为 |
|---|---|
| 开路 | 非回路电流 0；DFS 填电压 |
| 短路 | 导线最小电阻 1E-14；电池最小内阻 1E-4 |
| 熔断 | 保险丝 1e9 Ω，不可遍历 |
| 数值爆炸 | C/L `clampMagnitude` 1E20；assert `<1E100` |
| 探头出界 | `DRAG_BOUNDS_EROSION=20` |
| 电荷过速 | timeScale 节流，底部读出 |
| 电感无电流邻居 | clear 动态变量 |
| 0 电阻 | 用 MINIMUM_RESISTANCE |
| 真实灯泡 V=0 | log(V+2) 避免 log0 |
| 不可解矩阵 | QR；[待确认] 失败时 scenery 断言——Flutter 应对齐为保持上一帧解并记录 |

火焰：`isFlammable` 电池/AC 过流时显示 fire PNG。[待确认 阈值：Phase 4 读 CircuitElement 过流判定]

---

## 10. Lifecycle

- 进入：新 Model + View，空电路，播放中，zoom=1，lifelike。  
- 离开：joist 销毁 screen；本工程 Tab 不 KeepAlive → dispose Controller + Clock。  
- 再进：全新状态 = reset 后的空 Lab。  
- `phetioStateSetEmitter`：本工程不做 PhET-iO。

---

## 11. Responsive

全部贴 `visibleBounds`，无写死 1024 画布。Carousel / 面板 AlignGroup 统一宽度。  
矮屏：TimeControl 与 Reset 可能重叠——原版用 `isFinite` 防护 [ac issue #31]。Flutter 用 NineGrid footer 放 TimeControl，Reset 仍可 Positioned 在 center 右下。

---

## 12. Assets（只复制存在文件）

**common/images**：battery, batteryHigh, resistor, resistorHigh, fuse, lightBulbFront/Back/Real/High, wireIcon, coin, paperClip, pencil, thinPencil, eraser, dollar, hand, fire, ammeterBody。  
**common/mipmaps**：voltmeterBody, probeRed, probeBlack, lightBulbMiddle*。  
**common/sounds**：cut, breakFuse, repairFuse（repair 播放被注释，仍拷贝文件）。  
**ac/images**：screenIconLab。  
VL `images/license.json` 为空，无自有图。

禁止 Material Icon 冒充这些 PNG。

---

## 13. 有意差异（开工锁定）

| 原版 | 本工程 |
|---|---|
| joist 底栏 + 单 Screen | AppBar + NineGrid |
| 多语言 / PDOM / PhET-iO | 不做 |
| Projector 色表 | 只 default |
| `?solver=spice` | 不实现（源码已注释） |
| 键盘拖 | 指针优先 |
| UI 音量 0 | 可保留元件音（cut/break） |
| real/extreme 元件 | Lab 工具箱无 → 不做 |

---

## 14. 证据缺口

| ID | 项 | 标记 |
|---|---|---|
| S-1 | 过流火焰阈值 | [待确认] 读 flammable 判定 |
| S-2 | ACVoltage 模型长度 BATTERY_LENGTH vs AC_VOLTAGE_LENGTH | [待确认] 读 ACVoltageNode |
| S-3 | 图表 Y 自动缩放规则 | [待确认] 读 CCKCChartNode zoomRanges |
| S-4 | 焊点 SolderNode 几何 | Phase 5 对照 Node |
| S-5 | 原版运行截图 | Phase 2 |

无阻塞。进入 Phase 2。
