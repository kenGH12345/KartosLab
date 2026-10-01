import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';
import 'package:kratos/energy_skate_park/widgets/track_scene_icon.dart';

/// Square track-preset buttons (SceneSelectionRadioButtonGroup.ts).
class TrackSceneSelector extends StatelessWidget {
  const TrackSceneSelector({
    super.key,
    required this.scenes,
    required this.selected,
    required this.onSelected,
  });

  final List<TrackScene> scenes;
  final TrackScene selected;
  final ValueChanged<TrackScene> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in scenes)
          _TrackIconButton(
            scene: s,
            selected: selected == s,
            onTap: () => onSelected(s),
          ),
      ],
    );
  }
}

class _TrackIconButton extends StatelessWidget {
  const _TrackIconButton({
    required this.scene,
    required this.selected,
    required this.onTap,
  });

  final TrackScene scene;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 52,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? const Color(0xFF2196F3) : const Color(0xFFBBBBBB),
              width: selected ? 2.5 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: Center(child: TrackSceneIcon(scene: scene, size: 40)),
        ),
      ),
    );
  }
}
