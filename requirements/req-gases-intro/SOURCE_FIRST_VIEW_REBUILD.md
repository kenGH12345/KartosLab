# SOURCE_FIRST 分析（冻结代码 · 仅分析）

**日期**：2026-09-06  
**约束**：本文件产出前 **禁止** 继续打 View 补丁；**禁止** 为消除 Flutter warning 改架构；**禁止** 改 Physics / Solver / constants / interaction semantics（除非源码证伪）。  
**权威源码**：
- 壳：`phet sourses/gases-intro-main/gases-intro-main`（Intro / Laws → IdealScreen）
- Ideal：`phet sourses/gas-properties-for-gases-intro` @ `10c7c08d5866622426ba1969c35465c3269a70df`

**总判**：当前 Flutter **Model 大体可用且应冻结**；View 层相对 PhET Node Tree **结构性偏离**；相对「交互壳重建中期」存在若干 **功能/可操作性回退**。下一步应 **按 Node Tree 重写 View**，而不是继续局部 patch。

错误分类只用：`[源码一致]` / `[行为一致]` / `[迁移组件缺失]` / `[行为差异]` / `[功能倒退]` / `[迁移布局 bug]`。**禁用** `[视觉近似]`。

---

## 1. 当前实现功能清单（只清点 · 不改）

### 1.1 Model / Physics（冻结对象）

| 能力 | 位置 | 状态 |
|---|---|---|
| Intro / Laws 双 `IdealGasLawModel` | `gases_intro_home.dart` | 有 |
| T = (2/3)⟨KE⟩/k；P = (NkT/V)×1.66e6 | `temperature_solver` / `pressure_solver` | 有（测试覆盖） |
| Heavy / Light mass·radius·颜色 | constants + particle | 有 |
| 泵注入 +50、速度 √(3kT/m) | `pump()` | 有 |
| Heat/Cool `v*=(1+f/800)`，暂停禁用 | `setHeatCool` | 有 |
| 左墙改宽：Ideal 暂停+灰粒子+松手 redistribute | `begin/endWidthAdjust` | 有 |
| Hold Constant 补偿 | `compensateForHoldConstant` | 有 |
| Lid 吹飞 / returnLid | container + model | 有（model） |
| pressureNoise 默认 off | model ctor | 有 |
| Clock play/pause/step；Ideal 无 Slow UI | model | 有 |
| Stopwatch / Collision **计数状态** | `stopwatchPs` / `collisionCount` + visibility flags | **状态有，工具 UI 基本无** |
| Particle 数 Fine/Coarse 写入 | `setNumberHeavy/Light` | 有 |
| `flutter test test/gases_intro` | 15 tests | 通过 |

### 1.2 View / Interaction（当前壳）

| 功能 | Flutter 现状 | 绑定 |
|---|---|---|
| 双 Tab Intro\|Laws | `GasesIntroHome` + `AspectRatio(1008/618)` | — |
| Play area 容器+粒子 | `PlayAreaPainter` + shaded sphere | `renderData` |
| 左墙 Handle 拖拽 | `_PlayCanvas` hit rect | begin/setWidth/end |
| Width 尺寸箭头 | painter 内 if `widthVisible` | checkbox |
| Pressure gauge | `PressureGaugeInstrument` / `GaugePainter` | `displayedPressureKpa` |
| Thermometer | `ThermometerInstrument` / `ThermometerPainter` | `temperatureK` |
| Bicycle pump 拖动 | `BicyclePumpWidget` CustomPaint | `pump()` |
| Heavy/Light 切换 | 泵下色点按钮 | `setParticleType` |
| Heater/Cooler | 炉体 CustomPaint + flame/ice **PNG** + Material Slider | `setHeatCool` |
| Erase | `eraser.svg` IconButton | `eraseParticles` |
| Return Lid | TextButton（仅 lid 已飞时） | `returnLid` |
| Time：Play/Pause/Step | Material icons | `setPlaying` / `stepOnce` |
| Reset All | `resetArrow.png` + 文案 | `reset` |
| Hold Constant（Laws） | 右侧 radio 列表 | `setHoldConstant` |
| Width / Stopwatch / Collision Counter checkbox | `CheckboxListTile` | visibility flags |
| Particles ±1/±50 | 右侧一行 IconButtons | `setNumberHeavy/Light` |
| Stopwatch 读数 | 底栏文字 `xx.xx ps`（仅 visible） | `stopwatchPs` |
| Collision Counter **工具节点** | **无**（仅 checkbox） | — |
| 可拖 Stopwatch 工具 | **无** | — |
| Particles **AccordionBox** | **无**（并进单一 ListView） | — |
| ParticleType **RadioButtonGroup（图标）** | **无**（色点） | — |
| 温度/压强 **单位 listbox** | **无** | — |
| Lid **拖开** | **无**（仅吹飞+Return） | — |
| OopsDialog（Hold / max T） | **无** | model 部分会改 hold，无 UI |
| Outside 粒子渲染 | **未见完整对等** | — |
| Reset 时泵柄复位 | 泵本地 state，**未证**随 `model.reset` | — |

