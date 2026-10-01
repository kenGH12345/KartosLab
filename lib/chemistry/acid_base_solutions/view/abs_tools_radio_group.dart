import 'package:flutter/material.dart';

import '../model/abs_colors.dart';
import '../model/abs_view_properties.dart';
import 'abs_conductivity_layer.dart';
import 'abs_ph_meter_layer.dart';
import 'abs_ph_paper_layer.dart';

/// Tools radio group — PhET `ToolsRadioButtonGroup.ts`.
/// Does **not** expose ToolMode.none.
class AbsToolsRadioGroup extends StatelessWidget {
  const AbsToolsRadioGroup({
    super.key,
    required this.toolMode,
    required this.onChanged,
  });

  final AbsToolMode toolMode;
  final ValueChanged<AbsToolMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <({AbsToolMode mode, Widget icon})>[
      (mode: AbsToolMode.pHMeter, icon: const AbsPhMeterIcon()),
      (mode: AbsToolMode.pHPaper, icon: const AbsPhPaperIcon()),
      (mode: AbsToolMode.conductivityTester, icon: const AbsLightBulbIcon()),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: GestureDetector(
              onTap: () => onChanged(item.mode),
              child: Container(
                width: 48,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AbsColors.toolRadioButtonFill,
                  border: Border.all(
                    color:
                        toolMode == item.mode ? Colors.black : Colors.black38,
                    width: toolMode == item.mode ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: item.icon,
              ),
            ),
          ),
      ],
    );
  }
}
