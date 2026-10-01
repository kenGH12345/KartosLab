# Bending Light — Final Release Report

判定链：Local Source `1.3.0-dev.0` → Source Fidelity → Behavior → Lifecycle → Visual QA → Issue Classification → **READY**。

官方参考仍是 phet-dev **1.2.5**。官方画面只用于 VERSION_DELTA，不用于改物理、默认状态或补造本地 source 没有的控件。

本轮只修了两处已证实的 source structure mismatch，没有新功能，没有面板 / 视口 / 滑条 / 物理重调。

1. 放置后的强度计主体不再是 `72×32` 纯绿块。它使用与工具箱相同的 `IntensityMeterBody`：未缩放 `150×95`，`scale 0.6`，线起点是缩放后 `rightBottom` 再上移 12。
2. 波传感器图表不再包 `IgnorePointer`，也不再有 source 没有的紫色拖动点。拖动手势在图表本体上。

## 1. Build / Test

- `dart analyze lib/bending_light`：**clean**（No issues found）
- `flutter test test/bending_light/`：**161 passed**（数量未减少）
- 已知崩溃：无
- 临时 Web 服务在截图后已关闭。进程退出码 1 是主动 `taskkill`，不是启动失败。

## 2. Source Fidelity

SOURCE MISMATCH = **0**。

| 项 | 结果 |
| --- | --- |
| Intro 标量 Snell | SOURCE MATCH |
| Prisms 矢量 Snell | SOURCE MATCH |
| TIR | SOURCE MATCH |
| Fresnel | SOURCE MATCH |
| dispersion | SOURCE MATCH |
| wave `cos(kx−ωt+φ)` | SOURCE MATCH |
| intensity 0/1/2 交点 | SOURCE MATCH |
| velocity 箭头常数 `1.5e-14`，零速度读数 `?` | SOURCE MATCH |
| reset | SOURCE MATCH |
| layoutBounds `834×504`，视口 `1024×618` | SOURCE MATCH |
| panel / toolbox / graph / protractor / controls | SOURCE MATCH |
| refractive-index slider、wavelength slider、medium selector、+/- | SOURCE MATCH（sun 渐变、下拉高光、箭头倒角仍是 VERSION_DELTA） |
| Ray / Wave | SOURCE MATCH |
| Checkbox 盒 | SOURCE MATCH |
| TimeControl 布局与模型时钟 | SOURCE MATCH |
| ProbeNode kite、传感器中心原点 | SOURCE MATCH |
| IntensityMeter 放置主体 + 线 | SOURCE MATCH（本轮补上） |
| Velocity toolbox `1.2`，放置 `2`，body `0.7` | SOURCE MATCH |
| WaveSensor 两条独立 WireNode | SOURCE MATCH |
| 圆形棱镜无 reference point → 无旋钮 | SOURCE MATCH |
| 有 reference point → `knob.png` | SOURCE MATCH |
| prism fill `mediumColorFactory`，玻璃 `0xABA9D4` | SOURCE MATCH |
| 白光 400–690 nm、步长 10、VisibleColor、D65、`sqrt(power)`、叠加、黑背景 | SOURCE MATCH |

## 3. Interaction

回归来自既有 widget / integration 测试（本轮全部重新通过）以及 Web 运行帧。没有改默认状态。

### Intro

- 激光开关、拖转、Reset All：`play_area_integration_test`、`reset_all_test`
- 介质切换（水 / 玻璃 / 空气）：`medium_control_test`
- 波长写入模型：`wavelength_test`
- 量角器读数跟随几何：`protractor_test`
- 入射、折射、TIR、正入射：`intro_snell_test`

### More Tools

- 工具箱拖出、放回删除、图标显隐：`prism_interaction_test` 的放回删除，以及各 sensor `enabled` 复位测试
- 强度探头移动后读数更新：`probe_test`
- 速度方向、大小、零速度 `?`：`probe_test` + `velocityReadout`
- 波传感器采样、时间步进、图表数据：`probe_test`、`wave_test`
- TimeControl play / pause / step / 慢速：`time_control_test`。时钟在 Model。View 没有第二套物理 Timer。

### Prisms

- 拖动改变光路、旋钮旋转不按象限夹紧、放回工具箱删除：`prism_interaction_test`
- 单色 / 多波长 / 白光：`white_light_test`、`dispersion_test`
- 圆形棱镜 `getReferencePoint()` 为 null，测试断言无旋钮

