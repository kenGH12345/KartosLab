# COLORS / Gradients Source Audit（P4-1）

> 只调查，不改实现。2026-08-31  
> 原版：`d:\OneDrive\Desktop\phet sourses\build-a-nucleus-main\`  
> Flutter：`lib/chemistry/build_a_nucleus/`  
> 截图取样：`p4_1_screenshot_samples.json`（5×5 中位数；`var` 高 = 抗锯齿/渐变边，不当基色）

**不要用截图像素当源码色。** 截图 ≠ `BANColors`：先核对 alpha、合成、Theme 底、AA。

Family / 字号本阶段不谈。Theme 未改。

---

## 0. 渲染链路通则

### ProfileColorProperty [已确认]

`BANColors.ts` 全部是 `ProfileColorProperty`。默认 profile 的 `default:` **就是**本 sim 最终色。没有第二套 runtime 调色。

### 核子球链路 [已确认]

```
PARTICLE_COLORS.proton/neutron
  → BANColors.protonColorProperty / neutronColorProperty
  → ParticleNode.updateFill
      RadialGradient 中心 (-0.4r, -0.4r)、半径 1.6r
      stop 0 = WHITE，stop 1 = base
      stroke = base，lineWidth 1
```

不是「只画 `#D14600` 实心圆」。高光是白，边缘才接近基色。

### 电子云链路 [已确认]

```
PARTICLE_COLORS.electron = Color.BLUE (#0000FF)
  → BANColors.electronColorProperty
  → BANConstants.ELECTRON_CLOUD_FILL_GRADIENT(radius)
      RadialGradient(0,0,0 → 0,0,r)
      stop 0: electron.withAlpha(1)
      stop 0.9: electron.withAlpha(0)
  → ParticleAtomNode.electronCloud fill
  → 画在核子后面（先云后球）
  → 默认 source-over 叠在 screenBackground（WHITE）上
```

### Focused 格链路 [已确认]

```
cell.fill = cellModel.colorProperty   // 稳定/衰变/未知 的不透明 fill
cell.stroke = nuclideChartBorder
cell.makeOpaque(Δp, Δn):
  opacity = (Δp>2 || Δn>2) ? 0.65 : 1
```

`0.65` 是 **整节点 opacity**（fill + stroke 一起乘），不是另换一种 fill。

---

## 1. Decay colors

| 角色 | PhET 源码 | hex | Flutter | 分类 |
|---|---|---|---|---|
| 屏背景 | `screenBackgroundColorProperty` WHITE | `#FFFFFF` | Theme Scaffold **`#FEF7FF`**（取样） | [工程差异] Material 3 surface |
| AppBar / Tab | joist 底栏黑 | `#000000`（取样 joist） | Home `accentColor` **`#B45309`** | [工程差异] 工程 chrome |
| 质子基色 | `PARTICLE_COLORS.proton` | `#D14600` | `0xFFD14600` | [源码一致] |
| 中子基色 | `GRAY.darkerColor(0.1)` | `#737373` | `0xFF737373` | [源码一致] |
| 电子基色 | `Color.BLUE` | `#0000FF` | `0xFF0000FF` | [源码一致] |
| 正电子 | `PARTICLE_COLORS.positron` | `#35B64A` | `0xFF35B64A` | [源码一致] |
| 空核虚线 | `Color.GRAY` dash | `#808080` | `0xFF808080` | [源码一致] |
| 元素名 | `Color.RED` | `#FF0000` | `0xFFFF0000` | [源码一致] |
| Stability | `fill: 'black'` | `#000000` | `#000000` | [源码一致] |
| 面板填充 | rgb(241,250,254) | `#F1FAFE` | `panelBackgroundValue` | [源码一致] |
| 面板描边 | `Color.GRAY` | `#808080` | `panelStrokeValue` | [源码一致] |
| Available Decays 底 | rgb(242,242,242) | `#F2F2F2` | 同；截图 **精确** | [源码一致] |
| 衰变键 base | rgb(251,178,64) | `#FBB240` | `decayButtonColorValue` | [源码一致] 启用 |
| 衰变键 disabled | sun `RectangularPushButton` 灰化 | 原版取样偏灰 | `orange.alpha 0.35` → 截图 `#F5DCB4` | [待确认] sun 配方 ≠ 0.35 |
| Info 按钮 | rgb(255,153,255) | `#FF99FF` | `infoButtonColorValue` | [源码一致] |
| 半衰期指针 | rgb(255,0,255) | `#FF00FF` | 同；Flutter 截图 **精确** | [源码一致] |
| 图例箭头 | rgb(4,4,255) | `#0404FF` | `legendArrowColorValue` | [源码一致] |
| Info dialog 底 | `infoDialogBackground` rgb(255,254,244) | `#FFFEF4` | Half-life dialog 同 | [源码一致] |
| Available Decays info 键 | WHITE | `#FFFFFF` | 无独立 info 键 | [工程差异] |
| 分隔线 | `HSeparator` `#CACACA` | `#CACACA` | **无** | [工程差异] |
| 衰变图标蓝 | `Color.BLUE` | `#0000FF` | 短符号，无 IconFactory 图 | [工程差异] NineGrid |
| Reset | `ResetAllButton` 橙圆（取样中心约 `#F89626`） | scenery-phet | `IconButton` + `Icons.restart_alt` | [工程差异] |
| Undo | `ReturnButton` 黄方 | scenery-phet | Chart Intro `Icons.undo`；Decay 无独立黄键 | [工程差异] |
| Electron Cloud 勾选 | sun Checkbox | — | Material Checkbox（Theme 主色） | [工程差异] |
| 生成器双箭头 | `DoubleArrowButton` `baseColor: white`，箭头黑 | 白底 | `Colors.black87` 图标，无白底 | [视觉近似] |
| 生成器单箭头 | 箭头 fill = 核子色 | p/n 基色 | `Icon` color = p/n | [源码一致] 箭头色 |
| 计数点描边 | ParticleNode stroke = 基色 1 | 1 | 计数点 `border width 0.5` | [视觉近似] |

