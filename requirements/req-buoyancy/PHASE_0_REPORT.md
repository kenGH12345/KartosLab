# PHASE 0 REPORT

```text
PHASE 0 STATUS

Scope:
Source Archaeology + Migration Architecture Audit

Simulation:
Buoyancy

Source Version:
1.3.0-dev.2
PASS（package.json + dependencies.json comment）

Source Commit:
UNKNOWN
lockfile buoyancy sha e3a4d490dd75a4be8ad8a6f4744fc691d533c6f2
工作树没有 .git，不能核对

Dependency Snapshot:
dependencies.json
comment: Wed Feb 26 2025 16:28:33 GMT-0700
common lockfile sha: 0295f8f62bff7f345185fbf11a9e42c08206e4c5
local common HEAD: 0c835c642c0603531c3b9f0844fcb8b196abe003 (2026-04-20)
lockfile SHA 不在本地 git 对象库

density-buoyancy-common:
PASS
源码在本地，五屏引用的类都在。SHA 不一致记为 P1，不是缺失

Main Entry:
js/buoyancy-main.ts
PASS

Screens:
5
Compare, Explore, Lab, Shapes, Applications

Screen Architecture:
PASS

Shared Domain:
PASS

Model Architecture:
PASS

Physics:
PASS
外层帧 dt / pause 在 joist，UNKNOWN，记 P1

Object Catalog:
PASS

Interaction:
PASS

Coordinate Systems:
PASS（模型米、+y、相机常量）
像素 modelToView 与 DEFAULT_LAYOUT_BOUNDS 数值 UNKNOWN，记 P1

Clock / Animation:
PASS（p2 1/120，最多 30 子步，插值）
外层时钟 UNKNOWN，记 P1

Controls:
PASS（类名与所在屏）
scenery/sun 实现不在本地

Assets:
PASS（模块已登记，未复制）
固有像素尺寸 UNKNOWN，记 P2

Audio:
NONE FOUND
sim-local 无 mp3/wav/ogg。credits.soundDesign 为空

Accessibility:
PARTIAL
五屏键盘帮助节点为 grab + move + slider + combo。具体按键在 scenery-phet，不在本地

Existing KartosLab Implementation:
AUDITED
lib/density 是另一模拟。没有 lib/buoyancy。旧 BuoyancyWorld 不得当真源

P0:
none

P1:
common SHA 与 buoyancy lockfile 不一致，且 lockfile 对象不在本地 clone
buoyancy SOURCE_COMMIT UNKNOWN（无 .git）
ScreenView.DEFAULT_LAYOUT_BOUNDS 数值 UNKNOWN（joist 不在本地）
mobius modelToViewPoint UNKNOWN
joist 帧 dt 与 pause UNKNOWN
p2 0.7.1 与 three r104 文件不在本地

P2:
纹理固有尺寸未解码
DisplayProperties.initialForceScale 传入但未使用
Pool.reset(false, false) 与 BlockSetModel.reset 未逐行展开
共享库 grab 音效不在本地

Model:
NOT STARTED

Layout:
NOT STARTED

UI:
NOT STARTED

Golden:
0 / 0

Android:
NOT VERIFIED

Home:
NOT STARTED

Status:
READY CANDIDATE
```

Governance：`.cursor/skills` 里没有任务点名的 phet-migration / source-archaeology 等 skill。`.cursor/rules/80` 只是一行外部路径。已遵守本仓库的素材规则与 Reset All 规则，没有改治理文件，没有写 Flutter。

## A. Screen Map

| Screen | Model | View | Main Experiment | Shared Domain | Status |
| --- | --- | --- | --- | --- | --- |
| Compare | `BuoyancyCompareModel` | `BuoyancyCompareScreenView` | 两立方体，同质量/体积/密度，命名液体 | `CompareBlockSetModel` + `DensityBuoyancyModel` | AUDITED |
| Explore | `BuoyancyExploreModel` | `BuoyancyExploreScreenView` | 一或两块，材料/质量/体积，流体含 custom 与 mystery | `Cube` + `Pool` | AUDITED |
| Lab | `BuoyancyLabModel` | `BuoyancyLabScreenView` | 流体密度、重力、排开液体、力默认显示 | 同上 + `Gravity` | AUDITED |
| Shapes | `BuoyancyShapesModel` | `BuoyancyShapesScreenView` | 七种形状，高度与宽深 | `MassShape` + 各形状类 | AUDITED |
| Applications | `BuoyancyApplicationsModel` | `BuoyancyApplicationsScreenView` | 瓶与船，船舱液体 | `Bottle` `Boat`，override `updateFluid` | AUDITED |

