# MAGNET MIGRATION M2

> 阶段：**Dependency / Import / Asset Repair**
> 日期：2026-08-31
> 前置：M1 已完成（target = `lib/magnetism/magnet_and_compass/`）
> 证据级别：`[已确认]` = 工具调用实证 · `[推测]` = 标注推测依据 · `[待确认]` = 需用户拍板

本阶段允许修改：target Magnet 文件、明确依赖 Magnet 的 import、Magnet 相关 asset 引用、必要 barrel/export。

本阶段禁止：Home / NineGrid / Theme / Visual QA / Electromagnet 业务修复 / Transformer / common 重构 / 删除 Legacy / 新建测试 / 生成 `earth.svg` 替代品。

---

## 1. Legacy 引用

全工程 Dart `import` 搜索（`magnet_and_compass` / `magnet_and_compass.dart` / `SimState` / `CompassPainter` / `BarMagnetPainter`）：

**没有任何 Dart 文件 `import` `simulations/magnet_and_compass.dart`。** Runtime consumer = **0**。

| Legacy Symbol / Path | Consumer | 当前状态 | Target Path | Action |
|---|---|---|---|---|
| `simulations/magnet_and_compass.dart`（整文件） | 无 Dart import | 孤立遗留 · 暂不删除 | `lib/magnetism/magnet_and_compass/`（12 文件） | **keep**（M2 不删） |
| `SimState` | 仅 Legacy B 内部 + A `phet/magnet_and_compass/lib/main.dart` | 无 app runtime consumer | `model/magnet_state.dart` → `MagnetState` | 无需改 import |
| `MagnetAndCompassPage` | 无 | 无 consumer | `screens/magnet_and_compass_screen.dart` → `MagnetAndCompassScreen` | 无需改 import |
| `MagneticField`（B 版 · k=strength×18000） | 仅 Legacy B 内部 | 无外部 Dart import | `model/magnetic_field.dart` | 无需改 import · **禁止**与 `phet/widgets/physics/magnetism/magnetic_field.dart` 合并 |
| `CompassPainter`（B） | 原 `simulations/electromagnet_page.dart` | **已指向 target** | `painters/compass_painter.dart` | M1 已改路径；M2 将 `../lib/...` 改为 `package:kratos/...` |
| `BarMagnetPainter` | 仅 B / A / target 内部 | 无外部 consumer | `painters/bar_magnet_painter.dart` | 无需改 import |
| `FieldNeedlePainter` | 仅 B / A / target 内部 | 无外部 consumer | `painters/field_needle_painter.dart` | 无需改 import |
| `_EarthGlowPainter` | 仅 B / A 内部 | target 已公开为 `EarthGlowPainter` | `painters/earth_glow_painter.dart` | 无需改 import |
| `_VerticalMagnetPainter` | 仅 B / A 内部 | target 已公开为 `VerticalMagnetPainter` | `painters/vertical_magnet_painter.dart` | 无需改 import |
| `_ControlPanel` | 仅 B / A 内部 | target 已公开为 `MagnetControlPanel` | `widgets/control_panel.dart` | 无需改 import |
| `_MiniCompassPreviewPainter` | 仅 B / A 内部 | target 已公开 | `widgets/mini_compass_preview_painter.dart` | 无需改 import |
| `phet/magnet_and_compass/`（A） | 无 `lib/` import | 保持不动 | — | **untouched** |
| `phet/widgets/visualization/compass.dart` `CompassPainter` | phet 内部 | 另一套实现 | — | **不迁移** |
| `simulations/transformer_page.dart` `_CompassPainter` | Transformer 自有 | 不依赖 B | — | **不修改** |

注释中出现的 `simulations/magnet_and_compass.dart` 仅为 target 文件的抽取溯源注释，不是 import。

`lib/screens/`（含 Home）**零** Magnet / Electromagnet 引用。[已确认]

---

## 2. 修复的 imports

本阶段实际改动 **1 处**（Electromagnet 的 CompassPainter 路径规范化）：

