# Interaction Matrix · My Solar System

> 源码优先。父类手势细节标 `[二次证据]` / `[BLOCKED]`。

## 1. 可拖对象

| 对象 | 改什么 | 播放 | 轨迹 | 松手 |
|---|---|---|---|---|
| Body 位置 | `positionProperty` | 立即 pause | BodyNode start 清该体 path `[二次证据]` | saveStartingBodyInfo（若不可 Return）；Lab→CUSTOM |
| 速度矢箭头 | `velocityProperty` | pause | `[待确认 common]` | 同上 |
| 质量滑条/数字 | `massProperty` | **不** pause | 不自动清（非位置） | save；Lab→CUSTOM |
| More Data 数字 x/y/Vx/Vy | 对应分量 | 因 controlling pos/vel → pause | `clearPaths` | 同上 |
| Measuring Tape 两端 | 尺的模型点 | 不改轨道 | 无 | `[二次证据]` Kepler 可拖 |
| 面板 / Reset / ComboBox | UI | preset 切换会 pause | preset 清全部 path | — |

不可拖：CoM 红 X（只显示）。Intro 两体都可拖（太阳不钉死，与 Kepler 不同）。

## 2. 速度编辑

- Play Area：`DraggableVelocityVectorNode`（common）`[BLOCKED 细节]`
- `[二次证据 Kepler]` 最小模 1.055、snapToZero=false；重力矢不可拖
- Lab More Data：Vx/Vy 独立，范围 ±100 km/s
- 单位 km/s

## 3. 质量

- 滑条 step：`MASS_SLIDER_STEP` `[BLOCKED]`；constrain 到 step 整数倍
- UI min **0.1**（可大于 Body 内部 min）
- max：`body.massProperty.range.max` `[BLOCKED]`；文档约 300
- 视觉半径：`massToRadius` `[二次证据]`
- 无 Kepler「Always Circular / fixed size」模式
- `preventCollision` 在 `addNextBody` 时调用 `[BLOCKED 算法]`

## 4. 摄像机

| 操作 | 行为 |
|---|---|
| Zoom ± | `zoomLevel` 整数 1–6；scale 线性 25–125 |
| 无独立 pan 手势 | 未见 ScreenView 拖画布 |
| Follow CoM 按钮 | `followAndCenterCenterOfMass`：平移+去质心速度，清 path |
| Preset 加载 | `followCenterOfMass`：只去质心速度 |
| MVT | Y 向上；`centerOrbitOffset=(100,100)` `[BLOCKED 父类公式]` |
| World→Screen | `modelViewTransform.modelToViewPosition` |
| Screen→World | 拖拽反变换 `[二次证据]` |

## 5. Measuring Tape

实现全在 solar-system-common ScreenView。MSS 只提供 checkbox。  
`[二次证据 Kepler]` 默认模型 (0,1)–(1,1) AU，距离 AU，两端可拖。  
本树无法确认尺的 z-order 与单位字符串。

## 6. 播放 / 复位

| 控件 | 动作 |
|---|---|
| Play/Pause | `isPlayingProperty`；playingAllowed 来自父类 `[BLOCKED]`（MSS 无 Kepler 的 allowedOrbit 门闩） |
| Restart | `model.restart()`：t=0、恢复 startingBodyInfo、清碰撞旗标 |
| Reset All | Lab：先 CUSTOM 再 reset orbitalSystem + `super.reset` + `restart` |
| Return Bodies | **等于 restart**，不是把逃逸体瞬移回屏 |
| Clear | 只 reset time |
| Step | `stepOnce(1/8)` 仍跑完整 PEFRL 与碰撞 |

拖位置/速度期间强制 pause；松手 **不** 自动恢复 play。

## 7. Preset / 体数

- ComboBox 改 orbitalSystem → 见 source-analysis §3
- Bodies spinner ≠ active 数 → 循环 addNextBody / removeLastBody，pause，CUSTOM
- addNextBody：找第一个 inactive → reset → preventCollision → activate

## 8. Hit testing

`[二次证据]` 球 hit = 半径 + 10 view px。  
`getDragBoundsItems` 列出避让节点。  
`constrainDragPoint`：Kepler 描述为 interfaceBounds 减面板矩形后 `getClosestPoint`。**本树无实现 → `[BLOCKED]`，Build 不得编最近点算法。** 可做：夹在可见世界范围 / 记录 BLOCKED。

## 9. 无操作（看起来能做但不能）

- 不能在 Intro 加第 3 体
- 不能把质量滑到 preset 的 1e-6（UI min 0.1）
- 不能选 ComboBox 里隐藏的 OS1–4（除非 PhET-iO）
- CoM 不可拖
- Path 关闭时不累积点
- 重力矢不可编辑
