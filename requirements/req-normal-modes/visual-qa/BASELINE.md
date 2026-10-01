# Phase 2 / Visual QA — Baseline · Normal Modes

> 日期：2026-09-03（更新：Layout / Viewport 修复轮）  
> 规则：不伪造运行截图；不以营销图反推像素常量；不直接比异源 viewport 绝对像素。

---

## 0. 证据状态

| 项 | 状态 |
|---|---|
| 原版运行截图（用户图1/2） | **[已提供对照]**（会话内；建议落盘 `screenshots/phet-*.png`） |
| Flutter 截图 | `screenshots/flutter-one-dimension.png` / `flutter-two-dimensions.png`（1280×800） |
| 几何校准表 | [`GEOMETRY_CALIBRATION.md`](./GEOMETRY_CALIBRATION.md) |
| 布局锚点 | [已确认] ScreenView + `NmPageMetrics` |

归一化：`x_norm = x / VW`，`y_norm = y / VH`。逻辑视口仍为 **1024 × 618**；Flutter page 用 `availableWidth/Height` 推导列宽，不用截图像素硬编码。

---

## 1. Page layout（本轮 P0/P1）

```
App chrome (KARTOSLAB AppBar / Tabs)   ← 保留，占 page-level
└─ NineGrid center = available play
   ├─ SimulationViewport   （左 / 主）
   ├─ ControlColumn        （右，独占宽度）
   └─ BottomSpectrum       （仅 1D，左列底部）
```

| 检查 | 状态 |
|---|---|
| 右侧 panel 不覆盖 simulation | **[视觉已对齐]** |
| 2D Amplitudes 不侵入 grid | **[视觉已对齐]** |
| 1D Spectrum 不覆盖右列 | **[视觉已对齐]** |
| Model / Solver 未改 | **[源码一致]** |
| mass/spring/grid 微几何 | **[待确认]** → P3，viewport 之后 |

---

## 2. 各 Screen 默认状态（源码）

### 2.1 One Dimension

静止：3 蓝方块质量、橙弹簧、两端深灰墙。右列：Control + Normal Modes accordion + Reset。左列底：Spectrum（展开，频率标签折叠时仍在树内）。

### 2.2 Two Dimensions

3×3 蓝圆 + 橙网格 + 黑框。右列：Control + Normal Mode Amplitudes（270 格量级，列宽响应）+ Reset。无底 Spectrum。

---

## 3. 逻辑锚点（1024×618 · play 内部）

### 3.1 One Dimension

| 区域 | 逻辑坐标规则 |
|---|---|
| play / 弹簧中线原点 | (386.5, 159) |
| 左右墙 | **14 / 759** |
| 墙几何 | 6×80 |
| 质量 | 20×20，stroke 4 |
| control / modes | 页面右列（非 Stack 叠在 play 上） |
| spectrum | 左列底部 |

### 3.2 Two Dimensions

| 区域 | 逻辑坐标规则 |
|---|---|
| 盒中心 | (302, 309) |
| border | ≈ left=10，584×584 |
| amplitudes | 右列内，不与 grid 共享 Stack |
| 质量 | 圆 r=10 |

---

## 4. Typography / Color

（未改）见前版表；字体仍为 **[有意差异]**（无 PhetFont）。

---

## 5. Visual QA 状态

| 项 | 状态 |
|---|---|
| PAGE LAYOUT / VIEWPORT / PANEL ANCHOR | **[视觉已对齐]** |
| RESPONSIVE GEOMETRY（metrics） | **[行为一致]** |
| 微几何 / typography 精校 | **[视觉近似]** · 下一轮 P3 |
| 原版 PNG 落盘 | **[待确认]** |

比较禁止单一 mean RGB。详情见 `GEOMETRY_CALIBRATION.md`。
