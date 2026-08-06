# W0-2 · SimulationClock 蓝本草案

> 分析日期：2026-07-22 · Java 蓝本：`<PHET_JAVA_ROOT>/simulations-java/common/phetcommon/src/edu/colorado/phet/common/phetcommon/model/clock/`
> 目标：将 Java `IClock` + `ConstantDtClock` + `TimeControlPanel` 的核心概念翻译为 Flutter/Dart 最小可用 API
> 原则：Q4=B（借概念不照抄）——去掉 Swing 特有的 Listener/Event 模式，对齐 Flutter phet 现有的 @immutable + callback 范式

## 一、Java 蓝本架构

```
IClock (接口)
  ├── start() / pause() / isRunning() / isPaused()
  ├── stepClockWhilePaused() / stepClockBackWhilePaused()
  ├── resetSimulationTime() / setSimulationTime(t)
  ├── getSimulationTime() / getSimulationTimeChange()
  ├── getWallTime() / getWallTimeChange()
  └── addClockListener(ClockListener)

ClockListener (接口)
  ├── clockTicked(ClockEvent)
  ├── clockStarted(ClockEvent)
  ├── clockPaused(ClockEvent)
  ├── simulationTimeChanged(ClockEvent)
  └── simulationTimeReset(ClockEvent)

ClockEvent (包装类)
  └── getClock() / getSimulationTime() / getSimulationTimeChange()

ConstantDtClock extends SwingClock
  ├── new ConstantDtClock(framesPerSecond)
  ├── new ConstantDtClock(delay_ms, dt_seconds)
  ├── setDt(dt) / getDt()
  └── setRunning(bool)

TimeControlPanel (Swing UI)
  ├── Play/Pause button (双态图标)
  ├── Step forward button
  ├── Step back button
  ├── Restart button
  └── Time readout (文本框)
```

**关键设计思想**（应保留）：
1. **运行/暂停 双态** —— 不是"播放/停止"，而是"播放/暂停"（step while paused 独立按钮）
2. **wall time ≠ simulation time** —— 可调速（sim 时间可以比墙钟快/慢）
3. **listener 模式** —— 解耦 Clock 和 Model（Model 实现 ClockListener 即可在 onTick 中更新）
4. **帧率驱动** —— `framesPerSecond` 决定 tick 频率（默认 30fps）

**Java Swing 特有（应丢弃）**：
- `EventListener` / `EventListenerList` → Dart callback
- `SwingClock` / `javax.swing.Timer` → Flutter `Ticker` / `AnimationController`
- `ClockEvent` 包装类 → 直接传参数
- `ClockAdapter` 空实现 → Dart 可选参数

## 二、Dart API 草案

### 2.1 核心抽象：`SimulationClock`

```dart
/// 模拟时钟——驱动所有动力学 sim 的统一心跳。
///
/// 用法模式（Model 层实现 onTick）：
/// ```dart
/// class ForcesSimulation {
///   final SimulationClock clock;
///   ForcesSimulation({double fps = 30.0})
///     : clock = SimulationClock(fps: fps);
///
///   void init(TickerProvider vsync) {
///     clock.onTick = (double dt, double time) {
///       _step(dt);  // 纯函数：根据 dt 推进一步
///     };
///     // 绑定到 Flutter 的 Ticker
///     clock.attach(vsync);
///   }
/// }
/// ```
class SimulationClock {
  // ── 构造 ──

  /// [fps] 每秒帧数（默认 30），决定 dt = 1/fps
  /// [timeScale] 模拟时间倍速（1.0 = 真实时间，2.0 = 2 倍速）
  SimulationClock({
    this.fps = 30.0,
    this.timeScale = 1.0,
  }) : _dt = 1.0 / fps;

  // ── 可配置参数 ──

  final double fps;
  double timeScale;

  // ── 回调（由 Model 层注入）──

  /// 每次 tick 时调用。
  /// [dt] 本次步进的模拟时间增量（秒）
  /// [totalTime] 累计模拟时间（秒）
  void Function(double dt, double totalTime)? onTick;

