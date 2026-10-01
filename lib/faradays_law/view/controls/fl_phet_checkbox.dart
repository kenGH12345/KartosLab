import 'package:flutter/material.dart';

/// PhET sun-style checkbox (white fill, black border, black check).
/// Not Material [Checkbox].
class FlPhetCheckbox extends StatelessWidget {
  const FlPhetCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.boxWidth = 18,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final double boxWidth;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      button: true,
      child: GestureDetector(
        onTap: () => onChanged(!checked),
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          size: Size(boxWidth, boxWidth),
          painter: _FlCheckPainter(checked: checked),
        ),
      ),
    );
  }
}

class _FlCheckPainter extends CustomPainter {
  _FlCheckPainter({required this.checked});

  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(2),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white);
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (!checked) return;
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.52)
      ..lineTo(size.width * 0.40, size.height * 0.74)
      ..lineTo(size.width * 0.82, size.height * 0.22);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _FlCheckPainter oldDelegate) =>
      oldDelegate.checked != checked;
}

/// Checkbox + label row matching Faraday control strip.
class FlLabeledCheckbox extends StatelessWidget {
  const FlLabeledCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlPhetCheckbox(checked: value, onChanged: onChanged),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
