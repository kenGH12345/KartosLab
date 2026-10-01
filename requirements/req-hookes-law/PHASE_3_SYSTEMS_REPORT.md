# PHASE 3 — SYSTEMS REPORT · Hooke's Law

> 布局舞台：1024×618（`PHASE_2_LAYOUT_AUDIT.md`）  
> 模型：`PHASE_1_MODEL_REPORT.md`  
> 对照表：`requirements/req-hookes-law/PHASE_3_SYSTEMS_PARITY.md`  
> 视觉笔记：`requirements/req-hookes-law/visual-qa/SYSTEMS/QA.md`  
> 日期：2026-09-20

## 1. Status

**READY CANDIDATE**

Systems 的串联、并联、Total/Components、拖拽、snap、夹紧和 Reset 已经接到 Phase 1 模型。  
P0 = 0。布局和控件立体感还有明确 VERSION_DELTA，所以本阶段不是视觉验收。

模拟器整体仍然是 **NOT READY**。  
Energy、Home、最终视觉验收、行为验收都还没有做。本报告不宣布整个模拟器 READY。

| 门禁 | 结果 |
|---|---|
| 串联 / 并联同时存在，默认并联 | 已接 |
| View 不计算 keq / F / x | 已接 |
| Total / Components 只改箭头，不改模型 | 已接 |
| 拖拽 0.01 m snap，只在拖拽输入 | 已接 |
| 隐藏系统 Reset | 已接 |
| 离开屏幕不 reset | 已接 |
| Intro 行为 | 原测试仍通过 |
| `flutter test test/hookes_law/systems test/hookes_law/intro test/hookes_law/model` | 46 passed |
| `dart analyze lib/hookes_law test/hookes_law` | No issues found |
| P0 | 0 |
| 像素级对照官方运行时 | 未做 |

## 2. Files changed

新增：

- `lib/hookes_law/view/systems/systems_screen.dart`
- `lib/hookes_law/view/systems/systems_view_properties.dart`
- `lib/hookes_law/view/systems/systems_system_view.dart`
- `lib/hookes_law/view/systems/systems_scene_painter.dart`
- `lib/hookes_law/view/systems/systems_paint.dart`
- `lib/hookes_law/view/systems/systems_controls.dart`
- `lib/hookes_law/view/systems/systems_visibility_panel.dart`
- `lib/hookes_law/view/systems/systems_arm_drag.dart`
- `test/hookes_law/systems/systems_screen_test.dart`
- `requirements/req-hookes-law/PHASE_3_SYSTEMS_PARITY.md`
- `requirements/req-hookes-law/PHASE_3_SYSTEMS_REPORT.md`
- `requirements/req-hookes-law/visual-qa/SYSTEMS/QA.md`

共用抽参（Intro 默认值不变，Intro 测试仍通过）：

- `lib/hookes_law/constants/hookes_law_constants.dart` — Systems 舞台偏移、8 圈、墙高 300、k 轨宽 120、颜色分量
- `lib/hookes_law/view/parametric_spring_geometry.dart` — `xScaleForLength` 增加可选 `loops`，默认仍是单簧 12 圈
- `lib/hookes_law/view/intro/intro_play_painter.dart` — `_paintArm` 改为公开的 `paintRoboticArm`，Intro 的调用参数未改
- `lib/hookes_law/view/intro/intro_number_control.dart` — `trackWidth` 默认 180，`framed` 默认 true

没有改 Energy。没有改 Home。没有改 Phase 1 的力、位移、等效劲度公式。

## 3. Systems architecture

`SystemsScreen` 持有同一个 `SystemsModel`。模型里串联和并联从构造开始就都在。

可见性在 `SystemsViewProperties`，不在模型里：

- `systemType` 默认并联
- `springForceVectorVisible` 默认 false
- `springForceRepresentation` 默认 TOTAL

