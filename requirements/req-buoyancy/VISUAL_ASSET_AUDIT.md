# Visual Asset Audit

PHASE 0 只登记，不复制到 `assets/`。目标仍是以后 Substituted = 0。

本地没有独立 `.png` / `.jpg` 文件。图像在 PhET 的 `*_png.ts` / `*_jpg.ts` 模块里（mipmap 文件超过 100 KB，是内嵌数据）。固有像素尺寸未解码，记 UNKNOWN。

## Simulation-local (`buoyancy/mipmaps`)

| asset | path | format | intrinsic size | used by | source class | static/dynamic | reuse |
| --- | --- | --- | --- | --- | --- | --- | --- |
| compare_screen_icon.png | `buoyancy-main/mipmaps/compare_screen_icon_png.ts` | mipmap PNG module | UNKNOWN | Compare home 图标，和 THREE 图标二选一 | `CompareScreen.ts` `getThreeIcon` | static | 屏导航图标。`generateIconImages` 默认关，运行时用这份图 |
| shapes_screen_icon.png | `mipmaps/shapes_screen_icon_png.ts` | mipmap PNG module | UNKNOWN | Shapes | `ShapesScreen.ts` | static | 同上 |
| applications_screen_icon.png | `mipmaps/applications_screen_icon_png.ts` | mipmap PNG module | UNKNOWN | Applications | `ApplicationsScreen.ts` | static | 同上 |

`license.json`：这三张 “created by the simulation code”，版权 University of Colorado Boulder。Explore 与 Lab 的图标不在 buoyancy mipmaps 里，而在 common（见下）。

`images/license.json` 在 buoyancy 根上存在，目录里没有其它图像模块。

## Common images (`density-buoyancy-common/images`)

纹理许可：CC0，`https://cc0textures.com`（`images/license.json`）。图标许可同屏图标，“created by the simulation code”。

| asset | format | used by | class | kind |
| --- | --- | --- | --- | --- |
| Wood26_col/nrm/rgh.jpg | jpg module | wood | `WoodMaterialView` | PBR 纹理 |
| Bricks25_col/nrm/AO.jpg | jpg module | brick | `BrickMaterialView` | PBR |
| Styrofoam_001_col/nrm/rgh/AO.jpg | jpg module | styrofoam | `StyrofoamMaterialView` | PBR |
| Ice01_col/nrm/alpha.jpg | jpg module | ice | `IceMaterialView` | PBR + alpha |
| Plastic018B_col/nrm/rgh.jpg | jpg module | pvc / 塑料 | `PVCMaterialView` | PBR |
| DiamondPlate01_* | jpg module | aluminum 一类金属板 | `AluminumMaterialView` | PBR |
| Metal002 / Metal007 / Metal08 / Metal10 (+ brightened, met, nrm, rgh) | jpg module | copper, gold, platinum, steel, silver, tantalum | `MaterialView.ts` `DensityMaterials.getMaterialView` | PBR |
| buoyancy_explore_screen_block.png | png module | Explore 图标备用 | `getBuoyancyExploreIcon` 相关 | 图标 |
| boat_icon.png / bottle_icon.png | png module | Applications radio | `getBoatIcon` / `getBottleIcon` | 图标 |
| fluid_displaced_scale_icon.png | png module | Lab 排开液体图标 | `getFluidDisplacedAccordionBoxScaleIcon` | 图标 |

`DensityMaterials.getMaterialView` 映射（节选）：

- aluminum → Aluminum
- brick → Brick
- copper → Copper
- gold, pyrite, materialR, materialS → Gold
- silver, tantalum → GreyMetal
- ice → Ice
- platinum → Platinum
- pvc → PVC
- steel → Steel
- styrofoam → Styrofoam
- wood → Wood
- custom 或 hidden → `ColoredMaterialView`（灰度或给定色，不是贴图）
- 其余 → `DebugMaterialView` 橙色。PHASE 1 必须确认瓶子、混凝土、沙子没有落到 Debug 色

## Procedural, not missing assets

| Graphics | Mark |
| --- | --- |
| 天空 `LinearGradient` skyTop → skyBottom | PROCEDURAL SOURCE GRAPHICS |
| 地面、池壁 `GroundFrontMesh` `GroundTopMesh` `PoolMesh` | PROCEDURAL SOURCE GRAPHICS |
| 液面 `FluidMesh`，颜色来自 `Material.colorProperty` | PROCEDURAL SOURCE GRAPHICS |
| 立方体、圆柱、圆锥、椭球网格 | PROCEDURAL SOURCE GRAPHICS |
| 力箭头 `ArrowNode` | PROCEDURAL SOURCE GRAPHICS |
| 自定义固体灰度、自定义液体插值色 | PROCEDURAL SOURCE GRAPHICS |
| Duck / Boat / Bottle 网格 | PROCEDURAL SOURCE GRAPHICS，数据在 `DuckData.ts` `BoatDesign.ts` `Bottle.ts` 的 `compute*Data()`。不是“缺图” |

## SVG / CSS

buoyancy 与 common 的图像清单里没有 `.svg`。没有独立 CSS。THREE 材质用 roughness/metalness/normal。`flutter_svg` 风险：这些纹理用不上 flutter_svg。风险在于 PBR 通道如何在 Flutter 里采样，那是后续视觉阶段的事。

## Audio

搜索 `mp3` / `wav` / `ogg`：buoyancy 与 common 都没有音频文件。

`DensityBuoyancyCommonCredits.soundDesign = ''`。

`package.json` `simFeatures.supportsSound: true`。

`GRAB_RELEASE_SOUND_CLIP_OPTIONS` 只给了 `initialOutputLevel: 0.4`，片段本身不在本地。

**SIM LOCAL AUDIO = NONE。**

## Substitution count (this phase)

未复制资源。Substituted 计数不适用。登记结果：纹理与图标模块都在 common/buoyancy 源码树里，后续必须从这些模块抽出位图，禁止重画。
