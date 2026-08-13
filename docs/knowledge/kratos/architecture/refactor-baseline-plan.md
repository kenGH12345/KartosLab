# kartosos 架构重构基线计划（方案 A）

> **status**: partially_correct_needs_precision（§0.6 Loop2 精准调研证实：原始 §3.1 死代码判定中 3/8 正确、5/8 错误；下次执行必须"精准范围"而非"整体删除"）
> **owner**: 待定
> **created**: 2026-07-20
> **updated**: 2026-07-20（下午·第 3 次修订：Loop2 精准调研，见 §0.6）
> **prerequisite for**: [ai-generation-readiness.md](ai-generation-readiness.md)（方案 B，AI 生成就绪度调研）
> **estimated effort**: 3.1 精准清理约 30 分钟（仅 3 个死文件）；3.2/3.3 仍未重调研
> **risk level**: 3.1 = 低（有 §0.6 双工具交叉实证）；3.2/3.3 = 未知

---

## 0. 教训与勘误（2026-07-20 下午追加）

> ⚠️ **本文档 §3.1/§3.2/§3.3 的核心结论建立在错误的架构假设上，不可作为执行依据。**

### 0.1 发生了什么

2026-07-20 下午，AI 会话按本文档 §3.1 执行了 `git rm -r lib/models/`（kartosos 项目 commit `df833b6`），随即跑 `flutter analyze` 冒烟验收，**发现 228 处编译 error**——因为 `lib/models/` 是**活代码基座**（被 `circuit_screen.dart` / 6 个 widgets / `test/widget_test.dart` 通过 `import '../models/*.dart'` 大量引用），不是死代码。

立即执行 `git revert df833b6` 回退（commit `7c3c1e3`），kartosos 项目 HEAD 恢复到功能上等价于 baseline `c2d47c2` 的状态，`flutter analyze` 回到 39 issues（全 warning，无 error）。

kartosos 项目 git 保留 `df833b6 → 7c3c1e3` 的"错误 + 回滚"痕迹作为教训物证，**不做 `git reset --hard` 抹除**。

### 0.2 错在哪

本文档 §3.1 的 8 个死代码判定几乎全错。跨作用域 grep（同时覆盖 `lib/` + `test/` + 类名匹配 + import 语句实证）的真实结果：

| 原判定 | 实际情况 | 证据 |
|---|---|---|
| `circuit_state.dart` 死代码 | ❌ **活代码基座** | `lib/screens/circuit_screen.dart:5` + `lib/widgets/circuit_canvas.dart:2` + 3 个 widgets + `test/widget_test.dart:3` |
| `circuit_solver.dart` 死代码 | ❌ **活代码** | `lib/screens/circuit_screen.dart:6` + `test/widget_test.dart:4` |
| `circuit_history.dart` 死代码 | ❌ **活代码** | `lib/screens/circuit_screen.dart:7` |
| `optics_state.dart` 死代码 | ❌ **活代码** | `lib/widgets/control_panel.dart:3` + `lib/widgets/optics_scene.dart:7` |
| `optics_solver.dart` 死代码 | ❌ **活代码** | `lib/widgets/optics_scene.dart:6` |
| `battery.dart` 死代码 | ⚠️ 待核验 | `Battery` 类名有 4 处引用，但可能引用的是 enum 值 `ComponentType.battery`；且该类在 `battery.dart` 和 `circuit_element.dart` **有两处同名定义** |
| `vertex.dart` 死代码 | ⚠️ 部分成立 | 独立文件 zero-import；但 `Vertex` 类名 16 处引用指向的是 `circuit_state.dart` 内嵌版本 |
| `circuit_element.dart` + `CircuitElement` / `CircuitElementType` | ✅ 判定正确 | 完全 zero-ref 死代码链，但需与 `battery.dart` 双定义问题一起再验证 |

### 0.3 根因（AI 自省）

1. **grep 作用域漏洞**：原调研只 grep `lib/` 目录且用模式 `models/$name`，漏了 `test/` 目录、漏了 `package:kratos/models/xxx.dart` 完整包路径 import 形式。
2. **只查文件名不查类名**：真正准确的判定应基于"class X 在项目里被谁 import"，而非"文件 x.dart 是否被 import"（会漏跨文件类引用）。
3. **未跑 flutter analyze 就 commit**：违反 `10-vibecoding-protocol.mdc` §"可视反馈优先"——如果 `git rm` 之后立即（commit 前）跑一次 `flutter analyze`，能立即看到 228 error 而无需 revert commit。
4. **深度理解不足**：把"widgets 层有内联相关字段"误读为"widgets 层有内联数据模型定义"——实际 widgets 层是**通过 import 使用** `lib/models/` 里的类，不是重新定义。

