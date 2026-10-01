import 'package:flutter/material.dart';

/// PhET sun NumberSpinner (vertical arrows on the right) — RPAL style.
class RpalNumberSpinner extends StatelessWidget {
  const RpalNumberSpinner({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.fontSize = 28,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final atMin = value <= min;
    final atMax = value >= max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 36),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black54, width: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrowBtn(
              up: true,
              enabled: !atMax,
              onPressed: () => onChanged((value + 1).clamp(min, max)),
            ),
            _ArrowBtn(
              up: false,
              enabled: !atMin,
              onPressed: () => onChanged((value - 1).clamp(min, max)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({
    required this.up,
    required this.enabled,
    required this.onPressed,
  });

  final bool up;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 18,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: CustomPaint(
          painter: _TriPainter(up: up, enabled: enabled),
        ),
      ),
    );
  }
}

class _TriPainter extends CustomPainter {
  _TriPainter({required this.up, required this.enabled});

  final bool up;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = enabled ? const Color(0xFFE0E0E0) : const Color(0xFFF0F0F0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2)),
      bg,
    );
    final path = Path();
    final cx = size.width / 2;
    if (up) {
      path.moveTo(cx, 4);
      path.lineTo(size.width - 4, size.height - 4);
      path.lineTo(4, size.height - 4);
    } else {
      path.moveTo(4, 4);
      path.lineTo(size.width - 4, 4);
      path.lineTo(cx, size.height - 4);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()..color = enabled ? Colors.black87 : Colors.black26,
    );
  }

  @override
  bool shouldRepaint(covariant _TriPainter oldDelegate) =>
      oldDelegate.up != up || oldDelegate.enabled != enabled;
}
