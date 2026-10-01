import 'package:flutter/material.dart';

import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';
import '../waves_intro_constants.dart';
import 'control_column.dart';
import 'screen_views.dart';

/// PhET-like shell:
/// Top (tabs outside) · Main sim · Right controls · Bottom time/viewpoint.
class WavesIntroShell extends StatelessWidget {
  const WavesIntroShell({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return ColoredBox(
          color: const Color(0xFFE8E8E8),
          child: Padding(
            padding: const EdgeInsets.all(WavesIntroConstants.layoutMargin),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DisturbanceTypeToggle(model: model),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _screenBody(model),
                                const SizedBox(height: 6),
                                WaveGraphStrip(model: model),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      WavesIntroControlColumn(model: model),
                    ],
                  ),
                ),
                WavesIntroBottomBar(model: model),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _screenBody(WavesIntroModel model) {
    switch (model.scene.config.kind) {
      case SceneKind.water:
        return WaterScreenView(model: model);
      case SceneKind.sound:
        return SoundScreenView(model: model);
      case SceneKind.light:
        return LightScreenView(model: model);
    }
  }
}
