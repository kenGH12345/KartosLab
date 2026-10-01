# PHASE 4 — ENERGY LAYOUT AUDIT · Hooke's Law

> 舞台仍是 joist `ScreenView` 默认 **1024 × 618**。Energy 没有改这个 bounds。  
> 导航栏在 ScreenView 外面，本阶段不画。  
> 依据：`js/energy/view/EnergyScreenView.ts`、`EnergySystemNode.ts`、`EnergyBarGraph.ts`、`EnergyPlot.ts`、`ForcePlot.ts`、`XYPointPlot.ts`、`XYAxes.ts`。  
> 日期：2026-09-21

## Viewport

| 项 | 值 |
| --- | --- |
| layoutBounds | 0, 0, 1024, 618 |
| 缩放 | `min(viewW/1024, viewH/618)`，居中。`HookesLawStage` |
| Home 768×504 | 不用 |
| 导航栏 | 不画 |

## 系统节点

`EnergySystemNode` 的局部原点是弹簧与墙的连接点，y = 0。

| 项 | Source | Flutter |
| --- | --- | --- |
| 节点 left | `layoutBounds.left + 35` | 墙左缘 = 35。墙宽 25，所以连接点屏幕 x = 60 |
| 节点 bottom | `layoutBounds.bottom - 10` = 608 | 控件列底边 = 608 |
| 墙 | 25 × 170，右中贴在连接点 | 同样 |
| 弹簧 | 单簧 12 圈，蓝色，平衡长度 1.5 m | `paintColoredSpring`，`singleSpringLoops` |
| 机械臂右端 | 构造时 `right = spring.right + length` = 3.0 m | 同一 `RoboticArm` |
| 控件 | 墙底 + 10，水平居中于墙左到臂右，`spacing` 10 | 墙底 + 10。超宽时整行 scaleDown，没有按臂宽居中 |
| 力箭头 | 弹簧轴上方 50，单位长度 **0.4** | `energySceneForceAboveAxis = 50`，`energyUnitForceX = 0.4` |
| 位移箭头 | 弹簧轴下方 50，单位长度 225 | 与 Intro 位移箭头同一绘制，比例 225 |

柱图底边 = `systemNode.top - 35`。系统高度含控件，所以柱的 y 跟随测得的列高，而不是写死一个像素。

## 图

柱图始终在。模式只决定柱的 x，以及是否再画一张 XY 图。

| 模式 | 柱的 x | 另外的图 |
| --- | --- | --- |
| Bar Graph（默认） | 连接点 + 225 × equilibriumX。平衡时 = 60 + 337.5 = **397.5** | 无 |
| Energy Plot / Force Plot | `layoutBounds.left + 15` | 原点 x 与上式相同，原点 y = 柱轴的 y |

Energy Plot 的 `y` 把坐标原点放在柱轴上。Force Plot 的 source 用的是节点 `bottom` 对齐柱底，负半轴会把原点抬高。Flutter 把两张图的原点都放在柱轴上，负半轴向下画。这是 P1 锚点差，不是另一套比例。

## 三套比例，语义不同

| 常量 | 值 | 用在哪 |
| --- | --- | --- |
| `unitDisplacementX` | 225 | 弹簧、位移箭头、两张图的 x。1 m |
| `unitForceX` | 1.45 | Intro / Systems 场景力箭头。Energy 场景不用 |
| `energyUnitForceX` | 0.4 | **只**用于 Energy 场景里的施力箭头。1 N |
| `unitForceY` | 0.25 | **只**用于 Force Plot 的 y。1 N |
| `unitEnergyY` | 1.1 | 柱高和 Energy Plot 的 y。1 J |

图的 x 域：`225 × 1.1 × displacementRange` = **±247.5**。  
Energy Plot 的 y：0 … 250。  
Force Plot 的 y：**±125**（`FORCE_Y_AXIS_LENGTH / 2`，轴长 250）。

## 控件

右上可见性面板：`right - 10`，`top + 10`。  
Reset All：右、下各 15。  
k 轨宽 180，主刻度 100/200/300/400，次刻度 50。  
位移轨宽 180，主刻度 -1/0/1，次刻度 0.2 m。
