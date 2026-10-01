import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/abs_beaker.dart';
import '../model/abs_colors.dart';
import '../model/abs_math.dart';
import '../model/abs_view_properties.dart';
import '../model/particle_key.dart';
import '../model/solutions/aqueous_solution.dart';

/// Shared bar geometry — PhET `ConcentrationGraphNode` / `ConcentrationBarNode`.
///
/// Equation terms below the beaker use the same centers so species line up
/// under bars (original layout: no formulas on the graph x-axis).
class AbsGraphLayout {
  AbsGraphLayout._();

  static const double barWidth = 25;
  static const double barSpacing = 16;

  /// Same key order as PhET so visible bars match equation left-to-right.
  static const barOrder = <ParticleKey>[
    ParticleKey.b,
    ParticleKey.ha,
    ParticleKey.h2o,
    ParticleKey.moh,
    ParticleKey.m,
    ParticleKey.bh,
    ParticleKey.a,
    ParticleKey.h3o,
    ParticleKey.oh,
  ];

  static double graphWidth(AbsBeaker beaker) => 0.5 * beaker.size.width;

  static double graphLeft(AbsBeaker beaker) =>
      beaker.position.dx + (graphWidth(beaker) - beaker.size.width) / 2;

  /// Screen X of each visible bar's horizontal center.
  static List<double> barCenterXs(AbsBeaker beaker, AqueousSolution solution) {
    final keys = visibleBarKeys(solution);
    final n = keys.length;
    if (n == 0) return const [];
    final gw = graphWidth(beaker);
    final total = n * barWidth + (n - 1) * barSpacing;
    final start = graphLeft(beaker) + (gw - total) / 2;
    return [
      for (var i = 0; i < n; i++)
        start + i * (barWidth + barSpacing) + barWidth / 2,
    ];
  }

  static List<ParticleKey> visibleBarKeys(AqueousSolution solution) => [
        for (final key in barOrder)
          if (solution.particleWithKey(key) != null) key,
      ];
}

/// Equilibrium concentration graph — PhET `ConcentrationGraphNode.ts`.
///
/// Bars + vertical values only. Species identity is the reaction equation
/// below the beaker (aligned to [AbsGraphLayout.barCenterXs]).
class AbsConcentrationGraph extends StatelessWidget {
  const AbsConcentrationGraph({
    super.key,
    required this.beaker,
    required this.solution,
    required this.viewMode,
    this.valuesVisible = true,
  });

  final AbsBeaker beaker;
  final AqueousSolution solution;
  final AbsViewMode viewMode;
  final bool valuesVisible;

  static const double barWidth = AbsGraphLayout.barWidth;
  static const double barSpacing = AbsGraphLayout.barSpacing;
  static const String yAxisTitle = 'Equilibrium Concentration (mol/L)';
  static const double leftChrome = 70;

