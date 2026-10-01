import 'package:flutter/material.dart';

import '../model/beers_law_model.dart';
import 'beers_law_layout.dart';
import 'beers_law_mvt.dart';

/// PhET `LightNode` / `LaserPointerNode` — body left of lens, beam exits right.
class BeersLawLightNode extends StatelessWidget {
  const BeersLawLightNode({
    super.key,
    required this.model,
    this.mvt = const BeersLawMvt(),
  });

  final BeersLawModel model;
  final BeersLawMvt mvt;

  @override
  Widget build(BuildContext context) {
    final tip = mvt.modelToView(model.light.position);
    final bodyW = BeersLawLayout.lightBodySize.width;
    final nozzleW = BeersLawLayout.lightNozzleSize.width;
    final totalW = bodyW + nozzleW;
    final h = BeersLawLayout.lightBodySize.height;
    final left = tip.dx - totalW;
    final top = tip.dy - h / 2;
    final on = model.light.isOn;

    return Positioned(
      left: left,
      top: top,
      width: totalW,
      height: h,
      child: Semantics(
        button: true,
        label: 'Light',
        toggled: on,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => model.setLightOn(!on),
          child: CustomPaint(
            size: Size(totalW, h),
            painter: _LaserPainter(on: on),
          ),
        ),
      ),
    );
  }
}

class _LaserPainter extends CustomPainter {
  _LaserPainter({required this.on});

  final bool on;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyW = BeersLawLayout.lightBodySize.width;
    final nozzleW = BeersLawLayout.lightNozzleSize.width;
    final nozzleH = BeersLawLayout.lightNozzleSize.height;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, bodyW, size.height),
      const Radius.circular(8),
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(Colors.grey.shade400, Colors.white, 0.35)!,
          Colors.grey.shade600,
        ],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black54
        ..strokeWidth = 1.5,
    );

    final nozzleTop = (size.height - nozzleH) / 2;
    final nozzle = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyW - 2, nozzleTop, nozzleW + 2, nozzleH),
      const Radius.circular(3),
    );
    canvas.drawRRect(nozzle, Paint()..color = Colors.grey.shade700);
    canvas.drawRRect(
      nozzle,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black87
        ..strokeWidth = 1,
    );

    final cx = bodyW * 0.45;
    final cy = size.height / 2;
    final r = BeersLawLayout.lightButtonRadius;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = on ? const Color(0xFFE53935) : const Color(0xFFB71C1C),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black87
        ..strokeWidth = 2,
    );
    // highlight
    canvas.drawCircle(
      Offset(cx - r * 0.25, cy - r * 0.25),
      r * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _LaserPainter oldDelegate) =>
      oldDelegate.on != on;
}
