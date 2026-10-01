import 'package:flutter/material.dart';
import 'package:kratos/color_vision/color_vision_constants.dart';

/// PhET `RGBSlider.js` — vertical intensity 0–100%.
///
/// Track `0.5 × 90`, thumb `28 × 14`, major ticks 0/50/100, minor 25/75.
class RgbSlider extends StatelessWidget {
  const RgbSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.channelColor,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final Color channelColor;

  static const double _trackHeight = 90;
  static const double _thumbW = 28;
  static const double _thumbH = 14;

  @override
  Widget build(BuildContext context) {
    final border = Color(
      int.parse(
        ColorVisionConstants.sliderBorderStroke.replaceFirst('#', '0xFF'),
      ),
    );

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [channelColor, Colors.black],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '100%',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(
            height: _trackHeight + _thumbH,
            width: 48,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (d) =>
                      _setFromDy(d.localPosition.dy, constraints.maxHeight),
                  onTapDown: (d) =>
                      _setFromDy(d.localPosition.dy, constraints.maxHeight),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _RgbSliderPainter(
                      t: (value.clamp(0, 100) / 100),
                      channelColor: channelColor,
                    ),
                  ),
                );
              },
            ),
          ),
          const Text(
            '0%',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _setFromDy(double localDy, double height) {
    final trackTop = _thumbH / 2;
    final y = (localDy - trackTop).clamp(0.0, _trackHeight);
    // Top = 100%, bottom = 0%
    final intensity = 100 * (1 - y / _trackHeight);
    onChanged(intensity.clamp(0, 100));
  }
}

class _RgbSliderPainter extends CustomPainter {
  _RgbSliderPainter({required this.t, required this.channelColor});

  /// 0 at bottom (0%), 1 at top (100%).
  final double t;
  final Color channelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const trackH = RgbSlider._trackHeight;
    const thumbW = RgbSlider._thumbW;
    const thumbH = RgbSlider._thumbH;
    final cx = size.width / 2;
    final trackTop = thumbH / 2;
    final trackBottom = trackTop + trackH;

    // Thin white track line
    canvas.drawLine(
      Offset(cx, trackTop),
      Offset(cx, trackBottom),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 0.5,
    );

    // Ticks at 0, 0.25, 0.5, 0.75, 1.0 (from bottom)
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    for (final frac in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final y = trackBottom - frac * trackH;
      final major = frac == 0 || frac == 0.5 || frac == 1.0;
      final len = major ? 15.0 : 7.0;
      canvas.drawLine(
        Offset(cx - len / 2, y),
        Offset(cx + len / 2, y),
        tickPaint,
      );
    }

    // Thumb: light rectangle with dark center line (PhET thumbSize 28×14)
    final thumbY = trackBottom - t * trackH;
    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, thumbY),
        width: thumbW,
        height: thumbH,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      thumbRect,
      Paint()..color = const Color(0xFFEEEEEE),
    );
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF666666),
    );
    canvas.drawLine(
      Offset(cx - thumbW / 2 + 4, thumbY),
      Offset(cx + thumbW / 2 - 4, thumbY),
      Paint()
        ..color = const Color(0xFF333333)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _RgbSliderPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.channelColor != channelColor;
}
