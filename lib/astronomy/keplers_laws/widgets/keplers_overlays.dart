import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_strings.dart';
import '../keplers_motion.dart';
import '../model/period_tracker.dart';

/// Draggable period timer for Third Law.
///
/// [已确认] PeriodTimerNode + PeriodTracker.periodStopwatch
class PeriodTimerOverlay extends StatelessWidget {
  const PeriodTimerOverlay({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    final running =
        controller.periodTracker.trackingState == TrackingState.running;
    final t = controller.periodTracker.periodStopwatchTime;
    final show =
        controller.hasThirdLawFeatures && controller.visible.periodVisible;
    return Positioned(
      right: 16,
      top: 80,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: KeplersMotion.duration,
        curve: KeplersMotion.curve,
        child: IgnorePointer(
          ignoring: !show,
          child: Material(
            color: const Color(0xFF333333),
            elevation: 4,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => controller.setPeriodTracking(!running),
                    child: CustomPaint(
                      size: const Size(22, 22),
                      painter: _PlayPausePainter(running: running),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${t.toStringAsFixed(2)} ${KeplersLawsStrings.unitsYears}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// scenery-phet StopwatchNode, 2 decimal years.
///
/// [已确认] 初始位置 `resetAll.left - 200`, `timeControl.bottom - 75`
class YearsStopwatchOverlay extends StatelessWidget {
  const YearsStopwatchOverlay({
    super.key,
    required this.controller,
    required this.area,
    required this.footerH,
  });

  final KeplersLawsController controller;
  final Size area;
  final double footerH;

  static const double _width = 168;
  static const double _height = 72;
  static const Color _bg = Color.fromRGBO(80, 130, 230, 1);

  @override
  Widget build(BuildContext context) {
    final left = (area.width - 8 - 41 - 200 + controller.stopwatchOffset.dx)
        .clamp(8.0, mathMax(8.0, area.width - _width - 8));
    final top = (area.height - footerH - 75 + controller.stopwatchOffset.dy)
        .clamp(8.0, mathMax(8.0, area.height - _height - 8));

    final visible = controller.visible.stopwatchVisible;
    return Positioned(
      left: left,
      top: top,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: KeplersMotion.duration,
        curve: KeplersMotion.curve,
        child: IgnorePointer(
          ignoring: !visible,
          child: GestureDetector(
            onPanUpdate: (d) => controller.nudgeStopwatch(d.delta),
            child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          color: _bg,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 148,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black87),
                  ),
                  child: Text(
                    '${controller.stopwatchTime.toStringAsFixed(2)} ${KeplersLawsStrings.unitsYears}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RoundBtn(
                      onTap: controller.resetStopwatchTime,
                      child: CustomPaint(
                        size: const Size(14, 14),
                        painter: _ResetMarkPainter(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RoundBtn(
                      onTap: () => controller.setStopwatchRunning(
                        !controller.stopwatchRunning,
                      ),
                      child: CustomPaint(
                        size: const Size(14, 14),
                        painter: _PlayPausePainter(
                          running: controller.stopwatchRunning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }
}

double mathMax(double a, double b) => a > b ? a : b;

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFE8E8E8),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _PlayPausePainter extends CustomPainter {
  _PlayPausePainter({required this.running});

  final bool running;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black87;
    if (running) {
      canvas.drawRect(Rect.fromLTWH(2, 2, 3.5, size.height - 4), p);
      canvas.drawRect(Rect.fromLTWH(size.width - 5.5, 2, 3.5, size.height - 4), p);
    } else {
      final path = Path()
        ..moveTo(3, 1)
        ..lineTo(size.width - 1, size.height / 2)
        ..lineTo(3, size.height - 1)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _PlayPausePainter old) => old.running != running;
}

class _ResetMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFE5002B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      0.4,
      4.6,
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
