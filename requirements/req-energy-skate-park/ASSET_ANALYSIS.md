# Energy Skate Park · Asset Analysis

> Source: `phet sourses/energy-skate-park-main/energy-skate-park-main` @ **1.6.0-dev.2**  
> Updated: 2026-09-03 · Asset fidelity pass

## 1. 取证方法 [已确认]

1. 枚举本地 sim 仓库 `images/**/*_png.ts`、`*_jpg.ts`（111 个 data URL 文件）
2. 读取 `EnergySkateParkImages.ts`、`BackgroundNode.ts`、`ToolboxPanel.ts`、`SceneSelectionRadioButtonGroup.ts`
3. 对照 `dependencies.json` 中 **scenery-phet** 依赖（本地未 checkout）
4. 用 `tools/extract_esp_phet_assets.py` 从 TS data URL **解码** 到 `assets/energy_skate_park/`
5. Flutter 侧 `EspAssets` + `EspAssetLoader` + `test/energy_skate_park/asset_test.dart`

## 2. Sim 自有资源清单

### 2.1 Scenery [已确认]

| 原始文件 | PhET 使用 | Flutter | 状态 |
|---|---|---|---|
| `images/mountains_png.ts` | `BackgroundNode.ts` scale 1.23 | `BackgroundPainter` + `EspAssets.mountains` | **[源码直接使用]** |
| `images/cementTextureDark_jpg.ts` | `BackgroundNode.ts` ground cement Pattern | `BackgroundPainter` tiled strip | **[源码直接使用]** |
| Sky gradient `#02ace4 → #cfecfc` | `BackgroundNode.ts` LinearGradient | `EspColors.skyTop/Bottom` | **[几何绘制]** |
| Ground fill `#93774c` | `BackgroundNode.ts` earth Rectangle | `EspColors.ground` | **[几何绘制]** |

### 2.2 Skater / Character [已确认]

| 类别 | 原始路径 | Flutter | 状态 |
|---|---|---|---|
| usa 8 角色 × 3 姿态 | `images/usa/*_png.ts` (24) | `assets/energy_skate_park/usa/` | **[源码直接使用]** |
| 其他 locale | africa/asia/latinAmerica/oceania/… (87) | 同路径已提取，运行时默认 usa | **[源码直接使用·待接入 locale]** |
| Headshot 选择 | `SkaterRadioButtonGroup.ts` scale 0.5 | `SkaterSelectionPanel` `Image.asset` | **[源码直接使用]** |
| Canvas skater | `SkaterNode.ts` left/right Image | `SkaterPainter` + `SkaterImageCache` | **[源码直接使用]** |
| 选中边框 | `EnergySkateParkColors.radioButtonSelectedStroke` | `EspColors.radioSelected` | **[视觉已对齐]** |

切换人物 **不改变** mass/energy/velocity（`SkaterImageSet` 仅 presentation；`setSelectedSkater` 不触物理）。

### 2.3 Track 缩略图 [已确认]

PhET **无 PNG 缩略图**。`SceneSelectionRadioButtonGroup.ts` 用 `TrackNode` + `rasterizeNode` 生成图标。

| 方案 | 状态 |
|---|---|
| Flutter `_MiniTrackPainter` 手绘曲线 | 已移除 |
| Flutter `TrackSceneIcon` = PremadeTracks + Hermite 采样 | **[几何绘制·与源码一致]** |

### 2.4 Screen Tab Icons [已确认]

| 原始 | PhET | Flutter 路径 | 状态 |
|---|---|---|---|
| `introScreenIcon_png.ts` | `IntroScreen.ts` homeScreenIcon | `EspAssets.introScreenIcon` | **[源码直接使用·待 UI 接入 Tab 图标]** |
| `measureScreenIcon_png.ts` | `MeasureScreen.ts` | `EspAssets.measureScreenIcon` | 同上 |
| `graphsScreenIcon_png.ts` | `GraphsScreen.ts` | `EspAssets.graphsScreenIcon` | 同上 |
| `playgroundScreenIcon_png.ts` | `PlaygroundScreen.ts` | `EspAssets.playgroundScreenIcon` | 同上 |

### 2.5 Legacy / License-only PNG [已确认]

| 文件 | license.json | JS 引用 | 状态 |
|---|---|---|---|
| `attach.png` | ✅ | 无引用 | **[源码直接使用·未接入 UI]** |
| `detach.png` | ✅ | 无引用 | 同上 |
| `skater-icon.png` | ✅ | 无引用 | 同上 |

