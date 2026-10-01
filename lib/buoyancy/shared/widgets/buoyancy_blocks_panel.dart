import 'package:flutter/material.dart';

import '../compare_block_set.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';

/// Source: `BlocksPanel.ts` — title + Same Mass/Volume/Density radios only.
class BuoyancyBlocksPanel extends StatelessWidget {
  const BuoyancyBlocksPanel({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CompareBlockSet value;
  final ValueChanged<CompareBlockSet> onChanged;

  @override
  Widget build(BuildContext context) {
    return BuoyancyPanel(
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Blocks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            for (final mode in CompareBlockSet.values)
              InkWell(
                onTap: () => onChanged(mode),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        value == mode
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 18,
                        color: const Color(0xFF1177AA),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          switch (mode) {
                            CompareBlockSet.sameMass => 'Same Mass',
                            CompareBlockSet.sameVolume => 'Same Volume',
                            CompareBlockSet.sameDensity => 'Same Density',
                          },
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
