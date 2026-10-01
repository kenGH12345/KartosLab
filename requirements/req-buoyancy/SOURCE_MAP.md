# Source Map

置信度：HIGH 表示在本次打开的本地文件里读到。MEDIUM 表示文件在但只读了构造与调用，没有逐行展开。UNKNOWN 表示本地没有该依赖，不能从别的仓库脑补。

| Domain | Source File | Class | Responsibility | Evidence | Confidence |
| --- | --- | --- | --- | --- | --- |
| Main | `buoyancy/js/buoyancy-main.ts` | script | 启动、5 屏注册、WebGL、偏好面板 | 全文 | HIGH |
| Main | `buoyancy/js/buoyancy.ts` | Namespace | requirejs 命名空间 | 全文 | HIGH |
| Main | `buoyancy/package.json` | n/a | 版本 1.3.0-dev.2，phetLibs，screenNameKeys | 全文 | HIGH |
| Main | `buoyancy/dependencies.json` | n/a | SHA 快照，comment 2025-02-26 | 全文 | HIGH |
| Version | 工作树 `.git` | n/a | 不存在。lockfile sha 不能核对 | `git rev-parse` 失败 | HIGH |
| Screen | `js/compare/CompareScreen.ts` | `CompareScreen` | 壳，模型在 common | 全文 | HIGH |
| Screen | `js/explore/ExploreScreen.ts` | `ExploreScreen` | 壳 | 全文 | HIGH |
| Screen | `js/lab/LabScreen.ts` | `LabScreen` | 壳 | 全文 | HIGH |
| Screen | `js/shapes/ShapesScreen.ts` | `ShapesScreen` | 壳 | 全文 | HIGH |
| Screen | `js/applications/ApplicationsScreen.ts` | `ApplicationsScreen` | 壳 | 全文 | HIGH |
| Strings | `buoyancy-strings_en.json` | n/a | 标题与五屏英文名 | 全文 | HIGH |
| Common | `density-buoyancy-common/package.json` | n/a | 1.0.0-dev.0，依赖 mobius，preload p2 与 three | 全文 | HIGH |
| Common git | common `.git` | n/a | HEAD `0c835c64`，lockfile SHA 不在对象库 | git | HIGH |
| Model | `common/model/DensityBuoyancyModel.ts` | `DensityBuoyancyModel` | 池、屏障、postStep 力、step、reset | 构造、postStep、step、reset | HIGH |
| Model | `common/model/PhysicsEngine.ts` | `PhysicsEngine` | p2 适配、子步、指针约束、接触力 | 构造、step、constraint | HIGH |
| Model | `common/model/Mass.ts` | `Mass` | m=ρV、百分比、拖拽、reset | 相关方法 | HIGH |
| Model | `common/model/Cube.ts` | `Cube` | `createWithMass` = volume mass/density | `createWithMass` | HIGH |
| Model | `common/model/Material.ts` | `Material` | 全部密度与粘度 | 静态表 | HIGH |
| Model | `common/model/Gravity.ts` | `Gravity` | 1.6 / 9.8 / 24.8 / 19.6，custom 0.1–25 | 全文 | HIGH |
| Model | `common/model/Pool.ts` | `Pool` | 液体选择、100 L 目标、池秤扣体积 | 构造 | HIGH |
| Model | `common/model/Basin.ts` | `Basin` | 液面 y、溢出 | 被调用，未逐行 | MEDIUM |
| Model | `common/model/CompareBlockSetModel.ts` | `CompareBlockSetModel` | Same Mass/Volume/Density 如何写两块 | 构造与 createMasses | HIGH |
| Model | `buoyancy/model/BuoyancyCompareModel.ts` | `BuoyancyCompareModel` | 两块数据、4 kg、流体 simple、可移动秤 | 全文 | HIGH |
| Model | `buoyancy/model/BuoyancyExploreModel.ts` | `BuoyancyExploreModel` | A 2 kg wood，B 13.5 kg aluminum | 全文 | HIGH |
| Model | `buoyancy/model/BuoyancyLabModel.ts` | `BuoyancyLabModel` | 重力可操作，排开体积 | 全文 | HIGH |
| Model | `buoyancy/model/shapes/BuoyancyShapesModel.ts` | `BuoyancyShapesModel` | 七形状缓存 | 构造与 createMass | HIGH |
| Model | `common/model/MassShape.ts` | `MassShape` | 形状枚举 | 全文 | HIGH |
| Model | `buoyancy/model/applications/BuoyancyApplicationsModel.ts` | `BuoyancyApplicationsModel` | 瓶/船、溢出、re-float | 构造、reset、常量 | HIGH |
| Model | `Bottle.ts` `Boat.ts` `Duck.ts` | 各形状 | 预计算排水 | 文件在，几何函数未逐行展开 | MEDIUM |
| Constants | `DensityBuoyancyCommonConstants.ts` | constants | 边距、100 L、流体 0.5–15 kg/L、相机 lookAt | 全文 | HIGH |
| Query | `DensityBuoyancyCommonQueryParameters.ts` | defaults | p2 与粘滞默认值 | 全文 | HIGH |
| Doc | `common/doc/model.md` | n/a | 力的文字说明、mystery 表 | 前 135 行 | HIGH |
| Doc | `common/doc/implementation-notes.md` | n/a | p2 子步、reset、鸭/船/瓶 | 全文 | HIGH |
| View | `common/view/DensityBuoyancyScreenView.ts` | 基类视图 | 相机、光、池、拖拽、Reset | 构造到 reset | HIGH |
| View | `buoyancy/view/BuoyancyScreenView.ts` | 浮力视图基类 | 池秤滑条、力面板、lookAt | 全文 | HIGH |
| View | 五个 `*ScreenView.ts` | 各屏 | 控件树 | 构造区 `new` 扫描 | HIGH |
| View | `ForceDiagramNode.ts` | 力箭头 | `* vectorZoom * 20` | 第 130 行 | HIGH |
| View | `DisplayProperties.ts` | 显示开关 | 力默认、zoom 档 | 全文 | HIGH |
| View | `MaterialView.ts` | 纹理 | 材料到贴图 | 映射函数 | HIGH |
| View | `DebugView.ts` | 调试 | 600 px/m，Y 翻转。不是主 MVT | 构造 | HIGH |
| MVT | `mobius/.../MobiusScreenView.ts` | `THREEModelViewTransform` | 主画面 model↔view | 文件不在本地 | UNKNOWN |
| Layout | joist `ScreenView` | `DEFAULT_LAYOUT_BOUNDS` | 设计分辨率 | 文件不在本地 | UNKNOWN |
| Clock | joist `Sim` | step/pause | 帧 dt | 文件不在本地 | UNKNOWN |
| Engine | `sherpa/lib/p2-0.7.1.js` | p2 | 积分器本体 | preload 路径，文件不在本地 | UNKNOWN |
| Render | `sherpa/lib/three-r104.js` | THREE | 渲染器本体 | 同上 | UNKNOWN |
| Control | scenery-phet `ResetAllButton` | Reset All | 按钮外观与按压 | 类名已知，实现不在本地。Flutter 用 `KratosResetAllButton` | MEDIUM |
| A11y | `DensityBuoyancyCommonKeyboardHelpNode.ts` | 键盘帮助 | 五屏都 `(true, true)`：抓取、移动、滑条、ComboBox | 构造 | HIGH |
| A11y | scenery-phet keyboard help 各 Section | 具体按键 | 不在本地 | UNKNOWN |
| Audio | `DensityBuoyancyCommonCredits.ts` | credits | `soundDesign: ''` | 第 17 行 | HIGH |
| Asset | `images/*.ts` `mipmaps/*.ts` | 图像模块 | 纹理与图标内嵌 | 文件清单与 license | HIGH |
| Existing | `lib/density/solver/buoyancy_world.dart` | `BuoyancyWorld` | Density 近似，不是本真源 | 文件头 | HIGH |

## Camera constants that are local

`DensityBuoyancyScreenView`：`scaleIncrease = 3.5`，相机位置 `(0, 0.2, 2) * 3.5`，zoom 默认 `1.75 * 3.5`，`camera.up = (0, 0, -1)`。

Buoyancy 覆盖 lookAt 为 `BUOYANCY_CAMERA_LOOK_AT = (0, -0.18, 0)`。Density 的 lookAt 是原点，不要混用。

这些数不足以算出像素坐标。像素映射在 mobius。

## Coordinate summary

| Space | What is known |
| --- | --- |
| 物理 | 米。+y 向上（重力是 -y）。x 水平。z 是池的深度，p2 不用 z |
| p2 | 同向，乘 size scale 5、mass scale 0.1 |
| 主视图 | THREE 相机参数如上。`modelToViewPoint` 的比例、原点和是否翻轴：UNKNOWN |
| Debug 视图 | 原点在 layout 中心，scale 600，Y 翻转。仅 `?showDebug` |
| 各屏 | 同一套 Buoyancy 相机。没有每屏单独的 MVT 类。Applications 只是多一个 debug 子类，仍用 layoutBounds |

不要建一个拍脑袋的 `BuoyancyMVT` 套所有屏，在 mobius 映射未知之前。
