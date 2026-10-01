# SYSTEMS Visual QA · Hooke's Law Phase 3

> 日期：2026-09-20  
> 方法：对照 `js/systems/view` 的节点、颜色常量和 widget 测试。  
> 没有对官方运行时做像素 diff。下面不是 pixel-perfect 结论。

判定用语：`[模型已对齐]` `[布局近似]` `[动态绘制已对齐]` `[视觉债务]`

## A. Default Parallel

- `[模型已对齐]` 默认并联。串联模型已存在但 `Offstage`。
- `[动态绘制已对齐]` 上弹簧 spring1 紫、下弹簧 spring2 黄，各 8 圈 prolate cycloid。墙高 300。桁架线宽 4、重叠 10。nib 黑色。
- `[布局近似]` 系统左缘 30，列在 1024×618 舞台里垂直居中。
- 默认不画力箭头、位移箭头、平衡线。

## B. Serial

- `[动态绘制已对齐]` 两根弹簧首尾相接，墙高 170。左紫、右黄。nib 为 spring2 黄。
- `[模型已对齐]` 一根机械臂绑在等效弹簧上，不是两套 Intro 单簧。
- `[布局近似]` 控件是 Left | separator | Right，再加 Applied Force。超宽时整行 scaleDown，不是 source 那种居中在墙到机械臂之间。

## C. Total

- `[模型已对齐]` Spring Force 打开且表示为 Total 时，只显示等效弹簧力（蓝）。模型数值不变。
- 等效外力（橙）仍由 Applied Force checkbox 单独控制。

## D. Components

- `[模型已对齐]` 显示各弹簧自己的 springForce。并联不等 k 时两根分力不同。
- 串联左弹簧力为紫，左端外力为黄，右弹簧力为黄。
- `[布局近似]` 分力箭头的垂直间距是近似值（并联 ±18 px，串联 16+10 px）。

## E. Positive force

- `[模型已对齐]` 滑块 0.2 轨宽 → 40 N。并联 x1 = x2，F1 + F2 = Feq。串联 F1 = F2，x1 + x2 = xeq。
- 箭头方向读模型符号，弹簧力为 −F。

## F. Negative force

- `[模型已对齐]` 并联拖到左极限：位移 −0.25 m，力 −100 N，x1 仍等于 x2。
- 串联负向拖 −0.13 m 时 F1 仍等于 F2。

## G. Different k1/k2

- `[模型已对齐]` 并联 201 与 200：分力不相等。串联 201 与 200：力仍相等，位移不再相等，keq 来自模型。

## H. Dragged state

- `[模型已对齐]` 松手停住。没有回弹、振荡或缓动。
- 0.01 m snap 只发生在拖拽输入。夹紧在 snap 之前，与 `applyRoboticArmPointerLeft` 一致。
- `[视觉债务]` 铰链高光仍缺。

## I. Reset

- `[模型已对齐]` Reset All 同时恢复并联、串联、k、力、位移，以及 PARALLEL / TOTAL / checkbox。
- 隐藏系统也会回到默认。

## 继承的 Intro 视觉债务（本阶段不返工）

- 箭头按钮无斜面
- slider thumb 无斜面
- checkbox 无斜面
- radio 无斜面
- 铰链高光

## Systems 自己的视觉差

- 数值标签横坐标按 9 px/字符估算
- 位移数字在箭头下方 16 px，不是测量 `arrow.bottom + 2`
- 系统类型图标是缩小的 3 圈弹簧，不是 source 图标
- 控件行左对齐；标签很宽时会缩小，轨在布局坐标里仍是 120 / 180，缩小只为塞进舞台
