import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../view/baa_phet_font.dart';

/// PhET `ChargeMeter` — arc gauge with PlusNode / MinusNode and needle.
class ChargeMeter extends StatelessWidget {
  const ChargeMeter({
    super.key,
    required this.charge,
    this.maxCharge = 10,
    this.width = 70,
    this.showNumericalReadout = true,
  });

  final int charge;
  final int maxCharge;
  final double width;
  final bool showNumericalReadout;

  @override
  Widget build(BuildContext context) {
    final height = showNumericalReadout ? width * 0.9 : width * 0.55;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ChargeMeterPainter(
          charge: charge.clamp(-maxCharge, maxCharge).toDouble(),
          maxCharge: maxCharge.toDouble(),
          showReadoutSpace: showNumericalReadout,
        ),
        child: showNumericalReadout
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    charge == 0
                        ? '0'
                        : (charge > 0 ? '+$charge' : '\u2212${charge.abs()}'),
                    style: BaaPhetFont.of(
                      14,
                      fontWeight: FontWeight.bold,
                      color: charge > 0
                          ? const Color(0xFFD14600)
                          : charge < 0
                              ? const Color(0xFF0000FF)
                              : Colors.black,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _ChargeMeterPainter extends CustomPainter {
  _ChargeMeterPainter({
    required this.charge,
    required this.maxCharge,
    required this.showReadoutSpace,
  });

  final double charge;
  final double maxCharge;
  final bool showReadoutSpace;

  static const _symbolLineWidth = 0.8;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(7),
    );
    canvas.drawRRect(bg, Paint()..color = const Color(0xFFD2D2D2));
    canvas.drawRRect(
      bg,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.grey
        ..strokeWidth = 1,
    );

    final meterW = size.width * 0.8;
    final meterH = meterW * 0.5;
    final left = (size.width - meterW) / 2;
    const top = 3.0;
    final rect = Rect.fromLTWH(left, top, meterW, meterH);

    final path = Path()
      ..moveTo(rect.left, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.top, rect.center.dx, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.bottom)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0000FF), Colors.white, Color(0xFFFF0000)],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.grey
        ..strokeWidth = 2,
    );

    // Minus (left) / Plus (right) — scenery-phet MinusNode / PlusNode
    _drawMinus(canvas, Offset(rect.left + meterW * 0.3, rect.top + meterH * 0.5));
    _drawPlus(canvas, Offset(rect.left + meterW * 0.7, rect.top + meterH * 0.5));

    // Needle: PhET rotates ArrowNode by (charge/MAX)*PI*0.4 from vertical
    final t = (charge / maxCharge).clamp(-1.0, 1.0);
    final pivot = Offset(rect.center.dx, rect.bottom - 3);
    final needleLen = meterH * 0.9;
    final angle = -math.pi / 2 + t * math.pi * 0.4;
    final tip = Offset(
      pivot.dx + needleLen * math.cos(angle),
      pivot.dy + needleLen * math.sin(angle),
    );
    // Arrow shaft + head
    canvas.drawLine(
      pivot,
      tip,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    final headDir = (tip - pivot);
    final len = headDir.distance;
    if (len > 0) {
      final u = headDir / len;
      final n = Offset(-u.dy, u.dx);
      final base = tip - u * 7;
      final head = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(base.dx + n.dx * 2.5, base.dy + n.dy * 2.5)
        ..lineTo(base.dx - n.dx * 2.5, base.dy - n.dy * 2.5)
        ..close();
      canvas.drawPath(head, Paint()..color = Colors.black);
    }
    canvas.drawCircle(pivot, 2.5, Paint()..color = Colors.black);
  }

  void _drawPlus(Canvas canvas, Offset center) {
    const w = 10.0;
    const t = 3.0;
    final fill = Paint()..color = Colors.red;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = _symbolLineWidth;
    final hBar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: t),
      const Radius.circular(0.5),
    );
    final vBar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: t, height: w),
      const Radius.circular(0.5),
    );
    canvas.drawRRect(hBar, fill);
    canvas.drawRRect(vBar, fill);
    canvas.drawRRect(hBar, stroke);
    canvas.drawRRect(vBar, stroke);
  }

  void _drawMinus(Canvas canvas, Offset center) {
    const w = 10.0;
    const t = 3.0;
    final fill = Paint()..color = Colors.blue;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = _symbolLineWidth;
    final bar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: t),
      const Radius.circular(0.5),
    );
    canvas.drawRRect(bar, fill);
    canvas.drawRRect(bar, stroke);
  }

  @override
  bool shouldRepaint(covariant _ChargeMeterPainter oldDelegate) =>
      oldDelegate.charge != charge ||
      oldDelegate.showReadoutSpace != showReadoutSpace;
}
