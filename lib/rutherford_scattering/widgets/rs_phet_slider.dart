import 'package:flutter/material.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_layout.dart';

/// PhET sun HSlider thumb: 15×30 rounded rect with optional center line.
class RsPhetThumbShape extends SliderComponentShape {
  const RsPhetThumbShape({
    required this.fill,
    this.centerLine = false,
  });

  final Color fill;
  final bool centerLine;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => RsLayout.sliderThumb;

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
    final rect = Rect.fromCenter(
      center: center,
      width: RsLayout.sliderThumb.width,
      height: RsLayout.sliderThumb.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    final canvas = context.canvas;

    // Soft highlight (PhET 3D-ish thumb)
    final highlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.55),
          fill,
          fill.withValues(alpha: 0.85),
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, highlight);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (centerLine) {
      canvas.drawLine(
        Offset(center.dx, rect.top + 4),
        Offset(center.dx, rect.bottom - 4),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..strokeWidth = 1,
      );
    }
  }
}

/// Thin-track PhET-style slider (track height 1, thumb 15×30).
class RsPhetSlider extends StatelessWidget {
  const RsPhetSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.thumbColor,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.centerLine = false,
    this.width,
  });

  final double value;
  final double min;
  final double max;
  final Color thumbColor;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final bool centerLine;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final trackColor = RsColors.panelSliderLabel;
    return SizedBox(
      width: width,
      height: RsLayout.sliderThumb.height + 8,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: RsLayout.sliderTrackHeight,
          activeTrackColor: trackColor,
          inactiveTrackColor: trackColor,
          disabledActiveTrackColor: trackColor,
          disabledInactiveTrackColor: trackColor,
          thumbShape: RsPhetThumbShape(
            fill: thumbColor,
            centerLine: centerLine,
          ),
          overlayShape: SliderComponentShape.noOverlay,
          trackShape: const RectangularSliderTrackShape(),
          tickMarkShape: SliderTickMarkShape.noTickMark,
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
        ),
      ),
    );
  }
}
