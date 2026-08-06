import 'package:flutter/material.dart';
import 'simulation_clock.dart';

/// 模拟时钟播放控制栏。
///
/// 按钮布局：[◀◀] [▶/⏸] [▶▶] [↺]  [0.0 s]
class TimeControlBar extends StatelessWidget {
  const TimeControlBar({
    super.key,
    required this.clock,
    this.showStepBack = true,
    this.showRestart = true,
    this.showTimeDisplay = true,
    this.timeUnit = 's',
  });

  final SimulationClock clock;
  final bool showStepBack;
  final bool showRestart;
  final bool showTimeDisplay;
  final String timeUnit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStepBack)
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 20),
            onPressed: clock.isPaused ? clock.stepBackward : null,
            tooltip: '后退一帧',
            visualDensity: VisualDensity.compact,
          ),
        IconButton(
          icon: Icon(clock.isRunning ? Icons.pause : Icons.play_arrow, size: 22),
          onPressed: clock.toggle,
          tooltip: clock.isRunning ? '暂停' : '播放',
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 20),
          onPressed: clock.isPaused ? clock.stepForward : null,
          tooltip: '前进一帧',
          visualDensity: VisualDensity.compact,
        ),
        if (showRestart)
          IconButton(
            icon: const Icon(Icons.restart_alt, size: 20),
            onPressed: clock.reset,
            tooltip: '重置',
            visualDensity: VisualDensity.compact,
          ),
        if (showTimeDisplay) ...[
          const SizedBox(width: 4),
          Text(
            '${clock.totalTime.toStringAsFixed(1)} $timeUnit',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF475569)),
          ),
        ],
      ],
    );
  }
}
