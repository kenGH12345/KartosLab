# COMPASS PAINTER DEPENDENCY AUDIT

> 生成日期：2026-08-31
> 阶段：**READ-ONLY** · 未修改任何文件
> 依据：`MAGNET_MIGRATION_FINAL_PLAN.md` + 用户 7 项指令
> 证据级别：`[已确认]` = 工具调用实证 · `[推测]` = 标注推测依据 · `[待确认]` = 需用户拍板

---

## 1. CompassPainter 完整职责

### 源代码位置

`simulations/magnet_and_compass.dart:793-867`

### 完整实现

```dart
class CompassPainter extends CustomPainter {
  final double needleAngle;
  const CompassPainter({required this.needleAngle});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 外圆环（径向渐变深灰背景）
    // 2. 描边圆环（0xff555555, strokeWidth=6.0）
    // 3. 内圆（0xff1e1e1e）
    // 4. 内描边（0xff444444, strokeWidth=2.0）
    // 5. 72 个刻度线（每 5°一根，主刻度/中刻度/小刻度三级）
    // 6. canvas.save + translate + rotate(needleAngle)
    // 7. 白色指针（菱形，线性渐变）
    // 8. 红色指针（菱形，线性渐变）
    // 9. canvas.restore
    // 10. 中心轴帽（径向渐变 + 白点）
  }

  @override
  bool shouldRepaint(CompassPainter o) => o.needleAngle != needleAngle;
}
```

### 输入参数

| 参数 | 类型 | 来源 | 说明 |
|---|---|---|---|
| `needleAngle` | `double` | 调用方传入 | 指针旋转角度（弧度） |

**仅一个参数**。无其他依赖。

### 使用的数据

- `dart:math`：`min` · `pi` · `cos` · `sin`（标准库）
- `flutter/material`：`CustomPainter` · `Canvas` · `Size` · `Offset` · `Paint` · `Path` · `RadialGradient` · `LinearGradient` · `Color` · `Colors` · `PaintingStyle` · `StrokeCap` · `Alignment` · `Rect`（Flutter 框架）

### 依赖检查

| 依赖项 | 是否依赖 | 证据 |
|---|---|---|
| 通用几何（`dart:math`） | ✅ 是 | `:801` `min(cx, cy)` · `:816` `i * pi / 36` · `:821` `cos(a)` `sin(a)` |
| Flutter 框架 | ✅ 是 | `CustomPainter` / `Canvas` / `Paint` 等 |
| **Magnet-specific State** | ❌ 否 | `CompassPainter` 不引用 `SimState` / `MagnetState` · 不引用 `magnetPos` / `strength` / `flipped` 等任何 magnet 字段 |
| **Magnet-specific constants** | ❌ 否 | 不引用 `_magnetW` / `_magnetH` / `_earthR` / `_compassR` 等常量 |
| **assets** | ❌ 否 | 不引用 `earth.svg` 或任何 asset |
| **magnetic field** | ❌ 否 | 不引用 `MagneticField` / `compute()` · 不计算磁场 |
| **MagneticField 类** | ❌ 否 | 无任何 import 或类引用 |
| **SimState / MagnetState** | ❌ 否 | 无任何引用 |

### 是否能独立作为通用 widget/painter

**✅ 是**。`CompassPainter` 是一个纯粹的**罗盘表盘 + 指针绘制器**：

1. 输入仅一个 `needleAngle`（角度）
2. 不依赖任何 magnet 语义
3. 不依赖任何 magnet state
4. 不依赖任何 magnet 常量
5. 不依赖任何 asset
6. 不依赖任何物理计算
7. 所有绘制逻辑自包含在 `paint()` 方法内

它的语义是：**给定一个角度，画一个罗盘**。与 magnet 的唯一联系是**调用方**传入的角度恰好来自 magnet 的 state。

---

## 2. 消费者分析

### 全工程 CompassPainter 引用

`search_content` grep `CompassPainter`（case-sensitive）结果：

| # | Consumer | Path | 行号 | 用途 | 是否依赖 Magnet 语义 |
|---|---|---|---|---|---|
| 1 | **magnet B 自身** | `simulations/magnet_and_compass.dart` | `:447` `CompassPainter(needleAngle: _state.compassAngle)` | 罗盘指针绘制 | ✅ 是（`_state.compassAngle` 来自 `SimState`） |
| 2 | **magnet B 定义** | `simulations/magnet_and_compass.dart` | `:793` `class CompassPainter` | 类定义 | — |
| 3 | **electromagnet** | `simulations/electromagnet_page.dart` | `:10` `import 'magnet_and_compass.dart' show CompassPainter;` | import | — |
| 4 | **electromagnet** | `simulations/electromagnet_page.dart` | `:463` `CompassPainter(needleAngle: _state.compassAngle)` | 罗盘指针绘制 | ❌ 否（`_state` 是 `ElectromagnetState` · 非 magnet state · 但字段名恰好也叫 `compassAngle`） |

