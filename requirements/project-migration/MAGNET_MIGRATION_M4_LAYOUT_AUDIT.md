# MAGNET MIGRATION M4-1 · Screen Layout Audit

> 阶段：**只分析，不修改任何代码**
> 日期：2026-08-31
> 前置：M1 结构迁移 · M2 依赖 · M3 行为测试 19/19
> 证据级别：`[已确认]` = 源码/测试实证 · `[推测]` = 标注推测依据 · `[待确认]` = 需用户拍板

本阶段禁止：改 State / MagneticField / Controller / Painter geometry / Animation / Theme / Home / Assets / NineGrid 实现。

---

## 1. Original layout

对照三份源：

| 源 | 路径 | 布局角色 |
|---|---|---|
| **B（迁移真源）** | `simulations/magnet_and_compass.dart:243-343` | Flutter 复刻页 · M1 逐段抽出 |
| **Target（当前）** | `lib/magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart` | 与 B **逐 Positioned 等价** |
| **A（PhET Flutter 原型）** | `phet/magnet_and_compass/lib/main.dart:423+` | 同为 `Positioned(top:12, right:12)` + `_ControlPanel` `width: 230` |

Java 原版不在本仓库；本审计以 **B = Original**（用户指定 MagnetAndCompassPage）。

### 1.1 页面整体 viewport

```
Scaffold
  backgroundColor: Color.fromARGB(93, 0, 0, 0)
  body: Stack          ← 铺满 MediaQuery.size（无 AppBar、无 SafeArea、无 NineGrid）
```

- Viewport = **整个 Scaffold body** = `MediaQuery.of(context).size`
- 无 footer、无独立 side panel 槽
- 无世界坐标系缩放：1 逻辑像素 = 1 场计算单位

### 1.2 元素 Rect / Anchor（相对 viewport W×H）

| Element | Anchor | Size | 默认中心 / 位置 | Parent |
|---|---|---|---|---|
| **main canvas** | 满屏 | `W × H` | origin `(0,0)` 左上 | `Stack` |
| **field arrows** | `Positioned.fill` | `W × H` | 34×19 网格，格心 `(col+0.5)*W/34` | canvas Stack |
| **magnet** | 中心 `magnetPos` | **500 × 128** 硬编码 | `(0.42W, 0.50H)` | canvas Stack |
| **earth** | 中心 `magnetPos`（与磁铁共用） | **直径 360**（r=180） | 同上 | canvas Stack（与 magnet 互斥） |
| **vertical magnet on Earth** | Earth 正中 | **28 × 198**（`mH = r*1.1`） | Earth 中心 | Earth 内部 Stack |
| **compass** | 中心 `compassPos` | **直径 152**（r=76） | `(0.60W, 0.66H)` | canvas Stack |
| **field meter** | 中心 `fieldMeterPos` | **260 × 192** | `(0.28W, 0.30H)` · 默认隐藏 | canvas Stack |
| **control panel** | **右上** `top:12, right:12` | **宽 230** · 高随内容（约 280–320） | 浮动卡片 | 全屏 Stack（盖在 canvas 上） |
| **mini compass** | 面板 Compass 行右侧 | **60 × 22** | 非独立舞台元素 | ControlPanel 内部 |
| **back** | **左上** `top:12, left:12` | **44 × 44** | 导航 | 全屏 Stack |
| **reset** | **右下** `right:18, bottom:18` | **52 × 52** | 操作 | 全屏 Stack |
| **footer / side panel** | — | — | **不存在** | — |

### 1.3 缩放方式

**没有视口缩放。** [已确认]

| 随视口变的 | 不变的（硬编码 px） |
|---|---|
| 满屏 Stack / 磁场网格间距 | 磁铁 500×128 |
| 初始中心的 **比例**（0.42/0.50 等） | 地球 r=180 · 罗盘 r=76 |
| 拖拽 clamp 上界（`W - half`） | 面板宽 230 · 磁场计 260×192 · 按钮 44/52 |

大屏上磁铁相对变小；小屏上磁铁相对占满。这是 B 原行为，不是迁移引入。

---

## 2. Flutter current layout

Target 与 B 的页面级 Positioned **无 Δ**（M1 抽出未改布局）。