## 4. Reset / Lifecycle

- Intro、More Tools、Prisms 的 Reset All 测试把激光、介质、波长、传感器、时间和棱镜回到 source 默认值。
- Intro 与 More Tools 各有一个 `Ticker`，在 `initState` 创建，在 `dispose` 释放。只在 wave 视图或波传感器启用时调用 `model.step()`。
- Prisms 没有 ticker。白光不是第二套时钟。
- `colorMode` 在 `PrismsScreen` 和 `PrismsPlayArea` 的 `ListenableBuilder` 内读取。白光运行帧背景是黑色。
- 离开屏幕会 `dispose` model 与 ticker。测试 pump 会创建并销毁这些 State。没有第二套 listener 注册点。

## 5. Visual QA

证据：

- 历史基线：`requirements/req-bending-light/visual-qa/final8/`
- 本轮复核：`requirements/req-bending-light/visual-qa/release-gate/`
  - `GATE_INTRO.png`
  - `GATE_MORE_TOOLS.png`
  - `GATE_PRISMS.png`
  - `GATE_WHITE.png`
  - `GATE_GRAPH.png`
  - `GATE_SENSORS.png`
  - `GATE_TOOLBOX.png`

裁剪仍是 y=56、1024×618。没有伪造 joist 导航条。

白光帧：`(10,10)` 与 `(200,200)` 为 `(0,0,0)`，`(500,235)` 为 `(255,255,255)`。这是黑环境上的采样，不是空白页。

| Area | Result |
| --- | --- |
| Layout | PASS |
| Typography | PASS |
| Panel | PASS |
| Toolbox | PASS |
| Graph | PASS |
| Sensors | PASS |
| Protractor | PASS |
| White Light | PASS |
| Z-order | PASS |
| Clipping | PASS |

Source Match、Version Delta、Rendering Delta 分开记在第 8–10 节。RGB 差值没有当作 READY 阈值。

## 6. P0

无。**0**。

## 7. P1

无。**0**。

本轮开始时放置强度计主体和紫色波传感器拖动点是 source structure mismatch。两者已按本地节点改完，并重新跑过测试和分析。它们没有被改记成 P2。

## 8. P2

只保留不影响识别、交互、几何和 source 语义的项：

- Probe 玻璃高光用 `Color.lerp` 落实本地 `ProbeNode` 的亮度因子。本地树没有 `PaintColorProperty`。几何仍是 kite。
- 放置后的速度盒是平面 `#CF8702`。工具箱图标有渐变。尺寸、`scale 2`、箭头常数和 `?` 没有改。
- 激光主体是按既有喷嘴 / 机身尺寸画的金属渐变，不是把 `laser.png` 再描一遍。旋钮仍是 `knob.png`。开关、拖转不变。
- 平台抗锯齿和栅格，与 source 几何无关。

单色光线透明度不再列入 P2。`SingleColorLightCanvasNode` 的 alpha 是 `sqrt(power)`，功率 `<= 1e-6` 不画。

## 9. VERSION_DELTA

本地 `1.3.0-dev.0` 与官方 `1.2.5` 的差异。不是本地 source mismatch，本轮没有为截图补造：

- sun slider gradient
- dropdown highlight
- arrow-button bevel
- water / aqua radio fill
- checkbox mark path
- circular button bevel
- 官方 1.2.5 joist navigation bar。Flutter 模拟视口保持 `1024×618`。

## 10. NOT VERIFIED

核心功能和核心 source 结构没有 NOT VERIFIED。

- Android runtime：**NOT VERIFIED**。Web 通过、测试通过、分析干净，都不算 Android PASS。

## 11. Android

**NOT VERIFIED**

## 12. Home

**UNCHANGED**

`lib/screens/home_screen.dart` 与 `lib/main.dart` 没有 `bending_light` 引用。Home 路由、图标、分类都没有接。Home 上的「几何光学」不是本 sim。

## 13. Final Status

# READY

P0 = 0，P1 = 0，SOURCE MISMATCH = 0。测试 161 通过，分析干净。剩余差异只有 P2 和 VERSION_DELTA。

Bending Light 核心开发在此停止。不自动接 Home。下一阶段单独做 Home Integration 和全仓库回归。
