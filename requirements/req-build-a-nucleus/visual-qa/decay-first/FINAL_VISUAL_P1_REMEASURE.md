# FINAL-VISUAL-P1-REMEASURE

> Decay 首屏 · 只重测 · **未改任何实现代码**  
> 日期：2026-08-31  
> 状态：nucleus X / nucleus Y / generator X = **resolved**

本文件替换上一份对照表中已过时的核 X、生成器 X 数字。其余项重新用同一套截图条件计算。

---

## 验证环境（与上一轮相同）

| 端 | 视口 | DPR | 状态 |
|---|---|---|---|
| 原版 PhET | 1024×672（LAYOUT_BOUNDS 1024×618 + joist ≈54） | 1 | `original_decay_screen1.png` · Fe-69 |
| Flutter | Pixel Tablet · 物理 2560×1600 · 逻辑 1280×800 | 2.0 | `flutter_decay_fe69.png` · 26p43n |

归一化：去掉各自 chrome 后，把 play area 仿射到 **1024×618**。

| 量 | 值 |
|---|---|
| Flutter chrome 高 | AppBar 56 + TabBar 48 = **108** |
| Flutter play | 0,108 · 1280×692 |
| sx / sy | 1024/1280 = **0.8** · 618/692 ≈ **0.89306** |
| 原版坐标来源 | `DecayScreenView` / `BANScreenView` / `BANConstants` 锚点；宽高带「≈」的来自 `minWidth` 或目测 |

叠图 mean \|ΔRGB\|（本轮重算，未改代码）：

| 配对 | mean \|ΔRGB\| |
|---|---:|
| 全画幅 · 空核 | 47.06 |
| 全画幅 · Fe-69 | 49.15 |
| Play 区 · Fe-69 | **31.20** |

相对 P0 前 Play **34.51** → P0 后 **31.22** → 本轮 **31.20**（生成器 X 对齐后的同一截图条件）。

原始逻辑矩形：`flutter_decay_fe69_rects.json`。机器表：`p1_remeasure_matrix.json`。

---

## 差异矩阵（按 P0 → P5）

Δ 针对归一化后的 **left / top / width / height**。中心对齐另列 Δcx / Δcy。  
**resolved** = 本阶段之前已修、本轮复测仍成立。本轮 **没有修复任何项**。

### P0 · 整体布局位置 / 尺寸

| 元素 | 原版 Rect | Flutter 映射 | Δx | Δy | Δw | Δh | 状态 |
|---|---|---|---:|---:|---:|---:|---|
| page | 0,0 1024×672 | 0,0 1280×800（未映射） | — | — | +256 | +128 | [有意差异：验证视口] |
| chrome / nav | 底栏 0,618 1024×54 | 顶栏 0,0 1280×108 | — | — | — | +54 | [有意差异：工程布局约束] |
| playArea | 0,0 1024×618 | 0,0 1024×618 | 0 | 0 | 0 | 0 | 归一化参考框 |
| canvas / stage | 0,0 1024×618 | 83.6,157.5 856.7×331.6 | +83.6 | +157.5 | -167.3 | -286.4 | [有意差异：NineGrid] |

P0 说明：原版粒子层铺满 LAYOUT_BOUNDS。Flutter 核画布只占 NineGrid 中心格，且上半被半衰期条占走。不改 NineGrid。

### P1 · Canvas / Nucleus 几何

| 元素 | 原版 | Flutter 映射 | Δx | Δy | Δw | Δh | Δcx | Δcy | 状态 |
|---|---|---|---:|---:|---:|---:|---:|---:|---|
| nucleus center | 341.3, 339.9 | 341.3, 339.9 | **0.0** | **0.0** | 0 | 0 | **0.0** | **0.0** | **resolved** |
| generator center X | cx = 341.3 | cx = 341.3 | — | — | — | — | **0.0** | +17.1 | **resolved**（仅 X） |
| generator 条带 | 161.3,513 360×90 | 273.7,536.3 135.2×77.7 | +112.4 | +23.3 | -224.8 | -12.3 | 0.0 | +17.1 | X resolved；Y/宽 [有意差异：footer] |

P1 说明：

