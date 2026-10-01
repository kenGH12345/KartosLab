# PHASE 3 — View Report · Projectile Motion

日期：2026-09-15
源码：projectile-motion **1.1.0-dev.41**

## 实现文件

| 文件 | 对应源码 |
|---|---|
| `painters/scene_painters.dart` | BackgroundNode.ts（天空/草/路/虚线/david/flatirons） |
| `painters/cannon_painter.dart` | CannonNode.ts（圆柱/炮管/底座/高度尺/十字/火焰） |
| `painters/trajectory_painter.dart` | TrajectoryNode + ProjectileNode + FBD |
| `painters/tools_painters.dart` | TargetNode / MeasuringTapeNode / DataProbeNode |
| `view/projectile_view_factory.dart` | ProjectileObjectViewFactory.ts |
| `view/pm_image_cache.dart` | 原版 PNG → `ui.Image` |
| `widgets/pm_scene.dart` | 图层顺序：背景 → 靶 → 炮 → 轨迹 → 工具 |
| `widgets/pm_screen_layout.dart` | ScreenView:504-515 控件锚点 |
| `widgets/pm_controls.dart` / `pm_buttons.dart` / `pm_panels.dart` | sun/scenery-phet chrome |
| `widgets/pm_simulation_shell.dart` | layoutBounds 1024×618 FittedBox |

## 坐标变换

`PmTransform` ≡ `ModelViewTransform2.createSinglePointScaleInvertedYMapping(ZERO, (70,510), 30·zoom)`

- Model X 正右、Y 正上；Screen X 正右、Y 正下
- 发射点视图 = `modelToView(0, cannonHeight)`，与初速度方向共用同一 θ

## 图层（ScreenView:454-472）

`background → target → david → cannon → trajectories → chrome → tape/probe`

Flutter 将 david 并入背景 painter；炮在轨迹之下，保证抛体盖住炮口。

## 本轮 P1 修复（相对首轮 capture）

1. 圆柱 `ellipticalArc` 方向：顶椭圆从左 **逆时针经下沿** 到右（CannonNode:368），此前顺时针扫上沿画成锥体。
2. 色板对齐源码：圆柱灰 rgb(230/103)、面板 rgb(255,238,218)、cue 箭头 rgb(100,200,255)、向量绿/黄/黑、apex `DOT_GREEN`。
3. 测试/绘制字体指定 `Arial`（避免 Ahem 黑块覆盖炮/靶）。
4. Fire 按钮改走 `PmImageCache`（widget test 中 `Image.asset` 未解码）。
5. Zoom 按钮改为横向（MagnifyingGlassZoomButtonGroup spacing=X_MARGIN）。

## 资源

见 `ASSET_MAP.md`。Substituted Assets = **0**。
