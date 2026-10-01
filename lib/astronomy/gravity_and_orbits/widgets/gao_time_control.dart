/// Fast/Normal/Slow + play/pause + step + rewind (light-blue PhET circles).
library;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../gao_colors.dart';
import '../gao_constants.dart';
import '../gao_strings.dart';

class GaoTimeControl extends StatelessWidget {
  const GaoTimeControl({super.key, required this.controller});

  final GaoController controller;

  @override
  Widget build(BuildContext context) {
    final playing = controller.model.isPlaying;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _speed(GaoTimeSpeed.fast, GaoStrings.fast),
            _speed(GaoTimeSpeed.normal, GaoStrings.normal),
            _speed(GaoTimeSpeed.slow, GaoStrings.slow),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _round(
              icon: Icons.fast_rewind,
              tooltip: GaoStrings.rewind,
              onPressed: controller.rewind,
              size: 40,
            ),
            const SizedBox(width: 8),
            _round(
              icon: playing ? Icons.pause : Icons.play_arrow,
              tooltip: playing ? GaoStrings.pause : GaoStrings.play,
              onPressed: controller.togglePlay,
              size: 52,
            ),
            const SizedBox(width: 8),
            _round(
              icon: Icons.skip_next,
              tooltip: GaoStrings.step,
              onPressed: playing ? null : controller.stepForward,
              size: 40,
            ),
          ],
        ),
      ],
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
        color: GaoColors.playBlue,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: onPressed == null
                  ? Colors.black38
                  : Colors.black87,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _speed(GaoTimeSpeed speed, String label) {
    final selected = controller.model.timeSpeed == speed;
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
              color: GaoColors.foreground,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: GaoColors.foreground, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
