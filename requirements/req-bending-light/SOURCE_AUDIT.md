# PHASE 0 — SOURCE AUDIT · Bending Light

> **Behavior Reference** = 本地源码（SOURCE OF TRUTH）  
> **Visual Reference** = published `latest`（交叉验证；冲突时行为以本地为准）  
> 审计日期：2026-09-18  
> 禁止状态：未开始 Flutter 编码 · 未宣布 READY

---

## 1. Simulation Version

| 项 | 值 | 来源 |
|---|---|---|
| Sim 名称 | Bending Light | `bending-light-strings_en.json` → `bending-light.title` |
| package.json version | **1.3.0-dev.0** | `package.json:3` |
| dependencies.json snapshot comment | **1.2.0-dev.2** · Tue Dec 03 2024 | `dependencies.json` 首行 |
| bending-light SHA | `a85e95079c52a2abc8386e637e49ea75526f8327` | `dependencies.json` |
| requirejsNamespace | `BENDING_LIGHT` | `package.json` |
| screenNameKeys | `intro` / `prisms` / `moreTools` | `package.json` phet.screenNameKeys |
| Published indexed release | **1.1.32**（目录存在）；`latest` 端点在用 | phet.colorado.edu |
| Version 对应性结论 | 本地为 **main 开发快照（1.3.0-dev）**，比官网索引的 **1.1.32** 更新。**行为以本地源码为准**；视觉 QA 用 published latest 作对照，若有差异记入 PHASE 6 风险表 |

---

## 2. Source Root & Tree

```
phet sourses/bending-light-main/bending-light-main/
├── js/
│   ├── bending-light-main.ts          # Entry · simLauncher
│   ├── bendingLight.ts                # namespace
│   ├── BendingLightStrings.ts
│   ├── BendingLightQueryParameters.ts
│   ├── common/                        # 跨屏 Model / View / Constants
│   ├── intro/                         # Screen 1
│   ├── prisms/                        # Screen 2
│   └── more-tools/                    # Screen 3（扩展 Intro）
├── images/                            # 运行时 PNG（3）
├── mipmaps/                           # Screen 图标（4）
├── assets/                            # .ai 源稿 + marketing 截图（非运行时）
├── doc/
│   ├── model.md                       # 物理文档（Snell / Fresnel / Sellmeier）
│   └── implementation-notes.md        # 坐标 / 图层 / 目录结构
├── bending-light-strings_en.json
├── package.json / dependencies.json / LICENSE / README.md
└── （无 sounds/ · 无 test/）
```

官方说明（`doc/implementation-notes.md`）：**三个仿真** Intro / Prisms / More Tools；More Tools 是 Intro 的扩展。

---

## 3. Dependencies（`dependencies.json` 关键 SHA）

| Repo | SHA (short) | 迁移含义 |
|---|---|---|
| axon | `46d1abcd…` | Property / DerivedProperty → Dart ChangeNotifier / ValueNotifier |
| dot | `64574adc…` | Vector2 / Bounds2 / Utils → Dart 数学 |
| kite | `c0be5771…` | Shape → Path / CustomPainter |
| scenery | `5ddc8d4d…` | Node / DragListener / Canvas → Flutter Widgets / Gesture |
| scenery-phet | `5e46666f…` | LaserPointerNode / Protractor / WavelengthSlider / ResetAll / TimeControl / ProbeNode |
| sun | `67e44959…` | Checkbox / ComboBox / HSlider / AquaRadioButton / Panel / ArrowButton |
| joist | `6622b286…` | Sim / Screen / ScreenView / ScreenIcon |
| phetcommon | `3b67089f…` | ModelViewTransform2 |
| twixt | `f2184ad8…` | （若有动画缓动） |
| tambo | `23b888ea…` | 本 sim **无声音资产**；依赖存在但本仓库无 sounds |
| tandem / phet-io* | — | PhET-iO；Flutter 可不移植 instrumentation |

**本地快照未包含依赖源码** —— scenery-phet / sun 组件需在后续 Phase 对照已有 KartosLab L0（如 `KratosResetAllButton`）或从上游仓库补读。

---

## 4. Entry Point

`js/bending-light-main.ts`：

