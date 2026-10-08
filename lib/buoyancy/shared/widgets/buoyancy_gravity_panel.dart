import 'package:flutter/material.dart';

import '../../buoyancy_strings.dart';
import '../../domain/material/buoyancy_gravity.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';

/// Source: `GravityControlNode` panel.
class BuoyancyGravityPanel extends StatelessWidget {
  const BuoyancyGravityPanel({
    super.key,
    required this.value,
    required this.presets,
    required this.onChanged,
  });

  final BuoyancyGravity value;
  final List<BuoyancyGravity> presets;
  final ValueChanged<BuoyancyGravity> onChanged;

  String _label(BuoyancyGravity g) => BuoyancyStrings.gravityLabel(g.id);

  @override
  Widget build(BuildContext context) {
    final selected = presets.cast<BuoyancyGravity?>().firstWhere(
          (g) => g!.id == value.id,
          orElse: () => presets.firstWhere((g) => g.id == 'earth',
              orElse: () => presets.first),
        )!;
    return BuoyancyPanel(
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(BuoyancyStrings.gravity,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            DropdownButton<BuoyancyGravity>(
              isExpanded: true,
              value: selected,
              items: [
                for (final g in presets)
                  DropdownMenuItem(value: g, child: Text(_label(g))),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
