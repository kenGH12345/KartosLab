/// Visibility checkboxes: Force / Velocity / Mass / Path / Grid / Tape.
library;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../gao_colors.dart';
import '../gao_strings.dart';
import 'gravity_control.dart';

class CheckboxPanel extends StatelessWidget {
  const CheckboxPanel({super.key, required this.controller});

  final GaoController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GravityControl(controller: controller),
        const SizedBox(height: 8),
        _check(
          GaoStrings.gravityForce,
          m.showGravityForce,
          controller.setShowGravityForce,
        ),
        _check(
          GaoStrings.velocity,
          m.showVelocity,
          controller.setShowVelocity,
        ),
        if (m.showMassCheckbox)
          _check(GaoStrings.mass, m.showMass, controller.setShowMass),
        _check(
          GaoStrings.path,
          m.showPath,
          controller.setShowPath,
          trailing: Image.asset(
            GaoConstants.pathIconAsset,
            width: 18,
            height: 18,
          ),
        ),
        _check(GaoStrings.grid, m.showGrid, controller.setShowGrid),
        if (m.showMeasuringTape)
          _check(
            GaoStrings.measuringTape,
            m.showMeasuringTapeFlag,
            controller.setShowMeasuringTape,
          ),
      ],
    );
  }

  Widget _check(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                side: const BorderSide(color: GaoColors.foreground),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF1177AA);
                  }
                  return Colors.transparent;
                }),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: GaoColors.foreground, fontSize: 13),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}
