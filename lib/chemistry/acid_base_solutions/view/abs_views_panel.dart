import 'package:flutter/material.dart';

import '../model/abs_colors.dart';
import '../model/abs_view_properties.dart';
import 'abs_assets.dart';
import 'abs_beaker_painter.dart';
import 'abs_concentration_graph.dart';

/// Views panel — PhET `ViewsPanel.ts`.
class AbsViewsPanel extends StatelessWidget {
  const AbsViewsPanel({
    super.key,
    required this.viewMode,
    required this.onChanged,
  });

  final AbsViewMode viewMode;
  final ValueChanged<AbsViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <({AbsViewMode mode, String label, Widget icon})>[
      (
        mode: AbsViewMode.particles,
        label: 'Particles',
        icon: Image.asset(AbsAssets.magnifyingGlassIcon, width: 28, height: 22),
      ),
      (
        mode: AbsViewMode.graph,
        label: 'Graph',
        icon: const AbsGraphIcon(),
      ),
      (
        mode: AbsViewMode.hideViews,
        label: 'Hide Views',
        icon: const AbsBeakerIcon(),
      ),
    ];

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: AbsColors.controlPanelFill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF5A6BB0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Views',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onChanged(item.mode),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    _AquaRadio(selected: viewMode == item.mode),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    item.icon,
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AquaRadio extends StatelessWidget {
  const _AquaRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 1.5),
        color: Colors.white,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3376C4),
                ),
              ),
            )
          : null,
    );
  }
}