| Element | Original (B) | Flutter (target) | Δ | Current Parent |
|---|---|---|---|---|
| Viewport / canvas | `Scaffold > Stack` 满屏 | 同 | **0** | `Scaffold.body` |
| Field arrows | `Positioned.fill` + `FieldNeedlePainter` 34×19 | 同 | **0** | 全屏 Stack |
| Magnet | `Positioned(left: cx-250, top: cy-64)` + rotate | 同 · 常量改名 `kMagnetWidth` | **0** 布局 | 全屏 Stack |
| Earth | `Positioned` 直径 360 + SVG + glow + 竖磁铁 | 同 | **0** 布局 · SVG 仍缺失 | 全屏 Stack |
| Compass | `Positioned` 直径 152 | 同 | **0** | 全屏 Stack |
| Field meter | `Positioned` 260×192 · 可拖 | 抽出为 `FieldMeter` widget | **0** 几何 | 全屏 Stack |
| Control panel | `Positioned(top:12,right:12)` `width:230` | `MagnetControlPanel` | **0** | 全屏 Stack |
| Mini compass | 面板内 60×22 `CustomPaint` | `MiniCompassPreviewPainter` | **0** | ControlPanel Row |
| Back | `Positioned(top:12,left:12)` 44 | 同 | **0** | 全屏 Stack |
| Reset | `Positioned(right:18,bottom:18)` 52 | 同 | **0** | 全屏 Stack |
| Footer | 无 | 无 | **0** | — |
| NineGrid | 无 | **无** | 相对 kratos 规范 **缺失** | — |
| AppBar | 无 | 无 | **0** | — |

**当前未满足** checklist `80-kratos-sim-checklist.mdc` §七：

| 条款 | 现状 |
|---|---|
| L0-1 主图居中 | 满屏 Stack，主图即全屏；磁铁用 `Positioned(left: 动态中心)`（拖拽坐标，L0-1 允许加注释的绝对定位） |
| L0-2 无溢出 | **失败**：Slider 行 overflow ~55px（M3 测试实证） |
| L0-3 主图随视口 | 磁场网格随 `CustomPaint` size 变；磁铁/地球/罗盘 **硬编码 px**（L0-3 允许面板宽硬编码，不允许主 Canvas 固定；此处 Canvas 是满屏，物体尺寸固定） |
| L0-4 NineGridLayout | **失败**：主屏未引用 `NineGridLayout` |

---

## 3. NineGrid mapping

`NineGridLayout`（`lib/common/widgets/nine_grid_layout.dart`）：中间格面积 ≥ 70% · `side = √0.7 ≈ 0.8367` · 左右边格宽度各约为 **8.17% W**。

### 3.1 边格物理宽度（无 footer）

| 视口 | center W×H | 左右边格宽 | 上下边格高 |
|---|---|---|---|
| 1280×800 | 1071×669 | **105** | 65 |
| 1024×768 | 857×643 | **84** | 63 |
| 640×360 | 见 §6（sideH 触发 48px 下限） | **52** | 48（clamp 后） |

要把 **230px** 面板放进 `topRight` / `midRight`：需要边格宽 ≥ 230 ⇒ `0.0817 W ≥ 230` ⇒ **W ≥ ~2816**。在 1280/1024/640 上 **边格装不下原面板**。[已确认] 算术。

对照存量 sim：`wave_interference` 把宽控件放进 **footer**（横滑 + FittedBox），而不是 `midRight`。

### 3.2 适合进 NineGrid 的

| 元素 | 建议槽位 | 理由 | 风险 |
|---|---|---|---|
| **page-level canvas**（磁场网格 + 磁铁/地球/罗盘/磁场计 的 Stack） | `center` | 实验主画面 · 面积 ≥ 70% | 坐标必须改用 **center 的 LayoutBuilder size**，不能再用全屏 `MediaQuery`（见 §5） |
| **reset** | `bottomRight` | 页面级操作 · 52px 可放入边格 | 相对原 `right:18, bottom:18` 会随边格居中/贴边，略有位移 |
| **back** | `topLeft` | 页面级导航 · 44px 可放入 | 或改 AppBar（[待确认]） |
| **control panel** | **不要**塞进 `topRight`/`midRight` 保持 230px | 边格只有 50–105px | 见 §4 方案 A/B |
| **mini compass** | **随 ControlPanel** | 本来就是面板行内预览，不是独立舞台 | 不要单独占一格 |
| **field meter** | **留在 center Stack** | 位置 = `fieldMeterPos` · 拖去测场点 · 不是贴边 chrome | 若放边格会失去「对准场点」语义 |

### 3.3 必须保留局部绝对 / Canvas 定位