## B. Domain Map

| Domain | Source | Shared? | Flutter Strategy | Risk |
| --- | --- | ---: | --- | --- |
| Screen shell | `buoyancy/js/*Screen.ts` | no | REIMPLEMENT 薄注册 | LOW |
| Pool / mass / forces | `DensityBuoyancyModel` `PhysicsEngine` `Mass` | yes，五屏 | REIMPLEMENT。不要搬 `lib/density` solver | VERY HIGH |
| Materials | `Material.ts` | yes，静态单例 | REIMPLEMENT 表 | MEDIUM |
| Compare blocks | `CompareBlockSetModel` | Compare，也给 Basics（本次不注册） | REIMPLEMENT | HIGH |
| Shapes | `buoyancy/model/shapes` | Shapes | REIMPLEMENT 排水函数 | HIGH |
| Boat / bottle | `buoyancy/model/applications` | Applications | REIMPLEMENT，不能用立方体代替 | VERY HIGH |
| THREE view | `DensityBuoyancyScreenView` + meshes | yes | 以后 REIMPLEMENT。mobius 映射仍 UNKNOWN | VERY HIGH |
| scenery 控件 | sun / scenery-phet 类名 | yes | REIMPLEMENT 为 PhET 外观，含 `KratosResetAllButton` | HIGH |
| p2 / THREE 库 | sherpa preload | yes | 不嵌入。按适配器行为重写 | HIGH |
| joist / mobius | 不在本地 | framework | SOURCE AUDIT REQUIRED 后再做 layout | HIGH |
| Density Flutter | `lib/density` | 否 | REFERENCE ONLY | HIGH if reused |

## C. Object Catalog

| Object | Material | Shape | Physical Parameters | Interaction | View |
| --- | --- | --- | --- | --- | --- |
| Compare 两块 × 三模式 | custom 密度，初值对应木/砖等 | cube | Same Mass 默认 4 kg，范围 1–10；Same Volume 默认 0.005 m³；Same Density 默认 400 | 拖拽约束 | 程序立方体 + 颜色 |
| Explore A | wood，可选 SIMPLE/custom/R/S | cube | 2 kg，体积 0.005 m³ | 拖拽 | 木纹 |
| Explore B | aluminum | cube | 13.5 kg，默认隐藏 | Two Blocks 后拖拽 | 金属 |
| Lab block | wood + T/U | cube | 2 kg | 拖拽 | 木纹。力默认开 |
| Shapes A/B | SIMPLE，默认 wood | 7 种，默认 block | 比例 0.25 × 0.75 | 拖拽，换形状保持底边 | 程序网格；鸭是网格+椭球排水 |
| Bottle | 内容物 + 空气 + 瓶壁 | 瓶 | 系统密度含内部质量 | 拖拽 | `Bottle.ts` 网格 |
| Boat + block | 船体=铝密度；块默认 brick 0.001 m³ | 船 + 立方体 | 第二 basin | 拖拽；re-float 按钮 | `BoatDesign.ts` |
| 地面秤 | n/a | 秤 | 牛顿 = 接触力 +y | Compare/Explore/Shapes 可拖；Lab/Applications 不可 | `ScaleView` |
| 池秤 | n/a | 平台 | 高度滑条，初始高度常数 0.5 | 滑条，不是 grab | `PoolScaleHeightControl` |

液体与完整密度表在 `OBJECT_CATALOG.md`。

## D. Interaction Map

