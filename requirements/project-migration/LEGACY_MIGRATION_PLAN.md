# LEGACY MIGRATION PLAN

> 生成日期：2026-08-31
> 阶段：**READ-ONLY 迁移计划** · 未修改任何文件
> 依据：`requirements/project-migration/LEGACY_SIMULATION_INVENTORY.md`（盘点报告）
> 决策动词：KEEP / MIGRATE / MERGE / ARCHIVE / DELETE / BLOCKED
> 引用先行：所有标记 `[已确认]` 的结论均有工具调用实证

---

## Magnet status（2026-08-31 M7）

**MIGRATED / VERIFIED**

- 正式实现：`lib/magnetism/magnet_and_compass/`
- Home：物理 → 电磁学 → 磁铁与罗盘
- Legacy B 已归档：`requirements/project-migration/archive/magnet_and_compass.dart`（不删除）
- PhET A 原位保留：`phet/magnet_and_compass/`（独立 app / 视觉对照）
- Earth 仍 **BLOCKED: missing earth.svg**
- Electromagnet / Transformer 仍 **BLOCKED**（非 Magnet 范围）

详见 `MAGNET_MIGRATION_M6_HOME.md` · `MAGNET_MIGRATION_M7.md`。

---

## 0. 执行摘要

本计划覆盖 16 个 simulation 代码集合 + 相关 assets / docs / 共享层。核心结论：

- **KEEP（10 个）**：9 个原已挂载 Home 的正规 sim + **magnet_and_compass（MIGRATED / VERIFIED）**
- **BLOCKED（4 个）**：2 个 PhET quantum 项目 + electromagnet 散落文件 + transformer 散落文件——需用户决策才能确定动作
- **ARCHIVE（2 个）**：phet/widgets 组件库；**Legacy Magnet B** `simulations/magnet_and_compass.dart` → `requirements/project-migration/archive/magnet_and_compass.dart`
- **DELETE（3 个文档）**：3 份 /wf init 占位文档——存在明确证据
- **MERGE（1 组）**：color_vision 重复 assets 目录——确认连字符版在用，下划线版仅 2 个文件
- **3-Time Rule**：磁场计算 4 处实现，唯一归属 [待确认]（运行时 Magnet 以 `lib/magnetism/magnet_and_compass/model/magnetic_field.dart` 为准）
- **入口冲突**：phet/magnet_and_compass 自带 main()——**保留为对照 reference**，不接入 KratosApp `main`

---

## 1. Simulation 唯一身份

| Simulation | PhET 原项目 | 当前 Home 引用 | import dependency | tests | assets | simulation-specific code | requirements | 是否存在多副本 |
|---|---|---|---|---|---|---|---|---|
| forces | [推测] Forces & Motion | ✅ `_buildForces` | `lib/common/` 共享层 | ✅ 3 | `scenarios/forces/` + `images/mechanics/` | `lib/forces/` 13 文件 | ❌ | ❌ |
| circuit | [推测] Circuit Construction Kit | ✅ `_buildCircuit` | `lib/common/` | ✅ 4 | `scenarios/circuit/` + `images/circuit/` | `lib/circuit/` 12 文件 | ❌ | ❌ |
| optics | [推测] Geometric Optics | ✅ `_buildOptics` | `lib/common/` | ✅ 1 | `scenarios/*.json`（顶层）+ `images/optics/` | `lib/optics/` 15 文件 | ❌ | ❌ |
| color_vision | Color Vision | ✅ `_buildColorVision` | `lib/common/` | ✅ 6 | `scenarios/color-vision/`（11）+ `scenarios/color_vision/`（2） | `lib/color_vision/` 17 文件 | ✅ 2 req | ✅ assets 双目录 |
| wave_interference | Wave Interference | ✅ `_buildWaveInterference` | `lib/common/` | ✅ 2 | `scenarios/wave-interference/` | `lib/wave_interference/` 5 文件 | ❌ | ❌ |
| sound | Sound | ✅ `_buildSound` | `lib/common/` | ✅ 2 | `scenarios/sound/` | `lib/sound/` 8 文件 | ❌ | ❌ |
| radio_waves | Radio Waves & Electromagnetic Fields | ✅ `_buildRadioWaves` | `lib/common/` | ✅ 2 | `scenarios/radio-waves/` | `lib/radio_waves/` 5 文件 | ❌ | ❌ |
| molarity | Molarity | ✅ `_buildMolarity` | `lib/common/` | ✅ 5 | `scenarios/molarity/` | `lib/chemistry/molarity/` 19 文件 | ✅ req-port-molarity (done) | ❌ |
| build_a_nucleus | Build a Nucleus | ✅ `_buildBuildANucleus` | `lib/common/` | ✅ 41 | `data/nuclide_table.json` + `images/full_nuclide_chart.png` | `lib/chemistry/build_a_nucleus/` 60+ 文件 | ✅ req-build-a-nucleus | ❌ |
| **magnet_and_compass** | Magnet & Compass | ✅ `_buildMagnetAndCompass` | `lib/magnetism/magnet_and_compass/` | ✅ `test/magnetism` | `earth.svg` 仍缺 | 正式 `lib/magnetism/...` | ✅ MAGNET_MIGRATION_* | PhET A 保留；B 已 ARCHIVE |
| **electromagnet** | [推测] Faraday's Electromagnetic Lab（Electromagnet 子屏） | ❌ 未挂载 | import `electromagnet_model.dart`（**缺失**）+ reuse `magnet_and_compass.dart` 的 `CompassPainter` | ❌ | ❌ | `simulations/electromagnet_{page,painter}.dart` | ❌ | ❌ |
| **transformer** | [推测] Faraday's Electromagnetic Lab（Transformer 子屏） | ❌ 未挂载 | `phet/widgets/physics/magnetism/electromagnet.dart` + `phet/widgets/visualization/field.dart` 等 | ❌ | ❌ | `simulations/transformer_{page,model,painter}.dart` | ❌ | ❌ |
| **quantum_coin_toss** | [推测] Quantum Measurement（coin toss 子模块） | ❌ 未挂载 | 自包含 | ❌ | ❌ | `phet/quantum_coin_toss/lib/`（8 文件） | ❌ | ✅ 疑似与 meansuremant 同源 |
| **quantum_meansuremant** | [推测] Quantum Measurement | ❌ 未挂载 | 自包含 | ❌ | ❌ | `phet/quantum_meansuremant/lib/`（13 文件） | ❌ | ✅ 疑似与 coin_toss 同源 |
| **phet/widgets** | N/A（共享层） | N/A | barrel export `phet/phet.dart` | ❌ | ❌ | `phet/widgets/` 71 文件 | ❌ | ✅ 与 `lib/common/` 平行 |
| **simulations/magnet_and_compass.dart** | Magnet & Compass（Legacy B） | ❌ 已移出运行目录 | 无 Dart import | ❌ | ❌ | `requirements/project-migration/archive/magnet_and_compass.dart` | ✅ M7 | **ARCHIVE** · MIGRATED / VERIFIED |

