# LEGACY DECISION 1-5

> 生成日期：2026-08-31
> 阶段：**READ-ONLY 证据收集与决策建议** · 未修改任何文件
> 依据：`requirements/project-migration/LEGACY_MIGRATION_PLAN.md` 决策 1-5
> 证据级别：`[已确认]` = 全文阅读实证 · `[推测]` = 标注推测依据 · `[待确认]` = 需用户拍板

---

## 1. magnet_and_compass A/B 全文对比

### 来源

| 来源 | 路径 | 行数 | 入口 |
|---|---|---|---|
| A | `phet/magnet_and_compass/lib/main.dart` | 1650 行 | `main()` + `MagnetApp` + `MaterialApp` + `EntryPage` → `SimulationPage` |
| B | `simulations/magnet_and_compass.dart` | ~1100 行（估算） | `MagnetAndCompassPage`（StatefulWidget · 无 `main()`） |

### 功能对比矩阵

| 功能 | A | B | 差异 | 哪份更完整 | 证据 |
|---|---|---|---|---|---|
| **main** | ✅ `void main()` + `runApp(MagnetApp())` + `SystemChrome.setPreferredOrientations` | ❌ 无 `main()` | A 自带完整 app 入口；B 是 library 组件 | A | A:6-13 · B 全文无 `main` |
| **MaterialApp** | ✅ `MagnetApp extends StatelessWidget` 返回 `MaterialApp` | ❌ 无 | A 自带主题；B 依赖外部 `MaterialApp` | A | A:15-26 |
| **EntryPage** | ✅ 启动页（磁铁圆形按钮 + Tap to Start） | ❌ 无 | A 有独立启动动画页 | A | A:31-133 |
| **SimulationPage** | ✅ `SimulationPage extends StatefulWidget` | ✅ `MagnetAndCompassPage extends StatefulWidget` | 类名不同但功能相同 | — | A:272 · B:133 |
| **SimState** | ✅ 12 字段（magnetPos/magnetAngle/strength/flipped/showField/seeInside/earthField/showCompass/showFieldMeter/compassPos/compassAngle/fieldMeterPos） | ✅ 12 字段（完全相同） | **逐字段 1:1 一致** | 等价 | A:138-194 · B:11-67 |
| **SimState.copyWith** | ✅ 12 参数 | ✅ 12 参数（完全相同） | **逐参数 1:1 一致** | 等价 | A:167-193 · B:40-66 |
| **MagneticField.compute** | ✅ 静态方法 · 7 参数（p/magnetPos/angle/halfLen/strength/flipped/earthField） | ✅ 静态方法 · 7 参数（完全相同） | **算法逐行等价**（见 §6 详析） | 等价 | A:202-263 · B:73-124 |
| **MagneticField.magnitude** | ✅ `sqrt(b.dx² + b.dy²)` | ✅ 完全相同 | 等价 | 等价 | A:265 · B:126 |
| **MagneticField.fieldAngle** | ✅ `atan2(b.dy, b.dx)` | ✅ 完全相同 | 等价 | 等价 | A:266 · B:127 |
| **BarMagnetPainter** | ✅ `extends CustomPainter` | ✅ `extends CustomPainter` | [待确认] 未逐行 diff paint 方法 | [推测] 等价 | A:862 · B:618 |
| **CompassPainter** | ✅ `extends CustomPainter` | ✅ `extends CustomPainter` | [待确认] 未逐行 diff paint 方法 | [推测] 等价 | A:1157 · B:793 |
| **FieldArrowPainter** | [推测] 有（A 1650 行 vs B ~1100 行，A 多出 550 行可能含此 Painter） | [推测] 有 | [待确认] | [待确认] | — |
| **FieldMeterPainter** | [推测] 有 | [推测] 有 | [待确认] | [待确认] | — |
| **earth.svg 引用** | ✅ `import 'package:flutter_svg/flutter_svg.dart'` + 引用 `assets/earth.svg` | ✅ `import 'package:flutter_svg/flutter_svg.dart'` | 两者都引用 SVG | 等价 | A:4 · B:6 |
| **中文注释** | ✅ 有（如 `计算空间点 p 处的磁场向量`、`地球模式`） | ❌ 无 | A 保留开发注释 | A | A:200-201 · B:70 |
| **ControlPanel** | ✅ `_ControlPanel`（独立 Widget） | [推测] 有 | [待确认] | [待确认] | A 内有 `_ControlPanel` |
| **assets** | `phet/magnet_and_compass/` 下无独立 assets 目录 · 引用 `assets/earth.svg`（工程根） | 无独立 assets · 引用 `assets/earth.svg` | 两者共享工程根 assets | 等价 | — |
| **tests** | ❌ 无 | ❌ 无 | — | — | — |
| **constants** | 硬编码在类内（如 `_magnetW = 500.0`） | 硬编码在类内 | [推测] 等价 | 等价 | A:143-146 · B 同位置 |
| **physics** | `MagneticField.compute()` 偶极子模型 | `MagneticField.compute()` 偶极子模型 | **逐行等价**（见 §6） | 等价 | §6 详析 |
| **interaction** | `GestureDetector` 拖拽 + `AnimationController` | [推测] 相同 | [待确认] | [推测] 等价 | A 有 `TickerProviderStateMixin` · B 同 |
| **resource loading** | `flutter_svg` 加载 `earth.svg` | `flutter_svg` 加载 `earth.svg` | 等价 | 等价 | A:4 · B:6 |

