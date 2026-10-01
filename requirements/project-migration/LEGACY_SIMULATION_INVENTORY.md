# LEGACY SIMULATION INVENTORY

> 生成日期：2026-08-31
> 阶段：**READ-ONLY 扫描盘点** · 未修改任何文件
> 范围：KartosLab 工程根目录递归扫描（lib / test / assets / requirements / docs / scripts / simulations / phet / integration_test / schemas）
> 参考规范：Build a Nucleus（`lib/chemistry/build_a_nucleus/`）——工程内已完成且结构最完整的 sim

---

## 0. 执行摘要

- 扫描发现 **12 个**"simulation 代码集合"：
  - **9 个**已挂载到 `lib/main.dart → HomeScreen` 的正规 sim（力学 / 电路 / 几何光学 / 色觉 / 波的干涉 / 声波 / 电磁波 / 摩尔浓度 / 构建原子核）
  - **3 个**位于 `phet/` 下的 PhET 迁移代码集合（Magnet & Compass / Quantum Coin Toss / Quantum Measurement）
  - **6 个**位于工程根 `simulations/` 下的散落 Dart 文件（Magnet & Compass 副本 / Electromagnet / Transformer ×3 文件 / 模型），**未挂载到 Home**
- 当前 Home 入口仅注册 9 个 sim，`phet/` 与 `simulations/` 全部为孤立代码（无 `main` / `Home` 引用）。
- 规范偏差集中在三类：① PhET 项目自带 `main()`、自带 `MaterialApp`、未走 `common/` 共享组件；② `simulations/` 文件扁平堆放在根目录；③ sim 间目录结构风格分裂（`model/` vs `models/`、`painters/` vs `view/painters/`、`screens/` vs `view/screens/`）。
- **3-Time Rule 触发风险**：磁铁/指南针逻辑在 `phet/magnet_and_compass/lib/main.dart` + `simulations/magnet_and_compass.dart` + `simulations/electromagnet_page.dart`（reuse CompassPainter）+ `simulations/transformer_painter.dart`（reuse phet/widgets/physics/magnetism/electromagnet.dart）共 4 处重复实现，已远超第 3 次阈值。

---

## 1. 扫描范围与发现

| 位置 | 代码集合数 | Dart 文件数 | 状态 |
|---|---|---|---|
| `lib/` | 9 sim + `common/` 共享层 | ≈200 | 正规挂载 |
| `simulations/` | 1 组散落文件（6 个 .dart） | 6 | **孤立** |
| `phet/` | 3 个项目 | 95（ widgets 71 + 项目 24） | **孤立**（`phet.dart` 是 barrel export，无 app 入口在主 main 引用） |
| `test/` | 73 | 73 | 覆盖 9 个正规 sim |
| `integration_test/` | 4 | 4 | 覆盖 color_vision / molarity / home overflow |
| `assets/scenarios/` | 9 schema + 55 JSON | 54 | 8 sim + optics 顶层 3 个 |
| `requirements/` | 13 req 目录 | 116 | 见 §6 |
| `docs/` | 56 .md + reviews/prompts | — | — |
| `scripts/` | `_inventory.mjs` + `_diag_ident.mjs` + `_fix_test_markers.mjs` + `ai_scenario_gen/` | — | — |

---

## 2. Legacy Simulation Matrix

> "判断"枚举：已完成 / 部分完成 / 原型 / 未知 / 孤立代码 / 重复实现 / 疑似废弃

