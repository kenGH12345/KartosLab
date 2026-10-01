# PHASE 4 — ENERGY SOURCE PARITY · Hooke's Law

> 对照：`phet sourses/hookes-law-main/hookes-law-main/js/energy`  
> 模型：Phase 1 `EnergyModel` / `Spring`（位移是自变量）  
> 日期：2026-09-21

状态只使用 PASS / PARTIAL / FAIL / NOT VERIFIED。

| Feature | PhET Source | Flutter | Status |
| --- | --- | --- | --- |
| Single spring | `EnergyModel` 只有一个 `SingleSpringSystem`，位移区间 −1…1，k 100…400 默认 100 | `SingleSpringSystem.energy()` | PASS |
| Displacement input | 滑块和箭头写 `displacementProperty` | `setDisplacement`。箭头 0.01 m，滑块 0.05 m | PASS |
| k behavior | 改 k 保持 x，重算 F = kx、E = kx²/2 | x=0.5、k 200→400 时 x 仍为 0.5，F 100→200，E 25→50 | PASS |
| Negative x | F = kx < 0，E > 0，springForce = −F > 0 | 同一断言 | PASS |
| Zero | F、springForce、E 都是 0；零高度柱不画 | 柱矩形隐藏；三角形在显示位移四舍五入到 0 时隐藏 | PASS |
| Drag | 机械臂 0.01 m，先 constrain 再 snap，不写进 `setDisplacement` | `applyRoboticArmPointerLeft`；`setDisplacement(0.013)` 保持 0.013 | PASS |
| Clamp | 位移闭区间 ±1 | 拖到两端为 ±1；直接写入 2 被夹到 1 | PASS |
| Scene force scale | `ENERGY_UNIT_FORCE_X = 0.4` | 场景箭头用 0.4，不用 1.45 | PASS |
| Bar Graph | 默认；E×1.1 向上；E=0 不画柱；切到其它图时柱移到 left+15 | 默认柱；其它模式柱仍在，x 改为 15 | PASS |
| Energy Plot | 两段 `quadraticCurveTo`，y 单位 1.1，线宽 3 | `EnergyGraphData.energyPlotBezier`，Painter 只描这条路径 | PASS |
| Force Plot | 直线 F=kx，y 单位 0.25，范围 ±125 | `forcePlotLine`；与场景 0.4、Intro 1.45 都不同 | PASS |
| Triangle area | 原点、(x,0)、(x,F)；仅 Force Plot 且 Energy 勾选且显示位移 ≠ 0 | 同一条件。勾选不改模型 | PASS |
| Graph switch | 只改 view `graphProperty`，不 reset x/k | 切 Energy Plot / Force Plot 后 x、k、E 不变 | PASS |
| Reset | 模型 reset，图回到 BAR_GRAPH，能量勾选 false | x=0、k=100、柱图、勾选关闭 | PASS |
| Leave screen | 切屏不 reset | 卸下再挂上同一 model 与 view，x、k、图模式还在 | PASS |
| Isolation | 三屏模型不共享 | Intro 的 F、Systems 的 k 与 Energy 的 x 互不影响 | PASS |
| Values | 始终可点；图上和矢量上的数字 | 勾选没有 Intro 那种“至少一个矢量”限制。图上数字有，避让规则简化 | PARTIAL |
| Layout | 控件居中于墙到机械臂；Force Plot 用节点 bottom 对齐 | 控件左对齐并在超宽时缩小。两张图的原点都放在柱轴上 | PARTIAL |
| Label dodge | `XYPointPlot` 的 X_SPACING / Y_SPACING | 只做了上下侧的粗放置 | PARTIAL |
| Controls bevel | 立体箭头、滑块、checkbox、radio | 沿用平面控件 | PARTIAL |
| Hinge highlight | 铰链高光 | 复用 Intro 机械臂，高光仍缺 | PARTIAL |
| Keyboard | 位移键盘步进 0.10 / 0.01 / 0.20 | 未接 | NOT VERIFIED |
| Pixel diff | 官方运行时 | 未做 | NOT VERIFIED |
