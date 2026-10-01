# MAGNET MIGRATION DESIGN

> 生成日期：2026-08-31
> 阶段：**READ-ONLY + MIGRATION DESIGN** · 未移动任何文件 · 未修改任何 import
> 依据：`requirements/project-migration/LEGACY_MIGRATION_PLAN.md` + `LEGACY_DECISION_1_5.md`
> 源实现：`simulations/magnet_and_compass.dart`（B 版 · 1089 行 · 单文件）
> 证据级别：`[已确认]` = 全文阅读实证 · `[推测]` = 标注推测依据 · `[待确认]` = 需用户拍板

---

## 1. 当前实现结构

### 源文件

| 项 | 值 |
|---|---|
| 路径 | `simulations/magnet_and_compass.dart` |
| 行数 | 1089 |
| 单文件 | ✅ 是（所有类在同一文件） |
| 入口 | `MagnetAndCompassPage`（StatefulWidget · 无 `main()`） |
| 依赖 | `dart:math` · `flutter/material` · `flutter_svg` |

### B 内部结构（按行号区间）

| 行号区间 | 类 / 组件 | 职责 | KARTOSLAB 对应层 |
|---|---|---|---|
| 11-67 | `SimState` | 12 字段状态 + `copyWith` | **model** |
| 72-128 | `MagneticField` | 静态 `compute()` + `magnitude()` + `fieldAngle()` | **model**（physics） |
| 133-523 | `MagnetAndCompassPage` + `_MagnetAndCompassPageState` | 页面 + 控制器 + tick loop + 拖拽 + reset | **controller + screen**（当前未分离） |
| 528-550 | `_EarthGlowPainter` | 地球辉光 | **painter** |
| 555-613 | `_VerticalMagnetPainter` | 地球模式下的垂直磁铁 | **painter** |
| 618-694 | `BarMagnetPainter` | 条形磁铁（含 seeInside 域） | **painter** |
| 699-788 | `FieldNeedlePainter` | 磁场箭头网格（34×19） | **painter** |
| 793-867 | `CompassPainter` | 罗盘指针 | **painter** |
| 872-1043 | `_ControlPanel` | 控制面板（强度/翻转/显示开关） | **widget** |
| 1045-1088 | `_MiniCompassPreviewPainter` | 控制面板内的迷你罗盘预览 | **painter** |

### constants

[已确认] B 内硬编码常量：

| 常量 | 值 | 位置 | 用途 |
|---|---|---|---|
| `_magnetW` | 500.0 | :143 | 磁铁宽度 |
| `_magnetH` | 128.0 | :144 | 磁铁高度 |
| `_earthR` | 180.0 | :145 | 地球半径 |
| `_compassR` | 76.0 | :146 | 罗盘半径 |
| FieldNeedlePainter cols | 34 | :726 | 箭头列数 |
| FieldNeedlePainter rows | 19 | :727 | 箭头行数 |
| FieldMeter 尺寸 | 260×192 | :455 | 磁场计面板 |
| _ControlPanel 宽度 | 230 | :898 | 控制面板宽度 |

### assets

| 项 | 引用位置 | 文件是否存在 | 说明 |
|---|---|---|---|
| `assets/earth.svg` | `:403` `_buildEarth()` 内 `SvgPicture.asset('assets/earth.svg')` | 🔴 **不存在** | 全工程 `search_file` 递归 0 结果 · `pubspec.yaml` assets 未列 |
| 其他图片 | 无 | — | B 不引用其他图片 |

### tests

[已确认] `test/` 目录内无任何 magnet / compass 相关测试文件（`search_content` 0 结果）。

---

## 2. 目标目录

### domain 选择

[已确认] 当前 `lib/` 下已有 domain：

| domain | 路径 | sims |
|---|---|---|
| chemistry | `lib/chemistry/` | build_a_nucleus · molarity |
| circuit | `lib/circuit/` | circuit |
| color_vision | `lib/color_vision/` | color_vision |
| forces | `lib/forces/` | forces |
| optics | `lib/optics/` | optics |
| sound | `lib/sound/` | sound |
| radio_waves | `lib/radio_waves/` | radio_waves |
| wave_interference | `lib/wave_interference/` | wave_interference |