---

## 2. 迁移决策矩阵

| # | Simulation | 当前来源 | 使用中的实现 | 重复实现 | Home | Tests | Assets | 当前状态 | 建议动作 | 目标目录 | 风险 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | forces | `lib/forces/` | ✅ `ForcesHome` | ❌ | ✅ | ✅ 3 | ✅ | 已完成 | **KEEP** | `lib/forces/`（不变） | 低 |
| 2 | circuit | `lib/circuit/` | ✅ `CircuitScreen` | ❌ | ✅ | ✅ 4 | ✅ | 已完成 | **KEEP** | `lib/circuit/`（不变） | 低 |
| 3 | optics | `lib/optics/` | ✅ `OpticsScreen` | ❌ | ✅ | ✅ 1 | ✅ | 已完成 | **KEEP** | `lib/optics/`（不变） | 低 |
| 4 | color_vision | `lib/color_vision/` | ✅ `ColorVisionHome` | assets 双目录 | ✅ | ✅ 6 | ✅ | 已完成（布局修复 in_progress） | **KEEP** + MERGE assets | `lib/color_vision/`（不变）+ 删 `assets/scenarios/color_vision/`（下划线） | 中 |
| 5 | wave_interference | `lib/wave_interference/` | ✅ `WaveInterferenceScreen` | ❌ | ✅ | ✅ 2 | ✅ | 部分完成 | **KEEP** | `lib/wave_interference/`（不变） | 低 |
| 6 | sound | `lib/sound/` | ✅ `SoundScreen` | ❌ | ✅ | ✅ 2 | ✅ | 已完成 | **KEEP** | `lib/sound/`（不变） | 低 |
| 7 | radio_waves | `lib/radio_waves/` | ✅ `RadioWavesScreen` | ❌ | ✅ | ✅ 2 | ✅ | 部分完成 | **KEEP** | `lib/radio_waves/`（不变） | 低 |
| 8 | molarity | `lib/chemistry/molarity/` | ✅ `MolarityScreen` | ❌ | ✅ | ✅ 5 | ✅ | 已完成 | **KEEP** | `lib/chemistry/molarity/`（不变） | 低 |
| 9 | build_a_nucleus | `lib/chemistry/build_a_nucleus/` | ✅ `BuildANucleusHome` | ❌ | ✅ | ✅ 41 | ✅ | 已完成（参考规范） | **KEEP** | `lib/chemistry/build_a_nucleus/`（不变） | 低 |
| 9a | magnet_and_compass（正式） | `lib/magnetism/magnet_and_compass/` | ✅ `MagnetAndCompassScreen` | PhET A + archive B | ✅ | ✅ 40 | earth.svg 缺 | **MIGRATED / VERIFIED** | **KEEP** | `lib/magnetism/magnet_and_compass/` | 低 |
| 10 | magnet_and_compass（PhET A） | `phet/magnet_and_compass/lib/main.dart` | ❌（对照用） | ✅ 已迁 lib | ❌ | visual QA 引用 | `earth.svg` 缺 | 对照 reference | **KEEP reference** | `phet/magnet_and_compass/`（不变） | 低 |
| 11 | quantum_coin_toss | `phet/quantum_coin_toss/lib/` | ❌ | ✅ #12 疑似同源 | ❌ | ❌ | ❌ | 原型 | **BLOCKED** | [待确认] | 中 |
| 12 | quantum_meansuremant | `phet/quantum_meansuremant/lib/` | ❌ | ✅ #11 疑似同源 | ❌ | ❌ | ❌ | 原型·拼写错误 | **BLOCKED** | [待确认] | 中 |
| 13 | magnet_and_compass（Legacy B） | 原 `simulations/magnet_and_compass.dart` | ❌ | ✅ #9a/#10 | ❌ | ❌ | ❌ | 已归档 | **ARCHIVE** · **MIGRATED / VERIFIED** | `requirements/project-migration/archive/magnet_and_compass.dart` | 低 |
| 14 | electromagnet | `simulations/electromagnet_{page,painter}.dart` | ❌ | ❌ | ❌ | ❌ | ❌ | 原型·缺 model·无法编译 | **BLOCKED** | [待确认] | 🔴 高 |
| 15 | transformer | `simulations/transformer_{page,model,painter}.dart` | ❌ | ❌ | ❌ | ❌ | ❌ | 原型·完整但未挂载 | **BLOCKED** | [待确认] | 中 |
| 16 | phet/widgets | `phet/widgets/`（71 文件）+ `phet/phet.dart` | ❌ | ✅ 与 `lib/common/` 平行 | N/A | ❌ | N/A | 疑似废弃·仅 1 孤立消费者 | **ARCHIVE** | 从运行工程退出·[待确认]是否上抽磁场可视化 | 中 |