  // ── 状态 ──

  double _dt;
  bool _isRunning = false;

  double get dt => _dt;
  bool get isRunning => _isRunning;
  bool get isPaused => !_isRunning;

  // ── 生命周期 ──

  /// 绑定到 Flutter Ticker（必须在有 vsync 的 Widget 里调用）
  void attach(TickerProvider vsync) { /* 创建内部 Ticker */ }

  /// 启动 / 恢复
  void play() {
    if (!_isRunning) {
      _isRunning = true;
      _onPlay?.call();
    }
  }

  /// 暂停
  void pause() {
    if (_isRunning) {
      _isRunning = false;
      _onPause?.call();
    }
  }

  /// 切换播放/暂停
  void toggle() => _isRunning ? pause() : play();

  // ── 手动步进（暂停时可用）──

  /// 手动前进一帧（暂停状态下）
  void stepForward() {
    if (!_isRunning) {
      final stepDt = _dt * timeScale;
      onTick?.call(stepDt, _totalTime + stepDt);
    }
  }

  /// 手动后退一帧（暂停状态下）
  void stepBackward() {
    if (!_isRunning) {
      final stepDt = -_dt * timeScale;
      onTick?.call(stepDt, _totalTime + stepDt);
    }
  }

  /// 重置模拟时间到 0
  void reset() {
    _totalTime = 0;
    _onReset?.call();
  }

  /// 释放资源
  void dispose() { /* 销毁内部 Ticker */ }
}
```

### 2.2 与 `AnimationController` 的关系

Flutter phet 现状：`ForcesSimulation`（`lib/forces/models/forces_simulation.dart`）内部用 `AnimationController` 驱动。

**两种集成方式**（不必二选一，由你决定）：

| 方式 | 说明 | 改动力度 |
|---|---|---|
| **A. 包装模式**（推荐） | `SimulationClock` 内部持有一个私有 `AnimationController`，对外暴露 play/pause/step | 小——加一个新文件，现有 forces 模块逐步迁移 |
| **B. 直接扩展** | 不改现有代码，`SimulationClock` 只是一个纯数据抽象，实际 tick 仍由模块自己写 | 零改动——但没达到"统一心跳"目标 |

### 2.3 UI 控件：`TimeControlBar`

```dart
/// 播放控制栏（横向排列）。
///
/// 对应 Java `TimeControlPanel`，去掉 Swing 组件，改用 Flutter 惯用法。
class TimeControlBar extends StatelessWidget {
  final SimulationClock clock;
  final bool showStepBack;    // 是否显示"后退一帧"按钮
  final bool showRestart;     // 是否显示"重置"按钮
  final bool showTimeDisplay; // 是否显示耗时读数
  final String timeUnit;      // 时间单位，如 "s"

  const TimeControlBar({
    required this.clock,
    this.showStepBack = true,
    this.showRestart = true,
    this.showTimeDisplay = true,
    this.timeUnit = 's',
  });

  // ── 按钮布局 ──
  // [◀◀] [▶/⏸] [▶▶] [↺]  [0.00 s]
  // stepBack  play   step  restart  time
}
```

### 2.4 与 ForcesSimulation 的迁移示意（最小改动）

```dart
// BEFORE（现状 · lib/forces/models/forces_simulation.dart）
class ForcesSimulation {
  // ... AnimationController _controller;
  // ... void tick() { _controller.forward(); }
}

// AFTER（迁移后）
class ForcesSimulation {
  final SimulationClock clock;

  ForcesSimulation() : clock = SimulationClock(fps: 60);

