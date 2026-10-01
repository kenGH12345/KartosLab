# V5 验收报告 — Responsive Layout / Overflow Reconstruction

**日期**：2026-09-06  
**阶段**：V5 **初步结束（可报告）** · **停止，不进入 V6**  
**验收口径**：**初步通过** — 布局策略落地、目标 viewport 无 overflow、V1–V4 行为保留、Model 冻结。  
**后续标记**：**[待改 / follow-up]** — 本阶段不封死；真实多机视口、像素对齐与若干 chrome 细节留待后续迭代（含 V6 截图 QA 及 V5 回修）。

**Model / Physics / Solver**：**零修改**（仅 View / layout / instruments chrome）

---

## 后续必须再改（勿当作最终布局）

| 项 | 说明 | 状态 |
|---|---|---|
| 真机/多窗口手测 | Desktop / Tablet / 窄窗仅有 widget 测试；需人工拖窗确认 hit-test | **[待确认]** |
| Fine/Coarse × scale（≥28） | 均匀缩放可接受作过渡；是否与 PhET 命中区完全一致待定 | **[待改]** |
| 右栏 236 vs 225 | Flutter chrome 补偿；若源码布局再校准可回看 | **[有意差异]** → 可再议 |
| Gauge / Heater / Units 视觉 | 约束修复优先于像素；V6 截图后再抠 | **[视觉近似]** → **[待改]** |
| Accordion 展开 + Laws 长列表 | ScrollView 可用；极端高度未封 | **[待确认]** |
| scale floor 0.55 letterbox | 非 PhET 原生范围 | **[有意差异]** |
| V6 像素截图 QA | 未开始 | **[待实现]** |

> **结论**：V5 报告可归档作阶段基线；**不要**把当前布局当作最终 sealed。回修入口：本表 + `V5_RESPONSIVE_REPORT.md` §I。

---

## A. Layout Policy

权威文档：`LAYOUT_POLICY.md` + `lib/gases_intro/view/layout_policy.dart`。

| 类别 | 含义 | 示例 | 为何固定 / 可变 |
|---|---|---|---|
| **A. Source-derived fixed** | PhET 逻辑尺寸 | layoutBounds 1008×618；pump 120×230；Fine/Coarse 40×40（逻辑） | GasPropertiesConstants / Node options |
| **B. Flexible** | 视口适配 | `layoutScale = min(availW/1008, availH/618)`，上限 1，下限 0.55 | 父级 constraints |
| **C. Anchored** | 相对 Container / layoutBounds | Gauge / Thermo / Pump / Heater / Erase / Reset / panels | IdealGasLawScreenView 规则（V2 未推翻） |
| **D. Viewport-constrained** | 工具拖动 | Stopwatch / CC：逻辑坐标 × scale；drag delta ÷ scale | DragBounds = layoutBounds |

**右栏宽**：逻辑 **236**（Flutter Material 40×40 Fine/Coarse）vs 源码 225 → **[有意差异]**。

**禁止**：ClipRect / OverflowBox / FittedBox / Transform.scale 掩盖 overflow；合并 ControlPanel ‖ Accordion；缩字体躲 overflow。

---

## B. 修改前后 viewport 对比

| Viewport | 修改前 | 修改后 |
|---|---|---|
| Desktop ≥1008×618 | FittedBox 整体缩放；右栏/控件偶发 RIGHT OVERFLOW；ListTile ink 断言 | `LayoutBuilder` + `fitScale≤1`；物理 shell = 逻辑×scale；scale=1 无 overflow **[布局稳定]** |
| Tablet ~1024×768 | 依赖 FittedBox；锚点与物理像素不一致 | scale≈1；anchors × scale；widget 测试通过 **[布局稳定]** |
| Narrow 720×480 | 右栏/Gauge UnitsCombo overflow；Heater Slider clamp 崩溃 | scale≈0.71；Gauge 随父宽；UnitsCombo ellipsis；Fine/Coarse×scale（≥28）；Heater track 显式长度 **[布局稳定]** |
| &lt;0.55 可用区 | 强行缩到不可读 | 钳制 0.55 + letterbox **[有意差异]** |

---

## C. Overflow 修复项

