/// Buoyancy Simulation Module — Descriptor + Registry registration.
library;

import 'package:kratos/buoyancy/screens/buoyancy_home.dart';
import 'package:kratos/common/simulation/simulation_descriptor.dart';
import 'package:kratos/common/simulation/simulation_registry.dart';

abstract final class BuoyancyModule {
  static const String id = BuoyancyHome.simulationId;

  static final SimulationDescriptor descriptor = SimulationDescriptor(
    id: id,
    title: BuoyancyHome.title,
    subtitle: BuoyancyHome.subtitle,
    category: '物理 / 密度与浮力',
    iconAsset: BuoyancyHome.homeIconAsset,
    sourceVersion: '1.5+',
    enabled: true,
    builder: (_) => const BuoyancyHome(),
  );

  /// Idempotent registration for app start / tests.
  static void register({SimulationRegistry? registry}) {
    (registry ?? SimulationRegistry.instance).register(descriptor);
  }
}