---

## 3. 重复项目特别处理

### 3.1 magnet_and_compass（三重存在）

**M7 状态：MIGRATED / VERIFIED。** 运行实现为 `lib/magnetism/magnet_and_compass/`。Legacy B 已 ARCHIVE。PhET A 原位保留作对照。Earth 仍缺 svg。

#### 来源 A：`phet/magnet_and_compass/lib/main.dart`

- **路径**：`phet/magnet_and_compass/lib/main.dart`
- **动作**：**KEEP reference**（不接入 `KratosApp.main`）
- **入口**：自带 `main()` + `MagnetApp` + `SimulationPage`（视觉 QA 对照）
- **earth.svg**：仍缺失

#### 来源 B：Legacy 单文件

- **原路径**：`simulations/magnet_and_compass.dart`
- **归档**：`requirements/project-migration/archive/magnet_and_compass.dart`
- **动作**：**ARCHIVE**（完整源码保留，不永久删除）
- **runtime consumer**：0（M7 grep：无 Dart import / export / Home / test）
- **electromagnet**：已改 import 正式 `CompassPainter`；仍因缺 model **BLOCKED**

#### 正式 target

- `lib/magnetism/magnet_and_compass/` + Home「磁铁与罗盘」

#### 来源 C：`simulations/electromagnet_page.dart`（部分复用）

- **路径**：`simulations/electromagnet_page.dart`
- **复用方式**：`package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart`
- **特点**：仍 BLOCKED（`electromagnet_model.dart` 缺失）

#### 决策依据（历史 · 已执行）

来源 B 为迁移真源；已拆入 `lib/`。PhET A 不作删除。禁止永久 delete B。

---

### 3.2 electromagnet（缺失依赖）

#### 当前状态

- **路径**：`simulations/electromagnet_page.dart` + `simulations/electromagnet_painter.dart`
- **缺失**：`electromagnet_model.dart`（被两个文件 import 但文件不存在）
  - [已确认] `simulations/` 目录内无 `electromagnet_model.dart`（search_file 结果 0）
  - [已确认] `lib/` 目录内无 `electromagnet_model.dart`（search_content 结果 0）
  - [已确认] `phet/` 目录内无 `electromagnet_model.dart`（search_file 全局结果 0）
- **依赖**：import `magnet_and_compass.dart` 的 `CompassPainter`（即来源 B）

#### 缺什么

| 缺失项 | 被谁 import | 是否在其他位置存在同名/类似 Model | 是否可确认属于同一项目 |
|---|---|---|---|
| `electromagnet_model.dart` | `electromagnet_page.dart:7` + `electromagnet_painter.dart:5` | ❌ 不存在 | [推测] 属于 electromagnet 项目 |

[已确认] 工程内**不存在**任何 `electromagnet_model.dart` 文件（全局 search_file 递归结果为 0）。

#### [推测] 原因

从 `electromagnet_page.dart` 前 60 行可见：
- 引用 `ElectromagnetState`（含 voltage / sourceType / loops / showField / showElectrons / showCompass 等字段）
- 引用 `ElectronModel`（含 positions 列表）
- 引用 `CurrentSourceType.dc`

这些类**应该在 `electromagnet_model.dart` 中定义**，但该文件从未创建。

#### 是否只是未完成原型

[推测] 是——`electromagnet_page.dart` 的 `initState()` 实例化了 `ElectromagnetState(...)` 和 `ElectronModel(...)`，说明作者已设计好 model 接口，但 model 实现文件未创建。

#### 决策