| 元素 | 方式 | 理由 |
|---|---|---|
| magnet | `Positioned` + `Transform.rotate` + `BarMagnetPainter` | 拖拽中心 `magnetPos` |
| compass | `Positioned` + `CompassPainter` | 拖拽中心 `compassPos` |
| field arrows / needle | `Positioned.fill` + `FieldNeedlePainter` | 铺满 **canvas**（NineGrid 后 = center 格） |
| Earth | `Positioned` + 内部 Stack | 与 `magnetPos` 绑定 |
| vertical magnet / glow | Earth 内部 | 地球装饰，非页面槽 |
| field meter | `Positioned` 在 center Stack | 可拖测量 |

**不要为了规范把磁铁/罗盘/场箭头改成 NineGrid 边格。**

### 3.4 建议壳层（M4-2 实施，本阶段不写代码）

```
Scaffold
└── Stack
    ├── NineGridLayout
    │     center: LayoutBuilder → Stack(          // 唯一实验画面
    │       Positioned.fill(FieldNeedlePainter),
    │       magnet | earth,
    │       compass,
    │       fieldMeter,
    │     )
    │     topLeft: back
    │     bottomRight: reset
    │     footer: （仅当采用方案 B）
    └── Overlay sibling: ControlPanel             // 方案 A：保持右上浮动
```

与 `sound_screen` / `optics_screen` 相同：NineGrid 分格 + Stack 兄弟做浮动层（InquiryDrawer）。

---

## 4. ControlPanel overflow analysis

### 4.1 实测（M3 widget test · 800×600）

```
RenderFlex overflowed by 55 pixels on the right
constraints: BoxConstraints(0.0<=w<=208.0, 0.0<=h<=Infinity)
size: Size(208.0, 20.0)
parentData.offset.dy = 88.0   ← 卡片内「箭头 + Slider」那一行
```

### 4.2 宽度拆解 [已确认]

| 项 | px |
|---|---|
| 面板 `SizedBox.width` | **230**（B / A / target 相同） |
| `_card` `padding: all(10)` | −20 |
| `border: Border.all` 左右各 1 | −2 |
| **Slider 行可用宽度** | **208** |
| `_arrowBtn` ×2 | 22+22 = **44** |
| **留给 Slider 的宽度** | **164** |
| overflow 55 ⇒ Slider 最小需求 | **208+55−44 = 219** |

根因：Flutter **Material 3 `Slider` 最小占宽 ≈ 219px**（含 theme 水平 padding），大于 164。  
`overlayShape: SliderComponentShape.noOverlay` 已关 overlay，仍不够。

**这是 B 原实现就有的溢出，不是 M1 拆分引入的 Δ。** 原版「slider width」并没有单独常量；track 吃的是 `Expanded` 剩余空间，但 Slider 自身有 minWidth。

| 项 | 值 |
|---|---|
| label「Strength:」+ 百分数徽章 | 上一行，不占 Slider 行 |
| 0% / 50% / 100% | Slider **上方**独立 Row（Spacer，不溢出） |
| unit / value | 徽章在 Strength 行，不在 Slider 行 |
| row spacing | `SizedBox(height: 2)` |
| panel min width | 硬编码 230 |
| 缩放 | **无** · 不随视口变宽 |

### 4.3 方案（本阶段不实施）

#### A · 保持原 UI，响应式压缩

保持右上浮动卡片、230 宽、原 checkbox / Flip 结构。只修 Slider 行：

1. `SliderTheme.padding = EdgeInsets.zero`（若 SDK 有 `year2023: false` 一并关 M3 大 padding）
2. 仍溢出则对该 Row 包 `FittedBox(fit: BoxFit.scaleDown)`
3. 或略减箭头 22→18、padding 10→8（视觉仍接近）

| 维度 | 评估 |
|---|---|
| 与原版接近 | **高** · 仍是右上 230 卡片 |
| 代码复杂度 | **低** |
| 小屏 | 面板仍 230，640 宽上覆盖右侧 ~36% · 与磁铁重叠（§6） |
| 交互 | Slider / 步进箭头保留 · FittedBox 过小会缩小点按热区 |

NineGrid：面板作为 **Stack 覆盖层**，不进边格。

#### B · NineGrid 内部重新布局

把控件改造成存量 sim 的 footer 横条（参照 `wave_interference_screen._buildSideControlPanel`）：

- `footer`: 横滑 + `FittedBox` · 强度滑块单独 `SizedBox(width: 180)`（该宽度下 Slider 不溢）
- 或 `midRight` 重做成 ~84–105px 竖条：必须拆掉 230 卡片、迷你罗盘、双栏 checkbox · **远离 PhET 原貌**

