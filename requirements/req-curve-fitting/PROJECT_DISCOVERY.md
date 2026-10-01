# PROJECT_DISCOVERY — Curve Fitting

## 本地版本 [已确认]

| 字段 | 值 |
|---|---|
| package.json `name` | `curve-fitting` |
| package.json `version` | **`1.1.0-dev.0`** |
| dependencies.json comment | `curve-fitting 1.0.0-dev.19 Wed Sep 04 2019 ...` |
| dependencies.json `curve-fitting.sha` | `cb6f00b03721427040808eaca67575dafb6ad13e` |
| 本地路径 | `phet sourses/curve-fitting-main/curve-fitting-main` |
| 策略 | **不以官网 latest / GitHub main 替换本地源码** |

## Screen [已确认：单 Screen]

| 项 | 值 | 证据 |
|---|---|---|
| Screen count | **1** | `curve-fitting-main.js`：`new Sim(..., [ new CurveFittingScreen() ], ...)` |
| Screen name | Curve Fitting | `CurveFittingStrings['curve-fitting'].title` |
| Model ownership | 每屏独立 `CurveFittingModel` | `CurveFittingScreen` constructor |
| Default | 该唯一 Screen | — |
| Background | `rgb(187, 230, 246)` | `CurveFittingScreen.js` |

## 源码根目录

```
js/curve-fitting-main.js          # 入口
js/curve-fitting/
  CurveFittingScreen.js
  CurveFittingConstants.js
  CurveFittingQueryParameters.js  # snapToGrid default false
  model/  CurveFittingModel, Curve, Point, FitType, CurveShape, createPoints
  view/   ScreenView, Graph, Curve, Residuals, Bucket, Point, Fit, Order,
          ViewOptions, Deviations, Equation, Barometers, CoefficientSlider
doc/model.md, doc/implementation-notes.md
curve-fitting-strings_en.json
```

## 依赖（PhET libs）

`axon`, `dot`, `joist`, `kite`, `scenery`, `scenery-phet`, `sun`, `twixt`, `phetcommon`, `phet-core`, …；sim 特有 preload：KaTeX（方程排版，Flutter 用 RichText/Text 等价）。

## KARTOSLAB 工程要点

| 项 | 发现 |
|---|---|
| 工程名 | `kratos` 1.0.0+1 |
| Home taxonomy | 仅 **物理 / 化学**；无「数学」一级 |
| 归类决策 | **物理 → 力学**（对齐 Vector Addition；不改 taxonomy）[已确认策略] |
| 可复用 L0 | `NineGridLayout`；`common/chart` **语义不匹配**（时间序列），图区自研 |
| 已有 curve-fitting 代码 | **无** |
| 代码落点 | `lib/curve_fitting/` + `test/curve_fitting/` |

## 功能清单（Phase 0 概览）

| 域 | 状态 |
|---|---|
| DataPoint + delta + drag | [已确认] 源码存在 |
| Linear/Quadratic/Cubic | [已确认] order ∈ {1,2,3} |
| Best Fit / Adjustable Fit | [已确认] FitType |
| Residuals 竖线 | [已确认] ResidualsNode |
| r² + reduced χ² | [已确认] Curve.updateRAndChiSquared；属性名 chiSquared = reduced χ² |
| Graph MVT inverted-Y | [已确认] scale 25.5 |
| Bucket 拖出点 | [已确认] 无图上初始点 |
| Assets | [已确认] 主要为几何绘制 + scenery-phet Bucket/Arrow/InfoButton；无大量 PNG |

## 暂停条件检查

| 条件 | 触发？ |
|---|---|
| 修改 common API | 否 |
| 修改全局 Theme / Navigation / taxonomy | 否（仅追加一张 Home 卡） |
| 跨 sim regression framework | 否 |
| 无法确认 fitting / statistics | 否 — Curve.js 完整 |

→ **自动继续 Phase 1–12**