- **BLOCKED**——禁止为了迁移而自行生成缺失 Model（用户明确要求）
- 需用户决策：
  - 补齐 model → MIGRATE 到 `lib/electromagnetism/electromagnet/`
  - 废弃 → ARCHIVE 或 DELETE（但需确认与 magnet_and_compass 功能重叠度）

---

### 3.3 transformer（孤立但完整）

#### 当前状态

- **路径**：`simulations/transformer_{page,model,painter}.dart`（3 文件完整）
- **入口**：`TransformerPage`（StatefulWidget · 未挂载 Home）
- **依赖**：`phet/widgets/physics/magnetism/electromagnet.dart` + `phet/widgets/visualization/field.dart` + `phet/widgets/visualization/field_arrow_painter.dart` + `phet/widgets/shapes/phet_arrow.dart` + `phet/widgets/core/phet_types.dart`
- **注释**："Faraday's Electromagnetic Lab → Transformer page"
- **测试**：❌ 无

#### 决策

- **BLOCKED**——完整但未挂载 · 依赖 phet/widgets（而 phet/widgets 本身也 BLOCKED）
- 需用户决策：
  - 接入 Home → MIGRATE 到 `lib/electromagnetism/transformer/` + 重写对 phet/widgets 的依赖
  - 废弃 → ARCHIVE

---

### 3.4 phet/widgets（共享组件库）

#### 被谁引用

[已确认] grep `phet/widgets|phet/phet.dart` 全工程结果：

| 引用方 | 引用路径 |
|---|---|
| `simulations/transformer_painter.dart` | `../phet/widgets/visualization/field.dart` + `field_arrow_painter.dart` + `shapes/phet_arrow.dart` + `core/phet_types.dart` |
| `simulations/transformer_model.dart` | `../phet/widgets/physics/magnetism/electromagnet.dart` |
| `phet/phet.dart` | barrel export（自身） |

**仅 2 个文件引用 `phet/widgets/`，且这 2 个文件本身都是 `simulations/transformer_*.dart`（未挂载 Home 的孤立代码）。**

#### 是否只有 transformer 使用

[已确认] 是。`lib/` 内 grep `phet/widgets|phet/phet.dart` 结果为 0。`phet/` 内 3 个项目（magnet_and_compass / quantum_coin_toss / quantum_meansuremant）都不引用 `phet/widgets/`。

#### transformer 是否本身孤立

[已确认] transformer 未挂载 Home · 无测试 · 无 requirements。

#### 是否存在通用能力

[推测] `phet/widgets/` 中以下组件具有通用价值（`lib/common/` 无等价物）：

| phet/widgets 组件 | 通用能力 | lib/common 等价物 |
|---|---|---|
| `visualization/compass.dart` | 指南针绘制 | ❌ 无 |
| `visualization/field.dart` | 磁场可视化 | ❌ 无 |
| `visualization/field_arrow_painter.dart` | 磁场箭头绘制 | ❌ 无 |
| `physics/magnetism/electromagnet.dart` | 电磁铁/磁场计算 | ❌ 无 |

其余组件（slider / combo_box / panel / clock / chart / button 等）在 `lib/common/` 均有等价物（见盘点报告 §9.4）。

#### 是否存在重复实现

[已确认] phet/widgets 与 lib/common 存在大量平行实现（盘点报告 §9.4）。

#### 决策

- **ARCHIVE**——从运行工程退出
- **禁止直接移动到 `lib/common/`**——需逐个评估：
  - 有 lib/common 等价物的 → 不移动（用 lib/common 版）
  - 无等价物且有通用价值的（compass / field / field_arrow_painter / electromagnet）→ [待确认] 是否上抽到 `lib/common/visualization/`
- **禁止直接删除**——需用户确认是否保留磁场可视化能力

---

## 4. 3-Time Rule：磁场计算逻辑

### 4 处实现

| 实现 | 路径 | 被谁引用 | 是否相同 | 建议唯一归属 |
|---|---|---|---|---|
| **实现 1** | `phet/magnet_and_compass/lib/main.dart`（`MagneticField.compute()` 静态方法 + 4 Painter） | ❌ 无（未挂载） | — | [待确认] |
| **实现 2** | `simulations/magnet_and_compass.dart`（`SimState` + `CompassPainter` + `BarMagnetPainter`——[推测] 与实现 1 相同） | `simulations/electromagnet_page.dart`（show CompassPainter） | [待确认] 未做全文 diff | [待确认] |
| **实现 3** | `simulations/electromagnet_page.dart` + `electromagnet_painter.dart`（ElectromagnetPainter + reuse CompassPainter） | ❌ 无（未挂载） | 部分复用实现 2 的 CompassPainter | [待确认] |
| **实现 4** | `phet/widgets/physics/magnetism/electromagnet.dart`（电磁铁/磁场计算）+ `phet/widgets/visualization/field.dart` + `field_arrow_painter.dart` | `simulations/transformer_model.dart` + `transformer_painter.dart` | 不同实现（封装为可复用组件） | [待确认] |

### Single Source of Truth 应该属于哪里

**[待确认]**——无法在 READ-ONLY 阶段确定。原因：