```ts
simLauncher.launch( () => {
  const sim = new Sim( bendingLightTitleStringProperty, [
    new IntroScreen( tandem.createTandem( 'introScreen' ) ),
    new PrismsScreen( tandem.createTandem( 'prismsScreen' ) ),
    new MoreToolsScreen( tandem.createTandem( 'moreToolsScreen' ) )
  ], { credits: {...}, webgl: true } );
  sim.start();
} );
```

- Sim 标题：`"Bending Light"`
- `webgl: true`（Wave / 部分光线渲染优先 WebGL，Canvas fallback）
- **无独立 Home Screen 类** —— joist 标准多屏导航（Home 图标条 + navbar）

---

## 5. Screens（完整识别 · 已证明为 3 屏）

| # | Screen 类 | EN 标题 | String key | Model | View | Home Icon | NavBar Icon | 默认底介质 |
|---|---|---|---|---|---|---|---|---|
| 1 | `IntroScreen` | Intro | `BENDING_LIGHT/intro` | `IntroModel(WATER, true)` | `IntroScreenView(..., hasMoreTools=false, decimals=2)` | `introScreen.png` | （复用 home） | Water |
| 2 | `PrismsScreen` | Prisms | `BENDING_LIGHT/prisms` | `PrismsModel` | `PrismsScreenView` | `prismsScreenWhite.png` | `prismsScreenWhiteNavBar.png` | —（环境 Air / 物体 Glass） |
| 3 | `MoreToolsScreen` | More Tools | `BENDING_LIGHT/moreTools` | `MoreToolsModel` → `IntroModel(GLASS, false)` | `MoreToolsScreenView` → 扩展 Intro | `moreToolsScreen.png` | （复用 home） | Glass |

**证明只有这三屏**：`package.json` screenNameKeys、入口数组、`doc/implementation-notes.md` 均一致；用户截图三张对应 Intro / Prisms / More Tools。

### Screen 行为差异（关键关键）

| 能力 | Intro | Prisms | More Tools |
|---|---|---|---|
| 上下介质面板 | ✅ | ❌（环境 + Objects） | ✅ |
| Ray / Wave | ✅ | ❌ | ✅ |
| Wavelength 控制 | ❌ | ✅ | ✅ |
| Angles 复选 | ❌ | ❌ | ✅ |
| Intensity meter | ✅ | ❌ | ✅ |
| Velocity / Wave(Time) sensor | ❌ | ❌ | ✅ |
| 棱镜工具箱 | ❌ | ✅ | ❌ |
| Laser 平移 + 旋钮 | ❌（仅旋转） | ✅ | ❌（仅旋转） |
| 白光 / 多束 | ❌ | ✅ | ❌ |
| TimeControl | Wave 时 | ❌ | Wave **或** WaveSensor on |
| IOR 小数位 | 2 | 面板无数值框 | 3 |
| ResetAll radius | **19** | **19** | **19** |
| layoutBounds | `834×504` | 同 | 同 |

---

## 6. Model Classes

