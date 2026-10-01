# ARCHITECTURE_PLAN — Curve Fitting

## 决策

- **不**创建跨 simulation statistics / regression framework → 不触发暂停。
- 图区自研于 `lib/curve_fitting/`；不复用 `common/chart`（时间序列语义不匹配）。
- Home：物理 → 力学（不改 taxonomy）。

## 分层

```
DataPoint / DataSet
    ↓
CurveFittingModel (FitType, order, sliders, view flags)
    ↓
RegressionSolver (Best Fit)  |  sliders (Adjustable)
    ↓
CurveModel.coefficients
    ↓
StatisticsSolver → r², reduced χ²
    ↓
CfRenderBuilder → CfRenderData
    ↓
Painters (Graph / Curve / Residual / Points)  — 只消费 RenderData
    ↓
Widgets / Screen
```

| 组件 | 拥有？ | 备注 |
|---|---|---|
| FitModel 参数 | CurveFittingModel.sliderValues + CurveModel.coefficients | Best 时 coefficients 由 solver 写入；Adjustable 从 slider 拷贝 |
| Statistics | **derived** | 每次 updateFit 重算 |
| Painter | 无数学 | 禁止 best fit |

## MathCoordinateTransform

`createSinglePointScaleInvertedYMapping(origin, viewCenter, 25.5)`  
**所有 Y 翻转集中于此**。

## UI 结构（单屏）

```
Scaffold(AppBar)
  NineGridLayout(
    center: FittedBox(1024×618)
      CfScreenBody:
        GraphArea + Curve + Residuals + Points/Bucket
        Equation overlay
        Left: Deviations (χ² / r² barometers)
        Right: ViewOptions + Order + Fit(+sliders)
        ResetAll
  )
```

## 文件地图

```
lib/curve_fitting/
  curve_fitting_{constants,colors,strings}.dart
  format_number.dart
  model/   data_point, data_set, fit_type, curve_model, curve_fitting_model
  solver/  matrix_solver, regression_solver, statistics_solver, chi_barometer_color
  transform/math_coordinate_transform.dart
  render/  cf_render_data, cf_render_builder
  painters/
  widgets/
  interaction/
  screens/ curve_fitting_home.dart, cf_screen_body.dart
```

## 风险

| 风险 | 缓解 |
|---|---|
| Matrix.solve 数值差异 | 同 det epsilon + 高斯消元；完美多项式测试钉死 |
| Bucket 视觉 | 几何近似 scenery-phet；标 [视觉近似] 若无像素级 |
| 原版 runtime 截图 | [待确认：缺少原版运行截图] |
