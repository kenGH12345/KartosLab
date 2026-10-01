import 'dart:math' as math;
import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/common/model/energy_chunk.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_container_category.dart';
import 'package:kratos/energy_forms_and_changes/common/model/heat_transfer_constants.dart';
import 'package:kratos/energy_forms_and_changes/common/model/model_rect.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

/// Shared thermal API used by Intro stepModel (blocks + beakers).
abstract class ThermalContainer {
  String get id;
  Offset get position;
  set position(Offset value);
  bool get userControlled;
  set userControlled(bool value);
  double get verticalVelocity;
  set verticalVelocity(double value);
  HorizontalSurface? get supportingSurface;
  set supportingSurface(HorizontalSurface? value);
  HorizontalSurface? get topSurface;
  ModelRect get bounds;
  ModelRect get thermalContactArea;
  EnergyContainerCategory get category;
  double get temperature;
  double get energy;
  double get energyAboveMinimum;
  double get energyBeyondMaxTemperature;
  List<EnergyChunk> get energyChunks;
  int get energyChunkBalance; // chunks − expected from energy

  void changeEnergy(double delta);
  double exchangeEnergyWith(ThermalContainer other, double dt);
  void step(double dt) {}
  void reset({required Offset home});
}

class HorizontalSurface {
  HorizontalSurface({
    required this.x,
    required this.y,
    this.elementOnSurface,
  });

  double x;
  double y;
  ThermalContainer? elementOnSurface;
}

/// Pairwise continuous heat exchange — PhET RTMME.exchangeEnergyWith.
double exchangeThermalEnergy(
  ThermalContainer a,
  ThermalContainer b,
  double dt, {
  required double contactLength,
}) {
  if (contactLength <= 0) return 0;
  final dT = b.temperature - a.temperature;
  if (dT.abs() <= EfacConstants.temperaturesEqualThreshold) return 0;

  final factor =
      HeatTransferConstants.getHeatTransferFactor(a.category, b.category);
  var remaining = dt;
  var totalFromAtoB = 0.0;
  while (remaining > 1e-12) {
    final step = remaining > EfacConstants.maxHeatExchangeTimeStep
        ? EfacConstants.maxHeatExchangeTimeStep
        : remaining;
    // energy gained by A from B = (T_b - T_a) * contact * factor * dt
    // so energy transferred FROM A TO B = -gainedByA
    final gainedByA = (b.temperature - a.temperature) * contactLength * factor * step;
    b.changeEnergy(-gainedByA);
    a.changeEnergy(gainedByA);
    totalFromAtoB += -gainedByA;
    remaining -= step;
  }
  return totalFromAtoB;
}

double aabbContactLength(ModelRect a, ModelRect b) {
  if (!a.intersects(b)) return 0;
  final overlapX =
      math.min(a.maxX, b.maxX) - math.max(a.minX, b.minX);
  final overlapY =
      math.min(a.maxY, b.maxY) - math.max(a.minY, b.minY);
  if (overlapX <= 0 || overlapY <= 0) return 0;
  return overlapX > overlapY ? overlapX : overlapY;
}
