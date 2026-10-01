/// Gravity on/off radio control.
library;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../gao_colors.dart';
import '../gao_strings.dart';

class GravityControl extends StatelessWidget {
  const GravityControl({super.key, required this.controller});

  final GaoController controller;

  @override
  Widget build(BuildContext context) {
    final on = controller.model.gravityEnabled;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '${GaoStrings.gravity}:',
          style: TextStyle(color: GaoColors.foreground, fontSize: 14),
        ),
        const SizedBox(width: 8),
        _radio(GaoStrings.on, on, () => controller.setGravityEnabled(true)),
        const SizedBox(width: 10),
        _radio(GaoStrings.off, !on, () => controller.setGravityEnabled(false)),
      ],
    );
  }

  Widget _radio(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 16,
            color: GaoColors.foreground,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: GaoColors.foreground, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
