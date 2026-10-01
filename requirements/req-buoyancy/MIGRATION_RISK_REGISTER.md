# Migration Risk Register

复杂度是分项的，不是一个“中等”。

| Axis | Level | Why |
| --- | --- | --- |
| Model | VERY HIGH | p2 子步、多 basin、船瓶特例、插值属性 |
| View | VERY HIGH | THREE 场景、PBR 纹理、力箭头贴在投影点上 |
| Interaction | HIGH | 射线抓取、约束拖拽、池秤滑条、形状缓存切换 |
| Animation | HIGH | 几乎全部是物理时间。仅船舱排空有 `FILL_EMPTY_MULTIPLIER` |
| Asset | MEDIUM | 纹理在 ts 模块里，没有独立文件；尺寸未解码 |
| Cross-screen coupling | MEDIUM | 类共享，实例不共享。静态 Material 单例 |
| Shared dependency | VERY HIGH | common SHA 对不上；mobius/joist/p2/three 不在本地 |
| Platform integration | HIGH | WebGL 在源码里会为 mobile Safari 关抗锯齿、降 pixel ratio。Flutter 侧尚未验证 |

## Register

| Risk | Severity | Evidence | Impact | Next phase |
| --- | --- | --- | --- | --- |
| R1 Shared density-buoyancy-common | HIGH | lockfile `0295f8f6` 不在本地 git；HEAD `0c835c64`（2026-04-20） | 后续若发现 API 和 2025-02 buoyancy 不一致，要以当时文件为准，不能悄悄升级 | PHASE 1 开工前保持这份工作树。缺符号再标 BLOCKED |
| R2 Screen count | LOW | `buoyancy-main.ts` 5 屏，与 `screenNameKeys` 一致 | 不要做成 4 屏或把 Basics 算进来 | 保持 5 |
| R3 Physics model | VERY HIGH | postStep 浮力+粘滞+接触+速度钳制 | 画面像但实验不对 | Model 阶段按 `MODEL_RISK_REGISTER.md` 逐式移植，先单测力，不先画 UI |
| R4 Dynamic motion | HIGH | p2 `world.step`，不是 `y += v` | 沉降振荡会错 | 固定 1/120 子步 |
| R5 Fluid surface | HIGH | 瞬时水平；体积含被排开部分；船是第二 basin | 液位和浮力不一致 | 先池，后船 |
| R6 Force visualization | MEDIUM | `vectorZoom * 20`，接触力只显示 y | 箭头长度被 UI 自己算 | 箭头只读模型力 |
| R7 Drag / physics | HIGH | RevoluteConstraint maxForce 2500，拖拽不暂停物理 | 松手不沉降 | 保留 grab → constraint → release → step |
| R8 Measurement | MEDIUM | 秤是接触力 +y 之和；百分比由浮力反推 | 秤和标签各算各的 | 读模型属性 |
| R9 Procedural shapes | HIGH | 七种形状 + 鸭椭球排水 + 瓶船预计算曲线 | 用一种立方体碰撞体代替 | 每种 `getDisplacedVolume` 单独移植 |
| R10 Assets | MEDIUM | 位图在 ts 模块，PBR 多通道 | 用纯色顶替纹理 | 抽出 jpg。custom 才允许程序着色 |
| R11 Coordinates | HIGH | 模型米、+y 向上已确认。`modelToViewPoint` 在 mobius，不在本地。`DEFAULT_LAYOUT_BOUNDS` 数值 UNKNOWN。DebugView 用 600 px/m 且 Y 翻转，那不是主画面 | 布局和拾取全偏 | 取得 mobius 与 joist 常量后再做 layout。不要假设 1024×618 |
| R12 Reset | MEDIUM | Reset 不 new Model。船有第二按钮。`Pool.reset(false, false)` 两个 flag 未在本阶段展开 | Reset 后场景错 | 读 `Pool.reset` 与 `BlockSetModel.reset` 全文再写测试 |
| R13 Clock | MEDIUM | 内层 1/120 已知。外层帧 `dt` 与 pause 在 joist，UNKNOWN | 快放或漂移 | 不要用动画曲线代替 step |
| R14 Continuous physics | HIGH | 同 R4/R7 | “点一下就沉到底”的测试会放过错误 | 行为测试必须跑多帧 |
| R15 Cross-screen state | LOW | 五套 model 实例 | 低 | 屏间不共享质量 |
| R16 Existing Density solver | HIGH | `buoyancy_world.dart` 是弹簧指针，粘滞常数 8 | 把 Density 的错带进 Buoyancy | 并行实现，不改 `lib/density` |
| R17 Android performance | HIGH | 源码已经为 mobile Safari 降 THREE 负载。5 屏 × 多形状缓存 × PBR | 掉帧 | Android 阶段再测。PHASE 0：NOT VERIFIED |
| R18 CustomPainter / 3D | HIGH | 主画面不是一张 Painter 能等价的 2D 正交 | 伪 3D 和拾取对不上 | 视觉阶段单独立项，不在 PHASE 0 选方案 |
| R19 initialForceScale 未使用 | LOW | `DisplayProperties` 接收 `initialForceScale`（Shapes 传 1/4）但构造函数没有读它。zoom 档位写死 4（scale 1/16） | 若以后“修复”它会改变箭头 | 保持源码行为，不要自行接上 |
| R20 框架源码缺失 | HIGH | axon/dot/scenery/sun/joist/mobius/sherpa 都不在树里 | 像素布局、拾取射线、键盘具体按键无法从本地闭包 | P1。领域模型本身可以开始读 common |

## P0 / P1 / P2

P0：无。common 在本地，五屏类都在，主公式在本地文件里。

P1：

- common lockfile SHA 无法在本地对象库核对
- buoyancy 工作树无 git，`SOURCE_COMMIT` UNKNOWN
- `ScreenView.DEFAULT_LAYOUT_BOUNDS` 数值 UNKNOWN
- `THREEModelViewTransform` / `modelToViewPoint` 不在本地
- joist 帧时钟与 pause UNKNOWN
- p2 与 THREE 本体不在本地（行为由适配器描述）

P2：

- 纹理固有像素尺寸未解码
- `initialForceScale` 死参数
- scenery-phet 键盘帮助的具体按键不在本地
- `Pool.reset` 的两个布尔参数、`BlockSetModel.reset` 全文未逐行抄进本文
- 音频共享库是否还有 grab 音效：本地文件没有
