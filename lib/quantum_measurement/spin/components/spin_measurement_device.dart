/// MeasurementDeviceNode — mini Bloch + camera; flashes on particle crossing.
/// Sources: MeasurementDeviceNode.ts, MeasurementSymbolNode.ts
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../bloch_sphere/components/bloch_sphere_view.dart';

class SpinMeasurementDevice extends StatelessWidget {
  const SpinMeasurementDevice({
    super.key,
    required this.polar,
    required this.azimuthal,
    this.active = true,
    this.flash = false,
    this.stateVectorVisible = false,
  });

  final double polar;
  final double azimuthal;
  final bool active;
  final bool flash;
  final bool stateVectorVisible;

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlochSphereView(
          center: Offset.zero,
          polar: polar,
          azimuthal: azimuthal,
          scale: 0.5,
          drawKets: false,
          drawAngleIndicators: false,
          drawAxesLabels: true,
          stateVectorScale: 2,
          stateVectorVisible: stateVectorVisible,
        ),
        const SizedBox(height: 20),
        CustomPaint(
          size: const Size(52, 42),
          painter: _MeasurementCameraPainter(
            // particleColor #C0C while flashing; idle black
            fill: flash ? const Color(0xFFCC00CC) : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _MeasurementCameraPainter extends CustomPainter {
  _MeasurementCameraPainter({required this.fill});

  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyTop = h * 0.28;
    final camera = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(0, bodyTop, w, h),
          Radius.circular(w * 0.1),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.26, h * 0.05, w * 0.74, bodyTop + 1),
          Radius.circular(w * 0.05),
        ),
      );
    canvas.drawPath(camera, Paint()..color = fill);

    final cx = w * 0.50;
    final cy = h * 0.64;
    final r = w * 0.24;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy + r * 0.2), radius: r),
      math.pi,
      math.pi,
      false,
      stroke,
    );

    final tip = Offset(cx + r * 0.55, cy - r * 0.75);
    final base = Offset(cx - r * 0.2, cy + r * 0.35);
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = Colors.white
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round,
    );
    final ang = math.atan2(tip.dy - base.dy, tip.dx - base.dx);
    final head = w * 0.09;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          tip.dx - head * math.cos(ang - 0.5),
          tip.dy - head * math.sin(ang - 0.5),
        )
        ..lineTo(
          tip.dx - head * math.cos(ang + 0.5),
          tip.dy - head * math.sin(ang + 0.5),
        )
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _MeasurementCameraPainter oldDelegate) =>
      oldDelegate.fill != fill;
}

({double polar, double azimuthal}) spinDirectionAngles({
  required bool isUp,
  required bool isZ,
}) {
  if (isZ) {
    return (polar: isUp ? 0.0 : math.pi, azimuthal: 0.0);
  }
  return (polar: math.pi / 2, azimuthal: isUp ? 0.0 : math.pi);
}
