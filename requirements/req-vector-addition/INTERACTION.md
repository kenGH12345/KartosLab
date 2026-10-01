# Phase 6 · Interaction

> 源码：`vector-addition` **1.3.0-dev.0** · 本地唯一事实来源  
> 完成时间：2026-09-04

## 取证结论（不得回退）

| 主题 | 源码 | Flutter 实现 |
|---|---|---|
| Grab offset | `SoundDragListener` + `positionProperty`（tail/tip） | `grabOffsetView = pointer₀ − pos₀`；`newPos = pointer − grabOffset` |
| 禁止 jump | 按下不改 model | `onPointerDown` 只记录 offset，不写 tail/tip |
| Snap 时机 | `setTip/Tail…WithInvariants` 在 drag **move** | `moveTip/Tail…WithInvariants` on move |
| Cartesian | 整数格点 | `SnapPolicy`（未改） |
| Polar | 整数模长 + 5°；tail 吸引距离=1 | 同上 |
| Origin | `GraphOriginManipulator`；margin=5；diameter=0.8；`moveOriginToPoint` + roundSymmetric；向量保持 **view** tail | `VaDragKind.origin` + preserve-view |
| Pop | cursor 出 graph → `popOffOfGraph`；仍在 `activeVectors` | 同；**不删除** |
| Shadow | `!isOnGraph && !animateToToolbox`；offset (3.2, 2.1) α0.28 | `VaArrowRender.showShadow` |
| Selection | label `setHighlighted` | label 黄底 |
| Toolbox return | `animateToPoint` speed **75** → `returnToToolbox` | `VaReturnAnimation` + `completeReturnToToolbox` |
| Resultant | body OK；`isTipDraggable=false`；`isRemovable=false`；Sum 仅 `isOnGraph` | 未改 SumVector |
| Equations | `EquationsResultant ≠ SumVector`；operands tip 不可拖 | 未改 |
| Multi-touch | 源码无多指并发拖向量 | **未实现** |
| Hover | 无独立 hover 样式（仅 selected highlight + shadow） | 同 |

## 未改核心（硬约束）

- Canonical State（tail + xyComponents）
- `SumVector` / `EquationsResultant`
- `MathCoordinateTransform`
- `SnapPolicy`

## 视觉裁剪 vs isOnGraph

- `isOnGraph`：model 状态；false ≠ 删除
- Painter：`onGraph==true` 时 `clipRect(graphRect)`；off-graph 不裁剪（可画 shadow）
- Drag：cursor 出界才 pop；与 clip 独立

## Visual QA（轻量）

验证项：placement / drag continuity / snap / selected / shadow / toolbox return。  
未做大规模 typography / color 调整。

## Angle 方向（Phase 7 钉死）

- Model：`atan2` **CCW from +x**（注释 clockwise 作废）
- View arc：Flutter sweep = `-modelAngle`（对齐 `CurvedArrowNode`）
- 详见 `PHASE_7_CONTROLS.md` / `visual-qa/GEOMETRY_CALIBRATION.md`

## 测试

`test/vector_addition/phase6_interaction_test.dart` + Phase 7 suite：

`flutter test test/vector_addition/` → 全绿  
`flutter analyze lib/vector_addition` → 0 issues

## 下一阶段

→ **Phase 8** Visual / Screen Integration
