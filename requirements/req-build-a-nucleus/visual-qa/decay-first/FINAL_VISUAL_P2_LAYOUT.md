# FINAL-VISUAL-P2-LAYOUT

> 信息面板布局差异分析 · **只分析，未改代码**  
> 日期：2026-08-31

不得改 NineGrid / State / Controller / Painter。不得为单张截图做绝对像素定位。

---

## 1. 原版：没有「一个信息面板」

Decay 屏这些节点都是 **ScreenView 的平级子节点**，用 `layoutBounds` 互相对齐。没有共同父 Panel。

实际是 **两簇**：

| 簇 | 成员 | 语义 |
|---|---|---|
| **右栏** | counters + symbol + Available Decays（+ undo / checkbox 借左缘） | 核素身份与衰变操作 |
| **核上方标签** | Stable/Unstable + element name | 跟着半衰期中心 X，压在核上方 |

把五者收成一个 local information panel **违反原版语义**。

---

## 2. 原版逐项

参考：`BANScreenView.ts`、`DecayScreenView.ts`、`NucleonNumberPanel.ts`、`AvailableDecaysPanel.ts`。

### counters（NucleonNumberPanel）

| | |
|---|---|
| 父容器 | ScreenView（`BANScreenView` 创建） |
| 相对位置 | `top = Y_MARGIN`（15）；`left = availableDecaysPanel.left`（Decay 后绑） |
| anchor | **top + left**，左缘与衰变面板对齐 |
| width / height | 内容盒经验值 **140×40** + Panel 边距 |
| spacing | 与 symbol **同一顶边**；在 symbol **左侧**，不在其下 |
| 对齐 | 数字右对齐；与 decays 共左缘 |

### isotope symbol（AccordionBox > SymbolNode scale 0.3）

| | |
|---|---|
| 父容器 | ScreenView |
| 相对位置 | `right = maxX - 15`，`top = Y_MARGIN`（15） |
| anchor | **top + right** |
| width / height | 标题 `maxWidth: 113` 控制整盒（issue #187）；`contentXMargin 35` / `Y 16` |
| spacing | decays 在其下 **+10** |
| 对齐 | 标题左对齐；内容居中 |

### Available Decays

| | |
|---|---|
| 父容器 | ScreenView |
| 相对位置 | `right = symbol.right`，`top = symbol.bottom + 10` |
| anchor | **top + right**（右缘锁 symbol） |
| width / height | `minWidth: 322`，`x/yMargin: 15`，键高 35、键内容宽 145 |
| spacing | 内部 VBox **10**；与 symbol **10** |
| 对齐 | 右栏主轴：counters.left、checkbox.left、undo.right 都相对它 |

### Stable / Unstable（StabilityIndicatorText）

| | |
|---|---|
| 父容器 | ScreenView（独立 Text，**无 Panel**） |
| 相对位置 | `center = (halfLifeInformationNodeCenterX, availableDecays.top)` |
| anchor | **center** |
| width | `maxWidth: 225` |
| spacing | 元素名在其下 **+60**（center 间距） |
| 对齐 | X = 半衰期块中心（创建时冻结，不跟箭头跑） |

### element name（ElementNameText）

| | |
|---|---|
| 父容器 | ScreenView（`BANScreenView` 创建，Decay 定位） |
| 相对位置 | `center = stability.center + (0, 60)` |
| anchor | **center** |
| width | `ELEMENT_NAME_MAX_WIDTH`；红字 |
| spacing | 在 Unstable **下方**、核 **上方** |
| 对齐 | 与 Unstable、半衰期中心 **同 X**，不是屏中、不是右栏 |

原版右栏顶行示意（1024 宽）：

```
                    [counters 140] [symbol]
                    [Available Decays ≥322     ]
```

核上方：

```
        [Half-life 550，left=45]
              [Unstable]     ← X = 半衰期中心，Y = decays.top
           [Iron - 69]       ← 再下 60
              (nucleus)
```

---

## 3. Flutter 当前

`NineGridLayout`（不可改）：

```
topLeft     topCenter      topRight
midLeft     center         midRight
bottomLeft  bottomCenter   bottomRight
+ footer
```

中心格 ≥70% 面积；边格均分剩余。Pixel Tablet 逻辑下边格大约几十到一百 px，**装不下** 322 宽衰变面板或 140 计数盒的原尺寸。

