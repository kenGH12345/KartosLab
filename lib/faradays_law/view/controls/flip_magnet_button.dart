import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../painters/magnet_painter.dart';
import '../../model/magnet_orientation.dart';
import 'package:kratos/faradays_law/faradays_law_strings.dart';

/// `FlipMagnetButton.js` — RectangularPushButton with magnet + curved arrows.
class FlipMagnetButton extends StatefulWidget {
  const FlipMagnetButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  static const Color baseColor = Color.fromRGBO(205, 254, 195, 1);

  @override
  State<FlipMagnetButton> createState() => _FlipMagnetButtonState();
}

class _FlipMagnetButtonState extends State<FlipMagnetButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: FaradaysLawStrings.flipMagnet,
      hint: 'Flip North and South poles',
      child: GestureDetector(
        key: const Key('faradays_law_flip_magnet'),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 60),
          child: Container(
            constraints: const BoxConstraints(minWidth: 118, minHeight: 65),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Color.lerp(
                FlipMagnetButton.baseColor,
                Colors.black,
                _pressed ? 0.08 : 0,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black54, width: 1),
              boxShadow: _pressed
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x44000000),
                        offset: Offset(1, 2),
                        blurRadius: 2,
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(40, 14),
                  painter: _CurvedArrowPainter(rotation: 0),
                ),
                const SizedBox(height: 1),
                SizedBox(
                  width: 74,
                  height: 16,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 140,
                      height: 30,
                      child: CustomPaint(
                        painter:
                            MagnetPainter(orientation: MagnetOrientation.ns),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                CustomPaint(
                  size: const Size(40, 14),
                  painter: _CurvedArrowPainter(rotation: math.pi),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurvedArrowPainter extends CustomPainter {
  _CurvedArrowPainter({required this.rotation});

  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);

    const radius = 10.0;
    const lineWidth = 2.0;
    const arcStart = -math.pi * 0.90;
    const arcEnd = -math.pi * 0.18;

    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      arcStart,
      arcEnd - arcStart,
      false,
      stroke,
    );

    final tip = Offset(radius * math.cos(arcEnd), radius * math.sin(arcEnd));
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(arcEnd);
    final head = Path()
      ..moveTo(0, 5)
      ..lineTo(2.5, 0)
      ..lineTo(-2.5, 0)
      ..close();
    canvas.drawPath(head, Paint()..color = Colors.black);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CurvedArrowPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
