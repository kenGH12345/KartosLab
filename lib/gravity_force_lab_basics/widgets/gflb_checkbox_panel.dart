import 'package:flutter/material.dart';

import '../gflb_colors.dart';
import '../gflb_strings.dart';
import '../model/gravity_model.dart';

/// Checkbox panel: Force Values / Distance / Constant Size.
class GflbCheckboxPanel extends StatelessWidget {
  const GflbCheckboxPanel({super.key, required this.model});

  final GravityModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 170),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GflbColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(
            GflbStrings.forceValues,
            model.showForceValues,
            model.setShowForceValues,
          ),
          const SizedBox(height: 10),
          _row(
            GflbStrings.distance,
            model.showDistance,
            model.setShowDistance,
          ),
          const SizedBox(height: 10),
          _row(
            GflbStrings.constantSize,
            model.constantSize,
            model.setConstantSize,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