1. 实现 1 和实现 2 **内容是否完全相同**未做全文 diff
2. 实现 4 是**不同封装**（可复用组件 vs 单文件 app），与实现 1/2 的关系是"同一物理逻辑的两种架构"
3. 4 个实现**全部未挂载 Home**——都不是"当前运行中的实现"
4. 如果未来要接入 magnet_and_compass 或 transformer，**唯一归属取决于哪个 sim 先迁移**

**候选归属**（按可能性排序）：

| 候选 | 路径 | 理由 |
|---|---|---|
| A. `lib/common/visualization/magnetic_field.dart` | 新建 | 磁场计算是跨 sim 通用能力（magnet + electromagnet + transformer 都用） → 上抽到 common |
| B. `lib/electromagnetism/magnet_and_compass/model/magnetic_field.dart` | 新建 | 如果只接入 magnet_and_compass 一个 sim → 放 sim 内 |
| C. [待确认] | — | 需用户决策接入哪些 sim 后才能定 |

---

## 5. 入口冲突

### 当前真正运行入口

[已确认] `lib/main.dart` → `KratosApp` → `HomeScreen`

- `lib/main.dart` 定义 `KratosApp`（`MaterialApp`）
- `lib/screens/home_screen.dart:60-163` 定义 `_disciplines`（9 个 sim 卡）
- 9 个 sim 全部通过 `_build*` builder 挂载

### 其他 main.dart

| 文件 | 内容 | 入口类型 | 与 KratosApp 冲突 | 建议动作 |
|---|---|---|---|---|
| `phet/magnet_and_compass/lib/main.dart` | `main()` + `MagnetApp` + `MaterialApp` + `EntryPage` | **独立 app 入口** | 🔴 是（两个 `main()` + 两个 `MaterialApp`） | **BLOCKED** |
| `phet/quantum_coin_toss/lib/quantum_coin_toss.dart` | 定义 `CoinModel` 等 · **无 `main()`** | 库文件 | ❌ 不冲突（无 main） | **BLOCKED**（未挂载但无入口冲突） |
| `phet/quantum_meansuremant/lib/coins/coins_screen.dart` | `CoinsScreen` StatefulWidget · **无 `main()`** | 库文件 | ❌ 不冲突 | **BLOCKED** |

### route / Navigator

[已确认] `lib/screens/home_screen.dart` 使用 `Navigator.push` 推各 sim screen。无 `route` 命名路由表——全部是直接 `MaterialPageRoute(builder: ...)` 推屏。

### 决策

| 文件 | 动作 | 理由 |
|---|---|---|
| `lib/main.dart` | **KEEP** | 唯一运行入口 |
| `phet/magnet_and_compass/lib/main.dart` | **BLOCKED** | 自带 main() 冲突 · 需用户决策是接入 Home（删 main）还是 ARCHIVE |
| `phet/quantum_coin_toss/lib/*` | **BLOCKED** | 无 main 但未挂载 · 需用户决策 |
| `phet/quantum_meansuremant/lib/*` | **BLOCKED** | 无 main 但未挂载 · 需用户决策 |

---

## 6. 缺失依赖：electromagnet

### 确认

| 项 | 结果 |
|---|---|
| 缺什么 | `electromagnet_model.dart`（定义 `ElectromagnetState` / `ElectronModel` / `CurrentSourceType`） |
| 是否在其他位置存在同名/类似 Model | [已确认] 不存在（全局 search_file `electromagnet_model*` 结果 0 · `lib/` grep `electromagnet_model` 结果 0） |
| 是否可以确认属于同一项目 | [推测] 是——`electromagnet_page.dart` 和 `electromagnet_painter.dart` 都 import 它，类名一致 |
| 是否只是未完成原型 | [推测] 是——`initState()` 已设计好 `ElectromagnetState(...)` 和 `ElectronModel(...)` 的构造接口，但 model 文件未创建 |

### 禁止

**禁止为了迁移而自行生成缺失 Model**——用户明确要求。

### 决策

- **BLOCKED**——需用户决策：
  - 补齐 model（用户自行或委派开发）→ MIGRATE
  - 废弃 → ARCHIVE 或 DELETE（需确认与 magnet_and_compass 功能重叠度）

---

## 7. phet/widgets 决策

（已在 §3.4 详述）

### 总结

| 维度 | 结论 |
|---|---|
| 被谁引用 | [已确认] 仅 `simulations/transformer_{painter,model}.dart`（2 文件 · 均未挂载 Home） |
| 是否只有 transformer 使用 | [已确认] 是 |
| transformer 是否本身孤立 | [已确认] 是（未挂载 · 无测试 · 无 requirements） |
| 是否存在通用能力 | [推测] 磁场可视化 4 组件（compass / field / field_arrow_painter / electromagnet）有通用价值 |
| 是否存在重复实现 | [已确认] 与 `lib/common/` 平行（slider / combo_box / panel / clock / chart 等均有等价物） |

### 建议

- **ARCHIVE**——从运行工程退出
- **禁止直接移动到 `lib/common/`**——需逐个评估：
  - 有 lib/common 等价物的 → 不移动（用 lib/common 版）
  - 无等价物且有通用价值的 → [待确认] 是否上抽到 `lib/common/visualization/`
- **禁止直接删除**——需用户确认

---

