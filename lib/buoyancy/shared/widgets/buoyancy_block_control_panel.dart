import 'package:flutter/material.dart';

import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/material/buoyancy_material.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';

/// Source: `BlockControlNode` / `MaterialMassVolumeControlNode`.
class BuoyancyBlockControlPanel extends StatelessWidget {
  const BuoyancyBlockControlPanel({
    super.key,
    required this.mass,
    required this.materials,
    required this.onMaterial,
    required this.onMass,
    required this.onVolume,
    this.tag,
    this.tagColor = const Color(0xFF1177AA),
    this.maxVolumeL = 10,
  });

  final BuoyancyMass mass;
  final List<BuoyancyMaterial> materials;
  final ValueChanged<BuoyancyMaterial> onMaterial;
  final ValueChanged<double> onMass;
  final ValueChanged<double> onVolume;
  final String? tag;
  final Color tagColor;
  final double maxVolumeL;

  static const double minMass = 0.1;
  static const double maxMass = 27;
  static const double minVolumeL = 1;

  String _label(BuoyancyMaterial m) {
    if (m.custom) return 'Custom';
    if (m.id.startsWith('material')) {
      return 'Material ${m.id.substring(m.id.length - 1).toUpperCase()}';
    }
    return m.id[0].toUpperCase() + m.id.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final volumeL =
        (mass.volume * 1000).clamp(minVolumeL, maxVolumeL).toDouble();
    final massKg = mass.mass.clamp(minMass, maxMass).toDouble();
    final selected = materials.cast<BuoyancyMaterial?>().firstWhere(
          (m) => m!.id == mass.material.id,
          orElse: () => materials.first,
        )!;

    return BuoyancyPanel(
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (tag != null) ...[
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      tag!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: DropdownButton<BuoyancyMaterial>(
                    isExpanded: true,
                    isDense: true,
                    value: selected,
                    items: [
                      for (final m in materials)
                        DropdownMenuItem(value: m, child: Text(_label(m))),
                    ],
                    onChanged: (v) {
                      if (v != null) onMaterial(v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Mass ${massKg.toStringAsFixed(2)} kg',
                style: const TextStyle(fontSize: 11)),
            Slider(
              value: massKg,
              min: minMass,
              max: maxMass,
              activeColor: tagColor,
              onChanged: onMass,
            ),
            Text('Volume ${volumeL.toStringAsFixed(2)} L',
                style: const TextStyle(fontSize: 11)),
            Slider(
              value: volumeL,
              min: minVolumeL,
              max: maxVolumeL,
              activeColor: tagColor,
              onChanged: (liters) => onVolume(liters / 1000),
            ),
          ],
        ),
      ),
    );
  }
}
