import 'package:flutter/material.dart';

import '../../buoyancy_strings.dart';
import '../../domain/material/buoyancy_material.dart';
import '../../physics/constants.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';

/// Source: `FluidDensityPanel` / `FluidDensityControlNode` (ComboNumberControl).
///
/// Dropdown picks preset fluids; density slider (kg/L, 0.5–15) switches to custom.
class BuoyancyFluidPanel extends StatelessWidget {
  const BuoyancyFluidPanel({
    super.key,
    required this.fluid,
    required this.onChanged,
    this.fluids = defaultFluids,
  });

  final BuoyancyMaterial fluid;
  final ValueChanged<BuoyancyMaterial> onChanged;
  final List<BuoyancyMaterial> fluids;

  /// Explore / Lab default mystery A/B visible.
  static const defaultFluids = <BuoyancyMaterial>[
    BuoyancyMaterial.gasoline,
    BuoyancyMaterial.oil,
    BuoyancyMaterial.water,
    BuoyancyMaterial.seawater,
    BuoyancyMaterial.honey,
    BuoyancyMaterial.mercury,
    BuoyancyMaterial.fluidA,
    BuoyancyMaterial.fluidB,
  ];

  static const shapesFluids = <BuoyancyMaterial>[
    BuoyancyMaterial.gasoline,
    BuoyancyMaterial.oil,
    BuoyancyMaterial.water,
    BuoyancyMaterial.seawater,
    BuoyancyMaterial.honey,
    BuoyancyMaterial.mercury,
    BuoyancyMaterial.fluidC,
    BuoyancyMaterial.fluidD,
  ];

  static const applicationsFluids = <BuoyancyMaterial>[
    BuoyancyMaterial.gasoline,
    BuoyancyMaterial.oil,
    BuoyancyMaterial.water,
    BuoyancyMaterial.seawater,
    BuoyancyMaterial.honey,
    BuoyancyMaterial.mercury,
    BuoyancyMaterial.fluidE,
    BuoyancyMaterial.fluidF,
  ];

  static const compareFluids = <BuoyancyMaterial>[
    BuoyancyMaterial.gasoline,
    BuoyancyMaterial.oil,
    BuoyancyMaterial.water,
    BuoyancyMaterial.seawater,
    BuoyancyMaterial.honey,
    BuoyancyMaterial.mercury,
  ];

  static const _customSentinel = '__custom__';

  String _label(BuoyancyMaterial m) {
    if (m.custom) return BuoyancyStrings.custom;
    return BuoyancyStrings.fluidLabel(m.id);
  }

  @override
  Widget build(BuildContext context) {
    final kgPerL = (fluid.density / 1000).clamp(0.5, 15.0).toDouble();
    final presetMatch = fluids.cast<BuoyancyMaterial?>().firstWhere(
          (f) => f!.id == fluid.id && !fluid.custom,
          orElse: () => null,
        );
    final dropdownId = presetMatch?.id ?? _customSentinel;

    return BuoyancyPanel(
      child: SizedBox(
        width: 168,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(BuoyancyStrings.fluidDensity,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: dropdownId,
              items: [
                for (final f in fluids)
                  DropdownMenuItem(value: f.id, child: Text(_label(f))),
                const DropdownMenuItem(
                  value: _customSentinel,
                  child: Text(BuoyancyStrings.custom),
                ),
              ],
              onChanged: (id) {
                if (id == null) return;
                if (id == _customSentinel) {
                  onChanged(BuoyancyMaterial.customFluid(fluid.density));
                  return;
                }
                onChanged(fluids.firstWhere((f) => f.id == id));
              },
            ),
            Text(
              '${kgPerL.toStringAsFixed(2)} kg/L',
              style: const TextStyle(fontSize: 11),
            ),
            Slider(
              value: kgPerL,
              min: 0.5,
              max: 15,
              onChanged: (v) {
                final density = (v * 1000)
                    .clamp(
                      BuoyancyPhysicsConstants.fluidDensityMinKgPerM3,
                      BuoyancyPhysicsConstants.fluidDensityMaxKgPerM3,
                    )
                    .toDouble();
                BuoyancyMaterial? match;
                for (final f in fluids) {
                  if ((f.density - density).abs() < 1) {
                    match = f;
                    break;
                  }
                }
                onChanged(match ?? BuoyancyMaterial.customFluid(density));
              },
            ),
          ],
        ),
      ),
    );
  }
}
