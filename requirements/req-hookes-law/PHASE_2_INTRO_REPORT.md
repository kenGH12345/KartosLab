# PHASE 2 — INTRO REPORT · Hooke's Law

> 布局依据：`requirements/req-hookes-law/PHASE_2_LAYOUT_AUDIT.md`  
> 模型依据：`requirements/req-hookes-law/PHASE_1_MODEL_REPORT.md`  
> 行为依据：`phet sourses/hookes-law-main/hookes-law-main` TypeScript  
> 日期：2026-09-20

## 1. Status

**READY CANDIDATE**

Intro 的模型绑定、拖拽、控件步长、1/2 套动画和 Reset 已经接上 Phase 1 模型。  
P0 = 0。视觉上还有明确的 VERSION_DELTA（见第 20–22 节），所以本阶段不是视觉验收。

模拟器整体仍然是 **NOT READY**。  
没有 Systems，没有 Energy，没有 Home。本报告不宣布 READY。

| 门禁 | 结果 |
|---|---|
| viewport / layoutBounds | 1024×618，已核对 joist SHA |
| Intro 游乐场、弹簧、机械臂、力箭头、位移、平衡线 | 已接模型 |
| Values / 控件 / 1↔2 | 已接 |
| 拖拽闭环 + 仅在拖拽里 0.01 m snap | 已接 |
| 改 k 保持 F | 已接 |
| Reset（含隐藏的第二套） | 已接 |
| 动画不对称、无振荡 | 已接 |
| Model/View 无第二份 F/x/k | 已接 |
| `flutter test test/hookes_law` | 38 passed（模型 27 + Intro 11） |
| `dart analyze lib/hookes_law test/hookes_law` | No issues found |
| P0 | 0 |
| 像素级对照官方运行时 | 未做 |

## 2. Files changed

模型只加了卸载监听，没有改公式。

- `lib/hookes_law/model/number_property.dart` — `removeListener`，供屏幕 dispose
- `lib/hookes_law/constants/hookes_law_constants.dart` — 1024×618、墙、滑块、Intro 偏移、动画 0.5 s

View：

- `lib/hookes_law/view/hookes_law_stage.dart`
- `lib/hookes_law/view/phet_font.dart`
- `lib/hookes_law/view/parametric_spring_geometry.dart`
- `lib/hookes_law/view/intro/intro_screen.dart`
- `lib/hookes_law/view/intro/intro_system_view.dart`
- `lib/hookes_law/view/intro/intro_play_painter.dart`
- `lib/hookes_law/view/intro/intro_number_control.dart`
- `lib/hookes_law/view/intro/intro_visibility_panel.dart`
- `lib/hookes_law/view/intro/intro_view_properties.dart`

测试与记录：

- `test/hookes_law/intro/intro_spring_geometry_test.dart`
- `test/hookes_law/intro/intro_screen_test.dart`
- `requirements/req-hookes-law/PHASE_2_LAYOUT_AUDIT.md`
- `requirements/req-hookes-law/visual-qa/INTRO/QA.md`

没有改 Home，没有 Systems / Energy 的 View。

## 3. View architecture

| Flutter | Source |
|---|---|
| `IntroScreen` | `IntroScreenView` + `IntroAnimator` |
| `IntroViewProperties` | `IntroViewProperties` |
| `IntroSystemView` | `IntroSystemNode` |
| `IntroPlayPainter` | 墙、弹簧、nib、臂、箭头、平衡线 |
| `IntroNumberControl` | `SpringConstantControl` / `AppliedForceControl` |
| `IntroVisibilityPanel` | `IntroVisibilityPanel` |
| 右上两个弹簧按钮 | `NumberOfSystemsRadioButtonGroup` |
| `KratosResetAllButton` | `ResetAllButton`，半径 20.5 |

View 不计算 F、x、E。读 `Spring` / `RoboticArm`，写 `setAppliedForce`、`setSpringConstant`，拖拽写 `applyRoboticArmPointerLeft`。

