import 'package:flutter/material.dart';

import '../layout/high_intensity_layout_composer.dart';
import 'high_intensity_controller.dart';

/// Design-coordinate HI play area (768×504) — Composer-based.
class HighIntensityScene extends StatelessWidget {
  const HighIntensityScene({super.key, required this.controller});

  final HighIntensityController controller;

  @override
  Widget build(BuildContext context) {
    return HighIntensityLayoutComposer(controller: controller);
  }
}
