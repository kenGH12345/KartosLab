# PHASE 4 — ENERGY REPORT · Hooke's Law

> 布局：`requirements/req-hookes-law/PHASE_4_ENERGY_LAYOUT_AUDIT.md`  
> 对照：`requirements/req-hookes-law/PHASE_4_ENERGY_PARITY.md`  
> 视觉：`requirements/req-hookes-law/visual-qa/ENERGY/QA.md`  
> 日期：2026-09-21

## 1. Status

**READY CANDIDATE**

Energy 的位移输入、改 k 保持 x、三张图、三角形、拖拽和 Reset 已经接到 Phase 1 模型。  
P0 = 0。标签锚点和控件立体感还有 VERSION_DELTA，所以不是视觉验收。

模拟器整体仍然是 **NOT READY**。  
没有 Home，没有最终行为验收，没有最终视觉验收。本报告不宣布整个模拟器 READY。

| 门禁 | 结果 |
| --- | --- |
| 自变量是 x，不是 F | 已接 |
| 改 k 保持 x | 已接 |
| 三张图同一模型 | 已接 |
| 场景力箭头 0.4，Force Plot 0.25，能量 1.1 | 已分开 |
| 拖拽 0.01 m，滑块 0.05 m，箭头 0.01 m | 已分开 |
| Intro / Systems 原测试 | 仍然通过 |
| `flutter test` energy + systems + intro + model | 61 passed |
| `dart analyze lib/hookes_law test/hookes_law` | No issues found |
| P0 | 0 |

## 2. Files changed

新增：

- `lib/hookes_law/view/energy/energy_screen.dart`
- `lib/hookes_law/view/energy/energy_view_properties.dart`
- `lib/hookes_law/view/energy/energy_system_view.dart`
- `lib/hookes_law/view/energy/energy_scene_painter.dart`
- `lib/hookes_law/view/energy/energy_graph_painter.dart`
- `lib/hookes_law/view/energy/energy_visibility_panel.dart`
- `test/hookes_law/energy/energy_screen_test.dart`
- `requirements/req-hookes-law/PHASE_4_ENERGY_LAYOUT_AUDIT.md`
- `requirements/req-hookes-law/PHASE_4_ENERGY_PARITY.md`
- `requirements/req-hookes-law/PHASE_4_ENERGY_REPORT.md`
- `requirements/req-hookes-law/visual-qa/ENERGY/QA.md`

常量只追加 Energy 布局数字，没有改 Intro / Systems 已有常量的值：

- `lib/hookes_law/constants/hookes_law_constants.dart`

没有改 Intro 或 Systems 的屏幕代码。没有改 Phase 1 公式。没有接 Home。

## 3. Energy Model binding

`EnergyScreen` 使用 `EnergyModel`。弹簧由 `SingleSpringSystem.energy()` 构造：k 100–400 默认 100，位移 −1…1 默认 0。

View 读取 `displacement`、`springConstant`、`appliedForce`、`springForce`、`potentialEnergy`。  
曲线和直线的采样在 `EnergyGraphData`，Painter 不写 `k * x * x / 2`。

屏幕监听位移、k 和力，图与弹簧同一帧更新。dispose 不调用 `reset`。

## 4. Layout

见布局审计。墙左缘 35，底边距 10，控件在墙下 10。右上是图选择和勾选，右下是 Reset。  
柱底在系统列顶之上 35。系统高度是测出来的，避免把控件高度写死。

## 5. Viewport

1024 × 618，`HookesLawStage`。不是 768 × 504。不画导航栏。

## 6. Transform

| 用途 | 常量 | 值 |
| --- | --- | --- |
| 弹簧、位移、图的 x | `unitDisplacementX` | 225 px / m |
| Intro / Systems 场景力箭头 | `unitForceX` | 1.45 px / N |
| Energy 场景力箭头 | `energyUnitForceX` | 0.4 px / N |
| Force Plot 的 y | `unitForceY` | 0.25 px / N |
| 柱和 Energy Plot 的 y | `unitEnergyY` | 1.1 px / J |

连接点屏幕 x = 35 + 25 = 60。图原点 x = 60 + 225 × 1.5 = 397.5。

## 7. Controls

- Spring Constant：100–400，箭头 1 N/m，滑块 10 N/m，刻度 100/200/300/400，次刻度 50。写 `setSpringConstant`。
- Displacement：−1…1，箭头 0.01 m，滑块 0.05 m，刻度 −1/0/1，次刻度 0.2 m。写 `setDisplacement`。
- 图：Bar Graph / Energy Plot / Force Plot。默认柱图。
- Energy 勾选只在 Force Plot 上生效，控制三角形，不改能量数值。
- Applied Force、Displacement、Equilibrium Position、Values。没有 Spring Force。Values 没有“先打开某个矢量”的限制。
- Reset All：`KratosResetAllButton`，半径 20.5。