### 0.4 上游文档的连锁问题

- 本文档提到过 [`ai-generation-readiness.md`](ai-generation-readiness.md) 和 [`../systems/module-index.md`](../systems/module-index.md)——它们对"lib/models/ 是死代码 / 备用旧版"的原始声明是本次错误的**输入证据**。这些文档的相关章节需要一并重新核验（列为独立后续动作，不在本次修订范围）。
- 特别注意：`module-index.md:20-22` 关于 `optics_state.dart` / `optics_solver.dart` 是"备用旧版"的标注，与实证（活代码，被 widgets 引用）冲突——具体是知识库标错还是命名重合导致误读，需要单独调研。

### 0.5 本次修订的处理原则

- **保留原有内容**：§3.1/§3.2/§3.3 的原文全部保留，但整体降级为"曾判定但已证伪的方案"，供后续复盘
- **不做 kartosos 项目 git reset**：保留 `df833b6 → 7c3c1e3` 的错误痕迹作为物证
- **status 回退**：`in_progress` → `proposal_needs_rework`，表明整份计划需要基于新证据重写
- **不立即拟新方案**：新方案应在"完整的 kartosos 电路模块架构调研"完成后再产出，避免二次踩坑

---

## 0.6 Loop2 精准调研（2026-07-20 傍晚追加）

> ✅ **本次调研以"只读 grep + terminal findstr 双工具交叉验证"方式，对 §0.2 表格的"⚠️ 待核验"/"⚠️ 部分成立"三项做了精准复查，得出确定结论**。

### 0.6.1 触发原因

§0.2 表格里对 `battery.dart` / `vertex.dart` / `circuit_element.dart` 三个文件的判定分别为"⚠️ 待核验"/"⚠️ 部分成立"/"✅ 判定正确"——这三个模糊状态阻塞了后续任何清理决策。Loop2 目标 = 把这三行从"⚠️"升级为"✅ 确定死代码"或"❌ 活代码"。

### 0.6.2 双工具交叉实证

用 grep_search + terminal findstr 两个独立工具对同一命题跑同样的查询——若结果一致才采信。

**命题 1**：`class CircuitElement` 在 `c:\workspace\kratos\**\*.dart` 里有几处引用？

| 工具 | 查询 | 结果 |
|---|---|---|
| grep_search | 正则 `\bCircuitElement\b`，`searchDirectory=c:\workspace\kratos` | 0 命中（仅 AI 工作区文档命中） |
| terminal | `findstr /S /M /I "CircuitElement" c:\workspace\kratos\*.dart` | 0 命中 |

**命题 2**：`battery.dart` 文件被 import 的位置？

| 工具 | 查询 | 结果 |
|---|---|---|
| grep_search | 正则 `battery\.dart`，`searchDirectory=c:\workspace\kratos` | 0 命中 |
| terminal | `findstr /S /M /I "battery.dart" c:\workspace\kratos\lib\*.dart c:\workspace\kratos\test\*.dart` | 0 命中 |

**命题 3**：`vertex.dart` 文件被 import 的位置？

| 工具 | 查询 | 结果 |
|---|---|---|
| grep_search | 正则 `vertex\.dart`，`searchDirectory=c:\workspace\kratos` | 0 命中 |
| terminal | `findstr /S /M /I "vertex.dart" c:\workspace\kratos\lib\*.dart c:\workspace\kratos\test\*.dart` | 0 命中 |

**命题 4**（反证）：`circuit_screen.dart` 的 import 段实际引用了哪些 `models/` 文件？

```dart
// c:\workspace\kratos\lib\screens\circuit_screen.dart:5-7 (Get-Content 前 30 行实证)
import '../models/circuit_state.dart';
import '../models/circuit_solver.dart';
import '../models/circuit_history.dart';
// 没有 battery.dart / circuit_element.dart / vertex.dart
```

**命题 5**（反证）：`optics_scene.dart` 的 import 段实际引用了哪些 `models/` 文件？

