import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_strings.dart';
import '../model/collision_lab_model.dart';

class TimeControl extends StatelessWidget {
  const TimeControl({
    super.key,
    required this.playing,
    required this.speed,
    required this.canStepBackward,
    required this.onPlayPause,
    required this.onStepForward,
    required this.onStepBackward,
    required this.onSpeed,
    required this.onRestart,
    required this.onReset,
  });

  final bool playing;
  final TimeSpeed speed;
  final bool canStepBackward;
  final VoidCallback onPlayPause;
  final VoidCallback onStepForward;
  final VoidCallback onStepBackward;
  final ValueChanged<TimeSpeed> onSpeed;
  final VoidCallback onRestart;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundBtn(
          onTap: canStepBackward ? onStepBackward : null,
          child: Icon(
            Icons.skip_previous,
            size: 22,
            color: canStepBackward ? const Color(0xFF1E3A5F) : Colors.black26,
          ),
        ),
        const SizedBox(width: 8),
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
          onTap: playing ? null : onStepForward,
          child: Icon(
            Icons.skip_next,
            size: 22,
            color: playing ? Colors.black26 : const Color(0xFF1E3A5F),
          ),
        ),
        const SizedBox(width: 14),
        _speedChip(CollisionLabStrings.normal, speed == TimeSpeed.normal,
            () => onSpeed(TimeSpeed.normal)),
        const SizedBox(width: 8),
        _speedChip(CollisionLabStrings.slow, speed == TimeSpeed.slow,
            () => onSpeed(TimeSpeed.slow)),
        const Spacer(),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: CollisionLabColors.restartButton,
            foregroundColor: Colors.black87,
          ),
          onPressed: onRestart,
          child: const Text(CollisionLabStrings.restart),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: '全部重置',
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
