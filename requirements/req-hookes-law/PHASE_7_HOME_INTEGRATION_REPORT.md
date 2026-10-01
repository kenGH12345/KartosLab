# Hooke's Law — Phase 7 Home Integration Report

## Status

**READY CANDIDATE**

Home 正式入口已接到现有 Home 机制。Hooke's Law 本体没有改 Model、三屏行为、Graph、spring、受力 / 拖拽语义、Intro 动画、Systems / Energy 物理，也没有重做视觉。

整个模拟器仍然是 **NOT READY**。本阶段不宣布 READY。下一步才是 Phase 8 Final Acceptance。

本阶段没有 `OUT_OF_SCOPE_REGRESSION`。

## 1. Home category

现有结构是 `HomeScreen` 的学科 `物理`，其下子分组 `力学`。没有新建「经典力学」「弹簧」「机械学」。

卡片放在 `力学` 里，位于 Masses and Springs: Basics 与 Pendulum Lab 之间。相邻两张卡片的标题在测试里仍然存在。

## 2. Card

复用 `_SimEntry`，没有改卡片尺寸、字体或其它模拟的图标。

- title：`Hooke's Law`（source `hookes-law.title`）
- subtitle：`Intro · Systems · Energy`（与 Pendulum Lab 的多屏 subtitle 写法一致）
- icon：`Icons.swap_vert_rounded`。source 仓库没有可作 Home 卡片的专用图片；这个 Material icon 只出现在 Home 卡片上，没有放进模拟器内部
- accent：`#1E3A8A`
- enabled：与其它卡片一样，点击即可进入

## 3. Entry route

Home 卡片点击仍是：

`Navigator.of(context).push(MaterialPageRoute<void>(builder: sim.builder))`

Hooke's Law 的 builder 是 `_buildHookesLaw`，返回 `const HookesLawHome()`。

没有 `pushReplacement`，没有新的导航框架，没有 QA / debug / demo / screenshot 页。

## 4. Simulation root

`HookesLawHome` 是正式 screen container，包在已有的 `KratosTabbedScreen` 里。`initialIndex` 为 0，所以一进入就是 Intro。

三个 child 是现有的 `IntroScreen`、`SystemsScreen`、`EnergyScreen`，各自收到 route 持有的 model 与 view properties。

## 5. Back navigation

返回使用 `KratosTabbedScreen` 已有的 `AppBar` 默认 `BackButton`（`automaticallyImplyLeading`）。Home 没有嵌套 Navigator，所以这次 pop 回到 `HomeScreen`。

测试路径：Intro → Systems → Energy → Back。`NavigatorObserver.didPop` 增加，`HookesLawHome` 离开树，`HomeScreen` 仍在。

## 6. Intro / Systems / Energy entry

- 进入后可见 Intro 的 `intro-hand-1`
- 点 Systems tab 后可见 `systems-hand-parallel`
- 点 Energy tab 后可见 `Displacement:`
- 三屏都是正式 screen，不是测试页

tab 查找用 `Tab` 控件，避免点到 Energy 屏内部同名标签。

## 7. Lifecycle

与 Capacitor Lab Basics 等多屏 Home 入口相同，不以 Phase 6「离开某一屏不 reset」推断「离开 Home 也永远保存状态」。

- 一次访问内，`KratosTabSwitcher` 让三屏保持挂载。Intro ↔ Systems ↔ Energy 不销毁 model，也不 reset
- 弹出 route 时，子 screen 先 dispose：Intro 释放 ticker 并移除 view listener；Systems 移除 view listener；Energy 移除 view 与 spring listener。这些 screen 不拥有 view properties（`_ownsView` 为 false），所以不会二次 dispose
- 随后 `HookesLawHome.dispose` 释放三个 view properties
- model 本身没有 `dispose()`。route 丢掉引用后，下一次进入会 `new` 出新 model

## 8. Reopen behavior

Home → Hooke's Law → 修改 → Back → 再进入：

- 新的 spring 对象与离开前那个不是同一个
- Intro 回到 F = 0、k = 200
- Systems 顶部弹簧回到 k = 200
- Energy 回到 x = 0、k = 100
- 默认仍是 Intro（`intro-hand-1` 在）
- 对已经离开树的旧 spring 再写值不会抛异常
- 连续进入并返回两次：`didPop` 为 2，没有残留 route，Pendulum Lab 卡片仍在

## 9. Theme isolation

测试把 `MaterialApp` 主题字体设成 Courier。Intro 标签 `Spring Constant 1:` 仍是 Arial，不是 Courier。

模拟器内部控件没有改成 Home 主题。AppBar / TabBar 是既有 shell 的外框，不在 1024×618 舞台里面。

## 10. Viewport isolation