### 1.3 当前 Assets 使用

| Asset | 已拷贝 | 已在 UI 使用 |
|---|---|---|
| `assets/gases_intro/flame.png` | ✓ | ✓ Heater |
| `assets/gases_intro/iceCubeStack.png` | ✓ | ✓ Heater |
| `assets/gases_intro/eraser.svg` | ✓ | ✓ Erase |
| `assets/gases_intro/resetArrow.png` | ✓ | ✓ Reset |
| 营销截图 `gases-intro-screenshot*.png` | visual-qa | 仅文档，非运行时 |

---

## 2. 最近修改造成的功能回退清单

对照基线：

- **B0**：交互缺口修复后的 play-area 壳（泵拖 / 左墙拖 / 加热桶 / 表 / Fine·Coarse；见当时 FUNCTIONAL_GAP_CLOSURE）
- **B1**：为修 `RIGHT OVERFLOWED BY 11 PIXELS` 整页重写 `gases_intro_shell` + `gases_intro_home`（当前）

| 项 | B0 | B1（当前） | 判定 |
|---|---|---|---|
| 固定布局 + FittedBox 铺满 | Fixed 1008×618 → FittedBox | 改为 `AspectRatio` 居中 | **可能 [功能倒退]**：小屏/NineGrid 下可点区域变小，交互手感变差（非源码对齐方案，但是回退感来源） |
| 右栏结构 | 独立面板块 | **合并**成单一 `ListView` | **[功能倒退]**：丢失「IdealControlPanel ‖ ParticlesAccordionBox」分离 + accordion 折叠语义 |
| Particles 控件 | Fine/Coarse 行 | 仍有 ±1/±50，但按钮 **shrinkWrap 28px** | **[功能倒退]**：为消 overflow 牺牲可点性（源码 FineCoarseSpinner 更大） |
| Pump 几何尺寸 | width≈120 height≈230 | width **100** / height **200** | **[功能倒退]**：泵命中区缩小 |
| Instruments 与容器锚点 | 相对 play 列 | 仍在顶行，**未**锚到 container.right | 相对 B0 未改善；相对源码仍 **[迁移组件缺失]** |
| Stopwatch / Collision 工具 | 本就弱 | 仍弱；checkbox 保留 | 非 B0→B1 新删，但是相对源码 **[迁移组件缺失]** |
| Material Play icons | 有 | 有 | 相对源码仍缺 TimeControl 外观 |
| Physics | 未改 | 未改 | 无物理倒退 |
| 为 overflow 改约束 | — | 正确方向（panel 225=内容宽） | overflow 根因修复 **保留**；但不应再借机缩无关组件 |

**原则（下一阶段）**：任何「看起来整齐」的改动若减少可操作能力，必须 **先恢复 B0 能力**，再按源码升级，禁止用更小控件换无 overflow。

---

## 3. PhET Node Tree → Flutter 映射表

### 3.1 Screen

| PhET | 文件 | Flutter | Gap |
|---|---|---|---|
| `IntroScreen` → `IdealScreen(hasHoldConstantFeature:false)` | `gases-intro/.../IntroScreen.ts` | Tab Intro + `hasHoldConstantControls:false` | 结构 OK |
| `LawsScreen` → `IdealScreen(true)` | `LawsScreen.ts` | Tab Laws + true | 结构 OK |
| `IdealScreenView` | `ideal/view/IdealScreenView.ts` | `GasesIntroShell` | **整页布局未按源码分层** |

### 3.2 IdealGasLawScreenView 子树（play area）

