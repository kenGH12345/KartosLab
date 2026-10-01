import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/controller/intro_controller.dart';
import 'package:kratos/energy_forms_and_changes/systems/controller/systems_controller.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

/// Fixed, reproducible screenshot / QA fixtures.
///
/// Each fixture documents Model state, elapsed sim time, controls, and
/// animation so Original ↔ Flutter comparisons share the same timeline.
///
/// Do **not** tune fixtures to reduce meanΔ against mismatched Originals.
class EfacRuntimeFixtures {
  EfacRuntimeFixtures._();

  /// Intro #1 — Reset / initial (pure PhET reset, playing = true like Original).
  static IntroController introInitial() {
    final c = IntroController();
    c.model.reset();
    // PhET default isPlaying=true → Pause button shown on Original reset.
    c.model.setPlaying(true);
    return c;
  }

  /// Intro #2 — heater active at fixed elapsed time.
  ///
  /// State:
  /// - linkedHeaters = true
  /// - energyChunksVisible = false
  /// - both burners heatCoolLevel = 1
  /// - water on left burner, oil on right
  /// - thermometers[0/1] attached to water/oil (ElementFollower offsets)
  /// - elapsed = [heaterActiveElapsedSeconds] at normal speed stepping
  ///
  /// Note: may not match legacy `alt1` Original frame — meanΔ is auxiliary.
  static const double heaterActiveElapsedSeconds = 8.0;

  static IntroController introHeaterActive() {
    final c = IntroController();
    final m = c.model;
    m.reset();
    m.setPlaying(false);
    m.setLinkedHeaters(true);
    m.setEnergyChunksVisible(false);
    m.setHeatCoolLevel(m.leftBurner, 1.0);
    assert(m.rightBurner.heatCoolLevel == 1.0);

    final leftTop = m.leftBurner.topSurface.y;
    final rightTop = m.rightBurner.topSurface.y;
    m.moveBeaker(m.beakers.first, Offset(m.leftBurner.position.dx, leftTop));
    m.endBeakerDrag(m.beakers.first);
    m.moveBeaker(m.beakers.last, Offset(m.rightBurner.position.dx, rightTop));
    m.endBeakerDrag(m.beakers.last);

    final water = m.beakers.first;
    final oil = m.beakers.last;
    m.moveThermometer(
      m.thermometers[0],
      Offset(
        water.position.dx + water.width * 0.45,
        water.position.dy + water.height * water.fluidProportion * 0.5,
      ),
    );
    m.thermometers[0].startFollowingBeaker(water);
    m.moveThermometer(
      m.thermometers[1],
      Offset(
        oil.position.dx + oil.width * 0.45,
        oil.position.dy + oil.height * oil.fluidProportion * 0.5,
      ),
    );
    m.thermometers[1].startFollowingBeaker(oil);

    final dt = 1 / EfacConstants.framesPerSecond;
    final steps = (heaterActiveElapsedSeconds / dt).round();
    // step() only advances thermal when isPlaying; use manualStep for fixed elapsed.
    for (var i = 0; i < steps; i++) {
      m.manualStep();
    }
    return c;
  }

  /// Intro #3 — thermometer attached (no heater), fixed tip in water fluid.
  static IntroController introThermometerAttached() {
    final c = IntroController();
    final m = c.model;
    m.reset();
    m.setPlaying(false);
    final water = m.beakers.first;
    m.moveThermometer(
      m.thermometers[0],
      Offset(
        water.position.dx + water.width * 0.45,
        water.position.dy + water.height * water.fluidProportion * 0.5,
      ),
    );
    m.endThermometerDrag(m.thermometers[0]);
    return c;
  }

  /// Intro #4 — linked heaters only (level 0, checkbox on).
  static IntroController introLinkedHeaters() {
    final c = IntroController();
    c.model.reset();
    c.model.setPlaying(false);
    c.model.setLinkedHeaters(true);
    return c;
  }

  /// Intro #5 — after heater_active, Reset All.
  static IntroController introAfterReset() {
    final c = introHeaterActive();
    c.reset();
    c.model.setPlaying(false);
    return c;
  }

  /// Systems #1 — bike → gen → beaker reset (Flutter default).
  /// Original runtime for this state is [BLOCKED] if missing in repo.
  static SystemsController systemsBikeReset() {
    final c = SystemsController();
    c.model.reset();
    c.model.setPlaying(false);
    assert(c.model.sources.selected == EnergySourceId.biker);
    assert(c.model.converters.selected == EnergyConverterId.generator);
    assert(c.model.users.selected == EnergyUserId.beakerHeater);
    return c;
  }

  /// Systems #2 — bike active at fixed elapsed time.
  static const double systemsBikeActiveElapsedSeconds = 1.5;

  static SystemsController systemsBikeActive() {
    final c = SystemsController();
    final m = c.model;
    m.reset();
    m.setPlaying(false);
    m.selectUserIndex(1); // bulb path in prior fixture; keep documented
    // Prior design-space used user index 1 + EC on + crank speed.
    m.setEnergyChunksVisible(true);
    m.setBikerSpeed(2.5 * 3.14159);
    final dt = 1 / EfacConstants.framesPerSecond;
    final steps = (systemsBikeActiveElapsedSeconds / dt).round();
    for (var i = 0; i < steps; i++) {
      m.manualStep();
    }
    return c;
  }

  /// Systems #3 — selector change (faucet source) then settle 0 elapsed.
  static SystemsController systemsSelectorFaucet() {
    final c = SystemsController();
    c.model.reset();
    c.model.setPlaying(false);
    c.model.selectSourceIndex(1); // faucet
    return c;
  }

  /// Systems #4 — reset after bike active.
  static SystemsController systemsAfterReset() {
    final c = systemsBikeActive();
    c.reset();
    c.model.setPlaying(false);
    return c;
  }
}
