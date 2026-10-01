/// Ticker-driven spatial simulation stepper — dispose cancels ticker.
library;

import 'package:flutter/scheduler.dart';

import '../model/photon_simulation.dart';

class PhotonAnimationController {
  PhotonAnimationController({
    required this.simulation,
    required this.onTick,
  });

  PhotonsSpatialSimulation simulation;
  final VoidCallback onTick;

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
    final dtMs = _last == Duration.zero
        ? 0.0
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final dt = dtMs.clamp(0.0, 0.05);
    if (dt > 0) {
      simulation.step(dt);
      onTick();
    }
  }

  void dispose() => stop();
}