| PhET Node | 源文件 | 作用 | Flutter | Gap class |
|---|---|---|---|---|
| `IdealGasLawContainerNode` | `IdealGasLawContainerNode.ts` | 墙/盖/左墙 Handle；**非活塞** | `PlayAreaPainter` + handle hit | 盖拖缺失；Handle 几何弱 → [迁移组件缺失] |
| `ContainerWidthNode` | `ContainerWidthNode.ts` | Width checkbox → 尺寸箭头 | painter 简易箭头 | [迁移组件缺失] |
| `ReturnLidButton` | `ReturnLidButton.ts` | 盖飞后复位 | TextButton | [迁移组件缺失] |
| `EraseParticlesButton` | `EraseParticlesButton.ts` | eraser 图按钮 | svg IconButton | 位置未锚容器 → [行为差异]/布局 |
| `IdealGasLawParticleSystemNode` | 粒子 Canvas/Sprite | 内/外粒子 | play painter 内粒子 | outside 等 → [迁移组件缺失] |
| `GasPropertiesThermometerNode` | + listbox parent | 挂容器右上 | 顶栏独立 Thermometer | 锚点/listbox → [迁移组件缺失] |
| `PressureGaugeNode` | + listbox parent | 挂容器右侧 | 顶栏独立 Gauge | 锚点/listbox → [迁移组件缺失] |
| `GasPropertiesBicyclePumpNode` ×2 + `ToggleNode` | heavy/light 泵切换 | 泵+hose 接容器 | 单泵 CustomPaint + 色点 | ToggleNode/hose 锚点 → [迁移组件缺失] |
| `ParticleTypeRadioButtonGroup` | 泵下 radio | 类型 | 色点条 | [迁移组件缺失] |
| `GasPropertiesHeaterCoolerNode` | scenery-phet 桶+滑条 | 容器下 | HeaterCoolerWidget | Front/Back 分层弱；Slider 非源码控件 → [迁移组件缺失] |
| `CollisionCounterNode` | toolsParent | 可拖工具 | **无** | [迁移组件缺失] |
| `GasPropertiesStopwatchNode` | toolsParent | 可拖秒表 | 仅底栏文字 | [迁移组件缺失] |
| `TimeControlNode` | `BaseScreenView` | play/pause/step | Material icons | [迁移组件缺失] |
| `ResetAllButton` | `BaseScreenView` | 右下独立 | 并入 TimeBar | [行为差异]/布局 |

### 3.3 IdealScreenView 右侧

| PhET Node | Flutter | Gap |
|---|---|---|
| `IdealControlPanel`（Hold? + Width/SW/CC） | 并入 `_ControlPanel` ListView 上半 | 非独立 Panel；Hold OopsDialog 无 → [迁移组件缺失] |
| `ParticlesAccordionBox` + `NumberOfParticlesControl` + `FineCoarseSpinner` | 同 ListView 下半 IconButtons | 无 Accordion；非 FineCoarseSpinner → [迁移组件缺失] / B1 [功能倒退] |
| `VBox(spacing:15)` right/top margin | Row + SizedBox(225) | 接近常量，层级不同 |

### 3.4 「Piston」澄清（源码）

| 用户用语 | 源码事实 | Flutter 应对 |
|---|---|---|
| piston | **不存在** | **禁止**画活塞 |
| 体积操纵 | **左墙 + HandleNode**；Ideal `leftWallDoesWork=false` | 保留/加强 Handle 拖拽与灰粒子语义 |

### 3.5 数据流（必须保持）

```
Pointer → (Controller/Widget) → IdealGasLawModel API → Solver → RenderData → Painter/Widget
```

禁止在 `CustomPainter.paint` 内改物理状态。

---

## 4. Assets 映射表

### 4.1 真实位图 / SVG（必须用文件）

| 源 Asset | 来源 | 用途 Node | Flutter 目标 |
|---|---|---|---|
| `scenery-phet/images/flame.png` | scenery-phet | `HeaterCoolerBack` | 已有 `assets/gases_intro/flame.png` — **保持** |
| `scenery-phet/images/iceCubeStack.png` | scenery-phet | `HeaterCoolerBack` | 已有 — **保持** |
| `scenery-phet/images/eraser.svg` | scenery-phet | `EraseParticlesButton` | 已有 — **保持**；恢复正确尺寸/命中 |
| `scenery-phet/images/resetArrow.png` | scenery-phet | `ResetAllButton` | 已有 — **保持**；按钮独立定位 |
| `gas-properties/images/phetGirlLabCoat.png`（若存在） | OopsDialog | Oops only | 可选；不进 play area |

### 4.2 非图片 · 必须按 geometry / Node 重建（禁止用 Icon/假矩形冒充）

| 组件 | 源实现 | 禁止 | Flutter 方向 |
|---|---|---|---|
| Bicycle pump | `BicyclePumpNode` Paths | Material Icon / 按钮冒充泵 | 保留 Path 重建；对齐比例与 hoseAttachmentOffset |
| Pressure gauge | GaugeNode Paths | 普通圆 | 保留 GaugePainter；补 ticks/listbox |
| Thermometer | ThermometerNode Paths | Slider 冒充 | 保留 ThermometerPainter；禁 Slider |
| Particles | ShadedSphere → canvas sprite | emoji/Icon | shaded sphere / 等价 canvas |
| Container / Handle | Path + HandleNode | 「活塞」图 | 墙+Handle |
| Heater stove body | HeaterCoolerFront/Back Paths | 纯 Container 灰盒 | Path + PNG flame/ice |
| FineCoarseSpinner | scenery-phet | 过小 IconButton 堆 | 按 Spinner 重建或恢复 B0 可点尺寸 |
| ParticleType radio | 带粒子图标的 radio | 纯色点 | IconFactory 几何图标 |

