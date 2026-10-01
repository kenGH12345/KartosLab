import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../model/kl_vec.dart';
import '../render/orbit_render_data.dart';

/// Second-law swept areas.
///
/// [已确认] EllipticalOrbitNode: moveTo(radiusC,0).ellipticalArc(...).close()
class SweptAreaPainter extends CustomPainter {
  SweptAreaPainter({required this.data, required this.visible});

  final OrbitRenderData data;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || !data.allowed) return;
    final mvt = data.mvt;
    final scale = mvt.scale;
    final geoCenter = mvt.toView(KlVec(-data.c, 0));
    canvas.save();
    canvas.translate(geoCenter.dx, geoCenter.dy);
    canvas.rotate(-data.w);

    final radiusX = scale * data.a;
    final radiusY = scale * data.b;
    final radiusC = scale * data.c;

    for (var i = 0; i < data.areas.length; i++) {
      final area = data.areas[i];
      if (!area.active) continue;
      final startLocal = Offset(
        area.start.x * scale + data.c * scale,
        -area.start.y * scale,
      );
      final endLocal = Offset(
        area.end.x * scale + data.c * scale,
        -area.end.y * scale,
      );
      final startAngle =
          math.atan2(startLocal.dy / radiusY, startLocal.dx / radiusX);
      final endAngle = math.atan2(endLocal.dy / radiusY, endLocal.dx / radiusX);

      final path = Path()
        ..moveTo(radiusC, 0)
        ..arcTo(
          Rect.fromCenter(
            center: Offset.zero,
            width: radiusX * 2,
            height: radiusY * 2,
          ),
          startAngle,
          clockwiseSweep(startAngle, endAngle),
          false,
        )
        ..close();

      canvas.drawPath(
        path,
        Paint()..color = area.fill.withValues(alpha: area.alreadyEntered ? 1 : 0),
      );

      if (area.active) {
        final dot = Offset(
          area.dot.x * scale + data.c * scale,
          -area.dot.y * scale,
        );
        canvas.drawCircle(dot, 4, Paint()..color = Colors.black);
        canvas.drawCircle(
          dot,
          4,
          Paint()
            ..color = KeplersLawsColors.orbit
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }

      if (area.active && (data.showAreaValues || data.showTimeValues)) {
        _drawValues(canvas, area, scale, radiusY, i);
      }
    }
    canvas.restore();
  }

  void _drawValues(
    Canvas canvas,
    SweptAreaDraw area,
    double scale,
    double radiusY,
    int i,
  ) {
    final midNu = (area.startAngle + area.endAngle) / 2;
    final r = data.a *
        (1 - data.e * data.e) /
        (1 + data.e * math.cos(midNu));
    var pos = Offset(
      r * math.cos(midNu) * scale + data.c * scale,
      -r * math.sin(midNu) * scale,
    );
    final divisions = data.areas.where((a) => a.active).length;
    if (divisions == 2) {
      pos = Offset(0, 0.8 * radiusY * math.pow(-1, i).toDouble());
    }
    final mag = pos.distance;
    var scaling = 2.0 - (mag - 10) * (2.0 - 1.2) / (250 - 10);
    scaling = scaling.clamp(1.2, 2.0);
    final center = pos * scaling;
    if (data.showAreaValues) {
      _text(
        canvas,
        area.alreadyEntered
            ? area.sweptArea.toStringAsFixed(2)
            : '0.00',
        center + const Offset(0, -12),
      );
    }
    if (data.showTimeValues) {
      _text(
        canvas,
        area.alreadyEntered
            ? area.durationYears.toStringAsFixed(2)
            : '0.00',
        center + const Offset(0, 12),
      );
    }
  }

  void _text(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  /// Clockwise sweep from [start] to [end], in radians, range (0, 2π].
  ///
  /// [已确认] kite `ellipticalArc(..., startAngle, endAngle, false)` —
  /// `anticlockwise=false` 始终沿顺时针走到终点，不是最短弧。
  /// Flutter `Path.arcTo` 正 sweep 在 Y-down 下为屏幕顺时针。
  static double clockwiseSweep(double start, double end) {
    var d = end - start;
    d %= 2 * math.pi;
    if (d < 0) {
      d += 2 * math.pi;
    }
    return d;
  }

  @override
  bool shouldRepaint(covariant SweptAreaPainter old) =>
      old.data != data || old.visible != visible;
}
