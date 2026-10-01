import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Source: `scenery-phet/js/StarNode.ts` + `StarShape.ts`.
///
/// Defaults: outerRadius 15, innerRadius 7.5, 5 points;
/// filled `#fcff03` / stroke black 1.5; empty `#e1e1e1` / stroke `#d3d1d1`.
class BaStarNode extends StatelessWidget {
  const BaStarNode({
    super.key,
    this.value = 1.0,
    this.outerRadius = 15,
    this.innerRadius = 7.5,
  });

  /// 0 = empty, 1 = fully filled (left-to-right clip for partial).
  final double value;
  final double outerRadius;
  final double innerRadius;

  static const Color emptyFill = Color(0xFFE1E1E1);
  static const Color emptyStroke = Color(0xFFD3D1D1);
  static const Color filledFill = Color(0xFFFCFF03);

  @override
  Widget build(BuildContext context) {
    final size = outerRadius * 2 + 3; // lineWidth padding
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarNodePainter(
          value: value.clamp(0.0, 1.0),
          outerRadius: outerRadius,
          innerRadius: innerRadius,
        ),
      ),
    );
  }
}

class _StarNodePainter extends CustomPainter {
  _StarNodePainter({
    required this.value,
    required this.outerRadius,
    required this.innerRadius,
  });

  final double value;
  final double outerRadius;
  final double innerRadius;

  Path _starPath(Offset center) {
    const n = 5;
    final path = Path();
    for (var i = 0; i < n * 2; i++) {
      final angle = i / (n * 2) * math.pi * 2 - math.pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = _starPath(center);

    // Empty background star
    canvas.drawPath(path, Paint()..color = BaStarNode.emptyFill);
    canvas.drawPath(
      path,
      Paint()
        ..color = BaStarNode.emptyStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    if (value <= 0) return;

    if (value >= 1) {
      canvas.drawPath(path, Paint()..color = BaStarNode.filledFill);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      );
      return;
    }

    // Left-to-right fill via clip (StarNode clipArea)
    final bounds = path.getBounds();
    final clipW = value * bounds.width;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(bounds.left, bounds.top - 2, clipW, bounds.height + 4));
    canvas.drawPath(path, Paint()..color = BaStarNode.filledFill);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StarNodePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.outerRadius != outerRadius ||
      oldDelegate.innerRadius != innerRadius;
}

/// ScoreDisplayStars row — [count] stars, filled by score/perfect ratio.
class BaScoreStars extends StatelessWidget {
  const BaScoreStars({
    super.key,
    required this.score,
    required this.perfect,
    this.count = 6,
    this.outerRadius = 8,
  });

  final int score;
  final int perfect;
  final int count;
  final double outerRadius;

  @override
  Widget build(BuildContext context) {
    final filled = perfect <= 0
        ? 0
        : ((score / perfect) * count).round().clamp(0, count);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: BaStarNode(
              value: i < filled ? 1.0 : 0.0,
              outerRadius: outerRadius,
              innerRadius: outerRadius / 2,
            ),
          );
        }),
      ),
    );
  }
}
