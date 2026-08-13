# PhET Java 蓝本 · 深读进度追踪

> **产出触发**：主对话 2026-07-24 用户选 D 后追加选 C（先深读 Java 蓝本 + 建 EDD）
> **核心目的**：为 4 个新模块（color-vision / sound / radio-waves / wave-interference）各产出一份 EDD（Experiment Design Document），符合 memory 2q03lm2g §4.6.7 门禁要求
> **数据源**：`c:\workspace\kartosTrunk\kartosTrunk\simulations-java\simulations\<sim>\src\edu\colorado\kartos\<pkg>\`

---

## 一、Java 蓝本磁盘路径（已实测确认 2026-07-24）

**PHET_JAVA_ROOT** = `c:\workspace\kartosTrunk\kartosTrunk\`（注意嵌套两层）

4 个目标 sim 完整路径：

| sim | 完整路径 |
|---|---|
| color-vision | `c:\workspace\kartosTrunk\kartosTrunk\simulations-java\simulations\color-vision\src\edu\colorado\kartos\colorvision\` |
| sound | `c:\workspace\kartosTrunk\kartosTrunk\simulations-java\simulations\sound\src\edu\colorado\kartos\sound\` |
| radio-waves | `c:\workspace\kartosTrunk\kartosTrunk\simulations-java\simulations\radio-waves\src\edu\colorado\kartos\radiowaves\` |
| wave-interference | `c:\workspace\kartosTrunk\kartosTrunk\simulations-java\simulations\wave-interference\src\edu\colorado\kartos\waveinterference\` |

---

## 二、深读进度看板

| sim | 目录结构已探 | 主入口已读 | Model 类已读 | View 类已读 | 轻量 EDD | 完整 EDD |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| color-vision | ✅ 33 文件 | ✅ 2 module | ✅ 6/6 | 🟡 通过 module 引用 | ✅ | ✅ **v2.0** |
| sound | ✅ 111 文件 | ✅ 5 module | ✅ 10/10 | 🟡 通过 module 引用 | ✅ | ✅ **v2.0** |
| radio-waves | ✅ 57 文件 | ✅ 1 module | ✅ 6/8 | 🟡 通过 module 引用 | ✅ | ✅ **v2.0** |
| wave-interference | ✅ 196 文件 | ✅ 3 module | ✅ 7/16 | 🟡 通过 module 引用 | ✅ | ✅ **v2.0** |
**产出文件**：
- `docs/knowledge/kkartoss-java-simulations/4-sim-lightweight-EDD-index.md`（4 sim 轻量 EDD 索引 · Q1-Q6 全景对照）
- `docs/knowledge/kkartoss-java-simulations/edd/color-vision-EDD.md`（**首个完整 EDD · 8 章节全量 · 作为后续 sim 模板锚点**）

---

## 三、color-vision 首扫记录（2026-07-24）

### 目录布局（33 Java 文件 · 标准 MVC）

```
edu/colorado/kartos/colorvision/
├── ColorVisionApplication.java     (1.79 KB · 应用入口)
├── ColorVisionConstants.java       (1.90 KB · 常量)
├── ColorVisionResources.java       (2.20 KB · 资源加载)
├── ColorVisionStrings.java         (1.57 KB · 字符串)
├── RgbBulbsModule.java             (14.49 KB · ★ 子屏 1: RGB 三色合成)
├── SingleBulbModule.java           (18.68 KB · ★ 子屏 2: 单光源+滤色片)
├── control/                        (6 文件 · 控件)
│   ├── ColorIntensitySlider.java
│   ├── RgbBulbsControlPanel.java
│   ├── SingleBulbControlPanel.java
│   ├── SpectrumSlider.java         (20.19 KB · 光谱滑条)
│   ├── SpectrumSliderKnob.java
│   └── ToggleSwitch.java
├── event/                          (2 文件 · 事件)
│   ├── VisibleColorChangeEvent.java
│   └── VisibleColorChangeListener.java
├── help/                           (3 文件 · WiggleMe 提示动效)
│   ├── FilterSliderWiggleMe.java
│   ├── IntensitySliderWiggleMe.java
│   └── WiggleMe.java
├── model/                          (6 元件 · ★ 核心)
│   ├── Filter.java                 (6.63 KB · 滤色片)
│   ├── Person.java                 (2.70 KB · 观察者)
│   ├── Photon.java                 (6.72 KB · 单光子)
│   ├── PhotonBeam.java             (22.32 KB · 光子束 · 最大文件)
│   ├── SolidBeam.java              (6.84 KB · 实光束)
│   └── Spotlight.java              (6.52 KB · 光源)
└── view/                           (9 painter · MVC View)
    ├── BellCurve.java
    ├── BoundsOutliner.java
    ├── FilterGraphic.java
    ├── FilterHolderGraphic.java
    ├── PersonGraphic.java
    ├── PhotonBeamGraphic.java
    ├── PipeGraphic.java
    ├── SolidBeamGraphic.java
    ├── SpotlightGraphic.java
    └── ThoughtBubbleGraphic.java   (思考气泡 · 显示"看到什么颜色")
