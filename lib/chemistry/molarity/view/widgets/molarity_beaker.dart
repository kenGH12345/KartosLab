import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../model/molarity_constants.dart';
import '../../model/molarity_math.dart';
import '../../model/solution.dart';
import '../molarity_layout.dart';

/// Beaker + liquid + precipitate + label — source `BeakerNode` / `SolutionNode` /
/// `PrecipitateNode` / `BeakerLabelNode`.
///
/// Uses original `beaker.png` (scale 0.75). No Material beaker icons.
class MolarityBeaker extends StatelessWidget {
  const MolarityBeaker({
    super.key,
    required this.solution,
    required this.valuesVisible,
    this.randomSeed = 42,
  });

  final Solution solution;
  final bool valuesVisible;

  /// Deterministic particle placement for golden / tests.
  final int randomSeed;

  @override
  Widget build(BuildContext context) {
    final size = MolarityLayout.beakerDisplaySize;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Liquid under glass image.
          Positioned.fill(
            child: CustomPaint(
              painter: _SolutionPainter(
                solution: solution,
                valuesVisible: valuesVisible,
              ),
            ),
          ),
          // Precipitate under glass.
          Positioned.fill(
            child: CustomPaint(
              painter: _PrecipitatePainter(
                solution: solution,
                seed: randomSeed,
              ),
            ),
          ),
          // Original PhET beaker asset.
          Image.asset(
            MolarityLayout.beakerAsset,
            width: size.width,
            height: size.height,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
          // Tick marks + labels (labels only when valuesVisible).
          Positioned.fill(
            child: CustomPaint(
              painter: _BeakerTicksPainter(valuesVisible: valuesVisible),
            ),
          ),
          // Beaker label (formula / H₂O).
          Positioned(
            left: MolarityLayout.cylinderUpperLeft.dx,
            top: MolarityLayout.cylinderUpperLeft.dy +
                0.15 * MolarityLayout.cylinderSize.height,
            width: MolarityLayout.cylinderSize.width,
            child: Center(
              child: _BeakerLabel(text: solution.beakerLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeakerLabel extends StatelessWidget {
  const _BeakerLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      width: 180 * MolarityLayout.beakerScale / 0.75 * 0.75,
      // Source LABEL_SIZE 180×80 at unscaled beaker; keep readable.
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.1,
        ),
      ),
    );
  }
}

class _SolutionPainter extends CustomPainter {
  _SolutionPainter({
    required this.solution,
    required this.valuesVisible,
  });

  final Solution solution;
  final bool valuesVisible;

  @override
  void paint(Canvas canvas, Size size) {
    final cyl = MolarityLayout.cylinderSize;
    final origin = MolarityLayout.cylinderUpperLeft;
    final endH = MolarityLayout.cylinderEndHeight;
    final maxV = MolarityConstants.volumeMax;
    final height = MolarityMath.linear(
      0,
      maxV,
      0,
      cyl.height,
      solution.volume,
    );
    if (height <= 0) return;

    final color = solution.solutionColor;
    final topY = origin.dy + cyl.height - height;
    final bottomY = origin.dy + cyl.height;
    final cx = origin.dx + cyl.width / 2;
    final rx = cyl.width / 2;
    final ry = endH / 2;

    // Middle rectangle.
    final mid = Rect.fromLTRB(
      origin.dx,
      topY,
      origin.dx + cyl.width,
      bottomY,
    );
    canvas.drawRect(mid, Paint()..color = color);

    // Bottom ellipse.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bottomY), width: cyl.width, height: endH),
      Paint()..color = color,
    );

    // Top ellipse + stroke.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, topY), width: cyl.width, height: endH),
      Paint()..color = color,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, topY), width: cyl.width, height: endH),
      Paint()
        ..color = const Color.fromRGBO(0, 0, 0, 0.33)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Suppress unused warning for ry when only used conceptually.
    assert(rx > 0 && ry >= 0);
  }

  @override
  bool shouldRepaint(covariant _SolutionPainter old) =>
      old.solution.volume != solution.volume ||
      old.solution.concentration != solution.concentration ||
      old.solution.solute != solution.solute ||
      old.valuesVisible != valuesVisible;
}

