import 'package:flutter/material.dart';

import '../layout/experiment_layout_composer.dart';
import 'experiment_controller.dart';

/// Experiment play area — assembled by [ExperimentLayoutComposer] from LAYOUT_SPEC.
class ExperimentScene extends StatelessWidget {
  const ExperimentScene({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    return ExperimentLayoutComposer(controller: controller);
  }
}
