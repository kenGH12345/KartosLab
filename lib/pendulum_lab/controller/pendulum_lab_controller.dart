import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/pendulum_lab/model/pendulum.dart';
import 'package:kratos/pendulum_lab/model/pendulum_lab_model.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';

/// View-only period-trace fade. Source: `PeriodTraceNode.js`.
class PeriodTraceViewState {
  bool isCompleted = false;
  double colorAlpha = 1;
  double? fadeOutSpeed;
  int lastPoints = 0;

  void resetPath() {
    isCompleted = false;
    colorAlpha = 1;
    fadeOutSpeed = null;
  }

  void onPointsChanged(int numberNew, int numberPrev) {
    if (numberNew < numberPrev) {
      resetPath();
    }
    lastPoints = numberNew;
  }

  void markCompleted(Pendulum pendulum) {
    if (isCompleted) return;
    isCompleted = true;
    fadeOutSpeed = 1 / (3 * pendulum.getApproximatePeriod() / 2);
  }

  void step(double dt, Pendulum pendulum) {
    final speed = fadeOutSpeed;
    if (speed == null) return;
    colorAlpha = (colorAlpha - speed * dt).clamp(0.0, 1.0);
    if (colorAlpha == 0) {
      pendulum.periodTrace.onFaded();
      fadeOutSpeed = null;
    }
  }
}

/// Clock + model bridge. Speed lives on the model, not [SimulationClock.timeScale].
class PendulumLabController extends ChangeNotifier {
  PendulumLabController(this.model)
      : clock = SimulationClock(fps: PlConstants.framesPerSecond) {
    traces = [
      PeriodTraceViewState(),
      PeriodTraceViewState(),
    ];
    model.addListener(_onModel);
  }

  final PendulumLabModel model;
  final SimulationClock clock;
  late final List<PeriodTraceViewState> traces;

  void _onModel() => notifyListeners();

  void attach(TickerProvider vsync) {
    clock.attach(vsync);
    clock.onTick = (dt, _) {
      final prevPoints = [
        model.pendula[0].periodTrace.numberOfPoints,
        model.pendula[1].periodTrace.numberOfPoints,
      ];
      model.step(dt);
      var fading = false;
      for (var i = 0; i < 2; i++) {
        final p = model.pendula[i];
        traces[i].onPointsChanged(
          p.periodTrace.numberOfPoints,
          prevPoints[i],
        );
        if (p.periodTrace.numberOfPoints > 3) {
          traces[i].markCompleted(p);
        }
        if (model.isPlaying) {
          traces[i].step(dt, p);
        }
        if (traces[i].fadeOutSpeed != null) {
          fading = true;
        }
      }
      // The trace fade-out is view-only state; the model may legitimately
      // skip its notify when nothing moved, so drive the fade repaint here.
      if (fading) {
        notifyListeners();
      }
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

  void stepManual() {
    if (clock.isRunning) return;
    model.stepManual();
  }

  void reset() {
    for (final t in traces) {
      t.resetPath();
    }
    model.reset();
    clock.reset();
    if (model.isPlaying) {
      clock.play();
    } else {
      clock.pause();
    }
  }

  @override
  void dispose() {
    model.removeListener(_onModel);
    clock.dispose();
    model.dispose();
    super.dispose();
  }
}
