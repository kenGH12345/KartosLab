import 'package:flutter/material.dart';

import '../../../common/controls/kratos_radio_group.dart';
import '../../../common/controls/kratos_slider.dart';
import '../../../common/widgets/nine_grid_layout.dart';
import '../../controller/density_controller.dart';
import '../../density_constants.dart';
import '../../density_strings.dart';
import '../../model/compare_state.dart';
import '../../model/density_block.dart';
import '../../solver/compare_constraint.dart';
import '../canvas/density_canvas.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key, required this.controller});

  final DensityController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.compare;
        return NineGridLayout(
          center: DensityCanvas(controller: controller),
          footer: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  KratosRadioGroup<CompareBlockSet>(
                    items: CompareBlockSet.values,
                    itemLabels: const [
                      DensityStrings.sameMass,
                      DensityStrings.sameVolume,
                      DensityStrings.sameDensity,
                    ],
                    value: state.blockSet,
                    direction: Axis.horizontal,
                    onChanged: controller.setCompareSet,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 220,
                    child: _lockedSlider(state),
                  ),
                  TextButton(
                    onPressed: controller.resetCompare,
                    child: const Text(DensityStrings.resetAll),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _lockedSlider(CompareState state) {
    switch (state.blockSet) {
      case CompareBlockSet.sameMass:
        return KratosSlider(
          label: DensityStrings.mass,
          unit: DensityStrings.kg,
          min: CompareConstraint.sameMassMin,
          max: CompareConstraint.sameMassMax,
          value: state.lockedMass,
          step: 0.05,
          compact: true,
          onChanged: controller.setCompareLockedMass,
        );
      case CompareBlockSet.sameVolume:
        return KratosSlider(
          label: DensityStrings.volume,
          unit: DensityStrings.liters,
          min: DensityConstants.minVolumeLiters,
          max: DensityConstants.maxVolumeLiters,
          value: DensityConstants.litersFromCubicMeters(state.lockedVolume),
          step: 0.05,
          compact: true,
          onChanged: controller.setCompareLockedVolumeLiters,
        );
      case CompareBlockSet.sameDensity:
        return KratosSlider(
          label: DensityStrings.density,
          unit: 'kg/m³',
          min: CompareConstraint.sameDensityMin,
          max: CompareConstraint.sameDensityMax,
          value: state.lockedDensity,
          step: 0.05,
          compact: true,
          onChanged: controller.setCompareLockedDensity,
        );
    }
  }
}
