import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';
import '../waves_intro_constants.dart';
import 'control_column.dart';
import 'screen_views.dart';
import 'wave_render_visibility.dart';
import 'wave_source_nodes.dart';

/// PhET `WavesScreenView` play area on a 1024×618 ScreenView.
class WavesIntroShell extends StatelessWidget {
  const WavesIntroShell({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: WavesIntroConstants.waveAreaLeft,
            bottom: WavesIntroConstants.layoutHeight -
                WavesIntroConstants.waveAreaTop +
                2,
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) => LengthScaleIndicator(model: model),
            ),
          ),
          Positioned(
            left: WavesIntroConstants.waveAreaLeft,
            top: WavesIntroConstants.waveAreaTop,
            child: ListenableBuilder(
              listenable: Listenable.merge([model, model.latticeEpoch]),
              builder: (context, _) => _screenBody(model),
            ),
          ),
          ListenableBuilder(
            listenable: model,
            builder: (context, _) => _sourceLayer(model),
          ),
          Positioned(
            left: WavesIntroConstants.waveAreaLeft / 2 - 22,
            top: WavesIntroConstants.waveAreaBottom - 72,
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) => DisturbanceTypeToggle(model: model),
            ),
          ),
          Positioned(
            right: WavesIntroConstants.layoutMargin,
            top: WavesIntroConstants.layoutMargin,
            width: WavesIntroConstants.panelMaxWidth,
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) => WavesIntroControlColumn(model: model),
            ),
          ),
          Positioned(
            left: WavesIntroConstants.waveAreaLeft,
            bottom: WavesIntroConstants.layoutMargin,
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) => ViewpointRadioGroup(model: model),
            ),
          ),
          Positioned(
            left: WavesIntroConstants.waveAreaCenterX - 108,
            bottom: WavesIntroConstants.layoutMargin,
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) => TimeControlCluster(model: model),
            ),
          ),
          Positioned(
            right: WavesIntroConstants.layoutMargin,
            bottom: WavesIntroConstants.layoutMargin,
            child: KratosResetAllButton(
              onPressed: model.reset,
              radius: 20.5,
            ),
          ),
        ],
      ),
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

  static Widget _sourceLayer(WavesIntroModel model) {
    final vis = WaveRenderVisibility(model);
    const faucetH = 88.0;
    // PhET WaterWaveGeneratorNode FAUCET_VERTICAL_OFFSET = -110 on FaucetNode.
    // Compact faucet sprites: keep the pipe on the wave-area midline (screenshot).
    final sourceTop = WavesIntroConstants.waveAreaCenterY - faucetH / 2;
    if (vis.showFaucet) {
      return Positioned(
        left: 0,
        top: vis.showWaterSideView
            ? WavesIntroConstants.waveAreaTop +
                WavesIntroConstants.waveAreaViewSize * 0.22
            : sourceTop,
        child: WaterFaucetSource(
          model: model,
          pipeWidth: WavesIntroConstants.waveAreaLeft + 8,
        ),
      );
    }
    if (vis.showSpeaker) {
      return Positioned(
        left: WavesIntroConstants.waveAreaLeft - 86,
        top: WavesIntroConstants.waveAreaCenterY - 40,
        child: SoundSpeakerSource(model: model),
      );
    }
    if (vis.showLaser) {
      return Positioned(
        left: WavesIntroConstants.waveAreaLeft - 90,
        top: WavesIntroConstants.waveAreaCenterY - 22,
        child: LightLaserSource(model: model),
      );
    }
    return const SizedBox.shrink();
  }
}
