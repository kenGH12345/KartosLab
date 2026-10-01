# Bending Light — Home Integration Report

Bending Light 核心保持 READY，没有重开物理或视觉阶段。本阶段只把正式入口加进现有 Home。

## 1. Home Entry

- category：`物理` → `光学与波动`
- location：该分组列表末尾，在「电磁波」之后
- display name：`Bending Light`
- subtitle：`折射 · 棱镜 · 传感器`
- icon：`Icons.lens_outlined`。`assets/simulations/bending_light/` 里只有 `laser.png`、`protractor.png`、`knob.png`，没有 Home 卡片图标。现有 Home 卡片一律用 Material `IconData`，这里沿用这个 fallback，没有裁截图，也没有改其他卡片的图标。
- color：`#1D4ED8`
- route：现有 `Navigator.push` + `MaterialPageRoute`，builder 是 `BendingLightHome`。没有新导航系统。

## 2. Changed Files

- `lib/screens/home_screen.dart`：光学与波动增加一张卡片
- `lib/bending_light/screens/bending_light_home.dart`：正式入口。`KratosTabbedScreen`，三个标签 Intro / Prisms / More Tools
- `lib/bending_light/screens/intro_screen.dart`
- `lib/bending_light/screens/prisms_screen.dart`
- `lib/bending_light/screens/more_tools_screen.dart`：增加 `embedded`。Home 嵌入时不画 QA AppBar。默认 `false`，demo / 旧测试仍看到原来的 QA 标题
- `test/home/bending_light_integration_test.dart`
- `requirements/req-bending-light/visual-qa/home/HOME_BENDING_LIGHT_ENTRY.png`
- `requirements/req-bending-light/visual-qa/home/HOME_BENDING_LIGHT_RUNNING.png`
- `requirements/req-bending-light/visual-qa/home/HOME_BENDING_LIGHT_RETURN.png`

`bending_light_demo_main.dart` 和 `BendingLightHub` 仍只给开发 / 截图 / QA。Home 不打开它们。

## 3. Bending Light Core

`CORE = FROZEN`

没有改 Snell、Fresnel、dispersion、白光、波、传感器物理、激光约束、棱镜几何、图表或 source node。`embedded` 只决定要不要包 QA `AppBar`。

## 4. Navigation

- Home → Bending Light：卡片进入 `BendingLightHome`。标题是 `Bending Light`，带返回键和三个标签。没有 `Bending Light — Intro` 这类 QA 标题，也没有 demo hub。
- Bending Light → Home：AppBar 返回键回到 Home。其他实验卡片仍在。

## 5. Lifecycle

- enter：三个 screen 各建自己的 Model。Intro 默认激光关闭、波长 `wavelengthRed`、下介质水。
- dispose：离开路由后 Intro / Prisms / More Tools 的 play area 都卸掉。ticker 跟着 State `dispose`。
- re-enter：新的 Model 实例，不保留上一次把激光打开、波长改成 500 nm 的状态。
- 标签切换：`KratosTabSwitcher` 保持三个子页挂载，非当前页 `TickerMode` 关闭。这是现有多屏实验的做法，不是第二套时钟。
- reset：仍是各屏自己的 Reset All，没有从 Home 注入状态。

## 6. Tests

- `flutter test test/bending_light/`：**161 passed**
- `flutter test test/home/bending_light_integration_test.dart`：**3 passed**（登记、正式入口、进入/返回/再进入默认状态、每种 play area 只有一个）
- `flutter test`：`2347 passed`，`1 skipped`，`56 failed`

这 56 个失败都是 `TimeoutException`，文件是：

- `test/projectile_motion/projectile_visual_qa_capture_test.dart`（20）
- `test/pendulum_lab/pendulum_visual_qa_capture_test.dart`（18）
- `test/chemistry/states_of_matter/states_of_matter_visual_qa_capture_test.dart`（15）
- `test/gas_properties/gas_properties_screenshot_capture_test.dart`（2）
- `test/forces/forces_scenario_test.dart` 的 `netforce-tug scenario has valid pullers`（1，10 分钟超时）

这些测试不引用 Home，也不引用 Bending Light。没有为它们改期望值，也没有删测试。

## 7. Analyze

本次改动的文件没有新的 analyzer issue。

`dart analyze` / `flutter analyze` 扫整个工作区时仍有既有问题：`phet/quantum_coin_toss` 的 error，以及 `tool/`、其他 sim 的 warning / info。没有用 ignore 或 exclude 去藏。没有为了这份报告去改那些文件。

`dart analyze lib/bending_light` 仍然 clean。

## 8. Build

`flutter build apk` 成功：

`build/app/outputs/flutter-apk/app-release.apk`（75.5MB）

这是 **BUILD VERIFIED**。没有在设备或模拟器上安装运行。

Web：`flutter run -d web-server -t lib/main.dart` 已打开正式 Home 并完成进入 / 返回。截图结束后服务已关闭；退出码 1 是主动 `taskkill`，不是启动失败。

## 9. Runtime QA

截图在 `requirements/req-bending-light/visual-qa/home/`。

- `HOME_BENDING_LIGHT_ENTRY.png`：光学与波动末尾的卡片，名称、副标题、圆环图标
- `HOME_BENDING_LIGHT_RUNNING.png`：正式页。返回键、`Bending Light` 标题、Intro 标签、Ray/Wave、空气/水。不是 QA AppBar，也不是 demo hub
- `HOME_BENDING_LIGHT_RETURN.png`：返回后 Home 仍列出 Bending Light，下一项仍是 Diffusion

无障碍树里同时有 Intro、Prisms、More Tools 三个标签。运行帧的视觉描述有时只读到前两个标签。

## 10. Android

APK 已编出。

`Android runtime NOT VERIFIED`

## 11. Final Status

# HOME INTEGRATION PASS

正式入口、分类、路由、生命周期和 Bending Light 回归都通过。全库 `flutter test` 里那 56 个超时不在这次改动的调用链上，也没有被改掉或藏起来。