| PhET Source | Responsibility | Flutter Target |
|---|---|---|
| `common/model/BendingLightModel.ts` | 基类：laser、rays、时间、法线/角度开关、Fresnel 功率静态方法 | `lib/bending_light/model/bending_light_model.dart` |
| `common/model/Laser.ts` | 发射点、角度、开关、波长/颜色模式 | `model/laser.dart` |
| `common/model/LaserColor.ts` | 单色 / 白光颜色 | `model/laser_color.dart` |
| `common/model/LaserViewEnum.ts` | RAY \| WAVE | `model/laser_view_enum.dart` |
| `common/model/ColorModeEnum.ts` | WHITE \| SINGLE_COLOR | `model/color_mode_enum.dart` |
| `common/model/LightRay.ts` | 射线段：功率、波长、波宽、相交、相位 | `model/light_ray.dart` |
| `common/model/Medium.ts` | 形状 + Substance + 填充色 | `model/medium.dart` |
| `common/model/Substance.ts` | Air/Water/Glass/Diamond/Mystery/Custom | `model/substance.dart` |
| `common/model/DispersionFunction.ts` | Sellmeier + 空气 + 插值 n(λ) | `physics/dispersion_function.dart` |
| `common/model/MediumColorFactory.ts` | n → 介质填充色 | `model/medium_color_factory.dart` |
| `common/model/IntensityMeter.ts` | 探头圆 + 读数累加 | `model/intensity_meter.dart` |
| `common/model/Reading.ts` | 强度读数 / MISS | `model/reading.dart` |
| `common/model/WaveParticle.ts` | Canvas 波粒子 | `model/wave_particle.dart` |
| `common/model/RayTypeEnum.ts` | incident/reflected/transmitted… | `model/ray_type_enum.dart` |
| `intro/model/IntroModel.ts` | 上下介质 + **标量 Snell** 传播 | `model/intro_model.dart` |
| `more-tools/model/MoreToolsModel.ts` | Intro + 速度/波传感器 | `model/more_tools_model.dart` |
| `more-tools/model/VelocitySensor.ts` | 速度探头 | `model/velocity_sensor.dart` |
| `more-tools/model/WaveSensor.ts` | 双探头时序 | `model/wave_sensor.dart` |
| `more-tools/model/Probe.ts` / `Series.ts` / `DataPoint.ts` | 图表数据 | `model/probe.dart` 等 |
| `prisms/model/PrismsModel.ts` | 多棱镜 + **向量 Snell** 递归 | `model/prisms_model.dart` |
| `prisms/model/Prism.ts` | 位置 / 旋转 / shape | `model/prism.dart` |
| `prisms/model/Polygon.ts` / `BendingLightCircle.ts` / `SemiCircle.ts` | 几何 | `model/shapes/` |
| `prisms/model/PrismIntersection.ts` | 射线–棱镜交点与法线 | `physics/prism_intersection.dart` |
| `prisms/model/ColoredRay.ts` | 不可变着色射线 | `model/colored_ray.dart` |
| `prisms/model/Intersection.ts` | 交点（画法线） | `model/intersection.dart` |
| `prisms/model/LightType.ts` | SINGLE / 5X / WHITE UI 适配 | `model/light_type.dart` |

---

## 7. View Classes

| PhET Source | Responsibility | Flutter Target |
|---|---|---|
| `common/view/BendingLightScreenView.ts` | 基 ScreenView：MVT、图层、激光、handles | `view/bending_light_screen_view.dart` |
| `common/view/LaserNode.ts` | 激光图形 + 拖拽 | `view/laser_node.dart` |
| `common/view/MediumNode.ts` | 介质背景色块 | `view/medium_node.dart` |
| `common/view/MediumControlPanel.ts` | 材料 ComboBox + IOR | `components/medium_control_panel.dart` |
| `common/view/IntensityMeterNode.ts` | 强度计 UI | `view/intensity_meter_node.dart` |
| `common/view/WavelengthControl.ts` | 光谱滑块 + nm | `components/wavelength_control.dart` |
| `common/view/RotationDragHandle.ts` | 旋转提示弧箭头（非交互） | `view/rotation_drag_handle.dart` |
| `common/view/TranslationDragHandle.ts` | 平移提示箭头（Prisms） | `view/translation_drag_handle.dart` |
| `common/view/SingleColorLightCanvasNode.ts` | 单色光 Canvas | `view/single_color_light_canvas.dart` |
| `common/view/FloatingLayout.ts` | 边缘浮动布局 | `view/floating_layout.dart` |
| `intro/view/IntroScreenView.ts` | Intro/MT 基视图：工具箱、复选、Reset | `screens/intro_screen.dart` (+ shared) |
| `intro/view/NormalLine.ts` | 虚线法线 | `view/normal_line.dart` |
| `intro/view/AngleNode.ts` / `AngleTextView.ts` / `AngleIcon.ts` | 角度弧与读数 | `view/angle_node.dart` |
| `intro/view/LaserTypeAquaRadioButtonGroup.ts` | Ray/Wave | `components/laser_type_radio.dart` |
| `intro/view/WaveCanvasNode.ts` / `WaveWebGLNode.ts` | 波模式渲染 | `view/wave_renderer.dart` |
| `more-tools/view/MoreToolsScreenView.ts` | 附加传感器 + 波长面板 | `screens/more_tools_screen.dart` |
| `more-tools/view/VelocitySensorNode.ts` | Speed 传感器 | `view/velocity_sensor_node.dart` |
| `more-tools/view/WaveSensorNode.ts` / `ChartNode.ts` / `*CanvasNode.ts` | Time 图 | `view/wave_sensor_*.dart` |
| `prisms/view/PrismsScreenView.ts` | Prisms 布局 | `screens/prisms_screen.dart` |
| `prisms/view/PrismToolboxNode.ts` | 棱镜箱 + Objects 面板 + 复选 | `view/prism_toolbox_node.dart` |
| `prisms/view/PrismNode.ts` | 可拖/转棱镜 | `view/prism_node.dart` |
| `prisms/view/LaserTypeRadioButtonGroup.ts` | 1×/5×/白光 | `components/prisms_laser_type_radio.dart` |
| `prisms/view/IntersectionNode.ts` | 交点法线 | `view/intersection_node.dart` |
| `prisms/view/WhiteLightCanvasNode.ts` | 白光叠加 Canvas | `view/white_light_canvas.dart` |

