/// Quantum Measurement — Spin Screen (shared apparatus + experiment config).
library;

import 'package:flutter/material.dart';

import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/qm_random.dart';
import '../../layout/qm_global_layout_spec.dart';
import '../animation/spin_animation_controller.dart';
import '../animation/spin_particle_simulation.dart';
import '../composer/spin_composer.dart';
import '../configuration/spin_experiment_view_configuration.dart';
import '../model/spin_model.dart';
import 'spin_scene.dart';

class QuantumMeasurementSpinScreen extends StatefulWidget {
  const QuantumMeasurementSpinScreen({
    super.key,
    this.model,
    this.random,
  });

  final SpinModel? model;
  final QmRandom? random;

  @override
  State<QuantumMeasurementSpinScreen> createState() =>
      _QuantumMeasurementSpinScreenState();
}

class _QuantumMeasurementSpinScreenState
    extends State<QuantumMeasurementSpinScreen>
    with SingleTickerProviderStateMixin {
  late final SpinModel _model;
  late final SpinParticleSimulation _simulation;
  late final SpinAnimationController _anim;
  final _composer = const SpinComposer();

  @override
  void initState() {
    super.initState();
    final rng = widget.random ?? SystemQmRandom();
    _model = widget.model ?? SpinModel(random: rng);
    _simulation = SpinParticleSimulation(model: _model);
    _anim = SpinAnimationController(
      simulation: _simulation,
      onTick: () {
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _anim.start(this);
    });
  }

  void _rebuild() => setState(() {});

  void _reset() {
    _simulation.clear();
    _model.reset();
    _rebuild();
  }

  @override
  void dispose() {
    _anim.dispose();
    _simulation.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = SpinExperimentViewConfiguration.fromModel(_model);

    return Scaffold(
      backgroundColor: QuantumMeasurementColors.screenBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);
          final frame = _composer.designFrame(viewport);
          final geometry = _composer.compose(
            viewport: viewport,
            config: config,
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
                    child: ColoredBox(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: SpinScene(
                              model: _model,
                              geometry: geometry,
                              simulation: _simulation,
                              onChanged: _rebuild,
                            ),
                          ),
                          Positioned(
                            right: qmScreenViewXMargin,
                            bottom: qmScreenViewYMargin,
                            child: KratosResetAllButton(
                              onPressed: _reset,
                              radius: 20.5,
                              tooltip: 'Reset All',
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

typedef SpinScreen = QuantumMeasurementSpinScreen;
