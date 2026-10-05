import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../render/orbit_render_data.dart';
import '../render/orbit_view.dart';

/// Second-law swept areas.
///
/// [已确认] EllipticalOrbitNode: pie from sun through true-anomaly arc.
class SweptAreaPainter extends CustomPainter {
  SweptAreaPainter({required this.data, required this.visible});

  final OrbitRenderData data;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || !data.allowed) return;
    final sunView = data.mvt.toView(data.sunPos);

    for (var i = 0; i < data.areas.length; i++) {
      final area = data.areas[i];
      if (!area.active) continue;

      final path = Path()..moveTo(sunView.dx, sunView.dy);
      addTrueAnomalyArc(
        path,
        data,
        area.startAngle,
        area.endAngle,
        retrograde: data.retrograde,
      );
      path.close();

      canvas.drawPath(
        path,
        Paint()..color = area.fill.withValues(alpha: area.alreadyEntered ? 1 : 0),
      );

      if (area.active) {
        final dot = data.mvt.toView(area.dot);
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
        _drawValues(canvas, area, i);
      }
    }
  }

  void _drawValues(Canvas canvas, SweptAreaDraw area, int i) {
    final midNu = (area.startAngle + area.endAngle) / 2;
    var pos = orbitViewPoint(data, midNu);
    final divisions = data.areas.where((a) => a.active).length;
    if (divisions == 2) {
      final geo = data.mvt.toView(orbitGeoCenter(data));
      final sign = i.isEven ? 1.0 : -1.0;
      pos = Offset(geo.dx, geo.dy + 0.8 * data.mvt.scale * data.b * sign);
    }
    final mag = (pos - data.mvt.toView(data.sunPos)).distance;
    var scaling = 2.0 - (mag - 10) * (2.0 - 1.2) / (250 - 10);
    scaling = scaling.clamp(1.2, 2.0);
    final sun = data.mvt.toView(data.sunPos);
    final center = sun + (pos - sun) * scaling;
    if (data.showAreaValues) {
      _text(
        canvas,
        area.alreadyEntered ? area.sweptArea.toStringAsFixed(2) : '0.00',
        center + const Offset(0, -12),
      );
    }
    if (data.showTimeValues) {
      _text(
        canvas,
        area.alreadyEntered ? area.durationYears.toStringAsFixed(2) : '0.00',
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

  @override
  bool shouldRepaint(covariant SweptAreaPainter old) =>
      old.data != data || old.visible != visible;
}
