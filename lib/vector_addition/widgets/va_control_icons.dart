import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../painters/va_arrow_geometry.dart';
import '../vector_addition_colors.dart';

/// PhET `ComponentsRadioButtonGroup` icon size (RADIO_BUTTON_ICON_SIZE = 45).
const double kVaComponentIconSize = 45;

/// Component-style radio icons — PhET `VectorAdditionIconFactory.createComponentStyleRadioButtonIcon`.
class VaComponentStyleIcon extends StatelessWidget {
  const VaComponentStyleIcon({super.key, required this.style});

  final ComponentVectorStyle style;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(kVaComponentIconSize, kVaComponentIconSize),
      painter: _ComponentStyleIconPainter(style),
    );
  }
}

class _ComponentStyleIconPainter extends CustomPainter {
  _ComponentStyleIconPainter(this.style);
  final ComponentVectorStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    if (style == ComponentVectorStyle.invisible) {
      _eyeClosed(canvas, s);
      return;
    }
    final paint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.fill;

    final origin = Offset(2, s - 2);
    final tip = Offset(s - 2, 2);
    final sub = s / 3;

    void arrow(Offset a, Offset b, {bool dashed = false}) {
      if (dashed) {
        _dashedLine(canvas, a, b, paint);
      } else {
        canvas.drawLine(a, b, paint);
      }
      _arrowHead(canvas, a, b, fill);
    }

    if (style == ComponentVectorStyle.parallelogram) {
      arrow(origin, Offset(tip.dx, origin.dy), dashed: true);
      arrow(origin, Offset(origin.dx, tip.dy), dashed: true);
      arrow(origin, tip);
    } else if (style == ComponentVectorStyle.triangle) {
      arrow(origin, Offset(tip.dx, origin.dy), dashed: true);
      arrow(Offset(tip.dx, origin.dy), tip, dashed: true);
      arrow(origin, tip);
    } else if (style == ComponentVectorStyle.projection) {
      final o2 = Offset(sub, s - sub);
      final dash = Paint()
        ..color = const Color(0xFF888888)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round;
      _dashedLine(canvas, Offset(2, s - sub), Offset(sub, s - sub), dash);
      _dashedLine(canvas, Offset(sub, s - sub), Offset(sub, s - 2), dash);
      _dashedLine(canvas, Offset(2, 2), Offset(s - 2, 2), dash);
      _dashedLine(canvas, Offset(s - 2, 2), Offset(s - 2, s - 2), dash);
      arrow(o2, Offset(s - 2, s - 2), dashed: true);
      arrow(o2, Offset(2, 2), dashed: true);
      arrow(o2, tip);
    }
  }

  void _eyeClosed(Canvas canvas, double s) {
    final p = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final c = Offset(s / 2, s / 2);
    final path = Path()
      ..moveTo(c.dx - s * 0.32, c.dy)
      ..quadraticBezierTo(c.dx, c.dy - s * 0.18, c.dx + s * 0.32, c.dy)
      ..quadraticBezierTo(c.dx, c.dy + s * 0.18, c.dx - s * 0.32, c.dy);
    canvas.drawPath(path, p);
    canvas.drawLine(
      Offset(c.dx - s * 0.28, c.dy + s * 0.22),
      Offset(c.dx + s * 0.28, c.dy - s * 0.22),
      p,
    );
  }

  void _arrowHead(Canvas canvas, Offset a, Offset b, Paint fill) {
    final d = b - a;
    final len = d.distance;
    if (len < 1) return;
    final dir = d / len;
    final n = Offset(-dir.dy, dir.dx);
    const h = 7.0;
    const w = 5.0;
    final base = b - dir * h;
    final path = Path()
      ..moveTo(b.dx, b.dy)
      ..lineTo(base.dx + n.dx * w, base.dy + n.dy * w)
      ..lineTo(base.dx - n.dx * w, base.dy - n.dy * w)
      ..close();
    canvas.drawPath(path, fill);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final d = b - a;
    final len = d.distance;
    if (len < 1) return;
    final dir = d / len;
    var t = 0.0;
    const dash = 4.0;
    const gap = 3.0;
    while (t < len) {
      final t1 = math.min(t + dash, len);
      canvas.drawLine(a + dir * t, a + dir * t1, paint);
      t += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _ComponentStyleIconPainter oldDelegate) =>
      oldDelegate.style != style;
}

/// Cartesian scene radio icon (right-triangle axes + diagonal vector).
class VaCartesianSceneIcon extends StatelessWidget {
  const VaCartesianSceneIcon({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _CartesianIconPainter(color),
    );
  }
}