| User Action | Source Handler | Model Effect | View Effect | Animation |
| --- | --- | --- | --- | --- |
| 按下物体 | `Mass.startDrag` | y += 0.0001；RevoluteConstraint，maxForce 2500；物理不暂停 | 射线命中，手型 | 约束力 |
| 拖动 | `updatePointerConstraint` | 约束枢轴跟着指针 | 物体被拉向指针 | 物理继续 |
| 松开 | `Mass.endDrag` | 移除约束，速度保留 | 继续沉/浮 | p2 子步直到接触平衡 |
| 换材料 / 质量 / 体积 | `MaterialProperty`，`mass = ρV` | 固定密度时质量与体积联动；custom 时密度派生 | 尺寸与纹理 | 随后物理 |
| 换液体或重力 | `fluidMaterialProperty` / `gravityProperty` | 下一步浮力用新 ρ 或 g | 颜色、箭头、秤 | 物理 |
| 力勾选 | `DisplayProperties` | 不改力，只改可见性 | 箭头长度 = 力 × zoom × 20 | NONE |
| Reset All | `model.reset` + `displayProperties.reset` | 不 new Model | 回初始摆放与控件 | NONE |
| 船 re-float | `resetBoatAndBlockPosition` | 船和块回位置，舱水清空 | 船浮起 | NONE |

## E. Asset Audit

| Asset | Type | Intrinsic Size | Used By | Source/Procedural | Status |
| --- | --- | --- | --- | --- | --- |
| compare / shapes / applications screen icons | mipmap PNG module | UNKNOWN | 屏图标 | 源码生成的位图模块 | AUDITED，未复制 |
| Explore / Lab icons | common png module | UNKNOWN | 屏图标 | common | AUDITED |
| Wood / Brick / Styrofoam / Ice / Plastic / Metal* | jpg PBR 模块 | UNKNOWN | `MaterialView` | CC0 纹理 | AUDITED，必须复用 |
| boat / bottle / fluid-displaced icons | png module | UNKNOWN | Applications、Lab | common | AUDITED |
| 池、地面、液体、立方体、箭头、天空 | 无文件 | n/a | 主画面 | PROCEDURAL SOURCE GRAPHICS | 不要当成缺图 |
| Duck / Boat / Bottle 网格 | ts 数据 | n/a | Shapes / Applications | PROCEDURAL SOURCE GRAPHICS | 不要用立方体顶替 |
| 音频 | 无文件 | n/a | n/a | NONE | SIM LOCAL AUDIO = NONE |

## F. Risk

| Risk | Severity | Evidence | Impact | Next Phase |
| --- | --- | --- | --- | --- |
| common SHA 不一致 | HIGH | lockfile `0295f8f6` 不在 clone；HEAD `0c835c64` | 和 2025-02 壳可能有差 | 冻结当前树，缺 API 再停 |
| 用 Density 的 Dart solver | HIGH | `buoyancy_world.dart` 是弹簧不是约束 | 拖拽和粘滞错 | 新建模型，不改 `lib/density` |
| 跳过 p2 子步 | VERY HIGH | `step(1/120, dt, 30)` | 沉浮不像实验 | Model 阶段先做力与步进 |
| 拖拽直接设位置 | HIGH | `RevoluteConstraint` | 松手不沉降 | 保留 grab/release |
| 船瓶当立方体 | VERY HIGH | `updateFluid` override，预计算曲线 | Applications 不可用 | 单独移植 |
| 像素坐标系未知 | HIGH | mobius 与 joist 不在本地 | Layout 会猜 | 补到这两份常量再做 Layout |
| THREE / Android | HIGH | 源码已对 mobile Safari 降级 | 性能 | Android NOT VERIFIED |

## 阅读顺序

`SOURCE_MAP.md` → `DEPENDENCY_MAP.md` → `SCREEN_MAP.md` → `COMMON_DOMAIN_MAP.md` → `OBJECT_CATALOG.md` → `FUNCTION_MAP.md` → `RESET_SEMANTICS.md` → `VISUAL_ASSET_AUDIT.md` → `MODEL_RISK_REGISTER.md` → `MIGRATION_RISK_REGISTER.md` → `EXISTING_IMPLEMENTATION_AUDIT.md`