| # | Simulation | 文件位置 | 主要代码 | Tests | Assets | Home 入口 | requirements | 完成度 | 判断 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 力与运动（forces） | `lib/forces/` | `models/`（4）· `screens/`（3：home/motion/netforce）· `widgets/`（3）· `config/`（3） | `test/forces/forces_scenario_test.dart` + 根目录 `forces_home_test.dart` / `forces_layout_test.dart` | `assets/scenarios/forces/` · `assets/images/mechanics/` | ✅ `_buildForces` → `ForcesHome` | 无独立 req | 已完成 | 已完成 |
| 2 | 电路搭建（circuit） | `lib/circuit/` | `models/`（3）· `screens/`（1）· `widgets/`（3）· `config/`（5）· `services/`（1） | `test/circuit/`（3）+ 根 `circuit_layout_test.dart` | `assets/scenarios/circuit/`（8 JSON + 1 md）· `assets/images/circuit/`（53） | ✅ `_buildCircuit` → `CircuitScreen` | 无独立 req | 已完成 | 已完成 |
| 3 | 几何光学（optics） | `lib/optics/` | `models/`（6）· `screens/`（1）· `solvers/`（1）· `physics/`（1）· `config/`（7） | `test/optics_solver_test.dart` | `assets/scenarios/{basic-lens-imaging,lens-combination,mirror-imaging}.json` + `assets/images/optics/` | ✅ `_buildOptics` → `OpticsScreen` | 无独立 req | 已完成 | 已完成 |
| 4 | 色觉（color_vision） | `lib/color_vision/` | `model/`（5）· `screens/`（3：home/rgb_bulbs/single_bulb）· `painters/`（5）· `solver/`（2）· `config/`（2） | `test/color_vision/`（2）+ 根 `color_vision_l9_regression_test.dart` / `color_vision_model_test.dart` / `rgb_bulbs_layout_test.dart` / `single_bulb_layout_test.dart` | `assets/scenarios/color-vision/`（11）· `assets/scenarios/color_vision/` | ✅ `_buildColorVision` → `ColorVisionHome` | `req-color-vision-layout-fix`（in_progress）· `req-verify-selftest-color-vision` | 已完成（含布局修复 in_progress） | 已完成 |
| 5 | 波的干涉（wave_interference） | `lib/wave_interference/` | `model/`（1：wave_engine）· `screens/`（1）· `painters/`（1）· `config/`（2） | 根 `wave_interference_model_test.dart` / `wave_radio_layout_test.dart` | `assets/scenarios/wave-interference/` | ✅ `_buildWaveInterference` → `WaveInterferenceScreen` | 无独立 req | 部分完成（painter/model 单文件） | 部分完成 |
| 6 | 声波（sound） | `lib/sound/` | `model/`（1）· `screens/`（1）· `painters/`（3）· `widgets/`（1）· `config/`（2） | 根 `sound_layout_test.dart` / `sound_model_test.dart` | `assets/scenarios/sound/` | ✅ `_buildSound` → `SoundScreen` | 无独立 req | 已完成 | 已完成 |
| 7 | 电磁波（radio_waves） | `lib/radio_waves/` | `model/`（1：radio_state）· `screens/`（1）· `painters/`（1）· `config/`（2） | 根 `radio_waves_model_test.dart` / `wave_radio_layout_test.dart` | `assets/scenarios/radio-waves/` | ✅ `_buildRadioWaves` → `RadioWavesScreen` | 无独立 req | 部分完成（model/painter 单文件） | 部分完成 |
| 8 | 摩尔浓度（molarity） | `lib/chemistry/molarity/` | `model/`（5）· `controller/`（1）· `view/{screens,painters,widgets}/`（10）· `config/`（3） | `test/chemistry/molarity/`（3）+ 根 `molarity_layout_test.dart` + `integration_test/molarity_test.dart` | `assets/scenarios/molarity/` | ✅ `_buildMolarity` → `MolarityScreen` | `req-port-molarity`（done） | 已完成 | 已完成 |
| 9 | 构建原子核（build_a_nucleus） | `lib/chemistry/build_a_nucleus/` | `controller/`（1）· `model/`（9）· `screens/`（3）· `painters/`（2）· `widgets/`（9）· `data/`（4）· `chart_intro/{controller,model,painters,render,widgets}/`（40）· `ban_constants.dart` | `test/chemistry/build_a_nucleus/`（24）+ `chart_intro/`（17） | `assets/data/nuclide_table.json` · `assets/images/full_nuclide_chart.png` | ✅ `_buildBuildANucleus` → `BuildANucleusHome` | `req-build-a-nucleus/`（多份分析报告） | 已完成（双屏：Decay + Chart Intro） | 已完成（**参考规范**） |
| 10 | Magnet & Compass（PhET 迁移） | `phet/magnet_and_compass/lib/main.dart` | 单文件 1650 行：自带 `main()` / `MagnetApp` / `EntryPage` / `SimulationPage` / `SimState` / `MagneticField` / 4 Painter / `_ControlPanel` | ❌ 无 | `assets/earth.svg`（被引用但未在 pubspec 单独声明） | ❌ 未挂载 Home | 无 | 原型 | **孤立代码 + 重复实现** |
| 11 | Quantum Coin Toss（PhET 迁移） | `phet/quantum_coin_toss/lib/` | `quantum_coin_toss.dart` + `models/`（2）· `screens/`（3）· `widgets/`（3） | ❌ 无 | ❌ 无 | ❌ 未挂载 Home（自带入口但无 main） | 无 | 原型 | **孤立代码** |
| 12 | Quantum Measurement（PhET 迁移） | `phet/quantum_meansuremant/lib/` | `coins/`（12：`coins_screen.dart` + `model/` + `view/`）· `common/view/` | ❌ 无 | ❌ 无 | ❌ 未挂载 Home | 无 | 原型（目录拼写错误 `meansuremant`） | **孤立代码 + 疑似废弃** |
| 13 | Magnet & Compass（根目录副本） | `simulations/magnet_and_compass.dart` | 单文件（"Migrated from lib/src/phet/magnet_and_compass/lib/main.dart"） | ❌ 无 | — | ❌ 未挂载 | 无 | 原型 | **重复实现**（与 #10 重复） |
| 14 | Electromagnet（根目录散落） | `simulations/electromagnet_{page,painter}.dart` | `ElectromagnetPage` + `ElectromagnetPainter` + 引用 `electromagnet_model.dart`（**缺失**）+ reuse `magnet_and_compass.dart` 的 `CompassPainter` | ❌ 无 | — | ❌ 未挂载 | 无 | 原型（依赖缺失，无法编译） | **孤立代码 + 重复实现** |
| 15 | Transformer（根目录散落） | `simulations/transformer_{page,model,painter}.dart` | `TransformerPage` + `TransformerPainter` + 三大模型（Circuit/MagneticField/Induction）+ reuse `phet/widgets/physics/magnetism/electromagnet.dart` + `phet/widgets/visualization/field.dart` 等 | ❌ 无 | — | ❌ 未挂载 | 无 | 原型 | **孤立代码** |
| 16 | PhET 共享组件库（phet/widgets） | `phet/widgets/` | 71 个 .dart：`canvas/` · `chemistry/`（10）· `controls/`（11）· `core/` · `graphs/` · `interaction/` · `layout/` · `measurement/` · `navigation/` · `objects/` · `panels/` · `particles/` · `physics/`（15）· `shapes/` · `simulation/` · `theme/` · `visualization/` | ❌ 无 | — | —（barrel export `phet/phet.dart`） | 无 | 组件库原型 | **疑似废弃**（仅被 `simulations/transformer_*.dart` 引用，而 transformer 本身未挂载 Home） |

> 总计 16 行（9 正规 + 4 孤立 sim + 3 重复/散落文件集合）。其中 #10/#13/#14/#15/#16 是当前"已经实现但没有按照当前工程规范组织"的核心目标。

---

## 3. 项目归并结果

### 3.1 [已确认] 归并

