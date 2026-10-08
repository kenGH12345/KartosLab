import 'package:flutter/material.dart';

import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';
import '../waves_intro_constants.dart';
import 'waves_intro_toolbox.dart';
import 'package:kratos/waves_intro/waves_intro_strings.dart';

class _AudioMeterBar extends StatelessWidget {
  const _AudioMeterBar({required this.level});
  final double level;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(WavesIntroStrings.level, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: level.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE5E5E5),
              color: const Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }
}

/// Control panel: amplitude, frequency, continuous/pulse, source button,
/// graph checkbox, sound view, play/pause/step, reset, toolbox.
class WavesIntroControls extends StatelessWidget {
  const WavesIntroControls({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    final scene = model.scene;
    final config = scene.config;

    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return Card(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  WavesIntroToolbox(model: model),
                  const SizedBox(height: 8),
                  Text(
                    WavesIntroStrings.amplitude,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Slider(
                    value: scene.controlAmplitude,
                    min: WavesIntroConstants.amplitudeMin,
                    max: WavesIntroConstants.amplitudeMax,
                    divisions: 20,
                    label: scene.controlAmplitude.toStringAsFixed(1),
                    onChanged: model.setAmplitude,
                  ),
                  Text(
                    'Frequency (${config.frequencyUnitLabel})',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Slider(
                    value: scene.controlFrequency,
                    min: config.frequencyMin,
                    max: config.frequencyMax,
                    label: scene.controlFrequency.toStringAsFixed(3),
                    onChanged: model.setFrequency,
                  ),
                  const SizedBox(height: 4),
                  SegmentedButton<DisturbanceType>(
                    segments: const [
                      ButtonSegment(
                        value: DisturbanceType.continuous,
                        label: Text(WavesIntroStrings.continuous),
                      ),
                      ButtonSegment(
                        value: DisturbanceType.pulse,
                        label: Text(WavesIntroStrings.pulse),
                      ),
                    ],
                    selected: {scene.disturbanceType},
                    onSelectionChanged: (s) =>
                        model.setDisturbanceType(s.first),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (scene.disturbanceType == DisturbanceType.pulse) {
                          if (!scene.pulseFiring && !scene.isAboutToFire) {
                            model.setButtonPressed(true);
                          }
                        } else {
                          model.setButtonPressed(!scene.buttonPressed);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(
                            WavesIntroConstants.waveGeneratorButtonColor,
                          ),
                          border: Border.all(
                            color: scene.buttonPressed
                                ? Colors.black87
                                : Colors.black26,
                            width: scene.buttonPressed ? 3 : 1,
                          ),
                          boxShadow: scene.buttonPressed
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'λ ≈ ${scene.wavelength.toStringAsFixed(2)} ${config.positionUnitLabel}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(WavesIntroStrings.graph),
                    value: model.showGraph,
                    onChanged: (v) => model.setShowGraph(v ?? false),
                  ),
                  Text(
                    WavesIntroStrings.viewpoint,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  SegmentedButton<Viewpoint>(
                    segments: const [
                      ButtonSegment(
                        value: Viewpoint.top,
                        label: Text(WavesIntroStrings.top),
                      ),
                      ButtonSegment(
                        value: Viewpoint.side,
                        label: Text(WavesIntroStrings.side),
                      ),
                    ],
                    selected: {model.viewpoint},
                    onSelectionChanged: (s) => model.setViewpoint(s.first),
                  ),
                  if (config.kind == SceneKind.light)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(WavesIntroStrings.screen),
                      value: model.showScreen,
                      onChanged: (v) => model.setShowScreen(v ?? false),
                    ),
                  if (config.kind == SceneKind.sound) ...[
                    Text(
                      WavesIntroStrings.soundView,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    SegmentedButton<SoundViewType>(
                      segments: const [
                        ButtonSegment(
                          value: SoundViewType.waves,
                          label: Text(WavesIntroStrings.waves),
                        ),
                        ButtonSegment(
                          value: SoundViewType.particles,
                          label: Text(WavesIntroStrings.particles),
                        ),
                      ],
                      selected: {scene.soundViewType},
                      onSelectionChanged: (s) =>
                          model.setSoundViewType(s.first),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(WavesIntroStrings.playTone),
                      value: model.audioState.isTonePlaying,
                      onChanged: (v) => model.setTonePlaying(v ?? false),
                    ),
                  ],
                  if (config.kind == SceneKind.light)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(WavesIntroStrings.soundEffect),
                      value: model.audioState.soundEffectEnabled,
                      onChanged: (v) =>
                          model.setSoundEffectEnabled(v ?? false),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    WavesIntroStrings.audio,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: model.audioState.muted ? WavesIntroStrings.unmute : WavesIntroStrings.mute,
                        onPressed: () =>
                            model.setMute(!model.audioState.muted),
                        icon: Icon(
                          model.audioState.muted
                              ? Icons.volume_off
                              : Icons.volume_up,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: model.audioState.masterVolume,
                          min: 0,
                          max: 1,
                          onChanged: model.audioState.muted
                              ? null
                              : model.setMasterVolume,
                        ),
                      ),
                    ],
                  ),
                  _AudioMeterBar(level: model.audioState.visualMeterLevel),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: model.isRunning ? WavesIntroStrings.pause : WavesIntroStrings.play,
                        onPressed: model.togglePlayPause,
                        icon: Icon(
                          model.isRunning ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                      IconButton(
                        tooltip: WavesIntroStrings.step,
                        onPressed: model.manualStep,
                        icon: const Icon(Icons.skip_next),
                      ),
                      IconButton(
                        tooltip: WavesIntroStrings.reset,
                        onPressed: model.reset,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
