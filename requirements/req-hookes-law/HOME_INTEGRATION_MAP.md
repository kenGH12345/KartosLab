# Hooke's Law — Home Integration Map

Phase 7 only. The simulation body was not changed.

| Layer           | Existing Pattern | Hooke's Law | Status |
| --------------- | ---------------- | ----------- | ------ |
| Home category   | `HomeScreen` → 学科 `物理` → 子分组 `力学` | 同一分组。卡片在 Masses and Springs: Basics 之后、Pendulum Lab 之前 | PASS |
| Card            | `_SimEntry`：title / subtitle / Material icon / accent / builder | title `Hooke's Law`，subtitle `Intro · Systems · Energy`，icon `Icons.swap_vert_rounded`（仅 Home 卡片），accent `#1E3A8A` | PASS |
| Route           | 卡片 `Navigator.push(MaterialPageRoute(builder: sim.builder))` | `_buildHookesLaw` → `const HookesLawHome()`。无 `pushReplacement`，无单独导航框架 | PASS |
| Simulation root | 多屏 sim 用 `KratosTabbedScreen`，`initialIndex: 0` | `HookesLawHome` 持有 Intro / Systems / Energy 三个 model，默认屏是 Intro | PASS |
| Back            | `KratosTabbedScreen` 的 `AppBar` 默认返回，`maybePop` 弹出当前 route | 同一 `BackButton`。Intro → Systems → Energy → Back 回到 `HomeScreen`，不经过 QA / debug | PASS |
| Lifecycle       | route `State.initState` 建实例，route pop 时子树先 dispose，再 dispose view properties。再次进入是新实例 | 屏内换 tab 不 reset（`KratosTabSwitcher` 保持三屏挂载）。回到 Home 后再次进入得到 source default | PASS |
