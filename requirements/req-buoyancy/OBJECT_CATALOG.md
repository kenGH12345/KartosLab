# Object Catalog

单位：质量 kg，体积 m³，密度 kg/m³。体积控件显示升（1 m³ = 1000 L），见 `LITERS_IN_CUBIC_METER`。

形状是否进入物理：排水体积由 `Mass.getDisplacedVolume(fluidY)` 按形状计算。Duck 的池排水按椭球，网格是单独的 THREE 模型（`doc/implementation-notes.md`）。没有阻力随形状变化的独立 drag coefficient。粘滞力用浸没比例和流体粘度，不用形状阻力系数。

## Materials (solids used by Buoyancy)

来源 `Material.ts`。`packageJSON.name === 'buoyancy'` 才挂 tandem 的项，在本模拟里会实例化。

| materialId | density | viscosity | hidden | notes |
| --- | ---: | ---: | --- | --- |
| styrofoam | 150 | 1e-3 | no | SIMPLE |
| wood | 400 | 1e-3 | no | SIMPLE，Explore/Lab/Shapes 默认 |
| ice | 919 | 1e-3 | no | SIMPLE |
| pvc | 1440 | 1e-3 | no | SIMPLE |
| brick | 2000 | 1e-3 | no | SIMPLE |
| aluminum | 2700 | 1e-3 | no | SIMPLE |
| boatHull | 2700 | 1e-3 | no | 名称不同，密度等于铝 |
| concrete | 3150 | 1e-3 | no | 纯色 |
| copper | 8960 | 1e-3 | no | |
| gold | 19320 | 1e-3 | no | |
| platinum | 21450 | 1e-3 | no | |
| pyrite | 5010 | 1e-3 | no | |
| sand | 1442 | 0.03 | no | 粘度是动画用值 |
| silver | 10490 | 1e-3 | no | |
| steel | 7800 | 1e-3 | no | |
| tantalum | 16650 | 1e-3 | no | |
| diamond | 3510 | 1e-3 | no | mystery U 的密度来源 |
| human | 950 | 1e-3 | no | mystery T |
| titanium | 4500 | 1e-3 | no | mystery X |
| lead | 11342 | 1e-3 | no | mystery W，tandem OPT_OUT |
| custom | 由控件 | 1e-3 | no | 密度范围默认 `0.8 .. 27000` |

Mystery 固体（`hidden: true`，密度指向上表）：

| id | equals | density | screen |
| --- | --- | ---: | --- |
| materialR | pyrite | 5010 | Explore |
| materialS | gold | 19320 | Explore |
| materialT | human | 950 | Lab |
| materialU | diamond | 3510 | Lab |
| materialV | ice | 919 | Applications bottle（`doc/model.md`） |
| materialW | lead | 11342 | Applications bottle |
| materialX | titanium | 4500 | Applications boat |
| materialY | mercury | 13593 | Applications boat |

`SIMPLE_MASS_MATERIALS` = styrofoam, wood, ice, pvc, brick, aluminum。

## Liquids

| id | density | viscosity Pa·s | screens |
| --- | ---: | ---: | --- |
| gasoline | 680 | 6e-4 | 五屏（Compare 无 custom/mystery） |
| oil | 920 | 0.02 | 同上 |
| water | 1000 | 8.9e-4 | 默认 |
| seawater | 1029 | 1.88e-3 | |
| honey | 1440 | 0.03 | 注释写真实值约 2.5，这里是动画值 |
| mercury | 13593 | 1.53e-3 | |
| custom | 初值 1000，范围 500–15000 | 1e-3 | Explore Lab Shapes Applications |
| fluidA | 3100 | 1e-3 | Explore, Lab |
| fluidB | 790 | 1e-3 | Explore, Lab |
| fluidC | 490 | 1e-3 | Shapes（`doc/model.md`） |
| fluidD | 2890 | 1e-3 | Shapes |
| fluidE | 1260 | 1e-3 | Applications |
| fluidF | 6440 | 1e-3 | Applications |
| air | 1.2 | 0 | 瓶子内部，不是池液体 |

Mystery 液体 `hidden: true`。哪些屏的下拉把哪些 hidden 液体标成不可见，由各 ScreenView 的 `invisibleMaterials` 决定。密度表以上表为准；屏归属以 `doc/model.md` Table 2 为辅，和源码常量一致。

