# FUNCTIONAL_GAP_CLOSURE — Diffusion

## 源码确认（本轮 · Control / Time / Panel）

| 项 | gas-properties @ 7a52c48 | 标记 |
|---|---|---|
| 参数控件 | **NumberSpinner**（`GasPropertiesSpinner`），非 Slider | [源码一致] |
| 交互 | 上下箭头 + 数字显示；`deltaValue`；range；decimalPlaces=0 | [源码一致] |
| L/R 语义 | `leftSettings` / `rightSettings`；每行 QuantityControl = cyan+left + red+right | [源码一致] |
| 启用条件 | spinners `enabledProperty = hasDividerProperty` | [源码一致] |
| Divider 按钮 | **控制面板内** `DividerToggleButton`；N==0 禁用；文案 Remove/Reset Divider | [源码一致] |
| Data | `DataAccordionBox` **在容器上方**；`dataExpandedProperty` **默认 false** | [源码一致] |
| 时间 | `Stopwatch`（ps，1 位小数）；`StopwatchCheckbox` 控制可见；Clock→stopwatch.step(dt) | [源码一致] |
| TimeControl | Play/Pause/Step + Normal/Slow；**不**内嵌永久时间条 | [源码一致] |

**纠正**：截图对照曾假设「原版是 Slider、Flutter 是 stepper」。Lock 源码明确为 NumberSpinner。Flutter 已按 Spinner 实现（含数字输入 + 上下步进）。**不得**把 Spinner→Slider 当成补缺口。

## 已实现

| 项 | 标记 |
|---|---|
| 核心粒子 / 碰撞 / Clock | [源码一致] / [物理一致] |
| Particle Flow Rate | [源码一致] |
| NumberSpinner L/R 四参 | [行为一致] |
| Data accordion 默认折叠 | [行为一致] |
| Stopwatch 显示 + checkbox | [行为一致] |
| Divider 在控制面板 + N==0 禁用 | [行为一致] |
| Audio | **[源码一致：原版无音效]** |

## 仅保留尾标

| 项 | 标记 |
|---|---|
| Stopwatch scenery-phet 完整 chrome / 拖拽 | [视觉近似] |
| Accordion / Spinner 像素级样式 | [视觉近似] |
| Region 网格碰撞优化 | [有意差异] |
| Home icon | [有意差异] |
| 与原版 runtime 像素 overlay | [待确认] |

## 禁止已遵守

- 未迁 Ideal Gas / Collision Lab
- 未把 Slider 误标为原版交互
- 未删除源码存在的 Data accordion（仅纠正位置与默认折叠）