| 维度 | 评估 |
|---|---|
| 与原版接近 | **低**（右上卡片 → 底栏/窄侧栏） |
| 代码复杂度 | **中–高** |
| 小屏 | **更好** · footer 有现成压缩路径；L0-4 更干净 |
| 交互 | 强度/开关仍在；空间记忆（右上看面板）改变 |

### 4.4 比较小结

| | A | B |
|---|---|---|
| 原版接近 | ✅ | ❌ |
| L0-2 overflow | 可修 | 可修 |
| L0-4 边格装面板 | 不装（覆盖层） | footer 合规 |
| 推荐 M4-2 | **A 为主**（保 PhET）+ 用注释标明覆盖层例外 | 若用户优先 L0-4 字面「控件必须在边格」再选 B |

**不在 M4-1 实施。** 也不把溢出当物理/公式问题修。

---

## 5. Canvas mapping

**不要修改 `MagneticField.compute()`。** 场公式与像素坐标偶合是 B 的既有模型。

| 项 | 当前（B / target） |
|---|---|
| Coordinate system | Flutter 逻辑像素 · **Y 向下** |
| Origin | Scaffold body **左上** `(0,0)` |
| World-to-screen | **恒等** · 无投影、无 `scale` |
| Scale | 1.0 |
| Viewport | `MediaQuery.size` 全屏 |
| Magnet center | `_state.magnetPos` · 初始 `(0.42W, 0.50H)` |
| Compass center | `_state.compassPos` · 初始 `(0.60W, 0.66H)` |
| Field sample | `FieldNeedlePainter` 在 **painter Size** 上 34×19；`MagneticField.compute(p, magnetPos, …)` 的 `p` 与 `magnetPos` 同一空间 |
| Clamp magnet | `halfW…W-halfW` × `halfH…H-halfH`（半宽 250） |
| Clamp earth | `r…W-r` × `r…H-r`（r=180） |
| Clamp compass | `76…W-76` × `76…H-76` |
| Clamp field meter | `130…W-130` × `96…H-96` |

### M4-2 坐标陷阱 [已确认 逻辑]

若 `center` 小于全屏，而 `_initPositions` / clamp / painter 仍用 `MediaQuery.size`：

- 磁铁中心会按 **全屏** 比例落在 NineGrid 外或与网格错位
- 场箭头在 center 内绘制，却用全屏坐标的 `magnetPos`

**M4-2 必须**：center 内 `LayoutBuilder` 的 `constraints.biggest` 作为 canvas size；init / clamp / `FieldNeedlePainter` 共用这一 size。公式本身不变。

---

## 6. Responsive behavior

物体尺寸固定，只算 **全屏 Stack 现状**（NineGrid 后 center 更小，磁铁相对更大）。

符号：磁铁 500×128 · 地球 ⌀360 · 罗盘 ⌀152 · 面板 230×~300 · 磁场计 260×192 · reset 52。

### 6.1 1280×800

| | 值 |
|---|---|
| 磁铁中心 / 盒 | (538, 400) · left 288 · **与面板无重叠**（面板左缘 1038） |
| 罗盘中心 | (768, 528) |
| 磁场计中心 | (358, 240) |
| 地球 | ⌀360 完全落入 |
| 磁铁占宽 | 500/1280 = 39% |
| overflow | **Slider 行仍 55px**（与视口无关，是面板内宽） |
| clipping | 无（物体小于屏） |
| panel | 右上完整 |
| canvas | 满 1280×800 |
| NineGrid 边格若启用 | 105px **装不下 230 面板** |

### 6.2 1024×768

| | 值 |
|---|---|
| 磁铁中心 / 盒 | (430, 384) · left 180 · 右缘 680 · 面板左缘 782 · **间隙 ~100** |
| 罗盘 | (614, 507) |
| 磁铁占宽 | 49% |
| overflow | 同 Slider 55px |
| clipping | 无 |
| NineGrid 边格 | **84px** |

### 6.3 640×360