## Gravity values

| name | m/s² | hidden | control |
| --- | ---: | --- | --- |
| Moon | 1.6 | no | Lab combo |
| Earth | `gEarth` 默认 9.8，合法 9–10 | no | 默认 |
| Jupiter | 24.8 | no | Lab combo |
| Planet X | 19.6 | yes | Lab |
| Custom | 初值等于 Earth，范围 0.1–25 | no | Lab 滑条 |

## Objects

| Object | Shape | Material | Mass | Volume | Density | Fixed/Dynamic | Asset/Procedural |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Compare block 1A | cube | custom，初密度 4/0.002 = 2000 | 4 kg（Same Mass 滑条 1–10，默认 4） | 0.002 m³ | 滑条改密度，体积固定 | dynamic | 程序立方体 + 颜色 `compareOchre`。标签 ONE_A |
| Compare block 1B | cube | custom，初密度 4/0.01 = 400 | 4 kg | 0.010 m³ | 同上 | dynamic | 程序立方体 + `compareBlue`。标签 ONE_B |
| Compare Same Volume A | cube | custom | 10 kg | 0.005 m³（滑条 0.001–0.01） | 10/V | dynamic | 标签 TWO_A |
| Compare Same Volume B | cube | custom | 2 kg | 0.005 m³ | 2/V | dynamic | 标签 TWO_B |
| Compare Same Density A | cube | custom，密度滑条默认 wood 400，范围 100–3000 | 400×0.005 | 0.005 m³ | 共用密度 | dynamic | 标签 THREE_A |
| Compare Same Density B | cube | 同上 | 400×0.010 | 0.010 m³ | 共用密度 | dynamic | 标签 THREE_B |
| Explore block A | cube | wood，可选 SIMPLE + custom + R + S | 2 kg | 2/400 = 0.005 m³ | 材料固定时 V=m/ρ；custom 时密度由 m 与 V 派生 | dynamic | 程序立方体。位置 (-0.2, 0.2) |
| Explore block B | cube | aluminum | 13.5 kg | 13.5/2700 = 0.005 m³ | 同上 | dynamic，默认不可见 | 位置 (0.05, 0.35)。Two Blocks 才可见 |
| Lab block | cube | wood + SIMPLE + custom + T + U | 2 kg | 0.005 m³ | 同 Explore | dynamic | 位置 (-0.2, 0.2) |
| Shapes object A/B | 见下 | wood，仅 SIMPLE，A/B 共用 `materialProperty` | 密度×体积 | 由高、宽深比例 | 材料密度 | dynamic | 默认比例 width 0.25，height 0.75。A 位置 (-0.225, 0)，B (0.075, 0) |
| Applications bottle | 瓶子网格 + 预计算排水曲线 | 瓶壁 + 内部材料 + 空气 | 屏上读数含内容物 | 瓶体积 + air volume 控件 | 系统密度 = (塑料 + 空气 + 内部流体) / 瓶体积 | dynamic | THREE 网格 `Bottle.ts`。场景默认 bottle |
| Applications boat | 船体 | `BOAT_HULL` 密度 2700 | 船体 + 舱内物 | 船体几何 | 见 Applications 特例 | dynamic | `BoatDesign.ts` 预计算 |
| Applications block | cube | brick，体积 0.001 m³ | 2 kg | 0.001 | 2000，材料表更长 | dynamic | 只在 boat 场景可见。位置 (-0.5, 0.3) |
| Ground scale | 秤台 | n/a | n/a | 见 `Scale` | n/a | dynamic 或 kinematic，见 `canMove` | 程序网格 `ScaleView`。读数牛顿 |
| Pool scale | 池中平台 | n/a | n/a | 构造时从池体积扣除 | n/a | 滑条驱动高度，不是自由下落。Applications 切到 boat 时该控件隐藏 | `PoolScaleHeightControl` |

Compare 的 Same Mass 滑条改两块的 custom 密度 = `mass / volume`，体积保持各块自己的 `sameMassVolume`。Same Volume 滑条改尺寸，密度 = 各块固定质量 / 新体积。Same Density 滑条改两块 custom 密度，体积保持 `sameDensityVolume`。初始材料数组 `[WOOD, BRICK]` 用于色块模式切换前的材料列表；立方体本身走 custom 密度同步（`CompareBlockSetModel.createCube`）。

