# Common Domain Map

Buoyancy 的实验代码几乎全在 `density-buoyancy-common`。`buoyancy/js` 只有命名空间、字符串和 5 个 Screen 壳。

## Shared by every Buoyancy screen

| Domain | Source | Used by |
| --- | --- | --- |
| Model root | `common/model/DensityBuoyancyModel.ts` | 五屏 |
| Physics adapter | `common/model/PhysicsEngine.ts` | 五屏。p2.World，`applyGravity = false`，`fixedRotation = true` |
| Pool | `common/model/Pool.ts` extends `Basin` | 五屏。`usePoolScale` 默认 true |
| Mass | `common/model/Mass.ts` | 所有物体 |
| Material | `common/model/Material.ts` | 固体、液体、mystery |
| Gravity | `common/model/Gravity.ts` + `GravityProperty` | 五屏都有重力场。只有 Lab 把 `gravityProperty` 做成可操作控件（`isGravityPropertyInstrumented: true`） |
| Scale | `common/model/Scale.ts`，`PoolScale.ts` | 地面秤 + 池中秤 |
| Constants | `common/DensityBuoyancyCommonConstants.ts` | 池初始体积、流体密度范围、边距 |
| Query defaults | `common/DensityBuoyancyCommonQueryParameters.ts` | p2 步长、刚度、粘滞、gEarth |
| Screen view base | `common/view/DensityBuoyancyScreenView.ts` | 天空、灯光、池网格、流体、拖拽射线、Reset All |
| Buoyancy view base | `buoyancy/view/BuoyancyScreenView.ts` | 力面板、池秤滑条、相机 lookAt |
| Display flags | `buoyancy/view/DisplayProperties.ts` | 力、质量、深度线、矢量缩放 |
| Force arrows | `common/view/ForceDiagramNode.ts` | 重力 / 浮力 / 接触力 |
| Credits | `common/DensityBuoyancyCommonCredits.ts` | `soundDesign: ''` |

`js/density/**` 是 Density 模拟，Buoyancy 入口不引用。`js/buoyancy-basics/**` 是 Buoyancy Basics，本次入口不引用。

## Screen-specific

| Piece | Only used by |
| --- | --- |
| `CompareBlockSetModel` + `BlockSet` | Compare（Basics 也用同一 Compare 类，但不在本次入口） |
| `BuoyancyExploreModel` cubes A/B + `TwoBlockMode` | Explore |
| `BuoyancyLabModel.fluidDisplacedVolumeProperty` | Lab |
| `MassShape` + `BuoyancyShapeModel` + Cone/Ellipsoid/Cylinders/Duck | Shapes |
| `Bottle` / `Boat` / `BoatBasin` / `BuoyancyApplicationsModel.updateFluid` override | Applications |

## Pool geometry (model meters)

`DensityBuoyancyModel.ts`：

```text
POOL_VOLUME = 0.15 m^3
POOL_WIDTH  = 0.9 m
POOL_DEPTH  = 0.4 m
POOL_HEIGHT = 0.15 / 0.9 / 0.4
poolBounds  = x [-0.45, 0.45], y [-height, 0], z [-0.2, 0.2]
groundBounds = x [-10, 10], y [-10, 0], z [-2, front]
invisibleBarrierBounds default = x [-0.875, 0.875], y [-4, 4], z pool depth
```

`query poolWidthMultiplier` 默认 1。不是 1 时重算池宽，开发参数，学生路径不用。

物理容器是 `groundPoints` 多边形（地面 + 池腔）和 barrier 多边形，都是 p2 静态刚体。视图容器是 `PoolMesh` / `GroundFrontMesh` / `GroundTopMesh`，读同一 `poolBounds`。

## Fluid

`FluidSelectionType`：`justWater` | `simple` | `all`。

| Screen | Type | Materials |
| --- | --- | --- |
| Compare | `simple` | `BUOYANCY_FLUID_MATERIALS`：Gasoline, Oil, Water, Seawater, Honey, Mercury |
| Explore, Lab, Shapes, Applications | `all` | 上面六种 + Custom + Fluid A–F |

初始液体都是 `Material.WATER`。Custom 密度范围 `FLUID_DENSITY_RANGE_PER_M3` = `(0.5 .. 15) kg/L * 1000` = `500 .. 15000 kg/m^3`。

液面永远水平。`Basin.computeY()` 由体积和容器截面积得到 `fluidY`。流体不模拟波动。

初始目标体积 `DESIRED_STARTING_POOL_VOLUME = 0.1 m^3`（100 L）。若有池秤，构造时减去秤的体积再 `setInitialValue`，使秤浸入后液位读数仍是目标值。

## What multiple screens share at runtime

静态 `Material.*` 与 `Gravity.*` 是进程级单例。五个 Screen 的 Pool、Mass、engine 各自一份。切换屏幕不把 Compare 的块带到 Explore。Reset 只重置当前 model（`ResetAllButton` listener 调 `model.reset()`）。