class _PrecipitatePainter extends CustomPainter {
  _PrecipitatePainter({
    required this.solution,
    required this.seed,
  });

  final Solution solution;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final count = solution.numberOfParticles;
    if (count <= 0) return;

    final cyl = MolarityLayout.cylinderSize;
    final origin = MolarityLayout.cylinderUpperLeft;
    final endH = MolarityLayout.cylinderEndHeight;
    final length = MolarityConstants.particleLength;
    final fill = solution.solute.particleColor;
    final stroke = Color.lerp(fill, Colors.black, 0.35)!;

    // Seed must be stable across Solute instance identity (no ==/hashCode override).
    // Mix formula so different solutes still get distinct layouts at same seed.
    final rng = math.Random(seed ^ solution.solute.formula.hashCode);
    for (var i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final p = _randomInEllipse(
        angle,
        cyl.width - 2 * length,
        endH - 2 * length,
        rng,
      );
      final x = origin.dx + cyl.width / 2 + p.dx;
      final y = origin.dy + cyl.height - p.dy - length / 2;
      final rot = rng.nextDouble() * 2 * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: length,
        height: length,
      );
      canvas.drawRect(rect, Paint()..color = fill);
      canvas.drawRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      canvas.restore();
    }
  }

  static Offset _randomInEllipse(
    double theta,
    double width,
    double height,
    math.Random rng,
  ) {
    final r = math.sqrt(rng.nextDouble());
    return Offset(
      r * math.cos(theta) * width / 2,
      r * math.sin(theta) * height / 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PrecipitatePainter old) =>
      old.solution.precipitateAmount != solution.precipitateAmount ||
      old.solution.solute != solution.solute ||
      old.seed != seed;
}

class _BeakerTicksPainter extends CustomPainter {
  _BeakerTicksPainter({required this.valuesVisible});

  final bool valuesVisible;

  static const _minorSpacing = 0.1; // L
  static const _minorsPerMajor = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final cyl = MolarityLayout.cylinderSize;
    final origin = MolarityLayout.cylinderUpperLeft;
    final endH = MolarityLayout.cylinderEndHeight;
    final maxV = MolarityConstants.volumeMax;
    final nTicks = (maxV / _minorSpacing).round();
    final deltaY = cyl.height / nTicks;
    final cx = origin.dx + cyl.width / 2;
    final rx = cyl.width / 2;
    final ry = endH / 2;

    final majorPaint = Paint()
      ..color = const Color(0xFF808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final minorPaint = Paint()
      ..color = const Color(0xFF808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 1; i <= nTicks; i++) {
      final y = origin.dy + cyl.height - i * deltaY;
      final isMajor = i % _minorsPerMajor == 0;
      final startDeg = 165.0;
      final endDeg = isMajor ? 135.0 : 150.0;
      final path = Path();
      path.addArc(
        Rect.fromCenter(center: Offset(cx, y), width: rx * 2, height: ry * 2),
        startDeg * math.pi / 180,
        (endDeg - startDeg) * math.pi / 180,
      );
      canvas.drawPath(path, isMajor ? majorPaint : minorPaint);

      if (valuesVisible && isMajor) {
        final majorIndex = (i / _minorsPerMajor).round() - 1;
        final labels = ['½ L', '1 L'];
        if (majorIndex >= 0 && majorIndex < labels.length) {
          final tp = TextPainter(
            text: TextSpan(
              text: labels[majorIndex],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF404040),
              ),
            ),
            textDirection: ui.TextDirection.ltr,
          )..layout();
          // Tick arc ends near left; place label to the right of tick end.
          final labelX = cx + rx * math.cos(endDeg * math.pi / 180) + 8;
          tp.paint(canvas, Offset(labelX, y - tp.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BeakerTicksPainter old) =>
      old.valuesVisible != valuesVisible;
}
