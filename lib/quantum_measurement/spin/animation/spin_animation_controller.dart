/// Ticker for Spin particle simulation.
library;

import 'package:flutter/scheduler.dart';

import 'spin_particle_simulation.dart';
import '../model/spin_model.dart';

class SpinAnimationController {
  SpinAnimationController({
    required this.simulation,
    required this.onTick,
  });

  final SpinParticleSimulation simulation;
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
    final dt = _last == Duration.zero
        ? 0.0
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    if (dt <= 0) return;
    final active = simulation.model.sourceMode == SourceMode.continuous ||
        simulation.particles.isNotEmpty ||
        simulation.measurementDevices.any((d) => d.isAnimating);

    if (!active) return;
    simulation.step(dt);
    onTick();
  }

  void dispose() => stop();
}
