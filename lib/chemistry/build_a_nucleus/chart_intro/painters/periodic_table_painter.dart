/// 周期表格子 Painter。只画 [PeriodicTableRender]，不读 State / Repository。
library;

import 'package:flutter/material.dart';

import '../chart_intro_visuals.dart';
import '../render/periodic_table_render.dart';

class PeriodicTablePainter extends CustomPainter {
  PeriodicTablePainter({required this.render});

  final PeriodicTableRender render;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(ChartIntroVisuals.periodicTableScale);
    for (final cell in render.cells) {
      canvas.drawRect(cell.rect, Paint()..color = cell.fill);
      canvas.drawRect(
        cell.rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell.strokeWidth
          ..color = cell.stroke,
      );
      _paintSymbol(canvas, cell);
    }
    canvas.restore();
  }

  void _paintSymbol(Canvas canvas, PeriodicTableCellVisual cell) {
    if (cell.symbol.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(
        text: cell.symbol,
        style: TextStyle(
          fontSize: ChartIntroVisuals.periodicTableSymbolFontSize,
          color: cell.labelColor,
          fontWeight: cell.labelWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: ChartIntroVisuals.periodicTableCellSize - 1);
    tp.paint(
      canvas,
      Offset(
        cell.rect.center.dx - tp.width / 2,
        cell.rect.center.dy - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant PeriodicTablePainter old) =>
      old.render != render;
}
