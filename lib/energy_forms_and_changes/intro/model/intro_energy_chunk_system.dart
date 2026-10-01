import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/common/model/energy_chunk.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_chunk_wander.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_type.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

/// Lightweight chunk pool + wander list for Intro air/burners/containers.
class IntroEnergyChunkSystem {
  final List<EnergyChunk> chunks = <EnergyChunk>[];
  final List<EnergyChunkWanderController> wanderers =
      <EnergyChunkWanderController>[];
  int _nextId = 1;

  EnergyChunk createThermal(Offset position) {
    final c = EnergyChunk(
      id: _nextId++,
      energyType: EnergyType.thermal,
      position: position,
    );
    chunks.add(c);
    return c;
  }

  EnergyChunkWanderController wanderTo(
    EnergyChunk chunk,
    Offset destination, {
    double? xMin,
    double? xMax,
    double wanderAngleVariation = 0.6283185307179586, // pi*0.2
  }) {
    final w = EnergyChunkWanderController(
      chunk: chunk,
      destination: destination,
      horizontalConstraintMin: xMin,
      horizontalConstraintMax: xMax,
      wanderAngleVariation: wanderAngleVariation,
    );
    wanderers.add(w);
    return w;
  }

  void step(double dt) {
    final done = <EnergyChunkWanderController>[];
    for (final w in wanderers) {
      w.updatePosition(dt);
      if (w.isDestinationReached) done.add(w);
    }
    for (final w in done) {
      wanderers.remove(w);
    }
  }

  void clear() {
    chunks.clear();
    wanderers.clear();
  }

  /// Seed approximate room-temp chunks inside a container bounds center.
  void seedForEnergy(Offset center, double energy, List<EnergyChunk> into) {
    into.clear();
    final n = EfacConstants.energyToNumChunksMapper(energy);
    for (var i = 0; i < n; i++) {
      final c = createThermal(
        center + Offset((i % 3 - 1) * 0.01, (i ~/ 3) * 0.01 + 0.02),
      );
      into.add(c);
    }
  }
}
