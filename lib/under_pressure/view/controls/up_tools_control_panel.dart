import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';

/// Source: `ControlPanel.js` — ruler / grid checkboxes + atmosphere radios.
class UpToolsControlPanel extends StatelessWidget {
  const UpToolsControlPanel({super.key, required this.controller});

  final UnderPressureController controller;

  static const Color panelFill = Color(0xFFF2FA6A);

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        color: panelFill,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _check(
            'Ruler',
            m.isRulerVisible,
            (v) => controller.setRulerVisible(v),
          ),
          _check(
            'Grid',
            m.isGridVisible,
            (v) => controller.setGridVisible(v),
          ),
          const SizedBox(height: 6),
          const Text(
            'Atmosphere',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _radio('On', m.isAtmosphere, () => controller.setAtmosphere(true)),
              const SizedBox(width: 10),
              _radio('Off', !m.isAtmosphere, () => controller.setAtmosphere(false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _check(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radio(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 14,
            color: selected ? Colors.blue : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