[推测] Magnet and Compass 属于"电磁学"领域，但当前工程无 `lib/electromagnetism/` domain。可选方案：

| 选项 | 路径 | 权衡 | 推荐？ |
|---|---|---|---|
| A | `lib/magnetism/magnet_and_compass/` | 新建 magnetism domain · 未来 electromagnet / transformer 可归入 | ✅ 推荐 |
| B | `lib/physics/magnet_and_compass/` | 新建 physics domain · 但与 forces/optics/sound 并列不协调 | ❌ |
| C | `lib/electromagnetism/magnet_and_compass/` | 新建 electromagnetism domain · 未来 electromagnet / transformer 可归入 | ✅ 备选 |

**推荐 A**：`lib/magnetism/magnet_and_compass/`

理由：

1. 与已有 domain 命名风格一致（`sound/` · `optics/` · `forces/` 均为学科名）
2. `magnetism` 比 `electromagnetism` 更简洁
3. 未来 electromagnet / transformer 可归入同一 domain
4. [待确认] 用户拍板

### 目标目录结构

基于 KARTOSLAB 已有 sim 规范（参考 `lib/sound/` · `lib/chemistry/build_a_nucleus/`）：

```
lib/magnetism/magnet_and_compass/
├── model/
│   ├── magnet_state.dart          ← SimState → MagnetState
│   └── magnetic_field.dart         ← MagneticField
├── painters/
│   ├── bar_magnet_painter.dart    ← BarMagnetPainter
│   ├── compass_painter.dart       ← CompassPainter
│   ├── field_needle_painter.dart   ← FieldNeedlePainter
│   ├── vertical_magnet_painter.dart ← _VerticalMagnetPainter（改 public）
│   └── earth_glow_painter.dart    ← _EarthGlowPainter（改 public）
├── screens/
│   └── magnet_and_compass_screen.dart ← MagnetAndCompassPage → MagnetAndCompassScreen
├── widgets/
│   ├── control_panel.dart          ← _ControlPanel（改 public）
│   ├── field_meter.dart            ← _buildFieldMeter 提取为 Widget
│   └── mini_compass_preview_painter.dart ← _MiniCompassPreviewPainter（改 public）
└── magnet_and_compass_constants.dart ← 常量提取
```

**不机械复制 build_a_nucleus 的全部层级**——build_a_nucleus 有 `chart_intro/` 子目录（40 文件），Magnet 不需要。Magnet 的 `config/` 暂不需要（无 scenario JSON）。

[待确认] 是否需要 `controller/` 子目录？当前 B 的 controller 逻辑（tick loop + 拖拽 + reset）混在 `_MagnetAndCompassPageState` 内。KARTOSLAB 规范参考：
- `lib/sound/` 无 `controller/`（controller 逻辑在 `_SoundScreenState` 内）
- `lib/chemistry/build_a_nucleus/` 有 `controller/`

**推荐**：暂不拆 `controller/`，与 `lib/sound/` 保持一致——controller 逻辑留在 `Screen` State 内。如果后续 complexity 增长再拆。

---

## 3. 文件迁移表

### Legacy Path → Target Path

