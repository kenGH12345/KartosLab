import 'package:kratos/energy_forms_and_changes/common/model/energy_chunk.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_container_category.dart';
import 'package:kratos/energy_forms_and_changes/common/model/heat_transfer_constants.dart';
import 'package:kratos/energy_forms_and_changes/common/model/model_rect.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';

/// PhET `Air.ts` — infinite thermal reservoir (`changeEnergy` is a no-op).
class Air {
  Air() {
    _energy = mass * specificHeat * EfacConstants.roomTemperature;
  }

  static const double sizeWidth = 0.7;
  static const double sizeHeight = 0.85;
  static const double depth = 0.1;
  static const double density = 10; // PhET Air uses low density for chunk math
  // PhET Air.ts — verify mass/SH if precise chunk counts needed later.
  static const double specificHeat = 1012; // Air.ts:41

  double _energy = 0;
  final List<EnergyChunk> energyChunks = <EnergyChunk>[];

  double get mass => sizeWidth * sizeHeight * depth * density;
  double get temperature => _energy / (mass * specificHeat);
  EnergyContainerCategory get category => EnergyContainerCategory.air;

  ModelRect get bounds => const ModelRect(
        -sizeWidth / 2,
        0,
        sizeWidth / 2,
        sizeHeight,
      );

  /// Air energy does not change. Air.ts:130-134.
  void changeEnergy(double delta) {
    // intentionally empty
  }

  /// Exchange with a thermal container; only container energy changes.
  void exchangeEnergyWithContainer({
    required double Function() getTemperature,
    required void Function(double) changeContainerEnergy,
    required EnergyContainerCategory containerCategory,
    required double contactLength,
    required double getEnergyBeyondMaxTemperature,
    required double dt,
  }) {
    if (contactLength <= 0) return;
    final factor = HeatTransferConstants.getHeatTransferFactor(
      category,
      containerCategory,
    );
    var remaining = dt;
    while (remaining > 1e-12) {
      final step = remaining > EfacConstants.maxHeatExchangeTimeStep
          ? EfacConstants.maxHeatExchangeTimeStep
          : remaining;
      var energyToExchange =
          (getTemperature() - temperature) * contactLength * factor * step;
      // PhET: if energyToExchange >= 0, also dump boiling overflow.
      if (energyToExchange >= 0) {
        final beyond = getEnergyBeyondMaxTemperature;
        if (beyond > energyToExchange) energyToExchange = beyond;
      }
      changeContainerEnergy(-energyToExchange);
      remaining -= step;
    }
  }

  void exchangeWithBlock(ThermalBlock block, double dt) {
    final contact = block.surfaceWidth; // top-face proxy when sitting in air
    exchangeEnergyWithContainer(
      getTemperature: () => block.temperature,
      changeContainerEnergy: block.changeEnergy,
      containerCategory: block.category,
      contactLength: contact,
      getEnergyBeyondMaxTemperature: block.energyBeyondMaxTemperature,
      dt: dt,
    );
  }

  void reset() {
    _energy = mass * specificHeat * EfacConstants.roomTemperature;
    energyChunks.clear();
  }

  void stepChunks(double dt) {
    // Rising chunks removed when they reach top — wander handled by IntroEnergyChunkSystem.
  }
}
