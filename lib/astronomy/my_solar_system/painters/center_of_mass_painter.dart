/// Center of mass as a red X.
///
/// [MSS-SOURCE] `CenterOfMassNode.ts`
library;

import 'package:flutter/material.dart';

import '../render/mss_render_data.dart';

class CenterOfMassPainter extends CustomPainter {
  CenterOfMassPainter(this.data);

  final MssRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.centerOfMassVisible || data.comPosition == null) return;
    final c = data.mvt.toView(data.comPosition!);
    const arm = 10.0;
    final paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final outline = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final p in [outline, paint]) {
      canvas.drawLine(c + const Offset(-arm, -arm), c + const Offset(arm, arm), p);
      canvas.drawLine(c + const Offset(-arm, arm), c + const Offset(arm, -arm), p);
    }
  }

  @override
  bool shouldRepaint(CenterOfMassPainter oldDelegate) =>
      oldDelegate.data != data;
}
