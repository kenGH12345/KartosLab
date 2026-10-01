/// In-memory Simulation Registry (minimal).
///
/// Mixed migration: existing Home hard-coded entries remain;
/// new modules (e.g. Quantum Measurement) register here and Home may
/// resolve builders by [id] without depending on simulation internals.
library;

import 'simulation_descriptor.dart';

class SimulationRegistry {
  SimulationRegistry._();
  static final SimulationRegistry instance = SimulationRegistry._();

  final Map<String, SimulationDescriptor> _byId = {};

  void register(SimulationDescriptor descriptor) {
    assert(descriptor.id.isNotEmpty, 'SimulationDescriptor.id required');
    _byId[descriptor.id] = descriptor;
  }

  SimulationDescriptor? find(String id) => _byId[id];

  SimulationDescriptor require(String id) {
    final d = _byId[id];
    if (d == null) {
      throw StateError('Simulation "$id" is not registered');
    }
    return d;
  }

  Iterable<SimulationDescriptor> get all => _byId.values;

  bool get isEmpty => _byId.isEmpty;

  /// Test / hot-restart helper.
  void clear() => _byId.clear();
}