原版 Decay **没有** Stability 以外的第二套文字色。计数面板走 `PANEL_OPTIONS`（`#F1FAFE`）。Flutter 计数在 Theme 底上，无独立面板盒时看起来更「lilac」。

---

## 2. Decay gradients

### 核子球 `ParticleNode.updateFill` [已确认]

| 参数 | PhET | Flutter `NucleusPainter._paintBall` / 生成器 `BoxDecoration` |
|---|---|---|
| 基色 | proton / neutron Property | 同 hex |
| 高光 | WHITE | `Colors.white` |
| 渐变中心 | 球心 + `(-0.4r, -0.4r)` | `Offset(-0.4r,-0.4r)` / `Alignment(-0.4,-0.4)` |
| 渐变半径 | `1.6r` | `1.6r` |
| stop | 0 白 → 1 基色 | `[white, base]` 默认 0/1 |
| 描边 | 基色，宽 1 | 同（生成器球同） |
| β 换色 | `Color.interpolateRGBA` 0.5s | `Color.lerp` + `colorProgress` |

**最终 paint**：不是扁平 `#D14600`。截图高光偏浅橙、边缘才近基色，属渐变采样，**不要把高光像素当 base**。

### 电子云见 §3

### 无 LinearGradient

BAN Decay / Chart Intro 正文 **没有** 用于核/面板的 `LinearGradient`。

---

## 3. Electron Cloud

| 项 | PhET | Flutter | 分类 |
|---|---|---|---|
| base | `#0000FF` | `#0000FF` | [源码一致] |
| 几何 | `RadialGradient(0,0,0 → 0,0,r)` | `Gradient.radial(center, r, …)` | [源码一致] |
| stop 0 | alpha **1** | alpha 1 | [源码一致] |
| stop 0.9 | alpha **0** | `[0.0, 0.9]` | [源码一致] |
| 合成 | source-over on **WHITE** | source-over on **`#FEF7FF`** | [视觉近似] 底色不同 → 观感偏紫 |
| 半径 | `updateCloudSize(…, 0.27, 10, 20)` | 同公式，本阶段不改 | [源码一致] 公式 |
| z | 云在核子后 | 先画云再画球 | [源码一致] |
| 图标 | 同 gradient，r = 字高×0.82 | 16×16 同 stop | [视觉近似] 尺寸 |
| blending | 无特殊 blend mode | 无 | [源码一致] |

Flutter Fe-69 取样：云中 `#B5B0FF` / `#938FFF` = 蓝 × α 叠在 `#FEF7FF` 上，**不是**源码改成了紫。

原版 341,300 附近 `#D6DBE9`：云 + 白底 + 邻近核子 AA，**不当 base**。

---

## 4. Chart colors

