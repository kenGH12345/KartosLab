# FINAL-VISUAL-P2-REMEASURE

> Decay 首屏 · P2 全量重测 · **未改任何实现代码**  
> 日期：2026-08-31  
> 机器表：`p2_remeasure_matrix.json`

**resolved（保持，不重开）：**

- nucleus X = **resolved**（Δcx = 0.0）
- nucleus Y = **resolved**（公式仍为 `canvasH × 0.55`）
- generator X = **resolved**（Δcx = 0.0）

---

## 1. 验证环境（与此前完全一致）

| 端 | 视口 | DPR | 状态 / 产物 |
|---|---|---|---|
| 原版 PhET | 1024×672（LAYOUT_BOUNDS 1024×618 + joist ≈54） | 1 | `original_decay_screen1.png` · Fe-69 |
| Flutter | Pixel Tablet · 物理 2560×1600 · 逻辑 1280×800 | 2.0 | `flutter_decay_empty.png` · `flutter_decay_fe69.png`（本轮复跑 capture） |

归一化：去掉各自 chrome 后，把 play area 仿射到 **1024×618**。

| 量 | 值 |
|---|---|
| Flutter chrome 高 | AppBar 56 + TabBar 底 108 → **108** |
| Flutter play | 0,108 · 1280×692 |
| sx / sy | 1024/1280 = **0.8** · 618/692 ≈ **0.89306** |
| 原版坐标 | `DecayScreenView` / `BANScreenView` / `BANConstants` 锚点；宽高带「≈」的来自 `minWidth` 或目测 → `[视觉近似]` |

本轮复跑：

- `visual_qa_decay_capture_test`（空核 + Fe-69 截图与矩形）
- `measure_decay_first.py`（叠图）
- `build_a_nucleus_final_viewport_test`（含 **640×360**）

叠图 mean \|ΔRGB\|：

| 配对 | P1 重测 | 本轮 |
|---|---:|---:|
| 全画幅 · 空核 | 47.06 | 47.01 |
| 全画幅 · Fe-69 | 49.15 | 49.61 |
| Play 区 · Fe-69 | **31.20** | **31.79** |

Play 略升：标签从顶行进入 play，叠图多了一块与原版位置不同的红字/Unstable。不是核 X 回退。

---

## 2. 差异矩阵

Δ 针对归一化后的 **left / top / width / height**。中心另列 Δcx / Δcy。  
原版 Rect 单位 = LAYOUT_BOUNDS CSS px。Flutter Rect = 仿射后的同一空间。

### P0 · play / canvas / nucleus / generator

| 元素 | 原版 Rect | Flutter Rect | Δx | Δy | Δw | Δh | 分类 |
|---|---|---|---:|---:|---:|---:|---|
| page | 0,0 1024×672 | 0,0 1280×800（未映射） | — | — | +256 | +128 | [有意差异：NineGrid] 验证视口 |
| chrome / nav | 底 0,618 1024×54 | 顶 0,0 1280×108 | — | — | — | +54 | [有意差异：NineGrid] joist vs AppBar+Tab |
| playArea | 0,0 1024×618 | 0,0 1024×618 | 0 | 0 | 0 | 0 | [已对齐] 参考框 |
| canvas / stage | 0,0 1024×618 | 83.6,252.2 856.7×236.9 | +83.6 | +252.2 | -167.3 | -381.1 | [有意差异：NineGrid] |
| nucleus | 341.3, 339.9 | 341.3, 382.5 | **0.0** | +42.6 | 0 | 0 | [已对齐] X **resolved**；Y 公式 **resolved** |
| generator 中心 X | cx=341.3 | cx=341.3 | — | — | — | — | [已对齐] **resolved**（Δcx=0） |
| generator 条带 | 161.3,513 360×90 | 273.7,536.3 135.2×77.7 | +112.4 | +23.3 | -224.8 | -12.3 | [有意差异：NineGrid] footer；X 已对齐 |

canvas：P1 为 `83.6,157.5 856.7×331.6`。P2-2 把标签放进 center 后，画布顶下移、高度 331.6→236.9。  
nucleus play-Y +42.6：**不是** `atomOrigin` 回退，是画布变矮后 `0.55 × canvasH` 的屏位置下移。公式未改，**不重开 nucleus Y**。

### P2 · 信息簇 / 控件

| 元素 | 原版 Rect | Flutter Rect | Δx | Δy | Δw | Δh | 分类 |
|---|---|---|---:|---:|---:|---:|---|
| Half-Life | 45,95 550×80 | 83.6,46.8 856.7×110.7 | +38.6 | -48.2 | +306.7 | +30.7 | [有意差异：NineGrid] 拉满中心格 |
| counters | 687,15 ≈140×50 | 952.5,53.9 26.5×15.3 | +265.5 | +38.9 | -113.5 | -34.7 | [有意差异：NineGrid] |
| isotope symbol | 859,15 ≈150×120 | 985.4,62.9 32.2×42.0 | +126.4 | +47.9 | -117.8 | -78.0 | [有意差异：NineGrid] |
| Available Decays | 687,145 322×≈360 | 963.0,129.7 38.4×228.6 | +276.0 | -15.3 | -283.6 | -131.4 | [有意差异：NineGrid] |
| DecayRightColumn | 687,15 ≈322×490 | 940.4,46.8 83.6×442.3 | +253.4 | +31.8 | -238.4 | -47.7 | [有意差异：NineGrid] |
| Element name | 中心 ≈320,205 | 453.5,229.8 117.0×20.5（cx=512） | +203.5 | +36.8 | -23.0 | -3.5 | [值得修正] X |
| Stable / Unstable | 中心 ≈320,145 | 469.6,159.3 84.8×17.0（cx=512） | +204.6 | +26.3 | -25.2 | -7.0 | [值得修正] X |
| Reset | 969,563 40×40 | 940.4,489.2 83.6×42.9 | -28.6 | -73.8 | +43.6 | +2.9 | [视觉近似] |
| Electron Cloud | 687,575 ≈180×28 | 738.4,460.5 202.0×28.6 | +51.4 | -114.5 | +22.0 | +0.6 | [有意差异：NineGrid] |

