/// Simulation Controller — ties a [SimulationClock] to a Flutter
/// [Ticker] / [AnimationController], providing a simple widget that drives
/// the clock on each frame.
///
/// Usage:
/// ```dart
/// SimulationController(
///   clock: myClock,
///   builder: (context, clock) => MySimulationView(clock: clock),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'simulation_clock.dart';

class SimulationController extends StatefulWidget {
  final SimulationClock clock;
  final Widget Function(BuildContext context, SimulationClock clock) builder;

  const SimulationController({
    super.key,
    required this.clock,
    required this.builder,
  });

  @override
  State<SimulationController> createState() => _SimulationControllerState();
}

class _SimulationControllerState extends State<SimulationController>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _animController.addListener(_onTick);
    widget.clock.addListener(_onClockChanged);
  }

  void _onTick() {
    final rawDt = _animController.lastElapsedDuration != null
        ? _animController.lastElapsedDuration!.inMilliseconds / 1000.0
        : 0.016;
    widget.clock.tick(rawDt);
  }

  void _onClockChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _animController.removeListener(_onTick);
    widget.clock.removeListener(_onClockChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.clock);
  }
}
