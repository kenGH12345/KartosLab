# Phase 2 — Visual Baseline · Kepler's Laws

> 日期：2026-09-01  
> 标记：`[已确认]` / `[推测]` / `[待确认]`
>
> **后续 Flutter 实测截图见 `PHASE9.md`。** 本节保持 Phase 2 当时记录，不把宣传 PNG 像素写进 layout。

**禁止读成：** 这些 PNG 的像素坐标可写进 Flutter。它们是官方宣传/演示构图，不是默认态，也不是本机运行截图。

---

## 1. 原版截图来源

| 文件 | 像素 | 来源 |
|---|---|---|
| `visual-qa/original/keplers-laws-screenshot-screen1.png` | **1536×1008** | GitHub `phetsims/keplers-laws/assets/` First Law |
| `…-screen2.png` | 1536×1008 | Second Law |
| `…-screen3.png` | 1536×1008 | Third Law |
| `…-screen4.png` | 1536×1008 | All Laws |
| `keplers-laws-screenshot.png` | 1536×1008 | 首页构图（第二定律） |

下载成功，文件大小与 GitHub blob 一致（screen1=285025 bytes）。[已确认]

**不是** 本机打开 https://phet.colorado.edu 后的实时截图。  
**[待确认：缺少原版运行截图]** — 未在可控 viewport/DPR 下跑 live sim。本基线只用仓库官方 PNG。

---

## 2. Viewport / DPR / Play area

| 项 | 值 | 依据 |
|---|---|---|
| 截图像素 | 1536×1008 | PIL |
| 逻辑 layout | **768×504** @ **DPR 2** | 1536/2=768、1008/2=504，与 joist 默认 ScreenView 一致 [推测，强] |
| 背景 | RGB(0,0,0) | 采样 (10,10)、(768,504) |
| 右栏面板 | RGB(40,40,40) | 采样 (1456,200)；对齐 `PANEL_FILL_DEFAULT` |
| joist 底栏 | 白 RGB(255,255,255) | 采样 footer；**KARTOSLAB 不用** |
| 播放条附近灰 | RGB(170,170,170) | (768,928) 可能是导航/按钮区 [推测] |

Play area：黑底全屏减去左/右浮动面板与底栏 TimeControl + joist footer。太阳在模型原点；椭圆几何中心在 **太阳左侧** (−c)；默认行星在太阳 **右侧** 约 2 AU。[已确认 源码 MVT + vis viva]

---

## 3. 坐标系（源码，非截图像素）

```
ModelViewTransform2.createSinglePointScaleInvertedYMapping(
  Vector2.ZERO,                    // 模型原点 = 太阳
  layoutBounds.center,             // 视图：layout 中心
  zoomScale                        // 45 或 100（动画）
)
```

Y 向上。默认 zoomLevel=2 → scale=100 view-px / model-unit。  
默认行星 (2.00, 0) → 视图约在太阳右侧 200 CSS px（@1x）= 400 截图像素。[源码确认 + 截图几何一致]

**不得**把 1536 图上量到的 offset 写进 layout。

---

## 4. 主锚点（逻辑，对照截图）

| 锚点 | 原版 | 截图观察 |
|---|---|---|
| 太阳 | 模型 (0,0)，黄色 ShadedSphere | 黄球在椭圆左焦点 |
| 行星 | magenta 球 | 轨道上品红球 |
| 速度矢 | PhetColorScheme.VELOCITY 绿，默认开 | 绿箭头 + v |
| 轨道 | fuchsia，线宽 3 | 品红椭圆 |
| 左上面板 | AlignBox left-top margin 10 | 离心率 / 面积 / T-a 图 |
| 右上面板 | AlignBox right-top margin 10 + zoom | Target Orbit + checkbox |
| TimeControl | layout 底边中心 − 10 | 蓝圆 Play / Restart / Step + Fast/Normal/Slow |
| Reset All | 右下 − 10 | 橙圆 |
| All Laws radio | 左下 | 三枚定律缩略图 |
| joist 底栏 | 标题 + PhET logo | **有意差异：Flutter AppBar + Tab** |

---

## 5. 官方图 ≠ 默认态

源码默认：第一定律 axes/foci/string/e **全关**；第二定律 apo/peri/areaValues **关**；velocity **开**；isPlaying **false**。

官方 PNG 是教学构图（开了 Foci/String/Eccentricity、面积数值、Earth 目标轨道等）。  
Phase 9 对照时：**默认态跟源码走**；构图跟 PNG 走时先把同一组 checkbox 打开再叠图。

---

## 6. 当前 Flutter

**无 Kepler 实现、无 Flutter 截图。** 不伪造。

对照清单（实现后补）：

| 表面 | 原版 PNG | Flutter | 状态 |
|---|---|---|---|
| 主 Canvas | screen1–4 | — | 未实现 |
| 核心对象（日/星/轨/v） | 有 | — | 未实现 |
| 控制面板 | 左+右 | — | 未实现 |
| TimeControl / Reset | 底中 + 右下 | — | 未实现 |
| Header/Footer | joist | KARTOSLAB AppBar | [有意差异] |

---

## 7. 本阶段结论

- 有官方 1536×1008 PNG，可作构图参考。
- 无 live 运行截图、无 Flutter 截图。
- 坐标权威仍是 MVT 公式，不是 PNG。
- **Blocked：** 无。  
- **下一阶段：** Phase 3 Architecture Design。
