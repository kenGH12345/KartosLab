# FINAL QA-7 Report

比较顺序仍是本地 source，然后几何，然后 paint，然后交互，最后才是官方 1.2.5 运行画面。官方画面只作证据。本地包是 bending-light `1.3.0-dev.0`。官方运行时是 1.2.5。

## Completed

- Ray / Wave 不再是 Material 按钮。调用点是 `LaserTypeAquaRadioButtonGroup`：`AquaRadioButton` 半径 6、字号 12、垂直间距 10。Flutter 是 `PhetAquaRadio`。
- Checkbox 不再是 Material `Checkbox`。调用点 `boxWidth` 15、间距 5。勾是两段线，不是 `Icons.check`。Normal / Angles 图标按 `NormalLine` 与 `AngleIcon` 画。
- TimeControl 不再是 Material `TextButton` 行。布局跟 `TimeControlNode`：速度单选在左，间距 10，play 半径 20.8，step 半径 15。回调仍是 `model.togglePlaying` / `model.stepOnce` / `model.setSpeed`。View 没有第二套时钟。
- 工具箱图标不再是文字 chip，也不再是泛化轮廓。Intensity / Velocity / Wave / Prism 按各自 source class 的 body、渐变、读数和 scale 分层。拖出预览用的是同一个 child。
- 折射率滑条、波长滑条、介质下拉、加减按钮、面板外壳、工具箱锚点、图渐变与高光、视口、物理都没有重调。
- Home 未改。

清单：`FINAL_SCENERY_NODE_MAPPING.md`。`sun` 三项：`SUN_CONTROL_SOURCE_AUDIT.md`。逐项判定：`FINAL_SOURCE_FIDELITY.md`。

## Remaining Source Mismatch

这些不是 P2。source 里有对应子节点，Flutter 还没有等价结构。

| Item | Source | Flutter |
| --- | --- | --- |
| Intensity probe | `ProbeNode` kite path | `ProbeGlyph` 仍是圆加手柄 |
| Velocity placed scale | `MoreToolsScreenView` 放置节点 `scale: 2` | 已放置视图仍是 body scale 0.7 |
| Wave wires | `WaveSensorNode` 始终加两条 `WireNode` | 工具箱图标没画线 |
| Prism knob | `PrismNode` 在 shape 有 reference point 时加 `knob.png`，`isIcon` 也加 | 工具箱图标没有旋钮 |
| Prism fill | `mediumColorFactory.getColor(n)`，alpha 0.5 | 固定色 `0xFFB3E5FC`，alpha 0.5 |

## Version Delta

本地树没有 `sun/`。这些没有按 1.2.5 截图补造。

| Item | Verdict |
| --- | --- |
| Slider thumb gradient | VERSION_DELTA |
| ComboBox list highlight | VERSION_DELTA |
| ArrowButton bevel | VERSION_DELTA |
| Aqua radio pigment | VERSION_DELTA |
| Checkbox 精确 path | VERSION_DELTA |
| RoundPushButton 立体面 | VERSION_DELTA |
| 背景条 / navbar | VERSION_DELTA。1.2.5 有，本地 1.3.0 舞台没有，没有画假导航条 |

## Control Mapping

| UI | Source | Flutter | Verdict |
| --- | --- | --- | --- |
| Ray / Wave | `AquaRadioButton` in `LaserTypeAquaRadioButtonGroup` | `PhetAquaRadio` | SOURCE MATCH（水色填充 VERSION_DELTA） |
| Checkbox | sun `Checkbox`，调用点 15 / 5 | `PhetCheckbox` | 盒 SOURCE MATCH，勾 path VERSION_DELTA |
| Normal / Angles | `NormalLine` / `AngleIcon` | `NormalLineIcon` / `AngleMarkIcon` | SOURCE MATCH |
| TimeControl | `TimeControlNode` + `PlayPauseStepButtonGroup` | `SourceTimeControl` | 布局与图标比例 SOURCE MATCH；按钮立体面 VERSION_DELTA |

没有 `Checkbox`、`CheckboxListTile`、`Switch`、`ElevatedButton`、`IconButton` 作为这些控件的最终视觉。Demo hub 上的屏幕切换按钮不在本 sim 控件里，也不是 Home。

## Toolbox Mapping

