/// Quantum Measurement — Photons Screen.
library;

import 'package:flutter/material.dart';

import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';
import 'package:kratos/quantum_coin_toss/common/view/scene_selector_radio_button_group.dart';

import '../../common/qm_random.dart';
import '../../layout/qm_global_layout_spec.dart';
import '../animation/photon_animation_controller.dart';
import '../composer/photons_composer.dart';
import '../model/photon_simulation.dart';
import '../model/photons_model.dart';
import 'photons_scene.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class QuantumMeasurementPhotonsScreen extends StatefulWidget {
  const QuantumMeasurementPhotonsScreen({
    super.key,
    this.model,
    this.random,
  });

  final PhotonsModel? model;
  final QmRandom? random;

  @override
  State<QuantumMeasurementPhotonsScreen> createState() =>
      _QuantumMeasurementPhotonsScreenState();
}

class _QuantumMeasurementPhotonsScreenState
    extends State<QuantumMeasurementPhotonsScreen>
    with SingleTickerProviderStateMixin {
  late final PhotonsModel _model;
  late final QmRandom _random;
  late final PhotonsSpatialSimulation _singleSim;
  late final PhotonsSpatialSimulation _manySim;
  late final PhotonAnimationController _anim;
  final _composer = const PhotonsComposer();

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? SystemQmRandom();
    _model = widget.model ?? PhotonsModel(random: _random);
    _singleSim = PhotonsSpatialSimulation(
      scene: _model.singlePhotonScene,
      random: _random,
    );
    _manySim = PhotonsSpatialSimulation(
      scene: _model.manyPhotonsScene,
      random: _random,
    );
    _anim = PhotonAnimationController(
      simulation: _singleSim,
      onTick: () {
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _anim.start(this);
    });
  }

  PhotonsSpatialSimulation get _activeSim =>
      _model.experimentMode == PhotonExperimentMode.singlePhoton
          ? _singleSim
          : _manySim;

  void _rebuild() {
    _anim.simulation = _activeSim;
    setState(() {});
  }

  void _resetAll() {
    _singleSim.clearPhotons();
    _manySim.clearPhotons();
    _singleSim.emissionRate = 0;
    _manySim.emissionRate = 0;
    _model.reset();
    _rebuild();
  }

  @override
  void dispose() {
    _anim.dispose();
    _singleSim.clearPhotons();
    _manySim.clearPhotons();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _anim.simulation = _activeSim;

    return Scaffold(
      backgroundColor: QuantumMeasurementColors.screenBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);
          final frame = _composer.designFrame(viewport);
          final geometry = _composer.compose(viewport: viewport);

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
                    child: ColoredBox(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Positioned(
                            left: geometry.sceneSelector.left,
                            top: geometry.sceneSelector.top,
                            width: geometry.sceneSelector.width,
                            height: geometry.sceneSelector.height,
                            child: Center(
                              child: SceneSelectorRadioButtonGroup<
                                  PhotonExperimentMode>(
                                items: const [
                                  (
                                    PhotonExperimentMode.singlePhoton,
                                    QmStrings.singlePhoton
                                  ),
                                  (
                                    PhotonExperimentMode.manyPhotons,
                                    QmStrings.manyPhotons
                                  ),
                                ],
                                selectedValue: _model.experimentMode,
                                onChanged: (mode) {
                                  _model.experimentMode = mode;
                                  _rebuild();
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: geometry.sceneOriginY,
                            width: qmDesignWidth,
                            height: qmDesignHeight - geometry.sceneOriginY,
                            child: IndexedStack(
                              index: _model.experimentMode ==
                                      PhotonExperimentMode.singlePhoton
                                  ? 0
                                  : 1,
                              sizing: StackFit.expand,
                              children: [
                                PhotonsScene(
                                  geometry: geometry,
                                  simulation: _singleSim,
                                  onChanged: _rebuild,
                                ),
                                PhotonsScene(
                                  geometry: geometry,
                                  simulation: _manySim,
                                  onChanged: _rebuild,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: qmScreenViewXMargin,
                            bottom: qmScreenViewYMargin,
                            child: KratosResetAllButton(
                              onPressed: _resetAll,
                              radius: 20.5,
                              tooltip: QmStrings.resetAll,
                            ),
                          ),
                        ],
                      ),
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

typedef PhotonsScreen = QuantumMeasurementPhotonsScreen;
