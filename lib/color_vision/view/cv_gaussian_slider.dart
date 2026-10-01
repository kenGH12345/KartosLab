import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/color_vision/color_vision_constants.dart';
import 'package:kratos/color_vision/model/visible_color.dart';

/// PhET `GaussianWavelengthSlider` — spectrum track + white gaussian overlay.
class CvGaussianSlider extends StatelessWidget {
  const CvGaussianSlider({
    super.key,
    required this.wavelength,
    required this.onChanged,
    this.trackWidth = 200,
    this.trackHeight = 30,
    this.label,
  });

  final double wavelength;
  final ValueChanged<double> onChanged;
  final double trackWidth;
  final double trackHeight;
  final String? label;

  static const double minWl = ColorVisionConstants.minWavelength;
  static const double maxWl = ColorVisionConstants.maxWavelength;
  static const double gaussianWidthNm = ColorVisionConstants.gaussianWidth;

  double get _t => ((wavelength - minWl) / (maxWl - minWl)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final thumbColor = VisibleColor.wavelengthToColor(wavelength);
    const thumbWidth = 30.0;
    const thumbHeight = 40.0;
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
                  painter: _GaussianSliderPainter(
                    t: _t,
                    trackWidth: trackWidth,
                    trackHeight: trackHeight,
                    thumbWidth: thumbWidth,
                    thumbHeight: thumbHeight,
                    thumbColor: thumbColor,
                    wavelength: wavelength,
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
    final trackLeft = 15.0; // thumbWidth/2
    final x = (localDx - trackLeft).clamp(0.0, trackWidth);
    final wl = minWl + (x / trackWidth) * (maxWl - minWl);
    onChanged(wl);
  }
}

class _GaussianSliderPainter extends CustomPainter {
  _GaussianSliderPainter({
    required this.t,
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.thumbColor,
    required this.wavelength,
  });

  final double t;
  final double trackWidth;
  final double trackHeight;
  final double thumbWidth;
  final double thumbHeight;
  final Color thumbColor;
  final double wavelength;

  static double _gaussian(double x) {
    final constant = 1 / (0.5 * math.sqrt(2 * math.pi));
    return constant * math.exp(-(x * x));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trackLeft = thumbWidth / 2;
    final trackRect = Rect.fromLTWH(trackLeft, 0, trackWidth, trackHeight);

    // Dim full spectrum underlay (opacity 0.5 like SpectrumSliderTrack).
    final colors = <Color>[];
    const steps = 64;
    for (var i = 0; i <= steps; i++) {
      final wl = CvGaussianSlider.minWl +
          (i / steps) *
              (CvGaussianSlider.maxWl - CvGaussianSlider.minWl);
      colors.add(VisibleColor.wavelengthToColor(wl).withValues(alpha: 0.5));
    }
    canvas.drawRect(
      trackRect,
      Paint()
        ..shader = LinearGradient(colors: colors).createShader(trackRect),
    );

    // Gaussian width in track pixels (σ domain [-3, 3] over GAUSSIAN_WIDTH nm).
    final gaussianPx = trackWidth *
        (CvGaussianSlider.gaussianWidthNm /
            (CvGaussianSlider.maxWl - CvGaussianSlider.minWl));
    final cx = trackLeft + t * trackWidth;
    final xOffset = cx - gaussianPx / 2;

    final gaussianPath = Path()..moveTo(xOffset, trackHeight);
    for (var i = 0; i <= gaussianPx; i++) {
      final xCoord = -3 + (i / gaussianPx) * 6;
      final y = trackHeight - _gaussian(xCoord) * trackHeight * 1.2;
      gaussianPath.lineTo(xOffset + i, y);
    }
    gaussianPath.lineTo(xOffset + gaussianPx, trackHeight);
    gaussianPath.close();

    canvas.save();
    canvas.clipPath(gaussianPath);

    // Full-brightness spectrum clipped to gaussian (shifted so peak matches λ).
    final brightColors = <Color>[];
    for (var i = 0; i <= steps; i++) {
      final wl = CvGaussianSlider.minWl +
          (i / steps) *
              (CvGaussianSlider.maxWl - CvGaussianSlider.minWl);
      brightColors.add(VisibleColor.wavelengthToColor(wl));
    }
    final spectrumShift = trackWidth / 2 - t * trackWidth;
    final shiftedRect = trackRect.translate(spectrumShift, 0);
    canvas.drawRect(
      Rect.fromLTRB(
        trackRect.left - trackWidth,
        trackRect.top,
        trackRect.right + trackWidth,
        trackRect.bottom,
      ),
      Paint()
        ..shader = LinearGradient(colors: brightColors).createShader(
          Rect.fromLTWH(shiftedRect.left, 0, trackWidth, trackHeight),
        ),
    );
    canvas.restore();

    // White gaussian outline.
    final outline = Path()..moveTo(xOffset, trackHeight);
    for (var i = 0; i <= gaussianPx; i++) {
      final xCoord = -3 + (i / gaussianPx) * 6;
      final y = trackHeight - _gaussian(xCoord) * trackHeight * 1.2;
      outline.lineTo(xOffset + i, y);
    }
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white,
    );

    canvas.drawRect(
      trackRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFC0B9B9),
    );

    // Pentagon thumb (no window cursor — windowCursorOptions.visible: false).
    final thumbPath = Path()
      ..moveTo(cx, trackHeight)
      ..lineTo(cx + 0.5 * thumbWidth, trackHeight + 0.3 * thumbHeight)
      ..lineTo(cx + 0.5 * thumbWidth, trackHeight + thumbHeight)
      ..lineTo(cx - 0.5 * thumbWidth, trackHeight + thumbHeight)
      ..lineTo(cx - 0.5 * thumbWidth, trackHeight + 0.3 * thumbHeight)
      ..close();
    canvas.drawPath(thumbPath, Paint()..color = thumbColor);
    canvas.drawPath(
      thumbPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _GaussianSliderPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.thumbColor != thumbColor ||
      oldDelegate.wavelength != wavelength;
}