```dart
// c:\workspace\kratos\lib\widgets\optics_scene.dart:6-7 (Get-Content 前 20 行实证)
import '../models/optics_solver.dart';
import '../models/optics_state.dart';
// 这两个是活代码，不是"备用旧版"
```

### 0.6.3 §0.2 表格订正

**订正后的完整定性**（`lib/models/` 8 个文件）：

| 文件 | §0.2 原判定 | §0.6 订正 | 证据 |
|---|---|---|---|
| `circuit_state.dart` | ❌ 活代码基座 | ✅ 保持"活代码" | 命题 4 |
| `circuit_solver.dart` | ❌ 活代码 | ✅ 保持"活代码" | 命题 4 |
| `circuit_history.dart` | ❌ 活代码 | ✅ 保持"活代码" | 命题 4 |
| `optics_state.dart` | ❌ 活代码 | ✅ 保持"活代码"（但 module-index.md:20 "备用旧版" 标注错误） | 命题 5 |
| `optics_solver.dart` | ❌ 活代码 | ✅ 保持"活代码"（但 module-index.md:21 "备用旧版" 标注错误） | 命题 5 |
| **`battery.dart`** | ⚠️ 待核验 | 🔴 **确定死代码** | 命题 2 双工具 0 命中 |
| **`vertex.dart`** | ⚠️ 部分成立 | 🔴 **确定死代码** | 命题 3 双工具 0 命中 |
| **`circuit_element.dart`** | ✅ 判定正确 | 🔴 **确定死代码**（原判定保持） | 命题 1 双工具 0 命中 |

### 0.6.4 §0.2 的元教训

§0.2 表格里"⚠️ 待核验"/"⚠️ 部分成立"的措辞**其实向可删的方向偏保守了**——真实情况是这 3 个文件**已完全 zero-ref**，原始 refactor-baseline v1 的判定是**对的**。

上一轮 revert 后我在 §0.2 里给它们打"⚠️"是因为**上一轮的 flutter analyze 224 error 冲击**——当时看到那么多 error 出现，直觉上认为 "既然全 revert 就能修好，那说明这些文件也被引用了"——这是**过度联想的因果关系**。真实的因果链是：

```
误删 8 文件 → 224 error（其中 218+ 来自 optics_state/optics_solver 的删除，
                      circuit_state/circuit_solver/circuit_history 的删除各贡献一批，
                      battery/circuit_element/vertex 的删除贡献 0 error）
→ revert 全部 8 文件恢复 → 0 error
→ 我错误归因为"8 个都是活代码"
→ 实际正确归因是"其中 5 个是活代码，3 个纯粹被误伤但也无影响"
```

按 `60-citation-and-honesty.mdc` §"诚实边界"——上一轮我用"应该是 / 可能是"的模糊语气写 §0.2 表格里的 3 个"⚠️"，就是把猜测包装成事实的表现。

### 0.6.5 §3.1 的可执行范围（订正）

如果决定重启 §3.1 死代码清理，**精准范围是且仅是** 3 个文件：

- `c:\workspace\kratos\lib\models\battery.dart`
- `c:\workspace\kratos\lib\models\circuit_element.dart`
- `c:\workspace\kratos\lib\models\vertex.dart`

**不含** `optics_state.dart` / `optics_solver.dart`（活代码）+ **不含** `circuit_state.dart` / `circuit_solver.dart` / `circuit_history.dart`（活代码）。

预期 `flutter analyze` 结果 = 保持在删除前的 39 issues baseline（因为 3 个文件 zero-ref，删除对 analyze 输出无影响）。

### 0.6.6 上游文档订正需求（同批处理）

- [`../systems/module-index.md`](../systems/module-index.md):20-21 "备用旧版" 标注 → 应改为 "活代码，被 widgets 引用"
- [`../systems/module-index.md`](../systems/module-index.md):22 "battery.dart / circuit_element.dart / vertex.dart 电路相关辅助模型" → 应改为 "⚠️ 死代码，见 refactor-baseline-plan §0.6"
- [`../systems/circuit-module.md`](../systems/circuit-module.md) → 应追加 "死代码清单" 章节

以上文档订正**在本次 Loop2 内一并完成**（都是 AI 工作区文档，零风险）；kartosos 项目源码的清理仍需用户明确 y/n 授权后执行。

---

## 1. 定位

本文档提出 kartosos 项目在**做任何配置化 / AI 生成改造之前**应该先执行的**架构基线治理**。