---

## 8. Interaction Classes / Patterns

| Pattern | 类 / 位置 | Flutter Handler |
|---|---|---|
| `DragListener` | Laser / Prism / Protractor / meters / sensors | `GestureDetector` / `Listener` + model setters |
| `DragListener.createForwardingListener` | Toolbox → play area | Toolbox drag-out → enable + press forward |
| Toolbox put-back | Intro/MT `dropInToolbox` | 全局 bounds 相交 → `enabled=false` |
| Prism delete | 中心落入 toolbox → `removePrism` | 同 |
| Occlusion bump | `bumpLeft` / `occlusionHandler` | 松手后避开右侧面板 |
| `PressListener` | **未使用** | — |
| Keyboard / PDOM | **本 sim 无专用实现** | Phase 7 可标记 P2 |

完整手势表见 `INTERACTION_MATRIX.md`。

---

## 9. Constants

| 常量 | 值 | 文件 |
|---|---|---|
| `SPEED_OF_LIGHT` | `2.99792458e8` m/s | `BendingLightConstants.ts` |
| `WAVELENGTH_RED` / `CHARACTERISTIC_LENGTH` | `650e-9` m | 同 |
| `LASER_MAX_WAVELENGTH` | 700 nm | 同 |
| `LASER_MIN_WAVELENGTH` | `VisibleColor.MIN_WAVELENGTH` | scenery-phet |
| `MAX_ANGLE_IN_WAVE_MODE` | `3.0194` rad | 同 |
| `SCREEN_VIEW_OPTIONS.layoutBounds` | `Bounds2(0,0,834,504)` | 同 |
| `WHITE_LIGHT_WAVELENGTHS` | `range(400,700,10)` nm | 同 |
| `PRISM_NODE_ALPHA` | `0.5` | 同 |
| `maxLightRaySteps` | **50**（query param 默认） | `BendingLightQueryParameters` |
| `LightRay.RAY_WIDTH` | `~1.599e-7` m | `LightRay.ts` |
| XYZ / D65 / 转换矩阵 | 白光着色 | `BendingLightConstants.ts` |
| ResetAll `radius` | **19**（非 20.5） | Intro/Prisms ScreenView |

Flutter：`lib/bending_light/bending_light_constants.dart`

---

## 10. Assets 摘要

| 类别 | 数量 | 说明 |
|---|---|---|
| 运行时 PNG (`images/`) | 3 | `knob.png`, `laser.png`, `laserKnob.png`（后者 **JS 未引用**） |
| Screen mipmaps | 4 | Intro / MoreTools / Prisms home / Prisms navbar |
| Design `.ai` | 7 | 非运行时源稿 |
| Marketing PNG | 7 | README / 商店截图 |
| SVG | **0** | — |
| Sounds | **0** | — |

详情：`ASSET_MAPPING.md`。

**关键注意**：激光本体来自 **scenery-phet `LaserPointerNode`（矢量绘制）**，不是 `laser.png`。`laser.png` 仅用于 Prisms 激光类型电台按钮裁剪图标。

---

## 11. Physics（摘要 · 详见 PHYSICS_MODEL.md）