| | 值 |
|---|---|
| 磁铁中心 / 盒 | (269, 180) · left 19 · 右缘 519 · **与面板重叠 ~121px**（面板左缘 398） |
| 磁铁水平可拖范围 | clamp `[250, 390]` · 仅 **140px** |
| 地球 ⌀360 | **高等于视口** · 垂直 clamp `[180, 180]` · **不能上下拖** |
| 罗盘 | (384, 238) · 可拖范围窄 |
| 磁场计 | 高 192 / 屏高 360 · 盖住大量画面 |
| 面板 | 宽 230+12 占屏宽 38% · 高几乎通栏 · **压住 reset 区域** |
| overflow | Slider 55px **依旧** |
| clipping | 磁铁不 clip；地球贴顶底；Stack 不滚动 |
| canvas | 满 640×360 · 实验区被 chrome 严重侵占 |
| NineGrid 后 center 高 | sideH 下限 48 ⇒ centerH ≈ **264** · 地球 360 **必裁切** |

L0-2「480px 高以上主要控件可见」：360 高低于该下限；640×360 是本审计点，不是 checklist 保证区间。

---

## 7. Earth（只谈布局，不谈缺文件）

**Earth rendering path remains blocked by missing earth.svg**（资源问题不在本阶段解决）。

| 项 | 值 |
|---|---|
| 开关 | 面板 `Earth` → `earthField` · 与条形磁铁 **互斥** |
| 定位 | 中心 = `magnetPos`（拖地球 = 拖场源） |
| 外接方框 | `left/top = magnetPos − 180` · 边长 **360** |
| 内部 | `ClipOval` SVG 360 → `EarthGlowPainter` 360 → 竖磁铁 28×198 居中 |
| 场可视化 | `skipCircle` + `circleRadius: 180` · 圆内不画箭头 |
| 与 NineGrid | **留在 center canvas** · 禁止边格 |

640×360 上地球直径 = 屏高，布局已满；缺 SVG 是另一条 BLOCKED。

---

## 8. Recommended layout（M4-2 草案 · 本阶段不实施）

1. **壳**：`Scaffold > Stack > NineGridLayout` + 覆盖层。`center` = 实验 Stack。`topLeft` = back。`bottomRight` = reset。无 footer（除非改选方案 B）。
2. **Canvas 内**：保持 magnet / compass / field / earth / field meter 的 `Positioned` + `CustomPaint`。不改 Painter 几何、不改 `MagneticField.compute`。
3. **坐标**：init / clamp / 网格全部改用 center `LayoutBuilder` size。
4. **ControlPanel**：方案 **A**（右上覆盖 + 修 Slider min 宽 / FittedBox）。边格放不下 230px 是几何事实，不是偷懒。
5. **Mini compass**：留在面板内。
6. **Field meter**：留在 center，可拖。
7. **不修**：earth.svg、Electromagnet、原物理、控制面板视觉重设计（除 overflow）。
8. **L0-1**：center 内拖拽 `Positioned` 加行内注释（checklist 允许）。
9. **AppBar**：[待确认] FINAL_PLAN 曾建议；会改变 viewport 高度与 0.50H 中心。

---

## 9. [已确认]

1. B 与 target 页面 Positioned 布局 Δ = 0。
2. A 同样是右上 230 浮动面板。
3. 无 NineGrid、无 footer。
4. 坐标恒等映射，无 scale。
5. 磁铁/地球/罗盘/面板/磁场计为硬编码像素。
6. Slider 行 overflow 55px · 内宽 208 · 原 B 即有。
7. NineGrid 70% 中间格时，1280 边格仅 ~105px，**装不下 230 面板**（需约 2816 宽才够）。
8. 640×360：磁铁与面板重叠；地球不能竖向拖；Slider 溢出仍在。
9. `wave_interference` 用 footer 承载宽控件，而不是 midRight。

---

## 10. [推测]

1. Material 3 Slider 默认水平 padding 是 219 vs 164 的主要来源（未打开 SDK 源码逐行，以 M3 布局约束为准）。
2. 覆盖层 ControlPanel 会被 code-reviewer 视为 L0-4 可接受例外（有 InquiryDrawer 先例），但需注释。
3. 引入 NineGrid 后若不改用 center size，场与磁铁会错位——属 M4-2 必测项。

---

## 11. [待确认]

1. M4-2 控制面板选 **A（保原右上卡片）** 还是 **B（footer 横条）**。
2. 是否加 AppBar（标题 / 知识点）——会改变 H 与初始中心。
3. 小屏是否缩放磁铁/地球（当前 B 不缩放；L0-3 对「主图」更严，对场中物体未写死）。
4. Field meter 是否坚持用户清单里的「进 NineGrid」——本审计建议否。

---

M4-1 到此停止。下一步才是 **M4-2：Screen Layout Migration**。
