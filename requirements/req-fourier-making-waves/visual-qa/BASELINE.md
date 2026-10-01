# Phase 2 — Visual Baseline · Fourier Making Waves

> 需求：`req-fourier-making-waves`  
> 日期：2026-09-03  
> **[待确认：缺少原版运行截图]** — 不伪造。基线以源码 layout 常量 + 结构描述为主。

---

## 0. 证据状态

| 证据 | 状态 |
|---|---|
| 本地源码 layout 常量 | [已确认] `FMWConstants.ts` |
| `doc/` 文档 | [已确认] |
| README 官方截图 URL | 存在远程 URL；**未下载入库** → 不作为像素真值 |
| 本机运行 PhET HTML 截图 | **缺失** → `[待确认：缺少原版运行截图]` |
| KARTOSLAB 实现截图 | Phase 5+ 后补充 |

禁止用 mean RGB / 伪造截图声称「视觉一致」。

---

## 1. 全局视口（源码）

| 项 | 值 | 标记 |
|---|---|---|
| PhET ScreenView | 1024 × 618 | [推测] joist 默认；对齐工程其他 sim |
| SCREEN_VIEW_X/Y_MARGIN | 15 | [已确认] |
| Chart rectangle | 645 × 123 | [已确认] |
| Chart x origin | 65 | [已确认 `X_CHART_RECTANGLES`] |
| Panel corner radius | 5 | [已确认] |
| Control font | PhetFont 12 | [已确认] · Flutter **[有意差异]** 无 Source Sans Pro |

KARTOSLAB 外壳：AppBar + Tab + NineGrid → **[有意差异]**，不改全局架构。

---

## 2. Discrete — 结构基线（无截图像素）

### 默认态 [已确认模型]

- Waveform: Sinusoid
- Domain: SPACE (x)
- Series: SIN
- Harmonics: 11
- Equation: HIDDEN
- Playing: true（但 SPACE 下 t 不推进）
- Charts: Amplitudes（可交互） / Harmonics / Sum（可折叠）

### 区域（逻辑，非像素真值）

| 区域 | 内容 |
|---|---|
| Play / Charts | 三张纵向 ChartRectangle 对齐 x=65 |
| Control | 右侧 Panel：Fourier Series / Graph Controls / Measurement Tools |
| Bottom | TimeControl（仅 SPACE_AND_TIME 启用）+ ResetAll + Eraser（振幅图旁） |

### 需基线的状态（实现后补截图）

1. default sinusoid  
2. square + infinite harmonics  
3. custom + erase  
4. SPACE_AND_TIME + playing  
5. zoom out max  

---

## 3. Wave Game — 结构基线

| 态 | 描述 |
|---|---|
| Level select | 5 关卡按钮 + Info + Reset |
| In-level | Amplitudes / Harmonics / Sum（粉=answer，黑=guess）+ Check / Show / New + Erase |
| Solved | Smiley + 可选 Reward |

---

## 4. Wave Packet — 结构基线

| 态 | 描述 |
|---|---|
| default | Amplitudes + Components + Sum；envelope on；有限/无限取决于 spacing |
| width indicators on | 卡尺式宽度 |
| continuous waveform on | Amplitudes 连续高斯 |
| spacing=0 | Infinite components 文案；解析 Sum |

---

## 5. 颜色（源码入口）

`FMWColors.ts`：谐波色条、panel fill/stroke、sum 线、answer 粉等。  
实现时移植关键色；未截图校准的微差标 **[视觉近似]**。

---

## 6. Phase 2 结论

- 几何真值：**源码常量优先**。  
- 像素基线：**待补运行截图** → **[待确认：缺少原版运行截图]**。  
- Gap Closure（2026-09-03）后：测量工具 / 波包指示已可对照源码做结构 Visual QA，但仍**不得**声称「视觉已对齐」。

**Phase 2 状态：完成（证据不足项已标明）· 自动进入 Phase 3**
