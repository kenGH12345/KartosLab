# FINAL QA-8 Report

本地 source 优先。官方 1.2.5 画面只作证据。`sun` 控件仍是 VERSION_DELTA，没有按截图补造。

## 1. Four Source Mismatches Fixed

| Feature | Required Source Behavior | Result |
| --- | --- | --- |
| Intensity | ProbeNode kite path | PASS |
| Velocity | placed scale = 2 | PASS |
| Wave Sensor | 2 × WireNode | PASS |
| Prism | knob.png + mediumColorFactory | PASS |

开工记录在 `FINAL_QA_8_SOURCE_CLOSURE.md`。判定表已回写 `FINAL_SOURCE_FIDELITY.md`。

## 2. Exact Source Mapping

| Item | Source | Flutter |
| --- | --- | --- |
| Intensity probe | `scenery-phet/js/ProbeNode.ts`，`IntensityMeterNode` scale 0.6 | `ProbeNodeGeometry` / `ProbeGlyph` |
| Wave probes | 同一 `ProbeNode`，radius 43，inner 32，handle 40×30，corner 9，scale 0.35，`crosshairs()` | 同一个 `buildProbeOutline` |
| Velocity placed | `bodyNode.setScaleMagnitude(0.7)` 之后 `scale: 2` | `VelocitySensorGraphic.placedNodeScale = 2`，body scale 仍是 0.7 |
| Velocity toolbox | 同一节点 `scale: 1.2` | `nodeScale: 1.2`，没有改成 2 |
| Wave wires | 两条 `WireNode`，法线 `(25,0)` 与 `(0,25)` | 两个 `WaveWire` |
| Prism knob | `images/knob.png`，高度 15，有 reference point 才加 | `placePrismKnob` + `Image.asset` |
| Prism fill | `mediumColorFactory.getColor(n).withAlpha(0.5)` | `MediumColorFactory.getColor` |

## 3. Geometry

- Probe 外形：底边中心出发，圆角手柄，颈，`0.8π` 到 `0.2π` 的长弧（sweep `1.4π`）。原点是传感器中心。内孔用 even-odd，中心点不在填充里。手柄点 `(0, 65)` 在填充里。
- 强度计探头平移仍是 model 的 `sensorPosition`。导线终点是 `centerBottom`，不是另算一套坐标。
- 速度传感器热点仍是三角形左尖。外层 `canvas.scale(2)` 绕这个点。没有改三角形宽、箭头公式或命中框来假装 scale 2。工具箱仍是 1.2。
- 波传感器导线起点是 body `rightBottom + (-2, -(1-0.82)·height)`。两条线终点分别是两个探头的 `centerBottom`。
- 棱镜旋钮锚在 reference point，偏移 `(-width-7, -height/2-8)`，角度是 reference 到 rotation center 的 `atan2`。圆没有 reference point，不画旋钮。

## 4. Paint

- Probe 主路径线宽 2，填充停靠点跟 `ProbeNode`：0 / 0.03 / 0.07 / 0.11 / 0.3 / 0.8 / 1，亮度因子 +0.5、+0.4、+0.2、0、-0.2、-0.3。正面缩放 0.9 × 0.94，下移 2。默认传感器是玻璃径向渐变。波探头是黑色十字，线宽 3，中心留空 8。
- `PaintColorProperty` 不在本地树里。亮度混合用朝白/朝黑的插值实现那些因子，不是另造一套 1.2.5 颜色。
- 强度导线 stroke `gray`，线宽 3。波导线颜色 `rgb(88,89,91)` 与 `rgb(147,149,152)`，线宽 3。
- 棱镜 stroke `gray`。填充 alpha 0.5。玻璃在白底上是 `0xABA9D4`，空气是白，白光模式下空气是黑。

## 5. Interaction Regression

- 强度：探头拖动仍写 `sensorPosition`。读数、交点、中点计算没有改。
- 速度：箭头常数仍是 `1.5e-14`。速度为 0 时读数是 `?`。拖动和 reset 仍走 model。
- 波：工具箱图标有两条独立 `WaveWire`。放下后的导线终点跟 probe model 位置。图和波形公式没改。离开再进入不会追加导线，导线是从 model 重建的。
- 棱镜：拖动仍改 position。旋钮旋转仍绕 rotation center，坐标取自播放区，不取旋钮自己的局部盒。介质改变时 fill 跟 `mediumColorFactory`。圆不出现旋钮。

## 6. Tests

`flutter test test/bending_light/`：**161 passed**。旧测试没有删。新增覆盖 kite 孔、placed scale 2、两条导线端点、旋钮宽高比、玻璃/空气/白光颜色。

## 7. Analyze

`dart analyze lib/bending_light`：**No issues found.**

## 8. VERSION_DELTA

未改，也没有按 1.2.5 补造：

- sun slider gradient
- dropdown highlight
- arrow-button 立体面
- water radio fill
- checkbox path
- circular button bevel

## 9. Remaining P2

- 已对齐几何上的抗锯齿和平台栅格
- Probe 亮度因子的精确 `PaintColorProperty` 曲线不在本地 scenery 源码里，当前用插值落实本地写出的因子

这四项结构 mismatch 不再记成 P2。

## 10. Visual Evidence

`requirements/req-bending-light/visual-qa/final8/`，同样的帧在 `visual-qa/flutter/`。视口裁剪 y=56，1024×618。

- `FINAL8_INTRO.png`
- `FINAL8_MORE_TOOLS.png`
- `FINAL8_PRISMS.png`
- `FINAL8_WHITE_LIGHT.png`
- `FINAL8_GRAPH.png`
- `FINAL8_SENSORS.png`
- `FINAL8_TOOLBOX.png`

工具箱里的强度探头是带玻璃高光的 kite，不是圆加手柄。波传感器图标有两条线。棱镜图标带 `knob.png`，填充是介质色而不是固定青。白光采样 `(500,235)` 仍是 `(255,255,255)`。

## 11. Final Status

**READY CANDIDATE**

P0 = 0，P1 = 0。四个明确的 source structure mismatch 已清零。测试通过，分析干净。面板、视口、图、滑条、下拉、加减按钮、物理没有重调。

Android：**NOT VERIFIED**

Home：**UNCHANGED**