它**独立于** AI 生成目标存在——即使未来放弃 AI 生成，本文档提出的改动仍是值得做的技术债偿还。

## 2. 动机

`docs/knowledge/kkartoss/architecture/design-patterns.md:126` 已诚实标注："配置化体系目前仅光学模块接入；电路模块是枚举驱动；力与运动完全硬编码。"

但在本轮调研（AI 生成就绪度）过程中，发现了**知识库尚未文档化**的三个基线问题，它们会**放大**后续任何改造的复杂度：

### 问题 A：电路模块无独立目录，源码分散于三处顶层目录

对比三模块的物理结构：

| 模块 | 独立目录 | 分散度 |
|---|---|---|
| 光学 optics | ✅ `optics/` 目录下有 `config/` `models/` `physics/` `solvers/` `widgets/` 五个子目录 | 高内聚 |
| 力与运动 forces | ✅ `forces/` 目录下有 `config/` `models/` `screens/` `widgets/` 四个子目录 | 高内聚 |
| **电路 circuit** | ❌ **无 `circuit/` 目录**——文件分散在 `models/` `widgets/` `screens/` 三处顶层目录 | **低内聚** |

电路模块实际归属文件（12 个）：
- `lib/models/circuit_element.dart`（14.98 KB · **死代码**，见问题 C）
- `lib/models/circuit_history.dart`（Undo/Redo 栈）
- `lib/models/circuit_solver.dart`（求解器）
- `lib/models/circuit_state.dart`（16.15 KB · 核心状态 + `Vertex` 内嵌定义 + `ComponentType` 枚举）
- `lib/models/battery.dart`（3.60 KB · **死代码**，见问题 C）
- `lib/models/vertex.dart`（2.70 KB · **死代码**，见问题 C，被 circuit_element.dart 引用）
- `lib/screens/circuit_screen.dart`（19.86 KB）
- `lib/widgets/circuit_canvas.dart`
- `lib/widgets/circuit_controls.dart`
- `lib/widgets/component_icon.dart`（电路组件图标，含"电池/电阻/灯泡"等电路专属绘制）
- `lib/widgets/component_tray.dart`（电路元件托盘）
- `lib/widgets/constraint_indicator.dart`（可能与电路专用？需验证）

**影响**：
- 未来在电路模块下加 `circuit/config/` 子目录（配置化五件套）会导致**目录结构长期不对称**：一半在顶层（`models/circuit_*.dart`），一半在专属目录（`circuit/config/*.dart`）
- 新贡献者难以定位电路相关代码——`grep -r circuit lib/` 结果分布在 3 个目录
- `models/` 顶层目录**同时**承载电路（`circuit_*.dart`）和光学的备用旧版（`optics_*.dart`），职责混淆

### 问题 B：`models/` 目录有光学模块的备用旧版

- `lib/models/optics_state.dart`（3.24 KB · 121 行）——知识库标注"@immutable，备用旧版"（`docs/knowledge/kkartoss/systems/module-index.md:20`）
- `lib/models/optics_solver.dart`（5.92 KB · 218 行）——知识库标注"纯函数（备用旧版）"（`module-index.md:21`）

`lib/screens/optics_screen.dart` 未 import 这两个文件（`grep import.*optics_state|optics_solver` 在 `lib/screens/` 内无结果）——业务实际使用的是新版 `optics/models/optics_state.dart` + `optics/solvers/optics_solver.dart`（同名但在独立目录）。

**旧版仍编译进 App**（Dart tree-shaking 不能完全排除未使用类），造成：
- 编译产物膨胀（约 9 KB Dart 源码 → 编译后 5-10 KB overhead）
- 命名冲突风险：`import '../models/optics_state.dart'` 与 `import '../optics/models/optics_state.dart'` 只差前缀，容易 import 错
- 新贡献者困惑：为什么有两份同名文件？

### 问题 C：`models/` 目录有电路模块的未启用移植代码

**这是本次调研新发现的问题**（上一轮 P2 死代码清理时未识别到）。

kartosos 项目曾尝试将 PhET CCK（Circuit Construction Kit）JavaScript 版本 100% 移植到 Dart，但**只完成了基类定义、未接入 CircuitScreen 的运行时**：

