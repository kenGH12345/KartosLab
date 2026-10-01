import 'package:flutter/material.dart';

import '../model/time_speed.dart';
import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';
import '../normal_modes_strings.dart';

class NmTimeControl extends StatelessWidget {
  const NmTimeControl({
    super.key,
    required this.playing,
    required this.speed,
    required this.onPlayPause,
    required this.onStep,
    required this.onSpeed,
  });

  final bool playing;
  final NmTimeSpeed speed;
  final VoidCallback onPlayPause;
  final VoidCallback onStep;
  final ValueChanged<NmTimeSpeed> onSpeed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoundIconButton(
              onTap: onPlayPause,
              child: Icon(
                playing ? Icons.pause : Icons.play_arrow,
                size: 22,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(width: 10),
            _RoundIconButton(
              onTap: playing ? null : onStep,
              child: Icon(
                Icons.skip_next,
                size: 22,
                color: playing
                    ? NormalModesColors.blueButtonDisabled
                    : const Color(0xFF1E3A5F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SpeedChip(
              label: NormalModesStrings.normal,
              selected: speed == NmTimeSpeed.normal,
              onTap: () => onSpeed(NmTimeSpeed.normal),
            ),
            const SizedBox(width: 8),
            _SpeedChip(
              label: NormalModesStrings.slow,
              selected: speed == NmTimeSpeed.slow,
              onTap: () => onSpeed(NmTimeSpeed.slow),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.onTap, required this.child});
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null
          ? NormalModesColors.blueButtonDisabled
          : NormalModesColors.blueButtonUp,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  const _SpeedChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 16,
            color: const Color(0xFF334155),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: NormalModesConstants.generalFontSize),
          ),
        ],
      ),
    );
  }
}