隐藏的那一套用 `Offstage`，不销毁。两套各有自己的机械臂和手势计数。没有 `SharedHookesLawState`，也没有和 Intro 共用的弹簧属性。

## 4. Serial semantics

外部操作写等效弹簧。模型再把同一力分到两根弹簧，位移按劲度分配。

- F1 = F2 = Feq
- xeq = x1 + x2
- keq = 1 / (1/k1 + 1/k2)

不等 k 时力仍然相等，位移不相等。View 只读这些属性。

## 5. Parallel semantics

外部操作写等效弹簧。模型把同一位移写到两根弹簧，力按劲度分配。

- x1 = x2 = xeq
- Feq = F1 + F2
- keq = k1 + k2

不等 k 时位移仍然相等，分力不相等。没有用 total/2。

## 6. Total / Components semantics

`forceDisplayMode` 没有进模型。模型始终维护 F1、F2、Feq。

Spring Force 未勾选时，Total / Components 单选无效，表示保持 TOTAL。  
勾选之后：

- Total：等效弹簧力箭头（蓝）
- Components：每根弹簧自己的 springForce 箭头

等效外力箭头只看 Applied Force，不跟着 Total/Components 走。  
切换前后模型快照不变。

## 7. Drag

可见系统的手势调用 `applyRoboticArmPointerLeft(arm, equivalent.rightRange, proposed)`。

- 串联拖外部臂不会把 F1 和 F2 拆开
- 并联拖动不会把 x1 和 x2 拆开
- 松手停在当前位移，没有回弹或振荡

## 8. Snapping

0.01 m 只在拖拽输入里。顺序与 Phase 1 相同：先按 right range constrain，再 `roundToInterval(0.01)`，不再夹一次。

滑块和箭头用各自的 source step：k 箭头 1、k 滑块 10、力箭头 1、力滑块 5。位移 setter 本身不 snap。

默认夹紧：

- 并联 keq = 400，位移 ±0.25 m，力 ±100 N
- 串联 keq = 100，位移 ±1.0 m，力 ±100 N

## 9. Controls

- k：200–600，默认 200。Systems 轨宽 120。并联是 Top / Bottom，串联是 Left / Right。拇指颜色分别是 spring1 / spring2。
- 力：标题 “Applied Force:”，写等效弹簧，轨宽 180，范围 −100..100。
- 可见性面板：Applied Force、Spring Force、缩进的 Total / Components、Displacement、Equilibrium Position、Values。
- 系统类型：并联在左，串联在右。
- Reset All：`KratosResetAllButton`，半径 20.5，颜色 `#F79722`。

立体斜面没有在本阶段补。这是和 Intro 相同的视觉债务。

## 10. Layout

舞台仍是 1024×618，没有改成 768×504，也没有套 Home。

- 两套系统 `left = 30`，列在舞台高度里居中（对应 layoutBounds.centerY = 309）
- 右上是可见性面板和系统类型
- Reset 在右下，边距 15
- 控件在墙底之下 25 px

和 source 的差别：source 把控件水平居中，并把最大宽度限制成墙左缘到机械臂右缘。Flutter 把控件左对齐，只在行宽超过舞台剩余宽度时整行缩小。这是 P1，不是物理错误。

## 11. Transform

位移比例 1 m = 225 px，和 Intro 相同。局部原点不是 Intro 那一套单簧原点。

- `systemsX(meters) = wallWidth + 225 × meters`
- 并联墙高 300，上弹簧在 0.25 墙高，下弹簧在 0.75 墙高
- 串联墙高 170，两根弹簧在同一条水平轴上
- 力箭头长度用 `unitForceX = 1.45`

## 12. Spring rendering

继续用 prolate cycloid，不用 PNG、SVG 或正弦波。

- Systems 圈数 8（Intro 仍是 12）
- 右端仍落在 `length × 225`
- k = 200、minK = 200 时线宽 3
- 并联上 / 串联左 = spring1 紫
- 并联下 / 串联右 = spring2 黄