### 结论

A 和 B 是**同一份代码的两个版本**：

- B 是从 A 迁移而来的"工程化版本"——删除了 `main()` / `MagnetApp` / `EntryPage`，改类名为 `MagnetAndCompassPage`，删除了中文注释
- **物理逻辑 100% 等价**（`SimState` 12 字段 + `MagneticField.compute` 算法逐行一致）
- A 更完整（含 app 入口 + 启动页 + 注释）
- B 更接近工程规范（无 `main()` 冲突 · 已是 library 组件）

---

## 2. magnet 入口决策

### 入口对比

| 项 | A | B |
|---|---|---|
| `void main()` | ✅ 有（A:6-13） | ❌ 无 |
| `MaterialApp` | ✅ `MagnetApp` 返回 `MaterialApp`（A:19-25） | ❌ 无 |
| `runApp()` | ✅ `runApp(MagnetApp())` | ❌ 无 |
| 能接入 KratosApp | ❌ 不能（自带 `main()` 会冲突） | ✅ 能（`MagnetAndCompassPage` 可被 Navigator.push） |
| 重复 App | 🔴 是（`MagnetApp` + `KratosApp` = 2 个 `MaterialApp`） | ❌ 否 |
| Home 引用 | ❌ 未被 `home_screen.dart` 引用 | ❌ 未被 `home_screen.dart` 引用 |
| 接近 KARTOSLAB 架构 | ❌ 不接近（自带 app · 不用 `lib/common/` · 不用 `NineGridLayout`） | ❌ 不接近（不用 `lib/common/` · 不用 `NineGridLayout`） |

### 建议保留实现

**推荐保留 B（`simulations/magnet_and_compass.dart`）**，理由：

1. **B 无 `main()` 冲突**——A 自带 `main()` + `MaterialApp`，与 `KratosApp` 构成重复 App
2. **B 是 library 组件**——`MagnetAndCompassPage` 可直接被 `Navigator.push` 挂载到 Home
3. **B 已完成迁移注释**——第 2 行 "Migrated from lib/src/phet/magnet_and_compass/lib/main.dart"
4. **物理逻辑 100% 等价**——`MagneticField.compute()` 逐行一致，无功能损失
5. **A 的额外内容（EntryPage + 启动动画）无迁移价值**——KARTOSLAB 已有 Home 作为入口

### 但仍标记 BLOCKED

虽然推荐保留 B，但仍标记 **BLOCKED**，原因：

