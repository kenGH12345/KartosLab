import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/controls/kratos_radio_group.dart';
import '../../../common/widgets/nine_grid_layout.dart';
import '../../controller/density_controller.dart';
import '../../density_strings.dart';
import '../../model/density_block.dart';
import '../canvas/density_canvas.dart';
import '../dialogs/density_table_panel.dart';

class MysteryScreen extends StatelessWidget {
  const MysteryScreen({super.key, required this.controller});

  final DensityController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.mystery;
        return LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth =
                constraints.maxWidth * math.sqrt(NineGridLayout.kMinCenterAreaRatio);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                NineGridLayout(
                  center: DensityCanvas(controller: controller),
                  footer: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          KratosRadioGroup<MysteryBlockSet>(
                            items: MysteryBlockSet.values,
                            itemLabels: const [
                              DensityStrings.set1,
                              DensityStrings.set2,
                              DensityStrings.set3,
                              DensityStrings.random,
                            ],
                            value: state.blockSet,
                            direction: Axis.horizontal,
                            onChanged: controller.setMysterySet,
                          ),
                          if (state.blockSet == MysteryBlockSet.random)
                            TextButton(
                              onPressed: controller.refreshMysteryRandom,
                              child: const Text(DensityStrings.refreshRandom),
                            ),
                          TextButton(
                            onPressed: controller.resetMystery,
                            child: const Text(DensityStrings.resetAll),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // PhET: AccordionBox at top-center; expands over play area (not
                // the ~55px NineGrid top row, which clipped all 13 table rows).
                Positioned(
                  top: 4,
                  left: (constraints.maxWidth - tableWidth) / 2,
                  width: tableWidth,
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(5),
                    clipBehavior: Clip.antiAlias,
                    child: DensityTablePanel(
                      key: ValueKey(state.tableExpanded),
                      expanded: state.tableExpanded,
                      onExpandedChanged: controller.setMysteryTableExpanded,
                      maxBodyHeight: constraints.maxHeight * 0.5,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
