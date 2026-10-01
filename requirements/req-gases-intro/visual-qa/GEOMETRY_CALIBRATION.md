# GEOMETRY_CALIBRATION — Gases Intro

## Model MVT（未改 · 冻结）

| 量 | 源码 |
|---|---|
| scale | 0.040 px/pm |
| y flip | true |
| origin offset | (645, 475) |

## Instrument geometry（View）

| 组件 | 源码关键尺寸 |
|---|---|
| GaugeNode radius | 50 |
| Gauge span | π + π/4 |
| Gauge ticks | 21 |
| Pressure range | 0..20000 kPa |
| Thermometer | bulb 30, tube 100×20, glass 3, T 0..1000 K |
| BicyclePump height | ~200–230（viewport 内） |
| HeaterCooler DEFAULT_WIDTH | 120 |
| ShadedSphere highlight | (−0.4, −0.4), diameterRatio 0.5 |
| RIGHT_PANEL_WIDTH | **225**（内容宽，不含外边距） |

## Page layout（修 overflow 后）

```
AspectRatio(1008/618)
  Row(
    Expanded(SimulationViewport),
    SizedBox(width: 8),
    SizedBox(width: 225, child: ControlPanel ListView),
  )
```

SimulationViewport Column：instruments → Expanded(canvas|pump) → heater+time

**根因记录**：把 margin/padding 算进 225 → Particles 行 RIGHT OVERFLOW ~11px → 已分离 gap。

禁止为单张截图写死像素偏移；禁止整体 scale / clip 右缘修 overflow。
