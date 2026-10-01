import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/lj_potential_calculator.dart';
import '../som_colors.dart';
import '../som_strings.dart';
import 'som_graph_axes.dart';

/// Lennard-Jones potential graph — PhET `PotentialGraphNode` + canvas curve.
///
/// Matches ORIGINAL: L-shaped white arrow axes, mid zero-energy line, grey
/// grid, red curve, cyan well marker, white σ / ε.
class LjPotentialGraphPainter extends CustomPainter {
  LjPotentialGraphPainter({
    required this.calculator,
    this.markerDistance,
    this.showMarker = true,
  });

  final LjPotentialCalculator calculator;
  final double? markerDistance;
  final bool showMarker;

  static const Color _curve = Color(0xFFE50000);
  static const Color _marker = Color(0xFF75D9FF);

  @override
  void paint(Canvas canvas, Size size) {
    // PhET: graphXOrigin≈8%W, graphYOrigin≈88%H
    final graphX0 = size.width * 0.10;
    final graphY0 = size.height * 0.86;
    final graphW = size.width - graphX0 - 12;
    final graphH = size.height * 0.70;

    final plot = Rect.fromLTWH(graphX0, graphY0 - graphH, graphW, graphH);
    canvas.drawRect(plot, Paint()..color = Colors.black);

    // Grey grid — 3×3 cells (2 interior lines each way)
    final gridPaint = Paint()
      ..color = SomGraphAxes.grid
      ..strokeWidth = 0.85;
    for (var i = 1; i <= 2; i++) {
      final x = plot.left + plot.width * (i / 3);
      final y = plot.top + plot.height * (i / 3);
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
    }

    // Zero-energy ≈ topmost interior grid line (matches reference chrome)
    final zeroY = plot.top + plot.height / 3;
    canvas.drawLine(
      Offset(plot.left, zeroY),
      Offset(plot.right, zeroY),
      Paint()
        ..color = SomGraphAxes.grid
        ..strokeWidth = 1.0,
    );

    final sigma = calculator.getSigma();
    final rMin = calculator.getMinimumForceDistance();
    final well = calculator.getLjPotential(rMin);
    final wellDepth = well.abs().clamp(1e-40, double.infinity);

    // |ε| spans most of the space below zero → near plot bottom
    final yBelow = (plot.bottom - zeroY) * 0.82;
    final yAbove = (zeroY - plot.top) * 0.92;
    final xMax = sigma * 2.75;
    const xMin = 0.0;

    double xToPx(double r) =>
        plot.left + (r.clamp(xMin, xMax) - xMin) / (xMax - xMin) * plot.width;

    double yToPx(double v) {
      // Positive potential → above zero; negative well → below
      final scale = v >= 0 ? yAbove / wellDepth : yBelow / wellDepth;
      return zeroY - v * scale;
    }

    // Curve — start slightly above 0.55σ to avoid off-plot spike
    const samples = 140;
    final curve = Path();
    var started = false;
    double? zeroCrossX;
    for (var i = 0; i <= samples; i++) {
      final r = xMin + (xMax - xMin) * (i / samples);
      if (r < sigma * 0.52) continue;
      final v = calculator.getLjPotential(r);
      final px = xToPx(r);
      final py = yToPx(v).clamp(plot.top + 1, plot.bottom - 1);
      if (!started) {
        curve.moveTo(px, py);
        started = true;
      } else {
        curve.lineTo(px, py);
      }
      // First zero crossing (σ)
      if (zeroCrossX == null && i > 0) {
        final prevR = xMin + (xMax - xMin) * ((i - 1) / samples);
        if (prevR >= sigma * 0.52) {
          final prevV = calculator.getLjPotential(prevR);
          if (prevV > 0 && v <= 0) {
            zeroCrossX = px;
          }
        }
      }
    }
    canvas.drawPath(
      curve,
      Paint()
        ..color = _curve
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );

    // L-shaped axes with arrowheads (origin = bottom-left of plot)
    SomGraphAxes.drawLAxes(
      canvas,
      origin: Offset(plot.left, plot.bottom),
      right: plot.right + 8,
      top: plot.top - 8,
    );

    // σ double-headed arrow on zero line: Y-axis → zero crossing
    final sigmaEndX = (zeroCrossX ?? xToPx(sigma)).clamp(plot.left + 10, plot.right);
    SomGraphAxes.drawDoubleHeadArrow(
      canvas,
      Offset(plot.left, zeroY),
      Offset(sigmaEndX, zeroY),
      head: 6,
      tail: 2.2,
    );
    final sigmaLabel = TextPainter(
      text: const TextSpan(
        text: 'σ',
        style: TextStyle(
          color: SomGraphAxes.axis,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    sigmaLabel.paint(
      canvas,
      Offset(
        (plot.left + sigmaEndX) / 2 - sigmaLabel.width / 2,
        zeroY - sigmaLabel.height - 1,
      ),
    );

    // Well position + cyan sphere (equilibrium / marker)
    final wellX = xToPx(rMin);
    final wellY = yToPx(well).clamp(zeroY + 4, plot.bottom - 4);

    // ε label just above the well marker (PhET: near zero line / above sphere)
    final epsLabel = TextPainter(
      text: const TextSpan(
        text: 'ε',
        style: TextStyle(
          color: SomGraphAxes.axis,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    epsLabel.paint(
      canvas,
      Offset(wellX - epsLabel.width / 2, wellY - epsLabel.height - 10),
    );

    // Cyan 3D sphere at well (and/or live marker)
    final markerR = showMarker && markerDistance != null
        ? markerDistance!.clamp(sigma * 0.52, xMax)
        : rMin;
    final mX = xToPx(markerR);
    final mY = yToPx(calculator.getLjPotential(markerR))
        .clamp(plot.top + 4, plot.bottom - 4);
    _drawCyanSphere(canvas, Offset(mX, mY), 6);

    // Axis labels
    SomGraphAxes.drawBottomLabel(
      canvas,
      SomStrings.distanceBetweenAtoms,
      plotCenterX: plot.center.dx,
      y: size.height - 2,
      fontSize: 11,
    );
    SomGraphAxes.drawLeftLabel(
      canvas,
      SomStrings.potentialEnergy,
      x: 3,
      plotCenterY: plot.center.dy,
      fontSize: 11,
    );
  }

  void _drawCyanSphere(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          c + Offset(-r * 0.35, -r * 0.35),
          r * 1.2,
          const [
            Color(0xFFE8FFFF),
            _marker,
            Color(0xFF2A8FB0),
          ],
          const [0.0, 0.45, 1.0],
        ),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant LjPotentialGraphPainter oldDelegate) =>
      oldDelegate.calculator.getSigma() != calculator.getSigma() ||
      oldDelegate.calculator.getEpsilon() != calculator.getEpsilon() ||
      oldDelegate.markerDistance != markerDistance ||
      oldDelegate.showMarker != showMarker;
}

class LjPotentialGraphPanel extends StatelessWidget {
  const LjPotentialGraphPanel({
    super.key,
    required this.calculator,
    this.markerDistance,
    this.width = 160,
    this.height = 100,
    this.expanded = true,
    this.onToggle,
    this.showHeader = true,
  });

  final LjPotentialCalculator calculator;
  final double? markerDistance;
  final double width;
  final double height;
  final bool expanded;
  final VoidCallback? onToggle;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final graph = SizedBox(
      width: showHeader ? width - 8 : width,
      height: height,
      child: CustomPaint(
        painter: LjPotentialGraphPainter(
          calculator: calculator,
          markerDistance: markerDistance,
        ),
      ),
    );

    if (!showHeader) {
      return SizedBox(width: width, height: height, child: graph);
    }

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      SomStrings.interactionPotential,
                      style: const TextStyle(
                        color: SomColors.controlPanelText,
                        fontSize: 12,
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
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: graph,
            ),
        ],
      ),
    );
  }
}
