# Screen Map · Buoyancy

屏幕数量来自本地源码，不是网页记忆。

`package.json` `phet.screenNameKeys` 有 5 项。`js/buoyancy-main.ts` 按这个顺序构造 `Sim`：

1. `CompareScreen` → tandem `compareScreen`
2. `ExploreScreen` → `exploreScreen`
3. `LabScreen` → `labScreen`
4. `ShapesScreen` → `shapesScreen`
5. `ApplicationsScreen` → `applicationsScreen`

字符串（`buoyancy-strings_en.json`）：Compare / Explore / Lab / Shapes / Applications。标题 `Buoyancy`。

默认屏：数组第一项是 Compare。joist 是否允许 query 改初始屏：UNKNOWN（joist 不在本地）。

每个 Screen 的 Model 工厂在第一次进入时 `new`。五个 Model 互不共享实例。共享的是 common 里的类和静态 `Material.*`。

| Screen | Entry | Model | View | Main Experiment | Shared Code | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Compare | `js/compare/CompareScreen.ts` | `buoyancy/model/BuoyancyCompareModel.ts` extends `CompareBlockSetModel` | `buoyancy/view/BuoyancyCompareScreenView.ts` | 两块立方体，Same Mass / Same Volume / Same Density。流体是命名液体（simple）。牛顿秤可拖。池秤 | `DensityBuoyancyModel`, `Pool`, `PhysicsEngine`, `BlocksPanel`, `BlocksValuePanel`, `FluidSelectionPanel` | AUDITED |
| Explore | `js/explore/ExploreScreen.ts` | `buoyancy/model/BuoyancyExploreModel.ts` | `buoyancy/view/BuoyancyExploreScreenView.ts` | 一块或两块立方体。材料、质量、体积独立可调（密度由 m/V 派生）。流体含 custom 与 mystery。牛顿秤可拖 | `Cube`, `MaterialControlNode`, `ABControlsNode`, `FluidDensityPanel` | AUDITED |
| Lab | `js/lab/LabScreen.ts` | `buoyancy/model/BuoyancyLabModel.ts` | `buoyancy/view/BuoyancyLabScreenView.ts` | 单块。流体密度 + 重力（Moon/Earth/Jupiter/Custom/Planet X）。Fluid Displaced 体积与重量。力默认打开。秤不可拖 | `GravityControlNode`, `FluidDisplacedAccordionBox`, `BlockControlNode` | AUDITED |
| Shapes | `js/shapes/ShapesScreen.ts` | `buoyancy/model/shapes/BuoyancyShapesModel.ts` | `buoyancy/view/shapes/BuoyancyShapesScreenView.ts` | 一块或两块形状。材料只在 SIMPLE_MASS。高度与宽深改体积。形状含 duck（物理用椭球排水） | `BuoyancyShapeModel`, `MassShape`, shape views | AUDITED |
| Applications | `js/applications/ApplicationsScreen.ts` | `buoyancy/model/applications/BuoyancyApplicationsModel.ts` | `buoyancy/view/applications/BuoyancyApplicationsScreenView.ts` | Bottle / Boat 两场景。瓶子装材料与空气体积。船有自己的 basin，可装块，水可溢出回池 | `Bottle`, `Boat`, `BoatBasin`, `BottlePanel`, `BoatPanel` | AUDITED |

## Inheritance

```text
joist.Screen
  CompareScreen | ExploreScreen | LabScreen | ShapesScreen | ApplicationsScreen

DensityBuoyancyModel
  CompareBlockSetModel
    BuoyancyCompareModel
  BuoyancyExploreModel
  BuoyancyLabModel
  BuoyancyShapesModel
  BuoyancyApplicationsModel

MobiusScreenView                         (mobius, NOT LOCAL)
  DensityBuoyancyScreenView
    BuoyancyScreenView
      BuoyancyCompareScreenView
      BuoyancyExploreScreenView
      BuoyancyLabScreenView
      BuoyancyShapesScreenView
      BuoyancyApplicationsScreenView
```

`BuoyancyBasics*` 在 common 里存在，但 `buoyancy-main.ts` 没有注册。那是另一款模拟，不属于本次 Buoyancy。

## Per-screen node tree

公共（`DensityBuoyancyScreenView` + `BuoyancyScreenView`）：

```text
ScreenView
├── skyRectangle                         LinearGradient skyTop → skyBottom
├── massDecorationLayer                  标签、读数、力箭头（2D scenery，贴在 3D 投影上）
├── sceneNode (Mobius / THREE)
│   ├── AmbientLight 0x333333
│   ├── DirectionalLight sun (-0.7, 1.5, 0.8)
│   ├── DirectionalLight moon (2, -1, 1) intensity 0.2
│   ├── GroundFrontMesh / GroundTopMesh / PoolMesh
│   ├── FluidMesh                        renderOrder 10
│   └── MassView.massMesh                随 visibleMasses 增删
├── FluidLevelIndicator                  池左侧升数
├── poolScaleHeightControl               池内秤高度，贴在池右壁投影上
├── displayOptionsPanel                  Forces / Mass Values / Depth Lines
├── resetAllButton                       AlignBox right-bottom
└── popupLayer                           ComboBox / dialog
```

Compare 追加：`BlocksPanel`，`FluidSelectionPanel`（无密度滑条），`BlocksValuePanel`，`DensityAccordionBox`（文案 Density Comparison），`SubmergedAccordionBox`。

Explore 追加：`ABControlsNode`（材料 + Mass + Volume，B 随 Two Blocks），`FluidDensityPanel`，`BlocksModeRadioButtonGroup`，密度与浸没百分比折叠盒。

Lab 追加：左侧 `FluidDisplacedAccordionBox` + `displayOptionsPanel`；底部 `FluidDensityPanel` + `GravityControlNode`；右侧 `BlockControlNode` + 密度 + 浸没百分比。力默认显示，质量读数默认关。

Shapes 追加：`MaterialControlNode`，`ShapeSizeControlNode`（Height，Width & Depth），`InfoButton` → `ShapesInfoDialog`，`BlocksModeRadioButtonGroup`。`supportsDepthLines` 未覆盖，基类默认 false。

Applications 追加：`RectangularRadioButtonGroup` bottle/boat，`BottlePanel` / `BoatPanel`，`RectangularPushButton`（只在 boat 可见，调用 `resetBoatAndBlockPosition`），流体密度面板。

## Layout bounds

`BuoyancyCompareScreenView` 使用 `ScreenView.DEFAULT_LAYOUT_BOUNDS.width / 2` 作为右侧内容最大宽度。该常量定义在 joist，joist 不在本地。

| Item | Value |
| --- | --- |
| design width | UNKNOWN |
| design height | UNKNOWN |
| root bounds | `ScreenView.DEFAULT_LAYOUT_BOUNDS`，数值 UNKNOWN |
| margin | `DensityBuoyancyCommonConstants.MARGIN = 10`，`MARGIN_SMALL = 5`，`SPACING = 10` |
| orientation | 横向实验台。源码没有竖屏专用 layout |
| global scale | UNKNOWN。相机 zoom 已知，像素/米换算在 mobius |

不要把 1024×618 写进后续 layout。PHASE 1 必须先拿到 joist 的 `DEFAULT_LAYOUT_BOUNDS`，或从已构建的 HTML 度量，并记为单独证据。