| # | Legacy Path | Target Path | 操作 | 行数 | 说明 |
|---|---|---|---|---|---|
| 1 | `simulations/magnet_and_compass.dart:11-67` | `lib/magnetism/magnet_and_compass/model/magnet_state.dart` | **拆分** | 57 | `SimState` → `MagnetState` · 改类名 |
| 2 | `simulations/magnet_and_compass.dart:72-128` | `lib/magnetism/magnet_and_compass/model/magnetic_field.dart` | **拆分** | 57 | `MagneticField` 原样迁移 |
| 3 | `simulations/magnet_and_compass.dart:618-694` | `lib/magnetism/magnet_and_compass/painters/bar_magnet_painter.dart` | **拆分** | 77 | `BarMagnetPainter` 原样迁移 |
| 4 | `simulations/magnet_and_compass.dart:793-867` | `lib/magnetism/magnet_and_compass/painters/compass_painter.dart` | **拆分** | 75 | `CompassPainter` 原样迁移 |
| 5 | `simulations/magnet_and_compass.dart:699-788` | `lib/magnetism/magnet_and_compass/painters/field_needle_painter.dart` | **拆分** | 90 | `FieldNeedlePainter` 原样迁移 |
| 6 | `simulations/magnet_and_compass.dart:555-613` | `lib/magnetism/magnet_and_compass/painters/vertical_magnet_painter.dart` | **拆分+改 public** | 59 | `_VerticalMagnetPainter` → `VerticalMagnetPainter` |
| 7 | `simulations/magnet_and_compass.dart:528-550` | `lib/magnetism/magnet_and_compass/painters/earth_glow_painter.dart` | **拆分+改 public** | 23 | `_EarthGlowPainter` → `EarthGlowPainter` |
| 8 | `simulations/magnet_and_compass.dart:872-1043` | `lib/magnetism/magnet_and_compass/widgets/control_panel.dart` | **拆分+改 public** | 172 | `_ControlPanel` → `MagnetControlPanel` |
| 9 | `simulations/magnet_and_compass.dart:454-522` | `lib/magnetism/magnet_and_compass/widgets/field_meter.dart` | **提取** | 69 | `_buildFieldMeter` → `FieldMeter` Widget |
| 10 | `simulations/magnet_and_compass.dart:1045-1088` | `lib/magnetism/magnet_and_compass/widgets/mini_compass_preview_painter.dart` | **拆分+改 public** | 44 | `_MiniCompassPreviewPainter` → `MiniCompassPreviewPainter` |
| 11 | `simulations/magnet_and_compass.dart:133-523` | `lib/magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart` | **拆分+改类名** | 391 | `MagnetAndCompassPage` → `MagnetAndCompassScreen` · `_MagnetAndCompassPageState` → `_MagnetAndCompassScreenState` |
| 12 | `simulations/magnet_and_compass.dart:143-146` | `lib/magnetism/magnet_and_compass/magnet_and_compass_constants.dart` | **提取** | 4 | 常量提取 |

**总计**：1 个 legacy 文件 → 12 个 target 文件

### 类名变更表

| Legacy 类名 | Target 类名 | 理由 |
|---|---|---|
| `SimState` | `MagnetState` | 与 `SoundState` / `BuildANucleusState` 命名一致 |
| `MagnetAndCompassPage` | `MagnetAndCompassScreen` | 与 `SoundScreen` / `CircuitScreen` 命名一致 |
| `_MagnetAndCompassPageState` | `_MagnetAndCompassScreenState` | 跟随 Screen 改名 |
| `_ControlPanel` | `MagnetControlPanel` | 改 public + 加前缀避免歧义 |
| `_EarthGlowPainter` | `EarthGlowPainter` | 改 public |
| `_VerticalMagnetPainter` | `VerticalMagnetPainter` | 改 public |
| `_MiniCompassPreviewPainter` | `MiniCompassPreviewPainter` | 改 public |
| `MagneticField` | `MagneticField` | ✅ 不改（sim 内部逻辑） |
| `BarMagnetPainter` | `BarMagnetPainter` | ✅ 不改 |
| `CompassPainter` | `CompassPainter` | ✅ 不改 |
| `FieldNeedlePainter` | `FieldNeedlePainter` | ✅ 不改 |

---

## 4. Asset 迁移表

| Asset | Legacy 引用 | 文件存在？ | 迁移操作 | 说明 |
|---|---|---|---|---|
| `assets/earth.svg` | `simulations/magnet_and_compass.dart:403` | 🔴 **不存在** | [待确认] | 见下文 |

### earth.svg 问题分析

[已确认] 三路搜索均返回 0 结果：

1. `search_file` 全工程递归 `earth.svg` → 0 结果
2. `search_content` 在 `assets/` 内 grep `earth|Earth` → 0 结果
3. `pubspec.yaml:64-76` assets 列表无 `earth.svg` 或根 `assets/` 条目

