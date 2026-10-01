# V2 验收报告 — IdealGasLawScreenView Anchor Reconstruction

**日期**：2026-09-06  
**阶段**：V2 完成 · **停止，不进入 V3**  
**Model / Physics / Solver**：**零修改**

---

## A. PhET Anchor Map

见 `V2_ANCHOR_MAP.md`（完整表）。

状态：锚点规则取自源码 → **[源码一致]**（规则层）。像素级仪器外观 → **不宣称 [视觉已对齐]**。

---

## B. Flutter Layout Tree

见 `V2_ANCHOR_MAP.md` §B。核心：`Stack(layoutBounds)` + `IdealScreenAnchors`；容器为主要空间锚点；右栏仍为独立 `IdealControlPanel` ‖ `ParticlesAccordionBox`。

---

## C. 修改的 View 文件

| 文件 | 变更 |
|---|---|
| `lib/gases_intro/view/gases_intro_mvt.dart` | **新增** BaseModel MVT |
| `lib/gases_intro/view/ideal_screen_anchors.dart` | **新增** 源码锚点计算器 |
| `lib/gases_intro/widgets/play_area_layout.dart` | 启发式 fit → **源码 MVT** |
| `lib/gases_intro/widgets/gases_intro_shell.dart` | Row 分栏 → **Stack 锚点树**；Reset 独立；toolsParent 挂载点 |
| `lib/gases_intro/screens/gases_intro_home.dart` | 未改（仍 FittedBox+1008×618） |
| `lib/gases_intro/model/**` | **未改** |

---

## D. V1 功能回归结果

| V1 能力 | V2 | 状态 |
|---|---|---|
| ControlPanel ‖ ParticlesAccordion 分离 | 保留 | [行为一致] |
| Fine/Coarse ±1/±50 · 40×40 | 保留 | [行为一致] |
| Pump drag 120×230 → `pump()` | 保留 | [行为一致] |
| Left wall drag | 保留 | [行为一致] |
| Heater/Cooler + flame/ice | 保留 | [行为一致] |
| Hold Constant | 保留 | [行为一致] |
| Width / Stopwatch / Collision checkbox | 保留 | [行为一致] |
| Erase svg / Reset png | 保留（Reset 改锚到 BR） | [行为一致] |
| Play / Pause / Step | 保留（TimeControl 位） | [行为一致] |
| Home FittedBox | 保留 | [行为一致] |

---

## E. Model / Physics 是否零修改

**是。** 仅 View / layout / anchors。

---

## F. 当前剩余视觉问题

| 项 | 状态 |
|---|---|
| 仪器几何 vs scenery-phet 像素 | [待确认] 未做截图 QA；**非** [视觉已对齐] |
| Hose 末端精确贴合 hosePosition | [待确认] painter 仍近似路径 |
| ContainerWidthNode 高度取证（erase top） | [待确认] 用 +36 近似 widthNode |
| Panel / 控件 chrome | [有意差异] V2 不做 style |
| 局部 overflow（Fine/Coarse 宽） | [待确认] 留给 V5；未缩控件 |

---

## G. 当前剩余功能问题

| 项 | 状态 |
|---|---|
| 可拖 StopwatchNode / CollisionCounterNode | [待实现] V3（挂载点已就位） |
| ParticleTypeRadio 图标组 | [待实现] V4（现色点） |
| 单位 listbox / OopsDialog / lid 拖 | [待实现] V3/V4 |
| tools 读数仅 checkbox 开关 | [行为一致] 弱实现；非完整工具 |

---

## H. 测试结果

```
flutter test test/gases_intro     → 15 passed
flutter analyze lib/gases_intro   → 0 issues
```

---

## I. 是否存在功能回退

**否**（相对 V1 / B0 清单）。

---

## 验收对照

| 标准 | 结果 |
|---|---|
| Model 零修改 | ✓ |
| V1 功能 100% | ✓ |
| Panel 分离 | ✓ |
| Container 为主要锚点 | ✓ |
| 仪器锚到 container / layout 规则 | ✓ |
| V3 tools 挂载点 | ✓ |
| 非截图硬编码整页 | ✓（规则来自源码；widget 固有尺寸有证据） |
| 未删/缩控件消 overflow | ✓ |

**状态**：`v2_anchors_restored` · 等待确认后再开 V3。  
**禁止声明**：视觉完成 / [视觉已对齐]。
