/// Elapsed-time driver for BlochSphereModel.step — no physics inside.
library;

import 'package:flutter/scheduler.dart';

import '../model/bloch_sphere_model.dart';

typedef BlochTickCallback = void Function();

class BlochAnimationController {
  BlochAnimationController({
    required this.model,
    required this.onTick,
  });

  final BlochSphereModel model;
  final BlochTickCallback onTick;

  Ticker? _ticker;
  Duration _last = Duration.zero;
  bool _running = false;

  bool get isRunning => _running;

  void start(TickerProvider vsync) {
    stop();
    _last = Duration.zero;
    _ticker = vsync.createTicker(_onTick)..start();
    _running = true;
  }

  void stop() {
    _ticker?.dispose();
    _ticker = null;
    _running = false;
    _last = Duration.zero;
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.0
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    if (dt <= 0) return;

    final needsStep =
        model.measurementState == BlochMeasurementState.timingObservation ||
            model.singleMeasurement.rotatingSpeed != 0;
    if (!needsStep) return;

    model.step(dt);
    onTick();
  }

  /// Deterministic step for tests / golden checkpoints (bypasses ticker).
  void stepFixed(double dtSeconds) {
    model.step(dtSeconds);
    onTick();
  }

  void dispose() => stop();
}
