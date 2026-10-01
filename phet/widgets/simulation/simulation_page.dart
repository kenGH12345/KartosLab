/// PhET Simulation Page — a base widget for all simulation pages.
///
/// Provides:
/// - Black simulation background
/// - Optional back button overlay
/// - A [SimulationClock] via [SimulationController]
/// - Bottom simulation control bar (play/pause/reset)
///
/// Subclasses implement [buildSimulation] for the canvas/overlay content
/// and [onReset] for state reset.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';
import '../navigation/phet_back_button.dart';
import 'simulation_clock.dart';
import 'simulation_controller.dart';
import 'simulation_control_bar.dart';

abstract class SimulationPage extends StatefulWidget {
  final String title;

  const SimulationPage({super.key, required this.title});

  /// Subclasses must provide a key to the state.
  const SimulationPage.noKey({super.key}) : title = '';

  @override
  State<SimulationPage> createState() => SimulationPageState();
}

class SimulationPageState extends State<SimulationPage> {
  final SimulationClock clock = SimulationClock();

  /// Subclasses build the simulation canvas + overlays here.
  /// Default implementation returns an empty container; override in subclass.
  Widget buildSimulation(BuildContext context, SimulationClock clock) {
    return const SizedBox.shrink();
  }

  /// Subclasses reset their state here.
  void onReset() {}

  @override
  Widget build(BuildContext context) {
    return PhetTheme(
      data: PhetThemeData.defaultTheme,
      child: Scaffold(
        backgroundColor: PhetThemeData.defaultTheme.canvasBackground,
        body: Stack(
          children: [
            // Simulation content
            Positioned.fill(
              child: SimulationController(
                clock: clock,
                builder: (ctx, c) => buildSimulation(ctx, c),
              ),
            ),
            // Back button (top-left)
            Positioned(
              top: 12,
              left: 12,
              child: PhetBackButton(),
            ),
            // Title (top-center)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Control bar (bottom-center)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: SimulationControlBar(
                  clock: clock,
                  onReset: () {
                    clock.reset();
                    onReset();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