### Transformer 的 _CompassPainter 是独立实现

[已确认] `simulations/transformer_page.dart:45-80` 有自己的 `_CompassPainter`（private），**不引用** B 的 `CompassPainter`：

| 维度 | B `CompassPainter` | transformer `_CompassPainter` |
|---|---|---|
| 可见性 | public | private |
| 参数名 | `needleAngle` | `angle` |
| 尺寸 | 自适应 `size.width/2` | 自适应 `size.width/2` |
| 刻度 | 72 根（每 5°） | 8 根（每 45°） |
| 指针 | 菱形 + 线性渐变 + 红白双针 | 线段 + 红白双色线 |
| 中心轴帽 | 径向渐变圆 + 白点 | 黑色小圆点 |
| 视觉风格 | 精密罗盘 | 简化指南针 |

**transformer 不依赖 B 的 CompassPainter**。它有自己独立的简化版。

### 消费者总结

| 消费者 | 是否实际依赖 B 的 CompassPainter | 当前状态 |
|---|---|---|
| magnet B | ✅ 是 | 正常 |
| electromagnet | ✅ 是 | 🔴 BLOCKED（`electromagnet_model.dart` 不存在 · 无法编译） |
| transformer | ❌ 否（有自己的 `_CompassPainter`） | 正常 |

**实际消费者 = 2 个**（magnet + electromagnet）。

---

## 3. 三种方案比较

### 方案 A：Electromagnet 继续依赖 Magnet CompassPainter

**操作**：迁移 magnet 后，`electromagnet_page.dart:10` 的 import 改为指向新路径：
```dart
import '../magnetism/magnet_and_compass/painters/compass_painter.dart';
```

| 维度 | 评估 |
|---|---|
| 耦合 | 🟡 中 · electromagnet → magnet 单向依赖 |
| 重复代码 | ✅ 无 · 只有一份 CompassPainter |
| 当前工程规范 | 🟡 不符 · KARTOSLAB sim 之间应无横向依赖 · 已有 sim（sound/optics/forces 等）无跨 sim import |
| 后续维护 | 🟡 中 · 改 magnet 的 CompassPainter 会影响 electromagnet |
| 对已有 sim 的影响 | ✅ 无 |
| 最小迁移成本 | ✅ 最低 · 只改 1 行 import 路径 |

**风险**：如果未来 magnet 的 `CompassPainter` 为了 magnet 需求改动（如加刻度、改配色），会影响 electromagnet 的视觉。但 electromagnet 当前 BLOCKED，短期无影响。

---

### 方案 B：CompassPainter → `lib/common/`

**操作**：将 `CompassPainter` 提取到 `lib/common/painters/compass_painter.dart`（或 `lib/common/widgets/`），magnet 和 electromagnet 都从 common 引用。

| 维度 | 评估 |
|---|---|
| 耦合 | ✅ 低 · 两个 sim 都依赖 common · 无横向依赖 |
| 重复代码 | ✅ 无 · 只有一份 |
| 当前工程规范 | ✅ 符合 · common 是共享组件层 |
| 后续维护 | ✅ 好 · 改一处影响所有消费者 |
| 对已有 sim 的影响 | ✅ 无（magnet 迁移时引用 common · 不影响其他 sim） |
| 最小迁移成本 | 🟡 中 · 需创建 common 文件 + magnet 迁移时引用 common + 修复 electromagnet import |

**风险**：过早抽象。当前只有 2 个消费者，且其中 1 个（electromagnet）已 BLOCKED。如果未来 electromagnet 被废弃，CompassPainter 只剩 1 个消费者，common 层出现冗余。

---

### 方案 C：Electromagnet 建立自己的 CompassPainter

**操作**：electromagnet 不再依赖 magnet 的 CompassPainter，而是在 `simulations/electromagnet_painter.dart`（或迁移后的路径）内创建自己的 `ElectromagnetCompassPainter`。

| 维度 | 评估 |
|---|---|
| 耦合 | ✅ 无 · 两个 sim 完全独立 |
| 重复代码 | 🔴 有 · 两份 CompassPainter（可能逐行相同） |
| 当前工程规范 | 🟡 不符 · 触发 "3-Time Rule"（已有 magnet B + transformer `_CompassPainter` + electromagnet 新建 = 3 份） |
| 后续维护 | 🔴 差 · 改一处需同步改另两处 |
| 对已有 sim 的影响 | ✅ 无 |
| 最小迁移成本 | 🔴 高 · 需复制一份 CompassPainter 到 electromagnet |