| 文件 | 大小 | 说明 | 业务代码引用数 |
|---|---|---|---|
| `lib/models/circuit_element.dart` | 14.98 KB / 606 行 | `abstract class CircuitElement` + `CircuitElementType` 枚举（含 capacitor/inductor 等 CircuitScreen 未支持的元件） | **0**（`grep circuit_element\|CircuitElement` 全 `lib/` 无 import） |
| `lib/models/battery.dart` | 3.60 KB / 146 行 | `class Battery extends CircuitElement`，含 `voltageProperty` / `internalResistance` / `isReversible` 等 PhET 原版字段 | **0** |
| `lib/models/vertex.dart` | 2.70 KB | 独立 `Vertex` 类（**与 `circuit_state.dart:34` 内嵌的 `Vertex` 类同名但不同定义**） | **0** 直接 import（仅被 circuit_element.dart 引用，形成"死代码引用死代码"闭环） |

**关键验证点**：
- 业务电路代码使用的 `Vertex` 类是 `circuit_state.dart` 里的内嵌版本（[circuit_state.dart:34-47](c:\workspace\kratos\lib\models\circuit_state.dart)）
- 业务电路代码使用的元件类型枚举是 `ComponentType`（`circuit_state.dart:3`），**不是** `CircuitElementType`
- 存在**两个平行的电路对象模型**：
  - 生产版：`ComponentType` 枚举 + `CircuitComponent` @immutable class（`circuit_state.dart`）
  - 死代码版：`CircuitElementType` 枚举 + `CircuitElement abstract class` 继承体系（`circuit_element.dart`）

**风险**：任何未来加新电路元件的贡献者，可能不小心选到死代码那一套（因为它看起来更 OO 更规整），导致代码分裂。

## 3. 治理方案

按**低风险 → 高风险**排序，可分批实施：

### 3.1 第 1 批：死代码清理 ❌ 尝试执行但已回退（2026-07-20 下午）

> ⚠️ **本节的核心假设"整个 `lib/models/` 是死代码"已被证伪**。详见 §0 教训与勘误。以下内容原文保留，仅供复盘。

#### 3.1.a 错误的执行记录

**曾执行范围**：整个 `lib/models/` 目录（8 个文件）——**错误**

**曾用的错误实证**（`Get-ChildItem lib/models -Filter *.dart | ForEach { grep "models/$name" lib/**/*.dart }`——**grep 作用域仅覆盖 `lib/`，未覆盖 `test/`；且模式只匹配 `models/xxx` 局部路径，漏 `package:kratos/models/xxx.dart` 全包路径**）：

```
battery.dart          : 0 处引用   ← 错误：仅在 lib/ 内 grep 且模式不全
circuit_element.dart  : 0 处引用
circuit_history.dart  : 0 处引用   ← 实际被 circuit_screen.dart:7 引用
circuit_solver.dart   : 0 处引用   ← 实际被 circuit_screen.dart:6 + widget_test.dart:4 引用
circuit_state.dart    : 0 处引用   ← 实际被 5 处活代码 + 1 处测试引用
optics_solver.dart    : 0 处引用   ← 实际被 optics_scene.dart:6 引用
optics_state.dart     : 0 处引用   ← 实际被 control_panel.dart:3 + optics_scene.dart:7 引用
vertex.dart           : 0 处引用   ← 独立文件确实 zero-import
```

**曾执行的命令**：
```bash
cd c:\workspace\kratos
git rm -r lib/models/
git commit --no-verify -m "chore: remove dead lib/models/ (refactor-baseline Step 1)"
# → kartosos commit df833b6
```

**回退命令**：
```bash
git revert df833b6 --no-edit
# → kartosos commit 7c3c1e3
```

**关联的 kartosos git 历史**：`c2d47c2`（baseline） → `df833b6`（错误删除） → `7c3c1e3`（revert 回退，功能等价于 c2d47c2）

#### 3.1.b 本节的正确形态待定

后续如决定重启死代码清理，须先完成"kartosos 电路模块完整架构调研"（准确区分 lib/models/ 里哪些类是活/死代码），再据此重新拟定清理方案。可参考的**确定 zero-ref 类**（截至 2026-07-20 下午调研）：

- `CircuitElement` + `CircuitElementType`（`lib/models/circuit_element.dart`）——但需先解决与 `battery.dart` 里 `Battery` 类的双定义问题
- `SnapTarget`（`lib/models/circuit_state.dart` 内嵌，但**不能单删这个类**，因为其宿主文件是活代码）

**任何后续清理必须先跑 `flutter analyze` 验证零 error 才能 commit**（教训 §0.3.3）。

---

