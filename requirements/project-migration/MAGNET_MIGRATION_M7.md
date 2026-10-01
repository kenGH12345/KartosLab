# MAGNET M7 · Legacy Archive

> 日期：2026-08-31  
> 动作：**移动** `simulations/magnet_and_compass.dart` → archive（不永久删除）  
> 未改：`lib/magnetism/magnet_and_compass/` · `phet/magnet_and_compass/` · Earth · Electromagnet · Transformer · UI / physics / State / Controller / Painter

Magnet Migration **正式结束**。状态：**MIGRATED / VERIFIED**

---

## 1. Paths

| | Path |
|---|---|
| Legacy（运行目录） | `simulations/magnet_and_compass.dart` · **已移走** |
| Archive（migration reference） | `requirements/project-migration/archive/magnet_and_compass.dart` |
| 正式 target | `lib/magnetism/magnet_and_compass/` |
| PhET reference（未动） | `phet/magnet_and_compass/` |
| Home | `lib/screens/home_screen.dart` → `MagnetAndCompassScreen` |

仓库原先无独立 `legacy/` 目录。按本阶段指定路径归档。

---

## 2. 0 runtime consumer 证据

对 `simulations/magnet_and_compass.dart` / `import 'magnet_and_compass.dart'`（相对 simulations）:

| 检查 | 结果 |
|---|---|
| Dart `import` | **0**。`lib/`、`test/` 均指向 `package:kratos/magnetism/...` |
| Dart `export` | **0** |
| Home / route | Home 只 import `MagnetAndCompassScreen` |
| test 依赖 | **0**。visual QA 对照的是 `phet/magnet_and_compass/lib/main.dart` |
| pubspec assets | **无** 该文件；`earth.svg` 仍缺失，且不由本归档文件提供 runtime |
| 包边界 | `simulations/` **不在** `lib/`；KratosApp 编译树不含该文件 |

`simulations/electromagnet_page.dart:10` 已是：

```dart
import 'package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart' show CompassPainter;
```

**不再** `import 'magnet_and_compass.dart' show CompassPainter`。Electromagnet 仍因 `electromagnet_model.dart` 缺失而 **BLOCKED**，与本归档无关。

`lib/magnetism/...` 内 `simulations/magnet_and_compass.dart` 字样仅为抽取溯源注释，不是 import。

---

## 3. Archive 原因

- 正式实现已在 `lib/magnetism/magnet_and_compass/`（M1–M6）
- Home 已接；视觉验收 M5-FINAL 通过
- Legacy B 与运行树脱钩；留在 `simulations/` 会造成「第三份 Magnet」误导
- **禁止永久 delete** → 整文件保留作 migration reference

未改文件内容（41467 bytes 原样移动）。

---

## 4. 保留的 reference

| 角色 | 路径 | 本阶段 |
|---|---|---|
| 迁移真源归档 | `requirements/project-migration/archive/magnet_and_compass.dart` | **移动至此** |
| 原版独立 app | `phet/magnet_and_compass/` | **未动** |
| 运行实现 | `lib/magnetism/magnet_and_compass/` | **未动** |

---

## 5. 当前阻塞项

| 项 | 状态 |
|---|---|
| Earth | **BLOCKED: missing earth.svg** |
| Electromagnet | **BLOCKED**（缺 model · 未接 Home） |
| Transformer | **BLOCKED**（未接 Home · 非本迁移） |

---

## 6. 回归

| 命令 | 结果 |
|---|---|
| `flutter analyze lib/magnetism/magnet_and_compass lib/screens/home_screen.dart test/magnetism` | **No issues** |
| `flutter analyze`（全仓） | **381 issues** · 既有 `phet/quantum_*` + `simulations/electromagnet_*` + transformer；**无** archive Magnet 新错误。未改这些 BLOCKED 树 |
| `flutter test test/magnetism` | **40/40** |
| `flutter test test/chemistry/build_a_nucleus` | **407/407** |
| `flutter build apk --debug` | **成功** `app-debug.apk` · Kotlin plugin 弃用警告（既有，未改工程） |

`LEGACY_MIGRATION_PLAN.md`：Magnet 标为 **MIGRATED / VERIFIED**。

---

## 停止

**M7 完成。Magnet Migration 结束。**

不删 PhET。不修 Earth / Electromagnet / Transformer。
