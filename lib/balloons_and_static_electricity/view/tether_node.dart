import 'package:flutter/material.dart';

import '../model/balloon_model.dart';
import '../model/base_vec2.dart';
import '../model/balloons_static_electricity_constants.dart';
import 'base_view_layout.dart';

/// Balloon tether (string) — PhET `TetherNode` (View-only quadratic curve).
class TetherPainter extends CustomPainter {
  TetherPainter({
    required this.anchor,
    required this.attachment,
  });

  final BaseVec2 anchor;
  final BaseVec2 attachment;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(anchor.x, anchor.y)
      ..quadraticBezierTo(
        attachment.x,
        (anchor.y + attachment.y) / 2,
        attachment.x,
        attachment.y,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant TetherPainter oldDelegate) =>
      oldDelegate.anchor != anchor || oldDelegate.attachment != attachment;
}

class TetherNode extends StatelessWidget {
  const TetherNode({
    super.key,
    required this.balloon,
    required this.anchor,
    required this.visible,
  });

  final BalloonModel balloon;
  final BaseVec2 anchor;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final attach = BaseVec2(
      balloon.position.x + BaseConstants.balloonWidth / 2,
      balloon.position.y +
          BaseConstants.balloonHeight -
          BaseViewLayout.balloonTiePointHeight,
    );
    return CustomPaint(
      size: const Size(
        BaseViewLayout.layoutWidth,
        BaseViewLayout.layoutHeight,
      ),
      painter: TetherPainter(anchor: anchor, attachment: attach),
    );
  }
}