进入后逻辑舞台仍是 `HookesLawStage` 的 1024×618。测试看到 3 个 `SizedBox(width: 1024, height: 618)`，因为三个 tab 在一次访问里都保持挂载，不是因为舞台被改成别的尺寸。

没有变成 768×504，也没有把舞台套进 Home 卡片布局。AppBar 与 TabBar 在舞台之外，与其它使用 `KratosTabbedScreen` 的模拟器相同。

## 11. Regression tests

`flutter test test/hookes_law/`

**78 passed** = 原 73 + 本阶段 5。

没有删除、skip，也没有放宽旧 assertion。原有期望值没有改。

## 12. Home tests

新增 `test/hookes_law/home/home_integration_test.dart`，走真实 `HomeScreen` 与真实 `MaterialPageRoute`，没有 fake route。

覆盖：

1. 卡片存在，分类为 `力学`
2. 标题、subtitle、卡片 icon
3. 相邻卡片 Masses and Springs: Basics 与 Pendulum Lab 仍在
4. 打开正式 Intro
5. Systems / Energy 可打开，换 tab 不 reset
6. Back 回到 Home
7. 再进入是新默认实例
8. 旧 spring 写值不抛异常；同一次写入只通知测试 listener 一次
9. 连续打开关闭两次无异常、无残留 route
10. 主题字体不覆盖模拟器 Arial
11. 舞台尺寸常量与 1024×618 `SizedBox` 仍在

已有 Home 测试 `test/home/bending_light_integration_test.dart`：**3 passed**。Bending Light 仍在 `物理 / 光学与波动`，正式入口与返回未坏。

## 13. Analyze

`dart analyze lib/hookes_law lib/screens/home_screen.dart test/hookes_law`

**No issues found.**

## 14. Chrome verification

**Chrome = NOT VERIFIED**

再次执行 `flutter test --platform chrome test/hookes_law/home/home_integration_test.dart`。约 175 秒后输出仍只有一行 `loading`，没有进入任何用例。进程已终止。

同一文件在 VM tester 上约 12 秒内 5 项通过。停住的位置在测试工具加载，还没走到 Hooke's Law route。这与 Phase 6 的 Chrome loading 挂起是同一类现象，按既有工程的 browser test 启动问题记录，没有为它改模拟器。

## 15. Windows verification

**Windows = NOT VERIFIED**

- `flutter devices` 能看到 Windows
- `flutter test -d windows` 在约 12 秒内跑完，输出与 VM tester 相同，没有打开桌面窗口。widget test 不会因此变成窗口验证
- `flutter run -d windows` 完成了 Debug 构建（`build\windows\x64\runner\Debug\kratos.exe`），进程曾启动。没有在该窗口里操作 Home → Hooke's Law。进程随后被关掉

窗口里的正式入口没有被操作，所以不能写成 VERIFIED。

## 16. Android verification

**Android = NOT VERIFIED**

`flutter devices` 没有 Android 设备或模拟器。本阶段没有新建模拟器，也没有用 APK 构建代替真机验证。

## 17. Remaining NOT VERIFIED

- Chrome 窗口与 Chrome test
- Windows 窗口中的 Home → Hooke's Law
- Android
- 与官方像素的 visual diff（Phase 5 的 `VERSION_DELTA` 仍在，本阶段没有重做视觉）
- 整个模拟器的 Final Acceptance

## 18. Known limitations

- Home 外框（AppBar、TabBar）来自现有 `KratosTabbedScreen`，位于 1024×618 舞台之外。这是项目里多屏模拟器的既有壳，不是 Hooke's Law 单独的布局
- 一次访问内三块舞台同时挂载，是 tab 不 reset 的既有机制。回到 Home 会丢掉这棵树
- model 没有 `dispose()`。listener、Intro ticker、view properties 在 screen / route dispose 时释放
- Home 卡片 icon 是 Material icon，因为 source 没有可直接用作卡片的图片。它没有进入模拟器内部

## Acceptance checklist

- [x] Home 卡片存在
- [x] 正确分类（物理 → 力学）
- [x] 正确标题
- [x] 正确 icon 机制（仅 Home 卡片）
- [x] 正式入口
- [x] Intro 可打开
- [x] Systems 可打开
- [x] Energy 可打开
- [x] Back 正常
- [x] Reopen 正常
- [x] Lifecycle 正常
- [x] 无 duplicate listener（同一次写入通知一次；再进入是新实例）
- [x] 无 stale state（再进入为 source default）
- [x] 不污染 viewport
- [x] 不污染 simulation theme
- [x] 原 73 tests 全通过（合计 78）
- [x] Home tests PASS
- [x] Analyze clean
- [x] 无 P0

平台窗口不在这份清单的通过项里，并已标为 NOT VERIFIED。
