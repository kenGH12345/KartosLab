# ASSET_MAPPING — Curve Fitting

> 本 sim 几乎无位图资源；映射以源码几何 / 字符串为准。

| PhET 资源 / 节点 | Flutter 对应 | 策略 |
|---|---|---|
| `BucketFront` / `BucketHole` | `BucketWidget` CustomPainter | **[视觉近似]** 梯形桶身 + 椭圆洞；颜色 `rgb(65,63,117)` |
| `ArrowNode` (axes) | `GraphAreaPainter._drawArrowHead` | 几何双箭头 |
| `InfoButton` | `Icons.info_outline` | 功能等价，非像素级 |
| `ExpandCollapseButton` | Material expand icons | 功能等价 |
| `ResetAllButton` | `ElevatedButton` "Reset All" | **[视觉近似]** 非橙色圆形 ResetAll |
| Point fill | `CurveFittingColors.pointFill` | 一致 |
| Panel fill | `CurveFittingColors.panelBackground` | 一致 |
| KaTeX / FormulaNode | `Text.rich` / monospace 公式 | **[视觉近似]** |
| Strings EN | `CurveFittingStrings` | 自 `curve-fitting-strings_en.json` |

无 PNG/SVG 资源包需拷贝。[已确认]
