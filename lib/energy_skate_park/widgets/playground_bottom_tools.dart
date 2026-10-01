import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kratos/energy_skate_park/assets/esp_assets.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/widgets/track_scene_icon.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';

/// Playground bottom-center track tools (eraser + add track segment).
class PlaygroundBottomTools extends StatelessWidget {
  const PlaygroundBottomTools({
    super.key,
    required this.onAddTrack,
    required this.onClearTracks,
  });

  final VoidCallback onAddTrack;
  final VoidCallback onClearTracks;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      color: const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: EspStrings.clearTracks,
              onPressed: onClearTracks,
              icon: SvgPicture.asset(
                EspAssets.eraserSvg,
                width: 22,
                height: 22,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: EspStrings.addTrack,
              onPressed: onAddTrack,
              icon: const SizedBox(
                width: 44,
                height: 36,
                child: TrackSceneIcon(scene: TrackScene.parabola, size: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
