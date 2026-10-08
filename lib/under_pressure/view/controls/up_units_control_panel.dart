import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/under_pressure_strings.dart';

/// Source: `UnitsControlPanel.js`
class UpUnitsControlPanel extends StatelessWidget {
  const UpUnitsControlPanel({super.key, required this.controller});

  final UnderPressureController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FA6A),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            UnderPressureStrings.units,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          _item(UnderPressureStrings.metric, MeasureUnits.metric, m.measureUnits),
          _item(UnderPressureStrings.atmospheres, MeasureUnits.atmosphere, m.measureUnits),
          _item(UnderPressureStrings.english, MeasureUnits.english, m.measureUnits),
        ],
      ),
    );
  }

  Widget _item(String label, MeasureUnits value, MeasureUnits current) {
    final selected = value == current;
    return InkWell(
      onTap: () => controller.setUnits(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 14,
              color: selected ? Colors.blue : Colors.black54,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