| 文件 | 旧 | 新 | 原因 |
|---|---|---|---|
| `simulations/electromagnet_page.dart:10` | `import '../lib/magnetism/magnet_and_compass/painters/compass_painter.dart' show CompassPainter;` | `import 'package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart' show CompassPainter;` | 消除 `simulations/` → `lib/` 跨越式相对路径；目标仍是 target CompassPainter |
| 同文件顶部注释 | `from magnet_and_compass.dart` | `from the migrated Magnet & Compass target` | 注释不再指向 Legacy |

**未改**：target 内部 12 个文件的 import（已干净）。**未创建** barrel。**未改** `pubspec.yaml`。

---

## 3. Target dependency graph

Target 12 文件全部只引用：**同目录相对路径 / Flutter SDK / `flutter_svg`**。

不依赖 `simulations/magnet_and_compass.dart`。不引用 `lib/common/`。无 `../` 跳出 `magnet_and_compass/` 包根以外（`screens/` / `widgets/` / `painters/` 的 `../` 均停在 sim 根）。无 duplicate implementation 引入（B/A 遗留副本仍在磁盘，但不被 target import）。

```
magnet_and_compass_constants.dart
  └── (no imports)

model/magnet_state.dart
  └── package:flutter/material.dart

model/magnetic_field.dart
  └── dart:math
  └── package:flutter/material.dart

painters/bar_magnet_painter.dart
  └── package:flutter/material.dart

painters/vertical_magnet_painter.dart
  └── package:flutter/material.dart

painters/earth_glow_painter.dart
  └── dart:math
  └── package:flutter/material.dart

painters/compass_painter.dart
  └── dart:math
  └── package:flutter/material.dart

painters/field_needle_painter.dart
  └── dart:math
  └── package:flutter/material.dart
  └── ../model/magnetic_field.dart

widgets/mini_compass_preview_painter.dart
  └── dart:math
  └── package:flutter/material.dart

widgets/control_panel.dart
  └── package:flutter/material.dart
  └── ../model/magnet_state.dart
  └── mini_compass_preview_painter.dart

widgets/field_meter.dart
  └── dart:math
  └── package:flutter/material.dart
  └── ../model/magnetic_field.dart
  └── ../model/magnet_state.dart
  └── ../magnet_and_compass_constants.dart

screens/magnet_and_compass_screen.dart
  └── dart:math
  └── package:flutter/material.dart
  └── package:flutter_svg/flutter_svg.dart
  └── ../magnet_and_compass_constants.dart
  └── ../model/magnetic_field.dart
  └── ../model/magnet_state.dart
  └── ../painters/bar_magnet_painter.dart
  └── ../painters/compass_painter.dart
  └── ../painters/earth_glow_painter.dart
  └── ../painters/field_needle_painter.dart
  └── ../painters/vertical_magnet_painter.dart
  └── ../widgets/control_panel.dart
  └── ../widgets/field_meter.dart
```

**Inbound（target 之外指向 target）**：

```
simulations/electromagnet_page.dart
  └── package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart
      show CompassPainter
```

`MagnetAndCompassScreen` 目前 **0 个 app consumer**（Home 未接入，符合 M2 范围）。

---

## 4. Asset 审计

| 项 | 结果 |
|---|---|
| Magnet 引用的资源字符串 | 仅 `assets/earth.svg` |
| 其它图片 / 字体 / 音效 | 无 |
| `assets/` 目录现存 SVG | battery / bulb / drop / fuse / lens_* / ground / mirror / resistor / pencil / ruler / wire / switch_* · **无 earth** |
| 同名资源（earth.png / Earth.svg 等） | **0**（全仓库 glob `*[Ee]arth*` 仅命中 `earth_glow_painter.dart`） |
| backup / archive 中的 earth 资源 | **0** |
| `pubspec.yaml` assets 声明 | `assets/images/` · `sounds/` · `data/` · `scenarios/` · **无** `earth.svg` · **无** 根 `assets/` 条目 |
| `flutter_svg` 依赖 | 已有 `flutter_svg: ^2.3.0` · 无需为本资源改 pubspec |