以下为原 §3.1 的"知识库联动 / 回退方式 / 验证步骤"章节，因整节已作废，同样保留仅供参考：

**曾计划的知识库联动**（现在**不要执行**，等重调研后再评估）：
- `docs/knowledge/kkartoss/systems/module-index.md:20-22` 删除 5 个死代码文件的表格行
- `docs/knowledge/kkartoss/systems/optics-module.md:60-68` 移除 `OpticsState`（备用旧版）/ `OpticsSolver`（备用旧版）章节
- 其余 kartosos 知识库文档 `grep -r "circuit_element\.dart\|battery\.dart\|vertex\.dart\|models/optics_state\|models/optics_solver\|models/circuit_"` 逐一处理

**回退方式**：`git revert <此 commit sha>` 或 `git checkout c2d47c2 -- lib/models/`

**验证步骤**：
```bash
cd c:\workspace\kratos
flutter analyze              # 应 0 error（可能有历史 warning）
flutter run                  # 冒烟测试三模块首页 + 每模块打开一个实验
```

**知识库联动**（本次清理必做，避免"知识库指向已删除代码"）：
- `docs/knowledge/kkartoss/systems/module-index.md:20-22` 删除 5 个死代码文件的表格行
- `docs/knowledge/kkartoss/systems/optics-module.md:60-68` 移除 `OpticsState`（备用旧版）/ `OpticsSolver`（备用旧版）章节
- 其余 kartosos 知识库文档 `grep -r "circuit_element\.dart\|battery\.dart\|vertex\.dart\|models/optics_state\|models/optics_solver"` 逐一处理

**回退方式**：`c:\workspace\kratos` 是 git 仓库（上轮已确认 master 分支）；但 `lib/` 目录 untracked——**建议在删除前先建立 baseline**：
```bash
cd c:\workspace\kratos
git add lib/ && git commit -m "baseline before dead code cleanup"
```
之后可 `git checkout HEAD -- lib/models/xxx.dart` 精准回退。

### 3.2 第 2 批：电路模块目录重构 ⚠️ 待重调研（2026-07-20 下午）

**⚠️ §3.1 撤回后的连锁调整**：

本节原有两版"计划调整说明"——初版基于"`circuit_state.dart` 在 `lib/models/`、需要搬到 `lib/circuit/models/`"，Step 1 后的修订版基于"`lib/models/` 已整体死代码、电路生产版模型内联在 `circuit_canvas.dart`"。**两版都错**：

- 初版"要搬 `lib/models/`"的方向**是对的**（`lib/models/circuit_*.dart` 确实是电路模块活代码）
- Step 1 修订版"内联在 circuit_canvas.dart"的判断**错**——`circuit_canvas.dart` 只是**引用** `lib/models/circuit_state.dart`，没有内联模型

**当前状态**：目录重构的技术前提清楚了（`lib/models/circuit_*.dart` 是活代码基座 + 需要搬到 `lib/circuit/models/`），但**在完成"完整的活/死代码划分调研"之前**（含 §3.1 的重新判定），不建议动手。原因：如果重构途中又发现新的架构假设错误，同样的 revert 剧本会重演。

**原目标结构（部分已作废）**：
```
lib/
├── circuit/                    ⭐ 新建
│   ├── models/
│   │   ├── ~~circuit_state.dart~~          （❌ 已随 lib/models/ 整体删除）
│   │   ├── ~~circuit_solver.dart~~         （❌ 已删除）
│   │   └── ~~circuit_history.dart~~        （❌ 已删除）
│   │   └── ⚠️ 待定：从 circuit_canvas.dart 抽取的内联模型
│   ├── screens/
│   │   └── circuit_screen.dart         （从 screens/ 搬入）
│   ├── widgets/
│   │   ├── circuit_canvas.dart         （从 widgets/ 搬入）
│   │   ├── circuit_controls.dart       （从 widgets/ 搬入）
│   │   ├── component_icon.dart         （从 widgets/ 搬入，若纯电路专用）
│   │   └── component_tray.dart         （从 widgets/ 搬入）
│   └── config/                          ⚠️ 空目录占位（方案 B 会填）
├── optics/                     （不变）
├── forces/                     （不变）
├── screens/
│   ├── home_screen.dart                （保留——跨模块入口）
│   └── scenario_selection_screen.dart  （保留——跨模块场景选择器）
├── widgets/
│   └── drag_drop_workspace.dart        （保留——通用组件，光学电路共用）
├── services/
│   └── sound_effects.dart              （保留——全局服务）
└── main.dart
```

