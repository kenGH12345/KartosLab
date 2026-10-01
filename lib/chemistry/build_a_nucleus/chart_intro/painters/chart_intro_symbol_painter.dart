/// 同位素符号盒 Painter。对标 shred `SymbolNode`（无电荷）。
library;

import 'package:flutter/material.dart';

import '../chart_intro_visuals.dart';
import '../render/chart_intro_symbol_render.dart';

class ChartIntroSymbolPainter extends CustomPainter {
  ChartIntroSymbolPainter({required this.render});

  final ChartIntroSymbolRender render;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(ChartIntroVisuals.isotopeSymbolScale);

    const box = Rect.fromLTWH(
      0,
      0,
      ChartIntroVisuals.isotopeSymbolBoxWidth,
      ChartIntroVisuals.isotopeSymbolBoxHeight,
    );
    canvas.drawRect(box, Paint()..color = ChartIntroVisuals.isotopeSymbolBoxFill);
    canvas.drawRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ChartIntroVisuals.isotopeSymbolBoxStrokeWidth
        ..color = ChartIntroVisuals.isotopeSymbolBoxStroke,
    );

    _paintCentered(
      canvas,
      render.symbol,
      ChartIntroVisuals.isotopeSymbolFontSize,
      Colors.black,
      Offset(box.center.dx, box.center.dy),
    );

    _paintAnchored(
      canvas,
      '${render.massNumber}',
      ChartIntroVisuals.isotopeNumberFontSize,
      Colors.black,
      left: ChartIntroVisuals.isotopeNumberInset,
      top: ChartIntroVisuals.isotopeNumberInset,
    );

    _paintAnchored(
      canvas,
      '${render.protonCount}',
      ChartIntroVisuals.isotopeNumberFontSize,
      ChartIntroVisuals.isotopeProtonNumber,
      left: ChartIntroVisuals.isotopeNumberInset,
      bottom: ChartIntroVisuals.isotopeSymbolBoxHeight -
          ChartIntroVisuals.isotopeNumberInset,
    );

    canvas.restore();
  }

  void _paintCentered(
    Canvas canvas,
    String text,
    double fontSize,
    Color color,
    Offset center,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  void _paintAnchored(
    Canvas canvas,
    String text,
    double fontSize,
    Color color, {
    required double left,
    double? top,
    double? bottom,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dy = top ?? (bottom! - tp.height);
    tp.paint(canvas, Offset(left, dy));
  }

  @override
  bool shouldRepaint(covariant ChartIntroSymbolPainter old) =>
      old.render != render;
}
