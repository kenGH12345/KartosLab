import 'package:flutter/material.dart';

/// Converts a wavelength (380-780 nm) to an RGB Color using
/// the standard visible spectrum algorithm.
///
/// Algorithm based on the classic "wavelength to RGB" conversion:
/// - 380-440nm: violet → blue
/// - 440-490nm: blue → cyan
/// - 490-510nm: cyan → green
/// - 510-580nm: green → yellow
/// - 580-645nm: yellow → red
/// - 645-780nm: red
Color wavelengthToColor(double nm) {
  double r = 0, g = 0, b = 0;

  if (nm >= 380 && nm < 440) {
    r = -(nm - 440) / (440 - 380);
    g = 0;
    b = 1;
  } else if (nm >= 440 && nm < 490) {
    r = 0;
    g = (nm - 440) / (490 - 440);
    b = 1;
  } else if (nm >= 490 && nm < 510) {
    r = 0;
    g = 1;
    b = -(nm - 510) / (510 - 490);
  } else if (nm >= 510 && nm < 580) {
    r = (nm - 510) / (580 - 510);
    g = 1;
    b = 0;
  } else if (nm >= 580 && nm < 645) {
    r = 1;
    g = -(nm - 645) / (645 - 580);
    b = 0;
  } else if (nm >= 645 && nm <= 780) {
    r = 1;
    g = 0;
    b = 0;
  }

  // Intensity fall-off at spectrum edges
  double factor;
  if (nm >= 380 && nm < 420) {
    factor = 0.3 + 0.7 * (nm - 380) / (420 - 380);
  } else if (nm >= 420 && nm <= 700) {
    factor = 1.0;
  } else if (nm > 700 && nm <= 780) {
    factor = 0.3 + 0.7 * (780 - nm) / (780 - 700);
  } else {
    factor = 0;
  }

  return Color.fromARGB(
    255,
    (r * factor * 255).round().clamp(0, 255),
    (g * factor * 255).round().clamp(0, 255),
    (b * factor * 255).round().clamp(0, 255),
  );
}

/// Paints a rainbow spectrum gradient on the slider track.
class _SpectrumTrackPainter extends CustomPainter {
  _SpectrumTrackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const steps = 100;
    final colors = List<Color>.generate(steps, (i) {
      final nm = 380 + (780 - 380) * i / (steps - 1);
      return wavelengthToColor(nm);
    });
    final gradient = LinearGradient(
      colors: colors,
      stops: List.generate(steps, (i) => i / (steps - 1)),
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpectrumTrackPainter oldDelegate) => false;
}

/// Kratos-style spectrum slider: selects a wavelength (380–780 nm) on a
/// visible rainbow track. The knob shows the current wavelength color.
///
/// Usage:
/// ```dart
/// SpectrumSlider(
///   wavelength: 550,
///   onChanged: (nm) => setState(() => ...),
/// )
/// ```
class SpectrumSlider extends StatelessWidget {
  const SpectrumSlider({
    super.key,
    required this.wavelength,
    required this.onChanged,
    this.min = 380,
    this.max = 780,
    this.step = 5,
    this.enabled = true,
    this.trackHeight = 12,
  });

  final double wavelength; // nm, 380-780
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double step;
  final bool enabled;
  final double trackHeight;

  @override
  Widget build(BuildContext context) {
    final currentColor = wavelengthToColor(wavelength.clamp(min, max));
    final divisions = ((max - min) / step).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Wavelength', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
          const Spacer(),
          Text(
            '${wavelength.round()} nm',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          // Left label
          Text('UV', style: TextStyle(fontSize: 9, color: wavelengthToColor(380).withAlpha(180))),
          // Track
          Expanded(
            child: SizedBox(
              height: trackHeight + 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rainbow track
                  Positioned(
                    left: 0, right: 0, height: trackHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _SpectrumTrackPainter(),
                      ),
                    ),
                  ),
                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 0, // hide default track
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape: _SpectrumThumbShape(currentColor),
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: currentColor,
                    ),
                    child: Slider(
                      value: wavelength.clamp(min, max),
                      min: min,
                      max: max,
                      divisions: divisions,
                      onChanged: enabled ? (v) => onChanged(v) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right label
          Text('IR', style: TextStyle(fontSize: 9, color: wavelengthToColor(780).withAlpha(180))),
        ]),
        // Color preview
        Center(
          child: Container(
            width: 32, height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom thumb shape that draws a circle with the current wavelength color.
class _SpectrumThumbShape extends SliderComponentShape {
  final Color color;
  const _SpectrumThumbShape(this.color);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 20);

  @override
  void paint(PaintingContext context, Offset center, {
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
    final canvas = context.canvas;
    // Outer ring (white border)
    canvas.drawCircle(center, 10, Paint()..color = Colors.white);
    canvas.drawCircle(center, 10, Paint()..style = PaintingStyle.stroke..color = const Color(0xFFCBD5E1)..strokeWidth = 1.5);
    // Inner color circle
    canvas.drawCircle(center, 7, Paint()..color = color);
    // Inner border
    canvas.drawCircle(center, 7, Paint()..style = PaintingStyle.stroke..color = color.withAlpha(80)..strokeWidth = 1);
  }
}