| 主题 | 实现位置 | 要点 |
|---|---|---|
| Snell's law（Intro） | `IntroModel.propagateRays` | `θ2 = asin(n1/n2 · sin(θ1))`，θ1 相对**向上竖直线** |
| Snell's law（Prisms） | `PrismsModel.propagateTheRay` | Wikipedia **向量形式** + 递归 |
| Fresnel 功率 | `BendingLightModel.getReflected/TransmittedPower` | s-polarized |
| TIR | Intro: `asin(n2/n1)`；Prisms: `cosθ2_radicand < 0` | R=1, T=0 |
| 色散 | `DispersionFunction` | Sellmeier 玻璃 + 空气公式 + 相对红光插值 |
| 波动 | `cos(kx − ωt + φ)` | `doc/model.md` |
| 无衰减 | `power_in = power_out` | `doc/model.md` |
| 递归上限 | 50 步 | 可计算性 |

---

## 12. Observable Properties（核心）

见 `PHYSICS_MODEL.md` § Observables；Reset 时各 Screen 调用 model + 面板/工具 reset。

---

## 13. Reset Behavior

| Screen | 调用链 |
|---|---|
| Intro / More Tools | `ResetAllButton` → model.reset()（含 laser、media、meters、sensors）+ 工具箱工具 `enabled=false` + 控制面板复位 |
| Prisms | model.reset()（清空棱镜、media、复选、manyRays、激光）+ 面板复位 |
| 跨屏 | joist 切屏**不**自动 reset 他屏（标准 PhET） |

ResetAll：**必须**用 L0 `KratosResetAllButton`，`radius: 19`。

---

## 14. Animations

| 动画 | 机制 | Flutter |
|---|---|---|
| Wave 相位推进 | `step(dt)` · sim 时间 `1e-16` / `0.5e-16` s | `Ticker` / `AnimationController` |
| Wave particles | 非 WebGL 时 `propagateParticles` | CustomPainter |
| TimeControl play/pause/step | `isPlayingProperty` / `speedProperty` | 绑定 model |
| Drag 跟手 | DragListener 即时写 Property | Gesture 即时同步 |
| 禁止 | `Future.delayed` 假动画 | — |

---

## 15. Input Handling

- 指针：拖、点、toolbox forwarding
- 触摸：扩大 touchArea（Checkbox 等）
- 键盘 / 专用 a11y：**无**（依赖 sun/scenery-phet 默认，若有）
- 拖拽边界：`dragBoundsProperty` ≈ visible / layout bounds

---

## 16. Accessibility / Keyboard

本仓库 **无** `KeyboardListener` / 自定义 PDOM 热键。记为 **P2**：优先功能与视觉 1:1；a11y 跟 KartosLab 既有控件能力。

---

## 17. Original Tests

| 项 | 结果 |
|---|---|
| `test/` / `*.spec.ts` / `*.test.ts` | **不存在** |
| package.json test script | **无** |
| `doc/model.md` | 可作为物理金标文档 |

→ Flutter `test/bending_light/` **必须新建**，对照 `PHYSICS_MODEL.md` 公式。

---

## 18. PhET Reusable Components → Flutter

| Component | Package | Flutter |
|---|---|---|
| `ResetAllButton` | scenery-phet | **L0 `KratosResetAllButton` radius=19** |
| `LaserPointerNode` | scenery-phet | L1 复刻（渐变圆柱 + 红按钮）；禁 Material |
| `ProtractorNode` | scenery-phet | L1（查 lib/common 是否已有） |
| `WavelengthSlider` | scenery-phet | L1 光谱滑块 |
| `TimeControlNode` | scenery-phet | L1 play/pause/step/speed |
| `ProbeNode` / `WireNode` | scenery-phet | L1 |
| `Checkbox` / `ComboBox` / `HSlider` / `AquaRadioButton` / `ArrowButton` / `Panel` | sun | L0/L1 PhET 风格 |
| `Screen` / `ScreenView` | joist | `BendingLightHome` + Tab/Page 导航 · bounds 834×504 比例 |

---

## 19. Flutter Architecture Proposal