  void init(TickerProvider vsync) {
    clock.attach(vsync);
    clock.onTick = (double dt, double totalTime) {
      step(dt);  // ForcesSimulation 现有的纯函数计算
    };
  }
}
```

## 三、与 Flutter phet 三模块的接入点

| 模块 | 现状 | 接入 SimulationClock 后 |
|---|---|---|
| **forces** | `ForcesSimulation` 内写死 `AnimationController` | 替换为 `SimulationClock`，加 `TimeControlBar` 到 Screen |
| **circuit** | 无时间驱动（纯静态） | 暂无接入点（电容充电路需时钟） |
| **optics** | 无时间驱动（纯静态） | 暂无接入点 |

## 四、Java ↔ Dart 概念映射表

| Java (`IClock` / `ConstantDtClock`) | Dart (`SimulationClock`) | 说明 |
|---|---|---|
| `start()` / `pause()` | `play()` / `pause()` | 同义 |
| `isRunning()` / `isPaused()` | `isRunning` / `isPaused` | getter |
| `stepClockWhilePaused()` | `stepForward()` | 同义 |
| `stepClockBackWhilePaused()` | `stepBackward()` | 同义 |
| `resetSimulationTime()` | `reset()` | 同义 |
| `setSimulationTime(t)` | ❌ 不提供 | Flutter 教学 sim 不需要跳到任意时刻 |
| `getSimulationTime()` | `_totalTime`（内部 · 通过 onTick 参数暴露） | |
| `getSimulationTimeChange()` | onTick 的 `dt` 参数 | |
| `getWallTime()` / `getWallTimeChange()` | ❌ 不提供 | Dart 不需要墙钟分离 |
| `addClockListener(ClockListener)` | `onTick` / `_onPlay` / `_onPause` / `_onReset` 回调 | 一个 callback 替代整个 Listener 接口 |
| `ClockEvent` 包装类 | ❌ 不需要 | dt + totalTime 直接当参数传 |
| `framesPerSecond` 构造 | `fps` 命名参数（默认 30） | |
| `timeScale`（无 Java 版 · P2 增强） | `timeScale` 属性 | 教学 sim 调速（0.5x / 1x / 2x） |
| `ClockControlPanel` (Swing) | `TimeControlBar` (Flutter Widget) | |
| `javax.swing.Timer` | Flutter `Ticker`（通过 attach vsync） | |

## 五、文件落地位置（Q2=A · `lib/common/`）

```
C:\workspace\phet\lib\common\
├── simulation_clock.dart          # SimulationClock 核心类
└── widgets\
    └── time_control_bar.dart      # TimeControlBar UI 控件
```

## 六、下一步

### 如你批准本草案

1. 在 `c:\workspace\phet\lib\common\` 创建上述两个文件
2. forces 模块作为首个迁移目标——替换 `ForcesSimulation` 的 `AnimationController`
3. 在 `ForcesScreen` 底部加 `TimeControlBar`
4. 跑 integration_test 确保无回归

### 如你要调整

请回复需要调整的方面（如"stepBackward 不需要"、"fps 默认 60 而不是 30"、"加调速滑块"等）

---

> **关键引用**：
> - Java `IClock` 接口：`<PHET_JAVA_ROOT>/simulations-java/common/phetcommon/src/.../clock/IClock.java`（133 行 · 9 个方法 + 2 个 step 方法）
> - Java `ConstantDtClock`：`<PHET_JAVA_ROOT>/simulations-java/common/phetcommon/src/.../clock/ConstantDtClock.java`（230 行 · 双构造器 + setDt/setDelay）
> - Java `ClockListener` 回调：`<PHET_JAVA_ROOT>/simulations-java/common/phetcommon/src/.../clock/ClockListener.java`（5 个事件方法）
> - Java `TimeControlPanel` UI：`<PHET_JAVA_ROOT>/simulations-java/common/phetcommon/src/.../view/TimeControlPanel.java`（391 行 · Play/Step/Restart + 时间读数）
> - Java `MotionModel` 使用者：`<PHET_JAVA_ROOT>/simulations-java/common/motion/src/.../model/MotionModel.java`（line 18：`private ConstantDtClock clock` · line 62：`clock.addClockListener(new ClockAdapter(){...})`）
> - 原则：`20-verify-before-act.mdc` · Q4=B（借概念不照抄）
