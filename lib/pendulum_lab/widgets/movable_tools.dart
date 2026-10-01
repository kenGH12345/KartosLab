import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/pendulum_lab/model/lab_stopwatch.dart';
import 'package:kratos/pendulum_lab/model/period_timer.dart';
import 'package:kratos/pendulum_lab/model/pl_vector2.dart';
import 'package:kratos/pendulum_lab/model/ruler.dart';
import 'package:kratos/pendulum_lab/pl_assets.dart';
import 'package:kratos/pendulum_lab/pl_colors.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';
import 'package:kratos/pendulum_lab/pl_strings.dart';
import 'package:kratos/pendulum_lab/transform/pendulum_lab_transform.dart';
import 'package:kratos/pendulum_lab/widgets/pl_stopwatch_node.dart';

const _transform = PendulumLabTransform();

class DraggableRuler extends StatelessWidget {
  const DraggableRuler({
    super.key,
    required this.ruler,
    required this.onMoved,
  });

  final PlRuler ruler;
  final VoidCallback onMoved;

  static double get viewLength => _transform.modelToViewDeltaX(1);

  static Size get visualSize => Size(PlConstants.rulerHeight, viewLength);

  @override
  Widget build(BuildContext context) {
    if (!ruler.isVisible) return const SizedBox.shrink();
    final center = ruler.position ??
        PlVector2(
          PlConstants.panelPadding + visualSize.width / 2,
          PlConstants.panelPadding + visualSize.height / 2,
        );
    return Positioned(
      left: center.x - visualSize.width / 2,
      top: center.y - visualSize.height / 2,
      child: GestureDetector(
        onPanUpdate: (d) {
          final cur = ruler.position ?? center;
          ruler.position = PlVector2(cur.x + d.delta.dx, cur.y + d.delta.dy);
          onMoved();
        },
        child: CustomPaint(
          size: visualSize,
          painter: _RulerPainter(),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Source draws horizontal then rotates π/2. We paint vertical directly.
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = PlColors.rulerFill);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    final tickCount = (100 / PlConstants.rulerTickIntervalCm).round();
    final tickH = size.height / tickCount;
    for (var i = 0; i <= tickCount; i++) {
      final y = i * tickH;
      final cm = i * PlConstants.rulerTickIntervalCm;
      final major = cm % 10 == 0;
      final len = major ? 12.0 : 6.0;
      canvas.drawLine(
        Offset(0, y),
        Offset(len, y),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 0.8,
      );
      if (major && cm > 0 && cm < 100) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$cm',
            style: const TextStyle(fontSize: 10, fontFamily: 'Arial'),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(14, y - tp.height / 2));
      }
    }
    final units = TextPainter(
      text: const TextSpan(
        text: PlStrings.rulerUnits,
        style: TextStyle(fontSize: 10, fontFamily: 'Arial'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    units.paint(canvas, Offset(8, size.height - 28));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DraggableStopwatch extends StatelessWidget {
  const DraggableStopwatch({
    super.key,
    required this.stopwatch,
    required this.onChanged,
  });

  final PlStopwatch stopwatch;
  final VoidCallback onChanged;

  /// Measured from capture with real Trebuchet MS metrics (published-build
  /// StopwatchNode measures 99x75.5 design px; ours 98x69 — height is
  /// slightly shorter because the ORIGINAL button row includes taller bevel
  /// shading). Used only for initial bottom-alignment with the ruler.
  static const Size nodeSize = Size(98, 72);

  @override
  Widget build(BuildContext context) {
    if (!stopwatch.isVisible) return const SizedBox.shrink();
    final pos = stopwatch.position ?? const PlVector2(54, 415);
    return Positioned(
      left: pos.x,
      top: pos.y,
      child: GestureDetector(
        onPanUpdate: (d) {
          final cur = stopwatch.position ?? pos;
          stopwatch.position =
              PlVector2(cur.x + d.delta.dx, cur.y + d.delta.dy);
          onChanged();
        },
        child: PlStopwatchNode(
          timeSeconds: stopwatch.time,
          isRunning: stopwatch.isRunning,
          onToggleRunning: () {
            stopwatch.toggleRunning();
            onChanged();
          },
          onReset: () {
            stopwatch.resetTime();
            onChanged();
          },
        ),
      ),
    );
  }
}

class DraggablePeriodTimer extends StatelessWidget {
  const DraggablePeriodTimer({
    super.key,
    required this.timer,
    required this.secondVisible,
    required this.onChanged,
  });

  final PeriodTimer timer;
  final bool secondVisible;
  final VoidCallback onChanged;

  static Size get nodeSize => Size(
        231 * PlConstants.periodTimerBackgroundScale,
        158 * PlConstants.periodTimerBackgroundScale,
      );

  @override
  Widget build(BuildContext context) {
    if (!timer.isVisible) return const SizedBox.shrink();
    final center = timer.position ??
        PlVector2(
          PlConstants.layoutWidth - 280,
          PlConstants.layoutHeight / 2,
        );
    return Positioned(
      left: center.x - nodeSize.width / 2,
      top: center.y - nodeSize.height / 2,
      child: GestureDetector(
        onPanUpdate: (d) {
          final cur = timer.position ?? center;
          timer.position = PlVector2(cur.x + d.delta.dx, cur.y + d.delta.dy);
          onChanged();
        },
        child: SizedBox(
          width: nodeSize.width,
          height: nodeSize.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                PlAssets.periodTimerBackground,
                width: nodeSize.width,
                height: nodeSize.height,
                fit: BoxFit.fill,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      PlStrings.period,
                      style: TextStyle(fontSize: 14, fontFamily: 'Arial'),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0x80000000)),
                      ),
                      child: Text(
                        PlStrings.seconds(timer.elapsedTime.toStringAsFixed(4)),
                        style: const TextStyle(fontSize: 14, fontFamily: 'Arial'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (secondVisible) ...[
                          _PendulumSwitch(
                            index: timer.activePendulumIndex,
                            onChanged: (i) {
                              timer.setActiveIndex(i);
                              onChanged();
                            },
                          ),
                          const SizedBox(width: 10),
                        ],
                        GestureDetector(
                          onTap: () {
                            timer.setRunning(!timer.isRunning);
                            onChanged();
                          },
                          child: Container(
                            width: 40,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFE0E1),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: const Color(0xFF999999)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              timer.isRunning ? '↶' : '▶',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendulumSwitch extends StatelessWidget {
  const _PendulumSwitch({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _icon(0, PlColors.firstPendulum),
        GestureDetector(
          onTap: () => onChanged(index == 0 ? 1 : 0),
          child: Container(
            width: 25,
            height: 12.5,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: index == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        _icon(1, PlColors.secondPendulum),
      ],
    );
  }

  Widget _icon(int i, Color color) {
    return GestureDetector(
      onTap: () => onChanged(i),
      child: Container(
        width: 17,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              PlColors.brighter(color, 0.4),
              color,
              color,
            ],
            stops: const [0, 0.2, 0.4, 1],
          ),
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        child: Text(
          '${i + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

/// Ensures initial tool positions once (mirrors ScreenView constructors).
void ensureToolPositions({
  required PlRuler ruler,
  required PlStopwatch stopwatch,
  PeriodTimer? periodTimer,
  required bool energyGraphPresent,
  required bool arrowsPresent,
}) {
  if (ruler.initialPosition == null) {
    var left = PlConstants.panelPadding.toDouble();
    if (energyGraphPresent) left += 180;
    if (arrowsPresent) left = math.max(left, PlConstants.panelPadding + 0);
    final center = PlVector2(
      left + DraggableRuler.visualSize.width / 2,
      PlConstants.panelPadding + DraggableRuler.visualSize.height / 2,
    );
    ruler.setInitialPosition(center);
  }
  if (stopwatch.initialPosition == null) {
    final r = ruler.position!;
    final topLeft = PlVector2(
      r.x + DraggableRuler.visualSize.width / 2 + 10,
      r.y +
          DraggableRuler.visualSize.height / 2 -
          DraggableStopwatch.nodeSize.height,
    );
    stopwatch.setInitialPosition(topLeft);
  }
  if (periodTimer != null && periodTimer.initialPosition == null) {
    periodTimer.setInitialPosition(
      PlVector2(
        PlConstants.layoutWidth - 260,
        (stopwatch.position?.y ?? 400) + DraggableStopwatch.nodeSize.height / 2,
      ),
    );
  }
}
