# Phase 1 — Source Analysis · Normal Modes

> 日期：2026-09-03  
> 本地源码：`phet sourses/normal-modes-main/normal-modes-main`（第一事实来源）  
> 版本：`package.json` `1.1.0-dev.0`  
> 标记：`[已确认]` / `[推测]` / `[待确认]`

---

## 0. 结论

核心物理与时钟逻辑均可从源码闭合。**不存在**必须暂停的「无法确认的核心数学模型」。

动画本质：

```
x_i(t) = Σ_r A_r · sin(i r π / (N+1)) · cos(ω_r t − φ_r)
```

拖拽时改走 Verlet。Flutter **禁止**用 AnimationController 近似该公式。

---

## 1. 证据矩阵

### 1.1 Screen / 初始化 / 导航

| 功能 | 文件 | class | 结论 |
|---|---|---|---|
| Sim 入口 | `js/normal-modes-main.js` | `simLauncher.launch` | Screen 数组：`OneDimensionScreen`, `TwoDimensionsScreen` [已确认] |
| 1D Screen | `one-dimension/OneDimensionScreen.js` | `OneDimensionScreen` | `createModel: () => new OneDimensionModel`；背景 `SCREEN_BACKGROUND` white；icon `createOneDimensionScreenIcon` |
| 2D Screen | `two-dimensions/TwoDimensionsScreen.js` | `TwoDimensionsScreen` | 同上，独立 Model |
| Screen 切换 | joist `Sim` / `Screen` | （依赖库，本地无 joist） | 各 Screen 惰性创建 Model 后保持；仅活动屏 `step` [推测：joist 标准行为，源码无覆盖] |
| 共享状态 | — | — | 无。两 Model 完全独立 [已确认] |

### 1.2 Constants / Colors / Query

| 项 | 位置 | 值 |
|---|---|---|
| SCREEN_VIEW_X/Y_MARGIN | `NormalModesConstants.js` | 10 |
| FIXED_DT | 同 | 1/60 |
| NORMAL_SPEED / SLOW_SPEED | 同 | 1 / 0.2 |
| NUMBER_OF_MASSES_RANGE | 同 | 1..10（2D 为每行质量数，总数 N²）[已确认 TODO comment issue 89] |
| MASSES_MASS_VALUE | 同 | 0.1 |
| SPRING_CONSTANT_VALUE | 同 | `0.1 * 4 * Math.PI ** 2` |
| MIN/MAX/INITIAL_AMPLITUDE | 同 | 0 / 0.1（1D 滑条） / 0 |
| MIN/MAX/INITIAL_PHASE | 同 | −π / π / 0 |
| LEFT_WALL_X_POS | 同 | −1 |
| TOP_WALL_Y_POS | 同 | 1 |
| DISTANCE_BETWEEN_X/Y_WALLS | 同 | 2 |
| 字体 | 同 | 18 / 16 / 14 / 13 / 12 |
| dragBoundsHeight1D | `NormalModesQueryParameters.js` | 100（1D 拖拽高度，view 坐标） |
| MASS_FILL | `NormalModesColors.js` | `#007bff` |
| SPRING_STROKE | 同 | `PhetColorScheme.RED_COLORBLIND` = `#FF5500` [已确认 BAN 审计] |
| WALL | 同 | `#333` |
| PANEL | 同 | fill `rgb(240,240,240)` stroke `rgb(190,190,190)` |
| 2D selector | 同 | H `rgb(0,255,255)` V `rgb(0,0,255)`；背景黑 brighter 0.6 |
| Play 按钮 | 同 | `hsl(210, 70%, 75%)` 等（waves-on-a-string 风格，**不是**绿 Play） |

