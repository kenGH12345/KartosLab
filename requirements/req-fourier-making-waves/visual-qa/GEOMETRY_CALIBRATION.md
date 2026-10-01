# Visual QA · Geometry Calibration · Fourier Making Waves

> 日期：2026-09-03  
> 原则：源码 layout 常量优先；**禁止**截图像素硬编码。

---

## 1. 源码几何锚点 [已确认]

| 量 | 值 | 来源 |
|---|---|---|
| ScreenView | 1024 × 618 | joist 默认 · 对齐工程 |
| ChartRectangle | 645 × 123 | `FMWConstants.CHART_RECTANGLE_SIZE` |
| Chart x origin | 65 | `X_CHART_RECTANGLES` |
| Margins | 15 | `SCREEN_VIEW_*_MARGIN` |
| Panel radius | 5 | `PANEL_CORNER_RADIUS` |
| Answer sum stroke width | 4 | `SECONDARY_WAVEFORM_LINE_WIDTH` |

Flutter：`FmwConstants` + `FmwMvt` 做 math→screen。

---

## 2. 校准状态

| 项 | 状态 |
|---|---|
| Chart 宽高比 | **[视觉近似]** · FittedBox 缩放到 NineGrid center |
| 三图纵向对齐 | **[视觉近似]** |
| 右栏控制面板宽度 | **[视觉近似]** |
| 振幅条几何 | **[视觉近似]** |
| Wave Packet k 轴定位振幅棒 | **[待确认]** · 当前按序号排布 |
| 宽度指示器 / 连续波形绘制 | **[待确认]** · 开关已有，绘制未完 |
| 原版截图 overlay | **[待确认：缺少原版运行截图]** |

---

## 3. 有意差异

- KARTOSLAB AppBar + Tab + NineGrid
- 无 PhetFont / Source Sans Pro
- 无谐波音频（本轮）

---

## 4. 后续精校（非阻塞）

1. 补原版运行截图 → overlay diff  
2. Wave Packet 振幅按 waveNumber 定位  
3. Width indicators / continuous waveform 完整绘制  
4. EquationForm RichText  
5. Measurement tools（λ / T 卡尺）
