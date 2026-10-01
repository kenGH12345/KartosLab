# ENERGY Visual QA · Hooke's Law Phase 4

> 日期：2026-09-21  
> 方法：对照 `js/energy/view` 和 widget 测试。没有官方运行时像素 diff。

判定：`[模型已对齐]` `[布局近似]` `[动态绘制已对齐]` `[视觉债务]`

## A. Default Bar Graph

- `[模型已对齐]` x=0，k=100，F=0，E=0。柱矩形不画。纵轴标题 Potential Energy，轴长 250。
- `[动态绘制已对齐]` 一根 12 圈蓝色弹簧。没有第二根弹簧。
- `[布局近似]` 墙左缘 35，列底边距舞台底 10。

## B. Positive displacement Bar Graph

- `[模型已对齐]` 滑块到 x=0.5（k=100）时 F=50，E=12.5。柱高 = E × 1.1。
- 柱从 0 向上长。

## C. Negative displacement Bar Graph

- `[模型已对齐]` x<0 时 F<0，E>0。柱仍然向上，不会出现负能量柱。

## D. Energy Plot

- `[动态绘制已对齐]` 两段二次贝塞尔，不是折线，不是图表库。颜色 (0, 204, 255)，线宽 3。
- 当前点读 `potentialEnergy`，y 乘 1.1。点是弹簧中蓝，半径 5。
- 曲线裁在 x ±247.5、y 0…250 内。

## E. Force Plot

- `[动态绘制已对齐]` 直线用 `forcePlotLine`。正位移在上（view y 为负）。
- y 比例 0.25，不是场景箭头的 0.4，也不是 Intro 的 1.45。
- 勾选 Energy 后画三角形。x 显示为 0 时不画。

## F. k changed

- `[模型已对齐]` x 固定时增大 k，F 和 E 变大，柱和曲线跟着模型重画。x 不变。

## G. Zero displacement

- 箭头不画。柱不画。三角形不画。E 和 F 都是 0。

## H. Reset

- `[模型已对齐]` 回到 x=0、k=100、柱图、能量勾选关闭。

## I. Dragged state

- `[模型已对齐]` 松手停住。+30 px → 0.13 m。两端夹在 ±1 m。没有回弹。

## J. Graph switching

- 切图不改 x、k、F、E。柱图始终还在；Energy / Force 是额外的一张图。切到后两张时柱移到 x=15。

## 视觉差

- 控件无斜面，铰链无高光（Intro / Systems 同一笔债）
- 数值避让、Force Plot 相对柱底的纵向锚点是近似
- 控件行左对齐，宽标签时会缩小
- 系统类型以外的单选是平面圆