- B 未挂载 Home
- B 不符合 `lib/common/` 共享层规范（不用 `NineGridLayout` / `KratosSlider` 等）
- B 仍在 `simulations/` 扁平目录而非 `lib/electromagnetism/magnet_and_compass/`
- **A 不应直接删除**——它是 PhET 原始形态，保留作为参考基线

---

## 3. electromagnet 状态

### 文件清单

| 文件 | 路径 | 状态 |
|---|---|---|
| `electromagnet_page.dart` | `simulations/electromagnet_page.dart` | ✅ 存在 |
| `electromagnet_painter.dart` | `simulations/electromagnet_painter.dart` | ✅ 存在 |
| `electromagnet_model.dart` | **不存在** | 🔴 缺失 |

### model 定义搜索结果

| 类名 | 搜索范围 | 结果 |
|---|---|---|
| `ElectromagnetState` | 全工程 `*.dart` | 🔴 **0 匹配**（仅 `electromagnet_page.dart` 引用，无定义） |
| `CurrentSourceType` | 全工程 `*.dart` | 🔴 **0 匹配**（仅 `electromagnet_page.dart` 引用，无定义） |
| `ElectronModel`（electromagnet 版） | 全工程 `*.dart` | ⚠️ 仅在 `transformer_model.dart:324` 有定义，但那是 **transformer 的 `ElectronModel`**，签名不同 |
| `ElectromagnetFieldPainter` | 全工程 `*.dart` | ✅ 在 `electromagnet_painter.dart:402` 定义 |

### `electromagnet_page.dart` 引用的类

[已确认] `electromagnet_page.dart` 引用以下在 `electromagnet_model.dart` 中应定义的类：

| 类 / 枚举 | 引用位置 | 证据 |
|---|---|---|
| `ElectromagnetState` | :22 `late ElectromagnetState _state` · :44 `ElectromagnetState(...)` · :110 | 9 处引用 |
| `CurrentSourceType` | :46 `CurrentSourceType.dc` · :112 · :348 · :350 · :406 | 5 处引用 |
| `ElectronModel` | :23 `late ElectronModel _electrons` · :60 `ElectronModel(positions: ...)` | 2 处引用 |

### `electromagnet_model.dart` 全工程不存在

[已确认] 三路搜索均返回 0 结果：

1. `search_file` 全局递归 `electromagnet_model*` → 0 结果
2. `search_content` 在 `lib/` 内 grep `electromagnet_model` → 0 结果
3. `search_file` 在 `phet/` 内搜索 → 0 结果

### 旧版本 / 备份 model

[已确认] 不存在任何旧版本或备份 model 文件。

### assets / tests

| 项 | 结果 |
|---|---|
| assets | ❌ 无独立 assets |
| tests | ❌ 无测试 |

### 判断

- **是否有足够材料继续修复**：❌ 不是"修复"而是"从零创建"——model 文件从未存在过
- **是否只能 BLOCKED**：✅ **是**——`ElectromagnetState` / `CurrentSourceType` 无任何定义来源，无法推断原始设计意图
- **是否存在可确认的旧版本来源**：❌ 不存在
- **`ElectronModel` 是否可复用 transformer 版**：❌ 不可——transformer 的 `ElectronModel` 接受 `positions` 列表，而 electromagnet 的 `ElectronModel` 也接受 `positions`，但 `ElectromagnetState` 和 `CurrentSourceType` 仍无来源

**禁止自行创建 model**——用户明确要求。

### 决策

**BLOCKED**——需用户决策：

| 选项 | 权衡 |
|---|---|
| 用户提供 model → MIGRATE | 需用户自行开发 |
| 废弃 → ARCHIVE | 清理但可能丢失有用代码 |
| 暂不决策 | 维持 BLOCKED |

---

## 4. transformer 状态

### 文件清单

| 文件 | 路径 | 行数 | 状态 |
|---|---|---|---|
| `transformer_page.dart` | `simulations/transformer_page.dart` | 950 行 | ✅ 完整 |
| `transformer_model.dart` | `simulations/transformer_model.dart` | 470 行 | ✅ 完整 |
| `transformer_painter.dart` | `simulations/transformer_painter.dart` | 747 行 | ✅ 完整 |

