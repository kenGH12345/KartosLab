import 'package:flutter/material.dart';

import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../fmw_strings.dart';

/// N vertical-ish sliders for A1..An.
class AmplitudeSliderRow extends StatelessWidget {
  const AmplitudeSliderRow({
    super.key,
    required this.values,
    required this.onChanged,
    required this.step,
    this.enabled = true,
    this.maxAmplitude = FmwConstants.maxAmplitude,
    this.height = 140,
  });

  final List<double> values;
  final ValueChanged<(int order, double value)> onChanged;
  final double step;
  final bool enabled;
  final double maxAmplitude;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: _VerticalAmpSlider(
                order: i + 1,
                value: values[i],
                step: step,
                maxAmplitude: maxAmplitude,
                enabled: enabled,
                color: FmwColors.harmonicColor(i + 1),
                onChanged: (v) => onChanged((i + 1, v)),
              ),
            ),
        ],
      ),
    );
  }
}

class _VerticalAmpSlider extends StatelessWidget {
  const _VerticalAmpSlider({
    required this.order,
    required this.value,
    required this.step,
    required this.maxAmplitude,
    required this.enabled,
    required this.color,
    required this.onChanged,
  });

  final int order;
  final double value;
  final double step;
  final double maxAmplitude;
  final bool enabled;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          FmwStrings.harmonicLabel(order),
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.25),
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.12),
              ),
              child: Slider(
                value: value.clamp(-maxAmplitude, maxAmplitude),
                min: -maxAmplitude,
                max: maxAmplitude,
                divisions: ((2 * maxAmplitude) / step).round(),
                onChanged: enabled
                    ? (v) {
                        final snapped = (v / step).round() * step;
                        onChanged(
                          snapped.clamp(-maxAmplitude, maxAmplitude).toDouble(),
                        );
                      }
                    : null,
              ),
            ),
          ),
        ),
        Text(
          value.toStringAsFixed(step >= 0.1 ? 1 : 2),
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }
}