## 4. Viewport

joist `bb6a94e05e03c82aa75dfb9717459e5be07a4507`：

`ScreenView.DEFAULT_LAYOUT_BOUNDS = (0, 0, 1024, 618)`

`IntroScreenView` 没有覆写。缩放是 `min(viewW/1024, viewH/618)`，居中，不分开拉 x/y。

导航栏高 40，在 ScreenView 外面。本阶段不画。

## 5. Layout

- 右上：先 Visibility，再 1/2 单选。`right = 1014`，`top = 10`，间距 10
- 系统列左边 = 15（墙的左缘）
- 弹簧原点在列内 x = 25（墙宽）
- 1 套：system1 `centerY = 309`
- 2 套：system1 `centerY = 154.5`，system2 `centerY = 463.5`
- Reset：右 15、下 15
- 控件在墙底之下 10 px，k 与 F 横向并排
- 系统列高度常量 298 ≤ 309（`layoutBounds.height / 2`）

源码变量 `system1CenterXForTwoSystems` 赋的是 centerY。按赋值，不按名字。

## 6. Model → View Transform

- 1 m = 225 px（`UNIT_DISPLACEMENT_X`）
- 场景力箭头 1 N = 1.45 px（`UNIT_FORCE_X`）
- Energy 的 0.25 / 0.4 **没有**用在 Intro
- 原点：弹簧左端 / 墙右中点。y 向下
- `equilibriumX = 1.5` m，左端锁在 0。平衡线不跟手移动
- `arm.right = 3.0` m，构造后固定。手在 `225 * arm.left`

## 7. Spring rendering

`ParametricSpringNode` 的 prolate cycloid，不是正弦，也不是图片。

- loops 12，pointsPerLoop 40，radius 10，aspectRatio 4
- phase π，deltaPhase π/2
- 左端 15，右端 25
- `xScale = (length * 225 - 40) / (12 * 10)`
- 线宽 `3 + 0.005 * (k - 100)`。k=200 时 3.5
- 先画 back 渐变，再画 front 渐变
- 颜色 front `(150,150,255)`，middle `(0,0,255)`，back `(0,0,200)`

几何测试确认：相邻采样点的 x 会减小（线圈折返），右端尖正好是 `length * 225`。

## 8. Mechanical arm

拖的是手，不是质量块。

- 红盒 7×30、灰白渐变盒 20×60 在固定端（`arm.right`）
- 伸缩臂高 14，两端各叠 10 px
- 夹爪半径 35、线宽 6。静止且 `toFixed(x, 3) == 0` 时张开，否则闭合
- 铰链按 `HingeNode` 的梯形、销和主体弧绘制。高光是简化的（P1）

## 9. Force arrows

施力与弹力共用弹簧右端，箭头底在轴上方 50 px。

- 施力填色 `(255, 85, 0)`，`alignZero = left`
- 弹力填色 `(0, 0, 255)`，数值是 `|−F|`，方向跟 `-F`
- 尾宽 10，头 20×10，黑描边
- F = 0 不画箭头（零长度画不出来）。Values 打开时，`0.0 N` 仍在
- 位移箭头是绿色描边，头 20×10，线宽 3，尾在平衡位置，F 式的 `x = 0` 时不画
- 数值格式：力 1 位小数 + ` N`（绝对值），位移 3 位小数 + ` m`

## 10. Drag behavior

按下记起点 → 位移 = 起点 + Δpx / 225 → `applyRoboticArmPointerLeft` → 模型通知 → 弹簧、箭头、文字重画。松手停在当前 x。没有回弹。

手移动时用全局位移除以舞台缩放，避免 FittedBox 把步长放大。

## 11. Snap semantics

只在这条拖拽路径里：

1. `rightRange.constrain`
2. `roundToInterval(0.01)`
3. `arm.left =`

不再夹一次。`setDisplacement` 仍然不 snap。

滑块步长是另一条路：力 5 N，k 10 N/m。箭头是 1 N 和 1 N/m。

