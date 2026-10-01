# PHASE 3 — Interaction Report · Bending Light

> 状态：**PHASE 3 COMPLETE**
> 日期：2026-09-18
> 不接 Home。不是 READY。

## Gate

| 项 | 结果 |
|---|---|
| P0 | 0 |
| P1 | 0 |
| `flutter test test/bending_light/` | **91 passed**（含 Phase 1 + Phase 2 回归） |
| `dart analyze lib/bending_light` | No issues found |
| Android runtime | **未运行**。`flutter devices` 只有 Windows / Chrome / Edge |
| Home | 未改 |

物理公式、Intro 标量 Snell、Prisms 矢量 Snell、射线追踪均未改。

## 1. Interaction architecture

```
Gesture / control value
  → screenToWorld 或控件数值
  → interaction/laser_interaction.dart 或 Model setter
  → updateModel / step
  → rays / sensors / time
  → ListenableBuilder 重绘
```

Widget 和 GestureDetector 里没有 Snell，也不直接改射线几何。

## 2. Laser interaction

- Intro / More Tools：拖激光体 → `screenToWorld` → `atan2` 绕 pivot → 限制第二象限 π/2…π；Wave 模式再夹到 `maxAngleInWaveMode`。
- Prisms：拖体平移（先 pivot 再 emission），拖旋钮 360°，无象限限制。
- 平移有模型边界夹取；非有限增量直接丢弃。
- 激光按钮切换 `laser.on`，然后 `updateModel`。

## 3. Medium controls

`MediumControlPanel`：Air / Water / Glass / Mystery A / Mystery B / Custom。
折射率范围 `[1.000293, 1.6]`。Intro 小数 2 位，More Tools 3 位。
Mystery 隐藏滑块和读数。
改介质走 `setTopSubstance` / `setBottomSubstance` / `setCustomIndex` → `updateModel`。

已测：Air→Water、Water→Air、Air→Glass、Glass→Air、n1=n2、水→空气大角度 TIR。

## 4. Protractor

Intro / More Tools：工具箱启用，拖动，放回工具箱则隐藏。
Prisms：复选框显示，只拖动，不放回（与矩阵一致）。
读数来自最近射线相对向上法线的夹角（`LightRay.getAngle`），不是写死的角度。
量角器自身刻度旋转、完整 `ProtractorNode` 外观留在 P2。

## 5. Prism interaction

- 点工具箱图标：复制原型，`addPrism`，每类最多 6。
- 拖棱镜体：`translate` → `updateModel`。
- 中心落入工具箱矩形：`removePrism`。
- 中心旋钮：`rotationDelta` → `prism.rotate` → 矢量 Snell 重算。
- 1× / 5× / White：`setLightType`。White 禁用波长滑块。
- 反射 / 法线 / 量角器复选框写入 Model。

工具箱是点击放入，不是从图标拖出。结果仍进入 `PrismsModel`。拖出的手势细节记为 P2。

## 6. Probe

强度计：启用后可分别拖 body 和 probe。位置写入 `IntensityMeter`，`updateModel` 用 `hitsSensorCircle` 更新读数（百分数，不是 View 自算）。
速度传感器：位置写入 `VelocitySensor`，`getVelocity` 在 `updateModel` 里刷新。
波探头：位置写入 `WaveSensor`，`step` 时按 `getWaveValue` 追加样本。
图表曲线本身留给后续显示阶段；样本序列已经在 Model 里。

## 7. Wire

强度计：body 与 probe 的屏幕点由模型位置经 `BlMvt` 得到，再连线。
波传感器：probe1、body、probe2 三点同样由模型位置决定。
不是一条与状态无关的装饰线。线形仍是直线，不是原版 WireNode 曲线（P2）。

## 8. Wavelength

范围 380–700 nm，步进 1 nm，默认 650 nm（`BendingLightConstants`）。
滑块调用 `setWavelength`（米）。射线 `wavelengthInVacuum` 和 `colorArgb` 随 Model 变。
White 模式下滑块 `enabled=false`，不直接 `slider → Color`。

## 9. Time control

