import 'package:flutter/material.dart';

import '../../view/baa_phet_font.dart';

/// PhET `BAANumberSpinner` / sun `NumberSpinner` with `arrowsPosition: bothRight`.
class BaaNumberSpinner extends StatelessWidget {
  const BaaNumberSpinner({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = -99,
    this.maxValue = 99,
    this.enabled = true,
    this.showPlusForPositive = false,
    this.textColor,
    this.width = 88,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;
  final bool enabled;
  final bool showPlusForPositive;
  final Color? textColor;
  final double width;

  String get _label {
    if (showPlusForPositive) {
      if (value > 0) return '+$value';
      if (value < 0) return '\u2212${value.abs()}';
      return '0';
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? Colors.black;
    final canUp = enabled && value < maxValue;
    final canDown = enabled && value > minValue;

    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Number display
          Expanded(
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black87, width: 1),
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(1, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Text(
                _label,
                style: BaaPhetFont.of(
                  28,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Arrow stack on right (sun bothRight)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ArrowButton(
                up: true,
                enabled: canUp,
                onTap: canUp ? () => onChanged(value + 1) : null,
              ),
              const SizedBox(height: 2),
              _ArrowButton(
                up: false,
                enabled: canDown,
                onTap: canDown ? () => onChanged(value - 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.up,
    required this.enabled,
    required this.onTap,
  });

  final bool up;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFFEEEFF2) : const Color(0xFFE0E0E0),
      elevation: enabled ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: const BorderSide(color: Colors.black54, width: 0.8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          width: 22,
          height: 16,
          child: CustomPaint(
            painter: _ChevronPainter(up: up, enabled: enabled),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.up, required this.enabled});
  final bool up;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = enabled ? const Color(0xFF333333) : Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path();
    if (up) {
      path
        ..moveTo(cx - 5, cy + 2)
        ..lineTo(cx, cy - 3)
        ..lineTo(cx + 5, cy + 2);
    } else {
      path
        ..moveTo(cx - 5, cy - 2)
        ..lineTo(cx, cy + 3)
        ..lineTo(cx + 5, cy - 2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.up != up || oldDelegate.enabled != enabled;
}