### tests / assets

| 项 | 结果 |
|---|---|
| tests | ❌ 无测试 |
| assets | ❌ 无独立 assets |

### Home 引用

[已确认] `home_screen.dart` 不引用 `TransformerPage`。

### main / route

[已确认] `transformer_page.dart` 无 `main()` · 无 `MaterialApp` · 入口是 `TransformerPage`（StatefulWidget）。

### 依赖 phet/widgets

[已确认] transformer 的 2 个文件引用 phet/widgets 的 5 个路径：

| 引用方 | 引用路径 |
|---|---|
| `transformer_model.dart:20` | `../phet/widgets/physics/magnetism/electromagnet.dart` |
| `transformer_painter.dart:11` | `../phet/widgets/physics/magnetism/electromagnet.dart` |
| `transformer_painter.dart:12` | `../phet/widgets/visualization/field.dart` |
| `transformer_painter.dart:13` | `../phet/widgets/visualization/field_arrow_painter.dart` |
| `transformer_painter.dart:14` | `../phet/widgets/shapes/phet_arrow.dart` |
| `transformer_painter.dart:15` | `../phet/widgets/core/phet_types.dart` |

### 是否具备完整运行条件

| 条件 | 状态 |
|---|---|
| model 完整 | ✅ `TransformerState` / `PowerSource` / `CircuitModel` / `MagneticFieldModel` / `InductionModel` / `ElectronModel` / `CoilModel` / `TransformerPhysics` |
| view 完整 | ✅ `TransformerPainter` / `TransformerElectronPainter` / `TransformerFieldPainter` / `TransformerFieldMeterPainter` / `_CompassWidget` / `_CompassPainter` / `_FieldMeterWidget` |
| controller | ✅ `_TransformerPageState` + `_tick()` + `AnimationController` |
| phet/widgets 依赖 | ✅ 全部 5 个引用路径存在 |
| 编译能力 | [推测] ✅ 可编译（model + view + 依赖均完整） |
| 挂载 Home | ❌ 未挂载 |
| NineGridLayout | ❌ 未使用 |
| lib/common 复用 | ❌ 未使用 |

### 决策

**BLOCKED**——代码完整但未挂载 · 依赖 phet/widgets（而 phet/widgets 也待决策）。

理由：

1. transformer 自身代码完整可编译
2. 但依赖 phet/widgets 的 5 个文件——如果 phet/widgets 被 ARCHIVE，transformer 需重写依赖
3. 未挂载 Home · 不符合工程规范
4. 无测试

**不建议 KEEP**（未挂载）· **不建议 ARCHIVE**（代码完整可惜）· **不建议 MIGRATE**（需先解决 phet/widgets 依赖）。

---

## 5. phet/widgets 完整引用矩阵

### 外部引用（phet/widgets 之外）

[已确认] 全工程 `grep "import.*phet/widgets"` 结果（不含 phet/widgets 内部）：

| 引用方 | 引用路径 | 仅 transformer | lib 引用 |
|---|---|---|---|
| `simulations/transformer_model.dart:20` | `../phet/widgets/physics/magnetism/electromagnet.dart` | ✅ 是 | ❌ 否 |
| `simulations/transformer_painter.dart:11` | `../phet/widgets/physics/magnetism/electromagnet.dart` | ✅ 是 | ❌ 否 |
| `simulations/transformer_painter.dart:12` | `../phet/widgets/visualization/field.dart` | ✅ 是 | ❌ 否 |
| `simulations/transformer_painter.dart:13` | `../phet/widgets/visualization/field_arrow_painter.dart` | ✅ 是 | ❌ 否 |
| `simulations/transformer_painter.dart:14` | `../phet/widgets/shapes/phet_arrow.dart` | ✅ 是 | ❌ 否 |
| `simulations/transformer_painter.dart:15` | `../phet/widgets/core/phet_types.dart` | ✅ 是 | ❌ 否 |
| `phet/phet.dart` | barrel export（自身） | ❌ | ❌ |