Stick-to-track 图标在 PhET 为 **几何绘制**（`EnergySkateParkCheckboxItem.createStickingToTrackIcon`），非 attach.png。

### 2.6 Measurement Tools [已确认]

| 元素 | PhET 来源 | Flutter | 状态 |
|---|---|---|---|
| Stopwatch 工具箱图标 | `scenery-phet/StopwatchNode` rasterize | `PhetStopwatchIcon` 几何 | **[几何绘制·StopwatchNode 无 PNG]** |
| Stopwatch 拖拽体 | `StopwatchNode` | `StopwatchOverlay` LCD 样式 | **[几何绘制·行为一致]** |
| Measuring tape 图标 | `MeasuringTapeNode.createIcon` | `PhetMeasuringTapeAssetIcon` → `measuringTape.png` | **[源码直接使用]** |
| Measuring tape 拖拽体 | `MeasuringTapeNode` PNG base + crosshairs | `MeasuringTapeOverlay` | **[源码直接使用·行为一致]** |
| Energy Sensor 探针 | `ProbeNode` scale 0.5 rgb(103,80,113) | `ProbeNodePainter` | **[几何绘制·源码一致]** |
| Sensor 导线 | `SkaterPathSensorNode.ts` WireNode | `SensorWirePainter` | **[几何绘制·源码一致]** |
| Eraser 按钮 | `EraserButton.ts` eraser.svg | `PlaygroundBottomTools` SvgPicture | **[源码直接使用]** |

### 2.7 scenery-phet 依赖 [已确认]

`dependencies.json` → **scenery-phet** @ sha `6035eb49939c9a703b074e4b66b3422a96d18b06` 已 checkout 至 `phet sourses/scenery-phet/`。

已提取并接入：
- `measuringTape.png` ← `images/measuringTape_png.ts`
- `eraser.svg` ← `images/eraser.svg`

仍为几何绘制（源码无 PNG）：
- StopwatchNode（ShadedRectangle + NumberDisplay）
- ProbeNode 渐变细节（`ProbeNodePainter` 近似）
- WireNode（`SensorWirePainter` cubic 复刻）

提取脚本：`tools/extract_scenery_phet_assets.py` → `assets/energy_skate_park/scenery_phet/`

### 2.8 UI Checkbox Icons [已确认]

PhET `EnergySkateParkCheckboxItem` 全部为 **Scenery 几何**（pie/speed/grid/path/stick/ref height），非 PNG。

Flutter 控制面板仍为纯文字 Checkbox → **[资源迁移缺口·图标几何未移植]**（非 PNG 缺口，但视觉未对齐）。

## 3. 提取统计 [已确认]

| 类别 | 文件数 |
|---|---|
| Sim PNG/JPG (decoded) | **111** |
| usa runtime bundle | 24 + 2 scenery = 26 |
| 全 locale skater PNG | 102 |
| Screen icons | 4 |
| Legacy | 3 |

提取脚本：`tools/extract_esp_phet_assets.py`

## 4. 本轮修复 [已确认]

- 从 `*_png.ts` 重新解码全部 111 资源（含 cement、screen icons、全 locale skaters）
- 接入 `cementTextureDark.jpg` + mountains scale 1.23
- 移除 toolbox/stopwatch **Material Icons**，改用 PhET 几何图标
- Track 预设改为 `TrackSceneIcon`（PremadeTracks 采样，与 PhET TrackNode 图标同源）
- Skater 选择/grid 直接用 `Image.asset` PhET headshot PNG
- 新增 `asset_test.dart`（5 tests，含 scenery-phet bundle）

## 5. 剩余缺口

| 项目 | 标签 |
|---|---|
| StopwatchNode 完整皮肤（无 PNG，几何已近似） | **[几何绘制·可接受]** |
| Checkbox 几何图标（pie/speed/grid/…） | **[视觉近似]** |
| Tab 屏幕图标接入 KratosTabBar | **[待确认]** |
| 非 usa locale 运行时切换 | **[待确认]** |
| attach/detach/skater-icon.png 用途 | **[待确认·JS 无引用]** |
| 拖工具回 toolbox 收起 | **[行为缺口]** |

## 6. 测试 [已确认]

```
flutter test test/energy_skate_park  → 40 passed
dart analyze lib/energy_skate_park   → clean
```

物理核心 **未修改**。
