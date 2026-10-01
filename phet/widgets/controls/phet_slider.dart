/// PhET Slider — a versatile horizontal/vertical slider for any numeric
/// quantity (voltage, temperature, mass, pressure, etc.).
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double? step;
  final String? label;
  final String? unit;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final bool vertical;
  final bool showValueIndicator;

  /// Display format for the value (e.g. 1 decimal place).
  final int decimalPlaces;

  const PhetSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.step,
    this.label,
    this.unit,
    this.divisions,
    this.onChanged,
    this.enabled = true,
    this.vertical = false,
    this.showValueIndicator = true,
    this.decimalPlaces = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    final formattedValue = value.toStringAsFixed(decimalPlaces);

    return Column(
      crossAxisAlignment: vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || unit != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(label!, style: TextStyle(fontSize: 12, color: theme.textPrimary)),
              if (unit != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.buttonBorder),
                  ),
                  child: Text(
                    '$formattedValue $unit',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.textPrimary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        // Min/max labels
        if (!vertical)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(min.toStringAsFixed(0), style: TextStyle(fontSize: 10, color: theme.textSecondary)),
              Text('${(min + max) / 2}', style: TextStyle(fontSize: 10, color: theme.textSecondary)),
              Text(max.toStringAsFixed(0), style: TextStyle(fontSize: 10, color: theme.textSecondary)),
            ],
          ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: theme.sliderActive,
            inactiveTrackColor: theme.sliderInactive,
            thumbColor: theme.sliderThumb,
            overlayColor: theme.sliderThumb.withValues(alpha: 0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            showValueIndicator: showValueIndicator ? ShowValueIndicator.onDrag : ShowValueIndicator.never,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions ?? ((max - min) / (step ?? 0.5)).round(),
            label: '$formattedValue${unit != null ? ' $unit' : ''}',
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}
