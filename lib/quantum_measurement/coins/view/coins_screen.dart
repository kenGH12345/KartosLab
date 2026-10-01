/// Quantum Measurement -?Coins Screen shell.
/// Design frame 1024×618, uniform scale, Classical/Quantum mutually exclusive scenes.
/// Does NOT navigate to QuantumCoinTossHome.
library;

import 'package:flutter/material.dart';

import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';
import 'package:kratos/quantum_coin_toss/common/view/scene_selector_radio_button_group.dart';

import '../../common/system_type.dart';
import '../../layout/qm_global_layout_spec.dart';
import '../composer/coins_composer.dart';
import '../model/coins_model.dart';
import 'classical_coins_scene.dart';
import 'quantum_coins_scene.dart';

class QuantumMeasurementCoinsScreen extends StatefulWidget {
  const QuantumMeasurementCoinsScreen({
    super.key,
    this.model,
  });

  final CoinsModel? model;

  @override
  State<QuantumMeasurementCoinsScreen> createState() =>
      _QuantumMeasurementCoinsScreenState();
}

class _QuantumMeasurementCoinsScreenState
    extends State<QuantumMeasurementCoinsScreen> {
  late final CoinsModel _model;
  final _composer = const CoinsComposer();

  @override
  void initState() {
    super.initState();
    _model = widget.model ?? CoinsModel();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuantumMeasurementColors.screenBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);
          final frame = _composer.designFrame(viewport);
          final classicalGeometry = _composer.compose(
            viewport: viewport,
            preparing: _model.classicalScene.preparingExperiment,
          );
          final quantumGeometry = _composer.compose(
            viewport: viewport,
            preparing: _model.quantumScene.preparingExperiment,
          );

          return Stack(
            children: [
              Positioned(
                left: frame.origin.dx,
                top: frame.origin.dy,
                child: Transform.scale(
                  scale: frame.scale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: qmDesignWidth,
                    height: qmDesignHeight,
                    child: _DesignCanvas(
                      model: _model,
                      classicalGeometry: classicalGeometry,
                      quantumGeometry: quantumGeometry,
                      onChanged: _rebuild,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DesignCanvas extends StatelessWidget {
  const _DesignCanvas({
    required this.model,
    required this.classicalGeometry,
    required this.quantumGeometry,
    required this.onChanged,
  });

  final CoinsModel model;
  final CoinsLayoutGeometry classicalGeometry;
  final CoinsLayoutGeometry quantumGeometry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final classicalBg = QuantumMeasurementColors.classicalSceneBackground;
    final quantumBg = QuantumMeasurementColors.quantumSceneBackground;
    final bg = model.experimentMode == SystemType.classical
        ? classicalBg
        : quantumBg;
    final geometry = model.experimentMode == SystemType.classical
        ? classicalGeometry
        : quantumGeometry;

    return ColoredBox(
      color: bg,
      child: Stack(
        children: [
          Positioned(
            left: geometry.sceneSelector.left,
            top: geometry.sceneSelector.top,
            width: geometry.sceneSelector.width,
            height: geometry.sceneSelector.height,
            child: Center(
              child: SceneSelectorRadioButtonGroup<SystemType>(
                items: const [
                  (SystemType.classical, 'Classical Coin'),
                  (SystemType.quantum, "Quantum 'Coin'"),
                ],
                selectedValue: model.experimentMode,
                onChanged: (mode) {
                  model.setExperimentMode(mode);
                  onChanged();
                },
              ),
            ),
          ),
          Positioned(
            left: geometry.sceneOrigin.dx,
            top: geometry.sceneOrigin.dy,
            width: qmDesignWidth,
            height: qmDesignHeight - geometry.sceneOrigin.dy,
            child: IndexedStack(
              index: model.experimentMode == SystemType.classical ? 0 : 1,
              sizing: StackFit.expand,
              children: [
                ClassicalCoinsScene(
                  scene: model.classicalScene,
                  geometry: classicalGeometry,
                  onChanged: onChanged,
                ),
                QuantumCoinsScene(
                  scene: model.quantumScene,
                  geometry: quantumGeometry,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
          Positioned(
            right: qmScreenViewXMargin,
            bottom: qmScreenViewYMargin,
            child: KratosResetAllButton(
              onPressed: () {
                model.reset();
                onChanged();
              },
              radius: 20.5,
              tooltip: 'Reset All',
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias matching PHASE 3 file inventory naming.
typedef CoinsScreen = QuantumMeasurementCoinsScreen;
