import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/molarity_constants.dart';
import '../../model/molarity_math.dart';
import '../molarity_layout.dart';

/// PhET `VerticalSlider` — qualitative / quantitative dual labels + value readout.
class MolarityVerticalSlider extends StatelessWidget {
  const MolarityVerticalSlider({
    super.key,
    required this.title,
    required this.subtitle,
    required this.minLabel,
    required this.maxLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.decimalPlaces,
    required this.unit,
    required this.trackHeight,
    required this.valuesVisible,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.semanticLabel,
  });

  final String title;
  final String subtitle;
  final String minLabel;
  final String maxLabel;
  final double value;
  final double min;
  final double max;
  final int decimalPlaces;
  final String unit;
  final double trackHeight;
  final bool valuesVisible;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final qMin = MolarityMath.toFixed(
      min,
      min == 0 ? 0 : MolarityConstants.rangeDecimalPlaces,
    );
    final qMax = MolarityMath.toFixed(max, MolarityConstants.rangeDecimalPlaces);
    final valueStr =
        '${MolarityMath.toFixed(value, decimalPlaces)} $unit';

    // Map value → thumb Y within track (max at top).
    final t = max == min ? 0.0 : (value - min) / (max - min);
    final thumbY = (1 - t) * trackHeight;

    // PhET: titles/track centered on VSlider; valueText at sliderNode.right+5
    // expands VerticalSlider bounds so the next slider shifts right.
    final columnW = MolarityLayout.sliderColumnWidthFor(valuesVisible);
    const trackCenterX = 55.0;
    final valueLeft = trackCenterX +
        MolarityLayout.sliderThumbSize.width / 2 +
        MolarityLayout.valuesReadoutGap;

    return SizedBox(
      width: columnW,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: MolarityLayout.sliderColumnWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                valuesVisible ? qMax : maxLabel,
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
              SizedBox(
                height: trackHeight + MolarityLayout.sliderThumbSize.height,
                width: 110,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track
                    Positioned(
                      left: trackCenterX - MolarityLayout.sliderTrackWidth / 2,
                      top: MolarityLayout.sliderThumbSize.height / 2,
                      child: Container(
                        width: MolarityLayout.sliderTrackWidth,
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFC8C8C8),
                            width: 3.5,
                          ),
                        ),
                      ),
                    ),
                    // Interactive slider (transparent track, visible thumb via theme).
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 110,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: MolarityLayout.sliderTrackWidth,
                            activeTrackColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            thumbShape: _PhetThumbShape(),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 18,
                            ),
                            thumbColor: MolarityLayout.sliderThumb,
                          ),
                          child: Semantics(
                            slider: true,
                            label: semanticLabel ?? title,
                            value: valueStr,
                            increasedValue: MolarityMath.toFixed(
                              (value + MolarityConstants.keyboardStep)
                                  .clamp(min, max),
                              decimalPlaces,
                            ),
                            decreasedValue: MolarityMath.toFixed(
                              (value - MolarityConstants.keyboardStep)
                                  .clamp(min, max),
                              decimalPlaces,
                            ),
                            // Vertical slider keyboard: Arrow / Home / End / Page
                            // (+ Shift = fine step), matching PhET VerticalSlider.
                            child: Focus(
                              onKeyEvent: (node, event) {
                                if (event is! KeyDownEvent) {
                                  return KeyEventResult.ignored;
                                }
                                final step = HardwareKeyboard
                                        .instance.isShiftPressed
                                    ? MolarityConstants.shiftKeyboardStep
                                    : MolarityConstants.keyboardStep;
                                double? next;
                                if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowUp ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.pageUp) {
                                  next = value + step;
                                } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowDown ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.pageDown) {
                                  next = value - step;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.home) {
                                  next = min;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.end) {
                                  next = max;
                                }
                                if (next == null) {
                                  return KeyEventResult.ignored;
                                }
                                onChanged(
                                  MolarityMath.toFixedNumber(
                                    next.clamp(min, max),
                                    decimalPlaces,
                                  ),
                                );
                                return KeyEventResult.handled;
                              },
                              child: Slider(
                                value: value.clamp(min, max),
                                min: min,
                                max: max,
                                divisions: ((max - min) /
                                        MolarityConstants.keyboardStep)
                                    .round(),
                                onChangeStart: onChangeStart,
                                onChangeEnd: onChangeEnd,
                                onChanged: (v) {
                                  final fixed = MolarityMath.toFixedNumber(
                                    v,
                                    decimalPlaces,
                                  );
                                  onChanged(
                                      fixed.clamp(min, max).toDouble());
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // PhET valueText — paints into reserved column width.
                    if (valuesVisible)
                      Positioned(
                        left: valueLeft,
                        top: MolarityLayout.sliderThumbSize.height / 2 +
                            thumbY -
                            10,
                        child: SizedBox(
                          width: MolarityLayout.valuesReadoutMaxWidth,
                          child: Text(
                            valueStr,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                valuesVisible ? qMin : minLabel,
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhetThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      MolarityLayout.sliderThumbSize;

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
    final canvas = context.canvas;
    // After RotatedBox(-1), preferred size maps: draw rounded rect thumb.
    final w = MolarityLayout.sliderThumbSize.height; // along track after rotate
    final h = MolarityLayout.sliderThumbSize.width;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h * 0.45),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      r,
      Paint()..color = MolarityLayout.sliderThumb,
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = const Color(0xFF2E6A9A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Center groove line.
    canvas.drawLine(
      Offset(center.dx - w * 0.25, center.dy),
      Offset(center.dx + w * 0.25, center.dy),
      Paint()
        ..color = const Color(0xFF2E6A9A)
        ..strokeWidth = 2,
    );
  }
}
