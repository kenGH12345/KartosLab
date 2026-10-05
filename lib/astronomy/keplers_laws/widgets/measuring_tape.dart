import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_motion.dart';
import '../render/keplers_mvt.dart';

/// Measuring tape overlay.
///
/// [已确认] SolarSystemCommonMeasuringTapeNode: AU, 2 sig figs, default (0,1)→(1,1)
/// Housing is scenery-phet `measuringTape.png`.
class MeasuringTapeOverlay extends StatelessWidget {
  const MeasuringTapeOverlay({
    super.key,
    required this.controller,
    required this.mvt,
  });

  final KeplersLawsController controller;
  final KeplersMvt mvt;

  static const String _housingAsset =
      'assets/energy_skate_park/scenery_phet/measuringTape.png';
  static const double _baseScale = 0.8;
  static const double _iw = 51 * _baseScale;
  static const double _ih = 51 * _baseScale;

  @override
  Widget build(BuildContext context) {
    final base = mvt.toView(controller.tapeBase);
    final tip = mvt.toView(controller.tapeTip);
    final dist = controller.tapeBase.distance(controller.tapeTip);
    final angle = math.atan2(tip.dy - base.dy, tip.dx - base.dx);

    final visible = controller.visible.measuringTapeVisible;
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: KeplersMotion.duration,
      curve: KeplersMotion.curve,
      child: IgnorePointer(
        ignoring: !visible,
        child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _TapePainter(base: base, tip: tip),
          ),
        ),
        Positioned(
          left: (base.dx + tip.dx) / 2 - 28,
          top: (base.dy + tip.dy) / 2 - 14,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xE6FFFFFF),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '${dist.toStringAsFixed(2)} AU',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
        ),
        Positioned(
          left: base.dx - _iw,
          top: base.dy - _ih,
          width: _iw,
          height: _ih,
          child: GestureDetector(
            onPanUpdate: (d) {
              controller.nudgeTape(
                d.delta,
                mvt.toView,
                mvt.toModel,
              );
            },
            child: Transform.rotate(
              angle: angle,
              alignment: Alignment.bottomRight,
              child: Image.asset(
                _housingAsset,
                width: _iw,
                height: _ih,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF5E000),
                  child: Center(
                    child: Container(
                      width: _ih * 0.45,
                      height: _ih * 0.45,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4AA3E0),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _handle(
          at: tip,
          onDelta: (delta) {
            final next = mvt.toView(controller.tapeTip) + delta;
            controller.setTapeTip(mvt.toModel(next));
          },
        ),
      ],
        ),
      ),
    );
  }

  Widget _handle({
    required Offset at,
    required void Function(Offset delta) onDelta,
  }) {
    return Positioned(
      left: at.dx - 12,
      top: at.dy - 12,
      child: GestureDetector(
        onPanUpdate: (d) => onDelta(d.delta),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0x66FFFFFF),
            border: Border.all(color: const Color(0xFFE05F20), width: 2),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _TapePainter extends CustomPainter {
  _TapePainter({required this.base, required this.tip});

  final Offset base;
  final Offset tip;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8C8C8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, tip, paint);
    final dx = tip.dx - base.dx;
    final dy = tip.dy - base.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final nx = -dy / len;
    final ny = dx / len;
    final tick = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 1;
    for (var t = 0.0; t <= 1.0; t += 0.1) {
      final px = base.dx + dx * t;
      final py = base.dy + dy * t;
      canvas.drawLine(
        Offset(px - nx * 4, py - ny * 4),
        Offset(px + nx * 4, py + ny * 4),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TapePainter old) =>
      old.base != base || old.tip != tip;
}
