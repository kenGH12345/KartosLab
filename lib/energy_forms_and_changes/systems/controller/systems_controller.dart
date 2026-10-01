import 'package:flutter/scheduler.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

class SystemsController {
  SystemsController({SystemsModel? model})
      : model = model ?? SystemsModel(),
        clock = SimulationClock(fps: EfacConstants.framesPerSecond);

  final SystemsModel model;
  final SimulationClock clock;

  void attach(TickerProvider vsync) {
    clock.attach(vsync);
    clock.onTick = (dt, _) => model.step(dt);
    // Always run ticker so carousel animates while paused (PhET behavior).
    clock.play();
  }

  void setPlaying(bool playing) {
    model.setPlaying(playing);
  }

  void manualStep() => model.manualStep();

  void reset() {
    model.reset();
    clock.reset();
    clock.play();
  }

  void dispose() {
    clock.dispose();
    model.dispose();
  }
}
