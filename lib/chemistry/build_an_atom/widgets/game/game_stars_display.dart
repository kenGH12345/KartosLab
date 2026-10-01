import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/game/score_model.dart';

/// vegas `ScoreDisplayStars` — painted stars (not Material Icons.star).
class GameStarsDisplay extends StatelessWidget {
  const GameStarsDisplay({
    super.key,
    required this.progress,
    this.starSize = 18,
  });

  final StarProgress progress;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < progress.filledStars; i++) {
      children.add(_Star(size: starSize, fill: 1));
    }
    if (progress.hasHalfStar) {
      children.add(_Star(size: starSize, fill: progress.remainder.clamp(0.0, 1.0)));
    }
    for (var i = 0; i < progress.emptyStars; i++) {
      children.add(_Star(size: starSize, fill: 0));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.size, required this.fill});
  final double size;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(fill: fill),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.fill});
  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _starPath(size);
    if (fill >= 1) {
      canvas.drawPath(path, Paint()..color = const Color(0xFFFFD700));
    } else if (fill <= 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    } else {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * fill, size.height));
      canvas.drawPath(path, Paint()..color = const Color(0xFFFFD700));
      canvas.restore();
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  Path _starPath(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final or = size.width * 0.48;
    final ir = or * 0.45;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? or : ir;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.fill != fill;
}
