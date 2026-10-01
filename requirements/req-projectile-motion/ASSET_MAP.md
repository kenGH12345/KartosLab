# ASSET_MAP — Projectile Motion

> 规则依据：`.cursor/rules/85-phet-original-assets.mdc`。
> 原版来源：`phet sourses/projectile-motion-main/projectile-motion-main`（mipmaps/ + images/）。
> **Substituted Assets = 0**（所有位图均直接复用原版 PNG；程序绘制部分按原源码 Path/Gradient 重建）。

## 1. 位图资源（Original → Flutter）

| Original Path (PhET) | Used By (TS) | Flutter Path | Scale | Rotation | Crop | Opacity | Transform |
|---|---|---|---|---|---|---|---|
| mipmaps/cannonBarrel.png | CannonNode.ts (barrel) | assets/simulations/projectile_motion/cannonBarrel.png | cannonLength/275 (view m→px) | -θ (绕 pivot) | 无 | 1 | pivot 对齐 muzzle 基座 |
| mipmaps/cannonBarrelTop.png | CannonNode.ts (barrelTop) | .../cannonBarrelTop.png | 同上 | -θ | 无 | 1 | 同上 |
| mipmaps/cannonBaseTop.png | CannonNode.ts (baseTop) | .../cannonBaseTop.png | 同上 | 0 | 无 | 1 | origin (0,h) |
| mipmaps/cannonBaseBottom.png | CannonNode.ts (baseBottom) | .../cannonBaseBottom.png | 同上 | 0 | 无 | 1 | origin (0,h) |
| mipmaps/tankShell.png | ProjectileObjectViewFactory (tankShell) | .../tankShell.png | diameter 等比 | 飞行方向角 | 无 | 1 | 中心 = 抛体质心 |
| mipmaps/pumpkin1.png | 同上 (pumpkin flying) | .../pumpkin1.png | diameter 等比 | 飞行方向角 | 无 | 1 | 同上 |
| mipmaps/pumpkin2.png | 同上 (pumpkin landed) | .../pumpkin2.png | diameter 等比 | 0 | 无 | 1 | bottom 对齐地面 |
| mipmaps/car1.png / car2.png | 同上 (buick flying/landed) | .../car1.png / car2.png | diameter 等比 | 飞行方向 / 0 | 无 | 1 | 同上 |
| mipmaps/human1.png / human2.png | 同上 (david flying/landed) | .../human1.png / human2.png | diameter 等比 | 飞行方向 / 0 | 无 | 1 | 同上 |
| mipmaps/piano1.png / piano2.png | 同上 (piano flying/landed) | .../piano1.png / piano2.png | diameter 等比 | 飞行方向 / 0 | 无 | 1 | 同上 |
| mipmaps/football.png | 同上 (football) | .../football.png | diameter 等比 | 飞行方向角 | 无 | 1 | 中心 |
| mipmaps/baseball.png | 同上 (baseball)；cannonball 为程序绘制圆 | .../baseball.png | diameter 等比 | 0 | 无 | 1 | 中心 |
| images/david.png | BackgroundNode.ts (david, 2 m @ x=7) | .../david.png | 2 m 高 | 0 | 无 | 1 | bottom 对齐地面 |
| images/flatirons.png | BackgroundNode.ts (altitude∈[1500,1700]) | .../flatirons.png | 宽 450 view px | 0 | 无 | 1 | bottom=VIEW_ORIGIN.y, left=modelToViewX(8) |
| images/fireButton.png | ScreenView (fire button) | .../fireButton.png | 原始尺寸 | 0 | 无 | 1 | 底部工具栏 |
| images/fireMultipleButton.png | ScreenView | .../fireMultipleButton.png | （备用，未启用） | — | — | — | — |
| scenery-phet/images/measuringTape.png | MeasuringTapeNode（卷尺壳体） | .../measuringTape.png | baseScale 0.8；toolbox 再 ×0.8 | 绕 rightBottom | 无 | 1 | rightBottom = base；tip 连线 |
| mipmaps/uncenteredHuman1.png | IntroScreen icon | .../uncenteredHuman1.png | tab 图标 22px | 0 | 无 | 1 | home tab |

## 2. 程序绘制（源码 Path/Shape/Gradient → Flutter Canvas）

| 原版 Node | 原版实现 | Flutter 实现 | 状态 |
|---|---|---|---|
| 天空渐变 (0,0)→(0,2h/3) #02ACE4→#CFECFC | BackgroundNode:64-66 LinearGradient | `ui.Gradient.linear` in `PmBackgroundPainter` | [原版资源一致] |
| 草地 / 路面 / 黄虚线 | BackgroundNode:68-71 | `PmBackgroundPainter` Rect + 虚线 | [原版资源一致] |
| 炮圆柱 + 洞口椭圆渐变 | CannonNode:117-137 | `PmCannonPainter` `ui.Gradient.linear` | [原版资源一致] |
| 高度/角度指示器 + muzzle flash | CannonNode:150-360 | `PmCannonPainter` | [动态绘制已对齐] |
| 轨迹线 / 时间点 / apex 红点 | TrajectoryNode | `PmTrajectoriesPainter` | [动态绘制已对齐] |
| 速度/加速度/力向量箭头 | VectorNode (arrow shape) | `PmTrajectoriesPainter._drawArrow` | [动态绘制已对齐] |
| 卷尺壳体 + 灰线 + 橙十字 | MeasuringTapeNode + measuringTape.png | `PmToolsPainter` / `PmMeasuringTapeIconPainter` | [原版资源一致] |
| DataProbe 蓝面板 + Time/Range/Height 白盒 | DataProbeNode.createIcon / createInformationBox | `PmToolsPainter` / `PmDataProbeIconPainter` | [原版资源一致] |
| 靶心（同心椭圆 + 星分） | TargetNode | `PmTargetPainter` | [动态绘制已对齐] |
| 面板 / slider / checkbox / radio / comboBox chrome | sun/ Panel, HSlider 等 | `pm_controls.dart` CustomPainter | [布局已对齐] |
| Play/Pause/Step/Eraser/Zoom/TimeSpeed 按钮 | scenery-phet buttons | `pm_buttons.dart` CustomPainter | [布局已对齐] |
| fire 按钮背景 | images/fireButton.png | `Image.asset` + 叠加 | [原版资源一致] |

## 3. Substituted Assets

**0 项。** 所有位图直接来自本地 PhET 源码 `mipmaps/`、`images/`；程序绘制元素全部按源码几何/渐变参数重建，无 Material Icon / Emoji / 网络图 / AI 图。

## 4. 已知偏差（非替代，仅为缩放适配）

- Tab 图标（home 页）使用原版 PNG 缩放至 22px，PhET 原版为 NavBar 位图，语义一致。
- `cannonball` 抛体在原版为程序绘制圆（ProjectileObjectViewFactory），Flutter 同样程序绘制，未用 baseball.png 冒充。
