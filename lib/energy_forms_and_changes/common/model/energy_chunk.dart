import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/common/model/energy_type.dart';

/// PhET `EnergyChunk.ts` — single energy particle (model space meters).
class EnergyChunk {
  EnergyChunk({
    required this.id,
    required this.energyType,
    required this.position,
    this.zPosition = 0,
    this.velocity = Offset.zero,
  });

  final int id;
  EnergyType energyType;
  Offset position;
  double zPosition;
  Offset velocity;

  bool get hasReachedDestination => false; // set by wander/path controllers

  EnergyChunk copy() => EnergyChunk(
        id: id,
        energyType: energyType,
        position: position,
        zPosition: zPosition,
        velocity: velocity,
      );
}
