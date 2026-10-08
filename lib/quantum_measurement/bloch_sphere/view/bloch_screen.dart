/// Quantum Measurement — Bloch Sphere Screen.
library;

import 'package:flutter/material.dart';

import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/qm_random.dart';
import '../../layout/qm_global_layout_spec.dart';
import '../animation/bloch_animation_controller.dart';
import '../composer/bloch_composer.dart';
import '../model/bloch_sphere_model.dart';
import 'bloch_scene.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class QuantumMeasurementBlochScreen extends StatefulWidget {
  const QuantumMeasurementBlochScreen({
    super.key,
    this.model,
    this.random,
  });

  final BlochSphereModel? model;
  final QmRandom? random;

  @override
  State<QuantumMeasurementBlochScreen> createState() =>
      _QuantumMeasurementBlochScreenState();
}

class _QuantumMeasurementBlochScreenState
    extends State<QuantumMeasurementBlochScreen>
    with SingleTickerProviderStateMixin {
  late final BlochSphereModel _model;
  late final BlochAnimationController _anim;
  final _composer = const BlochComposer();

  @override
  void initState() {
    super.initState();
    final rng = widget.random ?? SystemQmRandom();
    _model = widget.model ?? BlochSphereModel(random: rng);
    _anim = BlochAnimationController(
      model: _model,
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
    _model.reset();
    _rebuild();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Material(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: BlochScene(
                              model: _model,
                              geometry: geometry,
                              onChanged: _rebuild,
                            ),
                          ),
                          Positioned(
                            right: qmScreenViewXMargin,
                            bottom: qmScreenViewYMargin,
                            child: KratosResetAllButton(
                              onPressed: _reset,
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

typedef BlochScreen = QuantumMeasurementBlochScreen;
