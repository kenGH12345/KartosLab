import 'package:flutter/material.dart';
import 'package:kratos/color_vision/color_vision_constants.dart';
import 'package:kratos/color_vision/model/visible_color.dart';

/// PhET scenery-phet spectrum slider — horizontal rainbow track + pentagon thumb.
///
/// Track 200×30; thumb 30×40. Wavelength 380–780 via [VisibleColor.wavelengthToColor].
class CvSpectrumSlider extends StatelessWidget {
  const CvSpectrumSlider({
    super.key,
    required this.wavelength,
    required this.onChanged,
    this.trackWidth = 200,
    this.trackHeight = 30,
    this.thumbWidth = 30,
    this.thumbHeight = 40,
    this.showWindowCursor = true,
    this.label,
  });

  final double wavelength;
  final ValueChanged<double> onChanged;
  final double trackWidth;
  final double trackHeight;
  final double thumbWidth;
  final double thumbHeight;
  final bool showWindowCursor;
  final String? label;

  static const double minWl = ColorVisionConstants.minWavelength;
  static const double maxWl = ColorVisionConstants.maxWavelength;

  double get _t => ((wavelength - minWl) / (maxWl - minWl)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final thumbColor = VisibleColor.wavelengthToColor(wavelength);
    final totalHeight = trackHeight + thumbHeight * 0.7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(right: 18, bottom: 3),
            child: Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(
          width: trackWidth + thumbWidth,
          height: totalHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (d) => _setFromDx(d.localPosition.dx),
                onTapDown: (d) => _setFromDx(d.localPosition.dx),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _SpectrumSliderPainter(
                    t: _t,
                    trackWidth: trackWidth,
                    trackHeight: trackHeight,
                    thumbWidth: thumbWidth,
                    thumbHeight: thumbHeight,
                    thumbColor: thumbColor,
                    showWindowCursor: showWindowCursor,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _setFromDx(double localDx) {
    final trackLeft = thumbWidth / 2;
    final x = (localDx - trackLeft).clamp(0.0, trackWidth);
    final wl = minWl + (x / trackWidth) * (maxWl - minWl);
    onChanged(wl);
  }
}

class _SpectrumSliderPainter extends CustomPainter {
  _SpectrumSliderPainter({
    required this.t,
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.thumbColor,
    required this.showWindowCursor,
  });

  final double t;
  final double trackWidth;
  final double trackHeight;
  final double thumbWidth;
  final double thumbHeight;
  final Color thumbColor;
  final bool showWindowCursor;

  @override
  void paint(Canvas canvas, Size size) {
    final trackLeft = thumbWidth / 2;
    final trackTop = 0.0;
    final trackRect = Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);

    final colors = <Color>[];
    const steps = 64;
    for (var i = 0; i <= steps; i++) {
      final wl = CvSpectrumSlider.minWl +
          (i / steps) *
              (CvSpectrumSlider.maxWl - CvSpectrumSlider.minWl);
      colors.add(VisibleColor.wavelengthToColor(wl));
    }
    canvas.drawRect(
      trackRect,
      Paint()
        ..shader = LinearGradient(colors: colors).createShader(trackRect),
    );
    canvas.drawRect(
      trackRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFC0B9B9),
    );

    final cx = trackLeft + t * trackWidth;
    if (showWindowCursor) {
      final cursor = Rect.fromCenter(
        center: Offset(cx, trackTop + trackHeight / 2),
        width: 3,
        height: trackHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cursor, const Radius.circular(2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white,
      );
    }

    final thumbPath = _thumbPath(cx, trackTop + trackHeight, thumbWidth, thumbHeight);
    canvas.drawPath(
      thumbPath,
      Paint()..color = thumbColor,
    );
    canvas.drawPath(
      thumbPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black,
    );
  }

  /// Pentagon / teardrop handle; origin at top center of thumb (track bottom).
  Path _thumbPath(double cx, double top, double w, double h) {
    final radius = 0.15 * (w < h ? w : h);
    return Path()
      ..moveTo(cx, top)
      ..lineTo(cx + 0.5 * w, top + 0.3 * h)
      ..lineTo(cx + 0.5 * w, top + h - radius)
      ..arcToPoint(
        Offset(cx + 0.5 * w - radius, top + h),
        radius: Radius.circular(radius),
      )
      ..lineTo(cx - 0.5 * w + radius, top + h)
      ..arcToPoint(
        Offset(cx - 0.5 * w, top + h - radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(cx - 0.5 * w, top + 0.3 * h)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _SpectrumSliderPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.thumbColor != thumbColor ||
      oldDelegate.showWindowCursor != showWindowCursor;
}
