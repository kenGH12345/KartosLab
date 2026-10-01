import 'package:flutter/material.dart';

import '../layout/single_particles_layout_composer.dart';
import 'single_particles_controller.dart';

/// Design-coordinate Single Particles play area (768×504) — Composer-based.
class SingleParticlesScene extends StatelessWidget {
  const SingleParticlesScene({super.key, required this.controller});

  final SingleParticlesController controller;

  @override
  Widget build(BuildContext context) {
    return SingleParticlesLayoutComposer(controller: controller);
  }
}