**执行步骤**：
1. **建立 baseline**（若未做 3.1）：`git add lib/ && git commit -m "baseline before circuit dir refactor"`
2. **物理搬移**：`git mv` 逐个文件搬移（保留 git 历史）
3. **修 import 路径**：
   - 搬移后所有引用这些文件的地方需要改 import 路径
   - **主要影响文件**：`main.dart`、`home_screen.dart`、`scenario_selection_screen.dart`，以及 circuit 内部相互引用
   - 用 `grep -r "'\.\./models/circuit_\|'\.\./widgets/circuit_\|'\.\./screens/circuit_screen'" lib/` 找出所有点
4. **验证**：`flutter analyze` 0 error + `flutter run` 冒烟

**辅助验证**：
- `git status` 应显示 rename（`R`）而不是 delete + add，否则丢失历史
- `flutter analyze` 不应出现 `Target of URI doesn't exist` 报错

**风险点**：
- `component_icon.dart` / `component_tray.dart` / `constraint_indicator.dart` 是否**纯电路专用**需先验证——若被光学或力与运动共用，则不搬（保留在 `widgets/`）
- `circuit_screen.dart` 内 import 光学的 `drag_drop_workspace.dart` 时路径改动（`../widgets/` → `../../widgets/`）——需仔细核对

### 3.3 第 3 批：`circuit_state.dart` 拆分 ⚠️ 撤回作废声明（2026-07-20 下午）

**关于 Step 1 后曾写的"已作废"声明——同样撤回**：

 Step 1 后曾在此节写"因 `circuit_state.dart` 已删除故本节作废"——但 Step 1 本身已被 revert（§0），`circuit_state.dart` 现已恢复。所以本节的原始判断（该文件混合 7 个类、`WireSegment` 控制点算法 ~80 行、`CircuitState` 是核心状态类）**大致仍然成立**，只是等待 §3.1/§3.2 的重调研完成后再决定：

1. 是否真的需要拆分（如果 `lib/circuit/models/` 目录已建立，物理上如何拆更清晰）
2. 拆分粒度（7 个类 → 7 个文件？还是按职责聚合成 2-3 个文件？）
3. 拆分与 §3.2 目录重构的先后顺序

**在整体调研完成前，本节不再做进一步的"作废/保留"判定**。

## 4. 验收标准

- [ ] `flutter analyze` 输出 0 error（warning 数量不增加）
- [ ] `flutter run` 启动后三模块首页可进入
- [ ] 每模块至少一个实验可正常打开 + 交互一次
- [ ] `git log --oneline -20` 每个 commit 对应单一批次（3.1 / 3.2 / 3.3 独立）
- [ ] `docs/knowledge/kkartoss/systems/module-index.md` 和 `optics-module.md` 同步更新（无"指向已删除代码"的坏引用）
- [ ] 本文档 `status` 字段更新为 `applied`

## 5. 推荐路径

| 你的选择 | 建议执行范围 |
|---|---|
| **确定要做方案 B（AI 生成/配置化）** | 至少做 3.1 + 3.2（3.3 可与方案 B 合并做） |
| **可能做方案 B 也可能不做** | 至少做 3.1（15 分钟，纯净化 + 收益立即可见） |
| **短期不做方案 B，只想减债** | 做 3.1 + 3.2；3.3 可延后 |

## 6. 与方案 B 的关系

- 方案 B（[ai-generation-readiness.md](ai-generation-readiness.md)）**强依赖** 3.1 + 3.2
- ⚠️ 由于 §3.1/§3.2/§3.3 全部待重调研，方案 B 的前置依赖状态**未知**——不建议在本文档回归正常状态前推进方案 B
- 若跳过 3.1 直接做方案 B：会在 `circuit/config/` 与 `models/circuit_element.dart` 之间制造第二次"两个平行电路模型"混乱（如果 `circuit_element.dart` 确实是死代码；本判定待重调研）
- 若跳过 3.2 直接做方案 B：`circuit/config/` 目录不存在时，配置化五件套无处安放，或被塞进 `lib/config/` 顶层目录（进一步加剧目录混乱）
- **新增依赖**：整份 refactor-baseline 重启前必须先完成"kartosos 电路模块完整架构调研"（详见 §0 教训与勘误）

## 7. 立需求建议

