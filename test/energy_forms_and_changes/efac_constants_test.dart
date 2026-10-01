import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_container_category.dart';
import 'package:kratos/energy_forms_and_changes/common/model/heat_transfer_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

void main() {
  group('EfacConstants energy mapping', () {
    test('ENERGY_PER_CHUNK matches PhET linear map formula', () {
      final expected = EfacConstants.mapNumChunksToEnergy(2) -
          EfacConstants.mapNumChunksToEnergy(1);
      expect(EfacConstants.energyPerChunk, closeTo(expected, 1e-9));
      expect(EfacConstants.energyPerChunk, closeTo(5019.022369565222, 1e-6));
    });

    test('room brick maps to 2.4 chunks before rounding', () {
      expect(
        EfacConstants.mapEnergyToNumChunks(
          EfacConstants.brickEnergyAtRoomTemperature,
        ),
        closeTo(2.4, 1e-9),
      );
    });

    test('layout bounds are joist default 1024×618', () {
      expect(EfacConstants.layoutWidth, 1024);
      expect(EfacConstants.layoutHeight, 618);
    });
  });

  group('HeatTransferConstants', () {
    test('solid↔solid is 1000, solid↔air is 30', () {
      expect(
        HeatTransferConstants.getHeatTransferFactor(
          EnergyContainerCategory.iron,
          EnergyContainerCategory.brick,
        ),
        1000,
      );
      expect(
        HeatTransferConstants.getHeatTransferFactor(
          EnergyContainerCategory.water,
          EnergyContainerCategory.air,
        ),
        30,
      );
    });
  });

  group('cubicInOut', () {
    test('endpoints and midpoint', () {
      expect(cubicInOut(0), 0);
      expect(cubicInOut(1), 1);
      expect(cubicInOut(0.5), closeTo(0.5, 1e-9));
    });
  });
}
