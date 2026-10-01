# PHASE 0 — SCREENSHOT AUDIT · Faraday's Law

依据：

1. 用户提供原版截图（会话附件 · 初始态）
2. 本地 source layout constants（优先）
3. 官方 runtime（后续 Phase 5 对照）

**原则**：禁止凭感觉估尺寸；常量 > 截图测量 > runtime。

截图场景：**Initial State**（单线圈、电压表关、场线关、磁铁在右、四向箭头可见）。

---

## 1. Viewport / Background

| 项 | 截图观察 | Source 依据 | 判定 |
|---|---|---|---|
| 画布比例 | 横屏宽幅 | `LAYOUT_BOUNDS` **834×504** | 以常量锁定 Flutter layout |
| 背景 | 纯浅蓝 | `rgb(151, 208, 255)` = `#97D0FF` | 必须一致 |
| 导航条 | 截图可能含/不含 PhET chrome | Joist navbar 非 play area | Flutter 用 KartosLab 壳；**play area 对齐 834×504** |

---

## 2. Scene — Magnet

| 项 | 截图 | Source | 备注 |
|---|---|---|---|
| 位置 | 右侧、约竖直居中偏右 | 默认中心 **(647, 200)** | |
| 尺寸 | 扁长条形 | **140×30** | |
| 极性 | 左红 N / 右蓝 S | `OrientationEnum.NS` | |
| 3D 顶边 | 可见暗色斜面 | `MAGNET_OFFSET_DX/DY_RATIO` + `MAGNET_3D_SHADOW` | 源码绘制 |
| 拖拽箭头 | 上下左右浅绿 | `MagnetMovementArrowsNode` fill `#B2FCB7`；默认可见 | 首次拖动后隐藏直至 Reset |

---

## 3. Scene — Coil

| 项 | 截图 | Source | 备注 |
|---|---|---|---|
| 可见线圈数 | **1**（中间偏下） | `topCoilVisible=false` | |
| 圈数外观 | 铜线圈多层 | `fourLoop*` mipmap；`numberOfSpirals=4` | 目测「3 圈」≠ source；以 PNG 为准（VD-09） |
| 位置 | 中左偏下 | bottom **(448, 310)** | |
| 前后层 | 线圈有前后透视 | front/back 分离；磁铁可从中间穿过视觉夹层 | z-order 阻塞 |
| 顶线圈 | 不可见 | top 仅双线圈模式 | |

---

## 4. Scene — Bulb & Wires

| 项 | 截图 | Source |
|---|---|---|
| 灯泡位置 | 左侧 | `BULB_POSITION (190,200)` + x 位移 −45 |
| 状态 | 灭、无光晕 | voltage=0；halo 不可见 |
| 灯座 | 灰色螺纹底座 | `lightBulbBase.png` |
| 泡壳 | 灰绿渐变玻璃感 | RadialGradient `#eeeeee`→`#bbccbb` |
| 导线 | 两根棕铜色连灯座与线圈 | `#7f3521` width 3；带圆角转弯 |

---

## 5. Scene — Voltmeter / Field Lines

| 项 | 截图 | Source |
|---|---|---|
| 电压表 | **不可见** | `voltmeterVisible=false` |
| 场线 | **不可见** | `fieldLinesVisible=false` |

---

## 6. Controls（底栏）

布局参考 source 坐标（相对 control strip，`bottom = bounds.maxY - 10`）：

| 控件 | 截图状态 | Source |
|---|---|---|
| Voltmeter checkbox | 未勾选；文案 "Voltmeter" | x≈174；centerY = radio.centerY−20 |
| Field Lines checkbox | 未勾选；文案 "Field Lines" | x≈174；centerY = radio.centerY+20 |
| 单线圈 radio | **选中**（深边框、浅紫底） | `topCoilVisible=false`；baseColor `#cdd5f6`；selectedLineWidth 3 |
| 双线圈 radio | 未选中 | `topCoilVisible=true` 时选中 |
| Flip Polarity | 浅绿矩形；小磁铁+弯箭头 | `FlipMagnetButton`；right = maxX−110 |
| Reset All | 右下角橙色圆钮 | `ResetAllButton` scale **0.75**；right = maxX−10 |

**文案**：英文 source 为 "Voltmeter" / "Field Lines"（非 "Show Field Lines" 完整句；checkbox 标签用 `showFieldLines` 字符串值 **"Field Lines"**）。

---

## 7. Spacing / Layering / Fonts / Colors

| 项 | 要求 |
|---|---|
| Layering | 导线 → 灯 → 线圈后 → 控件/电压表 → 磁铁+场线 → 线圈前 → 交互提示 |
| Fonts | 标签 `PhetFont(16)`；磁铁 N/S `PhetFont(24)`；电压表标签 `PhetFont(18)` yellow |
| Borders | Coil radio selected 3px / deselected 1px |
| Shadows | 磁铁半块 3D darker；电压表 `ShadedRectangle` |
| Overflow | 全控件应在 834×504 内 |

---

## 8. Phase 5 截图矩阵预登记（本阶段不拍 Flutter 图）

| # | 场景 | Phase 0 预期（source） |
|---|---|---|
| 1 | initial | 本审计截图 |
| 2 | magnet approaching coil | EMF 非零趋势 |
| 3 | magnet inside coil | 近场 B 饱和区 |
| 4 | magnet leaving | 反号 EMF（相对进入） |
| 5 | reversed polarity | NS↔SN；符号翻转 |
| 6 | field lines ON | 椭圆场线随磁铁 |
| 7 | field lines OFF | 无场线 |
| 8a | single coil | 仅 bottom |
| 8b | double coil | top+bottom |
| 9 | voltmeter visible | 针表 + 蓝导线 |
| 10 | voltmeter hidden | 无表 |
| 11 | strongest induced response | 快速穿过；\|V\| 大、halo 大 |
| 12 | reset | 回到 initial |

每张对照记录 P0/P1/P2（Phase 5）。

---

## 9. Screenshot vs Source 差异笔记

| 笔记 | 处理 |
|---|---|
| 截图描述「3 loops」 | **忽略目测圈数**；采用 fourLoop PNG + spirals=4 |
| 截图无电压表 | 与 initial 一致 |
| 截图有四向箭头 | 与 `magnetArrowsVisible=true` 一致 |

---

## 10. Phase 0 结论（视觉）

- 初始态截图与 source initial state **一致**。
- 控件集合完整：2 checkbox + 2 coil radio + Flip + Reset。
- 无 electron；无第二 screen。
- 尺寸落地必须以 **834×504 + 常量坐标** 为准，截图仅作形态核对。
