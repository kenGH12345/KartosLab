# Visual Baseline — Energy Forms and Changes

> Phase 2 · 2026-09-10  
> 证据来源：PhET 仓库营销截图（非伪造）

---

## PHASE: 2 — Visual Baseline
## STATUS: DONE（营销截图基线；缺实时运行截图）

---

## 1. 证据来源

| 文件 | 内容 | 置信度 |
|---|---|---|
| `assets/energy-forms-and-changes-screenshot-screen1.png` | Intro 屏营销图 | `[已确认]` 官方仓库 |
| `assets/energy-forms-and-changes-screenshot-screen2.png` | Systems 屏营销图 | `[已确认]` |
| `visual-qa/phet-screenshots/` | 拷贝副本 | 同上 |
| 原版 HTML 实时运行截图 | — | **`[待确认：缺少原版运行截图]`**（本机无完整 PhET deps 构建链） |

营销图可能含 nav bar / PhET logo；**布局锚点以源码为准**，截图仅作视觉拓扑参考。

---

## 2. Viewport / Design

| 项 | 值 | 证据 |
|---|---|---|
| PhET layoutBounds | **1024 × 618** | joist DEFAULT；`EFACConstants.SCREEN_LAYOUT_BOUNDS` |
| Flutter 逻辑画布 | 同 1024×618，装入 NineGrid center | 架构约定 |
| DPR | 设备相关 | 运行时测量 |
| 背景 | RGB(249, 244, 205) | `EFACConstants.FIRST/SECOND_SCREEN_BACKGROUND_COLOR` |

---

## 3. Intro — 拓扑与锚点（源码 + 截图交叉）

| 区域 | 源码锚点 | 截图观察 |
|---|---|---|
| 台面 shelf | MVT(0,0)+10px Y | 木纹横条，物体落于其上 |
| MVT origin | (W×0.5, H×0.85) | 台面偏下 |
| 物体 | ground snap spots ×6；burners index 2,3 | L→R：Iron, Water+burner, Brick+burner, Olive Oil |
| Thermometer storage | 左上 EDGE_INSET=10 | 截图见左侧温度计 |
| Control panel | rightTop (W−10, 10) | Energy Symbols / Link Heaters |
| Time + Reset | 台面与底边之间居中/右侧 | 截图有 nav bar（Flutter 用 AppBar/Tab，**有意差异**） |

**Major objects**：Iron block, Brick, Water beaker, Olive Oil beaker, 2× HeaterCooler+stand, Energy chunks (orange E), steam, thermometers.

---

## 4. Systems — 拓扑与锚点

| 区域 | 源码锚点 | 截图观察 |
|---|---|---|
| MVT origin | (W×0.5, H×0.475) | 管线垂直居中偏上 |
| Source / Converter / User | 选中位 x≈ −0.15 / −0.025 / 0.09 m | L→R 能量链 |
| Energy Symbols panel | 右上 | 可见 |
| 3× Selector | 底栏上方，left=10 spacing=82 | 截图：Faucet+Generator+Beaker 选中 |
| Time + Reset | 底栏 | 无 Fast Forward（与 Intro 差异 `[已确认]`） |

**截图状态**：Faucet → Generator → BeakerHeater（非默认 Biker 组合）——仅视觉参考，默认状态以 Model 为准。

---

## 5. Flutter 当前

| 项 | 状态 |
|---|---|
| Flutter EFAC 实现 | 无 |
| Flutter 截图 | N/A（Phase 5 起） |

---

## 6. 坐标原则（落地约束）

- 逻辑坐标：PhET layout 1024×618 + 各屏 MVT  
- 页面壳：NineGrid / KratosTabbedScreen  
- **禁止**按单张营销图硬编码大量像素 offset  
- 允许：源码常量、比例缩放、anchor positioning

---

## 7. Phase 报告框

1. Completed：拷贝官方截图；记录 Intro/Systems 拓扑与锚点  
2. Files：`visual-qa/BASELINE.md`, `visual-qa/phet-screenshots/*`  
3. Evidence：官方 PNG + 源码 MVT；缺实时运行截图已标记  
4–5. Tests/Analyze：未改代码  
6. Visual status：基线就绪；Flutter 待建  
7. Blocked：无  
8. Known limitations：营销图含 PhET chrome；非交互态精确像素  
9. Next：Phase 3 Architecture

---

*Phase 2 完成 → 自动进入 Phase 3*