没有 Applied Force 滑条。

## 8. Drag

手势走 `applyRoboticArmPointerLeft`：先按位移窗口 ±1 m 对应的 right range 限制，再 0.01 m 吸附。  
`setDisplacement` 本身不吸附。松手停住，没有振荡。

## 9. k semantics

x = 0.5，k = 200 时 F = 100，E = 25。  
k 改为 400 后 x 仍是 0.5，F = 200，E = 50。  
不会变成 x = 0.25。

负位移：F 为负，弹簧力为正，能量仍为正。

## 10. Bar Graph

默认模式。柱宽 20，颜色 (0, 204, 255)，高度 `max(1, E × 1.1)`，从 0 向上。E = 0 不画柱。  
纵轴箭头长 250。横轴长 1.65 × 20。  
切到 Energy Plot 或 Force Plot 时柱不消失，改到 x = 15。

## 11. Energy Plot

`E = kx²/2` 用两段二次贝塞尔。控制点公式与 `EnergyPlot.ts` 相同：`cpx = 2 x2 − x1/2 − x3/2`。  
k = 200 时端点能量 100 J，view y = −110，控制点 x = 112.5。  
线宽 3。当前点用模型的位移和 `potentialEnergy`。路径被裁在图域内。

## 12. Force Plot

直线端点来自 `forcePlotLine`。x 与 Energy Plot 相同（±247.5 的轴，线画在 ±225）。  
y 是 ±125，单位 0.25 px/N。正力向上。  
当前点的 y 用 `appliedForce`，不用在 Painter 里乘 k。

## 13. Triangle area

顶点是原点、(x, 0)、(x, −F × 0.25)。  
仅当图是 Force Plot、Energy 已勾选、并且位移按 3 位小数不是 0。  
勾选或取消不改变 x、k、F、E。

## 14. Graph scales

三套比例见第 6 节。测试断言 0.4、0.25、1.45 互不相等，并且三角形和直线用的是 0.25，不是 0.4。

## 15. Reset

Reset 恢复 x、k、F、E、柱图、能量勾选和其它勾选。  
与第一次打开一致。切走屏幕本身不 reset。

## 16. Screen isolation

`IntroModel`、`SystemsModel`、`EnergyModel` 是三份对象。  
Intro 改力、Systems 改 k、Energy 改位移，另外两份不变。  
没有全局弹簧状态。

## 17. Animation

没有回弹、阻尼或惯性。拖动和滑块是状态更新，图在同一次 setState 里重画。

## 18. Tests

`test/hookes_law/energy/energy_screen_test.dart` 覆盖：默认值、改 k 保持 x、负位移、零、夹紧、setter 不吸附、贝塞尔、力线和三角形比例、柱图默认、位移箭头/滑块、k 箭头/滑块、三图切换、能量勾选、拖拽、Reset、离开再进入、与 Intro/Systems 隔离。

`flutter test test/hookes_law/energy test/hookes_law/systems test/hookes_law/intro test/hookes_law/model`：**61 passed**（Energy 15 + Systems 8 + Intro 11 + Model 27）。

没有改旧测试的期望。

## 19. Analyze

`dart analyze lib/hookes_law test/hookes_law`

**No issues found**

## 20. Visual QA

见 `requirements/req-hookes-law/visual-qa/ENERGY/QA.md`。  
查过默认柱图、正负位移、两张曲线图、改 k、零、Reset、拖拽、切图。不是像素对照。

## 21. P0

0。

没有缺图、没有把图模式写进物理、没有改 k 时把 x 改掉、没有用错比例、没有拖拽不写模型、没有让负位移的能量变成负数。

## 22. P1

- 数值避让不是 `XYPointPlot` 的完整碰撞规则
- Force Plot 原点与柱轴对齐；source 用节点 bottom，负半轴会把原点抬高一点
- 控件行左对齐，没有按墙到机械臂居中
- 箭头、滑块、checkbox、radio 仍然是平面的
- 铰链高光仍然没有
- 轴标题位置是近似的

## 23. P2

- 没有键盘步进
- 没有导航栏
- 没有像素 diff

## 24. VERSION_DELTA

- 控件立体效果和铰链高光，与 Intro / Systems 同一笔，留到视觉返工
- Force Plot 相对柱图的纵向锚点
- 图上数值的避让
- 控件水平居中
- 键盘
- 与官方运行时的像素对照

## 25. Known limitations

- 离开屏幕的测试是卸下这个 widget 再挂上，不是完整的屏幕路由器
- 宽字体下位移和 k 控件会整行缩小；滑块测试按轨的实际宽度拖
- 没有 Home，没有最终验收

本阶段到此停止。不接 Home，不做最终验收，不把整个模拟器标成 READY。