| UI | Source class | Scale | Flutter |
| --- | --- | --- | --- |
| Intensity | `IntensityMeterNode` | icon 0.45，body 0.6 | `IntensityMeterGraphic` |
| Velocity | `VelocitySensorNode` | icon 1.2，body 0.7，placed 2 | `VelocitySensorGraphic` 只覆盖工具箱 scale |
| Wave Sensor | `WaveSensorNode` | icon 0.4，body 0.93 | `WaveSensorGraphic` |
| Prism | `PrismNode` | height 55 | `prismIconGeometry` |
| Protractor | `ProtractorNode.createIcon` | 0.24 of 302 | `protractor.png` |

工具箱显示的是工具节点的分层结构，不是文字 chip。拖出仍跟手：按下出现同一 child，松手在工具箱外才启用，已启用的不再出现第二份。Hit 区域用 `FittedBox` 收成视觉尺寸，避免 `Transform.scale` 留下过大的命中框。

## Graph Mapping

未改。外框仍是 135×100、scale 0.93，渐变 `#5EB4DE` → `#005B86`。`FINAL7_GRAPH.png` 在图表内取样：灰边 `(222,222,222)`，中心白，下方蓝 `(29,119,175)`。不是整块纯白。波形公式未动。

## Interaction Regression

Widget 测试覆盖，不是只看像素：

- Ray / Wave：选中、切换、复位。
- Checkbox：未选、选中、点外面不切换、复位。
- TimeControl：默认播放；Pause 后 Step 推进 model time；播放中 Step 不推进；reset 后 `time == 0` 且 `isPlaying == true`。没有 Flutter `Timer`。
- 工具箱：source scale、拖出、放下、防重复。
- Prism 图标：高度 55，方形旋转中心接近宽的一半与 27.5。

Intro 光束区域平均差仍约 0.55，比值 0.009。介质、波长、reset 的既有测试没有删。

## Test Result

`flutter test test/bending_light/`：**157 passed**。旧测试未删。基线 153，本阶段新增在 `test/bending_light/view/scenery_nodes_test.dart`。

800×600 测试窗口里 Reset All 的 tap 警告仍在。点击点超出根尺寸。测试通过，不是失败。

## Analyze Result

`dart analyze lib/bending_light`：**No issues found.**

## Visual Evidence

`requirements/req-bending-light/visual-qa/final7/`，同样的帧在 `visual-qa/flutter/`。视口裁剪 y=56，1024×618。没有覆盖 final4 / final5 / final6。

- `FINAL7_INTRO.png`
- `FINAL7_MORE_TOOLS.png`
- `FINAL7_PRISMS.png`
- `FINAL7_WHITE_LIGHT.png`
- `FINAL7_GRAPH.png`
- `FINAL7_SENSORS.png`
- `FINAL7_PANEL.png`
- `FINAL7_TOOLBOX.png`
- `FINAL7_CONTROLS.png`（Graph 帧上的 Ray/Wave 裁块，加上底部 checkbox 与 TimeControl）

与官方 1.2.5 的区域差（最大通道差 > 12）：

| Region | Mean | Ratio |
| --- | --- | --- |
| Intro play | 0.55 | 0.009 |
| Panel | 19.13 | 0.329 |
| Toolbox | 29.31 | 0.462 |
| Graph | 20.28 | 0.306 |
| Sensors | 8.06 | 0.119 |
| Background | 25.83 | 0.412 |

Toolbox 比值从 QA-6 的 0.606 降到 0.462，因为图标换成了 source body，不是因为像素微调。剩下的差来自上表的 SOURCE MISMATCH，加上 sun 立体面 VERSION_DELTA。白光采样 `(500,235)` 仍是 `(255,255,255)`。RGB 不是 READY 门槛。

## Remaining P2

只保留已经按 source 核对过、且只剩光栅差异的项：

- 图表高光与面板填充的抗锯齿 / 平台栅格
- 已对齐几何上的笔画端点像素

下面这些**不能**再标成 P2：Material Ray/Wave、Material checkbox、Material TimeControl、只有轮廓的传感器图标。前三项已经拆掉。传感器图标不再是轮廓，但 ProbeNode、导线、旋钮、放置后的速度 scale、棱镜填充色仍是 SOURCE MISMATCH。

## Android

`NOT VERIFIED`

## Home

`UNCHANGED`

## Final Status

**NOT READY**

P0 = 0，P1 = 0，测试通过，分析干净。还没清零的是节点结构：`ProbeNode` 路径、已放置速度传感器 scale 2、波传感器导线、棱镜 `knob.png` 与介质色填充。`sun` 控件外观是 VERSION_DELTA，不是未核实的猜测。