class _CartesianIconPainter extends CustomPainter {
  _CartesianIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final o = Offset(4, size.height - 4);
    canvas.drawLine(o, Offset(size.width - 2, o.dy), axis);
    canvas.drawLine(o, Offset(o.dx, 2), axis);
    final tip = Offset(size.width - 4, 6);
    final v = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(o, tip, v);
    final d = tip - o;
    final len = d.distance;
    final dir = d / len;
    final n = Offset(-dir.dy, dir.dx);
    final base = tip - dir * 7;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(base.dx + n.dx * 4.5, base.dy + n.dy * 4.5)
        ..lineTo(base.dx - n.dx * 4.5, base.dy - n.dy * 4.5)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CartesianIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Polar scene radio icon (arc + radial vector).
class VaPolarSceneIcon extends StatelessWidget {
  const VaPolarSceneIcon({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _PolarIconPainter(color),
    );
  }
}

class _PolarIconPainter extends CustomPainter {
  _PolarIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final o = Offset(4, size.height - 4);
    final axis = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: o, radius: size.width * 0.55),
      -math.pi / 2,
      math.pi / 2,
      false,
      axis,
    );
    final tip = Offset(size.width - 4, 8);
    canvas.drawLine(
      o,
      tip,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    final d = tip - o;
    final dir = d / d.distance;
    final n = Offset(-dir.dy, dir.dx);
    final base = tip - dir * 7;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(base.dx + n.dx * 4.5, base.dy + n.dy * 4.5)
        ..lineTo(base.dx - n.dx * 4.5, base.dy - n.dy * 4.5)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _PolarIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// PhET ResetAll orange disc + ResetShape arrow.
/// Source: scenery-phet `ResetButton.ts` — "Drawn programmatically, does not use
/// any image files." (`resetArrow.png` exists in images/ but is unused by ResetButton.)
class VaResetAllButton extends StatelessWidget {
  const VaResetAllButton({super.key, required this.onPressed, this.size = 48});
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '全部重置',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _ResetAllPainter()),
        ),
      ),
    );
  }
}

class _ResetAllPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = VectorAdditionColors.resetOrange);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final arc = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.42),
      -math.pi * 0.85,
      math.pi * 1.45,
      false,
      arc,
    );
    final ang = -math.pi * 0.85 + math.pi * 1.45;
    final tip = Offset(
      c.dx + r * 0.42 * math.cos(ang),
      c.dy + r * 0.42 * math.sin(ang),
    );
    final tang = Offset(-math.sin(ang), math.cos(ang));
    final n = Offset(-tang.dy, tang.dx);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - tang.dx * 7 + n.dx * 4, tip.dy - tang.dy * 7 + n.dy * 4)
        ..lineTo(tip.dx - tang.dx * 7 - n.dx * 4, tip.dy - tang.dy * 7 - n.dy * 4)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Accordion expand/collapse (±) — sun ExpandCollapseButton is Path geometry
/// (no PNG/SVG). Material Icons forbidden → custom ± on orange square.
class VaAccordionButton extends StatelessWidget {
  const VaAccordionButton({
    super.key,
    required this.expanded,
    required this.onPressed,
  });

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VectorAdditionColors.accordionButton,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CustomPaint(
            painter: _AccordionGlyphPainter(expanded: expanded),
          ),
        ),
      ),
    );
  }
}

class _AccordionGlyphPainter extends CustomPainter {
  _AccordionGlyphPainter({required this.expanded});
  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const arm = 5.5;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), p);
    if (!expanded) {
      canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), p);
    }
  }

  @override
  bool shouldRepaint(covariant _AccordionGlyphPainter oldDelegate) =>
      oldDelegate.expanded != expanded;
}

/// BaseVectorsCheckbox / ResultantVectorCheckbox vector glyph —
/// PhET `VectorAdditionIconFactory.createVectorIcon` (ArrowNode, not an image).
class VaVectorCheckboxIcon extends StatelessWidget {
  const VaVectorCheckboxIcon({super.key, required this.color, this.length = 28});
  final Color color;
  final double length;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(length, length * 0.45),
      painter: _VectorCheckboxIconPainter(color: color),
    );
  }
}

class _VectorCheckboxIconPainter extends CustomPainter {
  _VectorCheckboxIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const geo = VaArrowGeometry(
      headWidth: 8,
      headHeight: 9,
      tailWidth: 2.5,
    );
    geo.paint(
      canvas,
      tail: Offset(2, size.height / 2),
      tip: Offset(size.width - 2, size.height / 2),
      color: color,
    );
  }

  @override
  bool shouldRepaint(covariant _VectorCheckboxIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
