import 'package:flutter/material.dart';

import '../vector_addition_colors.dart';

/// PhET-like NumberPicker (up/value/down) — not a Dropdown.
/// Mirrors sun `NumberPicker` + `VectorAdditionConstants.NUMBER_PICKER_OPTIONS`.
class VaNumberPicker extends StatelessWidget {
  const VaNumberPicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.color = Colors.black,
    this.enabled = true,
    this.width = 44,
    this.step = 1,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final Color color;
  final bool enabled;
  final double width;
  final int step;

  @override
  Widget build(BuildContext context) {
    final canUp = enabled && value + step <= max;
    final canDown = enabled && value - step >= min;
    return SizedBox(
      width: width,
      child: Material(
        color: VectorAdditionColors.panelFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.5),
          side: BorderSide(color: color.withValues(alpha: 0.85)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _arrow(
              up: true,
              enabled: canUp,
              onTap: () => onChanged(value + step),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            _arrow(
              up: false,
              enabled: canDown,
              onTap: () => onChanged(value - step),
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrow({
    required bool up,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        height: 16,
        width: width,
        child: CustomPaint(
          painter: _PickerArrowPainter(
            up: up,
            color: enabled ? color : color.withValues(alpha: 0),
          ),
        ),
      ),
    );
  }
}

class _PickerArrowPainter extends CustomPainter {
  _PickerArrowPainter({required this.up, required this.color});
  final bool up;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final cx = size.width / 2;
    if (up) {
      path
        ..moveTo(cx, 3)
        ..lineTo(cx - 5, 11)
        ..lineTo(cx + 5, 11)
        ..close();
    } else {
      path
        ..moveTo(cx, size.height - 3)
        ..lineTo(cx - 5, size.height - 11)
        ..lineTo(cx + 5, size.height - 11)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PickerArrowPainter oldDelegate) =>
      oldDelegate.up != up || oldDelegate.color != color;
}
