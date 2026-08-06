import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../model/single_bulb_state.dart';
import '../model/filter.dart';
import '../solver/color_model.dart';

/// Paints the single-bulb filter simulation.
///
/// Renders:
/// - White light source photons before the filter
/// - Filter bar at [filterX] with active filter color
/// - Filtered photons after the filter (color-changed)
/// - Person figure with perceived color label
class SingleBulbPainter extends CustomPainter {
  final SingleBulbState state;

  SingleBulbPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final fx = state.filterX;

    // ---- 场景居中 + 放大变换 ----
    // 模型内固定 x 范围: bulb(50) ~ person(320) ; 场景垂直中心 y=190
    // 目标: 让 [30, 340] × [100, 290] 这块区域按等比缩放填满 canvas 的 90%,
    // 并水平/垂直居中. 之后所有 draw 都在此坐标系中进行, 模型不需感知.
    const sceneMinX = 30.0, sceneMaxX = 340.0;
    const sceneMinY = 100.0, sceneMaxY = 290.0;
    final sceneW = sceneMaxX - sceneMinX;
    final sceneH = sceneMaxY - sceneMinY;
    final scale = (size.width * 0.92 / sceneW)
        .clamp(0.5, size.height * 0.95 / sceneH);
    final drawnW = sceneW * scale;
    final drawnH = sceneH * scale;
    final dx = (size.width - drawnW) / 2 - sceneMinX * scale;
    final dy = (size.height - drawnH) / 2 - sceneMinY * scale;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    // Draw source indicator (color depends on bulb mode)
    final srcColor = state.bulbMode == BulbMode.mono ? state.bulbColor : const Color(0xFFFFFFFF);
    final srcPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = srcColor;
    canvas.drawCircle(const Offset(50, 190), 12, srcPaint);
    canvas.drawCircle(const Offset(50, 190), 14,
      Paint()..style = PaintingStyle.stroke..color = const Color(0xFFCBD5E1)..strokeWidth = 2);

    // Draw photons
    for (final p in state.beam.alive) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = p.color;
      canvas.drawCircle(Offset(p.x, p.y), 3, paint);
    }

    // Draw filter bar
    _drawFilter(canvas, fx);

    // Draw person
    _drawPerson(canvas, state.personPosition, 190, _perceivedColor());

    canvas.restore();
  }

  void _drawFilter(Canvas canvas, double x) {
    // Filter background glow (semi-transparent fill around the filter zone)
    canvas.drawRect(
      Rect.fromLTWH(x - 7, 130, 14, 120),
      Paint()..color = const Color(0xFF475569).withAlpha(30),
    );
    // Filter body (dark gray bar)
    canvas.drawRect(
      Rect.fromLTWH(x - 4, 135, 8, 110),
      Paint()..color = const Color(0xFF334155),
    );
    // Left edge highlight
    canvas.drawRect(
      Rect.fromLTWH(x - 4, 135, 2, 110),
      Paint()..color = const Color(0xFF64748B),
    );

    // Filter indicator (colored ring showing active filter)
    Color indicatorColor;
    String filterLabel;
    switch (state.filter.type) {
      case FilterType.none:
        indicatorColor = const Color(0xFFCBD5E1);
        filterLabel = 'No Filter';
        break;
      case FilterType.red:
        indicatorColor = const Color(0xFFFF0000);
        filterLabel = 'Red Filter';
        break;
      case FilterType.green:
        indicatorColor = const Color(0xFF00FF00);
        filterLabel = 'Green Filter';
        break;
      case FilterType.blue:
        indicatorColor = const Color(0xFF0000FF);
        filterLabel = 'Blue Filter';
        break;
      case FilterType.custom:
        indicatorColor = Color.fromARGB(255,
          (state.filter.customR * 255).round(),
          (state.filter.customG * 255).round(),
          (state.filter.customB * 255).round(),
        );
        filterLabel = 'Custom';
        break;
    }

    // Colored indicator dot below filter
    canvas.drawCircle(Offset(x, 255), 7,
      Paint()
        ..style = PaintingStyle.fill
        ..color = indicatorColor);
    canvas.drawCircle(Offset(x, 255), 7,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 1.5);

    // "FILTER" label above the bar
    final labelTp = TextPainter(
      text: TextSpan(
        text: 'FILTER',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    labelTp.paint(canvas, Offset(x - labelTp.width / 2, 115));

    // Filter name below the bar
    final nameTp = TextPainter(
      text: TextSpan(
        text: filterLabel,
        style: TextStyle(
          color: indicatorColor,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    nameTp.paint(canvas, Offset(x - nameTp.width / 2, 270));
  }

  Color _perceivedColor() {
    // Calculate what the person sees based on filter
    if (state.filter.type == FilterType.none) {
      return ColorModel.mixRGB(100, 100, 100); // white
    }
    final (pr, pg, pb) = state.filter.passRates;
    return Color.fromARGB(255,
      (255 * pr).round(),
      (255 * pg).round(),
      (255 * pb).round(),
    );
  }

  void _drawPerson(Canvas canvas, double x, double y, Color perceived) {
    // Head
    final headPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawCircle(Offset(x, y - 12), 10, headPaint);
    // Body
    canvas.drawRect(
      Rect.fromLTWH(x - 6, y, 12, 20),
      Paint()..color = const Color(0xFF475569),
    );
    // Perceived color indicator
    canvas.drawCircle(
      Offset(x + 18, y - 12),
      8,
      Paint()..color = perceived,
    );
    // Color label
    final tp = TextPainter(
      text: TextSpan(
        text: ColorModel.colorName(perceived),
        style: TextStyle(
          color: perceived.computeLuminance() > 0.5
              ? const Color(0xFF1E293B)
              : const Color(0xFFF8FAFC),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x + 30, y - 18));
  }

  @override
  bool shouldRepaint(SingleBulbPainter oldDelegate) => true;
}