**结论**：`earth.svg` 文件从未存在于当前工程。B 的 `_buildEarth()` 方法引用一个不存在的 asset——**运行到 earthField 模式时会 crash**（`SvgPicture.asset` 找不到文件会抛异常）。

### 迁移操作

| 选项 | 操作 | 权衡 |
|---|---|---|
| A | 从 PhET 原始项目 `phet/magnet_and_compass/` 寻找 `earth.svg` 并复制到 `assets/images/earth.svg` | [待确认] A 是否有此文件 |
| B | 创建替代 SVG（简地球圆 + 大陆轮廓） | 可行但非原版 |
| C | 移除 earthField 模式 | 功能缺失 |
| D | 用 `CustomPainter` 绘制地球替代 SVG | 工程量大 |

**推荐 A**——先检查 A 是否有 `earth.svg`。如果 A 也没有，退回 B 或 D。

[待确认] 用户提供 `earth.svg` 或确认替代方案。

### 其他 assets

[已确认] B 不引用其他图片、字体、音效。迁移范围仅 `earth.svg`。

---

## 5. Home 接线方案

### 当前 Home 结构

[已确认] `lib/screens/home_screen.dart` 结构：

```dart
// 学科 → 子领域 → sim 入口
_Discipline('物理') → _SubjectGroup('光学与波动') → [
  _SimEntry(title: '色觉', builder: _buildColorVision),
  _SimEntry(title: '波的干涉', builder: _buildWaveInterference),
  _SimEntry(title: '声波', builder: _buildSound),
  _SimEntry(title: '电磁波', builder: _buildRadioWaves),
]
```

### 推荐接入方案

| 项 | 值 | 依据 |
|---|---|---|
| 学科 | 物理 | magnet 属物理 |
| 子领域 | 电磁学（新建）或 光学与波动 | [待确认] |
| title | 磁铁与罗盘 | |
| subtitle | 磁场 · 偶极子 · 指南针 | |
| icon | `Icons.explore_rounded` 或 `Icons.navigation_rounded` | [推测] |
| color | `Color(0xFF...)` | [待确认] |
| builder | `_buildMagnetAndCompass` | |
| route | `MaterialPageRoute(builder: (_) => const MagnetAndCompassScreen())` | |

### Home 改动清单（当前不执行）

| 文件 | 改动 |
|---|---|
| `lib/screens/home_screen.dart` | import + `_SimEntry` + `_buildMagnetAndCompass` 静态方法 |

**推荐子领域**：新建"电磁学"组，放在"电学与电路"之后或与"光学与波动"合并。

[待确认] 用户选择子领域归属。

### Screen 命名

| 项 | 值 |
|---|---|
| Screen 类名 | `MagnetAndCompassScreen` |
| 文件名 | `magnet_and_compass_screen.dart` |
| import 路径 | `lib/magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart` |

---

## 6. Test 方案

### 当前状态

[已确认] `test/` 目录内无 magnet / compass 相关测试（`search_content` 0 结果）。

### 最小测试计划（当前不创建）

| # | 测试文件 | 测试目标 | AC |
|---|---|---|---|
| 1 | `test/magnetism/magnet_state_test.dart` | `MagnetState` 初始化 + `copyWith` 12 字段 | AC-1 |
| 2 | `test/magnetism/magnetic_field_test.dart` | `MagneticField.compute()` 偶极子场 · 远场衰减 · earthField 模式 · flipped 极性翻转 | AC-2 |
| 3 | `test/magnetism/magnet_position_test.dart` | 磁铁拖拽 clamp 边界 | AC-3 |
| 4 | `test/magnetism/compass_behavior_test.dart` | 罗盘指针朝向磁场方向 · 翻转后反向 | AC-4 |
| 5 | `test/magnetism/magnet_screen_test.dart` | Screen 初始化 · reset 恢复默认 · 控制面板交互 | AC-5 |

### AC 定义