| 项 | 根因 | 修复 | 状态 |
|---|---|---|---|
| Home `FittedBox` | 用整体缩放掩盖约束问题 | 改为 `fitScale` + 物理 `SizedBox` | **[行为一致]** |
| 右栏 225 vs Fine/Coarse | Material chrome &gt; PhET maxWidth | `rightPanelWidthLogical=236` | **[有意差异]** |
| Gauge UnitsCombo | 固定 130 面宽 vs `gaugeW×scale`；Row 不伸缩 | `LayoutBuilder` + ellipsis Row | **[布局稳定]** |
| Heater `RotatedBox`+Slider | 无显式 track 长度 → clamp 断言 | `Expanded`+`LayoutBuilder` 显式 `SizedBox(trackLen)` | **[布局稳定]** |
| Fine/Coarse @ scale&lt;1 | 按钮仍 40，panel 已缩 | `layoutScale`，btn=`(40*s).clamp(28,40)` | **[有意差异]** 均匀缩放非删控件 |
| CheckboxListTile ink | DecoratedBox 遮 Material | `Material` 面板底色 | **[行为一致]** |
| Tools drag | 物理 delta 未换算 | `delta / layoutScale`（V5 边界） | **[行为一致]** |

---

## D. Anchor 保留情况

V2 Anchor Map **仍然成立**：

```
Screen → layoutBounds → GasContainer → instruments → ControlPanel ‖ ParticlesAccordion → toolsParent
```

| 锚点 | 状态 |
|---|---|
| MVT (645,475)×0.040 | **[源码一致]** × layoutScale |
| Gauge / Thermo ← containerNode | **[源码一致]** |
| Pump / ParticleType ← 右下 | **[源码一致]** |
| Heater ← bottom / widthMin | **[源码一致]** |
| ControlPanel ‖ Accordion（独立） | **[行为一致]** |
| Reset BR；tools mount (240,15)/(40,15) | **[源码一致]** |

未退回「一堆屏幕绝对 Positioned 无约束」；仍为 Stack(layoutBounds) + IdealScreenAnchors。

---

## E. Interaction regression

| 交互 | 结果 |
|---|---|
| Pump / Left wall / Lid drag | **[行为一致]**（未改语义；hit 随 scale） |
| Stopwatch / CC drag + bounds + reset | **[行为一致]**（仅 bounds/scale） |
| Accordion / ParticleType / Units | **[行为一致]** |
| Fine/Coarse / ±1±50 | **[行为一致]**（尺寸随 scale） |
| Flame/Ice / Reset / Play-Pause | **[行为一致]** |
| OopsDialog | **[行为一致]** |

计时 / 碰撞统计逻辑：**未改**（仍在 `ToolsController`）。

---

## F. Model / Physics 是否零修改

| 路径 | 本阶段 |
|---|---|
| `lib/gases_intro/model/**` | **0 编辑** |
| Physics / Solver / 公式 | **0 编辑** |
| View：`layout_policy` / anchors / home / shell / instruments / instrument_controls / tools drag API | 有改动 |

**结论**：**[Model 冻结] 成立**。

---

## G. 测试结果

```
flutter test test/gases_intro  →  24 passed
  (model 15 + layout_policy 3 + tools 3 + viewport 3)
flutter analyze lib/gases_intro → No issues found
```

Viewport widget 测试：1280×800 / 1024×768 / 720×480，shell 构建无 exception。

---

## H. 当前视觉差异

| 项 | 状态 |
|---|---|
| 右栏 236 vs 225 | **[有意差异]** |
| Fine/Coarse 随 scale（≥28） | **[有意差异]** 均匀适配 |
| Material Checkbox / PopupMenu chrome | **[视觉近似]** |
| Heater stove Path vs PhET PNG 合成 | **[视觉近似]**（V5 未重做 painter） |
| 像素级截图对齐 | **[待实现]** → V6 |

---

## I. V6 截图 QA 前仍存在的问题

1. **像素级** Gauge / Thermo / Pump / Heater 与 PhET 截图对比未做 → **[待实现]** V6  
2. ParticleType / Units 下拉视觉细节 → **[视觉近似]**  
3. 极窄/极矮窗口（scale 钳 0.55 letterbox）非 PhET 原生范围 → **[有意差异]**  
4. Accordion 展开 + Laws HoldConstant 长列表依赖 `SingleChildScrollView` → 可接受；超长文案未做截图回归 → **[待确认]**  
5. SVG eraser `<style/>` 控制台提示 → **[待确认]** 不影响布局  

---

## 变更文件（View only）

- `view/layout_policy.dart`、`ideal_screen_anchors.dart`、`tools_controller.dart`
- `screens/gases_intro_home.dart`
- `widgets/gases_intro_shell.dart`、`instruments.dart`、`instrument_controls.dart`、`play_area_layout.dart`、`tool_nodes.dart`
- `test/gases_intro/layout_policy_test.dart`、`viewport_layout_test.dart`
- `LAYOUT_POLICY.md`、本报告

---

**状态**：`v5_responsive_provisional`（初步结束，可报告）· **STOP — 不进入 V6** · **后续要改（见文首 follow-up 表）**