  @override
  Widget build(BuildContext context) {
    if (viewMode != AbsViewMode.graph) return const SizedBox.shrink();

    final graphW = AbsGraphLayout.graphWidth(beaker);
    final graphH = 0.9 * beaker.size.height;
    final graphTop = beaker.position.dy - (beaker.size.height + graphH) / 2;
    final graphLeft = AbsGraphLayout.graphLeft(beaker);
    final maxBarHeight = graphH - 10;

    final visibleBars = <_BarSpec>[
      for (final key in AbsGraphLayout.visibleBarKeys(solution))
        _BarSpec(
          key: key,
          color: solution.particleWithKey(key)!.color,
          concentration: solution.particleWithKey(key)!.getConcentration(),
        ),
    ];
    final n = visibleBars.length;

    return Positioned(
      left: graphLeft - leftChrome,
      top: graphTop,
      width: graphW + leftChrome,
      height: graphH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: leftChrome,
            top: 0,
            width: graphW,
            height: graphH,
            child: CustomPaint(
              painter: _GraphChromePainter(graphW: graphW, graphH: graphH),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: leftChrome,
            height: graphH,
            child: CustomPaint(
              painter: _TickLabelsPainter(
                graphH: graphH,
                leftChrome: leftChrome,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: leftChrome - 38,
            height: graphH,
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  yAxisTitle,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 13,
                    color: Colors.black,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: leftChrome,
            top: 10,
            width: graphW,
            height: maxBarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < n; i++) ...[
                  if (i > 0) const SizedBox(width: barSpacing),
                  _ConcentrationBar(
                    color: visibleBars[i].color,
                    concentration: visibleBars[i].concentration,
                    maxBarHeight: maxBarHeight,
                    valuesVisible: valuesVisible,
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: leftChrome,
            top: 0,
            width: graphW,
            height: graphH,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GraphStrokePainter(graphW: graphW, graphH: graphH),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarSpec {
  const _BarSpec({
    required this.key,
    required this.color,
    required this.concentration,
  });

  final ParticleKey key;
  final Color color;
  final double concentration;
}

/// One bar + vertical value — PhET `ConcentrationBarNode`.
class _ConcentrationBar extends StatelessWidget {
  const _ConcentrationBar({
    required this.color,
    required this.concentration,
    required this.maxBarHeight,
    required this.valuesVisible,
  });

  final Color color;
  final double concentration;
  final double maxBarHeight;
  final bool valuesVisible;

  @override
  Widget build(BuildContext context) {
    final h = absBarHeight(concentration, maxBarHeight);
    final label = absConcentrationToGraphString(concentration);

    return SizedBox(
      width: AbsGraphLayout.barWidth,
      height: maxBarHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: AbsGraphLayout.barWidth,
              height: h,
              color: color,
            ),
          ),
          if (valuesVisible && concentration > 0)
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    label,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: Colors.black,
                      height: 1,
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

/// Bar height mapping from `ConcentrationBarNode.ts`.
double absBarHeight(double concentration, double maxBarHeight) {
  if (concentration <= 0) return 0;
  final h = (AbsMath.log10(concentration) + 8).abs() * maxBarHeight / 10;
  return h.isFinite ? h.clamp(0.0, maxBarHeight) : 0;
}

/// Display string from `ConcentrationBarNode.concentrationToString`.
String absConcentrationToGraphString(double? concentration) {
  if (concentration == null) return 'null';
  if (concentration < 1e-13) return 'negligible';
  if (concentration <= 1) {
    var pow = AbsMath.log10(concentration).floor();
    var mantissa = concentration * math.pow(10, -pow).toDouble();
    const places = 1;
    if ((mantissa - 10).abs() < math.pow(10, -places)) {
      pow++;
      mantissa = 1;
    }
    if (pow == 0) {
      return AbsMath.toFixed(mantissa, places);
    }
    return '${AbsMath.toFixed(mantissa, places)} x 10${_toSuperscript(pow)}';
  }
  return AbsMath.toFixed(concentration, 1);
}

String _toSuperscript(int n) {
  const map = {
    '-': '⁻',
    '0': '⁰',
    '1': '¹',
    '2': '²',
    '3': '³',
    '4': '⁴',
    '5': '⁵',
    '6': '⁶',
    '7': '⁷',
    '8': '⁸',
    '9': '⁹',
  };
  final buf = StringBuffer();
  for (final ch in n.toString().split('')) {
    buf.write(map[ch] ?? ch);
  }
  return buf.toString();
}

class _GraphChromePainter extends CustomPainter {
  _GraphChromePainter({required this.graphW, required this.graphH});

  final double graphW;
  final double graphH;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, graphW, graphH),
      Paint()..color = AbsColors.graphFill,
    );

    final dy = (graphH / 10) - 1;
    final grid = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.5;
    final tick = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5;

    for (var i = 0; i < 11; i++) {
      final y = graphH - (dy * i);
      if (i > 0) {
        var x = 0.0;
        while (x < graphW) {
          canvas.drawLine(
            Offset(x, y),
            Offset(math.min(x + 2, graphW), y),
            grid,
          );
          x += 3;
        }
      }
      canvas.drawLine(Offset(0, y), Offset(2, y), tick);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphChromePainter oldDelegate) => false;
}

class _TickLabelsPainter extends CustomPainter {
  _TickLabelsPainter({required this.graphH, required this.leftChrome});

  final double graphH;
  final double leftChrome;

  @override
  void paint(Canvas canvas, Size size) {
    final dy = (graphH / 10) - 1;
    final tick = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5;

    for (var i = 0; i < 11; i++) {
      final y = graphH - (dy * i);
      canvas.drawLine(
        Offset(leftChrome - 2, y),
        Offset(leftChrome + 2, y),
        tick,
      );

      final exponent = i - 8;
      final tp = TextPainter(
        text: TextSpan(
          children: [
            const TextSpan(
              text: '10',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 11,
                color: Colors.black,
                height: 1,
              ),
            ),
            TextSpan(
              text: _superscript(exponent),
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 8,
                color: Colors.black,
                height: 1,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(leftChrome - 2 - 4 - tp.width, y - tp.height / 2),
      );
    }
  }

  static String _superscript(int n) {
    const map = {
      '-': '⁻',
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
    };
    final buf = StringBuffer();
    for (final ch in n.toString().split('')) {
      buf.write(map[ch] ?? ch);
    }
    return buf.toString();
  }

  @override
  bool shouldRepaint(covariant _TickLabelsPainter oldDelegate) => false;
}

class _GraphStrokePainter extends CustomPainter {
  _GraphStrokePainter({required this.graphW, required this.graphH});

  final double graphW;
  final double graphH;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, graphW, graphH),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant _GraphStrokePainter oldDelegate) => false;
}

/// Graph icon for Views panel.
class AbsGraphIcon extends StatelessWidget {
  const AbsGraphIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 22),
      painter: _GraphIconPainter(),
    );
  }
}

class _GraphIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AbsColors.graphFill,
    );
    final bars = [
      AbsColors.ha,
      AbsColors.h2o,
      AbsColors.a,
      AbsColors.h3o,
    ];
    final hs = [0.55, 0.85, 0.45, 0.45];
    for (var i = 0; i < bars.length; i++) {
      final h = size.height * hs[i];
      canvas.drawRect(
        Rect.fromLTWH(2.0 + i * 5, size.height - h, 3, h),
        Paint()..color = bars[i],
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
