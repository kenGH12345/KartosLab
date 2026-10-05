import 'package:flutter/material.dart';

import '../gases_intro_constants.dart';
import '../render/render_data.dart';
import '../widgets/play_area_layout.dart';
import 'shaded_sphere.dart';

/// Container walls + HandleNode-like left grip + particles via [paintShadedSphere].
/// Port of IdealGasLawContainerNode walls Path (no piston — Ideal uses HandleNode).
class PlayAreaPainter extends CustomPainter {
  PlayAreaPainter({required this.data, required this.layout});

  final RenderData data;
  final PlayAreaLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final l = layout;
    final left = l.vx(data.containerLeft);
    final right = l.vx(data.containerRight);
    final top = l.vy(data.containerTop);
    final bottom = l.vy(data.containerBottom);
    final wall = l.vs(data.wallThickness).clamp(2.0, 6.0);

    // Interior
    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
      Paint()..color = const Color(0xFF0B1220),
    );

    // Walls — open top (lid drawn separately). Shape like IdealGasLawContainerNode:
    // left / bottom / right; top open between opening insets when lid off.
    final wallPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wall
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final path = Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)
      ..lineTo(right, bottom)
      ..lineTo(right, top);
    canvas.drawPath(path, wallPaint);

    // Lid
    if (data.lidIsOn) {
      // Lid HandleNode (horizontal grip on lid, scenery HandleNode).
      final lidLeftModel = data.containerRight - data.lidWidth;
      final lidLeft = l.vx(lidLeftModel);
      canvas.drawLine(
        Offset(lidLeft, top),
        Offset(right, top),
        Paint()
          ..color = const Color(0xFFB0B0B0)
          ..strokeWidth = wall + 2,
      );
      _paintLidHandle(canvas, lidLeft + 18, top);
    }

    // Left-wall HandleNode (rotated −π/2, scale ~0.4) — NOT a piston.
    _paintHandleNode(canvas, left, (top + bottom) / 2);

    // Particles — ShadedSphereNode gradient
    for (final p in data.particles) {
      paintShadedSphere(
        canvas,
        Offset(l.vx(p.x), l.vy(p.y)),
        l.vs(p.radius),
        mainColor: p.color,
        highlightColor: p.highlight,
      );
    }

    // Width arrows live in ContainerWidthArrowsPainter (below the container).

    // Hose attachment marker (right wall)
    canvas.drawCircle(
      Offset(right + 4, l.vy(GasesIntroConstants.height / 5)),
      3,
      Paint()..color = const Color(0xFF94A3B8),
    );
  }

  /// Compact vertical HandleNode: grip with finger indents + right attachment to wall.
  void _paintHandleNode(Canvas canvas, double wallX, double midY) {
    const scale = 0.38;
    const gripW = 100.0 * scale; // becomes height when rotated
    const gripH = 42.0 * scale; // becomes width when rotated
    // After −90° rotation: grip is vertical along wall.
    final gripRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(wallX - gripH * 0.55 - 4, midY),
        width: gripH,
        height: gripW * 0.92,
      ),
      Radius.circular(gripH * 0.12),
    );

    final gripBounds = gripRect.outerRect;
    final gripFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          Color.fromRGBO(183, 184, 185, 1),
          Color.fromRGBO(245, 245, 245, 1),
          Color.fromRGBO(183, 184, 185, 1),
          Color.fromRGBO(120, 120, 120, 1),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(gripBounds);

    canvas.drawRRect(gripRect, gripFill);
    canvas.drawRRect(
      gripRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Finger indents (4 pairs along vertical grip)
    final indentPaint = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final gx = gripBounds.center.dx;
    final top = gripBounds.top + gripBounds.height * 0.12;
    final bot = gripBounds.bottom - gripBounds.height * 0.12;
    for (var i = 0; i < 4; i++) {
      final t = (i + 0.5) / 4;
      final y = top + (bot - top) * t;
      final depth = gripBounds.width * 0.11;
      final half = gripBounds.height * 0.06;
      final path = Path()
        ..moveTo(gx - depth, y - half)
        ..quadraticBezierTo(gx - depth * 1.6, y, gx - depth, y + half)
        ..moveTo(gx + depth, y - half)
        ..quadraticBezierTo(gx + depth * 1.6, y, gx + depth, y + half);
      canvas.drawPath(path, indentPaint);
    }

    // Attachment elbow into the wall
    final attachW = gripH * 0.35;
    final attachPath = Path()
      ..moveTo(gripBounds.right - 1, midY - attachW / 2)
      ..lineTo(wallX + 1, midY - attachW / 2)
      ..lineTo(wallX + 1, midY + attachW / 2)
      ..lineTo(gripBounds.right - 1, midY + attachW / 2)
      ..close();
    canvas.drawPath(attachPath, Paint()..color = const Color(0xFF808080));
    canvas.drawPath(
      attachPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintLidHandle(Canvas canvas, double x, double lidY) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, lidY - 10), width: 28, height: 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(245, 245, 245, 1),
            Color.fromRGBO(160, 160, 160, 1),
          ],
        ).createShader(rect.outerRect),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final indent = Paint()
      ..color = const Color(0x66000000)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final dx = rect.outerRect.left + 6 + i * 5.0;
      canvas.drawLine(
        Offset(dx, rect.outerRect.top + 3),
        Offset(dx, rect.outerRect.bottom - 3),
        indent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PlayAreaPainter oldDelegate) => true;
}

/// PhET ContainerWidthNode — dimensional arrows + nm readout below the container.
class ContainerWidthArrowsPainter extends CustomPainter {
  ContainerWidthArrowsPainter({
    required this.visible,
    required this.widthNm,
  });

  final bool visible;
  final double widthNm;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || size.width <= 0) return;
    final y = size.height / 2;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    _arrow(canvas, Offset(0, y), pointingLeft: true);
    _arrow(canvas, Offset(size.width, y), pointingLeft: false);

    final tp = TextPainter(
      text: TextSpan(
        text: '${widthNm.toStringAsFixed(1)} nm',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final box = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width - 28 - tp.width / 2, y),
        width: tp.width + 10,
        height: tp.height + 6,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(box, Paint()..color = Colors.white);
    canvas.drawRRect(
      box,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    tp.paint(
      canvas,
      Offset(box.left + 5, y - tp.height / 2),
    );
  }

  void _arrow(Canvas canvas, Offset tip, {required bool pointingLeft}) {
    final dir = pointingLeft ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - dir * 8, tip.dy - 4)
      ..lineTo(tip.dx - dir * 8, tip.dy + 4)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant ContainerWidthArrowsPainter old) =>
      old.visible != visible || old.widthNm != widthNm;
}
