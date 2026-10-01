import 'package:flutter/material.dart';
import 'package:kratos/pendulum_lab/pl_colors.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';
import 'package:kratos/pendulum_lab/pl_strings.dart';

class PlPanel extends StatelessWidget {
  const PlPanel({super.key, required this.child, this.width});

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: PlConstants.panelXMargin,
        vertical: PlConstants.panelYMargin,
      ),
      decoration: BoxDecoration(
        color: PlColors.panelFill,
        borderRadius: BorderRadius.circular(PlConstants.panelCornerRadius),
        border: Border.all(color: const Color(0xFFBBBBBB), width: 0.5),
      ),
      child: child,
    );
  }
}

class PendulumNumberControl extends StatelessWidget {
  const PendulumNumberControl({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.pattern,
    required this.onChanged,
    this.showDisplay = true,
    this.showArrows = true,
    this.minTick,
    this.maxTick,
    this.sliderConstrain,
    this.delta = 0.01,
    this.decimalPlaces = 2,
    this.sliderPadding = 0,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final Color color;
  final String Function(String formatted) pattern;
  final ValueChanged<double> onChanged;
  final bool showDisplay;
  final bool showArrows;
  final String? minTick;
  final String? maxTick;
  final double Function(double)? sliderConstrain;
  final double delta;
  final int decimalPlaces;
  final double sliderPadding;

  @override
  Widget build(BuildContext context) {
    final formatted = value.toStringAsFixed(decimalPlaces);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showDisplay) ...[
              if (showArrows)
                _TinyArrow(
                  minus: true,
                  onTap: () => onChanged((value - delta).clamp(min, max)),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF888888)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  pattern(formatted),
                  style: const TextStyle(fontSize: 14, fontFamily: 'Arial'),
                ),
              ),
              if (showArrows)
                _TinyArrow(
                  minus: false,
                  onTap: () => onChanged((value + delta).clamp(min, max)),
                ),
            ],
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sliderPadding),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const _PlThumbShape(),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: const Color(0xFF666666),
              inactiveTrackColor: const Color(0xFF666666),
              thumbColor: color,
            ),
            child: Slider(
              min: min,
              max: max,
              value: value.clamp(min, max),
              onChanged: (v) {
                final c = sliderConstrain ?? (x) => x;
                onChanged(c(v).clamp(min, max));
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sliderPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minTick ?? min.toString(),
                style: const TextStyle(fontSize: 12, fontFamily: 'Arial'),
              ),
              Text(
                maxTick ?? max.toString(),
                style: const TextStyle(fontSize: 12, fontFamily: 'Arial'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TinyArrow extends StatelessWidget {
  const _TinyArrow({required this.minus, required this.onTap});

  final bool minus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: CustomPaint(
          size: const Size(16, 16),
          painter: _ArrowBtnPainter(minus: minus),
        ),
      ),
    );
  }
}

class _ArrowBtnPainter extends CustomPainter {
  _ArrowBtnPainter({required this.minus});

  final bool minus;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(3),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFFEEEEEE));
    canvas.drawRRect(
      r,
      Paint()
        ..color = const Color(0xFF888888)
        ..style = PaintingStyle.stroke,
    );
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(c.dx - 4, c.dy), Offset(c.dx + 4, c.dy), p);
    if (!minus) {
      canvas.drawLine(Offset(c.dx, c.dy - 4), Offset(c.dx, c.dy + 4), p);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowBtnPainter oldDelegate) =>
      oldDelegate.minus != minus;
}

class _PlThumbShape extends SliderComponentShape {
  const _PlThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      PlConstants.thumbSize;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final size = PlConstants.thumbSize;
    final rect = Rect.fromCenter(center: center, width: size.width, height: size.height);
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    context.canvas.drawRRect(
      r,
      Paint()..color = sliderTheme.thumbColor ?? PlColors.thumbFill,
    );
    context.canvas.drawRRect(
      r,
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }
}

class PlCheckbox extends StatelessWidget {
  const PlCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            CustomPaint(
              size: const Size(14, 14),
              painter: _CheckPainter(checked: value),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontFamily: 'Arial'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.checked});

  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(2),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white);
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    if (checked) {
      final p = Path()
        ..moveTo(2.5, 7.5)
        ..lineTo(5.5, 11)
        ..lineTo(11.5, 3);
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.checked != checked;
}

class PlAquaRadio<T> extends StatelessWidget {
  const PlAquaRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
  });

  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            CustomPaint(
              size: const Size(14, 14),
              painter: _AquaPainter(selected: selected),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontFamily: 'Arial'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AquaPainter extends CustomPainter {
  _AquaPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      6.5,
      Paint()
        ..color = const Color(0xFF37ACE2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    if (selected) {
      canvas.drawCircle(c, 4, Paint()..color = const Color(0xFF37ACE2));
    }
  }

  @override
  bool shouldRepaint(covariant _AquaPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

String metersPattern(String v) => PlStrings.meters(v);
String kgPattern(String v) => PlStrings.kilograms(v);
String gravityPattern(String v) => PlStrings.gravityValue(v);