---

## 5. earth.svg 状态

**BLOCKED: missing earth.svg**

禁止事项均未执行：未自绘 SVG、未下载地球图、未从截图重画、未修改 Earth 逻辑绕过资源。

| 引用点 | 路径 | 是否存在文件 |
|---|---|---|
| Target `_buildEarth()` | `lib/magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart` ≈288 | 否 |
| Legacy B `_buildEarth()` | `simulations/magnet_and_compass.dart` ≈404 | 否 |
| Legacy A `_buildEarth()` | `phet/magnet_and_compass/lib/main.dart` ≈542 | 否 |

**触发路径（target）**：

1. `MagnetControlPanel` 勾选 `Earth` → `onEarthFieldChanged`
2. `_state.earthField = true`
3. Screen build：`if (_state.earthField) _buildEarth(size)`
4. `SvgPicture.asset('assets/earth.svg')` → 运行时找不到资源会失败

默认 `earthField: false`，未勾选 Earth 时不走该路径。

Target **仍需要**该资源（Earth 模式的地球贴图）。A 与 B 同样缺失，仓库内无原始文件可注册。

---

## 6. pubspec 是否修改

**否。未修改 `pubspec.yaml`。**

原因：没有可注册的 Magnet 原始资源。`earth.svg` 不存在，不能为缺失文件添加 assets 条目。

---

## 7. Barrel / export

| 检查项 | 结果 |
|---|---|
| 旧 `magnet_and_compass.dart` barrel | **不存在**。唯一同名文件是 Legacy 源 `simulations/magnet_and_compass.dart`（整文件实现，不是 export barrel） |
| `lib/` 下 Magnet export | **无**（`lib/` grep `^export` = 0） |
| `phet/phet.dart` 的 magnetism export | 导出的是 `phet/widgets/physics/magnetism/*`（另一套）· 与本 sim 无关 · 未改 |
| target 是否需要 barrel | **否**。外部消费者只有 1 个（Electromagnet → `CompassPainter`），直接 import 即可 |

**未创建** target barrel。

---

## 8. Electromagnet 状态

**BLOCKED**（保持）

| 项 | 状态 |
|---|---|
| CompassPainter import | 已指向 target · `package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart` |
| `electromagnet_model.dart` | **仍不存在** · 未创建 |
| `ElectromagnetState` | 未创建 |
| `ElectromagnetPainter` | 未修改 |
| `ElectromagnetPage` 业务 | 未修复（仅 import + 注释） |
| Home 接入 | 未做 |

`flutter analyze` 中 Electromagnet 相关 error 全部来自缺失 Model（见 §9），**不是** CompassPainter URI 错误。

---

## 9. Analyze

### Target（允许作为 migration 健康指标）

```
flutter analyze lib/magnetism/magnet_and_compass
→ No issues found! (ran in 1.9s)
```

**Magnet migration analyzer error = 0。**

### 全工程 `flutter analyze`

`380 issues`（370 error + 10 info · 0 warning）

| 分类 | 数量（约） | 判定 | M2 是否修复 |
|---|---|---|---|
| **Magnet migration** | **0** | target 路径零命中 · CompassPainter URI 无 error | 无需修 |
| **Electromagnet**（`electromagnet_model.dart` 缺失及连锁） | 26 error | Pre-existing · `uri_does_not_exist` / `ElectromagnetState` / `ElectromagnetField` 等 | **禁止修** |
| **Transformer** `private-named-parameters` | 1 error | Pre-existing · `simulations/transformer_model.dart:268` | **禁止修** |
| **phet/quantum_***（coin toss / measurement 残缺） | 343 error | Pre-existing project issue | **禁止修** |
| **info**（circuit curly braces · knowledge_panel · netforce deprecated · phet radio/graph） | 10 info | Pre-existing | 不修 |

Electromagnet CompassPainter 的 `package:kratos/.../compass_painter.dart` **未**出现在 analyzer error 列表中。[已确认]

---

## 10. Debug build

命令：`flutter build apk --debug`

**结果：失败**（Gradle `assembleDebug` · 31.8s · exit code 1）