Intro 的 12 圈绘制路径没有改成这套带颜色参数的 helper。

## 13. Force arrows

- 外力：橙，方向为 +F
- 总弹簧力：蓝 (0, 0, 255)，方向为 −F
- 并联分力：上紫、下黄，2 位小数，x 取各弹簧右端
- 串联分力：左弹簧力紫、左外力黄、右弹簧力黄，1 位小数
- 力为 0 时不画箭头；Values 打开时仍可显示 “0 N”

分力的垂直位置是近似的，见 P1。

## 14. Reset

`KratosResetAllButton` 调用 `model.reset()` 再 `view.reset()`。

模型 reset 两套系统。View reset 回到并联、TOTAL，并关掉矢量 checkbox。  
先改并联、再切到串联、再 Reset，重新看到的并联是默认状态。

## 15. Lifecycle

屏幕 dispose 只移除监听。自己创建的 `SystemsViewProperties` 才会 dispose。  
dispose 不调用 `model.reset()`。

用同一对 model 和 viewProperties 卸下再挂上，k、系统类型和 Components 都还在。  
状态不会写进 Intro 或 Energy。Energy 屏幕不存在于本阶段。

## 16. Tests

`test/hookes_law/systems/systems_screen_test.dart`：

1. 8 圈弹簧右端 = length × 225
2. 默认并联，串联已在默认值
3. k 与力写入并联，不等 k 时关系成立，且不碰到串联
4. 串联力相等、位移相加、keq 来自模型
5. Total / Components 只改可见性
6. 拖拽 snap、并联夹紧、串联夹紧，两套不串扰
7. Reset 隐藏系统与控件
8. 离开再进入不 reset

`flutter test test/hookes_law/systems test/hookes_law/intro test/hookes_law/model`：**46 passed**（Systems 8 + Intro 11 + Model 27）。

## 17. Analyze

`dart analyze lib/hookes_law test/hookes_law`

**No issues found**

## 18. Visual QA

见 `requirements/req-hookes-law/visual-qa/SYSTEMS/QA.md`。

查过默认并联、串联、Total、Components、正负力、不等 k、拖拽后、Reset。  
依据是 source 节点和 widget 测试，不是官方运行时截图。

## 19. P0

0。

没有发现：串联或并联关系错误、力方向错误、Total/Components 改模型、拖拽不写模型、两套状态串扰、隐藏系统 reset 失败、弹簧几何用错、控件无法操作。

## 20. P1

功能已经闭环，下面是视觉或布局差，不能当成视觉 PASS：

- 箭头、滑块拇指、checkbox、radio 仍是平面控件
- 铰链高光仍缺
- 分力箭头垂直间距是近似值
- 数值标签位置按字符宽度估算
- 系统类型图标是简化弹簧，不是 source 图标
- 控件行左对齐，没有按墙到机械臂的宽度居中
- 位移数字的纵向位置是近似的

## 21. P2

- 没有键盘拖拽（Intro 同样没有）
- 没有导航栏（本阶段明确不画）
- 没有像素 diff

## 22. Remaining VERSION_DELTA

- 控件立体效果和铰链高光留到后面的 Visual Reconstruction
- Systems 控件的水平居中和 `maxWidth`
- 分力箭头与数值标签的精确锚点
- 系统类型图标
- 键盘
- 与官方运行时的像素对照

## 23. Known limitations

- 本阶段没有 Energy，没有 Home
- 离开 Systems 的测试是卸下这个 widget 再挂上，不是完整的屏幕路由器
- 视觉 QA 没有官方像素对照
- 标签极宽时控件行会缩小；默认英文在正常字体下应能放进 1024 宽舞台。测试字体（方块字）会触发缩小，所以力滑块测试按轨的实际宽度拖，而不是写死 36 px

本阶段到此停止。不开始 Energy，不接 Home，不把整个模拟器标成 READY。
