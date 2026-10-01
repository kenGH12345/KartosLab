/// Quantum Measurement Simulation Module — Descriptor + Registry registration.
library;

import 'package:kratos/common/simulation/simulation_descriptor.dart';
import 'package:kratos/common/simulation/simulation_registry.dart';
import 'package:kratos/quantum_measurement/screens/quantum_measurement_home.dart';

abstract final class QuantumMeasurementModule {
  static const String id = QuantumMeasurementHome.simulationId;

  static final SimulationDescriptor descriptor = SimulationDescriptor(
    id: id,
    title: QuantumMeasurementHome.title,
    subtitle: QuantumMeasurementHome.subtitle,
    category: '物理 / 光学与波动',
    iconAsset: QuantumMeasurementHome.homeIconAsset,
    sourceVersion: '1.0.4',
    enabled: true,
    builder: (_) => const QuantumMeasurementHome(),
  );

  /// Idempotent registration for app start / tests.
  static void register({SimulationRegistry? registry}) {
    (registry ?? SimulationRegistry.instance).register(descriptor);
  }
}
