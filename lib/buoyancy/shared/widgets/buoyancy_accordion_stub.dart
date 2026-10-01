import 'package:flutter/material.dart';

import '../../rendering/runtime/buoyancy_play_area.dart';

/// Collapsed AccordionBox stand-in (`DensityAccordionBox` / `SubmergedAccordionBox`).
class BuoyancyAccordionStub extends StatelessWidget {
  const BuoyancyAccordionStub({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    this.child,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BuoyancyPanel(
      child: SizedBox(
        width: 176,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onToggle,
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.remove : Icons.add,
                    size: 18,
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            if (expanded && child != null) ...[
              const SizedBox(height: 6),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
