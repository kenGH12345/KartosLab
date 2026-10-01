# Phase 2 — Visual Baseline · CCK AC Virtual Lab

> 日期：2026-09-02  
> 规则：不伪造运行截图；不把营销缩略图像素当布局常量。

---

## 0. 证据状态

| 项 | 状态 |
|---|---|
| 原版**可运行**空 Lab 截图 | **[已确认]** 用户提供 · 本地 `visual-qa/phet-lab-empty.png` |
| 官网营销图 `*-600.png` | [已确认] 演示电路，不是空 Lab 默认态 |
| Flutter 对应截图 | 编码后对照空 Lab chrome |
| 布局锚点 | [已确认] `CCKCScreenView.ts` + 空 Lab 截图 |

官方 600px 图路径：

- URL：https://phet.colorado.edu/sims/html/circuit-construction-kit-ac-virtual-lab/latest/circuit-construction-kit-ac-virtual-lab-600.png
- 本地：`requirements/req-cck-ac-virtual-lab/visual-qa/phet-600.png`

README GitHub 大图与 `*-screenshot.png` 下载失败（超时 / 404）。**禁止**用 600×394 图反推 play-area 像素或写死 offset。

---

## 1. 营销图能告诉什么 / 不能告诉什么

### 能（定性 · 对照源码）

空 Lab **不是**这张图。图是演示电路：AC 源 + 串联安培计 + 电阻 + 电感 + 电容闭环，lifelike 铜导线，电容板带 +/-。

可见壳层（与 `CCKCScreenView` 一致）：

| 区域 | 观察 | 源码锚 |
|---|---|---|
| 主 Canvas | 浅蓝 `#99c1ff` 铺满 | `CCKCColors.screenBackgroundColor` |
| 左工具箱 | 垂直 carousel：Wire / Battery / AC / Bulb / Resistor / Capacitor / Switch + 上下翻页 | `toolbox.left = bounds.left+10`，`top = bounds.top+5`；Lab 第 1 页 8 项（图里未露出 Inductor，被裁或需翻页）[推测裁切] |
| 左下 | Lifelike（选中）/ Schematic 双按钮；其下 Zoom −/+ | ViewRadioButtonGroup 在 toolbox 下；Zoom `right=toolbox.right`，`bottom=bounds.bottom-5` |
| 右栏 | DisplayOptions → SensorToolbox（电压表/安培计/V图/I图）→ Advanced 展开（电阻率 / 源内阻 tiny） | 右侧 VBox；`RIGHT_SIDE_PANEL_MIN_WIDTH=190` |
| 右下 | Play（三角=暂停态）+ Step + 橙色 Reset | TimeControl + ResetAll `right-10,bottom-5` |
| 底栏 | joist：标题 / 音量 / PhET / 菜单 | **[有意差异] Flutter 用 AppBar，无 joist 底栏** |

图中 Show Current **未勾**、Conventional 选中、播放为 Pause 后的 Play 图标——这是**演示摆拍**，不是代码默认（默认 `showCurrent=true`、electrons、`isPlaying=true`、空画布）。[已确认源码 vs 图不一致]

底部提示 “Tap circuit element to edit.” 为未选中时的编辑条文案。[已确认存在 CircuitElementEditContainerNode]

### 不能

- 不能得到 DPR、devicePixelRatio、真实 1024×768 / 1920×1080 下的 Rect。
- 不能把 600px 图上的元件位置当模型坐标。
- 不能用 mean RGB 当完成标准。

---

## 2. 坐标系（源码，非截图）

| 项 | 值 | 证据 |
|---|---|---|
| 电路世界 | Scenery 局部，Y 向下 | CircuitNode |
| 长度换算 | `meters = viewPx * 0.0005` | Wire.ts `METERS_PER_VIEW_COORDINATE` |
| Zoom | 0.5 / 1 / 1.6，默认 1 | `ZOOM_SCALES` |
| 吸附 | 30 世界/屏像素（zoom 前 view 坐标） | `SNAP_RADIUS` |
| 主舞台 | 几乎全屏；控件浮在 bounds 上 | 非 NineGrid；Flutter 用 NineGrid 包外壳，**center 仍是这一套局部坐标** |

Play area = `visibleBounds` 减去浮层。无单独「网格世界原点」；原点随 ScreenView。元件位置是绝对 view 坐标。

Flutter 映射：`CckMvt` 把电路坐标画进 NineGrid center 的 `Size`；默认 zoom=1 时 1 电路单位 = 1 逻辑像素（对齐 PhET view 坐标），再乘 `animatedZoomScale`。

---

## 3. 必测表面（编码后对照）

对照清单（Phase 5+ 才有 Flutter 图）：

| 表面 | 原版 | Flutter 现状 |
|---|---|---|
| 主 Canvas 空态浅蓝 | 营销图背景 + 颜色常量 | 未实现 |
| 核心对象（导线/电池/AC/C/L） | 营销图有演示环 | 未实现 |
| 控制面板（Display / Advanced / Sensors） | 营销图右侧 | 未实现 |
| AC generator 外观 | 圆形正弦 | 未实现 |
| Reset 橙圆右下 | 营销图 | 未实现 |
| Header/Footer | joist 底栏 | AppBar [有意差异] |
| TimeControl | 蓝 Play/Pause + Step | 未实现 |
| 工具箱第 1 页 8 项含 Inductor | 源码；600 图可能裁切 | 未实现 |

---

## 4. 主要面板几何（公式，非像素）

```
H = HORIZONTAL_MARGIN = 10
V = VERTICAL_MARGIN = 5
panelMinWidth = 190
carouselScale = 0.85
iconH = 31, iconW = 60
fontSize = 14
cornerRadius = 6
panelLineWidth = 1.3
```

Reset / TimeControl / Zoom **贴 visibleBounds 底边**，不进电路世界。

NineGrid 落地（Phase 8）：

- `center`：电路 Canvas（面积 ≥70%）
- `midLeft`：Carousel + ViewRadio + Zoom（窄时允许滚动）
- `midRight`：Display + Sensors + Advanced
- `footer`：TimeControl
- Reset：center 内右下 Positioned（不进边格）

---

## 5. Flutter 基线

`lib/cck_ac_virtual_lab/` **不存在**。无截图可采。  
Phase 5 空屏后再补 `visual-qa/flutter-empty-*.png`。

---

## 6. 下一阶段

进入 Phase 3 Architecture。视觉 QA 在有可运行 Flutter 之后按 P0–P5 分层修；本阶段不根据 600px 图写死任何 offset。