| AC | 描述 |
|---|---|
| AC-1 | `MagnetState` 12 字段正确初始化 + `copyWith` 单字段替换 |
| AC-2 | `MagneticField.compute()` 在偶极子轴线上远场 ∝ 1/r³ · 翻转后 B 反向 · earthField 模式垂直偶极子 |
| AC-3 | 磁铁拖拽不超出屏幕边界（clamp 生效） |
| AC-4 | 罗盘指针方向与磁场方向一致 · 翻转极性后指针反向 |
| AC-5 | Screen 加载默认状态 · reset 按钮恢复初始 · 控制面板开关切换显示 |

### MagneticField 关键测试用例

| 用例 | 输入 | 期望 |
|---|---|---|
| 轴线远场 | p 在 N 极右侧 1000px · strength=0.75 | \|B\| ∝ k/r³ · k=0.75×18000 |
| 翻转极性 | flipped=true vs false | B 方向反转 180° |
| earthField 模式 | earthField=true · p 在 magnetPos 正上方 | B 方向垂直 · N 极向上 |
| 中点零场 | p 在 N/S 中点 · 垂直于轴 | B 方向垂直于轴线 |

---

## 7. MagneticField 处理原则

### 当前状态

[已确认] 工程内存在 2 组独立磁场实现（详见 `LEGACY_DECISION_1_5.md` §6）：

| 组 | 实现 | 特征 |
|---|---|---|
| 等价组 A | magnet B `MagneticField.compute()` · `k=strength*18000` · 有 earthField · 无 loops · 无 Field 接口 | **本 sim 专用** |
| 等价组 B | phet/widgets `MagneticField` extends `Field` · `k=strength*loops` · 无 earthField · 有 loops · 有 Field 接口 · transformer 委托此组 | **phet/widgets + transformer 共用** |

### 行为差异（禁止合并的理由）

| 维度 | magnet B | phet/widgets |
|---|---|---|
| earthField 模式 | ✅ 有（地球固定垂直偶极子） | ❌ 无 |
| loops 参数 | ❌ 无（strength 是标量） | ✅ 有（k=strength×loops） |
| k 系数 | `strength × 18000` | `strength × loops`（默认 100000） |
| 数值标度 | strength=0.75 → k=13500 | strength=100000 · loops=1 → k=100000 |
| Field 接口 | ❌ 不继承 | ✅ extends Field |
| 多偶极子叠加 | ❌ 单偶极子 | ✅ 列表 |
| 返回类型 | `Offset` | `PhetVector` |

### 处理原则

**禁止合并成一个万能实现**。理由：

1. 两组实现的**数值标度不同**（k=18000 vs k=100000）——合并会改变 sim 行为
2. magnet B 有 **earthField 模式**——phet/widgets 没有
3. phet/widgets 有 **loops 参数** + **Field 接口**——magnet B 没有
4. 两者面向**不同 sim 场景**——magnet 是条形磁铁 / 地球磁场，phet/widgets 是电磁铁 / 变压器

### 迁移操作

| 项 | 操作 |
|---|---|
| `MagneticField` | **原样迁移到** `lib/magnetism/magnet_and_compass/model/magnetic_field.dart` · 作为 **sim 内部逻辑** |
| common MagneticField | **不创建** · 不上抽到 `lib/common/` |
| phet/widgets MagneticField | 随 phet/widgets 决策（ARCHIVE 或其他）单独处理 |

---

## 8. phet A 的归档方案

### A 的状态

| 项 | 值 |
|---|---|
| 路径 | `phet/magnet_and_compass/` |
| 入口 | `void main()` + `MagnetApp` + `MaterialApp` + `EntryPage` |
| 性质 | standalone App（与 `KratosApp` 冲突） |
| 物理逻辑 | 与 B 逐行等价（`LEGACY_DECISION_1_5.md` §1 已确认） |
| Home 引用 | ❌ 未被引用 |
| assets | [待确认] A 是否有 `earth.svg` |

### 归档方案

| 选项 | 操作 | 权衡 |
|---|---|---|
| A | 保留 `phet/magnet_and_compass/` 原位 · 不动 | 维持现状 · 不影响运行 |
| B | 移到 `archive/phet/magnet_and_compass/` | 明确标记归档 |
| C | 删除 | [待确认] 用户决定 |