原版元素名 / Unstable 的宽高是按字号 20 估的盒，标 `[视觉近似]`。Δ 以中心为主：Δcx = **+192**（512−320）。

### 其他 · chrome / footer / 大块

| 元素 | 原版 Rect | Flutter Rect | Δx | Δy | Δw | Δh | 分类 |
|---|---|---|---:|---:|---:|---:|---|
| AppBar+Tab | 无（底 joist） | 逻辑 0,0 1280×108 | — | — | — | — | [有意差异：NineGrid] |
| footer 生成器条 | 在 play 底（`bottom = maxY−15`） | NineGrid footer（逻辑 y≈708） | — | +23.3 | — | — | [有意差异：NineGrid] |
| 半衰期图例 | 在 Half-Life 节点内 | 83.6,132.5 856.7×25.0 | — | — | — | — | [有意差异：NineGrid] 随数轴拉满 |

P3 字体、P4 取色：本轮 **未取样**。已知 Stability 13 / 元素名 16 bold vs `REGULAR_FONT` 20 → [视觉近似]；颜色红/黑已在源码对齐，截图未复核 → [待确认]。

---

## 3. 重点观察

### 3.1 P2-1 右栏

P1 时 counters 在 **topLeft**（映射 x=16）。本轮在 **midRight**（映射 x=952.5），与 symbol、Available Decays 同一 `DecayRightColumn`。

| | counters 顶 | symbol 顶 | decays 顶 |
|---|---:|---:|---:|
| 归一化 y | 53.9 | 62.9 | 129.7 |

结构已是：

```text
Row(counters | symbol)
Available Decays
```

宽仍 ≈84（列）/ 26（计数）/ 32（符号）/ 38（五键），对原版 140 / 150 / 322。这是边格宽度，不是锚点错误。

### 3.2 P2-2 标签

P1：element y=7.1、Unstable y=27.7，在 **topCenter**（数轴上方）。  
本轮：Unstable y=159.3、element y=229.8，在 Half-Life（底 y=157.5）与画布（顶 y=252.2）之间。

垂直顺序 **Half-Life → Unstable → Element → Nucleus** 已恢复。  
逻辑中心距 Unstable→Element = **81**（源码 center+60；Column 间隙未补字高）。

### 3.3 Half-Life 与 center 标签

- 标签顶（Unstable y=159.3）紧贴 Half-Life 底（157.5），归一化间隙约 **1.8**。
- 水平：Half-Life **盒**中心 = 512 = 标签 cx。原版标签跟的是 **550 宽块**中心 ≈320，不是拉满格后的盒中心。
- 数轴读数内容中心映射 cx=420.9，仍偏左于标签。

### 3.4 Generator 与 nucleus 横向

两者归一化 cx 均为 **341.3**。横向关系保持 P0/P1 resolved。Y 条带仍在 footer 内，本轮不改。

### 3.5 Electron Cloud 与 center 布局

逻辑像素（1280×800）：

| | 范围 |
|---|---|
| Element 底 | y=388.3 |
| 画布顶 | y=390.3（间隙 **2.0**） |
| Checkbox | 923,624 252×32 |
| Unstable / Element | 水平约 567–713 |

与标签 **无重叠**（x、y 都不相交）。Checkbox 仍在画布右下，贴 midRight。

### 3.6 640×360

`视口：控件可达且无 overflow` **通过**。矮视口靠 center 内 `maxHeight 40%` + `FittedBox`，未改 NineGrid。

---

## 4. resolved（不要再当未修项）

| 项 | 本轮 | 标记 |
|---|---|---|
| nucleus X | Δcx = **0.0**（341.3） | **resolved** |
| nucleus Y | 公式仍 `canvasH×0.55` | **resolved** |
| generator X | Δcx = **0.0**（341.3） | **resolved** |

play 归一化核 Y +42.6 只写在 canvas / NineGrid 副作用里，不列入下一拍 P0。

---

## 5. 下一轮真正该改的优先级

只排序，本文件对应阶段 **不修**。

1. **标签 X（Element + Stability）** — [值得修正]  
   垂直已对；水平仍在中心格中线（归一化 cx=512，原版 ≈320）。  
   下一拍若追原版「跟半衰期中心 / 核轴」，用已有 `atomCenterXForLayout` 或半衰期**内容**中心，禁止截图像素，禁止改 NineGrid。

2. **Available Decays 内部密度** — 仍 [有意差异：NineGrid]  
   五枚 IconButton、无示意图。能在 midRight 内压缩的再开；不扩格。

3. **Reset / Electron Cloud 皮肤与落点** — [视觉近似] / [有意差异]  
   无重叠，不是阻塞。

4. **P3 字体 / P4 颜色** — 本轮未取样。  
   Stability 13、元素名 16 bold vs 20。不要和布局绑在一起。

5. **不要动**  
   nucleus X/Y 公式、generator X、generator Y、Half-Life 宽度、NineGrid、State / Controller / Painter / CanvasProjection。

6. **不要为叠图 31.79 vs 31.20 回退 P2。**

---

*P2-REMEASURE 结束。未改实现代码。*
