// Copyright 2024-2026, University of Colorado Boulder
/// Coins screen shell: scene tabs + active scene + Reset All.
///
/// Corresponds to `js/coins/view/CoinsScreenView.ts`.
library;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../common/model/system_type.dart';
import '../../common/quantum_measurement_colors.dart';
import '../../common/quantum_measurement_strings.dart';
import '../../common/view/scene_selector_radio_button_group.dart';
import '../model/coins_model.dart';
import 'coins_experiment_scene_view.dart';

class CoinsScreenView extends StatelessWidget {
  const CoinsScreenView({super.key, required this.model});

  final CoinsModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuantumMeasurementColors.screenBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _SceneSelector(model: model),
                Expanded(
                  child: ValueListenableBuilder<SystemType>(
                    valueListenable: model.experimentModeProperty,
                    builder: (context, mode, _) {
                      // IndexedStack keeps both scenes alive and always
                      // expands to the full Expanded area (unlike Visibility
                      // which can report 0×0 and collapse layout).
                      return IndexedStack(
                        index: mode == SystemType.classical ? 0 : 1,
                        sizing: StackFit.expand,
                        children: [
                          CoinsExperimentSceneView(
                            scene: model.classicalCoinExperimentSceneModel,
                          ),
                          CoinsExperimentSceneView(
                            scene: model.quantumCoinExperimentSceneModel,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 12,
              child: KratosResetAllButton(
                onPressed: model.reset,
                radius: 20.5,
                tooltip: QuantumMeasurementStrings.reset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneSelector extends StatelessWidget {
  const _SceneSelector({required this.model});

  final CoinsModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Center(
        child: ValueListenableBuilder<SystemType>(
          valueListenable: model.experimentModeProperty,
          builder: (context, mode, _) {
            return SceneSelectorRadioButtonGroup<SystemType>(
              items: const [
                (
                  SystemType.classical,
                  QuantumMeasurementStrings.classicalCoin
                ),
                (
                  SystemType.quantum,
                  QuantumMeasurementStrings.quantumCoinQuoted
                ),
              ],
              selectedValue: mode,
              onChanged: (v) => model.experimentModeProperty.value = v,
            );
          },
        ),
      ),
    );
  }
}