| 归并组 | 成员 | 依据 |
|---|---|---|
| **forces** | `lib/forces/*` + `test/forces/*` + 根 `forces_*_test.dart` + `assets/scenarios/forces/` + `docs/prompts/forces_scenario.md` + `schemas/forces_scenario.schema.json` | 类名前缀 `Forces*` + Home `_buildForces` + scenario 路径 |
| **circuit** | `lib/circuit/*` + `test/circuit/*` + 根 `circuit_layout_test.dart` + `assets/scenarios/circuit/` + `docs/prompts/circuit_scenario.md` + `schemas/circuit_scenario.schema.json` + `docs/drag-logic.md`（描述 `lib/screens/circuit_screen.dart` ——注意：实际路径在 `lib/circuit/screens/`，drag-logic 文档路径漂移） | 类名前缀 `Circuit*` + Home `_buildCircuit` |
| **optics** | `lib/optics/*` + `test/optics_solver_test.dart` + `assets/scenarios/{basic-lens-imaging,lens-combination,mirror-imaging}.json` + `docs/prompts/optics_scenario.md` + `schemas/optics_scenario.schema.json` | 类名前缀 `Optics*`/`Optical*` + Home `_buildOptics`。注意：optics 无 `assets/scenarios/optics/` 子目录，3 个 JSON 直接在 scenarios 根 |
| **color_vision** | `lib/color_vision/*` + `test/color_vision/*` + 根 `color_vision_*_test.dart` + `rgb_bulbs_layout_test.dart` + `single_bulb_layout_test.dart` + `assets/scenarios/color-vision/`（连字符）+ `assets/scenarios/color_vision/`（下划线，**重复目录**）+ `docs/prompts/color_vision_scenario.md` + `schemas/color_vision_scenario.schema.json` | 类名 + Home。**assets 重复目录待确认** |
| **sound** | `lib/sound/*` + 根 `sound_*_test.dart` + `assets/scenarios/sound/` + `docs/prompts/sound_scenario.md` + `schemas/sound_scenario.schema.json` | 类名前缀 `Sound*` + Home `_buildSound` |
| **radio_waves** | `lib/radio_waves/*` + 根 `radio_waves_model_test.dart` + `wave_radio_layout_test.dart` + `assets/scenarios/radio-waves/` + `docs/prompts/radio_waves_scenario.md` + `schemas/radio_waves_scenario.schema.json` | 类名 + Home |
| **wave_interference** | `lib/wave_interference/*` + 根 `wave_interference_model_test.dart` + `wave_radio_layout_test.dart`（**与 radio_waves 共享测试文件**）+ `assets/scenarios/wave-interference/` + `docs/prompts/wave_interference_scenario.md` + `schemas/wave_interference_scenario.schema.json` | 类名 + Home |
| **molarity** | `lib/chemistry/molarity/*` + `test/chemistry/molarity/*` + 根 `molarity_layout_test.dart` + `integration_test/molarity_test.dart` + `assets/scenarios/molarity/` + `docs/prompts/molarity_scenario.md` + `schemas/molarity_scenario.schema.json` + `requirements/req-port-molarity/` | 类名 + Home + req |
| **build_a_nucleus** | `lib/chemistry/build_a_nucleus/*` + `test/chemistry/build_a_nucleus/*` + `assets/data/nuclide_table.json` + `assets/images/full_nuclide_chart.png` + `schemas/nuclide_table.schema.json` + `requirements/req-build-a-nucleus/` | 类名前缀 `BuildANucleus*`/`ChartIntro*` + Home。无 scenario JSON（用 nuclide_table） |

### 3.2 [推测] 归并（PhET 系列内部）

| 归并组 | 成员 | 依据 | 待确认 |
|---|---|---|---|
| **phet/magnet_and_compass** | `phet/magnet_and_compass/lib/main.dart` + `simulations/magnet_and_compass.dart`（注释 "Migrated from lib/src/phet/magnet_and_compass/lib/main.dart"） | 文件名 + 注释 + `SimState`/`CompassPainter`/`BarMagnetPainter` 类名 1:1 重复 | #13 是否就是 #10 的"迁移中副本"？目前两者内容看起来几乎一致 |
| **phet/quantum_meansuremant** | `phet/quantum_meansuremant/lib/coins/*` | 文件名 `coins_screen.dart` + `CoinsScreen`/`CoinsModel` 类名 | 目录名拼写错误（`meansuremant` 应为 `measurement`）——是历史遗留还是有意？ |
| **phet/quantum_coin_toss** | `phet/quantum_coin_toss/lib/*` | `quantum_coin_toss.dart` 自带 `CoinMode`/`CoinOrientation` 等枚举 + 独立 `models/`+`screens/`+`widgets/` 结构 | 是否与 `phet/quantum_meansuremant` 是同一 PhET 项目（"Quantum Measurement" Java 源码）的两种实现？coin_toss 用 `CoinMode.classical/quantum`，meansuremant 用 `CoinsModel` —— **疑似同一蓝本的两个分支** |
| **simulations/electromagnet** | `simulations/electromagnet_page.dart` + `electromagnet_painter.dart` | 类名 `ElectromagnetPage`/`ElectromagnetPainter` + 注释 "Reuse CompassPainter from existing magnet simulation" | 缺失 `electromagnet_model.dart`（import 但不在 simulations/ 也不在 lib/）—— **代码不完整，无法编译** |
| **simulations/transformer** | `simulations/transformer_{page,model,painter}.dart` | 类名 `TransformerPage`/`TransformerPainter` + 文件名前缀 + 注释 "Faraday's Electromagnetic Lab → Transformer page" | 仅这组文件依赖 `phet/widgets/`（其他孤立 sim 都不依赖） |

### 3.3 [推测] PhET 共享组件库（phet/widgets）的归属

`phet/widgets/`（71 个 .dart）+ barrel export `phet/phet.dart`：

- **被引用情况**：仅 `simulations/transformer_painter.dart` 与 `simulations/transformer_model.dart` 引用 `../phet/widgets/...`（grep 实证）
- **未被任何挂载到 Home 的 sim 引用**（`lib/` 内 grep `phet/widgets|phet/phet.dart` 结果为 0）
- **未被 `phet/magnet_and_compass`、`phet/quantum_coin_toss`、`phet/quantum_meansuremant` 引用**（这三个项目都是单文件或自带 lib/，不依赖 `phet/widgets/`）
- **结论**：`phet/widgets/` 是一个"为迁移 PhET 多个 sim 准备的共享组件库"，但实际只被一个未挂载的 transformer 用到。**疑似废弃 / 过度前置抽象**。

### 3.4 [待确认] 归并

| 项 | 疑点 |
|---|---|
| `simulations/magnet_and_compass.dart` vs `phet/magnet_and_compass/lib/main.dart` | 内容是否完全相同？如果相同，哪个是"权威源"？ |
| `simulations/electromagnet_model.dart` | 文件缺失但被 import——是被删除了？还是从未提交？还是计划中尚未创建？ |
| `phet/quantum_coin_toss` vs `phet/quantum_meansuremant` | 是否对应同一个 PhET Java 蓝本（"Quantum Measurements"）？为何有两个独立实现？哪个是新版？ |
| `assets/scenarios/color_vision/` vs `assets/scenarios/color-vision/` | 两个目录都存在（下划线 vs 连字符），哪个是当前在用的？是否其中一个已废弃？ |
| `lib/screens/scenario_selection_screen.dart` | `docs/reviews/interaction-issues-2026-08.md` C1 标注为"死代码（无活跃引用）"——是否可删？ |