```
lib/bending_light/
  bending_light_constants.dart
  bending_light_strings.dart          # EN 先；后续 i18n
  model/                              # 无 Flutter UI 依赖
  physics/                            # Snell / Fresnel / Dispersion / Intersection
  interaction/                        # drag handlers / toolbox
  view/                               # painters / nodes
  components/                         # 控件
  screens/
    bending_light_home.dart           # 三屏导航壳
    intro_screen.dart
    prisms_screen.dart
    more_tools_screen.dart
  assets/                             # 仅文档索引；实际文件在 assets/bending_light/

test/bending_light/
  physics_*.dart
  model_*.dart
  interaction_*.dart
  screen_lifecycle_*.dart
```

**Home 接入（Phase 8，勿提前改）**：

- 学科：**物理**
- 子领域：**光学与波动**（`home_screen.dart` 已有该组）
- 条目建议：`Bending Light` / `光的折射`（标题待产品确认）
- **禁止**新建导航体系；**禁止**改其他 sim

---

## 20. Migration Mapping Table（总表）

| PhET Source | Responsibility | Flutter Target |
|---|---|---|
| `bending-light-main.ts` | Entry / 三屏顺序 | `screens/bending_light_home.dart` |
| `IntroScreen` + `IntroModel` + `IntroScreenView` | Screen 1 | `intro_*` |
| `PrismsScreen` + `PrismsModel` + `PrismsScreenView` | Screen 2 | `prisms_*` |
| `MoreToolsScreen` + `MoreToolsModel` + `MoreToolsScreenView` | Screen 3 | `more_tools_*` |
| `BendingLightModel.get*Power` | Fresnel | `physics/fresnel.dart` |
| `IntroModel.propagateRays` | 标量 Snell | `physics/intro_propagation.dart` |
| `PrismsModel.propagateTheRay` | 向量 Snell | `physics/prisms_propagation.dart` |
| `DispersionFunction` | n(λ) | `physics/dispersion_function.dart` |
| `images/knob.png` | 旋钮 | `assets/bending_light/images/knob.png` |
| `images/laser.png` | 电台图标 | `assets/bending_light/images/laser.png` |
| `mipmaps/*.png` | 屏图标 | `assets/bending_light/mipmaps/` |
| scenery-phet `LaserPointerNode` | 激光外观 | L1 CustomPainter / 组件（**非** PNG 替代） |
| scenery-phet `ResetAllButton` | Reset | `KratosResetAllButton` |

---

## 21. Potential Migration Risks

| ID | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | `LaserPointerNode` 无本地 PNG，需矢量 1:1 复刻 | P0 视觉 | 对照 scenery-phet 源码几何；禁 Material |
| R2 | Wave WebGL → Flutter 无等价 GL 路径 | P0 功能 | CustomPainter / FragmentShader；先 Canvas 对拍 |
| R3 | 白光 Bresenham + XYZ 叠加 | P1 | 移植 `WhiteLightCanvasNode` 算法 |
| R4 | 两套 Snell（标量 vs 向量）易混用 | P0 | 分文件；分测试套件 |
| R5 | 本地 1.3.0-dev vs published 1.1.x | P1 文档 | 行为以本地为准；视觉差写入 QA |
| R6 | scenery-phet 依赖不在本仓库 | P1 | Phase 1 前列出需补读的上游文件 |
| R7 | `laserKnob.png` 未引用易误用 | P2 | ASSET_MAP 标明 unused |
| R8 | Prisms 递归 50 步性能 | P1 | isolate / dirty 标志同原版 |
| R9 | Reset radius 19 vs 规则默认 20.5 | P1 视觉 | 显式 `radius: 19` |
| R10 | 无上游单测 | P0 质量 | Phase 1 先写 physics tests |

---

## 22. Phase 0 Gate Checklist

- [x] 完整扫描本地源码树
- [x] 三 Screen 已证明（非假设）
- [x] Model / View / Interaction / Physics / Constants / Assets / Dependencies 已记录
- [x] `SOURCE_AUDIT.md` / `PHYSICS_MODEL.md` / `INTERACTION_MATRIX.md` / `ASSET_MAPPING.md` 已生成
- [x] Flutter 架构提案已给出
- [ ] **未写 Flutter UI**
- [ ] **未开始 Phase 1**
- [ ] **未宣布 READY**

---

*PHASE 0 SOURCE AUDIT · req-bending-light · 2026-09-18*
