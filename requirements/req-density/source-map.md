# Source Map · Density

> 需求：`req-density`  
> 日期：2026-09-02  
> 本文件只陈述原版。不写 Flutter 实现。

标记：`[已确认]` 本地文件 · `[clone]` density-buoyancy-common HEAD `0c835c6` · `[文档]` model.md

---

## 0. 源码登记

```text
Density 薄壳:
D:\OneDrive\Desktop\KartosLab\KartosLab\phet sourses\density-main\density-main

Project: density
Version: 1.3.0-dev.0          # package.json
License: GPL-3.0
HTML Entry: density_en.html
Main JS Entry: js/density-main.ts
Screens: js/intro/IntroScreen.ts
         js/compare/CompareScreen.ts
         js/mystery/MysteryScreen.ts
Strings (本仓): density-strings_en.json   # 仅 title + 3 screen 名
phetLibs: density-buoyancy-common, mobius
preload: sherpa/lib/p2-0.7.1.js, sherpa/lib/three-r104.js
simFeatures: dynamicLocale, interactiveDescription, sound
supportedBrands: phet, phet-io, adapted-from-phet
screenNameKeys: DENSITY/screen.intro | compare | mystery

密度/浮力共用库（真正的 Model/View）:
D:\OneDrive\Desktop\KartosLab\KartosLab\phet sourses\density-buoyancy-common-main
Version: 1.0.0-dev.0
Git: 0c835c642c0603531c3b9f0844fcb8b196abe003  (2026-09-02 clone --depth 1 main)
```

`density/doc/model.md` 与 `implementation-notes.md` 只指向 common 仓库。  
`[文档]` common `doc/model.md`、`doc/implementation-notes.md`。

本地 `density/dependencies.json` 注释为 `density 1.2.0-dev.4`（2024-08-22），其中 common sha `bc64def…`。本地 density 已是 `1.3.0-dev.0`。分析以 **本地 density 入口 + 新 clone 的 common main** 为准，不混用旧 sha。

---

## 1. 调用链

```
density-main.ts
  Sim(title, [IntroScreen, CompareScreen, MysteryScreen], simOptions)
    credits: DensityBuoyancyCommonCredits
    webgl: true
    preferences: DensityBuoyancyCommonPreferencesNode  → 仅 Volume Units
                 （percentSubmerged 在 density 包名下被 tandem OPT_OUT）

IntroScreen
  model: DensityIntroModel(fluidSelectionType:'justWater', usePoolScale:false)
  view:  DensityIntroScreenView
  keyboardHelp: DensityBuoyancyCommonKeyboardHelpNode(true, true)  // grab+combo

CompareScreen
  model: DensityCompareModel(...)
  view:  DensityCompareScreenView
  keyboardHelp: DensityBuoyancyCommonKeyboardHelpNode(true, false)

MysteryScreen
  model: DensityMysteryModel(...)
  view:  DensityMysteryScreenView(massValuesInitiallyDisplayed:false)
  keyboardHelp: DensityBuoyancyCommonKeyboardHelpNode(false, false)
```

证据：`js/density-main.ts:21-47`；三 Screen 文件各 `super(() => new XxxModel, model => new XxxScreenView)`。

所有 `Density*Model` / `Density*ScreenView` 都在 common：

| 角色 | 路径 |
|---|---|
| Intro Model | `js/density/model/DensityIntroModel.ts` |
| Compare Model | `js/density/model/DensityCompareModel.ts` |
| Mystery Model | `js/density/model/DensityMysteryModel.ts` |
| Intro View | `js/density/view/DensityIntroScreenView.ts` |
| Compare View | `js/density/view/DensityCompareScreenView.ts` |
| Mystery View | `js/density/view/DensityMysteryScreenView.ts` |
| Density Table | `js/density/view/DensityTableNode.ts` |
| Density Number Line | `js/density/view/DensityNumberLineNode.ts` |
| 共享 Model | `js/common/model/DensityBuoyancyModel.ts` `Mass.ts` `Cube.ts` `Cuboid.ts` `Material.ts` `BlockSetModel.ts` `CompareBlockSetModel.ts` `PhysicsEngine.ts` `Pool.ts` |
| 共享 View | `js/common/view/DensityBuoyancyScreenView.ts` `MassView.ts` `CuboidView.ts` `MaterialView.ts` `MaterialMassVolumeControlNode.ts` `BackgroundEventTargetListener.ts` |

---

## 2. 架构分层（原版）

```
User pointer / keyboard
        ↓
BackgroundEventTargetListener / GrabDragInteraction
        ↓
Mass.startDrag / updateDrag / endDrag   → p2 pointer constraint
        ↓
DensityBuoyancyModel.step(dt)
        ↓
PhysicsEngine.step (p2.js 多子步)
        ↓
postStep: 浮力 / 重力 / 粘滞 / 接触
        ↓
axon Property 更新
        ↓
THREE.js MassView + Scenery 控件
```

原版 **没有** 独立 Controller 包。控件在 view/。状态在 axon `Property`。  
Flutter 侧应对齐项目 MVC：把「改 Property」收成 Controller，把 p2 力计算收成纯 Solver。

---

## 3. 依赖

| 库 | 用途 | Flutter 策略 |
|---|---|---|
| p2.js 0.7.1 | 2D 刚体、接触、pointer constraint | **不嵌入**。Dart PhysicsSolver 行为等价 |
| three-r104 + mobius | 等距 3D 块、纹理、射线拾取 | CustomPainter + World↔Screen；纹理从 jpg.ts 提取 |
| axon | Property / Multilink | Dart 不可变 State + copyWith |
| joist Screen | 三屏 + Reset All + Preferences | KratosTabBar + 本工程 Reset |
| scenery-phet GrabDrag | 键盘抓取 | Semantics + 焦点；一期可降级完整键盘帮助窗 |
| tambo | grab/release 音 | 可选；common 无自带 mp3，用 joist sharedSoundPlayers |

---

## 4. 屏间状态

每个 `joist.Screen` 自有 Model 实例。切屏 **不共享** 块状态。  
Preferences `volumeUnitsProperty` **全局**，三屏共用。  
证据：`density-main.ts` 三个 `new XxxScreen`；`DensityBuoyancyCommonPreferences.ts`。

---

## 5. 许可证与署名

- density 与 common 均为 **GPL-3.0**。
- `supportedBrands` 含 `adapted-from-phet`。改编必须标 Adapted from PhET，不得冒充官方。
- Credits：`DensityBuoyancyCommonCredits.ts`（leadDesign / softwareDevelopment / team / QA）。
- 材质贴图：`images/license.json`，CC0Textures CC0 Public Domain（Bricks/Wood/Ice/Metal/Styrofoam/Plastic/DiamondPlate）。
- 屏图标 mipmap：PhET 代码生成，license contact phethelp@colorado.edu。
