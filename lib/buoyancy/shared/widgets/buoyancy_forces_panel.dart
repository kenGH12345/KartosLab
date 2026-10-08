import 'package:flutter/material.dart';

import '../../buoyancy_strings.dart';
import '../display_properties.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';

/// Source: `BuoyancyDisplayOptionsPanel.ts` (Forces + Mass Values + Depth Lines).
/// Compact Material stand-in — keep ≤ ~168px wide so it stays in the left margin.
class BuoyancyForcesPanel extends StatelessWidget {
  const BuoyancyForcesPanel({
    super.key,
    required this.display,
    required this.onChanged,
  });

  final BuoyancyDisplayProperties display;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    Widget check(String label, bool value, ValueChanged<bool?> set,
        {Widget? trailing}) {
      return InkWell(
        onTap: () {
          set(!value);
          onChanged();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: value,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: (v) {
                    set(v);
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 12)),
              ),
              ?trailing,
            ],
          ),
        ),
      );
    }

    Widget arrow(Color c) => Icon(Icons.arrow_right_alt, color: c, size: 18);

    return BuoyancyPanel(
      child: SizedBox(
        width: 156,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(BuoyancyStrings.forces,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            check(
              BuoyancyStrings.gravity,
              display.gravityForceVisible,
              (v) => display.gravityForceVisible = v ?? false,
              trailing: arrow(const Color(0xFFC51E1E)),
            ),
            check(
              BuoyancyStrings.buoyancy,
              display.buoyancyForceVisible,
              (v) => display.buoyancyForceVisible = v ?? false,
              trailing: arrow(const Color(0xFFDA338A)),
            ),
            check(
              BuoyancyStrings.contact,
              display.contactForceVisible,
              (v) => display.contactForceVisible = v ?? false,
              trailing: arrow(const Color(0xFFEA963E)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(BuoyancyStrings.vectorZoom,
                        style: TextStyle(fontSize: 12)),
                  ),
                  _zoomBtn(Icons.remove, () {
                    display.vectorZoomLevel =
                        (display.vectorZoomLevel - 1).clamp(0, 7);
                    onChanged();
                  }),
                  _zoomBtn(Icons.add, () {
                    display.vectorZoomLevel =
                        (display.vectorZoomLevel + 1).clamp(0, 7);
                    onChanged();
                  }),
                ],
              ),
            ),
            check(
              BuoyancyStrings.forceValues,
              display.forceValuesVisible,
              (v) => display.forceValuesVisible = v ?? false,
            ),
            const Divider(height: 6),
            check(
              BuoyancyStrings.massValues,
              display.massValuesVisible,
              (v) => display.massValuesVisible = v ?? false,
            ),
            if (display.supportsDepthLines)
              check(
                BuoyancyStrings.depthLines,
                display.depthLinesVisible,
                (v) => display.depthLinesVisible = v ?? false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
