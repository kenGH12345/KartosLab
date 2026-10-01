/// Simulation Control Bar — a row of play/pause/step/reset buttons.
///
/// Wired to a [SimulationClock].
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';
import '../controls/phet_icon_button.dart';
import 'simulation_clock.dart';

class SimulationControlBar extends StatelessWidget {
  final SimulationClock clock;
  final VoidCallback? onReset;
  final bool showStep;
  final bool showSpeed;

  const SimulationControlBar({
    super.key,
    required this.clock,
    this.onReset,
    this.showStep = false,
    this.showSpeed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.panelBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.panelBorder, width: theme.borderWidth),
        boxShadow: [
          BoxShadow(color: theme.panelShadow, blurRadius: 6, offset: const Offset(2, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause
          PhetIconButton(
            icon: clock.isPaused ? Icons.play_arrow : Icons.pause,
            tooltip: clock.isPaused ? 'Play' : 'Pause',
            onPressed: () => clock.toggle(),
            size: 28,
          ),
          if (showStep) ...[
            const SizedBox(width: 8),
            PhetIconButton(
              icon: Icons.skip_next,
              tooltip: 'Step',
              onPressed: clock.isPaused ? () => clock.step() : null,
              size: 22,
            ),
          ],
          if (showSpeed) ...[
            const SizedBox(width: 12),
            _buildSpeedButton(context, 0.25, '¼×'),
            _buildSpeedButton(context, 1.0, '1×'),
            _buildSpeedButton(context, 2.0, '2×'),
          ],
          if (onReset != null) ...[
            const SizedBox(width: 12),
            PhetIconButton(
              icon: Icons.refresh,
              tooltip: 'Reset',
              onPressed: onReset,
              size: 24,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedButton(BuildContext context, double speed, String label) {
    final theme = PhetTheme.of(context);
    final selected = clock.speed == speed;
    return GestureDetector(
      onTap: () => clock.speed = speed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? theme.buttonPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: selected ? theme.buttonOnPrimary : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}
