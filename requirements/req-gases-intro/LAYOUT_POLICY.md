# LAYOUT_POLICY — Gases Intro (V5)

> **状态**：V5 **初步结束**（可作阶段基线）· **`follow_up_required`** · 非最终 sealed。  
> 后续要改清单见 `V5_RESPONSIVE_REPORT.md` 文首。

见代码：`lib/gases_intro/view/layout_policy.dart`  
验收：`V5_RESPONSIVE_REPORT.md`

## 坐标空间

1. **逻辑空间** = PhET `layoutBounds` **1008 × 618**（V2 Anchor Map 定义于此）。
2. **物理空间** = `layoutScale ×` 逻辑空间。
3. `layoutScale = min(availW/1008, availH/618)`，**上限 1**，**下限 0.55**（更矮/窄 → letterbox，**[有意差异]**）。
4. 谁锚定谁不变：Container / instruments / panels / tools（V2）。

## 四类尺寸

| Kind | 含义 | 示例 | 为何这个值 |
|---|---|---|---|
| **A. Source-derived fixed** | 源码 Node 固有逻辑尺寸 | pump 120×230；gauge face ~130；Fine/Coarse 40×40；margins 20 | GasPropertiesConstants / scenery options |
| **B. Flexible** | 随视口 | shell 物理宽高 = 1008×618 × scale | 父级 `LayoutBuilder` constraints |
| **C. Anchored position** | 相对 Container / layoutBounds | gauge←containerRight；heater←bottom；panel←layoutRight−margin | IdealGasLawScreenView |
| **D. Viewport-constrained** | 拖动夹紧 | Stopwatch/CC 在 layoutBounds 内；delta÷scale | DragBoundsProperty |

## 右栏

- PhET `RIGHT_PANEL_WIDTH` = 225。
- Flutter Fine/Coarse Material 40×40 需要约 200+padding → 逻辑宽 **236** → **[有意差异]**。
- ControlPanel ‖ ParticlesAccordion **保持独立**；spacing 15×scale。
- Fine/Coarse 物理边长 `(40×scale).clamp(28,40)`：均匀缩放，不是为 overflow 单独缩控件。

## Overflow 原则

通过：**父 constraints → child intrinsic → available space → layout relationship**。

禁止：ClipRect / OverflowBox / FittedBox / Transform.scale 掩盖；缩字体躲 overflow；删控件；合并两面板。

仅当源码明确 clipping 时才允许 Clip。

## Viewport 预期

| Viewport | 预期 |
|---|---|
| Desktop ≥1008×618 | scale=1 |
| Tablet ~1024×768 | scale≈1 |
| Narrow ~720×480 | scale↓，居中；控件随 scale |
| 可用区 &lt; 0.55×逻辑 | scale=0.55 letterbox **[有意差异]** |