layoutBounds：两 ScreenView **未**覆盖 `layoutBounds`。joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` 自 2014 为 **1024×618**（joist#542）。1D `VIEW_SPRING_WIDTH=745` 在 1024 宽下右侧才放得下控制面板；若 768 会与弹簧重叠。**[已确认 1024×618]**

### 1.3 Model / State（基类）

`js/common/model/NormalModesModel.js`

| property | 默认 | reset |
|---|---|---|
| dt | 0 | 是 |
| timeProperty | 0 | **reset() 基类不清 time**；`initialPositions` 才 `timeProperty.reset()` |
| playingProperty | true | 是 |
| timeSpeedProperty | TimeSpeed.NORMAL | 是 |
| timeScaleProperty | derived 1 或 0.2 | — |
| springsVisibleProperty | true | 是 |
| numberOfMassesProperty | 3 | 是 |
| amplitudeDirectionProperty | VERTICAL | 是 |
| arrowsVisibleProperty | true | 是 |

**注意**：`reset()` 不清 `timeProperty`；`zeroPositions` 也不清 time。`initialPositions` 暂停并清 time。[已确认]

### 1.4 Mass / Spring

`Mass.js`：equilibriumPosition, visible, displacement, velocity, acceleration, previousAcceleration。`zeroPosition()` 只清运动学，不清平衡位置。

`Spring.js`：连接 left/right Mass。`visibleProperty = leftMass.visible`（**不**看 right）。视图再与 `springsVisibleProperty` AND。

弹簧绘制：`SpringNode.js` 是 **单位线段 Path**，按两端距离 scale、按角度 rotate，`lineWidth: 5`。**不是**螺旋弹簧。

### 1.5 一维数学模型 [已确认 `OneDimensionModel.js`]

**结构**

- `MAX_MASSES = 12`（10 可见 + 2 墙）
- `masses[0]` 左墙，`masses[MAX-1]` 右墙（View 用 WallNode）
- 可见质量 `i = 1..N`；`visible = (i <= N)` 故 index 0 也 visible（墙）
- 平衡位置：`x = -1 + i * (2/(N+1))`，y=0

**频率**（`modeFrequencyProperties[i]` DerivedProperty）

```
if i >= N: 0
else: ω_i = 2 * sqrt(k/m) * sin( π/2 * (i+1) / (N+1) )
```

k=`SPRING_CONSTANT_VALUE`，m=`MASSES_MASS_VALUE`。  
`sqrt(k/m) = 2π`（因为 k/m = 4π²）。  
Spectrum 标签：`ω / sqrt(k/m)` 保留 2 位 + `ω₀`（`frequencyRatioOmegaPattern`）。

**精确位置** `setExactPositions`（未拖拽）

对每个质量 i=1..N、每个模态 r=1..N，j=r-1：

```
sinShape = sin( i * r * π / (N+1) )
cosT     = cos( ω_j * t − φ_j )
sinT     = sin( ω_j * t − φ_j )
disp    += A_j * sinShape * cosT
vel     += −ω_j * A_j * sinShape * sinT
acc     += −ω_j² * (A_j * sinShape * cosT)
```

然后按 `amplitudeDirection` 写入 `Vector2(disp,0)` 或 `Vector2(0,disp)`。

**模态分解** `computeModeAmplitudesAndPhases`（拖拽结束）

先 `timeProperty.reset()`。对每个模态 i=1..N：

```
Acos += (2/(N+1)) * x_j * sin(i j π /(N+1))
Asin += (2/(ω_i (N+1))) * v_j * sin(...)
A = hypot(Acos, Asin)
φ = atan2(Asin, Acos)
```

只用当前轴向分量（H→x，V→y）。

**Verlet**（拖拽中，被拖质量跳过）

```
x += v*dt + a*dt²/2
a = (k/m) * (xLeft + xRight − 2x)   // 向量
v += (a + aLast)*dt/2
```

被拖质量 a=0, v=0。

**边界**：两端墙质量位移保持 0（从不在 1..N 循环里更新）。无「自由端」模式。[已确认 固定端]

**改 N**：`changedNumberOfMasses` 重放平衡位置、`zeroPosition`、`resetNormalModes`（振幅相位回 0）。View 同时 `interruptSubtreeInput`。

### 1.6 二维数学模型 [已确认 `TwoDimensionsModel.js`]

**频率**

```
ω_i = 2 sqrt(k/m) sin(π/2 * (i+1)/(N+1))
ω_j = 2 sqrt(k/m) sin(π/2 * (j+1)/(N+1))
ω_{ij} = sqrt(ω_i² + ω_j²)
```

i 或 j ≥ N 时为 0。

**maxAmplitude**（Flash 同款）

```
baseMaxAmplitude = 0.3
springLength = DISTANCE_BETWEEN_X_WALLS / (i+2)  // i = N-1 ⇒ 2/(N+1)
maxA = 0.3 * springLength
N=1 → 0.3（源码注释：1 mass 时上限即 baseMaxAmplitude）
N=3 → 0.15
```

点击格子：若当前振幅 **near** max（EPS=1e-4）则置 0，否则置 max。只改当前轴向振幅，**不改相位**。[已确认 `AmplitudeSelectorRectangle.js`]

**sineProduct[i][j][r][s] = sin(j r π/(N+1)) * sin(i s π/(N+1))**  
（注意 r 配 j、s 配 i）

**精确位置**（注意 **Y 用减号**）

```
disp.x += sine * A_x * cos(ω t − φx)
disp.y -= sine * A_y * cos(ω t − φy)
vel/acc 同样 y 为减
```

这是 **model 坐标**里的减号，再叠加 MVT inverted-Y。[已确认 必须原样迁移，不得「修正」]

**Verlet 加速度**

```
a = (k/m) * (sLeft + sRight + sAbove + sUnder − 4s)
```

**分解** 系数 `4/((N+1)²) * sineProduct`；Y 分支对位移/速度同样取负再 atan2。

**2D AmplitudeDirection** 只切换振幅网格编辑的是 X 还是 Y 矩阵，**不**把运动锁成单轴。质量可同时有 x、y 位移。[已确认 与 1D 语义不同]

**2D 相位**：UI 无滑条；仅拖拽分解会写 `modeX/YPhaseProperties`。点击格子不改相位。

**createDefaultMasses 的 y 方向**与 `changedNumberOfMasses` 不一致（constructor 用 y+=，changed 用 y-=）。因 `numberOfMassesProperty.link` 立即重定位，运行时以 `changedNumberOfMasses` 为准。[已确认]

### 1.7 Clock / Animation 表

| object | from | to | duration/speed | easing | 并发 / 中断 / reset / dispose |
|---|---|---|---|---|---|
| 质量位置 | 解析 superposition 或 Verlet | 每 FIXED_DT | 无 easing | 拖拽打断精确解；改 N interrupt drag；Reset→zeroPositions | 对象生命周期=sim，不 dispose |
| ModeGraph 曲线 | A,φ,ω,t | 每 time/A/φ 变化 `update()` | 同公式，amp 静态图用 0.075 且 t=0 | Accordion 折叠不销毁 CanvasNode [已确认 implementation-notes #51 只 dispose VStrut] |
| 弹簧线段 | 两端 mass 位置 | 立即 Multilink | — | visible= springVisible && springsVisible |

暂停：playing=false 时若未拖拽，**每帧仍 setExactPositions**。  
Step：`singleStep(FIXED_DT)`，内部再乘 timeScale。

`initialPositions`：pause + time=0 + setExactPositions（回到 t=0 的模态叠加，不是「上次按下 play 时的位置」——源码如此；文档说 “when the simulation started moving” 与实现不完全同义）。[已确认 以源码为准]  
实现 = 当前 A,φ 在 t=0 的形状。若用户拖过，A,φ 已是分解结果，t=0 即该瞬时构型。

### 1.8 Interaction 矩阵

| 交互 | 源码 | 行为 |
|---|---|---|
| 拖 1D 质量 | `MassNode1D.js` | 仅当前轴；拖时 arrowsVisible=false；start 设 draggingMassIndex；end 若未 interrupt 则 index=-1，**总是** computeModeAmplitudesAndPhases |
| 拖 2D 质量 | `MassNode2D.js` | 两轴自由，限制在 borderWalls；箭头旋转 π/4；arrows 四个全显 |
| 1D 拖拽范围 | `OneDimensionScreenView.js` | 墙之间，高度 `dragBoundsHeight1D=100` view px |
| 振幅滑条 1D | `NormalModeSpectrumAccordionBox.js` | VSlider，范围 **0..0.1**（property 本身允许 Infinity，拖拽分解可超过 0.1） |
| 相位滑条 1D | 同 | 仅 `phasesVisible` 时加入 children；默认 false |
| Show Phases | `NormalModesControlPanel.js` | 仅当 `model.phasesVisibleProperty !== undefined`（1D） |
| 轴向 radio | `AmplitudeDirectionRadioButtonGroup.js` | 竖排；H 箭头 / V 箭头；未选 opacity 0.35 |
| Number of Masses | `NumberOfMassesControl.js` | NumberControl，无箭头按钮，slider 150×3，thumb 11×19；2D formatter `value²` |
| Show Springs | Checkbox | `springsVisibleProperty` |
| Initial Positions | TextPushButton | `initialPositions()` |
| Zero Positions | TextPushButton | `zeroPositions()`（**不暂停**） |
| Play/Pause/Step + Speed | TimeControlNode | step listener → `singleStep(FIXED_DT)` |
| Reset All | ResetAllButton | `model.reset()` + 各 accordion `expandedProperty.reset()` |
| 2D 格子点击 | FireListener | toggle 0 ↔ maxAmplitude（当前轴） |
| 改 N | model+view | 清振幅；interrupt 正在进行的拖拽 |
| Spectrum collapse | AccordionBox | `showTitleWhenExpanded: false`；resize:true；折叠**不** remove 频率 Text（content visible=false）[已确认 不得 Offstage+dispose] |
| Normal Modes accordion | `NormalModesAccordionBox.js` | 每个 mode 一条动画曲线 133×11 + 序号；children 切到前 N 个，保留 HStrut 防 resize |
| Hover 箭头 | MassNode | arrowsVisible 且 isOver 时显示；第一次拖后 arrowsVisible 永久 false 直到 Reset All |

无 combobox。无自由端切换。

### 1.9 Spectrum / Graph

**StaticModeGraphCanvasNode**（Spectrum 顶上小图 40×25）

- 固定 A=0.075, φ=0, t=0
- `y = −(2H/3) * (A * sin(x*(n+1)*π) * cos(ωt−φ)) / MAX_AMPLITUDE`
- 仅在 `numberOfMassesProperty` 变化时 `update()`
- 参考线 y=0，线宽 2，蓝曲线

**ModeGraphCanvasNode**（右侧 Normal Modes 133×11）

- 用真实 A,φ,ω,t
- 左右短墙 wallHeight=8
- Multilink time + amplitude + phase → update

**频率标签**

- `Utils.toFixed(ω/sqrt(k/m), 2) + ω₀`
- 只在 N 改变时重写 string，**不**随时间变
- collapse 后节点仍在场景图 [原 PhET 行为]；若 Flutter 折叠时 remove 子 widget = **[KARTOSLAB migration bug]**

### 1.10 View 布局锚点（逻辑坐标 layoutBounds 1024×618）

**1D** `OneDimensionScreenView.js`

| 锚 | 公式 |
|---|---|
| VIEW_SPRING_WIDTH | 745 |
| viewOrigin | `(745/2+10+4, (maxY-300)/2)` = (386.5, 159) |
| MVT | `createSinglePointScaleInvertedYMapping(ZERO, viewOrigin, 372.5)` |
| ResetAll | right = maxX−10, bottom = maxY−10 |
| controlPanel | right = maxX−10−resetW−10, top = 10 |
| spectrum | bottom = maxY−10, centerX = viewOrigin.x |
| normalModes accordion | top = controlPanel.bottom+8, right = 同 controlPanel |
| 质量节点尺寸 | 20×20，线宽 4 |
| 墙 | 6×80，cornerRadius 2，线宽 2 |

**2D** `TwoDimensionsScreenView.js`

| 锚 | 公式 |
|---|---|
| viewOrigin | `((maxX-420)/2, maxY/2)` = (302, 309) |
| scale | `(maxX − 20 − 420)/2` = 292 |
| borderWalls | model (−1,1)→(1,−1) 的 Rectangle，lineWidth 2 |
| controlPanel | 同 1D 右上 |
| amplitudes accordion | right = controlPanel.right, bottom = borderWalls.bottom |
| 质量 | Circle r=10，箭头绕原点转 π/4 |
| 振幅格 | PANEL_REAL_SIZE=270，RECT_GRID=5，PADDING_GRID=1 |

### 1.11 Reset 行为差集

| 动作 | playing | time | 位移 | A,φ | arrows | accordion 展开 | N, springs, direction |
|---|---|---|---|---|---|---|---|
| Reset All | 默认 true | **不清**（基类 reset 无 time）然后 zeroPositions | 0 | 0 | true | reset | 全默认 |
| Zero Positions | 不变 | 不清 | 0 | 0 | 不清 | 不清 | 不清 |
| Initial Positions | **false** | 0 | setExact(t=0) | 不清 | 不清 | 不清 | 不清 |

`reset()` 调用 `zeroPositions()` → `resetNormalModes()`。time 在基类 reset 后仍可能非 0，但位移被清零；下一帧 setExact 用旧 t 乘 A=0 仍为 0。[已确认 表现静止]

### 1.12 Assets / strings

`normal-modes-strings_en.json` 全量英文。无本地化资源包在本迁移范围内；UI 用英文对齐原版（KARTOSLAB 其他 PhET 迁移同样保留原文字符串者：Kepler title）。控件英文：[已确认 源码字符串]

Screen 图标：`NormalModesIconFactory.js` 自绘线+方/圆，非 Material Icon。

### 1.13 原版已知问题（记录，不擅自修）

| 现象 | 分类 |
|---|---|
| `recalculateVelocityAndAcceleration` 方向 assert 在 CT 失败被注释 | [原 PhET bug] issue 56 |
| 1D `draggingMassIndex` 默认 0，end 设 −1；interrupt 时不清除 index | [原 PhET 行为] issue 78 workaround |
| `NormalModesConstants` 注释：numberOfMasses 在 2D 实为每行个数 | [原 PhET] issue 89 |
| layout magic numbers issue 38 | [原 PhET] |
| Spectrum collapse / frequency label：内容保持在 DAG | [原 PhET 行为]；implementation-notes 仅 dispose VStrut (#51) |
| README: simulation under development | 以本地 1.1.0-dev.0 为准 |

---

## 2. 待确认（不影响核心模型，不暂停）

| 项 | 原因 |
|---|---|
| TimeControlNode 内部 Play 是否 paused 才允许 Step | 本地无 scenery-phet；[推测] 标准 TimeControlNode 暂停才 Step |
| AccordionBox 默认 expanded=true | sun 默认；[推测] Reset 调用 expandedProperty.reset() 暗示默认 true |
| 官网最新 commit vs 本地树 | 用户要求不以 GitHub 更新替换本地 |
| 原版运行截图 | 见 Phase 2 |

**Phase 1 状态：核心模型 [源码一致]。自动进入 Phase 2。**
