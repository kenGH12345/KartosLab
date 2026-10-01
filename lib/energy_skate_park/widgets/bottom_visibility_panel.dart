import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/widgets/esp_checkbox_icons.dart';

/// Bottom-left Grid + Reference Height (EnergySkateParkVisibilityControls.ts).
class BottomVisibilityPanel extends StatelessWidget {
  const BottomVisibilityPanel({super.key, required this.controller});

  final EspController controller;

  @override
  Widget build(BuildContext context) {
    final view = controller.view;
    return Material(
      elevation: 1,
      color: const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: view.gridVisible,
              onChanged: (v) => controller.setGridVisible(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            EspCheckboxIcons.grid(),
            const SizedBox(width: 4),
            const Text(EspStrings.grid, style: TextStyle(fontSize: 12)),
            const SizedBox(width: 12),
            Checkbox(
              value: view.referenceHeightVisible,
              onChanged: (v) =>
                  controller.setReferenceHeightVisible(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            EspCheckboxIcons.referenceHeight(),
            const SizedBox(width: 4),
            const Text(EspStrings.referenceHeight,
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
