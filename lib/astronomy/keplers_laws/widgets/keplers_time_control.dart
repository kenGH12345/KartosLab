import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../keplers_laws_strings.dart';
import '../model/time_speed.dart';

/// Play / step / restart + Fast/Normal/Slow.
///
/// [已确认] SolarSystemCommonTimeControlNode — Restart ≠ Reset All
class KeplersTimeControl extends StatelessWidget {
  const KeplersTimeControl({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    Widget round({
      required IconData icon,
      required VoidCallback? onPressed,
      double size = 44,
    }) {
      return SizedBox(
        width: size,
        height: size,
        child: Material(
          color: KeplersLawsColors.playBlue,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Icon(icon, color: Colors.black87, size: size * 0.5),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            round(
              icon: Icons.fast_rewind,
              onPressed: controller.hasPlayed ? controller.restart : null,
              size: 40,
            ),
            const SizedBox(width: 8),
            round(
              icon: controller.isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: controller.engine.allowedOrbit
                  ? controller.togglePlay
                  : null,
              size: 56,
            ),
            const SizedBox(width: 8),
            round(
              icon: Icons.skip_next,
              onPressed: controller.engine.allowedOrbit && !controller.isPlaying
                  ? controller.stepForwardButton
                  : null,
              size: 40,
            ),
            const SizedBox(width: 20),
            _speed(TimeSpeed.fast, KeplersLawsStrings.fast),
            _speed(TimeSpeed.normal, KeplersLawsStrings.normal),
            _speed(TimeSpeed.slow, KeplersLawsStrings.slow),
          ],
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
