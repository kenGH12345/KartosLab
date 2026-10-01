import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/lab_controller.dart';
import '../plinko_colors.dart';
import '../plinko_strings.dart';
import 'lab_right_panel_layout.dart';

/// Lab statistics — `StatisticsAccordionBox.js` (AccordionBox + EquationNode).
///
/// View/layout/formatting only — does not change histogram math.
class StatisticsAccordionBox extends StatefulWidget {
  const StatisticsAccordionBox({
    super.key,
    required this.controller,
    this.layoutScale = 1.0,
  });

  final LabController controller;
  final double layoutScale;

  @override
  State<StatisticsAccordionBox> createState() => _StatisticsAccordionBoxState();
}

class _StatisticsAccordionBoxState extends State<StatisticsAccordionBox> {
  bool _expanded = true;

  double get s => widget.layoutScale;

  @override
  Widget build(BuildContext context) {
    final m = widget.controller.model;
    final h = m.histogram;
    final showIdeal =
        widget.controller.viewProperties.isTheoreticalHistogramVisible;
    final s = this.s;

    return Container(
      width: LabRightPanelLayout.panelFixedWidth * s,
      decoration: BoxDecoration(
        color: LabRightPanelLayout.statsFill,
        borderRadius:
            BorderRadius.circular(LabRightPanelLayout.panelCornerRadius * s),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row: N = …  |  expand/collapse
          Padding(
            padding: EdgeInsets.fromLTRB(
              5 * s,
              LabRightPanelLayout.statsContentYMargin * s,
              LabRightPanelLayout.expandButtonSide * s + 10 * s,
              _expanded ? 4 * s : LabRightPanelLayout.statsContentYMargin * s,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _EquationLine(
                    left: 'N',
                    right: _formatEq(h.landedBallsNumber.toDouble(), maxDp: 0),
                    color: PlinkoColors.sampleFont,
                    fontSize: 22 * s,
                    bold: true,
                    equalAt: 30 * s,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: CustomPaint(
                    size: Size(
                      LabRightPanelLayout.expandButtonSide * s,
                      LabRightPanelLayout.expandButtonSide * s,
                    ),
                    painter: _ExpandCollapsePainter(expanded: _expanded),
                  ),
                ),
              ],
            ),
          ),
          if (_expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                LabRightPanelLayout.statsContentXMargin * s,
                0,
                LabRightPanelLayout.statsContentXMargin * s,
                LabRightPanelLayout.statsContentYMargin * s,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sample (red), align right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _EquationLine(
                          left: 'x̄',
                          right: _formatEq(h.average),
                          color: PlinkoColors.sampleFont,
                          fontSize: 18 * s,
                          equalAt: 30 * s,
                        ),
                        SizedBox(
                            height: LabRightPanelLayout.statsContentYSpacing * s),
                        _EquationLine(
                          left: 's',
                          right: _formatEq(h.standardDeviation),
                          color: PlinkoColors.sampleFont,
                          fontSize: 18 * s,
                          equalAt: 30 * s,
                        ),
                        SizedBox(
                            height: LabRightPanelLayout.statsContentYSpacing * s),
                        _EquationLine(
                          left: 's',
                          leftSubscript: 'mean',
                          right: _formatEq(h.standardDeviationOfMean),
                          color: PlinkoColors.sampleFont,
                          fontSize: 18 * s,
                          equalAt: 30 * s,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: LabRightPanelLayout.statsHBoxSpacing * s),
                  // Theoretical (blue) + ideal checkbox
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _EquationLine(
                          left: 'μ',
                          right: _formatEq(m.theoreticalAverage),
                          color: PlinkoColors.theoreticalFont,
                          fontSize: 18 * s,
                          equalAt: 30 * s,
                        ),
                        SizedBox(
                            height: LabRightPanelLayout.statsContentYSpacing * s),
                        _EquationLine(
                          left: 'σ',
                          right: _formatEq(m.theoreticalStandardDeviation),
                          color: PlinkoColors.theoreticalFont,
                          fontSize: 18 * s,
                          equalAt: 30 * s,
                        ),
                        SizedBox(
                            height: LabRightPanelLayout.statsContentYSpacing * s),
                        GestureDetector(
                          onTap: () => widget.controller
                              .setIdealVisible(!showIdeal),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18 * s,
                                height: 18 * s,
                                child: Checkbox(
                                  value: showIdeal,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (v) => widget.controller
                                      .setIdealVisible(v ?? false),
                                ),
                              ),
                              SizedBox(width: 4 * s),
                              Column(
                                children: [
                                  CustomPaint(
                                    size: Size(30 * s, 12 * s),
                                    painter: _HistogramIconPainter(),
                                  ),
                                  SizedBox(height: 5 * s),
                                  Text(
                                    PlinkoStrings.ideal,
                                    style: TextStyle(
                                      fontSize: 18 * s,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

/// EquationNode.roundNumber — maxDecimalPlaces adaptive formatting.
String _formatEq(double number, {int maxDp = 3}) {
  if (number.isNaN || number.isInfinite) return '0';
  final abs = number.abs();
  if (abs == 0) return maxDp <= 0 ? '0' : (0.0).toStringAsFixed(maxDp);
  final exponent = math.log(abs) / math.ln10;
  final expFloor = exponent.floor();
  final int decimalPlaces;
  if (expFloor >= maxDp) {
    decimalPlaces = 0;
  } else if (expFloor > 0) {
    decimalPlaces = maxDp - expFloor;
  } else {
    decimalPlaces = maxDp;
  }
  return number.toStringAsFixed(decimalPlaces);
}

class _EquationLine extends StatelessWidget {
  const _EquationLine({
    required this.left,
    required this.right,
    required this.color,
    required this.fontSize,
    required this.equalAt,
    this.leftSubscript,
    this.bold = false,
  });

  final String left;
  final String? leftSubscript;
  final String right;
  final Color color;
  final double fontSize;
  final double equalAt;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontFamily: 'Arial',
      height: 1.0,
    );
    final subStyle = style.copyWith(fontSize: fontSize * 0.5);
    final leftWidget = leftSubscript == null
        ? Text(left, style: style, textAlign: TextAlign.right, maxLines: 1)
        : Text.rich(
            TextSpan(
              style: style,
              children: [
                TextSpan(text: left),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Transform.translate(
                    offset: Offset(0, fontSize * 0.15),
                    child: Text(leftSubscript!, style: subStyle),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
          );
    return SizedBox(
      height: fontSize * 1.45,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            width: equalAt,
            child: leftWidget,
          ),
          Positioned(
            left: equalAt,
            child: Text(' = $right', style: style, maxLines: 1),
          ),
        ],
      ),
    );
  }
}

/// sun AccordionBox expand/collapse square (orange, − when expanded).
class _ExpandCollapsePainter extends CustomPainter {
  _ExpandCollapsePainter({required this.expanded});
  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(size.width * 0.15),
    );
    final base = const Color.fromRGBO(247, 151, 34, 1);
    canvas.drawRRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(base, Colors.white, 0.35)!,
            base,
            Color.lerp(base, Colors.black, 0.15)!,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final cy = size.height / 2;
    final cx = size.width / 2;
    final half = size.width * 0.22;
    canvas.drawLine(Offset(cx - half, cy), Offset(cx + half, cy), paint);
    if (!expanded) {
      canvas.drawLine(Offset(cx, cy - half), Offset(cx, cy + half), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExpandCollapsePainter oldDelegate) =>
      oldDelegate.expanded != expanded;
}

/// `HistogramIcon.js` — 5 blue stroke bins.
class _HistogramIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const n = 5;
    final binW = size.width / n;
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < n; i++) {
      final height = 4 *
          size.height *
          (i + 1) /
          n *
          (1 - i / n);
      final top = size.height - height;
      canvas.drawRect(
        Rect.fromLTWH(i * binW, top, binW, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
