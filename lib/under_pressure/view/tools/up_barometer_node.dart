import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';

/// Source: `BarometerNode.js` — drag updates gauge **center**; pressure at **tip**.
class UpBarometerNode extends StatefulWidget {
  const UpBarometerNode({
    super.key,
    required this.controller,
    required this.index,
    required this.sensorPanelRect,
  });

  final UnderPressureController controller;
  final int index;
  final Rect sensorPanelRect;

  @override
  State<UpBarometerNode> createState() => _UpBarometerNodeState();
}

class _UpBarometerNodeState extends State<UpBarometerNode> {
  static const double localW = 80;
  static const double localH = 110;

  double get _scale => UpBarometerMetrics.nodeScale;
  double get _w => localW * _scale;
  double get _h => localH * _scale;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final sensor = c.model.barometers[widget.index];
    final mvt = c.mvt;
    final centerView = mvt.modelToViewOffset(sensor.position);

    final pressureString = sensor.value == null
        ? '—'
        : c.model.getPressureString(sensor.value!);

    return Positioned(
      left: centerView.dx - _w / 2,
      top: centerView.dy - _h * 0.42,
      width: _w,
      height: _h,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          final cur = mvt.modelToViewOffset(sensor.position);
          final next = Offset(
            (cur.dx + d.delta.dx).clamp(_w / 2, UpMvt.layoutWidth - _w / 2),
            (cur.dy + d.delta.dy).clamp(_h / 2, UpMvt.layoutHeight - _h / 2),
          );
          c.setSensorCenter(widget.index, mvt.viewToModelOffset(next));
        },
        onPanEnd: (_) {
          final cv = mvt.modelToViewOffset(sensor.position);
          final nodeBounds = Rect.fromCenter(center: cv, width: _w, height: _h);
          c.endSensorDrag(
            widget.index,
            overSensorPanel: widget.sensorPanelRect.overlaps(nodeBounds),
          );
        },
        child: CustomPaint(
          size: Size(_w, _h),
          painter: _BarometerPainter(
            valuePa: sensor.value,
            pressureString: pressureString,
          ),
        ),
      ),
    );
  }
}

class _BarometerPainter extends CustomPainter {
  _BarometerPainter({
    required this.valuePa,
    required this.pressureString,
  });

  final double? valuePa;
  final String pressureString;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final radius = size.width * 0.34;
    final center = Offset(cx, radius + 4);

    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final label = TextPainter(
      text: const TextSpan(
        text: 'Pressure',
        style: TextStyle(fontSize: 9, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 1.8);
    label.paint(
      canvas,
      Offset(cx - label.width / 2, center.dy - radius * 0.55),
    );

    if (valuePa != null) {
      final minP = UnderPressureConstants.minPressure;
      final maxP = UnderPressureConstants.maxPressure;
      final clamped = valuePa!.clamp(minP, maxP);
      const span = math.pi + math.pi / 4;
      final start = -math.pi / 2 - span / 2;
      final t = (clamped - minP) / (maxP - minP);
      final angle = start + t * span;
      final needleLen = radius - 6;
      canvas.drawLine(
        center,
        Offset(
          center.dx + needleLen * math.cos(angle),
          center.dy + needleLen * math.sin(angle),
        ),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.black);

    final stemTop = center.dy + radius - 2;
    const stemW = 12.0;
    const stemH = 15.0;
    final stemRect =
        Rect.fromCenter(center: Offset(cx, stemTop + stemH / 2), width: stemW, height: stemH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(stemRect, const Radius.circular(1)),
      Paint()..color = const Color(0xFFBDC3CF),
    );

    const triH = 12.0;
    final tri = Path()
      ..moveTo(cx - 3, stemRect.bottom - 1)
      ..lineTo(cx, stemRect.bottom - 1 + triH)
      ..lineTo(cx + 3, stemRect.bottom - 1)
      ..close();
    canvas.drawPath(tri, Paint()..color = const Color(0xFFDEE6F5));

    // Verify tip sits at bottom of widget ≈ pressureReadOffset*scale from center
    // (acceptance: visual tip == measurement tip)

    final readout = TextPainter(
      text: TextSpan(
        text: pressureString,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.85);
    final box = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, center.dy + 8),
        width: size.width * 0.72,
        height: 16,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(box, Paint()..color = Colors.white);
    canvas.drawRRect(
      box,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );
    readout.paint(
      canvas,
      Offset(cx - readout.width / 2, center.dy + 8 - readout.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _BarometerPainter old) =>
      old.valuePa != valuePa || old.pressureString != pressureString;
}
