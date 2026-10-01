import 'package:flutter/material.dart';

import '../compare_block_set.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';

/// Source: `BlocksValuePanel.ts` — Mass / Volume / Density NumberControl.
class BuoyancyBlocksValuePanel extends StatelessWidget {
  const BuoyancyBlocksValuePanel({
    super.key,
    required this.mode,
    required this.massKg,
    required this.volumeM3,
    required this.densityKgPerM3,
    required this.onMass,
    required this.onVolume,
    required this.onDensity,
    required this.massMin,
    required this.massMax,
    required this.volumeMin,
    required this.volumeMax,
    required this.densityMin,
    required this.densityMax,
  });

  final CompareBlockSet mode;
  final double massKg;
  final double volumeM3;
  final double densityKgPerM3;
  final ValueChanged<double> onMass;
  final ValueChanged<double> onVolume;
  final ValueChanged<double> onDensity;
  final double massMin;
  final double massMax;
  final double volumeMin;
  final double volumeMax;
  final double densityMin;
  final double densityMax;

  @override
  Widget build(BuildContext context) {
    final (title, valueText, min, max, value, onChanged) = switch (mode) {
      CompareBlockSet.sameMass => (
          'Mass',
          '${massKg.toStringAsFixed(2)} kg',
          massMin,
          massMax,
          massKg,
          onMass,
        ),
      CompareBlockSet.sameVolume => (
          'Volume',
          '${(volumeM3 * 1000).toStringAsFixed(2)} L',
          volumeMin * 1000,
          volumeMax * 1000,
          volumeM3 * 1000,
          (v) => onVolume(v / 1000),
        ),
      CompareBlockSet.sameDensity => (
          'Density',
          '${(densityKgPerM3 / 1000).toStringAsFixed(2)} kg/L',
          densityMin / 1000,
          densityMax / 1000,
          densityKgPerM3 / 1000,
          (v) => onDensity(v * 1000),
        ),
    };

    return BuoyancyPanel(
      child: SizedBox(
        width: 176,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(valueText, style: const TextStyle(fontSize: 13)),
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => onChanged((value - (max - min) * 0.05).clamp(min, max)),
                  icon: const Icon(Icons.remove, size: 16),
                ),
                Expanded(
                  child: Slider(
                    value: value.clamp(min, max),
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => onChanged((value + (max - min) * 0.05).clamp(min, max)),
                  icon: const Icon(Icons.add, size: 16),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(min.toStringAsFixed(mode == CompareBlockSet.sameMass ? 0 : 2),
                    style: const TextStyle(fontSize: 10, color: Colors.black54)),
                Text(max.toStringAsFixed(mode == CompareBlockSet.sameMass ? 0 : 2),
                    style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