---

## 4. 当前入口（Home 注册表）

`lib/screens/home_screen.dart:60-163` 定义 `_disciplines`：

| 学科 | 子领域 | sim 卡 | builder | 目标屏 |
|---|---|---|---|---|
| 物理 | 力学 | 力与运动 | `_buildForces` | `ForcesHome` (`lib/forces/screens/forces_home.dart`) |
| 物理 | 电学与电路 | 电路搭建 | `_buildCircuit` | `CircuitScreen` (`lib/circuit/screens/circuit_screen.dart`) |
| 物理 | 光学与波动 | 几何光学 | `_buildOptics` | `OpticsScreen` (`lib/optics/screens/optics_screen.dart`) |
| 物理 | 光学与波动 | 色觉 | `_buildColorVision` | `ColorVisionHome` (`lib/color_vision/screens/color_vision_home.dart`) |
| 物理 | 光学与波动 | 波的干涉 | `_buildWaveInterference` | `WaveInterferenceScreen` (`lib/wave_interference/screens/wave_interference_screen.dart`) |
| 物理 | 光学与波动 | 声波 | `_buildSound` | `SoundScreen` (`lib/sound/screens/sound_screen.dart`) |
| 物理 | 光学与波动 | 电磁波 | `_buildRadioWaves` | `RadioWavesScreen` (`lib/radio_waves/screens/radio_waves_screen.dart`) |
| 化学 | 溶液与浓度 | 摩尔浓度 | `_buildMolarity` | `MolarityScreen` (`lib/chemistry/molarity/view/screens/molarity_screen.dart`) |
| 化学 | 原子核 | 构建原子核 | `_buildBuildANucleus` | `BuildANucleusHome` (`lib/chemistry/build_a_nucleus/screens/build_a_nucleus_home.dart`) |

**未挂载**：Magnet & Compass / Electromagnet / Transformer / Quantum Coin Toss / Quantum Measurement / phet/widgets——这 6 项**没有任何 Home 卡**。

---

## 5. 测试覆盖矩阵