失败点：

```
:integration_test:compileDebugJavaWithJavac
Could not resolve androidx.test:runner:1.2+
Unable to load Maven meta-data from
  https://storage.flutter-io.cn/download.flutter.io/androidx/test/runner/maven-metadata.xml
Could not GET ... 不知道这样的主机。 (storage.flutter-io.cn)
```

| 分类 | 是否本失败原因 |
|---|---|
| Magnet migration issue | **否**。失败发生在 `integration_test` 的 Maven 解析，早于 Dart/Flutter 资源打包。`lib/main.dart` 不 import Magnet。 |
| Pre-existing project issue | **是**。Flutter 中国镜像主机 `storage.flutter-io.cn` DNS 失败 + `integration_test` 拉 `androidx.test:runner`。另有 Kotlin Gradle Plugin deprecation warning（非本次失败主因）。 |
| Missing asset | **否**。未进入 asset bundling。`earth.svg` 缺失不会以本次 Gradle 错误形式出现。 |
| Electromagnet issue | **否**。`ElectromagnetPage` 不在 `lib/main.dart` 编译图中。 |

M2 **未**为通过 build 而改 Gradle / 镜像 / `integration_test` / `pubspec`。

---

## 11. [已确认]

1. Runtime Dart 对 Legacy `simulations/magnet_and_compass.dart` 的 import consumer = **0**。
2. Target 12 文件 import graph 只含 target 内部相对路径 + Flutter + `flutter_svg`。
3. Electromagnet `CompassPainter` 已指向 target（`package:kratos/.../compass_painter.dart`）。
4. 全仓库不存在 `earth.svg` 文件；A / B / target 三处字符串引用；`pubspec` 未声明。
5. `flutter analyze lib/magnetism/magnet_and_compass` → 0 issue。
6. 全工程 analyze 中 **0** 条 Magnet migration error。
7. Home 未引用 Magnet / Electromagnet。
8. 未创建 barrel；未改 `pubspec.yaml`；未删 Legacy；未生成 earth 替代资源；未修 Electromagnet Model。
9. Debug APK 因既有 Gradle/镜像网络问题失败，与 Magnet 迁移无关。

---

## 12. [推测]

1. `earth.svg` 来自 PhET 原版外部 asset，从未进入本仓库（A 同样引用却无文件）。
2. 默认 `earthField: false`，用户未勾选 Earth 时 Magnet 不会因缺 SVG 立刻崩溃。
3. Debug APK 在可解析 `storage.flutter-io.cn`（或改用官方/可访问 Maven）的环境下，Magnet 迁移本身不会阻止 `assembleDebug`（Magnet 尚未挂 Home，不在 entrypoint 图中）。

---

## 13. [待确认]

1. `earth.svg` 来源：用户是否能提供 PhET 原版文件？（M2 明确禁止自制替代）
2. 提供后放置路径与 pubspec 注册（属后续阶段，非 M2）。
3. Home 挂载 `MagnetAndCompassScreen` 的时机（明确不在 M2）。
4. Legacy `simulations/magnet_and_compass.dart` 删除时机（明确不在 M2）。
5. Electromagnet Model 修复时机（明确不在 M2 · 保持 BLOCKED）。

---

## 完成条件核对

| # | 条件 | 结果 |
|---|---|---|
| 1 | Runtime 不再依赖 Legacy Magnet source | **满足** · 0 Dart import |
| 2 | Target import graph 干净 | **满足** |
| 3 | Electromagnet CompassPainter → target | **满足** |
| 4 | `earth.svg` 状态明确 | **满足** · `BLOCKED: missing earth.svg` |
| 5 | 不产生新的 migration analyzer error | **满足** · target 0 issue |
| 6 | Debug APK build 结果明确 | **满足**（已执行并分类）· 失败原因 = 既有 Gradle/镜像，非 Magnet |

M2 到此停止。未删除 Legacy、未接 Home、未建测试、未改 NineGrid、未做 Visual QA、未修 Electromagnet 业务、未修 Transformer。
