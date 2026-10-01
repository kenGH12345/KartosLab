# PHASE 3 — SYSTEMS SOURCE PARITY · Hooke's Law

> 对照：`phet sourses/hookes-law-main/hookes-law-main/js/systems`  
> 模型：Phase 1 `SeriesSystem` / `ParallelSystem`（View 不计算 keq、F1、F2、x1、x2、Feq）  
> 日期：2026-09-20

状态只使用 PASS / PARTIAL / FAIL / NOT VERIFIED。

| Feature | Source | Flutter | Status |
| --- | --- | --- | --- |
| Series creation | `SystemsModel` 同时创建 `SeriesSystem`，不因隐藏而销毁 | `SystemsModel.seriesSystem` 常驻；切到并联时 `Offstage`，不 dispose | PASS |
| Parallel creation | 同时创建 `ParallelSystem` | `SystemsModel.parallelSystem` 常驻 | PASS |
| Default visibility | `SystemsViewProperties.systemType` 默认 PARALLEL | `SystemsKind.parallel`；默认只绘制并联手、只显示 Top/Bottom Spring | PASS |
| Series isolation | 两套系统各自的 spring / arm | 拖并联到 0.25 m 后再拖串联，并联位移保持 0.25 m | PASS |
| Series F1 = F2 | 等效力写回两根弹簧，F1 = F2 | 不等 k（201 / 200）时 `left.appliedForce == right.appliedForce` | PASS |
| Series x total | xeq = x1 + x2 | 拖拽与力滑块后断言 x1 + x2 = xeq | PASS |
| Series keq | 1 / (1/k1 + 1/k2)，只读模型 | 左弹簧 +1 N/m 后 `equivalentSpring.springConstant` 等于该式 | PASS |
| Parallel x1 = x2 | 等效位移写回两根弹簧 | 力滑块与拖拽后 top/bottom/equivalent 位移相等 | PASS |
| Parallel F total | Feq = F1 + F2 | 不等 k 时分力不相等，且相加等于等效力 | PASS |
| Parallel keq | k1 + k2 | 上弹簧 201、下弹簧 200 时等效 401 | PASS |
| k range | 200–600 N/m，默认 200，inclusive | 使用 Phase 1 `springConstantRange`；默认 200 | PASS |
| k arrow step | 1 N/m | 点按 increment，k 变为 201，F 不变 | PASS |
| k slider step | 10 N/m | `IntroNumberControl.sliderInterval = springConstantSliderInterval`（10）；Systems 轨宽 120 | PASS |
| Force range | −100..100 N，默认 0 | 写 `equivalentSpring.setAppliedForce`；默认 0 | PASS |
| Force arrow step | 1 N | 同一 `IntroNumberControl`，`appliedForceArrowInterval` | PASS |
| Force slider step | 5 N | 滑块拖过 0.2 个轨宽得到 40 N（5 N 网格） | PASS |
| Total | 只切换箭头可见性，不改模型 | `springForceRepresentation` 在 View；Total 显示等效弹簧力箭头 | PASS |
| Components | 每根弹簧读自己的 springForce，禁止 total/2 | 并联不等 k 时分力不同；切换前后 `_snapshot` 不变 | PASS |
| Disabled radios | Spring Force 未勾选时不能改表示 | 未勾选时点 Components，表示保持 TOTAL | PASS |
| Applied force visibility | 独立于 Total/Components | 等效外力箭头只看 applied-force checkbox | PASS |
| Drag | 机械臂 pointer → 等效弹簧 right | `applyRoboticArmPointerLeft`，各系统自己的 arm | PASS |
| Snap | 只在拖拽输入 0.01 m；先 constrain 再 round | +30 px → 0.13 m；setter 本身不 snap | PASS |
| Clamp | 并联默认 keq 400 → ±0.25 m；串联默认 keq 100 → ±1.0 m | 测到并联 ±0.25 m / ±100 N，串联 +1.0 m / 100 N | PASS |
| Series drag relation | 拖外部臂仍 F1 = F2 且 x1 + x2 = xeq | 负向拖 −0.13 m 与正向夹紧后断言成立 | PASS |
| Parallel drag relation | 拖动保持 x1 = x2 | 正向、夹紧两端都断言 | PASS |
| Equilibrium | 一根等效平衡线，左端锁定，拖拽时位置不动 | 画在 `equivalent.equilibriumX`（1.5 m），不是每根弹簧一根 | PASS |
| Reset visible | Reset All 恢复当前系统与控件 | k、F、x、PARALLEL、TOTAL、Spring Force 关闭 | PASS |
| Reset hidden | 隐藏的系统也 reset | 先改并联再切串联再 Reset，并联回到 k=200、F=0、x=0 | PASS |
| Lifecycle | 离开不 reset、不传给 Intro/Energy；回来保持 | 卸下 widget 再挂上同一 model + viewProperties，k=201、series、components 仍在；dispose 不调用 `model.reset()` | PASS |
| Spring geometry | prolate cycloid，Systems 8 圈 | `xScaleForLength(..., loops: 8)`，右端 = length × 225；测试确认 8 圈尖端 | PASS |
| Spring colors | spring1 紫、spring2 黄 | 并联上/串联左 = spring1；并联下/串联右 = spring2。常量来自 `HookesLawColors.ts` | PASS |
| Series applied color | 左端外力箭头用 spring2 黄，不是蓝 | `leftApplied` 使用 `SystemsColors.spring2Middle` | PASS |
| Total arrow color | 等效弹簧力为单弹簧蓝 (0, 0, 255) | `SystemsColors.totalSpringForce` | PASS |
| Applied arrow color | (255, 85, 0) | `SystemsColors.appliedForce` | PASS |
| Force scale | UNIT_FORCE_X = 1.45，与 Intro 相同比例、不同局部原点 | `HookesLawConstants.unitForceX` | PASS |
| Displacement scale | UNIT_DISPLACEMENT_X = 225 | `systemsX` = wallWidth + 225 × meters | PASS |
| Stage | ScreenView 1024×618，本阶段不画 nav bar | `HookesLawStage` | PASS |
| Values | 力绝对值 + N，位移绝对值 3 位 + m；零力仍可显示数字 | 并联/串联的外力、总弹簧力、分力、位移都有读数；零位移居中 | PARTIAL |
| Layout | 系统 left=30、centerY=309；控件在墙下 25，水平居中于墙到机械臂 | 左缘 30，列垂直居中；控件左对齐并在超宽时 scaleDown，没有按 source 的 `maxWidth = arm.right − wall.left` 居中 | PARTIAL |
| Component arrow y | scenery `node.top` / `node.bottom` | 用 18 px 与 16+10 px 近似堆叠，不是测量后的节点顶边 | PARTIAL |
| Controls bevel | 箭头、滑块拇指、checkbox、radio 为立体件 | 沿用 Intro 的平面控件；本阶段不返工 | PARTIAL |
| Hinge highlight | 机械臂铰链高光 | 复用 Intro `paintRoboticArm`，高光仍缺 | PARTIAL |
| System type icon | 并联/串联示意图标 | 3 圈实色 cycloid 缩小，不是 source 图标节点 | PARTIAL |
| Keyboard drag | 机械臂可键盘调节 | 未接。与 Intro 相同的已知限制 | NOT VERIFIED |
| Pixel diff | 官方运行时逐像素 | 未做 | NOT VERIFIED |
