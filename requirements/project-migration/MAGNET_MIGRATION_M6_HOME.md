# MAGNET M6 · Home Integration

> 日期：2026-08-31  
> 范围：**只接 Home → `MagnetAndCompassScreen` 导航**  
> 未改：MagnetState / MagneticField / CompassPainter / FieldMeter / ControlPanel / Reset / NineGrid / Theme / Earth / Electromagnet / Transformer / 视觉几何  
> 未删 Legacy

---

## 1. Home entry

`lib/screens/home_screen.dart` 现有结构未改：`_Discipline` → `_SubjectGroup` → `_SimEntry` → `Navigator.push(MaterialPageRoute(builder: …))`。

物理学科下，在「电学与电路」之后新增分组 **电磁学**（与 `MAGNET_MIGRATION_FINAL_PLAN` 一致）：

| 项 | 值 |
|---|---|
| Group | 电磁学 |
| title | **磁铁与罗盘**（与 AppBar 一致；Home 卡均为中文） |
| subtitle | 条形磁铁 · 磁场 · 罗盘 |
| icon | `Icons.explore_rounded` |
| color | `#1565C0`（与 sim AppBar 同色，未改全局 typography） |
| builder | `_buildMagnetAndCompass` |

未接 Electromagnet / Transformer。

实验计数由 `_totalSimCount` 自动 +1。

---

## 2. Route / builder

无命名路由表。与其它 sim 相同：

```dart
static Widget _buildMagnetAndCompass(BuildContext _) =>
    const MagnetAndCompassScreen();

Navigator.push(MaterialPageRoute<void>(builder: sim.builder));
```

每次 tap 调用 builder → **新的** `MagnetAndCompassScreen` → 新 State。无 singleton、无缓存。

未创建第二个 `MaterialApp`。宿主仍是 `KratosApp`。

从 Home push 后 `Navigator.canPop == true`，AppBar **自动出现返回箭头**（M4-2 已预期；sim 测试里 `home:` 直挂时没有 leading）。

---

## 3. Lifecycle

`MagnetAndCompassScreen` 本阶段未改。既有行为：

| 项 | 行为 |
|---|---|
| initState | 新 `MagnetState` 默认值 + `AnimationController.repeat` + listener `_tickCompass` |
| `_tickCompass` | `if (!mounted) return` |
| dispose | `_compassCtrl.dispose()` |
| Overlay | sim **未** `insert OverlayEntry`；仅 Navigator 自带 Overlay |
| 再进入 | 全新 State；strength 0.75、flipped false、Field Meter 关 |

Back：`pageBack` / AppBar leading → pop → State.dispose → ticker 停。

---

## 4. Navigation

```
HomeScreen
  → tap「磁铁与罗盘」
  → MagnetAndCompassScreen
  → Back
  → HomeScreen（卡片仍在）
  → 再 tap
  → 新 Screen / 默认状态
```

变异（Flip Polarity）在 pop 后丢弃；再进入 `flipped == false`、`75%`。

---

## 5. Tests

新增 `test/magnetism/magnet_home_nav_test.dart`：

| # | 覆盖 |
|---|---|
| 1 | Home 有「磁铁与罗盘」卡 +「电磁学」组 |
| 2 | 点击进入；AppBar 标题「磁铁与罗盘」 |
| 3 | Back 回到 Home |
| 4 | 离开后 `MagnetAndCompassScreen` 不在树；再 pump 2s 无异常（controller 已 dispose） |
| 5–6 | Flip 后 Back 再进入：新实例默认（未翻转、75%、无 Field Meter） |

罗盘 ticker 常开：**sim 在栈上不用 `pumpAndSettle`**。

| 命令 | 结果 |
|---|---|
| `flutter analyze lib/screens/home_screen.dart lib/magnetism/magnet_and_compass test/magnetism` | **No issues** |
| `flutter test test/magnetism` | **40/40**（原 36 + nav 4） |
| `flutter test test/chemistry/build_a_nucleus` | **407/407** |

---

## 6. Build

```
flutter build apk --debug
```

**成功**：`build/app/outputs/flutter-apk/app-debug.apk`（Gradle ~35s）。

---

## 7. Existing environment issues

- Flutter 资源镜像：`storage.flutter-io.cn`（本机既有配置）
- Gradle Kotlin 插件警告：`android/app/build.gradle.kts` 仍 `apply` Kotlin plugin，未来 Flutter 可能失败。指南：migrate to built-in Kotlin。**未改业务工程。**
- Earth：`BLOCKED: missing earth.svg`（未修）
- Electromagnet：仍 BLOCKED（未接 Home）

本次 **无** Gradle 网络失败。

---

## 8. 明确没做

- 未删 `simulations/magnet_and_compass.dart` / `phet/magnet_and_compass/`
- 未修 Earth / Electromagnet / Transformer
- 未改 sim 视觉与场公式
- 未开其他 Legacy 项目

---

## 停止

**M6 Home Integration 完成。**