k=200 时拖出界停在 x = ±0.5 m（F = ±100 N）。

## 12. Controls

Intro 没有位移滑块。每套系统各有：

- Spring Constant n：100–1000，默认 200，刻度 100 / 500 / 1000，小刻度 100
- Applied Force n：−100–100，默认 0，刻度 −100 / −50（无标签）/ 0 / 50（无标签）/ 100，小刻度 10

共用一块 Visibility：Applied Force、Spring Force、Displacement、Equilibrium Position、Values。  
Values 只有至少一个矢量勾上才能点。关掉全部矢量不会把 Values 清成 false，只是禁用。

Reset All 用 `KratosResetAllButton`。

## 13. One/two system behavior

两套 `SingleSpringSystem.intro()`，互不读写。默认只画第一套。  
切到 2 套时第二套用自己的弹簧、臂和控件。可见性是 view 状态，不是并联或串联。

## 14. Animation

`IntroAnimator`，线性，各 0.5 s，不同时。

- 1→2：先把 system1 移到 `centerY = 154.5`，再把 system2 设为可见，opacity 从当前值到 1
- 2→1：先把 system2 的 opacity 收到 0，再 `visible = false`，然后把 system1 移回 `centerY = 309`
- 构造时 `numberOfSystems == 1` 也会跑一遍「收到 1 套」（第二套本来就不可见）。之后 opacity 停在 0，第一次真正的 1→2 才能淡入

没有弹簧振动。

## 15. Reset

`model.reset()` 然后 `viewProperties.reset()`。

- k、F、x 回到默认，两套都回到，包括当时看不见的那套
- 复选框全关，套数回到 1
- 套数从 2 变回 1 时走 2→1 动画，不是瞬移
- `epoch` 增加，进行中的拖拽和滑块手势记数清零
- 屏幕 dispose 时卸掉属性监听和 `Ticker`

## 16. Tests

`flutter test test/hookes_law/intro test/hookes_law/model`

**38 passed**

Intro 覆盖：默认、1/2 可见性、正向拖、负向拖、0.01 snap、夹紧、力、弹簧力、位移、改 k 保持 F、负力、零力箭头、Reset、隐藏第二套、1→2 的先后、2→1 的先后、dispose。

几何测试确认 cycloid 折返，以及右端长度 = `1.5 * 225`。

## 17. Analyze

`dart analyze lib/hookes_law test/hookes_law`

**No issues found**

## 18. Visual QA

`requirements/req-hookes-law/visual-qa/INTRO/QA.md`

A–L 的行为有 widget 测试。没有官方截图像素 diff，不能写成像素 PASS。

## 19. P0

无。

## 20. P1

这些是 VERSION_DELTA，不是行为错误：

- 箭头按钮、滑块拇指、复选框、单选按钮缺少 sun 的 3D / 选中色
- 铰链高光和主体闭合路径是简化的
- 右上图标 `pointsPerLoop = 24`，前/后纯色，不是三色渐变
- 矢量数字的水平位置用字符宽度估算

键盘（手的 0.01 m 方向键，以及 NumberControl 的 keyboard step）没有做。指针、箭头和滑块步长是按源码分开的。

## 21. P2

- 系统列用高度 298 对齐 `centerY`，控件自然高度大约少几像素
- 面板圆角 4
- 字体是 Arial，系统没有 Arial 时落到 sans-serif

## 22. Remaining VERSION_DELTA

见第 20、21 节。没有用截图冒充弹簧，也没有宣称与官方运行时像素一致。

## 23. Known limitations

- 不包含导航栏、Home、Systems、Energy
- Intro 没有位移滑块（源码也没有）
- Values 不是另一块 k/F/x 表。k 和 F 在 NumberControl 上；勾上 Values 后，数字出现在对应矢量上
- 平衡位置是固定参考线（左端锁死，`equilibriumX = 1.5`），不是随 F 移动的量
- 没有键盘拖拽

本阶段在此停止。
