import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kratos/l10n/kartos_localization.dart';

/// scenery-phet `ResetAllButton` / `RoundPushButton.ThreeDAppearanceStrategy`.
///
/// L0 chrome for every PhET port: spherical highlight + filled `ResetShape`.
/// Press scales down; release uses `elasticOut`.
class KratosResetAllButton extends StatefulWidget {
  const KratosResetAllButton({
    super.key,
    required this.onPressed,
    this.radius = 20.5,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final double radius;

  /// Defaults to [loc.shared.resetAll] when null/empty.
  final String? tooltip;

  /// `PhetColorScheme.RESET_ALL_BUTTON_BASE_COLOR`
  static const Color baseColor = Color.fromRGBO(247, 151, 34, 1);

  @override
  State<KratosResetAllButton> createState() => _KratosResetAllButtonState();
}

class _KratosResetAllButtonState extends State<KratosResetAllButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down() {
    _press.animateTo(1, curve: Curves.easeIn);
  }

  void _up({required bool fire}) {
    _press.animateBack(0, curve: Curves.elasticOut);
    if (fire) widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;
    final d = r * 2 + 8;
    final button = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _down(),
        onTapUp: (_) => _up(fire: true),
        onTapCancel: () => _up(fire: false),
        child: SizedBox(
          width: d,
          height: d,
          child: AnimatedBuilder(
            animation: _press,
            builder: (context, _) {
              final t = _press.value;
              final scale = 1.0 - 0.12 * t;
              return Transform.scale(
                scale: scale,
                child: CustomPaint(
                  size: Size(d, d),
                  painter: _ResetAllPainter(
                    radius: r,
                    press: t.clamp(0.0, 1.0),
                  ),
                ),
              );
            },
          ),
        ),
    );
    final tip = (widget.tooltip == null || widget.tooltip!.isEmpty)
        ? loc.shared.resetAll
        : widget.tooltip!;
    return Semantics(
      button: true,
      label: loc.shared.resetAllSemantics,
      child: Tooltip(message: tip, child: button),
    );
  }
}

class _ResetAllPainter extends CustomPainter {
  _ResetAllPainter({required this.radius, required this.press});

  final double radius;
  final double press;

  @override
  void paint(Canvas canvas, Size size) {
    final r = radius;
    final center = Offset(size.width / 2, size.height / 2 - 1 + 1.5 * press);

    final shadow = Paint()
      ..color = Color.fromRGBO(0, 0, 0, 0.28 - 0.14 * press)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.2 - 1.4 * press);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + r * (0.55 - 0.2 * press)),
        width: r * (1.55 - 0.25 * press),
        height: r * (0.42 - 0.12 * press),
      ),
      shadow,
    );

    final hx = -0.42 + 0.28 * press;
    final hy = -0.48 + 0.28 * press;
    final highlight = center + Offset(r * hx, r * hy);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          highlight,
          r * 1.55,
          [
            Color.lerp(const Color(0xFFFFE7B0), const Color(0xFFFFC56A), press)!,
            Color.lerp(KratosResetAllButton.baseColor, const Color(0xFFE07A12), press)!,
            Color.lerp(const Color(0xFFB85A0C), const Color(0xFF8F4308), press)!,
          ],
          const [0.0, 0.42, 1.0],
        ),
    );

    final specCenter = center + Offset(-r * 0.38, -r * 0.42);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          specCenter,
          r * 0.55,
          [
            Color.fromRGBO(255, 255, 255, 0.55 - 0.25 * press),
            const Color(0x00FFFFFF),
          ],
        ),
    );

    canvas.drawCircle(
      center,
      r - 0.4,
      Paint()
        ..color = const Color.fromRGBO(140, 75, 12, 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy - 0.0125 * r);
    final arrow = _resetShapePath(r);
    canvas.drawPath(arrow, Paint()..color = Colors.white);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = const Color.fromRGBO(80, 80, 80, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  /// `scenery-phet/js/ResetShape.ts`
  static Path _resetShapePath(double radius) {
    const adj = 0.8;
    final innerR = radius * 0.4 - adj;
    final outerR = radius * 0.625 + adj;
    final headWidth = 2.0 * (outerR - innerR);
    const startAngle = -math.pi * 0.35;
    const endToNeck = -2 * math.pi * 0.85;
    const arrowHeadSpan = -math.pi * 0.18;
    final neckAngle = startAngle + endToNeck;
    final extrusion = (headWidth - (outerR - innerR)) / 2;
    final path = Path()
      ..moveTo(innerR * math.cos(startAngle), innerR * math.sin(startAngle))
      ..lineTo(outerR * math.cos(startAngle), outerR * math.sin(startAngle));
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: outerR),
      startAngle,
      endToNeck,
      false,
    );
    path
      ..lineTo(
        (outerR + extrusion) * math.cos(neckAngle),
        (outerR + extrusion) * math.sin(neckAngle),
      )
      ..lineTo(
        ((outerR + innerR) * 0.55) * math.cos(neckAngle + arrowHeadSpan),
        ((outerR + innerR) * 0.55) * math.sin(neckAngle + arrowHeadSpan),
      )
      ..lineTo(
        (innerR - extrusion) * math.cos(neckAngle),
        (innerR - extrusion) * math.sin(neckAngle),
      )
      ..lineTo(innerR * math.cos(neckAngle), innerR * math.sin(neckAngle));
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: innerR),
      neckAngle,
      -endToNeck,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ResetAllPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.press != press;
}