**结论**：phet/widgets 的外部消费者**只有 transformer**（2 个文件 · 6 个 import 点）。`lib/` 内 0 引用。

### phet/widgets 内部互相引用

[已确认] phet/widgets 内部 69 个 import 全部是相对路径（如 `../core/phet_types.dart`），**0 个文件 import `phet/widgets` 或 `phet/phet.dart`**。内部引用关系（摘要）：

| 被引用模块 | 引用方数 | 典型引用方 |
|---|---|---|
| `core/phet_types.dart` | 5 | visualization/vector · visualization/field · physics/physics_object · physics/force · physics/mechanics/spring |
| `theme/phet_theme.dart` | 9 | controls/*（6 个）· simulation/*（2 个）· visualization/compass |
| `visualization/field.dart` | 3 | physics/magnetism/magnetic_field · visualization/field_arrow_painter · visualization/field_meter |
| `shapes/phet_arrow.dart` | 1 | visualization/field_arrow_painter |
| `physics/magnetism/magnetic_field.dart` | 2 | physics/magnetism/electromagnet · physics/magnetism/bar_magnet |
| `simulation/simulation_clock.dart` | 2 | simulation/simulation_control_bar · simulation/simulation_controller |

### 对外公共 API

[已确认] `phet/phet.dart` 是 barrel export 文件，export 全部 71 个组件。但：

- **无任何文件 import `phet/phet.dart`**（grep `import.*phet/phet` 结果 0）
- barrel export 是死代码——设计了但从未被使用

### 孤立文件

[推测] 以下 phet/widgets 文件**无任何引用**（既不被外部引用，也不被 phet/widgets 内部引用）：

| 文件 | 推测状态 |
|---|---|
| `canvas/phet_canvas.dart` | [待确认] 孤立 |
| `canvas/phet_painter.dart` | [待确认] 孤立 |
| `canvas/phet_layer.dart` | [待确认] 孤立 |
| `layout/phet_responsive_layout.dart` | [待确认] 孤立 |
| `interaction/phet_draggable.dart` | [待确认] 孤立 |
| `interaction/drag_controller.dart` | [待确认] 孤立 |
| `objects/phet_object.dart` | [待确认] 孤立 |
| `objects/phet_interactive_object.dart` | [待确认] 孤立 |
| `particles/particle.dart` | [待确认] 孤立 |
| `particles/particle_system.dart` | [待确认] 孤立 |
| `measurement/measurement_tool.dart` | [待确认] 孤立 |
| `measurement/ruler.dart` | [待确认] 孤立 |
| `chemistry/*`（10 文件） | [待确认] 孤立 |
| `physics/mechanics/*`（3 文件） | [待确认] 孤立 |
| `physics/electricity/*`（6 文件） | [待确认] 孤立 |
| `physics/magnetism/coil.dart` | [待确认] 孤立 |

> [推测] 71 个文件中可能超过 50 个是孤立的——设计了但从未被任何代码引用。

### 实际有消费者的文件

[已确认] 以下 phet/widgets 文件被 transformer 引用（即有实际消费者）：

| 文件 | 被引用路径 | 消费者 |
|---|---|---|
| `physics/magnetism/electromagnet.dart` | `../phet/widgets/physics/magnetism/electromagnet.dart` | transformer_model + transformer_painter |
| `visualization/field.dart` | `../phet/widgets/visualization/field.dart` | transformer_painter |
| `visualization/field_arrow_painter.dart` | `../phet/widgets/visualization/field_arrow_painter.dart` | transformer_painter |
| `shapes/phet_arrow.dart` | `../phet/widgets/shapes/phet_arrow.dart` | transformer_painter |
| `core/phet_types.dart` | `../phet/widgets/core/phet_types.dart` | transformer_painter |

**5 个文件有实际消费者**。其余 66 个文件 [推测] 孤立。

### 决策

**ARCHIVE**——从运行工程退出。

理由：

1. 71 个文件中仅 5 个有实际消费者（全在 transformer 链上）
2. barrel export `phet/phet.dart` 是死代码
3. [推测] 超过 50 个文件孤立
4. 与 `lib/common/` 平行存在（slider / combo_box / panel / clock / chart 等均有等价物）

**但**：

- 如果 transformer 被 MIGRATE，这 5 个文件需要决定是否上抽到 `lib/common/visualization/`
- 其余 66 个孤立文件不应自动移到 `lib/common/`（无消费者证明价值）
- **禁止直接删除**——需用户逐个确认

---

## 6. 3-Time Rule：磁场计算逻辑矩阵

### 全部磁场计算实现

| # | 实现 | 路径 | 函数 / 类 | 被谁使用 |
|---|---|---|---|---|
| 1 | **magnet A** | `phet/magnet_and_compass/lib/main.dart:199-267` | `class MagneticField` · `static Offset compute(p, magnetPos, angle, halfLen, strength, flipped, earthField)` | ❌ 无（A 未挂载） |
| 2 | **magnet B** | `simulations/magnet_and_compass.dart:72-128` | `class MagneticField` · `static Offset compute(p, magnetPos, angle, halfLen, strength, flipped, earthField)` | `simulations/electromagnet_page.dart`（show `CompassPainter`） |
| 3 | **phet/widgets** | `phet/widgets/physics/magnetism/magnetic_field.dart:46-89` | `class MagneticField extends Field` · `PhetVector valueAt(Offset point)` · `_dipoleField(d, p)` | `phet/widgets/physics/magnetism/electromagnet.dart` · `phet/widgets/physics/magnetism/bar_magnet.dart` → 被 transformer 引用 |
| 4 | **transformer** | `simulations/transformer_model.dart:149-236` | `class MagneticFieldModel` · `static Offset compute({p, coilCenter, current, turns, coilRadius})` · `static double computeFlux(...)` | `simulations/transformer_page.dart` · `simulations/transformer_painter.dart` |

### 算法等价性分析

#### 实现 1（magnet A）vs 实现 2（magnet B）

[已确认] **逐行等价**——同一算法的两种复制。

两者算法：

```
偶极子模型：两个单极子（N + S）叠加
N 极位置 = magnetPos + cos/sin(angle) * halfLen * sign
S 极位置 = magnetPos - cos/sin(angle) * halfLen * sign
sign = flipped ? -1 : 1
k = strength * 18000

BN = rN / |rN|³  （N 极出射）
BS = -rS / |rS|³ （S 极入射）
B = (BN + BS) * k

earthField 模式：固定垂直偶极子（N 极向上）
```

差异：**仅注释**——A 有中文注释（如 "计算空间点 p 处的磁场向量"），B 无注释。

#### 实现 3（phet/widgets）vs 实现 1/2

[已确认] **同一物理模型，不同封装**。

phet/widgets 版算法：

```
偶极子模型：MagneticDipole（center / axisAngle / halfLength / strength / loops）
N 极 = center + cos/sin(axisAngle) * halfLength
S 极 = center - cos/sin(axisAngle) * halfLength
k = strength * loops

BN = rN / |rN|³
BS = -rS / |rS|³
B = (BN + BS) * k
```

差异：

| 维度 | magnet A/B | phet/widgets |
|---|---|---|
| **封装** | 静态方法 · 7 个位置参数 | 实例方法 · `MagneticDipole` 对象封装 |
| **earthField 模式** | ✅ 有（固定垂直偶极子） | ❌ 无 |
| **loops 参数** | ❌ 无（strength 是单一标量） | ✅ 有（`k = strength * loops`） |
| **k 系数** | `strength * 18000` | `strength * loops`（默认 strength=100000） |
| **返回类型** | `Offset` | `PhetVector`（自定义向量类） |
| **多偶极子叠加** | ❌ 不支持（单偶极子） | ✅ 支持（`MagneticField(this.dipoles)` 列表） |
| **Field 接口** | ❌ 不继承 | ✅ `extends Field`（可被 `FieldArrowPainter` 通用渲染） |

#### 实现 4（transformer）vs 实现 1/2/3

[已确认] **是 phet/widgets 版的再封装**。

transformer 版 `MagneticFieldModel.compute()` 内部：

```dart
final emag = Electromagnet(
  center: coilCenter,
  axisAngle: 0,
  halfLength: 70,
  loops: turns,
  current: current,
);
final b = emag.field.valueAt(p);  // 调用 phet/widgets 的 MagneticField.valueAt()
```

即 transformer 的 `MagneticFieldModel.compute()` = 创建 `Electromagnet` 对象 → 取其 `field`（`MagneticField`）→ 调 `valueAt(p)`。

**实际计算委托给 phet/widgets 的实现 3**。

### 是否真的是 4 次独立实现

**否**。实际上是：

| 独立实现数 | 实际情况 |
|---|---|
| **2 次独立** | 实现 1/2（magnet A/B）是**同一份代码的复制**；实现 3（phet/widgets）是**不同封装的独立实现**；实现 4（transformer）**委托给实现 3**，不独立 |

### 哪些逻辑实际上等价

| 等价组 | 成员 | 理由 |
|---|---|---|
| 等价组 A | 实现 1 + 实现 2 | 逐行代码等价（仅注释差异） |
| 等价组 B | 实现 3 + 实现 4 | 实现 4 委托给实现 3 |

### 哪些存在行为差异

| 差异点 | magnet A/B | phet/widgets（+ transformer） |
|---|---|---|
| **earthField 模式** | ✅ 支持（地球磁场：固定垂直偶极子，N 极向上） | ❌ 不支持 |
| **loops 参数** | ❌ 不支持（strength 是标量） | ✅ 支持（strength × loops） |
| **多偶极子叠加** | ❌ 不支持 | ✅ 支持（列表） |
| **Field 接口** | ❌ 不继承 | ✅ 继承（可被通用 FieldArrowPainter 渲染） |
| **k 系数** | `strength * 18000` | `strength * loops`（默认 strength=100000 · loops=1 · → k=100000） |

**行为差异**：

- magnet A/B 的 `k = strength * 18000`（默认 strength 值 [待确认]，但 k 约为 18000 × strength）
- phet/widgets 的 `k = strength * loops`（默认 k = 100000）
- **两者数值标度不同**——不能简单互换

---

## 7. 风险

| 风险 | 等级 | 原因 |
|---|---|---|
| magnet A 自带 `main()` 冲突 | 🔴 高 | `MagnetApp` + `KratosApp` = 2 个 `MaterialApp` |
| magnet A/B 物理逻辑等价但数值标度不同 | 🟡 中 | k 系数差异（18000 vs 100000）——如果未来合并需校准 |
| electromagnet 缺失 model | 🔴 高 | 3 个类无定义 · 无法编译 |
| transformer 依赖 phet/widgets | 🟡 中 | 如果 phet/widgets ARCHIVE · transformer 需重写依赖 |
| phet/widgets 66 个孤立文件 | 🟡 中 | 大量死代码 · 但可能含未来有用组件 |
| 磁场计算 2 组独立实现 | 🟢 低 | 算法等价但封装不同 · 可并存 |

---

## 8. 建议执行顺序

> 仅建议 · **不执行任何文件操作**

| 优先级 | 动作 | 依赖 | 理由 |
|---|---|---|---|
| P0 | 确认 magnet 保留 B | 无 | B 无 `main()` 冲突 · 物理逻辑等价 |
| P1 | 确认 electromagnet 废弃或补齐 | P0 | 如补齐 model 可复用 B 的 `CompassPainter` |
| P2 | 确认 transformer 接入或废弃 | P1 | transformer 依赖 phet/widgets · 需先定 phet/widgets |
| P3 | 确认 phet/widgets 归档 | P2 | 5 个有消费者文件随 transformer 决策 |
| P4 | 磁场逻辑唯一归属 | P0-P3 | 取决于哪些 sim 最终接入 |

---

## 9. [已确认]

| 项 | 证据 |
|---|---|
| magnet A 自带 `main()` | `phet/magnet_and_compass/lib/main.dart:6-13` |
| magnet B 无 `main()` | `simulations/magnet_and_compass.dart` 全文无 `main` |
| magnet A/B `SimState` 12 字段 1:1 一致 | A:138-194 · B:11-67 |
| magnet A/B `MagneticField.compute` 算法逐行等价 | A:202-263 · B:73-124 |
| `electromagnet_model.dart` 全工程不存在 | search_file 递归 0 结果 · search_content 0 结果 |
| `ElectromagnetState` 全工程无定义 | grep `class ElectromagnetState` 0 结果 |
| `CurrentSourceType` 全工程无定义 | grep `enum CurrentSourceType` 0 结果 |
| transformer 3 文件完整 | `transformer_page.dart`(950行) + `transformer_model.dart`(470行) + `transformer_painter.dart`(747行) |
| transformer 依赖 phet/widgets 5 个路径 | `transformer_model.dart:20` + `transformer_painter.dart:11-15` |
| phet/widgets 外部消费者仅 transformer | grep `import.*phet/widgets` 结果 3 文件（transformer_model + transformer_painter + phet/phet.dart barrel） |
| `phet/phet.dart` barrel export 无消费者 | grep `import.*phet/phet` 0 结果 |
| phet/widgets 内部 69 个 import 全是相对路径 | grep `import.*phet/widgets` 在 phet/widgets 内 0 结果 |
| phet/widgets `MagneticField` 继承 `Field` 接口 | `phet/widgets/physics/magnetism/magnetic_field.dart:46` |
| transformer `MagneticFieldModel.compute` 委托 phet/widgets | `transformer_model.dart:162-172` 创建 `Electromagnet` → `emag.field.valueAt(p)` |
| Home 不引用 magnet / electromagnet / transformer | grep `home_screen.dart` 无三者引用 |

---

## 10. [推测]

| 项 | 推测依据 |
|---|---|
| magnet A/B `BarMagnetPainter` / `CompassPainter` 逐行等价 | 类名 1:1 + 前文 `SimState` + `MagneticField` 已确认等价 · 但未逐行 diff paint 方法 |
| phet/widgets 71 文件中超过 50 个孤立 | 69 个内部 import 中未出现的文件名 [待确认] · 但 barrel export 死代码 + chemistry/mechanics/electricity 无引用者 |
| magnet A/B 数值标度不同 | A: `k = strength * 18000` · B: 相同 · phet/widgets: `k = strength * loops`（默认 100000）——A/B 等价但与 phet/widgets 不同 |
| B 从 A 迁移而来 | B:2 注释 "Migrated from lib/src/phet/magnet_and_compass/lib/main.dart" |

---

## 11. [待确认]

| 项 | 需谁确认 |
|---|---|
| magnet A/B 的 `BarMagnetPainter` / `CompassPainter` / `FieldArrowPainter` / `FieldMeterPainter` 逐行 diff | 用户（如需确认无功能差异） |
| magnet 保留 B 后是否接入 Home | 用户决策 |
| A 是否可删除（保留作参考基线 vs 清理） | 用户决策 |
| electromagnet 是否废弃 | 用户决策（禁止 AI 自动生成 model） |
| transformer 是否接入 Home | 用户决策 |
| phet/widgets 5 个有消费者文件是否上抽到 `lib/common/visualization/` | 用户决策 |
| phet/widgets 66 个孤立文件是否删除 | 用户决策 |
| 磁场逻辑唯一归属（`lib/common/visualization/magnetic_field.dart` vs sim 内） | 用户决策（取决于接入哪些 sim） |

---

## 完成声明

- 本文档基于 READ-ONLY 全文阅读 · **未修改任何文件**
- 所有 `[已确认]` 项均有工具调用实证（read_file 全文 / search_content grep / search_file 递归）
- 所有 `[推测]` 项已标注推测依据
- 所有 `[待确认]` 项已列出待回答的问题
- 决策 1-5 证据收集完毕 · 决策建议已提出
- 完成后停止
