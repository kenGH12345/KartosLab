/// "N Earth Days|Minutes" + Clear (clears simulationTime only).
library;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../gao_colors.dart';
import '../gao_strings.dart';

class TimeCounter extends StatelessWidget {
  const TimeCounter({super.key, required this.controller});

  final GaoController controller;

  @override
  Widget build(BuildContext context) {
    final days = controller.model.scene.timeInDays;
    final value = controller.displayedTime;
    final unit = days ? GaoStrings.earthDays : GaoStrings.earthMinutes;
    final text = days
        ? '${value.round()} $unit'
        : '${value.toStringAsFixed(0)} $unit';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(color: GaoColors.foreground, fontSize: 15),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: value > 0 ? controller.clearSimulationTime : null,
          child: const Text(
            GaoStrings.clear,
            style: TextStyle(color: GaoColors.foreground, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
