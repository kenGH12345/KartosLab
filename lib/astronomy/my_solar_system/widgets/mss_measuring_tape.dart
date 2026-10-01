/// Measuring tape — real endpoints in model space via MVT.
///
/// [KEPLER-SECONDARY] SolarSystemCommonMeasuringTapeNode defaults / AU 2dp
library;

import 'package:flutter/material.dart';

import '../controller/my_solar_system_controller.dart';
import '../my_solar_system_constants.dart';
import '../render/mss_format.dart';
import '../render/mss_mvt.dart';

class MssMeasuringTapeOverlay extends StatelessWidget {
  const MssMeasuringTapeOverlay({
    super.key,
    required this.controller,
    required this.mvt,
  });

  final MySolarSystemController controller;
  final MssMvt mvt;

  @override
  Widget build(BuildContext context) {
    if (!controller.measuringTapeVisible) {
      return const SizedBox.shrink();
    }
    final base = mvt.toView(controller.tapeBase);
    final tip = mvt.toView(controller.tapeTip);
    final dist = controller.tapeDistance;
    const r = MySolarSystemConstants.tapeHandleRadius;

    return Stack(
      key: const ValueKey('mss-measuring-tape'),
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _TapePainter(base: base, tip: tip)),
        ),
        Positioned(
          left: base.dx - r,
          top: base.dy - r,
          child: GestureDetector(
            onPanUpdate: (d) {
              final next = mvt.toView(controller.tapeBase) + d.delta;
              controller.setTapeBase(mvt.toModel(next));
            },
            child: Container(
              width: r * 2,
              height: r * 2,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFF00),
                border: Border.all(color: Colors.black54),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          left: tip.dx - r,
          top: tip.dy - r,
          child: GestureDetector(
            onPanUpdate: (d) {
              final next = mvt.toView(controller.tapeTip) + d.delta;
              controller.setTapeTip(mvt.toModel(next));
            },
            child: Container(
              width: r * 2,
              height: r * 2,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFF00),
                border: Border.all(color: Colors.black54),
                shape: BoxShape.circle,
              ),
            ),
          ),
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
              '${MssFormat.tapeAu(dist)} AU',
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ),
      ],
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
