import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/common/model/energy_chunk.dart';
import 'package:kratos/energy_forms_and_changes/common/model/model_rect.dart';
import 'package:kratos/energy_forms_and_changes/common/model/thermal_container.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

/// PhET `Burner.ts` — heater/cooler stand.
class Burner {
  Burner({
    required this.id,
    required Offset position,
  })  : position = position,
        bounds = ModelRect(
          position.dx - sideLength / 2,
          position.dy,
          position.dx + sideLength / 2,
          position.dy + sideLength,
        ) {
    topSurface = HorizontalSurface(
      x: position.dx,
      y: position.dy + sideLength,
    );
  }

  static const double sideLength = 0.075; // m
  static const double maxEnergyGenerationRate = 5000; // J/s
  static const double maxEnergyGenerationRateIntoAir =
      maxEnergyGenerationRate * 0.3;
  static const double contactDistance = 0.001; // m

  final String id;
  final Offset position;
  final ModelRect bounds;
  late final HorizontalSurface topSurface;
  final List<EnergyChunk> energyChunks = <EnergyChunk>[];

  /// Range [-1, 1]. PhET `heatCoolLevelProperty`.
  double heatCoolLevel = 0;

  double get temperature {
    final t = EfacConstants.roomTemperature + heatCoolLevel * 100;
    return t < EfacConstants.waterFreezingPointTemperature
        ? EfacConstants.waterFreezingPointTemperature
        : t;
  }

  bool inContactWith(ModelRect objectBounds) {
    final onTopX = objectBounds.center.dx >= bounds.minX &&
        objectBounds.center.dx <= bounds.maxX;
    final nearTop =
        (objectBounds.minY - bounds.maxY).abs() < contactDistance;
    return onTopX && nearTop;
  }

  bool areAnyOnTop(Iterable<ModelRect> containers) {
    for (final b in containers) {
      if (inContactWith(b)) return true;
    }
    return false;
  }

  /// Energy to add to a contacted object this dt (J). PhET Burner.ts:172-188.
  double energyDeltaForObject(double dt,
      {required double objectEnergyAboveMin}) {
    var delta = maxEnergyGenerationRate * heatCoolLevel * dt;
    if (delta < 0 && delta.abs() > objectEnergyAboveMin) {
      delta = -objectEnergyAboveMin;
    }
    return delta;
  }

  /// Energy intended for air when nothing is on the burner.
  double energyDeltaForAir(double dt) =>
      maxEnergyGenerationRateIntoAir * heatCoolLevel * dt;

  void reset() {
    heatCoolLevel = 0;
    energyChunks.clear();
    topSurface.elementOnSurface = null;
  }
}
