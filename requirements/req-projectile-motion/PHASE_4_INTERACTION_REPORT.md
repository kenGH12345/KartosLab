# PHASE 4 — Interaction Report · Projectile Motion

日期：2026-09-15

## 手势对照

| 交互 | 源码 | Flutter |
|---|---|---|
| 拖炮管改角 | CannonNode:451-491 相对 pivot 夹角 + snap 5°/Lab 1° | `PmScene._applyDrag` cannonAngle |
| height&lt;4 角度下限 | CannonNode:414-416 `[5,-5,-20,-40]` | `setCannonHeight` 同步抬升 |
| 拖炮座改高 | CannonNode:501-524 snap 整数米 | cannonHeight |
| 拖靶 | TargetNode:112-133 仅水平 snap 0.1 | target.x |
| Toolbox 拖出/拖回 | ToolboxPanel:86-127 | `Listener` + pointerRouter 按住即拖；离开后再回箱才吸附；无 tap-to-place |
| 卷尺 base/tip + 壳体 | MeasuringTapeNode + measuringTape.png | tapeBase / tapeTip；`PmMeasuringTapeHousing` Image.asset |
| DataProbe | DataProbeNode drag | probe；工具叠层在右侧面板之上 |
| Fire / Step / PlayPause / Eraser / Reset / Zoom | ScreenView | `PmFireButton` 等；ResetAll = 3D + ResetShape + 弹性回弹 |

**禁止** `atan2(dy,dx)` 直接当炮角：实现与源码一样用 **相对起始角增量**。

## 参数变化语义（已测）

- angle/speed/mass/diameter/Cd/height → 仅下一次发射
- gravity / airResistance / altitude → 立即改空中抛体（`changedInMidAir`）
- 物体类型 → 立即同步 mass/diameter/Cd

## 测试证据

`test/projectile_motion/projectile_motion_interaction_test.dart`：炮管 5° 吸附、炮座整数高度、靶 0.1 m 吸附、卷尺 tip 独立、fire/reset。

`test/projectile_motion/projectile_motion_widget_test.dart`：四 Tab、打开/销毁/再打开、Intro↔Lab 切换。

## 未做（P2）

- Lab `KeypadLayer` 精确数字键盘（滑条 + 拖拽已覆盖同一 Property）
- Vectors 面板 Cd 形状预览图标
