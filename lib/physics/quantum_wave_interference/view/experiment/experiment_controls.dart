import 'package:flutter/material.dart';

import '../../constants/qwi_constants.dart';
import '../layout/experiment_layout_spec.dart';
import '../../domain/detector_mode.dart';
import '../../domain/slit_configuration.dart';
import '../../domain/source_type.dart';
import '../../domain/time_speed.dart';
import '../common/qwi_number_control.dart';
import '../common/qwi_particle_selector.dart';
import 'experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

/// Particle selector — PhET SceneRadioButtonGroup 2×2.
class ExperimentParticleSelector extends StatelessWidget {
  const ExperimentParticleSelector({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    return QwiParticleSelector(
      keyPrefix: 'qwi_source',
      active: controller.model.activeSource,
      onSelect: controller.selectSource,
      cellWidth: ExperimentLayoutConstants.sceneRadioCellWidth,
      cellHeight: ExperimentLayoutConstants.sceneRadioCellHeight,
      spacing: ExperimentLayoutConstants.sceneRadioSpacing,
      runSpacing: ExperimentLayoutConstants.sceneRadioSpacing,
    );
  }
}

/// Source panel: wavelength (rainbow) / speed + intensity — emit lives on overhead gun.
class ExperimentSourceControls extends StatelessWidget {
  const ExperimentSourceControls({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scene.sourceType.isPhoton)
          QwiWavelengthControl(
            sliderKey: const Key('qwi_wavelength_slider'),
            wavelengthNm: scene.wavelengthNm,
            minNm: QwiConstants.photonWavelengthControlMinNm,
            maxNm: QwiConstants.photonWavelengthControlMaxNm,
            onChanged: controller.setWavelengthNm,
          )
        else
          QwiNumberControl(
            sliderKey: const Key('qwi_speed_slider'),
            title: QwiStrings.speed,
            valueText: '${scene.particleSpeedMps.toStringAsExponential(2)} m/s',
            value: scene.particleSpeedMps.clamp(scene.defaults.speedMinMps, scene.defaults.speedMaxMps),
            min: scene.defaults.speedMinMps,
            max: scene.defaults.speedMaxMps,
            onChanged: controller.setParticleSpeedMps,
          ),
        const SizedBox(height: 4),
        QwiNumberControl(
          sliderKey: const Key('qwi_intensity_slider'),
          title: QwiStrings.sourceIntensity,
          valueText: '',
          value: scene.sourceStrength,
          min: 0,
          max: 1,
          minLabel: 'Min',
          maxLabel: 'Max',
          onChanged: controller.setSourceStrength,
        ),
        // Hidden emit toggle for tests / a11y — mirrors overhead gun.
        Opacity(
          opacity: 0,
          child: SizedBox(
            width: 1,
            height: 1,
            child: GestureDetector(
              key: const Key('qwi_emit_toggle'),
              onTap: controller.toggleEmitting,
            ),
          ),
        ),
      ],
    );
  }
}

/// Slit separation · barrier-screen distance · configuration (PhET order).
class ExperimentSlitControls extends StatelessWidget {
  const ExperimentSlitControls({super.key, required this.controller});

  final ExperimentController controller;