Play / Pause / Step / Normal / Slow 只改 `isPlaying`、`speed`，或调用 `IntroModel.step` / `stepOnce`。
UI 没有自己的 Timer。播放时由 `Ticker` 调用 `model.step()`。
Intro 仅 Wave 模式显示；More Tools 在 Wave 或波传感器启用时显示。
Slow 的时间步小于 Normal（`WaveMath.dtForSpeed`）。

## 10. Sun controls

源码里的 sun 是 PhET 控件库（ComboBox / HSlider / Checkbox / Radio / ArrowButton），不是天体太阳，也不单独改变波长或射线。
本阶段对应为：下拉、滑块、复选、单选、Reset。没有额外的 Sun 滑块。

## 11. Reset

`KratosResetAllButton`，radius **19**，右下角。
`model.reset()` 恢复激光、介质、棱镜、波长、时间、播放、强度计、速度传感器、波传感器、量角器视图状态。

## 12. Hit testing

同一 Stack 内，后面的子节点优先：

1. 介质 / 射线绘制（不接事件）
2. 棱镜拖拽层
3. 棱镜旋转柄
4. 量角器、探头
5. 激光（盖住重叠的棱镜）
6. 右侧控件、工具箱、Reset（盖住播放区）

拖拽坐标都做有限性检查和模型边界夹取，避免 NaN。
右侧面板遮挡修正（occlusion bump）未做，记为 P2。

## 13. Tests

`test/bending_light/interaction/`

| 文件 | 覆盖 |
|---|---|
| laser_drag_test | 角度改变反射/折射；象限限制；NaN 平移 |
| medium_control_test | 介质、n1=n2、TIR |
| protractor_test | 读数跟随模型几何 |
| prism_interaction_test | 旋转、平移、旋钮、1×/5×/White、删除 |
| probe_test | 强度、速度、波样本 |
| wavelength_test | 波长写入 Model 并改变射线 |
| time_control_test | play/pause/step/slow |
| reset_all_test | Intro / More Tools / Prisms |

另外：三屏 widget pump，以及三张控制区截图。

## 14. Regression

`flutter test test/bending_light/ --reporter compact` → **91 passed**。
Phase 1 物理测试和 Phase 2 视口测试仍在这 91 里，没有单独只跑新测试。

## 15. Runtime status

`flutter devices`：

- Windows (desktop)
- Chrome
- Edge

没有 Android 设备或模拟器。**不能写成 Android runtime PASS。**
三屏 widget 已 pump。`dart analyze lib/bending_light` 覆盖 `bending_light_demo_main.dart`，无 issue。
本阶段没有把 `flutter run` 留在前台。入口仍是：

`flutter run -t lib/bending_light/bending_light_demo_main.dart`

## 16. Screenshots

`requirements/req-bending-light/visual-qa/`

- `PHASE_3_INTRO_CONTROLS.png`
- `PHASE_3_PRISMS_CONTROLS.png`
- `PHASE_3_MORE_TOOLS_CONTROLS.png`

带时钟 `Ticker` 的 Widget `toImage` 会卡住，所以这三张是 Canvas：真实介质/射线，加上控件占位框和 Reset 圆。激光本体不在这三张图里。控件在右侧和左下，不盖住界面原点附近的折射。

## 17. P0

无。

激光、介质、射线、棱镜旋转、TIR、Reset、探头读数、时间暂停都有测试。

## 18. P1

无。

## 19. P2

- 控件是 Flutter 下拉/滑块/复选，不是 sun 像素级 ComboBox / AquaRadio
- 量角器没有刻度盘自转
- 棱镜工具箱是点击添加，不是从图标拖出
- 导线是直线
- 波传感器图表未画（样本已在 Model）
- 右侧面板 occlusion bump 未做
- 旋钮仍是棕色圆，不是 `knob.png`
- Phase 1 已记录的强度计交点近似、发散透镜 contains 近似，未在本阶段偷偷改

## 20. Remaining work

- 波前/波形绘制，波传感器图表
- 量角器刻度与自转
- 工具箱拖出放置
- 视觉 QA 与原版截图对齐
- Home 集成（物理 → 光学与波动）不在本阶段
