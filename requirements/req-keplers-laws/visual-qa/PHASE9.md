# Phase 9 — Visual Fix · Kepler's Laws

> 2026-09-01 续  
> 规则：源码公式 → Flutter 等价语义 → **实际截图测量**。禁止 mean RGB 当完成标准，禁止把截图像素写进 layout。

## 对照材料

| 材料 | 状态 |
|---|---|
| Flutter 1024×768 widget 截图 | [已确认] `visual-qa/flutter/*-1024x768.png` |
| 官方仓库 PNG 1536×1008 | [已确认] 构图态，非默认态；screen3/screen4 文件截断不可读 |
| 本机 live PhET 截图 | [待确认] 未在可控 viewport 运行 phet.colorado.edu |

widget 测试使用 Ahem 字体，文字显示为方块。这是测试字体，**不是** 产品缺字。[已确认]

官方 PNG 不能当默认态金标：源码默认 First Law 的 axes/foci/string/e 全关、`isPlaying=false`；宣传图是打开 Foci/String 等的教学构图。

未做 Rect overlay / pixel diff（视口、chrome、构图均不同）。

---

## 本轮修掉的真实布局 bug（非猜像素）

### 1. Play area Stack 高度塌成 0

隐藏的 `PeriodTimerOverlay` / `YearsStopwatchOverlay` 以非定位 `SizedBox.shrink()` 作为 Stack 子节点。NineGrid 中心格高度约束是松的 → Stack 高度 = 0，却仍按 LayoutBuilder 的 `maxHeight` 算 MVT。太阳被画到格子下半（测量 y≈618）。

修复：`SizedBox` 填满中心格 + `StackFit.expand`；隐藏 overlay 不进入 Stack。

布局测试：`play area fills NineGrid center` — 宽 > 600、高 > 400。

### 2. 定律面板叠在 70% 中心格内，挡住默认行星

NineGrid 中心格宽 ≈ `1024 × √0.7 ≈ 856px`。默认行星 view 位置 = 太阳 + 200px ≈ 屏幕 x=712。面板若再在中心格内占 230px，右栏左缘约 702，行星落在 Visibility 面板下（采样 `(712,360)=(40,40,40)`）。

原版 AlignBox 相对 **整屏 layoutBounds**，不是相对已缩小的中心格。[已确认 ScreenView]

修复：左/右面板、zoom、Reset、All Laws radio 提到页面级 Stack，贴屏幕边缘、底边避开 TimeControl footer。未改 `NineGridLayout` API。

---

## P0 几何（Flutter 1024×768 实测，非 mean RGB）

采样窗口：太阳附近 x∈[400,620] y∈[250,480] 的近黄像素；行星附近 x∈[620,800] 的品红像素。

| 项 | 源码预期 | first-law-default 实测 | 判定 |
|---|---|---|---|
| 太阳 | MVT 原点 ≈ 屏心略偏上（AppBar+footer） | 质心 **(508.0, 360.0)**；`(512,360)=(255,255,36)` | [已确认] |
| 行星 | 默认 (2,0)×scale 100 → 太阳右侧 200px | 品红质心 **(707.7, 363.5)**，Δx≈200 | [已确认] |
| 速度矢 | 默认开，绿 `Color(50,255,50)`，+Y → 屏上 | `(712,360)=(50,255,50)` | [已确认] |
| 左栏 | panelFill RGB(40,40,40) | `(80,200)=(40,40,40)` | [已确认] |
| 背景 | 黑 | `(420,360)=(0,0,0)`（First Law 默认） | [已确认] |
| 第二定律扇区 | 暂停时仍有 `update()` 面积色 | `(420,360)=(200,0,200)` | [已确认] 颜色来自 `ORBITAL_AREA_COLORS` |

未把上述数字写进 Dart layout 常量。

---

## 与官方 PNG 的关系（构图参考，非金标）

`original/keplers-laws-screenshot.png`（Second Law 构图、正在扫面积、数值标签）：太阳在焦点、品红椭圆、绿速度矢、左 Period Divisions、右 Visibility、底 TimeControl、橙 Reset — **结构同类**。

不能逐像素叠：官方 1536×1008 @DPR2 构图态 + joist 底栏；Flutter 1024×768 + AppBar/Tab。[有意差异]

---

## 已按源码对齐（非截图像素）

| 层 | 项 | 证据 |
|---|---|---|
| P0 | MVT：原点=太阳，Y 向上，scale=zoomScale | `KeplersMvt` |
| P0 | 默认行星 (2,0)，zoom 100 → 太阳右侧 200 view-px | constants + 本轮截图 |
| P1 | 面板 fill RGB(40,40,40)，圆角 5 | `KeplersLawsColors.panelFill` |
| P1 | 黑底；Reset 贴屏右下（footer 之上） | 页面 Stack |
| P4 | Velocity / Gravity / Reset / Play 色 | PhetColorScheme |
| P5 | 速度矢长度 `v * VELOCITY_TO_VIEW_MULTIPLIER * zoomScale` | VectorNode.ts |
| P5 | 非法轨道仅 dash [5] | EllipticalOrbitNode |

---

## 仍不宣称完成的视觉项

| 项 | 标记 |
|---|---|
| 与 live PhET 同视口 Rect overlay | [待确认] 无原版运行截图 |
| 面积扇区扫掠 | [源码一致] `clockwiseSweep`；live 播放态叠图仍 [待确认] |
| widget 截图中的文字glyphs | 测试 Ahem；真机字体 [待确认] 未做 device 截图 |
| `constrainDragPoint` 避开 UI 矩形 | [BLOCKED] 缺 solar-system-common；现只夹 escapeRadius |
| 声音 / Info PNG | [有意差异] 不自制 |

---

## 本阶段结论

- P0 主坐标（太阳中心、行星 +x、绿速度矢、面板叠在整页边缘）已用 **Flutter 实际截图** 验证。
- 不把 Visual QA 标成 BLOCKED：缺的是 live PhET overlay，不是缺 Flutter 截图。
- 禁止用 mean RGB；禁止 GitHub ZIP；不改 thirdLaw 理想公式测试。
