# Geometry Calibration · Energy Skate Park

> Source-based geometry notes · closure pass 2026-09-03

| Item | Flutter | PhET | Tag |
|---|---|---|---|
| MVT scale | `EspConstants.mvtScale = 61.40` | ScreenView | **[源码一致]** |
| Measuring tape base | PNG 51×51 @ scale 0.8, rightBottom anchor | `MeasuringTapeNode` | **[源码一致]** |
| Tape crosshair | rgb(224,95,32), size 5, line 2 | `DEFAULT_CROSSHAIR_COLOR` | **[源码一致]** |
| Stopwatch background | ShadedRectangle rgb(80,130,230) | `StopwatchNode` options | **[源码一致]** |
| Stopwatch digits | 25px / 17px Trebuchet MS | ESP ScreenView formatter | **[源码一致]** |
| Gauge checkbox icon | arc + red needle, ~20px wide | `GaugeNode` @ scale 20/width | **[源码一致]** |
| Grid icon | 20×20, 3×3 lines | `createGridIcon` | **[源码一致]** |
| Pie icon | r=10, KE/PE colors | `createPieChartIcon` | **[源码一致]** |
| Path icon | 3 circles r=3, spacing 9 | `createSamplesIcon` | **[源码一致]** |
| Stick icon | track 19×6.8, dash [2.5,1.8] | `createStickingToTrackIcon` | **[源码一致]** |
| Tab icon scale | height 28, aspect 548/374 | Joist ScreenIcon | **[视觉近似]** |
| Probe | scale 0.5, rot π/2, rgb(103,80,113) | `SkaterPathSensorNode` | **[源码一致]** |
| Wire cubic | cp1=(dx/3, max(dy, 2h)), cp2=(-25,0) | `WireNode` | **[源码一致]** |
| Sensor wire anchor | play-area left y≈210 | Flutter layout (panel external) | **[视觉近似]** |
| Energy graph plot | h=141, w=TRACK_WIDTH×mvtScale | `EnergyGraphPanel` | **[源码一致]** |
| Graphs page layout | topPanel + sim + control | was Stack overlay | **[视觉已对齐]** |

**Not done**: automated pixel diff; 375/1024/1920 capture set.