## 8. Assets：color_vision 重复目录

### 检查

| 目录 | 文件数 | 文件列表 |
|---|---|---|
| `assets/scenarios/color_vision/`（下划线） | 2 | `manifest.json` + `rgb-default.json` |
| `assets/scenarios/color-vision/`（连字符） | 11 | `manifest.json` + 10 个 scenario JSON |

### 谁在引用

[已确认] `lib/color_vision/config/color_vision_scenario_manager.dart`：

```dart
String get manifestPath => 'assets/scenarios/color-vision/manifest.json';
// ...
'assets/scenarios/color-vision/$entryKey.json';
```

**运行时加载的是连字符版 `color-vision/`**（11 个文件）。

### 内容是否相同

[推测] `color_vision/rgb-default.json`（下划线版）与 `color-vision/rgb-default.json`（连字符版）**可能**内容相同（同名文件），但未做 diff 确认。

### 哪一个是真正运行资源

[已确认] 连字符版 `color-vision/`（11 文件）是运行资源。

### 哪一个是旧副本

[推测] 下划线版 `color_vision/`（2 文件）是旧副本——文件数少 + 运行时不加载。

### 决策

- **MERGE**——删除 `assets/scenarios/color_vision/`（下划线版 · 2 文件）
- **禁止直接删除**——需先做 diff 确认 `rgb-default.json` 内容相同
- **风险**：低（运行时不加载）

### pubspec.yaml 声明

[已确认] `pubspec.yaml:72` 声明 `assets/scenarios/color-vision/`（连字符）。下划线版未被声明。

---

## 9. 目标目录

> 仅在确认 simulation 身份后建议 · 本阶段**不修改任何文件**

### 9.1 正规 sim（KEEP · 9 个）

| sim | 当前目录 | 建议目录 | 结构是否需调整 |
|---|---|---|---|
| forces | `lib/forces/` | `lib/forces/`（不变） | ❌ 维持复数 `models/` |
| circuit | `lib/circuit/` | `lib/circuit/`（不变） | ❌ 维持复数 `models/` |
| optics | `lib/optics/` | `lib/optics/`（不变） | ❌ 维持 `solvers/` + `physics/` |
| color_vision | `lib/color_vision/` | `lib/color_vision/`（不变） | ❌ 维持单数 `model/` |
| wave_interference | `lib/wave_interference/` | `lib/wave_interference/`（不变） | ❌ |
| sound | `lib/sound/` | `lib/sound/`（不变） | ❌ |
| radio_waves | `lib/radio_waves/` | `lib/radio_waves/`（不变） | ❌ |
| molarity | `lib/chemistry/molarity/` | `lib/chemistry/molarity/`（不变） | ❌ 维持 `view/` 嵌套 |
| build_a_nucleus | `lib/chemistry/build_a_nucleus/` | `lib/chemistry/build_a_nucleus/`（不变） | ❌ 参考规范 |

**不建议大规模重构存量 sim 目录结构**——改动面大、收益小、风险高。新 sim 复刻按 build_a_nucleus 风格落地。

### 9.2 孤立 PhET 项目（BLOCKED · 需用户决策）

如果用户决定接入 Home：

| sim | 建议目标目录 | 依据 |
|---|---|---|
| magnet_and_compass | `lib/electromagnetism/magnet_and_compass/` | 物理学科 · 电磁学子领域 |
| electromagnet | `lib/electromagnetism/electromagnet/` | 同上 |
| transformer | `lib/electromagnetism/transformer/` | 同上 |
| quantum_coin_toss | `lib/quantum/coin_toss/`（或合并到 measurement） | [待确认] 与 meansuremant 关系 |
| quantum_meansuremant | `lib/quantum/measurement/`（修正拼写） | [待确认] 与 coin_toss 关系 |

如果用户决定废弃：

| sim | 建议动作 |
|---|---|
| 全部 5 个 | ARCHIVE（保留但从运行工程退出） |

### 9.3 phet/widgets（ARCHIVE）

- 从运行工程退出
- 磁场可视化 4 组件 [待确认] 是否上抽到 `lib/common/visualization/`

### 9.4 docs 占位文档（DELETE · 有明确证据）

| 文件 | 证据 | 建议动作 |
|---|---|---|
| `docs/architecture.md` | `/wf init` 自动生成 · 写 "Project is a Unknown project" · 与实际 Flutter PhET 复刻脱节 | **DELETE** |
| `docs/code-scaffolds.md` | `/wf init` 自动生成 · 通用 Flutter 模板 · 与 `docs/knowledge/kratos/` 重复 | **DELETE** |
| `docs/init-checklist.md` | `/wf init` 自动生成 · 通用 onboarding 模板 | **DELETE** |

### 9.5 路径漂移文档（KEEP · 需修正内容）

| 文件 | 问题 | 建议动作 |
|---|---|---|
| `docs/drag-logic.md` | 顶部写 `lib/screens/circuit_screen.dart` · 实际在 `lib/circuit/screens/circuit_screen.dart` | **KEEP** · 修正路径 |
| `docs/project-requirements-overview.md` | 第 20 行写"8 个 sim" · 实际 9 个 | **KEEP** · 更新数字 |