**风险**：重复代码。transformer 已有自己的 `_CompassPainter`（第 3 份），再加 electromagnet 的新建就是第 4 份。

---

### 三方案对比矩阵

| 维度 | 方案 A（继续依赖） | 方案 B（抽 common） | 方案 C（各自独立） |
|---|---|---|---|
| 横向耦合 | 🟡 中 | ✅ 无 | ✅ 无 |
| 重复代码 | ✅ 无 | ✅ 无 | 🔴 有 |
| 工程规范 | 🟡 不符 | ✅ 符合 | 🔴 触发 3-Time Rule |
| 维护性 | 🟡 中 | ✅ 好 | 🔴 差 |
| 迁移成本 | ✅ 最低 | 🟡 中 | 🔴 最高 |
| 对已有 sim 影响 | ✅ 无 | ✅ 无 | ✅ 无 |

---

## 4. 是否应该抽到 common

### "公共组件"条件检查

| 条件 | CompassPainter 是否满足 | 说明 |
|---|---|---|
| 至少 2 个消费者 | ✅ 是 | magnet + electromagnet |
| 语义通用 | ✅ 是 | "给定角度画罗盘" · 无 domain 语义 |
| 无 domain-specific 依赖 | ✅ 是 | 不依赖 magnet state / 常量 / asset / 物理计算 |
| 接口稳定 | ✅ 是 | 仅 1 个参数 `needleAngle` |
| 消费者都活跃 | ❌ **否** | electromagnet 当前 BLOCKED · 无法编译 · 无法验证 |
| 消费者数量会增长 | [推测] 不会 | 工程内只有 magnet / electromagnet / transformer 用罗盘 · transformer 已有自己的简化版 |

### 关键判断

**不满足"消费者都活跃"条件**。

electromagnet 当前 BLOCKED（`electromagnet_model.dart` 全工程不存在）。一个无法编译的消费者不能作为"公共组件"的有效消费者。

当前**实际活跃消费者 = 1 个**（magnet B 自身）。

### 结论

**不应在此刻抽到 common**。

理由：

1. **只有一个活跃消费者**——magnet B 自身。electromagnet BLOCKED，不能算有效消费者
2. **过早抽象风险**——如果 electromagnet 最终被废弃（[待确认] 用户决定），common 层会出现只有 1 个消费者的冗余组件
3. **transformer 已选择独立实现**——transformer 有自己的 `_CompassPainter`，说明工程内已有"各自独立"的先例
4. **当前工程无 `lib/common/painters/` 目录**——[已确认] `list_dir lib/common/` 只有 `simulation_clock.dart` · 无 painters/ 目录 · 抽 CompassPainter 需新建目录结构

**如果未来 electromagnet 解除 BLOCKED 并确认保留**，再评估是否抽 common。

---

## 5. 推荐方案

### 方案 A · Electromagnet 继续依赖 Magnet CompassPainter

**但标记为临时方案**。

### 推荐理由

| 理由 | 说明 |
|---|---|
| 最小迁移成本 | 只改 1 行 import 路径 |
| electromagnet 已 BLOCKED | 无法编译 · 改 import 不影响任何运行时行为 |
| 不过早抽象 | 符合用户指令 §4"不允许提前抽 common" |
| 保持 electromagnet BLOCKED | 符合用户指令 §5"Electromagnet 不得因此解 BLOCKED" |
| 可逆 | 未来 electromagnet 决策明确后可再调整 |

### 迁移时的具体 import 处理方式

**步骤 1**：magnet 迁移时，`CompassPainter` 随 magnet 一起迁移到：
```
lib/magnetism/magnet_and_compass/painters/compass_painter.dart
```

**步骤 2**：修复 `simulations/electromagnet_page.dart:10` 的 import：

| 项 | 当前 | 迁移后 |
|---|---|---|
| 行号 | `:10` | `:10` |
| 当前代码 | `import 'magnet_and_compass.dart' show CompassPainter;` | — |
| 迁移后代码 | — | `import '../magnetism/magnet_and_compass/painters/compass_painter.dart';` |

**步骤 3**：electromagnet 的其他代码**不动**。`electromagnet_model.dart` 仍然缺失 · electromagnet 仍然 BLOCKED。

