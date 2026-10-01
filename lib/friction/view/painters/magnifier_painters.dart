import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../friction_constants.dart';
import '../../model/friction_model.dart';
import 'atoms_painter.dart';

/// Magnifier interior — backgrounds, bumps, atoms (PhET MagnifierNode layout).
///
/// Top-book blue fill bottom edge is ~127.5 (not full height), so a white gap
/// remains above the green bottom book — matching the original screenshot.
class MagnifierContentPainter extends CustomPainter {
  MagnifierContentPainter({required this.model});

  final FrictionModel model;

  static const double w = FrictionConstants.magnifierWindowWidth;
  static const double h = FrictionConstants.magnifierWindowHeight;
  static const double round = FrictionConstants.magnifierCornerRadius;

  /// PhET: atomDragArea.y - HEIGHT + (4*HEIGHT/3 - distance)
  /// = 0.175*H - H + 4H/3 - distance ≈ 127.4
  static double get topBookFillBottom {
    const distance = FrictionConstants.initialAtomSpacingYBooks;
    return 0.175 * h - h + (4 * h / 3) - distance;
  }

  /// Bump row on top book: HEIGHT/3 - distance
  static double get topBumpY =>
      h / 3 - FrictionConstants.initialAtomSpacingYBooks;

  /// Bottom book rect top: 2*HEIGHT/3 - 2
  static double get bottomBookTop => 2 * h / 3 - 2;

  @override
  void paint(Canvas canvas, Size size) {
    final top = model.topBookPosition;

    // --- Bottom book (fixed) ---
    final bottomRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(3, bottomBookTop, w - 6, h / 3),
      bottomLeft: const Radius.circular(round - 3),
      bottomRight: const Radius.circular(round - 3),
    );
    canvas.drawRRect(
      bottomRect,
      Paint()..color = FrictionConstants.bottomBookColor,
    );
    _drawBumps(
      canvas,
      color: FrictionConstants.bottomBookColor,
      startX: -FrictionConstants.initialAtomSpacingX / 2,
      y: bottomBookTop,
      width: w,
    );

    // --- Top book background (translates with model) ---
    canvas.save();
    canvas.translate(top.dx, top.dy);

    // Wide blue fill: from well above the window down to topBookFillBottom.
    // PhET background is ~3.25*WIDTH wide starting near -1.125*WIDTH relative
    // to atomDragArea; in topBookBackground coords that ≈ -WIDTH .. 2*WIDTH.
    final fillBottom = topBookFillBottom;
    canvas.drawRect(
      Rect.fromLTRB(-w, -h, 2 * w, fillBottom),
      Paint()..color = FrictionConstants.topBookColor,
    );
    _drawBumps(
      canvas,
      color: FrictionConstants.topBookColor,
      startX: -w,
      y: topBumpY,
      width: 3 * w,
    );

    canvas.restore();

    // --- Atoms (positions already include top-book motion) ---
    AtomsPainter(atoms: model.atoms).paint(canvas, size);
  }

  void _drawBumps(
    Canvas canvas, {
    required Color color,
    required double startX,
    required double y,
    required double width,
  }) {
    final r = FrictionConstants.atomRadius;
    final spacing = FrictionConstants.initialAtomSpacingX;
    final n = (width / spacing).ceil();
    final paint = Paint()..color = color;
    for (var i = 0; i < n; i++) {
      canvas.drawCircle(Offset(startX + spacing * i, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MagnifierContentPainter oldDelegate) => true;
}

/// Cue arrows — PhET CueArrow pair (white fill, black stroke).
class MagnifierHintArrowsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const arrowLen = 55.0;
    const headH = 28.0;
    const headW = 26.0;
    const tailW = 13.0;
    const gap = 20.0;

    final cy = size.height / 2;
    final totalW = arrowLen * 2 + gap;
    final leftTip = (size.width - totalW) / 2;
    final rightBase = leftTip + arrowLen + gap;

    _drawArrow(
      canvas,
      tip: Offset(leftTip, cy),
      pointingLeft: true,
      length: arrowLen,
      headH: headH,
      headW: headW,
      tailW: tailW,
    );
    _drawArrow(
      canvas,
      tip: Offset(rightBase + arrowLen, cy),
      pointingLeft: false,
      length: arrowLen,
      headH: headH,
      headW: headW,
      tailW: tailW,
    );
  }

  void _drawArrow(
    Canvas canvas, {
    required Offset tip,
    required bool pointingLeft,
    required double length,
    required double headH,
    required double headW,
    required double tailW,
  }) {
    final dir = pointingLeft ? -1.0 : 1.0;
    // Tip is the pointy end; body extends opposite to dir from tip.
    final baseX = tip.dx - dir * length;
    final headBaseX = tip.dx - dir * headH;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(headBaseX, tip.dy - headW / 2)
      ..lineTo(headBaseX, tip.dy - tailW / 2)
      ..lineTo(baseX, tip.dy - tailW / 2)
      ..lineTo(baseX, tip.dy + tailW / 2)
      ..lineTo(headBaseX, tip.dy + tailW / 2)
      ..lineTo(headBaseX, tip.dy + headW / 2)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Magnifier target + dashed lines (MagnifierTargetNode).
class MagnifierTargetPainter extends CustomPainter {
  MagnifierTargetPainter({required this.targetX, required this.targetY});

  final double targetX;
  final double targetY;

  @override
  void paint(Canvas canvas, Size size) {
    const mw = FrictionConstants.magnifierWindowWidth;
    const mh = FrictionConstants.magnifierWindowHeight;
    const round = FrictionConstants.magnifierCornerRadius;
    final tw = mw * FrictionConstants.magnifierScale;
    final th = mh * FrictionConstants.magnifierScale;
    final tr = round * FrictionConstants.magnifierScale;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(targetX, targetY),
        width: tw,
        height: th,
      ),
      Radius.circular(tr),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final leftAnchor = const Offset(round, mh);
    final rightAnchor = const Offset(mw - round, mh);
    final dash = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    _drawDashed(canvas, leftAnchor, Offset(targetX - tw / 2, targetY), dash);
    _drawDashed(canvas, rightAnchor, Offset(targetX + tw / 2, targetY), dash);
  }

  void _drawDashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dashLen = 10.0;
    const gap = 10.0;
    final total = (b - a).distance;
    if (total < 1) return;
    final dir = (b - a) / total;
    var drawn = 0.0;
    while (drawn < total) {
      final start = a + dir * drawn;
      final end = a + dir * math.min(drawn + dashLen, total);
      canvas.drawLine(start, end, paint);
      drawn += dashLen + gap;
    }
  }

  @override
  bool shouldRepaint(covariant MagnifierTargetPainter oldDelegate) => false;
}