### 9.6 scenario_selection_screen（[待确认] 死代码）

- `lib/screens/scenario_selection_screen.dart`
- [已确认] `lib/` 内 grep `import.*scenario_selection_screen` 结果为 0——无外部 import
- `docs/reviews/interaction-issues-2026-08.md` C1 标注"死代码（无活跃引用）"
- **但**文件本身定义了 `ScenarioSelectionScreen` 类——[推测] 可能曾通过命名路由或 `Navigator.push(MaterialPageRoute(builder: (_) => ScenarioSelectionScreen()))` 调用
- **[待确认]**——需用户二次确认是否可删

---

## 10. 迁移优先级

### P0：影响当前工程正确运行

| 项 | 动作 | 风险 | 依据 |
|---|---|---|---|
| `phet/magnet_and_compass/lib/main.dart` 自带 `main()` | BLOCKED · 需用户决策 | 🔴 高 | 自带 `main()` + `MaterialApp` 与 `KratosApp` 冲突 |
| `simulations/electromagnet_{page,painter}.dart` 缺失 model | BLOCKED · 需用户决策 | 🔴 高 | import `electromagnet_model.dart` 不存在 · 无法编译 |

> **注意**：虽然以上两项有 P0 风险，但它们都未挂载 Home——**不影响当前 9 个正规 sim 的运行**。P0 标记是因为如果有人尝试 `flutter run` 全工程（含 phet/ 和 simulations/），会触发编译错误。

### P1：明显重复实现 / 路径混乱

| 项 | 动作 | 风险 |
|---|---|---|
| magnet_and_compass 三重存在（#10/#13/#14） | BLOCKED · 需用户决策选权威源 | 中 |
| 磁场计算 4 处重复 | BLOCKED · 需用户决策唯一归属 | 中 |
| phet/widgets 与 lib/common 平行实现 | ARCHIVE · 从运行工程退出 | 中 |
| phet/quantum_coin_toss vs meansuremant 疑似同源 | BLOCKED · 需用户决策是否合并 | 中 |
| `simulations/` 目录扁平堆放 6 个散落文件 | BLOCKED · 需先确定每个文件的归属 | 中 |

### P2：目录规范化

| 项 | 动作 | 风险 |
|---|---|---|
| 9 个正规 sim 目录风格分裂 | KEEP · 不强行统一 | 低 |
| `phet/quantum_meansuremant` 拼写错误 | BLOCKED · 若保留则改名 · 若废弃则不处理 | 低 |

### P3：文档 / assets 清理

| 项 | 动作 | 风险 |
|---|---|---|
| `docs/architecture.md` / `code-scaffolds.md` / `init-checklist.md` | DELETE · 有明确证据 | 低 |
| `docs/drag-logic.md` 路径漂移 | KEEP · 修正内容 | 低 |
| `docs/project-requirements-overview.md` "8 个" → "9 个" | KEEP · 更新 | 低 |
| `assets/scenarios/color_vision/`（下划线 · 2 文件） | MERGE → 删除（先 diff 确认） | 低 |
| `lib/screens/scenario_selection_screen.dart` | [待确认] 死代码 · 需用户确认 | 低 |

---

## 11. 风险评估

| 迁移动作 | 风险等级 | 原因 |
|---|---|---|
| KEEP 9 个正规 sim | 🟢 低 | 不改动 · 无风险 |
| magnet_and_compass 选权威源 | 🔴 高 | 自带 main() 冲突 · 3 处重复 · 未确认内容 diff |
| electromagnet 补齐或废弃 | 🔴 高 | 缺失 model · 无法编译 · 与 magnet_and_compass 重叠度未确认 |
| transformer 接入或废弃 | 🟡 中 | 完整但依赖 phet/widgets · phet/widgets 本身也待决策 |
| phet/widgets ARCHIVE | 🟡 中 | 71 文件大规模退出 · 磁场可视化能力可能丢失 |
| quantum 合并或废弃 | 🟡 中 | 两套实现关系未确认 · 贸然合并可能丢功能 |
| color_vision assets MERGE | 🟢 低 | 运行时不加载下划线版 · diff 确认后删除 |
| docs 占位文档 DELETE | 🟢 低 | 有明确证据 · /wf init 残留 |
| docs 路径漂移修正 | 🟢 低 | 仅改文档内容 |
| scenario_selection_screen DELETE | 🟡 中 | [待确认] 死代码 · 需二次确认 |
| 存量 sim 目录统一 | 🟡 中 | 改动面大 · 收益小 |

---

## 12. 禁止事项

本阶段**绝对禁止**以下操作：

- ❌ move（移动任何文件）
- ❌ rename（重命名任何文件或目录）
- ❌ delete（删除任何文件——包括占位文档和重复 assets）
- ❌ refactor（重构任何代码）
- ❌ import 修改（修改任何 import 语句）
- ❌ Home 修改（修改 `home_screen.dart`）
- ❌ pubspec 修改（修改 `pubspec.yaml`）
- ❌ common 修改（修改 `lib/common/` 任何文件）
- ❌ 自动创建缺失 Model（为 electromagnet 生成 `electromagnet_model.dart`）
- ❌ 自动合并重复实现（合并磁场计算 4 处实现）