```

### 初步观察（Q1-Q10 十问的部分线索）

- **Q1 A 元件清单**（初判 6 类核心元件）：`Spotlight`（光源）· `Filter`（滤色片）· `Person`（观察者）· `Photon`（光子颗粒）· `SolidBeam`（实光束表征）· `PhotonBeam`（粒子光束表征）
- **Q1 B 辅助概念元件**：`BellCurve`（光谱高斯钟形分布）· `ThoughtBubbleGraphic`（思考气泡 · 显示学生"当前看到什么颜色"）· `PipeGraphic`（光管道 · 视觉限位）
- **Q2 元件数量**（初判）：子屏 1（RGB Bulbs）= 3 Spotlight + 1 Person + 3 PhotonBeam；子屏 2（Single Bulb）= 1 Spotlight + 1 Filter + 1 Person + 1 Beam
- **Q3-Q10** 需读代码细节

---

## 四、EDD 产出计划（4 个 sim × 各 1 份 EDD）

按 memory 2q03lm2g §4.6.7 EDD 8 章节要求，每个 sim 一份 EDD 大约 400-800 行。

**单次 vibe-loop 产出目标**：1 个 sim 的完整 EDD = 30-60 分钟深读代码 + 30 分钟写文档。

**建议节奏**（跟 shared-abstraction-plan.md §六 实施顺序对齐）：
1. **loop-1**（本轮 · 用户选 C 后展开）：先出 color-vision EDD（最小最简 · 33 文件）· 验证 EDD 模板可行性
2. **loop-2**：sound EDD（111 文件 · 复杂度中等）· 顺便沉淀 WaveField 概念
3. **loop-3**：radio-waves EDD（57 文件）· 验证 sound 的 WaveField 抽象是否可复用
4. **loop-4a**：wave-interference 骨架 EDD（196 文件 · 只出 MVP 范围声明 · 详细 EDD 拆到多个子 loop）

---

## 五、当前决策点

用户 2026-07-24 12:28 选 C 后，我实测确认了 Java 源码路径。**下一步需要用户拍板 EDD 的产出粒度**：

- **A · 现在立即产出 color-vision 完整 EDD**（Q1-Q10 全 + 8 章节 · 预计 30-60 分钟内产出 400-600 行文档）
- **B · 先产出 4 sim 的"轻量 EDD 索引"**（每 sim 一屏纸 · Q1-Q6 + 关键类清单 · 用于建立 4 sim 的横向对照），再决定深化哪个
- **C · 直接跳过 EDD 阶段**，回到用户之前拍板的 shared-abstraction-plan.md §六 顺序（P2 债务 → color-vision spec 阶段自然填 EDD）

**推荐 · A + B 混合**：先做 B（4 sim 各一屏纸 · 建立全景），再做 A（color-vision 完整 EDD 作为首个模板）
