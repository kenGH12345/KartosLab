# Energy Skate Park · Asset Mapping

> Canonical mapping · Flutter paths relative to project root.  
> PhET paths relative to `energy-skate-park-main/energy-skate-park-main/` + `scenery-phet/`.

## Scenery

| PhET Asset | Source Path | Flutter Path / Painter | Used By | Tag |
|---|---|---|---|---|
| mountains.png | `images/mountains_png.ts` | `assets/energy_skate_park/mountains.png` | `BackgroundPainter` | **[源码直接使用]** |
| cementTextureDark.jpg | `images/cementTextureDark_jpg.ts` | `assets/energy_skate_park/cementTextureDark.jpg` | `BackgroundPainter` | **[源码直接使用]** |
| sky gradient | `BackgroundNode.ts` | `EspColors.skyTop/Bottom` | `BackgroundPainter` | **[几何绘制]** |
| earth fill | `BackgroundNode.ts` | `EspColors.ground` | `BackgroundPainter` | **[几何绘制]** |

## Skaters (usa default)

| PhET Asset | Source Path | Flutter Path | Used By | Tag |
|---|---|---|---|---|
| usaSkater1–6 * | `images/usa/*_png.ts` | `assets/energy_skate_park/usa/` | `SkaterSelectionPanel`, `SkaterPainter` | **[源码直接使用]** |
| usaDog / usaCat | `images/usa/usa{Dog,Cat}*_png.ts` | `assets/energy_skate_park/usa/` | slots 7–8 | **[源码直接使用]** |

Catalog: `lib/energy_skate_park/assets/esp_assets.dart` → `usaSkaterBundle`

## Screen tab icons

| PhET Asset | Source Path | Flutter | Used By | Tag |
|---|---|---|---|---|
| introScreenIcon + skater overlay | `IntroScreenIcon.ts` | `EspScreenTabIcon.intro` + PNG + skater1 right | `EnergySkateParkHome` Tab | **[源码直接使用]** |
| measureScreenIcon | `measureScreenIcon_png.ts` | `EspScreenTabIcon.measure` | Tab | **[源码直接使用]** |
| graphsScreenIcon | `graphsScreenIcon_png.ts` | `EspScreenTabIcon.graphs` | Tab | **[源码直接使用]** |
| playgroundScreenIcon + skater | `PlaygroundScreenIcon.ts` | `EspScreenTabIcon.playground` + cat right | Tab | **[源码直接使用]** |

## Visibility checkbox icons

| PhET Visual | Source | Flutter | Used By | Tag |
|---|---|---|---|---|
| Pie chart | `EnergySkateParkCheckboxItem.createPieChartIcon` | `EspCheckboxIcons.pieChart` | `ControlPanel` | **[几何绘制·源码一致]** |
| Speed gauge | `GaugeNode` scale 20/width | `EspCheckboxIcons.speedometer` | `ControlPanel` | **[几何绘制·源码一致]** |
| Grid | `createGridIcon` 20×20 | `EspCheckboxIcons.grid` | `BottomVisibilityPanel` | **[几何绘制·源码一致]** |
| Path samples | `createSamplesIcon` | `EspCheckboxIcons.path` | `ControlPanel` (Measure) | **[几何绘制·源码一致]** |
| Stick to track | `createStickingToTrackIcon` | `EspCheckboxIcons.stickToTrack` | `ControlPanel` | **[几何绘制·源码一致]** |
| Reference height | `createReferenceHeightIcon` | `EspCheckboxIcons.referenceHeight` | `BottomVisibilityPanel` | **[几何绘制·源码一致]** |

## Track presets

| PhET Visual | Source | Flutter | Tag |
|---|---|---|---|
| Parabola/Ramp/DoubleWell/Loop | `PremadeTracks` → TrackNode | `TrackSceneIcon` | **[几何绘制·源码一致]** |

## Measurement tools

| PhET Visual | Source | Flutter | Tag |
|---|---|---|---|
| Stopwatch toolbox icon | `StopwatchNode` rasterize @0.4 | `PhetStopwatchIcon` | **[几何绘制]** |
| Stopwatch overlay | `StopwatchNode` fonts 25/17, rgb(80,130,230) | `StopwatchOverlay` | **[几何绘制·源码一致]** |
| Return to toolbox | `EnergySkateParkScreenView.ts` intersectsBounds | `ToolboxReturn` + controller | **[行为一致·无动画]** |
| Measuring tape icon | `MeasuringTapeNode.createIcon` | `PhetMeasuringTapeAssetIcon` | **[源码直接使用]** |
| Measuring tape overlay | `MeasuringTapeNode` | `MeasuringTapeOverlay` | **[源码直接使用·行为一致]** |
| Probe | `ProbeNode` scale 0.5 | `ProbeNodePainter` | **[几何绘制·源码一致]** |
| Sensor wire | `WireNode` | `SensorWirePainter` | **[几何绘制·源码一致]** |
| Eraser | `EraserButton.ts` eraser.svg | `PlaygroundBottomTools` SvgPicture | **[源码直接使用]** |

## scenery-phet (SHA 6035eb4)

| Component | Source | Flutter | Tag |
|---|---|---|---|
| measuringTape.png | `images/measuringTape_png.ts` | `assets/energy_skate_park/scenery_phet/` | **[源码直接使用]** |
| eraser.svg | `images/eraser.svg` | `assets/energy_skate_park/scenery_phet/` | **[源码直接使用]** |
| StopwatchNode | pure geometry | `StopwatchOverlay` / `PhetStopwatchIcon` | **[几何绘制·无 PNG]** |

## Legacy / unused in JS

| Asset | Flutter Path | Tag |
|---|---|---|
| attach / detach / skater-icon | `assets/energy_skate_park/*.png` | **[源码直接使用·JS 无引用]** |

## Extraction & tests

- Sim assets: `tools/extract_esp_phet_assets.py`
- scenery-phet: `tools/extract_scenery_phet_assets.py`
- Catalog: `lib/energy_skate_park/assets/esp_assets.dart`
- Tests: `test/energy_skate_park/asset_test.dart`, `functional_closure_test.dart`

## Still open

| Item | Tag |
|---|---|
| Non-usa locale runtime switch | **[待实现]** |
| Bar graph checkbox icon (PhET uses separate control) | **[视觉近似]** — text only |
| Play/pause on stopwatch node (ESP includes buttons) | **[行为近似]** — reset only on overlay |
| attach/detach PNG usage | **[待确认·JS 无引用]** |

Mirror: `requirements/req-energy-skate-park/visual-qa/ASSET_MAPPING.md`
