import 'package:flutter/material.dart';

import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/material/buoyancy_material.dart';
import 'buoyancy_block_control_panel.dart';

/// Source: `ABControlsNode` — A + optional B block panels.
class BuoyancyAbControlsPanel extends StatelessWidget {
  const BuoyancyAbControlsPanel({
    super.key,
    required this.blockA,
    required this.blockB,
    required this.showB,
    required this.materials,
    required this.onMaterial,
    required this.onMass,
    required this.onVolume,
  });

  final BuoyancyMass blockA;
  final BuoyancyMass blockB;
  final bool showB;
  final List<BuoyancyMaterial> materials;
  final void Function(String id, BuoyancyMaterial material) onMaterial;
  final void Function(String id, double massKg) onMass;
  final void Function(String id, double volumeM3) onVolume;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        BuoyancyBlockControlPanel(
          tag: 'A',
          tagColor: const Color(0xFF2F59A6),
          mass: blockA,
          materials: materials,
          onMaterial: (m) => onMaterial(blockA.id, m),
          onMass: (v) => onMass(blockA.id, v),
          onVolume: (v) => onVolume(blockA.id, v),
        ),
        if (showB) ...[
          const SizedBox(height: 5),
          BuoyancyBlockControlPanel(
            tag: 'B',
            tagColor: const Color(0xFFED3732),
            mass: blockB,
            materials: materials,
            onMaterial: (m) => onMaterial(blockB.id, m),
            onMass: (v) => onMass(blockB.id, v),
            onVolume: (v) => onVolume(blockB.id, v),
          ),
        ],
      ],
    );
  }
}
