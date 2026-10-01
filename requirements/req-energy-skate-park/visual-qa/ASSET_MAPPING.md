# Energy Skate Park · Asset Mapping

> Flutter paths relative to project root. PhET paths relative to `energy-skate-park-main/energy-skate-park-main/`.

## Scenery

| PhET Asset | Source Path | Flutter Path | Used By | Tag |
|---|---|---|---|---|
| mountains.png | `images/mountains_png.ts` | `assets/energy_skate_park/mountains.png` | `BackgroundPainter` | **[源码直接使用]** |
| cementTextureDark.jpg | `images/cementTextureDark_jpg.ts` | `assets/energy_skate_park/cementTextureDark.jpg` | `BackgroundPainter` | **[源码直接使用]** |
| sky gradient | `BackgroundNode.ts` | `EspColors.skyTop/Bottom` | `BackgroundPainter` | **[几何绘制]** |
| earth fill | `BackgroundNode.ts` | `EspColors.ground` | `BackgroundPainter` | **[几何绘制]** |

## Skaters (usa default)

| PhET Asset | Source Path | Flutter Path | Used By | Tag |
|---|---|---|---|---|
| usaSkater1Headshot | `images/usa/usaSkater1Headshot_png.ts` | `assets/energy_skate_park/usa/usaSkater1Headshot.png` | `SkaterSelectionPanel` | **[源码直接使用]** |
| usaSkater1Left | `images/usa/usaSkater1Left_png.ts` | `assets/energy_skate_park/usa/usaSkater1Left.png` | `SkaterPainter` | **[源码直接使用]** |
| usaSkater1Right | `images/usa/usaSkater1Right_png.ts` | `assets/energy_skate_park/usa/usaSkater1Right.png` | `SkaterPainter` | **[源码直接使用]** |
| … skater2–6 | `images/usa/usaSkater{2-6}*_png.ts` | `assets/energy_skate_park/usa/` | selection + canvas | **[源码直接使用]** |
| usaDog* / usaCat* | `images/usa/usa{Dog,Cat}*_png.ts` | `assets/energy_skate_park/usa/` | animal slots 7–8 | **[源码直接使用]** |

Catalog: `lib/energy_skate_park/assets/esp_assets.dart` → `usaSkaterBundle`

## Other locales (extracted, not default runtime)

| Locale | Source dir | Flutter dir | Tag |
|---|---|---|---|
| africa | `images/africa/` | `assets/energy_skate_park/africa/` | **[源码直接使用·待 locale 切换]** |
| asia | `images/asia/` | `assets/energy_skate_park/asia/` | 同上 |
| latinAmerica | `images/latinAmerica/` | `assets/energy_skate_park/latinAmerica/` | 同上 |
| oceania | `images/oceania/` | `assets/energy_skate_park/oceania/` | 同上 |
| africaModest | `images/africaModest/` | `assets/energy_skate_park/africaModest/` | 同上 |

## Screen icons

| PhET Asset | Source Path | Flutter Path | Used By | Tag |
|---|---|---|---|---|
| introScreenIcon | `images/introScreenIcon_png.ts` | `assets/energy_skate_park/introScreenIcon.png` | bundle only | **[源码直接使用·待 Tab UI]** |
| measureScreenIcon | `images/measureScreenIcon_png.ts` | `assets/energy_skate_park/measureScreenIcon.png` | bundle only | 同上 |
| graphsScreenIcon | `images/graphsScreenIcon_png.ts` | `assets/energy_skate_park/graphsScreenIcon.png` | bundle only | 同上 |
| playgroundScreenIcon | `images/playgroundScreenIcon_png.ts` | `assets/energy_skate_park/playgroundScreenIcon.png` | bundle only | 同上 |

## Legacy PNG (license only)

| PhET Asset | Source Path | Flutter Path | Tag |
|---|---|---|---|
| attach.png | `images/attach_png.ts` | `assets/energy_skate_park/attach.png` | **[源码直接使用·JS 无引用]** |
| detach.png | `images/detach_png.ts` | `assets/energy_skate_park/detach.png` | 同上 |
| skater-icon.png | `images/skater-icon_png.ts` | `assets/energy_skate_park/skater-icon.png` | 同上 |

## Track presets

| PhET Visual | Source | Flutter | Tag |
|---|---|---|---|
| Parabola/Ramp/DoubleWell/Loop icons | `SceneSelectionRadioButtonGroup.ts` → TrackNode | `TrackSceneIcon` | **[几何绘制·源码一致]** |

## Measurement tools

| PhET Visual | Source | Flutter | Tag |
|---|---|---|---|
| Stopwatch toolbox icon | `ToolboxPanel.ts` → StopwatchNode | `PhetStopwatchIcon` | **[几何绘制]** |
| Stopwatch overlay | `StopwatchNode` | `StopwatchOverlay` | **[几何绘制·行为一致]** |
| Measuring tape icon | `MeasuringTapeNode.createIcon` | `PhetMeasuringTapeAssetIcon` → `measuringTape.png` | **[源码直接使用]** |
| Measuring tape overlay | `MeasuringTapeNode` | `MeasuringTapeOverlay` + PNG base | **[源码直接使用·行为一致]** |
| Probe | `ProbeNode` @ scale 0.5 | `ProbeNodePainter` | **[几何绘制·源码一致]** |
| Sensor wire | `WireNode` | `SensorWirePainter` | **[几何绘制·源码一致]** |

## scenery-phet (SHA 6035eb4)

| Component | Source | Flutter | Tag |
|---|---|---|---|
| measuringTape.png | `scenery-phet/images/measuringTape_png.ts` | `assets/energy_skate_park/scenery_phet/measuringTape.png` | **[源码直接使用]** |
| eraser.svg | `scenery-phet/images/eraser.svg` | `assets/energy_skate_park/scenery_phet/eraser.svg` | **[源码直接使用]** |
| Stopwatch skin | `scenery-phet/js/StopwatchNode.ts` | `PhetStopwatchIcon` LCD geometry | **[几何绘制·无 PNG]** |
| ProbeNode gradients | `scenery-phet/js/ProbeNode.ts` | `ProbeNodePainter` | **[几何绘制]** |
| WireNode cubic | `scenery-phet/js/WireNode.ts` | `SensorWirePainter` | **[几何绘制]** |

## Code references

- Asset catalog: `lib/energy_skate_park/assets/esp_assets.dart`
- Loader: `lib/energy_skate_park/assets/esp_asset_loader.dart`
- Extraction: `tools/extract_esp_phet_assets.py`
- Tests: `test/energy_skate_park/asset_test.dart`