- 核：`layoutWidth/3` 与 `canvasH×0.55`，复测 ΔX = ΔY = 0。
- 生成器：整组 `centerX = layoutWidth/3`，复测 Δcx = 0。条带比原版窄（≈169 vs ≈360 逻辑 px），左缘因此偏右；Y 仍在 NineGrid footer 内垂直居中，原版是 `bottom = maxY-15`。

### P2 · Panel / Buttons / Controls

| 元素 | 原版 Rect | Flutter 映射 | Δx | Δy | Δw | Δh | 状态 |
|---|---|---|---:|---:|---:|---:|---|
| half-life 信息区 | 45,95 550×80 | 83.6,46.8 856.7×110.7 | +38.6 | -48.2 | +306.7 | +30.7 | [有意差异：NineGrid] |
| counters | 687,15 ≈140×50 | 16.0,8.2 58.8×15.2 | -671.0 | -6.8 | -81.2 | -34.8 | [有意差异：NineGrid] |
| isotope symbol | 859,15 ≈150×120 | 970.8,13.5 22.8×29.7 | +111.8 | -1.5 | -127.2 | -90.3 | [有意差异：NineGrid] |
| Available Decays | 687,145 322×≈360 | 963.0,157.4 38.4×228.6 | +276.0 | +12.4 | -283.6 | -131.4 | [有意差异：NineGrid] |
| reset | 969,563 40×40 | 940.4,489.2 83.6×42.9 | -28.6 | -73.8 | +43.6 | +2.9 | [视觉近似] |
| e-cloud checkbox | 687,575 ≈180×28 | 738.4,460.5 202.0×28.6 | +51.4 | -114.5 | +22.0 | +0.6 | [有意差异：NineGrid] |
| element name | 中心 ≈320,205 | 453.5,7.1 117.0×20.5（cx=512） | — | — | — | — | [有意差异：NineGrid topCenter] |
| Unstable 读数 | 中心 ≈320,145 | 469.6,27.7 84.8×17.0（cx=512） | — | — | — | — | [有意差异：NineGrid topCenter] |

P2 说明：

- 计数原版在右上、与衰变面板左对齐；Flutter 在 topLeft。
- 符号盒原版 Accordion；Flutter 边格 ≈28×33。
- 衰变原版 `minWidth: 322` + 五键文案 + 示意图；Flutter 五枚 48px IconButton。
- Reset / 电子云仍在右下象限，皮肤与落点不同。
- 元素名 / Unstable：原版中心在半衰期节点中心 X（≈320）与衰变面板顶；Flutter 在 topCenter（屏中 512）。

### P3 · Typography

本轮 **未取样** font family / weight / ascent / baseline / letter-spacing。  
已记录：[视觉近似：字体]（PhetFont 不可用）。不在本轮开修。

### P4 · 颜色 / gradient / border / shadow

本轮 **未做逐像素取色**。仅叠图 mean \|ΔRGB\|（上表）。  
已知源码色（质子 #D14600、中子 #737373、衰变键 #FBB240 等）未在本轮用截图复核。不在本轮开修。

### P5 · 细小 icon / 2–5 px

| 元素 | 观察 | 状态 |
|---|---|---|
| symbol Δy | -1.5 px（归一化 top） | 未修；不值得为本数改布局 |
| 无其它 2–5 px 独立项 | 剩余差都是几十到几百 px 的容器级差 | — |

---

## resolved

| 项 | 上一轮 | 本轮复测 | 标记 |
|---|---|---|---|
| nucleus X | +170.7 → 已修为 layoutW/3 | **Δx = 0.0 · Δcx = 0.0** | **resolved** |
| nucleus Y | 0.0 | **Δy = 0.0 · Δcy = 0.0** | **resolved** |
| generator X | +283.1（条带左缘，当时居中）→ 已修整组 centerX | **Δcx = 0.0** | **resolved** |

---

## 下一拍优先级（只排序，不修）

1. **P0** canvas / stage 与 chrome（NineGrid / joist）— 多为 [有意差异]  
2. **P2** Available Decays、symbol、counters、half-life 容器 — 边格装不下原文案  
3. **P2** Reset / checkbox 皮肤与落点  
4. **P1** generator 条带宽度与 Y（X 已 resolved）  
5. **P3 / P4** 字体与颜色取样  
6. **P5** 1–2 px 项不要动

禁止把 resolved 的核 X / 生成器 X 再当未修项开修。

---

*P1-REMEASURE 结束。未改代码。*