## Shapes

`MassShape`：BLOCK，ELLIPSOID，VERTICAL_CYLINDER，HORIZONTAL_CYLINDER，CONE，INVERTED_CONE，DUCK。

| Shape | Physics volume | Displacement | Drag |
| --- | --- | --- | --- |
| Block / Cuboid | `Cuboid.getVolume(size)` | `getDisplacedVolume` | 无形状阻力系数 |
| Ellipsoid | 椭球体积 | 椭球浸没 | 同上 |
| Vertical / Horizontal cylinder | 圆柱体积 | 圆柱浸没 | 同上 |
| Cone / Inverted cone | 圆锥体积。`isVertexUp` 区分 | 圆锥浸没 | 同上。`minVolume` 0.0002 |
| Duck | 视图是鸭子网格 | 池排水按椭球（implementation-notes） | 同上 |

所有形状 `fixedRotation = true`。不模拟转矩。

## Mass / volume / density 控制语义

`Mass.ts` Multilink：`mass = round(density * volume) + containedMass`。

文档字符串：改体积会改质量，不改材料密度。质量属性默认 `phetioReadOnly: true`，Explore/Lab 的 custom 材料密度也是只读，由质量和体积决定。

固定密度材料：用户改 Mass 滑条时，校验把质量换算成体积，体积必须落在 `volumeProperty.range`。改 Volume 则质量跟着 `density * volume` 变。密度读数不变。

Custom：质量与体积可分别改，密度 = m/V（Explore/Lab 的 `densityPropertyOptions.phetioReadOnly: true`）。

Shapes：没有独立质量滑条。材料改变写到每个缓存形状的 `materialProperty`。尺寸比例改变体积，质量由密度×体积重算。

## Interactive objects

| Target | Who can drag | Mechanism | Release |
| --- | --- | --- | --- |
| 块 / 形状 / 瓶 / 船 | 用户 | `Mass.startDrag`：y += 0.0001，然后 p2 `RevoluteConstraint`，`maxForce = 0 * mass + 2500` | `endDrag` 去掉约束。`userControlled = false`。物理继续，速度保留 |
| 地面秤 | Compare / Explore / Shapes `canMove: true`。Lab / Applications `canMove: false` | 同一套 pointer constraint | 同上 |
| 池秤 | 不可当物体自由拖。高度由 `PoolScaleHeightControl` | 滑条写高度 | 无 grab/release |
| 容器 | 不可拖 | 静态 ground + barrier | n/a |

拖拽期间物理不暂停。约束是力，不是直接写最终坐标。开始拖拽时有一次 0.0001 m 的位置写入，用来避免秤把重力算进读数。

被拖物体若掉到 `poolBounds.minY` 以下，`step` 里 `teleportUp()` 并 `interruptedEmitter`。被池秤卡在右侧时 `teleportLeft()`。

## Measurement tools

| Tool | Exists | Source |
| --- | --- | --- |
| 地面秤，牛顿 | 五屏 | `Scale`，`DisplayType.NEWTONS`。读数是接触力的 +y 分量之和 |
| 池中秤 + 高度滑条 | 默认 `usePoolScale: true` | `PoolScale`，`POOL_SCALE_INITIAL_HEIGHT = 0.5` |
| 液位升数 | 五屏 | `fluidLevelVolumeProperty`，`FluidLevelIndicator` |
| 质量标签 | 五屏，Lab 默认关 | `massValuesVisibleProperty` |
| 密度折叠盒 | Explore/Lab/Shapes/Applications 为 Object Density；Compare 为 Density Comparison | `DensityAccordionBox` |
| 浸没百分比 | 五屏 | `percentSubmergedProperty`。公式见物理节 |
| Fluid Displaced 烧杯 | 仅 Lab | `V_disp` 升 = `percentSubmerged/100 * volume * 1000` |
| 力箭头 | 五屏可开。Lab 默认开 | `ForceDiagramNode` |
| 直尺 / 压力计 / 力传感器探头 | 无 | 源码没有这些工具 |

秤的千克显示是 `scaleForce / gravity`，重力为 0 时显示 `-`（`ScaleReadoutNode`）。本模拟重力最小值 0.1，正常路径不会是 0。
