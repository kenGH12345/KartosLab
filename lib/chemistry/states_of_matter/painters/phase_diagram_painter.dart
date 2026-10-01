import 'package:flutter/material.dart';

import '../som_colors.dart';
import '../som_strings.dart';
import 'som_graph_axes.dart';

/// Phase diagram — PhET `PhaseDiagram` regions + shared L-arrow axes chrome.
///
/// Layout proportions from PhET `PhaseDiagram.ts` (functional, not pixel-perfect).
class PhaseDiagramPainter extends CustomPainter {
  PhaseDiagramPainter({
    required this.normalizedTemperature,
    required this.normalizedPressure,
    this.depictingWater = false,
  });

  /// 0..1 mapped onto diagram usable range (caller maps Kelvin/model → diagram).
  final double normalizedTemperature;
  final double normalizedPressure;
  final bool depictingWater;

  static const double _w = 148;
  static const double _h = 111;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _w;
    final sy = size.height / _h;
    canvas.save();
    canvas.scale(sx, sy);

    const xOrigin = 0.10 * _w;
    const yOrigin = 0.85 * _h;
    const xUsable = _w * 0.85 - 8;
    const yUsable = _h * (0.85 - 0.11);

    final triple = Offset(
      xOrigin + xUsable * 0.35,
      yOrigin - yUsable * 0.2,
    );
    final critical = Offset(
      xOrigin + xUsable * 0.8,
      yOrigin - yUsable * 0.45,
    );
    final topSolidLiquid = depictingWater
        ? Offset(xUsable * 0.30 + xOrigin, yOrigin - yUsable)
        : Offset(xUsable * 0.40 + xOrigin, yOrigin - yUsable);

    // Gas (yellow)
    final gasPath = Path()
      ..moveTo(triple.dx, triple.dy)
      ..lineTo(critical.dx, critical.dy)
      ..lineTo(xOrigin + xUsable, yOrigin)
      ..lineTo(triple.dx, yOrigin)
      ..close();
    canvas.drawPath(gasPath, Paint()..color = const Color(0xFFFFBC00));

    // Super-critical (green-yellow)
    final scPath = Path()
      ..moveTo(critical.dx, critical.dy)
      ..lineTo(xOrigin + xUsable, yOrigin - yUsable)
      ..lineTo(xOrigin + xUsable, yOrigin)
      ..close();
    canvas.drawPath(scPath, Paint()..color = const Color(0xFFC3DF53));

    // Liquid
    final liquidPath = Path()
      ..moveTo(triple.dx, triple.dy)
      ..lineTo(topSolidLiquid.dx, topSolidLiquid.dy)
      ..lineTo(critical.dx, critical.dy)
      ..close();
    canvas.drawPath(liquidPath, Paint()..color = const Color(0xFF83FFB9));

    // Solid
    final solidPath = Path()
      ..moveTo(xOrigin, yOrigin)
      ..lineTo(xOrigin, yOrigin - yUsable)
      ..lineTo(topSolidLiquid.dx, topSolidLiquid.dy)
      ..lineTo(triple.dx, triple.dy)
      ..close();
    canvas.drawPath(solidPath, Paint()..color = const Color(0xFF63D0FF));

    final linePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(xOrigin, yOrigin), triple, linePaint);
    canvas.drawLine(triple, critical, linePaint);
    canvas.drawLine(triple, topSolidLiquid, linePaint);

    // Triple / critical markers
    canvas.drawCircle(triple, 2.5, Paint()..color = Colors.black);
    canvas.drawCircle(critical, 2.5, Paint()..color = Colors.black);

    void label(String text, Offset at, {double fontSize = 10}) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: Colors.black87, fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(at.dx - tp.width / 2, at.dy - tp.height / 2));
    }

    label(SomStrings.solid, Offset(xOrigin + xUsable * 0.195, yOrigin - yUsable * 0.9));
    label(SomStrings.liquid, Offset(xOrigin + xUsable * 0.65, yOrigin - yUsable * 0.9));
    label(SomStrings.gas, Offset(xOrigin + xUsable * 0.7, yOrigin - yUsable * 0.15));

    // Current state marker
    final tx = (normalizedTemperature.clamp(0.0, 1.0) * xUsable) + xOrigin;
    final ty = yOrigin - (normalizedPressure.clamp(0.0, 1.0) * yUsable);
    canvas.drawCircle(Offset(tx, ty), 3.5, Paint()..color = const Color(0xFFE50000));

    // Shared L-arrow axes (same chrome as LJ potential graph)
    SomGraphAxes.drawLAxes(
      canvas,
      origin: const Offset(xOrigin, yOrigin),
      right: xOrigin + xUsable + 4,
      top: yOrigin - yUsable - 4,
      color: Colors.black87,
      stroke: 1.6,
      head: 6,
    );

    SomGraphAxes.drawBottomLabel(
      canvas,
      SomStrings.temperature,
      plotCenterX: xOrigin + xUsable * 0.5,
      y: yOrigin + 14,
      fontSize: 9,
      color: Colors.black87,
    );
    SomGraphAxes.drawLeftLabel(
      canvas,
      SomStrings.pressure,
      x: xOrigin - 12,
      plotCenterY: yOrigin - yUsable * 0.5,
      fontSize: 9,
      color: Colors.black87,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PhaseDiagramPainter oldDelegate) =>
      oldDelegate.normalizedTemperature != normalizedTemperature ||
      oldDelegate.normalizedPressure != normalizedPressure ||
      oldDelegate.depictingWater != depictingWater;
}

/// Thin wrapper panel for the phase diagram.
class PhaseDiagramPanel extends StatelessWidget {
  const PhaseDiagramPanel({
    super.key,
    required this.normalizedTemperature,
    required this.normalizedPressure,
    this.width = 160,
    this.contentWidth,
    this.contentHeight,
    this.expanded = true,
    this.onToggle,
  });

  final double normalizedTemperature;
  final double normalizedPressure;
  final double width;

  /// PhET `PhaseDiagram` canvas size (defaults to width-derived 0.75 aspect).
  final double? contentWidth;
  final double? contentHeight;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final diagramW = contentWidth ?? (width - 12);
    final diagramH = contentHeight ?? (diagramW * 0.75);
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: SomColors.controlPanelBackground,
        border: Border.all(color: SomColors.controlPanelStroke),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      SomStrings.phaseDiagram,
                      style: const TextStyle(
                        color: SomColors.controlPanelText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    expanded ? '▾' : '▸',
                    style: const TextStyle(color: SomColors.controlPanelText),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Center(
                child: SizedBox(
                  width: diagramW,
                  height: diagramH,
                  child: CustomPaint(
                    painter: PhaseDiagramPainter(
                      normalizedTemperature: normalizedTemperature,
                      normalizedPressure: normalizedPressure,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
