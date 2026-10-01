import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';

class TimeControl extends StatelessWidget {
  const TimeControl({
    super.key,
    required this.playing,
    required this.slow,
    required this.onPlayPause,
    required this.onStep,
    required this.onSlow,
    required this.onReset,
    this.onReturnSkater,
  });

  final bool playing;
  final bool slow;
  final VoidCallback onPlayPause;
  final VoidCallback onStep;
  final ValueChanged<bool> onSlow;
  final VoidCallback onReset;
  final VoidCallback? onReturnSkater;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundBtn(
          onTap: onPlayPause,
          child: Icon(
            playing ? Icons.pause : Icons.play_arrow,
            size: 22,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        const SizedBox(width: 8),
        _RoundBtn(
          onTap: playing ? null : onStep,
          child: Icon(
            Icons.skip_next,
            size: 22,
            color: playing ? Colors.black26 : const Color(0xFF1E3A5F),
          ),
        ),
        const SizedBox(width: 14),
        _speedChip(EspStrings.normal, !slow, () => onSlow(false)),
        const SizedBox(width: 8),
        _speedChip(EspStrings.slow, slow, () => onSlow(true)),
        const Spacer(),
        if (onReturnSkater != null)
          TextButton(
            onPressed: onReturnSkater,
            child: const Text(EspStrings.returnSkater),
          ),
        IconButton(
          tooltip: EspStrings.reset,
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _speedChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 16,
            color: EspColors.accent,
          ),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.onTap, required this.child});
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null
          ? const Color(0xFFD0D8E0)
          : const Color(0xFFB3D4FC),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    );
  }
}
