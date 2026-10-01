import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../render/keplers_mvt.dart';

/// Measuring tape overlay.
///
/// [已确认] SolarSystemCommonMeasuringTapeNode: AU, 2 sig figs, default (0,1)→(1,1)
class MeasuringTapeOverlay extends StatelessWidget {
  const MeasuringTapeOverlay({
    super.key,
    required this.controller,
    required this.mvt,
  });

  final KeplersLawsController controller;
  final KeplersMvt mvt;

  @override
  Widget build(BuildContext context) {
    final base = mvt.toView(controller.tapeBase);
    final tip = mvt.toView(controller.tapeTip);
    final dist = controller.tapeBase.distance(controller.tapeTip);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _TapePainter(base: base, tip: tip),
          ),
        ),
        _handle(
          at: base,
          onDelta: (delta) {
            final next = mvt.toView(controller.tapeBase) + delta;
            controller.setTapeBase(mvt.toModel(next));
          },
        ),
        _handle(
          at: tip,
          onDelta: (delta) {
            final next = mvt.toView(controller.tapeTip) + delta;
            controller.setTapeTip(mvt.toModel(next));
          },
        ),
        Positioned(
          left: (base.dx + tip.dx) / 2 - 28,
          top: (base.dy + tip.dy) / 2 - 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x80FFFFFF),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '${dist.toStringAsFixed(2)} AU',
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ),
      ],
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
            color: KeplersLawsColors.sun,
            border: Border.all(color: Colors.black54),
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
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _TapePainter old) =>
      old.base != base || old.tip != tip;
}
