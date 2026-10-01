# Phase 10 — Visual Layout Fidelity Correction

> 状态：**[视觉待修正]**  
> 核心布局已从「方程条左下角覆盖 Grid」纠正为 PhET Equations 拓扑；像素级 1:1 与图标精修仍有差距。  
> Phase 9 数学 / 行为锁：**未改动**。

## 1. 修改文件列表

| 文件 | 变更 |
|---|---|
| `lib/vector_addition/screens/vector_addition_home.dart` | 屏切换 Tab 移到底部；viewport 从 simulation UI 起 |
| `lib/vector_addition/widgets/va_screen_body.dart` | 方程条顶置；Vector Values / Components / Base Vectors / Reset / Scene radio |
| `lib/vector_addition/widgets/va_control_icons.dart` | **新建** Components 2×2 / Cartesian·Polar / ResetAll / Accordion ± |
| `lib/vector_addition/render/va_render_builder.dart` | `_anchors`：equationBar / baseVectors / 顶栏几何 |
| `lib/vector_addition/render/va_render_data.dart` | `equationBarRect` / `baseVectorsRect` |
| `lib/vector_addition/model/view_properties.dart` | `equationExpanded` / `baseVectorsExpanded` |
| `lib/vector_addition/vector_addition_constants.dart` | rightPanel / accordion / equationBarMinHeight |
| `lib/vector_addition/vector_addition_colors.dart` | accordion / radio / reset 色 |
| `lib/vector_addition/painters/va_scene_painter.dart` | label 背景 / 字重（仅绘制） |

## 2. Layout geometry 修改

对齐 PhET `EquationsSceneNode` / `EquationsScreenView` / `FixedSizeAccordionBox`：

```
Vector Values (centerX=graph.centerX, top=Y_MARGIN)
        ↓ +10
Equation bar (centerX=graph.centerX, 横向 radios + 1a+1b=c)
        ↓
Large Grid (MODEL_TO_VIEW_SCALE 14.5 · Equations bottomLeft.y += 40)
        │
        └── right: GraphControlPanel (固定 175) → Base Vectors (+8)
            bottom-right: Cartesian/Polar icons + ResetAll disc
```

- **禁止**：方程条 bottom sheet / 左下 floating / 覆盖 Grid  
- **禁止**：Expanded+Row 均分挤压 Grid  
- Home：屏 Tab **底部**（Joist navbar 语义）；`VaScreenBody` 截图不含顶部 Explore/Lab Tab

## 3. Grid bounds 修改前 / 后

| | L | T | R | B | W×H |
|---|---|---|---|---|---|
| **前/后（model 不变）** | 30 | 163 | 755 | 598 | **725×435** |

Grid 的 viewBounds **未改**（`scale=14.5` · Equations `bottomLeft.y=+40`）。  
视觉上变大：因方程条离开 Grid 底部，不再遮挡左下角。

## 4. Equation bar bounds 修改前 / 后

| | 位置 | 约略 bounds |
|---|---|---|
| **前** | 左下 floating | `left≈24, top≈498`（`layoutH−120`）· 覆盖 Grid |
| **后** | 顶栏 · Values 下 | `centerX=graph.centerX` · `top≈values.bottom+10` · `width≈688` · `height≥78` |

## 5. Components bounds 修改前 / 后

| | 形态 |
|---|---|
| **前** | 右栏顶部 `ChoiceChip` 文字 · Base Vectors 嵌在方程条内 |
| **后** | 右栏固定宽 175 · checkbox 序（resultant→values→angles→grid）→ separator → **2×2 icon radios**；**Base Vectors** 独立手风琴在 control 下方 |

## 6. Bottom controls bounds 修改前 / 后

| | 前 | 后 |
|---|---|---|
| Scene radio | ChoiceChip 文字 · `left=panel` | Cartesian/Polar **图标** 48×48 |
| Reset | Material `Icons.refresh` | PhET 风格 **橙色圆盘 + 白弧箭头** · `right=layout−20, bottom=layout−16` |

## 7. 四屏截图

`requirements/req-vector-addition/visual-qa/flutter/`

- `screen1_final.png` · `screen2_final.png` · `screen3_final.png` · `screen4_final.png`

对照 ref：`visual-qa/ref/screen4_equations.png`

## 8. Tests

```
flutter test test/vector_addition/   → 102 passed
flutter analyze lib/vector_addition → No issues found
```

## 9. Visual QA 最终差异列表

### 已纠正（相对 Phase 9 Flutter）

1. Equation bar 顶置，不再左下覆盖 Grid  
2. Values → Equation → Grid 垂直链  
3. Components 2×2 图标 radios（非 Material Chip 文字）  
4. Base Vectors 右侧独立面板 + 绿色可见性控件  
5. Reset 自定义几何；Cartesian/Polar 图标化  
6. Home 顶 Tab 移出 simulation 主视口（底栏）  
7. a/b 蓝 · c 黑；label 白底 / 选中黄底  

### Asset QA

- Original assets scanned: see `ASSET_INVENTORY.md`
- Assets reused: **1** (`eraser.svg` → Eraser)
- Custom drawn assets: **9** (PhET also ArrowNode/ResetShape/Path — no image files)
- Material replacements: **0**
- Unverified assets: **0**
- **[ASSET MISMATCH]**: none

详见 `requirements/req-vector-addition/visual-qa/ASSET_INVENTORY.md`。

### 仍待修正（故标记 **[视觉待修正]**）

1. Equation type 按钮仍为斜体文字，非 PhET 矢量符号图标节点  
2. Vector Values 展开内容未做「凹陷白底 NumberDisplay」分栏  
3. Components / scene icons 为工厂几何复刻，非位图像素 1:1（源码亦无 PNG）  
4. Equation NumberPicker 未按 PhET `contentFixedSize(670,50)` 等比缩放  
5. Resultant checkbox 仍用文字符号（源码为 createVectorIcon）  
6. Base Vectors 展开态 picker 排版密度仍偏疏  
7. Explore1D/2D/Lab 右栏与 toolbox 微距未逐像素复核  
8. Joist 黑底 status bar / PhET logo 属外壳，本工程 NineGrid 不复刻  

**禁止**用「整体相似」宣称完成。核心拓扑已对齐；细部图标与排版未达 1:1 → **[视觉待修正]**。