| 原版元素 | 原版父容器 | Flutter 当前父容器 | 最佳映射 | 原因 |
|---|---|---|---|---|
| counters | ScreenView；左缘=decays | **topLeft** + FittedBox | **midRight 内右栏顶行左侧** | 原版与 symbol 同行、与 decays 共左缘；topLeft 是另一侧 |
| isotope symbol | ScreenView；右上 | **topRight** + FittedBox | **midRight 内右栏顶行右侧** | 原版与 counters 同行、与 decays 共右缘；单独 topRight 被边格压成 ≈28×33 |
| Available Decays | ScreenView；symbol 下 +10 | **midRight** `_DecayPanel` | **仍 midRight，作为右栏主体** | 父格已对；应与上两项同一 Column，不要单独占格 |
| Stable / Unstable | ScreenView；核上方 | **topCenter** `ElementAndStabilityReadout` | **center：HalfLife 与画布之间** | 原版不是顶栏；X 跟半衰期/核，不跟屏中顶行 |
| element name | ScreenView；Unstable 下 60 | **同上 topCenter** | **同上，Unstable 下方** | 与 Unstable 必须同父；禁止单独挪到 topLeft/topRight |
| Half-life | ScreenView；上半屏宽 550 | **center Column 顶部** | **保持 center** | 顶行高 <124，已是合法 NineGrid 映射 |
| undo | ScreenView；decays.left-10 | midRight 内（有则 IconButton） | **midRight 或画布叠层，贴 decays 左** | 从属于衰变键，不是顶栏 |
| e-cloud / reset | 右下，借 decays 左 / 屏右下 | 画布内 Positioned / bottomRight | **保持**（本分析不改） | 非「信息面板」簇 |

---

## 4. 要不要合成一个 information panel？

**不要做成一个五合一 Panel。**

| 方案 | 结论 |
|---|---|
| 一个 Panel 装 counters+name+unstable+symbol+decays | **否**。原版把核标签和右栏拆开；合成后响应式会把「Iron-69」挤进右窄条 |
| 三个元素各自 `Positioned` 像素挪 | **否**。截图对齐、换视口即坏 |
| **两个本地组合，仍进已有格** | **是** |

推荐 Flutter 父子（仍只用现有 NineGrid 槽，不改 NineGrid）：

```text
NineGrid
  topLeft / topCenter / topRight    ← 清空（不再拆放这三项）
  midRight:
    DecayRightColumn                ← 新建组合 Widget，只做布局
      Column
        Row( crossAxis: start )
          NucleonCountReadout       // 左
          NuclideSymbolReadout      // 右
        SizedBox(height: 10)        // 对标 symbol.bottom+10
        Expanded(_DecayPanel)
  center:
    Column
      HalfLifeInformationView       // 已在
      ElementAndStabilityReadout    // 从 topCenter 移入；Column 水平居中
      Expanded(canvas)
  footer / bottomRight              ← 不动
```

`DecayRightColumn` 不是原版里的类，只是把 **已经共左/共右的三个节点** 收成一个可 `FittedBox` / 滚动的组合，避免再拆去 topLeft/topRight。

`ElementAndStabilityReadout` 已是 Unstable+名称的组合，**保持一个 Widget**，只换父格。

---

## 5. 分类

### [有意差异：工程布局约束] — 不修 NineGrid、不追像素

- midRight 宽度 << 322：五键全文案 + 示意图 + 图例无法原尺寸
- 顶行高度不够半衰期数轴（数轴留在 center 合法）
- joist 底栏 vs AppBar+Tab
- 右栏内部仍需 FittedBox / 滚动，不能复原 140×40 与 Accordion 原盒

### 值得以后改（P2 实现，本阶段不做）

1. **右栏合一进 midRight**：counters + symbol + decays 同一 Column/Row（原版右簇）
2. **核标签进 center**：ElementAndStability 放到 HalfLife 与画布之间（原版核上簇）
3. 清空 topLeft / topCenter / topRight 对这三项的占用
4. 右栏内部用比例/弹性，**禁止** `left: 687` 这类截图像素

### 不要改

- NineGrid
- State / Controller / Painter / 核与生成器 X（已 resolved）
- 为「更像这一张 Fe-69 图」做 Absolute 定位

---

## 6. P2 修正顺序（仅排序）

1. 在 **midRight** 建 `DecayRightColumn`：先 decays（已在），再把 symbol、counters 收进同一列顶行  
2. 把 **ElementAndStabilityReadout** 从 topCenter 移到 **center Column**（HalfLife 下、画布上）  
3. 顶行三格不再放这三项  
4. 再视 midRight 实宽做内部密度（键标签 / 封面示意图）— 仍标有意差异，能缩就缩，不扩 NineGrid  
5. undo 贴 decays；checkbox/reset 不动  
6. P3/P4 字体颜色另开，本布局不带

最小修改：只动 `build_a_nucleus_screen.dart` 的 NineGrid **槽位赋值** + 一个右栏组合 Widget；不改数据层。

---

*P2-LAYOUT 结束。未改代码。*
