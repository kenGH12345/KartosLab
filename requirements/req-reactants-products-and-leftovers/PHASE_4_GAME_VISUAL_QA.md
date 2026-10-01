# PHASE_4 — Game Visual QA

日期：2026-09-22  
判定标签按 85-phet-original-assets 要求。

## Checklist

| Scene | [原版资源一致] | [布局已对齐] | [动态绘制已对齐] | Notes |
|---|---|---|---|---|
| Level selection | PASS* | PASS | PASS | *无额外 bitmap；按钮为 source-equivalent |
| Level 1 play | PARTIAL | PASS | PASS | 部分分子 FormulaText chip |
| Level 2 play | PARTIAL | PASS | PASS | After 交互 |
| Level 3 play | PARTIAL | PASS | PASS | 双产物 After |
| Question mark | PASS | PASS | PASS | `?` 文本 |
| Answer spinner | PASS | PASS | PASS | RpalNumberSpinner |
| Correct face | APPROX | PASS | APPROX | FaceWithPoints CustomPainter |
| Incorrect face | APPROX | PASS | APPROX | frown |
| Retry / Show Answer / Next | PASS | PASS | PASS | GameButtons |
| Finished / stars | APPROX | PASS | APPROX | LevelCompleted 语义重建 |
| Reset All | PASS | PASS | PASS | KratosResetAllButton L0 |
| Status bar | APPROX | PASS | PASS | FiniteStatusBar 等价 |
| RandomBox | APPROX | PASS | APPROX | VERSION_DELTA |
| Hide molecules overlay | APPROX | PASS | APPROX | CustomPainter eye-slash |

## Viewport

- layoutBounds：835×504（与 Sandwiches/Molecules 同 SCREEN_VIEW，但 Game boxes 330×240）
- FittedBox contain 缩放

## Substituted Assets

**0**（无第三方/Material 冒充 PhET bitmap）

## P0 Visual

无阻断：可选关、可答题、可反馈、可 Next、可 Reset。

## P1 Visual

- RandomBox 非 scenery 随机布局算法逐像素一致
- 非 Molecules 七分子以外使用 FormulaText chip

## P2 Visual

- Face / Reward / StatusBar chrome 细节
- Level 按钮图标未用完整分子节点（文本示意 ?→HCl 等）