**推荐 A**——保留原位不动。理由：

1. A 不影响运行工程（无 `main()` 冲突——A 的 `main()` 不被 `KratosApp` 调用）
2. A 是 PhET 原始形态 · 保留作参考基线
3. 迁移 B 后 · A 不再被任何代码引用 · 自然成为死代码
4. [待确认] 用户是否需要 A 的 `earth.svg`（如 A 有此文件）

### earth.svg 溯源

[待确认] 需检查 A 是否有 `earth.svg`：

- `phet/magnet_and_compass/assets/earth.svg` 是否存在？
- 如果存在 → 复制到 `assets/images/earth.svg` · 修复 B 的运行时 crash
- 如果不存在 → 需用户决策替代方案

---

## 9. 风险

| 风险 | 等级 | 原因 | 缓解 |
|---|---|---|---|
| `earth.svg` 缺失 | 🔴 高 | B 运行到 earthField 模式会 crash | [待确认] 从 A 复制或创建替代 |
| 单文件 → 12 文件拆分 | 🟡 中 | 拆分过程中可能遗漏 private → public 改名 | 逐文件 `replace_in_file` · 逐个验证编译 |
| `NineGridLayout` 适配 | 🟡 中 | B 用 `Stack + Positioned` · 不符合 KARTOSLAB `NineGridLayout` 规范 | 迁移时需重构布局 · 增加 complexity |
| `_ControlPanel` 自造控件 | 🟡 中 | B 用原生 `Slider` + `Checkbox` · 未用 `lib/common/controls/` L0 组件 | 迁移时替换为 `KratosSlider` 等 |
| `SimulationClock` 缺失 | 🟡 中 | B 用 `AnimationController` · 未用 `lib/common/simulation_clock.dart` | 迁移时替换为 `SimulationClock` |
| 磁场标度不同 | 🟢 低 | B 与 phet/widgets 标度不同 · 但不合并 | ✅ 已禁止合并 |
| 无测试 | 🟡 中 | 迁移后无测试基线 | 提出最小测试计划（§6） |
| A 的 earth.svg 是否存在 | 🟡 中 | 影响 B 运行时 | [待确认] |

---

## 10. [已确认]

| 项 | 证据 |
|---|---|
| B 全文 1089 行 | `read_file` 完整读取 |
| B 无 `main()` | 全文无 `void main` |
| B 入口 `MagnetAndCompassPage` | `:133` |
| B 有 10 个类 | `SimState` / `MagneticField` / `MagnetAndCompassPage` / `_EarthGlowPainter` / `_VerticalMagnetPainter` / `BarMagnetPainter` / `FieldNeedlePainter` / `CompassPainter` / `_ControlPanel` / `_MiniCompassPreviewPainter` |
| `earth.svg` 全工程不存在 | `search_file` 递归 0 结果 · `assets/` 内 grep 0 结果 · `pubspec.yaml` 未列 |
| `test/` 无 magnet 测试 | `search_content` 0 结果 |
| Home 不引用 B | `home_screen.dart` 无 `magnet` import |
| 已有 sim 目录结构 | `model/` + `painters/` + `screens/` + `widgets/` + `config/`（可选） |
| `NineGridLayout` 是阻塞级规范 | `lib/common/widgets/nine_grid_layout.dart` · 已有 7 sim 使用 |
| Home 结构 | `_Discipline` → `_SubjectGroup` → `_SimEntry` + `builder` |
| L0 组件清单 | `lib/common/controls/` 有 `KratosSlider` / `KratosComboBox` / `KratosRadioGroup` / `KratosNumberField` · `lib/common/widgets/` 有 `PropertyControlPanel` / `TimeControlBar` / `NineGridLayout` / `ExperimentIntroPanel` 等 |
| `SimulationClock` | `lib/common/simulation_clock.dart` 存在 |
| B 用 `AnimationController` 而非 `SimulationClock` | `:170-173` |
| B 用 `Stack + Positioned` 而非 `NineGridLayout` | `:250-341` |
| B 用原生 `Slider` 而非 `KratosSlider` | `:937` |
| B 用原生 `Checkbox` 而非 L0 组件 | `:968-973` |