  static const _slitLabels = {
    SlitConfiguration.bothOpen: QwiStrings.bothSlitsOpen,
    SlitConfiguration.leftCovered: QwiStrings.leftSlitCovered,
    SlitConfiguration.rightCovered: QwiStrings.rightSlitCovered,
    SlitConfiguration.leftDetector: QwiStrings.detectorOnLeftSlit,
    SlitConfiguration.rightDetector: QwiStrings.detectorOnRightSlit,
    SlitConfiguration.bothDetectors: QwiStrings.detectorsOnBothSlits,
  };

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    final options = SlitConfiguration.values.where((c) => c != SlitConfiguration.noBarrier).toList();
    final sepUm = scene.slitSeparationMm * 1000;
    final sepMinUm = scene.defaults.slitSeparationMinMm * 1000;
    final sepMaxUm = scene.defaults.slitSeparationMaxMm * 1000;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QwiNumberControl(
          sliderKey: const Key('qwi_slit_separation_slider'),
          title: QwiStrings.slitSeparation,
          valueText: '${sepUm.toStringAsFixed(0)} µm',
          value: scene.slitSeparationMm.clamp(scene.defaults.slitSeparationMinMm, scene.defaults.slitSeparationMaxMm),
          min: scene.defaults.slitSeparationMinMm,
          max: scene.defaults.slitSeparationMaxMm,
          minLabel: sepMinUm.toStringAsFixed(0),
          maxLabel: sepMaxUm.toStringAsFixed(0),
          step: (scene.defaults.slitSeparationMaxMm - scene.defaults.slitSeparationMinMm) / 50,
          onChanged: controller.setSlitSeparationMm,
        ),
        const SizedBox(height: 4),
        QwiNumberControl(
          sliderKey: const Key('qwi_screen_distance_slider'),
          title: QwiStrings.barrierScreenDistance,
          valueText: '${scene.screenDistanceM.toStringAsFixed(2)} m',
          value: scene.screenDistanceM,
          min: QwiConstants.experimentScreenDistanceMinM,
          max: QwiConstants.experimentScreenDistanceMaxM,
          minLabel: QwiConstants.experimentScreenDistanceMinM.toStringAsFixed(2),
          maxLabel: QwiConstants.experimentScreenDistanceMaxM.toStringAsFixed(2),
          step: 0.01,
          onChanged: controller.setScreenDistanceM,
        ),
        const SizedBox(height: 4),
        Text(QwiStrings.configuration, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF888888)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<SlitConfiguration>(
              key: const Key('qwi_slit_config'),
              value: scene.slitConfiguration,
              isExpanded: true,
              isDense: true,
              style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: Colors.black87),
              items: options
                  .map((c) => DropdownMenuItem(value: c, child: Text(_slitLabels[c]!)))
                  .toList(),
              onChanged: (c) {
                if (c != null) controller.setSlitConfiguration(c);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Intensity / Hits (vertical) + Screen Brightness — PhET `ScreenControlsPanel`
/// (no panel fill/stroke; HBox radios | brightness).
class ExperimentDetectorControls extends StatelessWidget {
  const ExperimentDetectorControls({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    // Content-sized HBox (PhET ScreenControlsPanel) — Composer centers on detector.
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        QwiAquaRadioGroup<DetectorMode>(
          key: const Key('qwi_detection_mode'),
          value: scene.detectionMode,
          items: const {
            DetectorMode.intensity: QwiStrings.intensity,
            DetectorMode.hits: QwiStrings.hits,
          },
          onChanged: controller.setDetectionMode,
        ),
        const SizedBox(width: 24),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: ExperimentLayoutConstants.screenBrightnessColumnWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  QwiStrings.screenBrightness,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Arial', fontSize: 12, fontWeight: FontWeight.w600),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                  ),
                  child: Slider(
                    key: const Key('qwi_brightness_slider'),
                    value: scene.screenBrightness,
                    min: 0,
                    max: QwiConstants.screenBrightnessMax,
                    onChanged: controller.setScreenBrightness,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Hidden hook for zoom tests / a11y (detector ± is the real control).
        Opacity(
          opacity: 0,
          child: SizedBox(
            width: 1,
            height: 1,
            child: DropdownButton<int>(
              key: const Key('qwi_detector_zoom'),
              value: controller.model.detectorScreenScaleIndex,
              items: const [
                DropdownMenuItem(value: 0, child: Text('0')),
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
              ],
              onChanged: (i) {
                if (i != null) controller.setDetectorScreenScaleIndex(i);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Time controls — NORMAL/FAST + play/pause (hits mode only).
class ExperimentTimeControls extends StatelessWidget {
  const ExperimentTimeControls({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.scene.detectionMode != DetectorMode.hits) {
      return const SizedBox.shrink();
    }
    final clock = controller.model.clock;
    return Row(
      key: const Key('qwi_time_controls'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          key: const Key('qwi_play_pause'),
          onPressed: () => controller.setPlaying(!clock.isPlaying),
          child: Text(clock.isPlaying ? QwiStrings.pause : QwiStrings.play, style: const TextStyle(fontSize: 11)),
        ),
        _TinyChip(
          key: const Key('qwi_speed_normal'),
          label: QwiStrings.normal,
          selected: clock.speed == TimeSpeed.normal,
          onTap: () => controller.setTimeSpeed(TimeSpeed.normal),
        ),
        const SizedBox(width: 4),
        _TinyChip(
          key: const Key('qwi_speed_fast'),
          label: QwiStrings.fast,
          selected: clock.speed == TimeSpeed.fast,
          onTap: () => controller.setTimeSpeed(TimeSpeed.fast),
        ),
      ],
    );
  }
}

class _TinyChip extends StatelessWidget {
  const _TinyChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFB3D4FC) : const Color(0xFFE8E8E8),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