| 角色 | PhET | hex | Flutter | 分类 |
|---|---|---|---|---|
| Accordion 底 | WHITE | `#FFFFFF` | `chartAccordionFill` | [源码一致] |
| 格描边 | rgb(143,143,143) | `#8F8F8F` | `cellBorder` | [源码一致] |
| Magic 描边 | rgb(251,255,36) | `#FBFF24` | 常量有；**Painter 从未用** | [工程差异] 无 Magic checkbox |
| 稳定格 | rgb(27,20,100) | `#1B1464` | `stable` | [源码一致] |
| 未知格 | WHITE | `#FFFFFF` | `unknown` | [源码一致] |
| α 格 | rgb(40,215,86) | `#28D756` | `alpha` | [源码一致] |
| β- 格 | rgb(148,245,245) | `#94F5F5` | `betaMinus` | [源码一致] |
| β+ 格 | rgb(133,202,255) | `#85CAFF` | `betaPlus` | [源码一致] |
| p 发射格 | rgb(247,2,93) | `#F7025D` | `protonEmission` | [源码一致] |
| n 发射格 | rgb(255,31,255) | `#FF1FFF` | `neutronEmission` | [源码一致] |
| 格标签 | α/β-/unknown → 黑；其余白 | — | `labelFillFor` 同规则 | [源码一致] |
| 轴 / 刻度 | BLACK | `#000000` | 同 | [源码一致] |
| 高亮刻度字 | WHITE | `#FFFFFF` | 选中白字 | [源码一致] |
| 高亮刻度底 | proton / neutron 色 | `#D14600` / `#737373` | 同 | [源码一致] |
| Radio 选中底 | rgb(241,250,254) | `#F1FAFE` | `chartRadioBackground` | [源码一致] |
| Radio 未选 | sun Radio 默认 | — | **`#E8EEF2`** 自造 | [待确认] / 可修 |
| Radio 边 | — | — | `black87` / `black26` | [工程差异] |
| Zoom 裁剪框 | BLACK 1.5 | `#000000` | 同 | [源码一致] |
| 能级空 | BLACK | `#000000` | `emptyEnergyLevel` | [源码一致] |
| 能级满 | p/n 基色 | lerp | `Color.lerp(black, p\|n, t)` | [源码一致] |
| 能级粗 | 满层宽 4 / 默认 1 | — | 同 | [源码一致] |
| Shell 核子 fade | `opacityProperty` 0↔1 | 整粒 | `saveLayer` 白×opacity | [视觉近似] 合成路径 |
| 虚线 mini 核 | BLACK | `#000000` | 同 | [源码一致] |
| Nuclear Shell 高亮底 | rgb(189,255,255) | `#BDFFFF` | **无此控件** | [工程差异] |

`cellModel.colorProperty`：stable → stableColor；`decayType==null` → unknown WHITE；否则 `BANDecayType.colorProperty`。Flutter `colorForDecay` 同。

---

## 5. Focused opacity

| 项 | PhET | Flutter | 分类 |
|---|---|---|---|
| 窗外 | `makeOpaque`：`Δp>2 \|\| Δn>2` → **opacity 0.65** | `focusedDimDelta=2`，`focusedDimOpacity=0.65` | [源码一致] |
| 窗内 | opacity **1** | 1 | [源码一致] |
| 作用对象 | **整格 Node**（fill+stroke） | fill 与 stroke **各自** `withValues(alpha:)` | [源码一致] 结果等价 |
| 高亮框 | `Color.BLACK`，`lineWidth 1.5` | `Colors.black`，1.5 | [源码一致] |
| 当前格 fill | 仍是衰变/稳定色（不透明度 1） | 同 + 八角标签底 = 格色 | [源码一致] |
| 当前格 ≠ 窗外淡化 | 当前格在 5×5 内 | `opacityFor` 用 focus 锚 | [源码一致] |

**fill color 与 opacity 分开**：淡化格仍是原来的 `#28D756` 等，只是 ×0.65 叠在白 accordion 上。不要把截图上的「浅绿色」写成新 fill。

---

## 6. Periodic Table

Chart Intro **覆盖** shred 默认：

| 项 | shred 默认 | Chart Intro 源码 | Flutter | 分类 |
|---|---|---|---|---|
| disabled fill | `#EEEEEE` | **`Color.WHITE`** | `periodicTableDisabledFill` `#FFFFFF` | [源码一致] |
| 高亮 fill | — | BLACK | BLACK | [源码一致] |
| 高亮 stroke | — | BLACK，宽 **1** | 同 | [源码一致] |
| 高亮字 | — | WHITE | WHITE | [源码一致] |
| 未高亮字 | black | black | `#000000` | [源码一致] |
| 未高亮描边 | black 1 | black 1 | 同 | [源码一致] |
| 面板 | `PANEL_OPTIONS` `#F1FAFE` + GRAY | 同 | `panelBackground` / `panelStroke` | [源码一致] |
| 符号盒 | white / black 2 | 同 | 同 | [源码一致] |
| 符号 Z | shred positive `#D14600` | 同 | `isotopeProtonNumber` | [源码一致] |

