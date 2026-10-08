import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/energy_graph_data.dart';
import '../../model/hookes_law_numbers.dart';
import '../../model/spring.dart';
import '../intro/intro_play_painter.dart';
import '../phet_font.dart';
import 'energy_scene_painter.dart';
import 'energy_view_properties.dart';

/// Elastic potential energy. `HookesLawColors.energyColor`.
const energyColor = Color.fromRGBO(0, 204, 255, 1);

/// Bar graph, Energy Plot, and Force Plot. One painter.
///
/// Physics stays in [EnergyGraphData] and [Spring]. This file only maps
/// those values into view coordinates.
class EnergyGraphPainter extends CustomPainter {
  EnergyGraphPainter({
    required this.spring,
    required this.properties,
    required this.barAxisY,
  });

  final Spring spring;
  final EnergyViewProperties properties;
  final double barAxisY;

  @override
  void paint(Canvas canvas, Size size) {
    final barX = properties.graph == EnergyGraphKind.barGraph
        ? energyPlotOriginX(spring)
        : HookesLawConstants.energyBarWhenPlotLeft;
    _paintBar(canvas, Offset(barX, barAxisY));

    final originX = energyPlotOriginX(spring);
    if (properties.showEnergyPlot) {
      _paintEnergyPlot(canvas, Offset(originX, barAxisY));
    } else if (properties.showForcePlot) {
      // `forcePlot.bottom = barGraph.bottom`. The downward axis is half of
      // FORCE_Y_AXIS_LENGTH, so the origin sits that far above the bar axis.
      _paintForcePlot(
        canvas,
        Offset(originX, barAxisY - HookesLawConstants.forceYAxisLength / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant EnergyGraphPainter oldDelegate) => true;

  void _paintBar(Canvas canvas, Offset axis) {
    final sample = EnergyGraphData.energyBar(spring);
    final axisLength = HookesLawConstants.energyBarAxisLengthFactor * HookesLawConstants.energyBarWidth;
    final barLeft = axis.dx + axisLength / 2 - HookesLawConstants.energyBarWidth / 2;
    if (sample.visible) {
      canvas.drawRect(
        Rect.fromLTWH(barLeft, axis.dy - sample.height, HookesLawConstants.energyBarWidth, sample.height),
        Paint()..color = energyColor,
      );
    }
    canvas.drawLine(
      axis,
      axis + Offset(axisLength, 0),
      Paint()
        ..color = const Color(0xFF000000)
        ..strokeWidth = 0.25,
    );
    _arrow(
      canvas,
      axis,
      axis + const Offset(0, -HookesLawConstants.energyYAxisLength),
    );
    _rotatedLabel(canvas, '势能', axis + const Offset(-14, -HookesLawConstants.energyYAxisLength / 2));
    if (properties.valuesVisible) {
      final text = '${sample.energy.toStringAsFixed(HookesLawConstants.energyDecimalPlaces)} J';
      final label = _measure(text, energyColor, 16);
      final double top;
      if (!sample.visible || sample.height < label.height / 2) {
        top = axis.dy - label.height;
      } else {
        top = axis.dy - sample.height - label.height / 2;
      }
      label.paint(canvas, Offset(barLeft + HookesLawConstants.energyBarWidth + 5, top));
    }
  }

  void _paintEnergyPlot(Canvas canvas, Offset origin) {
    final bezier = EnergyGraphData.energyPlotBezier(spring);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.clipRect(Rect.fromLTRB(bezier.viewMinX, -bezier.viewMaxY, bezier.viewMaxX, 24));
    final path = Path()
      ..moveTo(-bezier.x1, bezier.y1)
      ..quadraticBezierTo(-bezier.cpx, bezier.cpy, bezier.x3, bezier.y3)
      ..quadraticBezierTo(bezier.cpx, bezier.cpy, bezier.x1, bezier.y1);
    canvas.drawPath(
      path,
      Paint()
        ..color = energyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = HookesLawConstants.energyPlotLineWidth,
    );
    _axes(canvas, bezier.viewMinX, bezier.viewMaxX, 0, -bezier.viewMaxY, '位移', '势能');
    _pointAndGuides(
      canvas,
      xMeters: spring.displacement,
      yModel: spring.potentialEnergy,
      yUnit: HookesLawConstants.unitEnergyY,
      xPlaces: HookesLawConstants.displacementDecimalPlaces,
      yPlaces: HookesLawConstants.energyDecimalPlaces,
      xUnits: 'm',
      yUnits: 'J',
      yColor: energyColor,
      minYIsZero: true,
    );
    canvas.restore();
  }

  void _paintForcePlot(Canvas canvas, Offset origin) {
    final line = EnergyGraphData.forcePlotLine(spring);
    final triangle = EnergyGraphData.forcePlotEnergyTriangle(spring);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.clipRect(Rect.fromLTRB(line.viewMinX, line.viewMinY, line.viewMaxX, line.viewMaxY));
    if (triangle.visible && properties.energyOnForcePlotVisible) {
      final area = Path()
        ..moveTo(triangle.originX, triangle.originY)
        ..lineTo(triangle.x, 0)
        ..lineTo(triangle.x, triangle.y)
        ..close();
      canvas.drawPath(area, Paint()..color = energyColor);
    }
    canvas.drawLine(
      Offset(line.x0, line.y0),
      Offset(line.x1, line.y1),
      Paint()
        ..color = IntroColors.appliedForce
        ..strokeWidth = HookesLawConstants.energyPlotLineWidth,
    );
    _axes(canvas, line.viewMinX, line.viewMaxX, line.viewMaxY, line.viewMinY, '位移', '外力');
    _pointAndGuides(
      canvas,
      xMeters: spring.displacement,
      yModel: spring.appliedForce,
      yUnit: HookesLawConstants.unitForceY,
      xPlaces: HookesLawConstants.displacementDecimalPlaces,
      yPlaces: HookesLawConstants.appliedForceDecimalPlaces,
      xUnits: 'm',
      yUnits: 'N',
      yColor: IntroColors.appliedForce,
      minYIsZero: false,
    );
    canvas.restore();
  }

  void _pointAndGuides(
    Canvas canvas, {
    required double xMeters,
    required double yModel,
    required double yUnit,
    required int xPlaces,
    required int yPlaces,
    required String xUnits,
    required String yUnits,
    required Color yColor,
    required bool minYIsZero,
  }) {
    final xFixed = HookesLawNumbers.toFixedNumber(xMeters, HookesLawConstants.displacementDecimalPlaces);
    final xView = HookesLawConstants.unitDisplacementX * xFixed;
    final yView = -yModel * yUnit;
    if (properties.displacementVectorVisible && xFixed != 0) {
      canvas.drawLine(
        Offset.zero,
        Offset(xView, 0),
        Paint()
          ..color = IntroColors.displacement
          ..strokeWidth = 3,
      );
    }
    if (properties.valuesVisible && xFixed != 0) {
      canvas.drawLine(Offset(xView, -6), Offset(xView, 6), Paint()..strokeWidth = 1);
      _dashed(canvas, Offset(xView, 0), Offset(xView, yView));
      _dashed(canvas, Offset(0, yView), Offset(xView, yView));
      final xText = '${xFixed.toStringAsFixed(xPlaces)} $xUnits';
      final yText = '${yModel.toStringAsFixed(yPlaces)} $yUnits';
      final xLabel = _measure(xText, IntroColors.displacement, 18);
      final yLabel = _measure(yText, yColor, 18);
      final double xLeft;
      final double xTop;
      if (minYIsZero || xView.abs() > 6 + xLabel.width / 2) {
        xLeft = xView - xLabel.width / 2;
      } else if (xFixed >= 0) {
        xLeft = 6;
      } else {
        xLeft = -6 - xLabel.width;
      }
      if (minYIsZero || yModel >= 0) {
        xTop = 12;
      } else {
        xTop = -12 - xLabel.height;
      }
      final double yLeft = xFixed >= 0 ? -10 - yLabel.width : 10;
      final double yTop;
      if (yView.abs() > 4 + yLabel.height / 2) {
        yTop = yView - yLabel.height / 2;
      } else if (yModel >= 0) {
        yTop = -4 - yLabel.height;
      } else {
        yTop = 4;
      }
      xLabel.paint(canvas, Offset(xLeft, xTop));
      yLabel.paint(canvas, Offset(yLeft, yTop));
    }
    canvas.drawCircle(Offset(xView, yView), HookesLawConstants.energyPointRadius, Paint()..color = IntroColors.springMiddle);
  }

  void _axes(
    Canvas canvas,
    double minX,
    double maxX,
    double downY,
    double upY,
    String xTitle,
    String yTitle,
  ) {
    _arrow(canvas, Offset(minX, 0), Offset(maxX, 0));
    _arrow(canvas, Offset(0, downY), Offset(0, upY));
    _label(canvas, xTitle, Offset(maxX + 4, -8), const Color(0xFF000000), below: false);
    _label(canvas, yTitle, Offset(-40, upY - 16), const Color(0xFF000000), below: false);
  }
}

void _arrow(Canvas canvas, Offset from, Offset to) {
  canvas.drawLine(from, to, Paint()..strokeWidth = 1);
  final dir = to - from;
  final length = dir.distance;
  if (length < 1) {
    return;
  }
  final unit = dir / length;
  final tip = to;
  final base = to - unit * 10;
  final normal = Offset(-unit.dy, unit.dx) * 5;
  final head = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(base.dx + normal.dx, base.dy + normal.dy)
    ..lineTo(base.dx - normal.dx, base.dy - normal.dy)
    ..close();
  canvas.drawPath(head, Paint());
}

void _dashed(Canvas canvas, Offset a, Offset b) {
  final delta = b - a;
  final length = delta.distance;
  if (length < 1) {
    return;
  }
  final unit = delta / length;
  var traveled = 0.0;
  final paint = Paint()..strokeWidth = 1;
  while (traveled < length) {
    final start = a + unit * traveled;
    final end = a + unit * (traveled + 3).clamp(0, length);
    canvas.drawLine(start, end, paint);
    traveled += 6;
  }
}

void _label(Canvas canvas, String text, Offset topLeft, Color color, {required bool below, double fontSize = 16}) {
  final painter = _measure(text, color, fontSize);
  painter.paint(canvas, below ? topLeft : topLeft - Offset(0, painter.height));
}

TextPainter _measure(String text, Color color, double fontSize) {
  return TextPainter(
    text: TextSpan(text: text, style: PhetFont.of(fontSize, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
}

void _rotatedLabel(Canvas canvas, String text, Offset center) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: PhetFont.of(16),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: HookesLawConstants.energyYAxisLength * 0.65);
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(-1.57079632679);
  painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  canvas.restore();
}
