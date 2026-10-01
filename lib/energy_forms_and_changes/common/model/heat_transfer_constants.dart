import 'package:kratos/energy_forms_and_changes/common/model/energy_container_category.dart';

/// PhET `HeatTransferConstants.ts` — pairwise factors.
class HeatTransferConstants {
  HeatTransferConstants._();

  static const double solidSolid = 1000;
  static const double solidAir = 30;

  static double getHeatTransferFactor(
    EnergyContainerCategory a,
    EnergyContainerCategory b,
  ) {
    if (a == EnergyContainerCategory.air || b == EnergyContainerCategory.air) {
      if (a == EnergyContainerCategory.air && b == EnergyContainerCategory.air) {
        throw ArgumentError('No AIR↔AIR heat transfer factor in PhET map');
      }
      return solidAir;
    }
    return solidSolid;
  }
}