**「disabled 白」= 不透明白填充，不是透明/无 fill。** Flutter 画了白矩形，正确。

C-12 截图里周期表被 NineGrid 缩到 ~104×42，取样落在格子缝上（`#A5A6A7` EDGE），**不能**用来否定白填充。

---

## 7. Equation / Buttons

| 项 | PhET | Flutter | 分类 |
|---|---|---|---|
| 方程箭头 fill | `DECAY_ARROW_OPTIONS` **WHITE** | `decayEquationArrowFill` 白 | [源码一致] |
| 方程箭头 stroke | BLACK，0.5 | 同 | [源码一致] |
| 加号 | `decayEquationArrowAndPlusNodeColor` BLACK | BLACK | [源码一致] |
| 方程 Z | `PhetColorScheme.RED_COLORBLIND` | `#FF5500` | [源码一致] |
| 方程 A / 符号 | 默认黑 | 黑 | [源码一致] |
| 标题 / % | LEGEND 黑 | 黑 | [源码一致] |
| Chart Decay 键 | `#FBB240`，字黑 | 同；disabled **alpha 0.4** | [待确认] 0.4 vs Decay 屏 0.35 |
| Full Chart 键 | WHITE + black stroke | 同 | [源码一致] |
| 图例色块 | 各 decay / stable 色 + 格描边 | 同 | [源码一致] |

---

## 8. Dialog

| Dialog | PhET fill | Flutter | 分类 |
|---|---|---|---|
| Half-life timescale | **显式** `infoDialogBackground` `#FFFEF4` | `infoDialogBackgroundValue` | [源码一致] |
| Available Decays info | `INFO_DIALOG_OPTIONS` **无 fill** → sun Dialog 默认（通常白） | 无此 Dialog | [工程差异] |
| Full Chart | `INFO_DIALOG_OPTIONS` 仅 `topMargin: 40` → **默认白** | **`#FFFEF4`** | [待确认] 用了半衰期奶油底 |
| Full Chart 图框 | black stroke，`dilated(5)` | 黑边 + pad 5 | [源码一致] |

C-12 dialog 截图在 1280 上 Dialog 可能未占到取样点（大量 `#FEF7FF` / `#1D1B20` AppBar 字）。**不以该帧像素定 Dialog 色。**

---

## 9. Flutter current（对照表）

| Component | PhET | Flutter | 差异 | 可修复 |
|---|---|---|---|---|
| 屏 / Scaffold 底 | `#FFFFFF` | Theme `#FEF7FF` | M3 surface | 是 · BAN 本地 Scaffold 白，勿改全局 Theme |
| 核子球 | 白→基色，-0.4r，1.6r，描边基色 | 同 | 底色合成不同 | 配方已齐；随底色走 |
| 电子云 | 蓝径向 0 / 0.9 | 同 stop | 叠在 lilac 上偏紫 | 随底色；**不改半径** |
| 半衰期指针 | `#FF00FF` | `#FF00FF` | 无 | — |
| Available Decays 底 | `#F2F2F2` | `#F2F2F2` | 无 | — |
| 衰变键启用 | `#FBB240` | `#FBB240` | 无 | — |
| 衰变键禁用 | sun 灰化 | α=0.35 → `#F5DCB4` | 配方不同 | 是 · 先查 sun disabled |
| Reset / Undo / Checkbox | scenery-phet / sun | Material 图标 / 主色 | chrome | 否（除非 BAN 本地重画，不动 Theme） |
| 周期表 disabled | 白填充 | 白填充 | 无 | — |
| 周期表高亮 | 黑底白字 | 同 | 无 | — |
| 图 fill / 0.65 | 分填充分透明度 | 同 | Magic 描边未接 | Magic 属功能，非本阶段 |
| Radio 未选 | sun | `#E8EEF2` | 自造 | 是 |
| 方程箭头 | 白填黑边 | 同 | 无 | — |
| Full Chart Dialog | 默认白 | `#FFFEF4` | 可能用错 Property | 是 · 先确认 sun Dialog 默认 |
| 壳层 fade | Node.opacity | `saveLayer` | 合成路径 | 视觉近似 |
| 生成器箭头底 | 白按钮 | 透明 IconButton | chrome | 视觉近似 |

---

## 10. Screenshot samples

方法：5×5 中位；`var>400` 标 EDGE，不当 base。  
原版 `original_decay_screen1.png` 1024×672。Flutter Fe-69 `2560×1600`（逻辑×2）。Chart Intro `1280×800` DPR1。

