# FUNCTIONAL_GAP_CLOSURE · Collision Lab

> 日期：2026-09-03（Gap Closure 轮）  
> 本地源码：`1.2.0-dev.0`  
> 原则：不重做 CollisionEngine / stick / 负步进；只补交互与视觉缺口

---

## 0. 本轮补齐结论

| 缺口 | 源码结论 | 实现状态 |
|---|---|---|
| Velocity Vector Tip Drag | **存在** · 全屏 · `BallVelocityVectorNode.js` | **[行为一致]** |
| ScaleBar | **存在** · 全屏 · `PlayAreaScaleBarNode` 固定 0.5 m | **[行为一致]** / **[视觉近似]** |
| bump / repel | **存在** · `BallSystem.bumpBallAwayFromOthers` / `repelBalls` | **[源码一致]** |

---

## 1. Velocity Tip Drag（源码证据 → 实现）

**文件**：`js/common/view/BallVelocityVectorNode.js`

| 项 | 源码 | Flutter |
|---|---|---|
| Screen | **全部 4 屏**（Velocity checkbox 开启时） | 同左 |
| Hit target | tip circle r=13 view px | `velocityTipCircleRadius=13` |
| 可见条件 | **仅暂停**时 tip 可见可拖 | `velocityTipsInteractive` |
| Mapping | `viewToModelDelta(tipOffset)` → velocity | `ClMvt.viewToModelDelta` |
| Bounds | `VELOCITY_RANGE` (−3…3) 对 x,y 分别 clamp | 同左 |
| 1D | 只 `setXVelocity` | 同左 |
| Position | **不改** | 同左 |
| Pause | tip 仅 paused；userControlled 触发 Model 暂停+elapsed=0 | Controller `_beginUserControl` |
| End | round 到 `10^-DISPLAY_DECIMAL_PLACES` | 同左 |
| 数据流 | Pointer → Controller → Ball.velocity → Render | **禁止** Widget 自改 velocity |

---

## 2. ScaleBar

**文件**：`PlayAreaScaleBarNode.js` + `CollisionLabScreenView.js:108-116`

| 项 | 源码 | Flutter |
|---|---|---|
| Screen | **全部** | 同左 |
| Length | **0.5 m** 常量 | `scaleBarLengthMeters` |
| Zoom | **无**关系 | 无 |
| Orientation | 1D 水平 · 2D 竖直 | Axis.horizontal / vertical |
| Placement | 1D: playArea 顶上方；2D: 左侧 | Positioned 相对 playAreaRect |
| Label | `"0.5 m"` | 同左 |
| Visibility | 始终 | 始终 |

---

## 3. bump / repel

**[已确认：当前源码存在该功能]** — 非臆造。

| API | 触发 | Flutter |
|---|---|---|
| `bumpBallAwayFromOthers` | 拖球结束、Keypad/质量改完、滑条质量 | `endDrag` / `setMass` / `setPosition` |
| `bumpBallIntoPlayArea` | reflecting border 时夹入 bounds | 同左 |
| `repelBalls` | bump 循环 >10 | 同左 |
| `moveBallNextToBall` | 沿方向向量贴邻 | `BallUtils.moveBallNextToBall` |

重叠判定：距离 **严格 &lt;** r1+r2（相切不算重叠）— **[源码一致]**。

---

## 4. 四 Screen 验收矩阵

| Screen | default | interaction | collision | reset |
|---|---|---|---|---|
| Intro | ✅ 无边 · 2 球 | tip drag · ball drag · bump | 既有物理测 | ✅ |
| Explore 1D | ✅ tick · y=0 | tip · step/reverse | e=0 粘连测 | ✅ |
| Explore 2D | ✅ border · multi | tip · grid · bump | 弹性测 | ✅ |
| Inelastic | ✅ stick/slip | drag · bump | cluster ω 测 | ✅ |

---

## 5. 测试

```
flutter test test/collision_lab
```

| 套件 | 结果 |
|---|---|
| `physics_test.dart` | 12 passed（未降标准） |
| `gap_closure_test.dart` | tip / ScaleBar / bump / lifecycle |
| `visual_capture_test.dart` | 4 play-area PNG |
| `flutter analyze lib/collision_lab` | No issues |

合计功能测：**26** + visual **4**。

---

## 6. 仍非阻塞

| 项 | 标记 |
|---|---|
| ScaleBar / tip 微几何 vs PhET | **[视觉近似]** |
| 本机浏览器 runtime overlay 逐像素 | **[待确认]**（有 assets 参考 + Flutter capture） |
| 速度矢量拖尖端时 leader-lines | **[待实现]**（源码有 LeaderLines；非本轮阻塞） |
| 球旁 speed/momentum NumberDisplay | **[视觉近似]** |

**无 BLOCKED。** 未把「暂时没做」写成「有意差异」。
