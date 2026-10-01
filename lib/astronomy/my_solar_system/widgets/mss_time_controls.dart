/// [MSS] `TimePanel.ts` — 右上：TimeControl + Clock(years + Clear)。
///
/// 不用 L0 TimeControlBar（缺 Restart≠Reset、三档速度、Clear）。[有意差异 同 Kepler]
library;

import 'package:flutter/material.dart';

import '../controller/my_solar_system_controller.dart';
import '../model/time_speed.dart';
import '../my_solar_system_colors.dart';
import '../my_solar_system_constants.dart';
import '../my_solar_system_strings.dart';

class MssTimePanel extends StatelessWidget {
  const MssTimePanel({super.key, required this.controller});

  final MySolarSystemController controller;

  @override
  Widget build(BuildContext context) {
    final years = controller.timeYears.toStringAsFixed(2);
    return Material(
      color: MySolarSystemColors.panel,
      elevation: 2,
      borderRadius: BorderRadius.circular(MySolarSystemConstants.panelCornerRadius),
      child: Padding(
        padding: const EdgeInsets.all(MySolarSystemConstants.panelMargin),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _round(
                    icon: Icons.replay,
                    tooltip: MySolarSystemStrings.restart,
                    onPressed: controller.restart,
                    size: 40,
                  ),
                  const SizedBox(width: 8),
                  _round(
                    icon: controller.isPlaying ? Icons.pause : Icons.play_arrow,
                    tooltip: controller.isPlaying
                        ? MySolarSystemStrings.pause
                        : MySolarSystemStrings.play,
                    onPressed: controller.togglePlay,
                    size: 56,
                  ),
                  const SizedBox(width: 8),
                  _round(
                    icon: Icons.skip_next,
                    tooltip: MySolarSystemStrings.step,
                    onPressed: controller.isPlaying ? null : controller.stepForward,
                    size: 40,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _speed(TimeSpeed.fast, MySolarSystemStrings.fast),
                  _speed(TimeSpeed.normal, MySolarSystemStrings.normal),
                  _speed(TimeSpeed.slow, MySolarSystemStrings.slow),
                ],
              ),
              const SizedBox(height: MySolarSystemConstants.timePanelInnerSpacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$years ${MySolarSystemStrings.years}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed:
                        controller.timeYears > 0 ? controller.clearSimulation : null,
                    child: const Text(
                      MySolarSystemStrings.clear,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _round({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    double size = 44,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: MySolarSystemColors.playBlue,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, color: Colors.black87, size: size * 0.5),
          ),
        ),
      ),
    );
  }

  Widget _speed(TimeSpeed speed, String label) {
    final selected = controller.timeSpeed == speed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => controller.setTimeSpeed(speed),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
