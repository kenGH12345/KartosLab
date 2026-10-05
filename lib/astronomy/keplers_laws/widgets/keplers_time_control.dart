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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _speed(TimeSpeed.fast, KeplersLawsStrings.fast),
                _speed(TimeSpeed.normal, KeplersLawsStrings.normal),
                _speed(TimeSpeed.slow, KeplersLawsStrings.slow),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _speed(TimeSpeed speed, String label) {
    final selected = controller.timeSpeed == speed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: GestureDetector(
        onTap: () => controller.setTimeSpeed(speed),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PhetRadioDot(selected: selected),
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

class _PhetRadioDot extends StatelessWidget {
  const _PhetRadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: _RadioDotPainter(selected: selected),
    );
  }
}

class _RadioDotPainter extends CustomPainter {
  _RadioDotPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      6.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    if (selected) {
      canvas.drawCircle(c, 3.6, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _RadioDotPainter oldDelegate) =>
      oldDelegate.selected != selected;
}
