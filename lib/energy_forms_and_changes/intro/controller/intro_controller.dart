import 'package:flutter/scheduler.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_model.dart';

/// Bridges [SimulationClock] → [EfacIntroModel].
class IntroController {
  IntroController({EfacIntroModel? model})
      : model = model ?? EfacIntroModel(),
        clock = SimulationClock(fps: EfacConstants.framesPerSecond);

  final EfacIntroModel model;
  final SimulationClock clock;

  void attach(TickerProvider vsync) {
    clock.attach(vsync);
    clock.onTick = (dt, _) {
      // Fast-forward via model.timeSpeed, not clock.timeScale, to match PhET.
      model.step(dt);
    };
    if (model.isPlaying) {
      clock.play();
    }
  }

  void setPlaying(bool playing) {
    model.setPlaying(playing);
    if (playing) {
      clock.play();
    } else {
      clock.pause();
    }
  }

  void manualStep() {
    if (clock.isRunning) return;
    model.manualStep();
  }

  void reset() {
    model.reset();
    clock.reset();
    if (model.isPlaying) {
      clock.play();
    }
  }

  void dispose() {
    clock.dispose();
    model.dispose();
  }
}