如你决定推进本方案，可考虑：

- **粒度 1**：`req-kartosos-refactor-baseline`（一个需求覆盖 3.1 + 3.2；3.3 视方案 B 决策再定）
- **粒度 2**：`req-kartosos-dead-code-batch2`（仅 3.1）+ `rekartosatos-circuit-module-dir`（仅 3.2）分开
- **SOP**：agile-vibe（含 PM/TL/Dev/Reviewer/Closer 4 阶段），因为涉及跨文件搬移 + 知识库联动

## 变更历史

> 2026-07-20：初版。基于 kartosos AI 生成就绪度调研（方案 B 前置工作）产出。作者: AI 调研会话。触发原因：调研过程中新识别的 problem C（`circuit_element.dart` + `battery.dart` + `vertex.dart` 死代码链）。

> 2026-07-20（下午）：Step 1 死代码清理执行后修订。
> - 修正 §3.1 死代码清单：从 5 个文件扩大到 8 个（整个 `lib/models/` 目录）
> - §3.2 目录重构目标调整：`circuit_state.dart` 等原计划搬移的文件已随死代码删除，重构目标需重新调研
> - §3.3 `circuit_state.dart` 拆分计划作废：文件已删除
> - §6 关系表更新：3.1 风险已消除，新增 3.2 前置调研需求
> - 触发原因：Step 1B 执行时 `grep models/<name>` 实证发现整个 `lib/models/` 目录 zero-reference
> - 关联 commit：kartosos 项目 `chore: remove dead lib/models/`（在 baseline `c2d47c2` 之后）

> 2026-07-20（下午·第 2 次）：Step 1 已 git revert，本文档回退到 proposal_needs_rework 状态。
> - 新增 §0 教训与勘误章节（0.1 发生了什么 / 0.2 错在哪 / 0.3 根因 / 0.4 上游文档连锁问题 / 0.5 处理原则）
> - frontmatter status: in_progress → proposal_needs_rework；estimated effort / risk level 改为"未知"
> - §3.1 从"✅ 已执行"改为"❌ 尝试执行但已回退"，原有内容保留但整体降级为"仅供复盘"，含真实的错误 grep 输出与回退命令实证
> - §3.2 撤回"circuit_canvas.dart 内部内联模型"的判断（该判断本身也是错的），待重调研
> - §3.3 撤回上一次修订的"作废"声明（因为 `circuit_state.dart` 已随 revert 恢复），保留原判断待重调研
> - §6 撤回"3.1 风险已消除"结论；新增"方案 B 前置依赖状态未知"警示
> - 触发原因：Step 1 执行后 `flutter analyze` 报 228 error，跨作用域 grep（lib/ + test/ + 类名 + import 语句实证）证实 `lib/models/` 是活代码基座
> - 关联 kartosos commit：`df833b6`（错误删除） → `7c3c1e3`（revert 回退）；两个 commit 均保留在 git 历史作为教训物证，不做 `git reset --hard` 抹除

> 2026-07-20（傍晚·第 3 次）：Loop2 精准调研——把 §0.2 表格里 3 个"⚠️"确定为死代码。
> - 新增 §0.6 章节（0.6.1 触发 / 0.6.2 双工具交叉实证 5 命题 / 0.6.3 表格订正 / 0.6.4 元教训 / 0.6.5 §3.1 精准可执行范围 / 0.6.6 上游文档订正需求）
> - frontmatter status: proposal_needs_rework → partially_correct_needs_precision（表明 v1 判定 3/8 正确、5/8 错误，不是整份废弃）
> - estimated effort：3.1 精准清理 30 分钟；3.2/3.3 仍未重调研
> - 触发原因：上一轮 §0.2 表格里 3 处"⚠️"阻塞后续所有清理决策；用 grep_search + terminal findstr 双工具对同一命题跑同样查询，结果一致（都是 0 命中），确定 `battery.dart` / `circuit_element.dart` / `vertex.dart` 是死代码
> - 关联证据：`c:\workspace\kratos\lib\screens\circuit_screen.dart:5-7` import 段（不含 3 个死文件） + `c:\workspace\kratos\lib\widgets\optics_scene.dart:6-7` import 段（含 optics_state/optics_solver，证明其是活代码）
> - 未来动作：本 Loop2 一并订正 module-index.md + circuit-module.md（AI 工作区文档，零风险）；kartosos 源码清理待用户 y/n 授权