---

## 13. 诚实声明

- 所有 `[已确认]` 标记的结论均有工具调用实证（list_dir / read_file / search_content / search_file）
- 所有 `[推测]` 标记的结论已标注推测依据
- 所有 `[待确认]` 标记的结论已列出待回答的问题
- **未发现引用 ≠ 确定废弃**——`phet/widgets/` 标记为"疑似废弃"而非"确定废弃"

---

## 14. 待用户决策

> 只列真正需要人工拍板的事项

### 决策 1：magnet_and_compass 两个来源选哪一个

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 选 `phet/magnet_and_compass/lib/main.dart`（来源 A） | 保留 PhET 原始完整 app · 删来源 B | 更完整 · 但自带 main() 需删除 |
| B. 选 `simulations/magnet_and_compass.dart`（来源 B） | 保留迁移中间产物 · 删来源 A | 更接近工程规范 · 但未确认内容是否完整 |
| C. 两者都保留 | 暂不决策 | 维持现状 |
| D. 两者都废弃 | ARCHIVE 全部 | 清理但可能丢失有用代码 |

**需先做全文 diff 确认内容是否相同。**

---

### 决策 2：electromagnet 是否废弃

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 补齐 model 并接入 Home | 生成 `electromagnet_model.dart` → MIGRATE | 完整 sim · 但需开发投入 |
| B. 废弃 | ARCHIVE `simulations/electromagnet_*.dart` | 清理 · 但需确认与 magnet_and_compass 功能重叠度 |
| C. 暂不决策 | 维持 BLOCKED | 不影响当前运行 |

**禁止 AI 自动生成缺失 model。**

---

### 决策 3：transformer 是否接入 Home

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 接入 Home | MIGRATE 到 `lib/electromagnetism/transformer/` + 重写 phet/widgets 依赖 | 完整 sim · 但需重写依赖 |
| B. 废弃 | ARCHIVE | 清理 · 但代码完整可惜 |
| C. 暂不决策 | 维持 BLOCKED | 不影响当前运行 |

---

### 决策 4：phet/widgets 是否归档

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. ARCHIVE（从运行工程退出） | 保留文件但不参与编译 | 清理 · 磁场可视化能力暂存 |
| B. 上抽磁场可视化 4 组件到 `lib/common/visualization/` 后 ARCHIVE 其余 | 保留通用能力 | 需逐个评估 · 有改动风险 |
| C. 全部 DELETE | 删除 71 文件 | 最激进 · 可能丢失有价值的组件 |
| D. 暂不决策 | 维持现状 | 不影响当前运行（因未被 Home 引用） |

---

### 决策 5：重复磁场逻辑唯一归属

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 上抽到 `lib/common/visualization/magnetic_field.dart` | 跨 sim 通用 | 需先确认接入哪些 sim |
| B. 放到 `lib/electromagnetism/magnet_and_compass/model/` | sim 专属 | 如果只接入 magnet_and_compass |
| C. [待确认] | 需先完成决策 1-3 后再定 | — |

---

### 决策 6：是否统一旧 sim 的目录规范

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 不统一 | KEEP 9 个正规 sim 当前目录 | 改动面大 · 收益小 |
| B. 逐步统一到 build_a_nucleus 风格 | 改 `models/` → `model/` · 加 `controller/` 等 | 长期债务 · 但短期成本高 |
| C. 新 sim 强制 build_a_nucleus 风格 · 存量不动 | 折中 | 推荐 |

---

### 决策 7：quantum 系列是否合并或废弃

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 合并为一套 | 确认同源后合并 | 需对照 PhET Java 蓝本 |
| B. 废弃 | ARCHIVE 全部 | 清理 |
| C. 暂不决策 | 维持 BLOCKED | 不影响当前运行 |

---

### 决策 8：scenario_selection_screen 是否删除

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 删除 | DELETE | [待确认] 是否真的无引用 |
| B. 保留 | KEEP | 维持死代码 |
| C. 二次确认后再定 | grep 更广范围 | 稳妥 |

---

### 决策 9：KRATOS_STUDENT 整体迁移是否启动

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 启动 | 按技术要求文档迁移到 `kratos-student/lib/src/simlab` | 大项目 · 本盘点是其前置基线 |
| B. 不启动 | 维持独立 App | 现状 |
| C. 暂不决策 | 先完成本迁移计划 | — |

---

### 决策 10：docs 占位文档是否删除

| 选项 | 内容 | 权衡 |
|---|---|---|
| A. 删除 3 份（architecture / code-scaffolds / init-checklist） | DELETE | 有明确证据 · /wf init 残留 |
| B. 重写 architecture.md 为真实架构 | KEEP + 重写 | 保留文档位 |
| C. 暂不决策 | 维持现状 | 误导风险 |

---

## 完成声明

- 本计划基于 READ-ONLY 扫描 · **未修改任何文件**
- 所有 `[已确认]` 项均有工具调用实证
- 所有 `[推测]` 项已标注推测依据
- 所有 `[待确认]` 项已列入待用户决策
- 10 项待用户决策均需人工拍板
- 完成后停止
