import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';

/// EnergySkateParkCheckboxItem.ts — geometry icons (no PNG/SVG).
class EspCheckboxIcons {
  EspCheckboxIcons._();

  static const double iconBox = 22;

  static Widget pieChart() => SizedBox(
        width: iconBox,
        height: iconBox,
        child: CustomPaint(painter: _PieChartPainter()),
      );

  static Widget grid() => SizedBox(
        width: iconBox,
        height: iconBox,
        child: CustomPaint(painter: _GridPainter()),
      );

  static Widget speedometer() => SizedBox(
        width: iconBox,
        height: iconBox,
        child: CustomPaint(painter: _SpeedGaugePainter()),
      );

  static Widget path() => SizedBox(
        width: iconBox,
        height: iconBox,
        child: CustomPaint(painter: _PathPainter()),
      );

  static Widget stickToTrack() => SizedBox(
        width: iconBox,
        height: iconBox,
        child: CustomPaint(painter: _StickTrackPainter()),
      );

  static Widget referenceHeight() => SizedBox(
        width: iconBox,
        height: iconBox,
        child: CustomPaint(painter: _ReferenceHeightPainter()),
      );
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 10.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = EspColors.potentialEnergy
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    final path = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -math.pi / 2,
        math.pi / 2,
        false,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = EspColors.kineticEnergy
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const s = 20.0;
    final ox = (size.width - s) / 2;
    final oy = (size.height - s) / 2;
    canvas.drawRect(
      Rect.fromLTWH(ox, oy, s, s),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromLTWH(ox, oy, s, s),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    for (final y in [5.0, 10.0, 15.0]) {
      canvas.drawLine(
        Offset(ox, oy + y),
        Offset(ox + s, oy + y),
        Paint()
          ..color = Colors.black
          ..strokeWidth = y == 10 ? 1 : 0.5,
      );
    }
    for (final x in [5.0, 10.0, 15.0]) {
      canvas.drawLine(
        Offset(ox + x, oy),
        Offset(ox + x, oy + s),
        Paint()
          ..color = Colors.black
          ..strokeWidth = x == 10 ? 1 : 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpeedGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.72;
    const r = 9.0;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (var i = 0; i <= 4; i++) {
      final a = math.pi + (math.pi * i / 4);
      final inner = r - (i.isEven ? 2.5 : 1.5);
      canvas.drawLine(
        Offset(cx + inner * math.cos(a), cy + inner * math.sin(a)),
        Offset(cx + r * math.cos(a), cy + r * math.sin(a)),
        Paint()
          ..color = Colors.grey
          ..strokeWidth = i.isEven ? 1 : 0.5,
      );
    }
    const needleAngle = math.pi * 1.35;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.75 * math.cos(needleAngle),
          cy + r * 0.75 * math.sin(needleAngle)),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy), 1.5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const d = 9.0;
    const r = 3.0;
    final p1 = Offset(cx - d, cy - d);
    final p2 = Offset(cx, cy);
    final p3 = Offset(cx + d, cy - d);

    final line = Path()
      ..moveTo(p1.dx, p1.dy)
      ..quadraticBezierTo(p1.dx, p1.dy + d, p2.dx, p2.dy)
      ..quadraticBezierTo(p3.dx, p3.dy + d, p3.dx, p3.dy);
    canvas.drawPath(
      line,
      Paint()
        ..color = EspColors.pathStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (final c in [p1, p2, p3]) {
      canvas.drawCircle(c, r, Paint()..color = EspColors.pathFill);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = EspColors.pathStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StickTrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const w = 19.0;
    const h = 6.8;
    final ox = (size.width - w) / 2;
    final oy = (size.height - h) / 2;
    canvas.drawRect(
      Rect.fromLTWH(ox, oy, w, h),
      Paint()..color = EspColors.roadFill,
    );
    const dash = [2.5, 1.8];
    _drawDashedLine(
      canvas,
      Offset(ox, oy + h / 2),
      Offset(ox + w, oy + h / 2),
      Paint()
        ..color = EspColors.roadLine
        ..strokeWidth = 1,
      dash,
    );
    canvas.drawCircle(
      Offset(ox + w / 2, oy + h / 2),
      2,
      Paint()..color = EspColors.particleCircle.withValues(alpha: 0.7),
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dash,
  ) {
    final total = (end - start).distance;
    if (total == 0) return;
    final dir = (end - start) / total;
    var dist = 0.0;
    var dashIdx = 0;
    var draw = true;
    while (dist < total) {
      final seg = dash[dashIdx % dash.length];
      final next = (dist + seg).clamp(0.0, total);
      if (draw) {
        canvas.drawLine(start + dir * dist, start + dir * next, paint);
      }
      dist = next;
      dashIdx++;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReferenceHeightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const w = 19.65;
    const h = 3.7;
    final oy = (size.height - h) / 2;
    final ox = (size.width - w) / 2;
    const dash = [w / 5, w / 5];
    _drawDashedLine(
      canvas,
      Offset(ox, oy + h / 2),
      Offset(ox + w, oy + h / 2),
      Paint()
        ..color = EspColors.referenceLineStroke
        ..strokeWidth = h,
      dash,
    );
    _drawDashedLine(
      canvas,
      Offset(ox, oy + h / 2),
      Offset(ox + w, oy + h / 2),
      Paint()
        ..color = EspColors.referenceLineFill
        ..strokeWidth = h * 0.8,
      dash,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dash,
  ) {
    final total = (end - start).distance;
    if (total == 0) return;
    final dir = (end - start) / total;
    var dist = 0.0;
    var dashIdx = 0;
    var draw = true;
    while (dist < total) {
      final seg = dash[dashIdx % dash.length];
      final next = (dist + seg).clamp(0.0, total);
      if (draw) {
        canvas.drawLine(start + dir * dist, start + dir * next, paint);
      }
      dist = next;
      dashIdx++;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
