import 'package:flutter/material.dart';

import '../model/abs_math.dart';
import '../model/abs_range.dart';

/// Logarithmic slider — PhET `LogSlider.ts` / sun `Slider` chrome.
///
/// Model stores the true log-space value (concentration / strength).
/// Thumb position uses `log10(value)` ↔ `10^linear` with `toFixedNumber(..., 10)`.
///
/// Not a Material [Slider] — rectangular 12×24 thumb on a 125×4 track.
class AbsLogSlider extends StatefulWidget {
  const AbsLogSlider({
    super.key,
    required this.value,
    required this.range,
    required this.onChanged,
    this.trackWidth = 125,
    this.majorTicks = const [],
    this.tickBuilder,
  });

  final double value;
  final AbsRange range;
  final ValueChanged<double> onChanged;
  final double trackWidth;

  /// Tick values in **model** (log) space.
  final List<double> majorTicks;

  /// Optional label for each major tick (model-space value).
  final Widget Function(double logValue)? tickBuilder;

  static const double trackHeight = 4;
  static const Size thumbSize = Size(12, 24);

  @override
  State<AbsLogSlider> createState() => _AbsLogSliderState();
}

class _AbsLogSliderState extends State<AbsLogSlider> {
  double get _linearMin => AbsMath.logToLinear(widget.range.min);
  double get _linearMax => AbsMath.logToLinear(widget.range.max);

  double _linearOf(double model) =>
      AbsMath.logToLinear(model).clamp(_linearMin, _linearMax);

  double _modelOf(double linear) => AbsMath.linearToLog(
        linear.clamp(_linearMin, _linearMax),
      );

  void _setFromLocalDx(double dx) {
    final t = (dx / widget.trackWidth).clamp(0.0, 1.0);
    final linear = _linearMin + t * (_linearMax - _linearMin);
    widget.onChanged(_modelOf(linear));
  }

  @override
  Widget build(BuildContext context) {
    final linear = _linearOf(widget.value);
    final t = (_linearMax == _linearMin)
        ? 0.0
        : (linear - _linearMin) / (_linearMax - _linearMin);
    final thumbCenterX = t * widget.trackWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.trackWidth + AbsLogSlider.thumbSize.width,
          height: AbsLogSlider.thumbSize.height + 4,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _setFromLocalDx(
              d.localPosition.dx - AbsLogSlider.thumbSize.width / 2,
            ),
            onHorizontalDragUpdate: (d) => _setFromLocalDx(
              d.localPosition.dx - AbsLogSlider.thumbSize.width / 2,
            ),
            child: CustomPaint(
              painter: _LogSliderPainter(
                trackWidth: widget.trackWidth,
                thumbCenterX: thumbCenterX,
                majorTickFractions: [
                  for (final v in widget.majorTicks)
                    (_linearOf(v) - _linearMin) /
                        (_linearMax - _linearMin).clamp(1e-12, double.infinity),
                ],
              ),
            ),
          ),
        ),
        if (widget.majorTicks.isNotEmpty)
          SizedBox(
            width: widget.trackWidth + AbsLogSlider.thumbSize.width,
            height: 16,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < widget.majorTicks.length; i++)
                  _TickLabel(
                    trackWidth: widget.trackWidth,
                    trackLeft: AbsLogSlider.thumbSize.width / 2,
                    fraction: (_linearOf(widget.majorTicks[i]) - _linearMin) /
                        (_linearMax - _linearMin),
                    child: widget.tickBuilder?.call(widget.majorTicks[i]) ??
                        Text(
                          _formatTick(widget.majorTicks[i]),
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 10,
                          ),
                        ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static String _formatTick(double v) {
    if (v >= 1) return v.toStringAsFixed(0);
    if (v == 0.001) return '0.001';
    if (v == 0.01) return '0.01';
    if (v == 0.1) return '0.1';
    return v.toString();
  }
}

class _TickLabel extends StatelessWidget {
  const _TickLabel({
    required this.trackWidth,
    required this.trackLeft,
    required this.fraction,
    required this.child,
  });

  final double trackWidth;
  final double trackLeft;
  final double fraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final x = trackLeft + fraction.clamp(0.0, 1.0) * trackWidth;
    return Positioned(
      left: x - 40,
      width: 80,
      top: 0,
      child: Center(child: child),
    );
  }
}

class _LogSliderPainter extends CustomPainter {
  _LogSliderPainter({
    required this.trackWidth,
    required this.thumbCenterX,
    required this.majorTickFractions,
  });

  final double trackWidth;
  final double thumbCenterX;
  final List<double> majorTickFractions;

  @override
  void paint(Canvas canvas, Size size) {
    final trackLeft = AbsLogSlider.thumbSize.width / 2;
    final trackTop = (size.height - AbsLogSlider.trackHeight) / 2;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(trackLeft, trackTop, trackWidth, AbsLogSlider.trackHeight),
      const Radius.circular(2),
    );

    // Inactive track
    canvas.drawRRect(
      trackRect,
      Paint()..color = const Color(0xFFCCCCCC),
    );

    // Active track (left of thumb)
    final activeW = thumbCenterX.clamp(0.0, trackWidth);
    if (activeW > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            trackLeft,
            trackTop,
            activeW,
            AbsLogSlider.trackHeight,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF3376C4),
      );
    }

    // Major ticks
    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1;
    for (final f in majorTickFractions) {
      final x = trackLeft + f.clamp(0.0, 1.0) * trackWidth;
      canvas.drawLine(
        Offset(x, trackTop - 6),
        Offset(x, trackTop + AbsLogSlider.trackHeight + 6),
        tickPaint,
      );
    }

    // Rectangular thumb 12×24
    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(trackLeft + thumbCenterX, size.height / 2),
        width: AbsLogSlider.thumbSize.width,
        height: AbsLogSlider.thumbSize.height,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..color = const Color(0xFF3376C4)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant _LogSliderPainter oldDelegate) {
    return oldDelegate.thumbCenterX != thumbCenterX ||
        oldDelegate.trackWidth != trackWidth;
  }
}