| Simulation | 单元测试 | 布局测试 | 集成测试 | 总数 |
|---|---|---|---|---|
| forces | `test/forces/forces_scenario_test.dart` | `forces_layout_test.dart`、`forces_home_test.dart` | — | 3 |
| circuit | `test/circuit/{circuit_solver_mna_test,inquiry_snapshot_test,scenario_manager_test}.dart` | `circuit_layout_test.dart` | — | 4 |
| optics | `optics_solver_test.dart` | — | — | 1 |
| color_vision | `test/color_vision/{challenge_config_test,magic_lab_ac44_test}.dart` | `color_vision_l9_regression_test.dart`、`rgb_bulbs_layout_test.dart`、`single_bulb_layout_test.dart` | `integration_test/color_vision_test.dart` | 6 |
| wave_interference | `wave_interference_model_test.dart` | `wave_radio_layout_test.dart`（与 radio_waves 共享） | — | 2 |
| sound | `sound_model_test.dart` | `sound_layout_test.dart` | — | 2 |
| radio_waves | `radio_waves_model_test.dart` | `wave_radio_layout_test.dart`（共享） | — | 2 |
| molarity | `test/chemistry/molarity/{molarity_scenario_test,molarity_screen_test,solution_test}.dart` | `molarity_layout_test.dart` | `integration_test/molarity_test.dart` | 5 |
| build_a_nucleus | `test/chemistry/build_a_nucleus/`（24）+ `chart_intro/`（17） | — | — | 41 |
| **common 共享层** | `test/common/`（8：conclusion_panel / experiment_intro_panel / experiment_logger / inquiry_scenario_parse / inquiry_task_panel / nine_grid_layout / prediction_panel / snapshot_chart） | — | `integration_test/app_test.dart`、`ac6_home_overflow_test.dart` | 10 |
| **phet/* 全部** | ❌ | ❌ | ❌ | 0 |
| **simulations/* 全部** | ❌ | ❌ | ❌ | 0 |

**总测试数**：73（test/）+ 4（integration_test/）= 77

---

## 6. requirements 映射

13 个 req 目录 + 1 个 `_template`：

| req-id | 状态 | 关联 sim | 备注 |
|---|---|---|---|
| `req-build-a-nucleus` | —（无 meta.yaml，仅分析报告） | build_a_nucleus | 含 `BUILD_A_NUCLEUS_*.md` + `CHART_INTRO_*.md` + `reference/` + `visual-qa/`（50 文件） |
| `req-port-molarity` | done | molarity | 化学模块首个 sim 复刻 · EDD v2.0 全流程 |
| `req-color-vision-layout-fix` | in_progress | color_vision | 修复 single_bulb 窄视口崩溃 |
| `req-verify-selftest-color-vision` | — | color_vision | 自测基线 · 含 screenshots/ |
| `req-home-screen-overflow-fix` | — | Home | 主界面溢出修复 |
| `req-nine-grid-layout` | — | 通用 | 九宫格布局规范落地（影响所有 sim） |
| `req-panel-bottom-migrate` | — | 通用 | 控件面板底部迁移 |
| `req-ui-interaction-polish` | — | 通用 | 交互打磨（对应 reviews/interaction-issues-2026-08.md） |
| `req-inquiry-chart-poc` | — | 通用 | 做中学图表 POC |
| `req-inquiry-chart-extend` | — | 通用 | 图表扩展 |
| `req-inquiry-extend` | — | 通用 | 做中学扩展 |
| `req-inquiry-learning` | — | 通用 | 做中学学习 |
| `req-predictive-inquiry` | — | 通用 | 预测式探究 |
| `req-ai-scenario-toolchain-lite` | — | 通用 | AI 场景生成工具链 |

**缺 requirements 的 sim**：forces / circuit / optics / sound / radio_waves / wave_interference（这 6 个已完成 sim 没有独立的复刻需求文档，可能是早期未走 SOP 直接开发的）。

---

## 7. 完成度详细评估

| Simulation | 完成度 | 依据 |
|---|---|---|
| forces | 已完成 | Home 挂载 + 4 model + 3 screen + 3 widget + 3 config + 测试 3 |
| circuit | 已完成 | Home 挂载 + 完整 MVC + 5 config + 1 service（sound_effects）+ 测试 4 + drag-logic 文档 |
| optics | 已完成 | Home 挂载 + 完整 MVC（含 physics/ + solvers/）+ 7 config + 测试 1（仅 solver） |
| color_vision | 已完成（含布局修复 in_progress） | Home 挂载 + 5 model + 3 screen + 5 painter + 2 solver + 测试 6 |
| wave_interference | **部分完成** | Home 挂载但 model/painter 各 1 文件（`wave_engine.dart` + `wave_heatmap_painter.dart`）——结构过单薄 |
| sound | 已完成 | Home 挂载 + 3 painter（spherical_view / wave_field / waveform_profile）+ 1 widget + 测试 2 |
| radio_waves | **部分完成** | Home 挂载但 model/painter 各 1 文件（`radio_state.dart` + `field_painter.dart`）——结构过单薄 |
| molarity | 已完成 | Home 挂载 + 完整 MVC（model 5 + controller 1 + view/{screens,painters,widgets} 10 + config 3）+ req done |
| build_a_nucleus | 已完成（**参考规范**） | Home 挂载 + 双屏（Decay + Chart Intro）+ controller + model 9 + painters 2 + widgets 9 + data 4 + chart_intro/ 子结构 40 + 测试 41 |
| phet/magnet_and_compass | **原型** | 单文件 1650 行 · 自带 main · 无测试 · 未挂载 |
| phet/quantum_coin_toss | **原型** | 独立 lib/ 但无 main · 无测试 · 未挂载 |
| phet/quantum_meansuremant | **原型** | 独立 lib/ + CoinsScreen + Model + View · 无 main · 无测试 · 未挂载 · 目录拼写错误 |
| simulations/magnet_and_compass.dart | **重复实现** | 与 phet/magnet_and_compass 重复 |
| simulations/electromagnet | **孤立代码** | 缺 `electromagnet_model.dart` · 无法编译 |
| simulations/transformer | **孤立代码** | 完整 3 文件 · 但未挂载 Home |
| phet/widgets | **疑似废弃** | 71 文件组件库 · 仅被未挂载的 transformer 引用 |

---

## 8. 当前目录问题清单

### 8.1 [已确认] 结构风格分裂

9 个正规 sim 的目录命名不统一，分三派：

| 风格派 | sim | 目录特征 |
|---|---|---|
| **单数 `model/` + `painters/` + `screens/`** | color_vision · sound · wave_interference · radio_waves | `model/`（单数）· `painters/`· `screens/` |
| **复数 `models/` + `widgets/` + `screens/`** | forces · circuit | `models/`（复数）· 无 painters/ · 用 `widgets/` |
| **`models/` + `solvers/` + `physics/`** | optics | `models/` + `solvers/` + `physics/`（独有） |
| **`model/` + `controller/` + `view/{screens,painters,widgets}/`** | molarity | 二级嵌套 `view/` |
| **`controller/` + `model/` + `screens/` + `painters/` + `widgets/` + `data/` + 子模块** | build_a_nucleus | 最完整 · 含 `chart_intro/` 二级 sim |

**Build a Nucleus 风格**（controller + 单数 model + screens + painters + widgets + data）是当前最规范、最贴近 80-kratos-sim-checklist §二 MVC 架构的形态。其余 sim 偏差：

- molarity 用 `view/` 二级嵌套（screens/painters/widgets 都进 view/）——与 build_a_nucleus 平铺不一致
- forces/circuit 用复数 `models/`——与 build_a_nucleus 单数 `model/` 不一致
- optics 用 `solvers/`（复数）+ `physics/`——独有
- 4 个波动 sim（color_vision/sound/wave_interference/radio_waves）用单数 `model/`+`painters/`——彼此一致但与 build_a_nucleus 的 controller 缺失（这 4 个都没有 `controller/` 目录）不一致

### 8.2 [已确认] 散落根目录的孤立文件

`simulations/` 6 个 .dart 文件**无目录组织**：

```
simulations/
  electromagnet_page.dart       # 引用 ../phet/widgets + magnet_and_compass.dart
  electromagnet_painter.dart    # 引用 electromagnet_model.dart（缺失）
  magnet_and_compass.dart       # 与 phet/magnet_and_compass/lib/main.dart 重复
  transformer_model.dart        # 引用 ../phet/widgets/physics/magnetism/electromagnet.dart
  transformer_page.dart         # 引用 transformer_model + transformer_painter
  transformer_painter.dart      # 引用 ../phet/widgets/{physics,visualization,shapes,core}/...
```

这 6 个文件应该归属于 3 个 sim（magnet_and_compass / electromagnet / transformer），但被扁平堆放在同一个 `simulations/` 目录下，无子目录切分。

### 8.3 [已确认] PhET 项目结构违反工程规范

3 个 `phet/` 项目都自带 `main()` 或独立 `lib/`，违反工程"单一 MaterialApp 入口"原则：

- `phet/magnet_and_compass/lib/main.dart`：自带 `MagnetApp` + `MaterialApp` + `main()`（与 `lib/main.dart` 的 `KratosApp` 冲突）
- `phet/quantum_coin_toss/lib/quantum_coin_toss.dart`：定义 `CoinModel` 等但无 `main()`（半成品）
- `phet/quantum_meansuremant/lib/coins/coins_screen.dart`：`CoinsScreen` + `CoinsModel` + 独立 `view/`（MVC 分裂为 model+view，无 controller）

### 8.4 [已确认] 路径漂移

- `docs/drag-logic.md` 顶部写 "文件：`lib/screens/circuit_screen.dart`"——实际路径是 `lib/circuit/screens/circuit_screen.dart`（已漂移）
- `docs/project-requirements-overview.md:20` 写 "完成 sim 数 **8 个**"——实际 Home 已挂载 9 个（含 build_a_nucleus，文档未更新）
- `docs/architecture.md` 是 `/wf init` 自动生成的占位文档（"Project is a Unknown project"），与实际 Flutter PhET 复刻项目完全脱节

### 8.5 [已确认] assets 目录命名不统一

| 命名风格 | sim |
|---|---|
| 连字符 `color-vision/` `radio-waves/` `wave-interference/` | color_vision · radio_waves · wave_interference |
| 下划线 `color_vision/`（**与连字符并存**） | color_vision（重复） |
| 单词 `circuit/` `forces/` `molarity/` `sound/` | circuit · forces · molarity · sound |
| 直接在 scenarios 根 | optics（`basic-lens-imaging.json` 等 3 个） |

`lib/` 用下划线（snake_case），`assets/scenarios/` 用连字符——**跨层命名不一致**。

---

## 9. 重复代码清单

### 9.1 [已确认] Magnet & Compass 三重存在

| 位置 | 行数 | 状态 |
|---|---|---|
| `phet/magnet_and_compass/lib/main.dart` | 1650 | 原型 · 自带 main |
| `simulations/magnet_and_compass.dart` | >60（读取前 60 行结构与 #1 一致） | 注释 "Migrated from lib/src/phet/magnet_and_compass/lib/main.dart" |
| `simulations/electromagnet_page.dart` | reuse `CompassPainter` from `magnet_and_compass.dart` | 部分复用 |

### 9.2 [已确认] MagneticField 计算逻辑重复

`MagneticField.compute(...)` 静态方法在 `phet/magnet_and_compass/lib/main.dart:199-263` 实现，而 `phet/widgets/physics/magnetism/electromagnet.dart` 也提供电磁铁/磁场计算（被 `simulations/transformer_model.dart` 引用）。**两套磁场计算实现并存**。

### 9.3 [推测] Quantum 系列两套实现

`phet/quantum_coin_toss/` 与 `phet/quantum_meansuremant/` 都涉及"量子 + 硬币 + 测量"概念，但：

- coin_toss 用 `CoinMode.classical/quantum` + `CoinOrientation/CoinFace` + `MeasurementState`
- meansuremant 用 `CoinsModel` + `CoinsScreen` + `view/coins_screen_view.dart`

**疑似同一 PhET Java 蓝本（"Quantum Measurements"）的两种实现尝试**，需确认是否应合并。

### 9.4 [已确认] PhET 共享层 vs kratos 共享层重复

| kratos 共享层 (`lib/common/`) | phet 共享层 (`phet/widgets/`) | 重复能力 |
|---|---|---|
| `controls/kratos_slider.dart` | `controls/phet_slider.dart` | Slider |
| `controls/kratos_combo_box.dart` | `controls/phet_button.dart` 等 | 控件 |
| `widgets/property_control_panel.dart` | `panels/phet_control_panel.dart` | 参数面板 |
| `widgets/time_control_bar.dart` | `simulation/simulation_control_bar.dart` | 时控条 |
| `simulation_clock.dart` | `simulation/simulation_clock.dart` | 时钟 |
| `chart/kratos_chart.dart` | `graphs/phet_graph.dart` | 图表 |
| — | `visualization/compass.dart` / `field.dart` / `field_arrow_painter.dart` | 磁场可视化（kratos 无对应） |

两套共享层并存，`phet/widgets/` 几乎是 `lib/common/` 的平行实现。**违反 80-kratos-sim-checklist §三 G1（L0 复用强制）**。

---

## 10. 孤立代码清单

| 文件/目录 | 类型 | 孤立原因 | 风险 |
|---|---|---|---|
| `phet/magnet_and_compass/lib/main.dart` | 自带 main 的 app | 与 `lib/main.dart` 的 KratosApp 冲突 · 未挂载 Home | 编译冲突（两个 main） |
| `phet/quantum_coin_toss/lib/*` | 半成品 | 无 main · 无 Home 挂载 · 无测试 | 死代码 |
| `phet/quantum_meansuremant/lib/*` | 半成品 + 拼写错误 | 目录名 `meansuremant` · 无 main · 无 Home · 无测试 | 死代码 |
| `phet/widgets/`（71 文件） | 共享组件库 | 仅被未挂载的 transformer 引用 · `lib/` 内 0 引用 | 大量死代码 |
| `phet/phet.dart` | barrel export | 导出 71 个 widget，但下游消费者仅 transformer | 死代码 |
| `simulations/electromagnet_page.dart` | 半成品 | import `electromagnet_model.dart` 缺失 · 无法编译 | 编译失败 |
| `simulations/electromagnet_painter.dart` | 半成品 | 依赖 #6 | 编译失败 |
| `simulations/magnet_and_compass.dart` | 重复 | 与 `phet/magnet_and_compass/lib/main.dart` 重复 | 维护双份 |
| `simulations/transformer_*.dart`（3 文件） | 原型 | 完整但未挂载 Home · 仅依赖 `phet/widgets` | 死代码 |
| `lib/screens/scenario_selection_screen.dart` | 死代码 | `docs/reviews/interaction-issues-2026-08.md` C1 标注"无活跃引用" | 死代码 |
| `docs/architecture.md` | 占位文档 | `/wf init` 自动生成 · 与实际项目脱节 | 误导 |
| `docs/code-scaffolds.md` | 占位文档 | `/wf init` 自动生成 · 通用模板 | 误导 |
| `docs/init-checklist.md` | 占位文档 | `/wf init` 自动生成 · 通用模板 | 误导 |

---

## 11. 迁移风险评估

| 风险 | 等级 | 描述 | 缓解 |
|---|---|---|---|
| **R1：phet/magnet_and_compass 自带 main()** | 🔴 高 | 与 `lib/main.dart` 共存会导致 Flutter 入口冲突；若直接 import 进 Home 会触发双重 MaterialApp | 迁移时必须删除自带 `main()` + `MagnetApp`，改为 `MagnetAndCompassScreen` StatelessWidget，由 Home builder 调用 |
| **R2：simulations/electromagnet 缺失 model 文件** | 🔴 高 | `electromagnet_model.dart` 被 import 但不存在 · 当前无法编译 | 迁移前必须先补齐 model 或确认该 sim 是否值得保留（与 magnet_and_compass 高度重叠） |
| **R3：phet/widgets/ 71 文件大规模废弃** | 🟡 中 | 若决定废弃 phet/widgets/，需先迁移 transformer 的依赖到 lib/common/ 或新建 lib/common/visualization/（磁场可视化） | 先做 transformer → lib/ 迁移，再评估 phet/widgets/ 是否还有保留价值 |
| **R4：Quantum 两套实现合并** | 🟡 中 | coin_toss vs meansuremant 哪个是权威不确定 · 贸然合并可能丢功能 | 需对照 PhET Java 蓝本确认 |
| **R5：assets/scenarios/color_vision vs color-vision 重复** | 🟡 中 | 两个目录都存在 · 若运行时优先读其中一个，另一个是死资源 | 先 grep 各 ScenarioManager 实际加载路径，再删冗余 |
| **R6：9 个正规 sim 目录风格分裂** | 🟡 中 | 单数/复数 · 嵌套/平铺 · 有/无 controller —— 全量统一改动面大 | 不建议为统一而统一；按 build_a_nucleus 风格在新 sim 落地，存量 sim 仅在改 bug 时顺手统一 |
| **R7：docs/ 占位文档误导** | 🟢 低 | architecture.md / code-scaffolds.md / init-checklist.md 是 /wf init 残留 | 直接删除或重写 |
| **R8：6 个已完成 sim 缺 requirements** | 🟡 中 | forces/circuit/optics/sound/radio_waves/wave_interference 没走 SOP · 历史债务 | 补回溯型 req（按 40-agent-self-evolution §commit 范围实证 回溯需求豁免条款） |
| **R9：KRATOS_STUDENT_SIMLAB_TECHNICAL_REQUIREMENTS.md 要求整体迁移** | 🔴 高 | 文档明确"KartosLab 必须作为 kratos-student 的内部功能模块集成"——当前独立 App 形态违反 §4 集成结论 | 这是更大的迁移项目（KartosLab → kratos-student/lib/src/simlab）· 本盘点是其前置基线 |
| **R10：phet/quantum_meansuremant 拼写错误** | 🟢 低 | 目录名 `meansuremant` 应为 `measurement` | 若决定保留则改名 · 若废弃则不处理 |

---

## 12. 建议目标目录

> 仅建议 · 本阶段**不修改任何文件**

### 12.1 正规 sim（已完成 9 个）

维持当前 `lib/<sim>/` 或 `lib/chemistry/<sim>/` 位置。**不建议大规模重构目录结构**——存量代码风险大、收益小。新 sim 复刻一律按 build_a_nucleus 风格：

```
lib/chemistry/<new_sim>/
  controller/<new_sim>_controller.dart
  model/                        # 单数
  screens/
  painters/
  widgets/
  data/                         # 如有数据
  ban_constants.dart 等价物     # 命名常量
```

### 12.2 PhET 项目迁移目标

#### 12.2.1 Magnet & Compass（保留并迁入工程）

```
lib/electromagnetism/magnet_and_compass/
  controller/
  model/magnet_state.dart        # 拆出 SimState
  screens/magnet_and_compass_screen.dart  # 删除自带 main + MagnetApp
  painters/                      # 拆出 4 个 Painter
  widgets/control_panel.dart
```

- 删除 `phet/magnet_and_compass/lib/main.dart` 的 `main()` + `MagnetApp` + `EntryPage`（EntryPage 功能由 Home 卡替代）
- `assets/earth.svg` 移至 `assets/images/electromagnetism/earth.svg` 并在 pubspec 显式声明

#### 12.2.2 Electromagnet + Transformer（合并到 electromagnetism 学科下）

```
lib/electromagnetism/electromagnet/
  model/electromagnet_model.dart  # 必须补齐当前缺失的文件
  screens/electromagnet_screen.dart
  painters/electromagnet_painter.dart

lib/electromagnetism/transformer/
  model/transformer_model.dart
  screens/transformer_screen.dart
  painters/transformer_painter.dart
```

- 重写 `transformer_painter.dart` 与 `transformer_model.dart` 对 `phet/widgets/` 的依赖为对 `lib/common/` 的依赖
- 若 `phet/widgets/visualization/compass.dart` / `field.dart` 无 kratos 等价物，触发 3-Time Rule 上抽到 `lib/common/visualization/`

#### 12.2.3 Quantum 系列（合并或废弃）

```
lib/quantum/coin_toss/   # 或废弃
lib/quantum/measurement/ # 修正拼写 meansuremant → measurement
```

需先对照 PhET Java 蓝本确认是否值得保留 · 若保留则两套合并为一套。

#### 12.2.4 phet/widgets/（废弃或上抽）

- **方案 A（推荐）**：废弃 `phet/widgets/` 整体，将其中有价值的组件（compass / field / field_arrow_painter）上抽到 `lib/common/visualization/`，其余删除
- **方案 B**：保留 `phet/widgets/` 作为"PhET 风格组件库"但改名为 `lib/phet_widgets/` 并接入工程——不推荐，会与 `lib/common/` 形成永久双轨

### 12.3 顶级 Home 卡扩展

若决定接入 magnet_and_compass / electromagnet / transformer，在 `lib/screens/home_screen.dart` 的 `_disciplines` 物理学科下新增子领域"电磁学"：

```
_SubjectGroup(name: '电磁学', sims: [
  _SimEntry(title: '磁铁与指南针', builder: _buildMagnetAndCompass, ...),
  _SimEntry(title: '电磁铁', builder: _buildElectromagnet, ...),
  _SimEntry(title: '变压器', builder: _buildTransformer, ...),
])
```

### 12.4 占位文档清理

```
docs/architecture.md         → 重写为真实架构（或删除）
docs/code-scaffolds.md       → 删除（与 docs/knowledge/kratos/ 重复）
docs/init-checklist.md       → 删除
docs/drag-logic.md           → 修正路径 lib/screens/ → lib/circuit/screens/
docs/project-requirements-overview.md → 更新"8 个"为"9 个"
```

### 12.5 散落根目录文件

`simulations/` 目录整体**应被清空**——6 个文件归并到对应 sim 目录后删除该目录。

---

## 13. 与 Build a Nucleus 参考规范对照

Build a Nucleus (`lib/chemistry/build_a_nucleus/`) 是工程内最完整的 sim，作为参考规范：

| 维度 | Build a Nucleus | 其余 sim 偏差 |
|---|---|---|
| 目录 | `lib/chemistry/build_a_nucleus/` | optics 无 `chemistry/` 二级（合理，非化学） |
| controller | `controller/build_a_nucleus_controller.dart` + `chart_intro/controller/chart_intro_controller.dart` | color_vision / sound / wave_interference / radio_waves **无 controller/** |
| model | `model/`（单数）+ 9 文件 + `chart_intro/model/` 7 文件 | forces/circuit 用复数 `models/`；molarity 单数 `model/` 一致 |
| screens | `screens/` 3 文件（home + decay + chart_intro） | 多数 sim 仅 1 screen（合理） |
| painters | `painters/` 2 + `chart_intro/painters/` 6 | 风格一致 |
| widgets | `widgets/` 9 + `chart_intro/widgets/` 12 | forces/circuit 用 `widgets/`（一致） |
| tests | `test/chemistry/build_a_nucleus/` 24 + `chart_intro/` 17 = 41 | 多数 sim 测试 < 10 |
| requirements | `requirements/req-build-a-nucleus/` 50 文件 | 6 个 sim 无 requirements |
| assets | `assets/data/nuclide_table.json` + `assets/images/full_nuclide_chart.png` | 风格一致 |
| navigation | Home `_buildBuildANucleus` → `BuildANucleusHome`（Tab 容器：Decay + Chart Intro） | 其余 sim 单屏直接 push |
| naming | `BuildANucleus*` / `ChartIntro*` 类名前缀 + `build_a_nucleus_*` 文件名 | 一致 |

**结论**：Build a Nucleus 风格适用于新 sim 复刻，但**不应强行套用到已完成 sim**——存量 sim 的风格偏差（单数/复数、有无 controller）影响有限，统一改动成本高于收益。

---

## 14. 推测与待确认清单

### 14.1 [推测]

1. `simulations/magnet_and_compass.dart` 是从 `phet/magnet_and_compass/lib/main.dart` 迁移到工程根的中间产物（注释实证）
2. `phet/quantum_coin_toss` 与 `phet/quantum_meansuremant` 对应同一 PhET Java 蓝本 "Quantum Measurements"
3. `phet/widgets/` 是为批量迁移 PhET 多个 sim 准备的前置共享层，但因 kratos 已有 `lib/common/` 而被边缘化
4. `simulations/electromagnet_model.dart` 从未创建（非被删除）——依据是其 import 在但文件不在
5. `assets/scenarios/color_vision/` 与 `assets/scenarios/color-vision/` 之一已废弃（哪个废弃需 grep ScenarioManager）
6. 6 个已完成但无 requirements 的 sim（forces/circuit/optics/sound/radio_waves/wave_interference）是早期未走 SOP 直接开发的产物
7. `docs/architecture.md` 等三份占位文档是 `/wf init` 流程的残留

### 14.2 [待确认]

1. **`simulations/magnet_and_compass.dart` 与 `phet/magnet_and_compass/lib/main.dart` 内容是否完全相同？** 哪个是权威源？
2. **`phet/quantum_coin_toss` 与 `phet/quantum_meansuremant` 是否对应同一 PhET Java 蓝本？** 哪个是新版？是否合并？
3. **`simulations/electromagnet_model.dart` 应该补齐还是删除整个 electromagnet？** 与 magnet_and_compass 功能重叠度多高？
4. **`assets/scenarios/color_vision/` vs `color-vision/` 哪个在用？** 运行时 ScenarioManager 加载哪个？
5. **`phet/widgets/` 是否值得保留？** 还是全部上抽到 `lib/common/` 后废弃？
6. **`lib/screens/scenario_selection_screen.dart` 是否真的死代码？** reviews 标注 C1，但需二次确认
7. **接入 magnet_and_compass / electromagnet / transformer 到 Home 是否是当前迁移项目的目标？** 还是这些 PhET 原型应直接废弃？
8. **KRATOS_STUDENT_SIMLAB_TECHNICAL_REQUIREMENTS.md 的"迁移到 kratos-student/lib/src/simlab"是否启动？** 若启动，本盘点是否为其前置基线？
9. **6 个已完成无 requirements 的 sim 是否要补回溯型 req？** 走 40-agent-self-evolution §commit 范围实证 回溯豁免？
10. **`docs/drag-logic.md` 路径漂移是历史遗留还是 drag-logic 描述的是旧路径？** circuit_screen 是否曾从 `lib/screens/` 迁到 `lib/circuit/screens/`？

---

## 15. 完成声明

- 本报告基于 READ-ONLY 扫描，**未修改任何文件**。
- 所有 [已确认] 项均有工具调用实证（list_dir / read_file / search_content）。
- 所有 [推测] 项已标注推测依据。
- 所有 [待确认] 项已列出待回答的问题。
- 下一步动作由用户决定（迁移 / 废弃 / 接入 Home / 等）。

---

## 附录 A：扫描工具调用清单

- `list_dir` × 60+ 次（覆盖 lib/ · test/ · assets/ · requirements/ · docs/ · scripts/ · simulations/ · phet/ · integration_test/ · schemas/ 及各级子目录）
- `read_file` × 20+ 次（main.dart / home_screen.dart / 各孤立 sim 入口 / meta.yaml / docs/）
- `search_content` × 4 次（grep `phet/widgets` 引用 / `simulations/` 引用 / 重复类名 / phet barrel import）

## 附录 B：关键文件路径速查

| 文件 | 路径 |
|---|---|
| 主入口 | `lib/main.dart` |
| Home 路由表 | `lib/screens/home_screen.dart:60-163` |
| 参考规范 sim | `lib/chemistry/build_a_nucleus/` |
| 孤立 PhET 项目 | `phet/{magnet_and_compass,quantum_coin_toss,quantum_meansuremant}/` |
| PhET 共享层 | `phet/widgets/` + barrel `phet/phet.dart` |
| 散落根文件 | `simulations/{electromagnet,magnet_and_compass,transformer}_*.dart` |
| 占位文档 | `docs/{architecture,code-scaffolds,init-checklist}.md` |
| 路径漂移文档 | `docs/drag-logic.md`（写 `lib/screens/circuit_screen.dart`，实际在 `lib/circuit/screens/`） |
| 集成要求 | `KRATOS_STUDENT_SIMLAB_TECHNICAL_REQUIREMENTS.md` |
| 交互问题清单 | `docs/reviews/interaction-issues-2026-08.md` |
| 项目总览（需更新） | `docs/project-requirements-overview.md`（写"8 个 sim"，实际 9 个） |
