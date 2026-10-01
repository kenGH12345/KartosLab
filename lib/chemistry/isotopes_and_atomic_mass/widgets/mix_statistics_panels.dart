/// Mix accordion shell + Percent Composition pie + Average Atomic Mass indicator.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/mixtures_controller.dart';
import '../iaam_constants.dart';
import '../model/data/data.dart';
import '../model/get_isotope_color.dart';

/// Shared AccordionBox chrome (yellow panel) — PhET expand/collapse (−/+).
class MixAccordionShell extends StatelessWidget {
  const MixAccordionShell({
    super.key,
    required this.title,
    required this.width,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final double width;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: IaamConstants.panelBackground,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  _ExpandCollapseButton(expanded: expanded),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// sun AccordionBox expand/collapse control lookalike.
class _ExpandCollapseButton extends StatelessWidget {
  const _ExpandCollapseButton({required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE36F1E),
        border: Border.all(color: Colors.black54, width: 0.8),
      ),
      child: Text(
        expanded ? '−' : '+',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}

/// PhET IsotopeProportionsPieChart (simplified label layout).
class IsotopeProportionsPieChart extends StatelessWidget {
  const IsotopeProportionsPieChart({
    super.key,
    required this.controller,
  });

  final MixturesController controller;

  static const double pieRadius = 40;
  static const double overallHeight = 120;
  /// PhET `isotopeProportionsPieChart.scale(0.6)`.
  static const double viewScale = 0.6;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final isotopes = m.possibleIsotopes;
    final total = m.totalIsotopeCount;
    final nature = m.showingNaturesMix;

    return SizedBox(
      height: overallHeight * viewScale,
      width: (overallHeight + 80) * viewScale,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          height: overallHeight,
          width: overallHeight + 80,
          child: CustomPaint(
            painter: _PieChartPainter(
              isotopes: isotopes,
              counts: {
                for (final iso in isotopes)
                  iso.massNumber: m.getIsotopeCount(iso.massNumber),
              },
              proportions: {
                for (final iso in isotopes)
                  iso.massNumber: nature
                      ? AtomInfoUtils.getNaturalAbundance(
                          protonCount: iso.atomicNumber,
                          massNumber: iso.massNumber,
                          numDecimalPlaces: 6,
                        )
                      : m.getIsotopeProportion(iso.massNumber),
              },
              total: total,
              nature: nature,
              atomicNumber: m.selectedAtomicNumber,
            ),
          ),
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.isotopes,
    required this.counts,
    required this.proportions,
    required this.total,
    required this.nature,
    required this.atomicNumber,
  });

  final List<IsotopeData> isotopes;
  final Map<int, int> counts;
  final Map<int, double> proportions;
  final int total;
  final bool nature;
  final int atomicNumber;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const r = IsotopeProportionsPieChart.pieRadius;

    if (total <= 0 && !nature) {
      final dash = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..strokeWidth = 1;
      _drawDashedCircle(canvas, center, r, dash);
      return;
    }

    // Nature: use abundance proportions even if chamber particles exist.
    final values = <double>[];
    final colors = <Color>[];
    for (final iso in isotopes) {
      final v = nature
          ? (proportions[iso.massNumber] ?? 0)
          : (counts[iso.massNumber] ?? 0).toDouble();
      values.add(v);
      colors.add(getIsotopeColor(
        protonCount: iso.atomicNumber,
        neutronCount: iso.neutronCount,
      ));
    }
    final sum = values.fold<double>(0, (a, b) => a + b);
    if (sum <= 0) {
      final dash = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..strokeWidth = 1;
      _drawDashedCircle(canvas, center, r, dash);
      return;
    }

    final lightestProp = values.first / sum;
    var start = math.pi - (lightestProp * math.pi);
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / sum) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        sweep,
        true,
        Paint()..color = colors[i],
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        sweep,
        true,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.black,
      );

      // Label at mid-slice
      final mid = start + sweep / 2;
      final edge = Offset(
        center.dx + math.cos(mid) * r,
        center.dy + math.sin(mid) * r,
      );
      final labelPos = Offset(
        center.dx + math.cos(mid) * r * 1.55,
        center.dy + math.sin(mid) * r * 1.55,
      );
      final pct = (proportions[isotopes[i].massNumber] ?? 0) * 100;
      final decimals = nature ? 4 : 1;
      final text = '${isotopes[i].symbol}-${isotopes[i].massNumber} '
          '${toFixedNumber(pct, decimals)}%';
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 11, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
      );
      canvas.drawLine(
        edge,
        labelPos,
        Paint()
          ..color = Colors.black54
          ..strokeWidth = 1,
      );

      start += sweep;
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset c, double r, Paint paint) {
    const dash = 3.0;
    const gap = 1.0;
    final circ = 2 * math.pi * r;
    var drawn = 0.0;
    while (drawn < circ) {
      final a0 = drawn / r;
      final a1 = math.min(drawn + dash, circ) / r;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        a0 - math.pi / 2,
        a1 - a0,
        false,
        paint,
      );
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.total != total ||
      oldDelegate.nature != nature ||
      oldDelegate.atomicNumber != atomicNumber ||
      oldDelegate.counts.toString() != counts.toString();
}

/// PhET AverageAtomicMassIndicator.
class AverageAtomicMassIndicator extends StatelessWidget {
  const AverageAtomicMassIndicator({
    super.key,
    required this.controller,
  });

  final MixturesController controller;

  static const double indicatorWidth = 200;
  static const Color pointerColor = Color.fromARGB(255, 0, 143, 212);

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final isotopes = m.possibleIsotopes;
    var lightest = double.infinity;
    var heaviest = 0.0;
    for (final iso in isotopes) {
      if (iso.atomicMass < lightest) lightest = iso.atomicMass;
      if (iso.atomicMass > heaviest) heaviest = iso.atomicMass;
    }
    var massSpan = heaviest - lightest;
    if (massSpan < 2) massSpan = 2;
    massSpan *= 1.2;
    final minMass = (heaviest + lightest) / 2 - massSpan / 2;

    double xOf(double mass) =>
        math.max(((mass - minMass) / massSpan) * indicatorWidth, 0);

    final total = m.totalIsotopeCount;
    // Pointer uses chamber average when My Mix has particles; Nature uses
    // displayed (standard) mass for readout text but pointer tracks chamber mean
    // in PhET via averageAtomicMassProperty — Nature chamber is filled so pointer moves.
    final avg = m.chamberAverageAtomicMass;
    final display = m.displayedAverageAtomicMass;
    final showPointer = total > 0;

    return SizedBox(
      width: indicatorWidth + 8,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 4,
            top: 18,
            child: Container(
              width: indicatorWidth,
              height: 3,
              color: Colors.black,
            ),
          ),
          for (final iso in isotopes)
            Positioned(
              left: 4 + xOf(iso.atomicMass) - 2.5,
              top: 8,
              child: Column(
                children: [
                  Container(width: 5, height: 12, color: Colors.black),
                  Text(
                    '${iso.massNumber}',
                    style: const TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          if (showPointer)
            Positioned(
              left: 4 + xOf(avg) - 10,
              top: 20,
              child: Column(
                children: [
                  CustomPaint(
                    size: const Size(18, 12),
                    painter: _TrianglePointerPainter(pointerColor),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${toFixed(display, 5)} amu',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TrianglePointerPainter extends CustomPainter {
  _TrianglePointerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePointerPainter oldDelegate) =>
      oldDelegate.color != color;
}
