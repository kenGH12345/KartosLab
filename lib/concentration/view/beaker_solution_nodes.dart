import 'package:flutter/material.dart';

import '../model/beaker.dart';
import '../model/concentration_constants.dart';
import 'concentration_layout.dart';

/// Beaker outline + tick marks — beers-law-lab `BeakerNode.ts`.
///
/// Origin at bottom center of beaker.
class BeakerNode extends StatelessWidget {
  const BeakerNode({super.key, required this.beaker});

  final Beaker beaker;

  static const double rimOffset = 20;
  static const double minorTickSpacing = 0.1; // L
  static const int minorTicksPerMajor = 5;
  static const double majorTickLength = 30;
  static const double minorTickLength = 15;
  static const double tickLabelXSpacing = 8;

  @override
  Widget build(BuildContext context) {
    final w = beaker.size.width;
    final h = beaker.size.height;
    final left = beaker.position.dx - w / 2;
    final top = beaker.position.dy - h - rimOffset;
    final paintH = h + rimOffset;
    final paintW = w + 2 * rimOffset;

    return Positioned(
      left: left - rimOffset,
      top: top,
      width: paintW,
      height: paintH + 4,
      child: CustomPaint(
        size: Size(paintW, paintH + 4),
        painter: _BeakerPainter(beaker: beaker),
      ),
    );
  }
}

class _BeakerPainter extends CustomPainter {
  _BeakerPainter({required this.beaker});

  final Beaker beaker;

  @override
  void paint(Canvas canvas, Size size) {
    final w = beaker.size.width;
    final h = beaker.size.height;
    // Local coords: origin shifted so rim is at top of paint box.
    // Bottom center of beaker interior is at (rimOffset + w/2, rimOffset + h).
    const rim = BeakerNode.rimOffset;
    final leftX = rim;
    final rightX = rim + w;
    final topY = rim;
    final bottomY = rim + h;

    final outline = Path()
      ..moveTo(leftX - rim, topY - rim)
      ..lineTo(leftX, topY)
      ..lineTo(leftX, bottomY)
      ..lineTo(rightX, bottomY)
      ..lineTo(rightX, topY)
      ..lineTo(rightX + rim, topY - rim);

    canvas.drawPath(
      outline,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final numberOfTicks =
        (beaker.volume / BeakerNode.minorTickSpacing).round();
    final deltaY = h / numberOfTicks;
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;

    var labelIndex = 0;
    const majorLabels = ['½', '1'];
    for (var i = 1; i <= numberOfTicks; i++) {
      final isMajor = i % BeakerNode.minorTicksPerMajor == 0;
      final y = bottomY - i * deltaY;
      final tickLen =
          isMajor ? BeakerNode.majorTickLength : BeakerNode.minorTickLength;
      canvas.drawLine(
        Offset(leftX, y),
        Offset(leftX + tickLen, y),
        tickPaint,
      );
      if (isMajor && labelIndex < majorLabels.length) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${majorLabels[labelIndex]} L',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Roboto',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 0.25 * w);
        tp.paint(
          canvas,
          Offset(
            leftX + tickLen + BeakerNode.tickLabelXSpacing,
            y - tp.height / 2,
          ),
        );
        labelIndex++;
      }
    }

    // Keep painter tied to beaker geometry only.
    assert(bottomY > topY);
  }

  @override
  bool shouldRepaint(covariant _BeakerPainter oldDelegate) =>
      oldDelegate.beaker != beaker;
}

/// Liquid in beaker — `SolutionNode.ts`.
class SolutionNode extends StatelessWidget {
  const SolutionNode({
    super.key,
    required this.beaker,
    required this.volume,
    required this.color,
  });

  final Beaker beaker;
  final double volume;
  final Color color;

  /// Source liquid height in model/view units.
  static double liquidHeight({
    required double volume,
    required double beakerVolume,
    required double beakerHeight,
  }) {
    if (volume <= 0) return 0;
    var h = (volume / beakerVolume) * beakerHeight;
    if (h < ConcentrationConstants.minNonzeroSolutionHeight) {
      h = ConcentrationConstants.minNonzeroSolutionHeight;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final h = liquidHeight(
      volume: volume,
      beakerVolume: beaker.volume,
      beakerHeight: beaker.size.height,
    );
    if (h <= 0) return const SizedBox.shrink();

    final left = beaker.position.dx - beaker.size.width / 2;
    final top = beaker.position.dy - h;

    return Positioned(
      left: left,
      top: top,
      width: beaker.size.width,
      height: h,
      child: CustomPaint(
        size: Size(beaker.size.width, h),
        painter: _SolutionPainter(color: color),
      ),
    );
  }
}

class _SolutionPainter extends CustomPainter {
  _SolutionPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(
      rect,
      Paint()
        ..color = ConcentrationLayout.solutionStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = ConcentrationConstants.minNonzeroSolutionHeight > 0
            ? 1
            : 1,
    );
  }

  @override
  bool shouldRepaint(covariant _SolutionPainter oldDelegate) =>
      oldDelegate.color != color;
}