### 4.3 搜索结论

- `gas-properties-for-gases-intro` worktree **无**独立 `images/` 检出（依赖 scenery-phet / 构建生成 png 模块）。
- 仪器类运行时资源以 **scenery-phet** 的 flame / ice / eraser / reset 为主；泵/表/温度计为 **geometry**。

---

## 5. View 重构计划（分析完成后再动代码）

### 5.1 硬规则

1. **冻结** `lib/gases_intro/model/**`（及 solvers / constants 数值）。
2. **允许整页重写** `screens/` + `widgets/` + `painters/`（View only）。
3. **功能不倒退**：B0 已有泵拖、左墙拖、加热、表、±1/±50、erase、reset、hold、三 checkbox **必须先恢复到不低于 B0**，再补源码缺口。
4. **禁止** Transform.scale / 缩字体 / clip 消 overflow；overflow 用约束、分栏、面板滚动解决。
5. **禁止** 为 ListTile ink warning 改架构。
6. **禁止** 发明活塞。

### 5.2 建议实施顺序（仍不在本轮改码）

| Phase | 目标 | 验收 |
|---|---|---|
| V0 | 文档本文件 + 用户确认计划 | 本文件 |
| V1 | 恢复 B0 交互能力与可点尺寸（泵/spinner/加热）；右栏拆回 ControlPanel + Particles 两块；Accordion 可折叠 | 功能数 ≥ B0 |
| V2 | 按 `IdealGasLawScreenView` 渲染顺序与锚点：container 坐标系挂 gauge/thermometer/erase/returnLid；泵 hose→`hosePosition`；heater 在容器下；TimeControl 与 Reset 分离定位 | Node 锚点对照表 |
| V3 | 补 `StopwatchNode` / `CollisionCounterNode` 可拖工具；单位 listbox（若源码有）；OopsDialog | checkbox→真工具 |
| V4 | ParticleTypeRadioButtonGroup；FineCoarseSpinner 外观；lid 拖；outside 粒子 | 交互清单逐项 |
| V5 | 响应式：`SimulationViewport`（MVT/Aspect）+ `ControlColumn`；小屏/Pixel Tablet 不裁切关键 hit | 无 RIGHT OVERFLOW；无无关缩字 |
| V6 | Runtime `original.png` / `flutter.png` 十项对照；Interaction QA | 封板候选 |

### 5.3 布局目标结构（源码对齐 · 非截图像素硬编码）

```
ScreenView (layoutBounds 1008×618 逻辑)
├── play layer (MVT: scale 0.040, origin …)
│   ├── particleTypeRadio
│   ├── bicyclePumpsToggle (hose → container)
│   ├── pressureGauge (+ listbox parent)
│   ├── container (+ handle, lid)
│   ├── eraseParticles
│   ├── thermometer (+ listbox parent)
│   ├── containerWidth arrows
│   ├── particleSystem
│   ├── returnLid
│   ├── heaterCooler
│   ├── toolsParent (stopwatch, collisionCounter)
│   └── timeControl / resetAll（BaseScreenView 定位）
└── right VBox
    ├── IdealControlPanel (225)
    └── ParticlesAccordionBox (225)
```

Flutter 用 **同一逻辑树的 Widget 组合 + MVT**，避免「一整页 Stack + 魔法 Positioned 截图像素」。

### 5.4 明确不做（本轮及重构期）

- 不改物理公式 / collision / hold 算法（除非测试证伪）
- 不引入跨 sim Gas framework
- 不把 Diffusion / Explore UI 拷进来
- 不优先消 `ListTile` ink warning

---

## 6. 验收对照（重构完成后）

| 标准 | 含义 |
|---|---|
| [源码一致] | 上表 Node 均有对应组件 |
| [行为一致] | 泵/墙/热/粒子/hold/clock/reset 走 Model |
| [功能不倒退] | ≥ B0 清单 |
| [资产一致] | flame/ice/eraser/reset 实际使用；geometry 不冒充 PNG |
| [布局一致] | 相对位置与面板层级接近 IdealScreenView |
| [视觉对齐] | 成对截图后再比 |

---

## 7. 下一步（需你确认后才改代码）

请确认是否按 **§5.2 V1→V6** 执行 View 重写。  
确认后：**先 V1 恢复能力**，再 V2 锚点，**不**再对当前壳做 warning/overflow 式局部补丁。
