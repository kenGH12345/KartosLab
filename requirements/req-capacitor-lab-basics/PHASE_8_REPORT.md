# PHASE_8_REPORT — Home 注册

> 2026-09-12

## 接线（最小改动）

| 文件 | 变更 |
|------|------|
| `lib/capacitor_lab_basics/screens/capacitor_lab_basics_home.dart` | **新建** `KratosTabbedScreen`：Capacitance \| Light Bulb |
| `lib/screens/home_screen.dart` | +import、`_SimEntry`（电学与电路）、`_buildCapacitorLabBasics` |

未改：`main.dart`、`lib/common/`、其他 Simulation。

## 模型边界

```text
ClbSharedState（switchUsed 共享）
├── CapacitanceModel → CapacitanceInteractiveScreenBody
└── ClbLightBulbModel → LightBulbInteractiveScreenBody
```

业务逻辑仍在 ScreenBody / Model；Home 只持有生命周期。

## Gate

| Gate | Result |
|------|--------|
| Home Entry | PASS（卡片 `Capacitor Lab: Basics`） |
| Screen Navigation | PASS（Tab Capacitance ↔ Light Bulb） |
| Back | PASS（AppBar BackButton + NavigatorObserver） |
| Re-entry | PASS |
| State Reinitialization | PASS（`reinitializeForTest` / 再 push 新 Model） |
| Dispose | PASS（两次 open/close） |
| Reset | PASS（`circuit.battery.voltage` → 0） |
| Regression | PASS（CLB suite **72 PASS**） |
| dart analyze（CLB+home_screen） | PASS clean |
| flutter test（CLB） | PASS |
| flutter build apk --debug | PASS → `build/app/outputs/flutter-apk/app-debug.apk` |

> 全仓 `flutter analyze`：508 issues，均在 **其他** 包（如 `phet/quantum_coin_toss`）；**本 sim 路径 0 issue**。按「不修其他 Simulation」未改动。

## 测试

`test/capacitor_lab_basics/home_lifecycle_test.dart`