### 原版 Fe-69（可靠）

| 点 | hex | 对照源码 |
|---|---|---|
| 页背景 | `#FFFFFF` | screen WHITE |
| Available Decays 面 | `#F2F2F2` | **精确** |
| joist 底栏 | `#000000` | joist |
| Reset 近中心 | `#F89626`（EDGE） | ResetAllButton 橙，非 BANColors |
| 云/核重叠 | `#D6DBE9` / `#FAC2A8` EDGE | **合成+AA，不当蓝/橙 base** |

### Flutter Fe-69（可靠）

| 点 | hex | 解释 |
|---|---|---|
| Scaffold | `#FEF7FF` | M3 surface，不是 WHITE |
| AppBar | `#B45309` | Home accent |
| Available Decays | `#F2F2F2` | **精确** |
| α 键（Fe-69 禁用） | `#F5DCB4` | `#FBB240` ×0.35 on `#FEF7FF` |
| 指针带 | `#FF00FF` | **精确** |
| 云 | `#B5B0FF` | `#0000FF`×α on `#FEF7FF` → 偏紫 |
| 核附近 | `#DE895E` / `#AAAAAA` | 渐变高光/中子，不当 base |

### Chart Intro C-12

| 点 | hex | 解释 |
|---|---|---|
| Scaffold | `#FEF7FF` | 同 Theme |
| 元素名 | `#FF0000` | **精确** |
| Accordion 内 | `#FFFFFF` | 白底（EDGE 混格） |
| 周期表区 | `#E5E5E5` 等 EDGE | 缩放过小，**不采格 fill** |

---

## 11. 可修复项（只记录，P4-1 不改）

**[可精确修复 · BAN 本地，不改 Theme]**

1. Decay / Chart Intro **play 底** 显式 WHITE（覆盖 Scaffold `#FEF7FF`）→ 云会回到「蓝雾」而不是紫雾  
2. Chart Radio **未选** 去掉 `#E8EEF2`，与选中同用 `#F1FAFE` 或对齐 sun  
3. Full Chart Dialog fill：若确认 sun 默认白 → 不要用 `#FFFEF4`  
4. Decay 键 disabled：按 sun 灰化，而不是 α=0.35（需再读 RectangularPushButton）

**[视觉近似 · 配方已齐]**

- 核子双色径向；电子云 0/0.9  
- Focused 0.65；周期表白填充  
- 半衰期品红；图例色块  

**[工程差异 · 不宜当 Color 修]**

- AppBar / Tab / Reset / Undo / Checkbox Material  
- 无 IconFactory 蓝图标、无 `#CACACA` 分隔、无 Magic 描边 UI  
- Home accent `#B45309`

---

## 12. [已确认]

- `BANColors` 默认 profile = 最终色；核子再经 ParticleNode 径向  
- 质子 `#D14600`、中子 `#737373`、电子 `#0000FF`、正电子 `#35B64A`  
- 云：中心不透明蓝，0.9 处透明；半径公式已对齐  
- Focused：fill 不变，窗外 **opacity 0.65**  
- 周期表 Chart Intro disabled = **不透明白**，不是透明  
- 方程箭头白填黑边；Z `#FF5500`  
- 面板 `#F1FAFE` / `#F2F2F2` / 描边 `#808080`  
- 指针 `#FF00FF`（Flutter 截图命中）  
- 无 BAN 正文 LinearGradient  

---

## 13. [视觉近似]

- 同等 hex 叠在 `#FEF7FF` vs `#FFFFFF` 上，云/抗锯齿边不同  
- 核子高光像素 ≠ base  
- 壳层 fade：`saveLayer` vs Node.opacity  
- 生成器箭头无白底按钮  
- 计数点描边 0.5 vs 1  
- 电子云图标 16px vs 字高×0.82  

---

## 14. [待确认]

- sun `RectangularPushButton` disabled 的精确灰化（亮度/饱和/opacity）  
- sun `Dialog` 默认 fill 是否 WHITE（Full Chart）  
- Chart Radio 未选在 scenery 里的实际底  
- ResetAllButton / ReturnButton 的 scenery-phet 精确橙/黄（仓库无该文件）  
- Windows 上 Theme surface 是否总是 `#FEF7FF`（随 `useMaterial3`）  
- C-12 缩略图无法验证格 fill / Dialog 奶油底的像素  

---

## 15. 停止

P4-1 只完成 Color / Gradient 取证与矩阵。

**未改** Color、Gradient、opacity、Painter、NineGrid、Typography、State / Controller。

未进入 P4-2。
