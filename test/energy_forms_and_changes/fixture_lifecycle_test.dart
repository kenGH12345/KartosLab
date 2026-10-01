import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

import 'efac_runtime_fixtures.dart';

void main() {
  test('Intro fixtures: reset clears heater_active state', () {
    final heated = EfacRuntimeFixtures.introHeaterActive();
    expect(heated.model.linkedHeaters, isTrue);
    expect(heated.model.leftBurner.heatCoolLevel, closeTo(1.0, 1e-9));

    final reset = EfacRuntimeFixtures.introAfterReset();
    expect(reset.model.linkedHeaters, isFalse);
    expect(reset.model.leftBurner.heatCoolLevel, 0);
    expect(reset.model.thermometers.every((t) => !t.active), isTrue);
    expect(reset.model.timeSpeed.toString(), contains('normal'));
  });

  test('Intro heater_active uses fixed elapsed time', () {
    final c = EfacRuntimeFixtures.introHeaterActive();
    expect(
      EfacRuntimeFixtures.heaterActiveElapsedSeconds,
      8.0,
    );
    // Temperature must have moved from room after fixed heat.
    expect(
      c.model.beakers.first.temperature,
      greaterThan(EfacConstants.roomTemperature),
    );
  });

  test('Systems fixtures: bike reset / selector / after-reset', () {
    final reset = EfacRuntimeFixtures.systemsBikeReset();
    expect(reset.model.sources.selected, EnergySourceId.biker);
    expect(reset.model.users.selected, EnergyUserId.beakerHeater);

    final faucet = EfacRuntimeFixtures.systemsSelectorFaucet();
    expect(faucet.model.sources.selected, EnergySourceId.faucet);

    final after = EfacRuntimeFixtures.systemsAfterReset();
    expect(after.model.sources.selected, EnergySourceId.biker);
    expect(after.model.bikerTargetCrankAngularVelocity, 0);
  });

  test('FF×4 multiplier unchanged', () {
    expect(EfacConstants.fastForwardMultiplier, 4);
  });
}