---

## 11. [推测]

| 项 | 推测依据 |
|---|---|
| `lib/magnetism/` 是合适 domain | 已有 domain 均为学科名（sound/optics/forces） |
| `MagnetAndCompassScreen` 是合适类名 | 已有 Screen 命名一致（SoundScreen/CircuitScreen） |
| 推荐子领域"电磁学" | magnet 属电磁学 · 但当前 Home 无此组 |
| A 可能有 `earth.svg` | A 是 PhET 原始项目 · 通常带 assets · 但未验证 |
| `earth.svg` 在 PhET 原版存在 | B 的 `_buildEarth` 引用它 · 说明某处应该有此文件 |
| 推荐保留 A 原位 | A 无 Home 引用 · 不影响运行 · 是参考基线 |

---

## 12. [待确认]

| # | 问题 | 需谁确认 | 选项 |
|---|---|---|---|
| 1 | domain 路径选 `lib/magnetism/` 还是 `lib/electromagnetism/`？ | 用户 | A=magnetism ✅ · B=electromagnetism |
| 2 | Home 子领域归属：新建"电磁学"组还是归入"光学与波动"？ | 用户 | A=新建电磁学 ✅ · B=归入光学与波动 |
| 3 | `earth.svg` 来源：A 是否有此文件？ | 用户/A 检查 | A=从 A 复制 · B=创建替代 · C=移除 earthField |
| 4 | A 归档方案：保留原位还是移到 archive？ | 用户 | A=保留原位 ✅ · B=移到 archive · C=删除 |
| 5 | 是否需要 `controller/` 子目录？ | 用户 | A=不拆 ✅ · B=拆 |
| 6 | 是否在迁移时替换 `AnimationController` → `SimulationClock`？ | 用户 | A=替换 · B=暂不替换 ✅ · C=后续迭代 |
| 7 | 是否在迁移时替换原生 `Slider`/`Checkbox` → L0 组件？ | 用户 | A=替换 · B=暂不替换 ✅ · C=后续迭代 |
| 8 | 是否在迁移时重构 `Stack+Positioned` → `NineGridLayout`？ | 用户 | A=迁移时重构 · B=暂不重构 ✅ · C=后续迭代 |
| 9 | Home card 的 icon 和 color？ | 用户 | [待确认] |
| 10 | 最小测试计划的 AC 是否覆盖关键路径？ | 用户 | [待确认] |

---

## 迁移步骤概览（当前不执行）

> 仅列出步骤顺序 · **不执行任何操作**

| 步骤 | 操作 | 依赖 |
|---|---|---|
| 1 | 确认 [待确认] 1-10 | 用户拍板 |
| 2 | 创建 `lib/magnetism/magnet_and_compass/` 目录树 | 步骤 1 |
| 3 | 从 B 拆分 12 个文件到目标路径 | 步骤 2 |
| 4 | 解决 `earth.svg` 缺失问题 | [待确认] 3 |
| 5 | 类名改写（private → public · Page → Screen） | 步骤 3 |
| 6 | import 路径调整 | 步骤 3-4 |
| 7 | Home 接线（import + `_SimEntry` + builder） | 步骤 3 |
| 8 | `pubspec.yaml` assets 添加 `earth.svg`（如需） | 步骤 4 |
| 9 | 创建测试文件 | 步骤 3 |
| 10 | `flutter analyze` 验证编译 | 步骤 3-9 |
| 11 | `flutter run` 验证运行 | 步骤 10 |
| 12 | 删除 `simulations/magnet_and_compass.dart`（原 B） | 步骤 11 |

---

## 完成声明

- 本文档基于 READ-ONLY 全文阅读 · **未移动任何文件** · **未修改任何 import**
- 所有 `[已确认]` 项均有工具调用实证
- 所有 `[推测]` 项已标注推测依据
- 所有 `[待确认]` 项已列出选项
- 迁移设计完毕 · **不执行任何文件操作** · 完成后停止