**注意**：由于 electromagnet 当前因 `electromagnet_model.dart` 缺失已无法编译，修复 import 路径不会改变其 BLOCKED 状态——它只是让 import 指向正确的新路径，以便未来解除 BLOCKED 时不需要再找。

---

## 6. 风险

| 风险 | 等级 | 原因 | 缓解 |
|---|---|---|---|
| 横向依赖 | 🟡 中 | electromagnet → magnet 单向依赖 | 标记为临时方案 · 待 electromagnet 决策后调整 |
| 过早抽象 | ✅ 已避免 | 不抽 common | — |
| 重复代码 | ✅ 无 | 只有一份 CompassPainter | — |
| 3-Time Rule | 🟢 低 | transformer 有自己的 `_CompassPainter` · 但这是独立实现 · 不算重复 | 如未来统一需评估 |
| electromagnet 仍 BLOCKED | ✅ 预期 | `electromagnet_model.dart` 仍缺失 | 符合用户指令 §5 |
| import 路径错误 | 🟡 低 | 迁移时可能写错相对路径 | 迁移后 `flutter analyze` 验证 |

---

## 7. [已确认]

| # | 项 | 证据 |
|---|---|---|
| 1 | CompassPainter 位于 `:793-867` | `read_file` 完整读取 |
| 2 | 仅 1 个参数 `needleAngle` | `:794` `final double needleAngle` |
| 3 | 不依赖 Magnet-specific State | 全文无 `SimState` / `MagnetState` 引用 |
| 4 | 不依赖 Magnet-specific constants | 不引用 `_magnetW` / `_magnetH` / `_earthR` / `_compassR` |
| 5 | 不依赖 assets | 不引用 `earth.svg` 或任何 asset |
| 6 | 不依赖 magnetic field | 不引用 `MagneticField` / `compute()` |
| 7 | 仅依赖 `dart:math` + `flutter/material` | `:4-5` import · `:801` `min` · `:816` `pi` · `:821` `cos` `sin` |
| 8 | 能独立作为通用 painter | 输入仅 1 个角度 · 无 domain 依赖 |
| 9 | 全工程 2 个实际消费者 | magnet B `:447` + electromagnet `:463` |
| 10 | transformer 有自己的 `_CompassPainter` | `transformer_page.dart:45-80` · 不引用 B 的 CompassPainter |
| 11 | transformer `_CompassPainter` 是简化版 | 8 刻度 vs 72 刻度 · 线段指针 vs 菱形指针 |
| 12 | electromagnet BLOCKED | `electromagnet_model.dart` 全工程不存在（`MAGNET_MIGRATION_FINAL_PLAN.md` [已确认] #24） |
| 13 | 当前工程无 `lib/common/painters/` 目录 | `list_dir lib/common/` 只有 `simulation_clock.dart` |
| 14 | `CompassPainter` 是 public class | `:793` `class CompassPainter`（无下划线前缀） |
| 15 | electromagnet 使用方式与 magnet 相同 | 两处都是 `CompassPainter(needleAngle: _state.compassAngle)` |

---

## 8. [推测]

| # | 项 | 推测依据 |
|---|---|---|
| 1 | 未来不会有新的 CompassPainter 消费者 | 工程内只有 magnet / electromagnet / transformer 用罗盘 · transformer 已独立 |
| 2 | 如果 electromagnet 最终被废弃 · CompassPainter 只剩 1 个消费者 | electromagnet 当前 BLOCKED · 无修复计划 |
| 3 | transformer 选择独立实现是因为视觉风格不同 | transformer 的 `_CompassPainter` 是简化版 · 刻度/指针/配色都不同 |

---

## 9. [待确认]

| # | 问题 | 选项 | 推荐 |
|---|---|---|---|
| 1 | 迁移时采用方案 A（继续依赖）还是方案 B（抽 common）？ | A=继续依赖 · B=抽 common · C=各自独立 | A（临时） |
| 2 | 如果未来 electromagnet 解除 BLOCKED · 是否重新评估抽 common？ | A=重新评估 · B=保持方案 A | A |
| 3 | transformer 的 `_CompassPainter` 是否应该统一？ | A=统一为 B 版 · B=保持独立 · C=抽 common | B（视觉不同 · 不应统一） |

---

## 完成声明

- 本文档基于 READ-ONLY 全文阅读 + 全工程 grep · **未修改任何文件**
- 所有 `[已确认]` 项均有工具调用实证（15 项）
- 所有 `[推测]` 项已标注推测依据（3 项）
- 所有 `[待确认]` 项已列出选项（3 项）
- CompassPainter 依赖审计完毕 · **不执行任何文件操作** · 完成后停止
