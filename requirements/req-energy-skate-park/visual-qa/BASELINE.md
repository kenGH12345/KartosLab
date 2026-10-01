# Phase 2 / Visual QA · Energy Skate Park

> Updated 2026-09-03 · Layout alignment vs PhET reference screenshots

## Original PhET reference (user-provided)

| Screen | Reference PNG | Key layout |
|---|---|---|
| Intro | `reference/intro.png` | 左侧 Energy 柱状图 · 右侧控制面板 · 右下工具箱 · 左下 Grid/参考高度 |
| Measure | `reference/measure.png` | 左侧紫色 Energy 传感器面板 + 探针 · 右下工具箱 |
| Graphs | `reference/graphs.png` | 左上 Energy Graph 折叠面板 · 右下工具箱 |
| Playground | `reference/playground.png` | 左侧 Energy 柱 · 底部中央轨道工具 · 右下工具箱 |

Official sim: https://phet.colorado.edu/sims/html/energy-skate-park/latest/energy-skate-park_all.html

## Layout alignment (2026-09-03)

| Element | PhET | Flutter (after layout pass) | Tag |
|---|---|---|---|
| Energy bar | Left sidebar accordion | `EnergyBarPanel` left of play area | **[视觉已对齐]** |
| Energy sensor | Left purple panel | `MeasureSensorPanel` left slot | **[视觉近似]** — wire/probe styling simplified |
| Energy graph | Short horizontal accordion above track | `EnergyGraphPanel` as `EspScreenBody.topPanel` | **[视觉已对齐]** — page layout, not overlay |
| Toolbox | Bottom of right panel | `ToolboxPanel` in `ControlPanel` | **[视觉已对齐]** |
| Grid / Reference Height | Bottom-left bar | `BottomVisibilityPanel` | **[视觉已对齐]** |
| Track presets | Square icon buttons | `TrackSceneSelector` mini-track icons | **[视觉近似]** |
| Playground track tools | Bottom center eraser + track | `PlaygroundBottomTools` | **[视觉近似]** |
| Time controls | Bottom center bar | `TimeControl` in bottom row | **[视觉近似]** |

## Screenshot checklist

| # | State | Flutter capture | Original PhET | Status |
|---|---|---|---|---|
| 1 | Intro — energy bar + controls | [待确认] | `reference/intro.png` | Layout structurally aligned |
| 2 | Measure — sensor panel + probe | [待确认] | `reference/measure.png` | Left panel added |
| 3 | Graphs — energy graph overlay | [待确认] | `reference/graphs.png` | Overlay on play area |
| 4 | Playground — flat ground + tools | [待确认] | `reference/playground.png` | Bottom tools added |
| 5 | Stopwatch placed in play area | [待确认] | intro.png toolbox | Draggable overlay |
| 6 | Measuring tape + endpoints | [待确认] | intro.png | Model distance in meters |
| 7 | Skater selection 8 characters | [待确认] | intro.png grid | Headshot grid 4×2 |

Flutter-side PNGs still **[待确认]** until manual capture in running app.

## Visual anchors (source-based)

| Element | Source | Flutter implementation | Tag |
|---|---|---|---|
| Toolbox icons | `ToolboxPanel.ts` | Right panel bottom; hide icon when tool active | **[行为一致]** |
| Stopwatch position | `StopwatchNode` view coords | `MeasurementTools.stopwatchViewPosition` | **[行为一致]** |
| Tape endpoints | `measuringTapeBase/TipPositionProperty` | Model `EspVec` + MVT | **[行为一致]** |
| Reference line 9.5 m | `ReferenceHeightLine.ts:42` | `referenceHeightLineModelLength` | **[源码一致]** |
| 8 skater headshots | `SkaterImageSet.ts` | `assets/energy_skate_park/usa/*` | **[视觉已对齐]** |
| Skater registration | `SkaterNode.ts` bottom center | `SkaterPainter` rect at (-w/2, -h) | **[源码一致]** |

## Remaining deltas

- Sensor wire anchor (panel in left column vs PhET in-play-area body): **[视觉近似]**
- Pixel overlay diff vs reference PNGs: **[待确认]** — manual Flutter capture
- Delete/Backspace keyboard return: **[待实现]**

## Closure pass (2026-09-03)

| Item | Status |
|---|---|
| Return tool to toolbox | **[行为一致]** |
| Checkbox geometry icons | **[几何绘制·源码一致]** |
| Screen tab PNG icons | **[源码直接使用]** |
| Stopwatch rgb(80,130,230) + fonts 25/17 | **[几何绘制·源码一致]** |
| Sensor WireNode | **[几何绘制·源码一致]** |

## Graphs Screen layout fix (2026-09-04)

| Item | Status |
|---|---|
| Graph as page `topPanel` (not Stack overlay) | **[视觉已对齐]** |
| Plot 141 × (10×61.4) geometry | **[源码一致]** |
| Capture `graphs-current.png` + rects JSON | **[已确认]** |
| Detail | `visual-qa/GRAPHS_SCREEN_CALIBRATION.md` |

## Method

1. Source geometry / MVT rule (scale 61.40, y flip)
2. Compare structural layout against `reference/*.png`
3. Flutter screenshot after asset load for pixel QA

Do **not** claim pixel parity without overlay diff evidence.
