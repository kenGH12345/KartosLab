# ARCHITECTURE_PLAN — Gravity Force Lab: Basics

## 分层

```
MassModel (value, x, radius derived)
    ↓
GravityModel (constantSize, showForce, showDistance)
    ↓
ForceSolver.calculateForce / min/max force
    ↓
RenderData (spheres, arrows, puller frame, distance)
    ↓
Painters / Widgets
```

| 组件 | 职责 |
|---|---|
| MathCoordinateTransform | MVT scale 0.05，Y invert |
| InteractionController | 拖球 → snap → bounds |
| ForceArrowPainter | 双段线性箭头 |
| PullerWidget | figurePull PNG 帧 |
| MassControl | NumberPicker billion kg |
| CheckboxPanel | Force / Distance / Constant Size |

## 不抽跨 sim framework

ISLC 语义仅落在本 sim 目录。

## Layout

```
Scaffold + AppBar
NineGrid(center: FittedBox 768×464)
  PlayArea: spheres + arrows + distance + pullers
  Controls: mass pickers + checkboxes + Reset
```

## Assets

`assets/phet/gravity_force_lab_basics/pullers/figurePull_1..31.png`
