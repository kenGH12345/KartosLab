import 'package:flutter/material.dart';

import '../../constants/qwi_constants.dart';
import '../../domain/slit_configuration.dart';
import '../../domain/source_type.dart';
import '../../domain/time_speed.dart';
import '../../domain/wave_display_mode.dart';
import '../common/qwi_ab_switch.dart';
import '../common/qwi_number_control.dart';
import 'single_particles_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

class SpSourceControls extends StatelessWidget {
  const SpSourceControls({super.key, required this.controller});

  final SingleParticlesController controller;

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                key: const Key('sp_auto_repeat'),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                value: scene.autoRepeat,
                onChanged: (v) => controller.setAutoRepeat(v ?? false),
              ),
            ),
            Flexible(child: Text(QwiStrings.autoFireMode, style: const TextStyle(fontSize: 11))),
          ],
        ),
        const SizedBox(height: 6),
        if (scene.sourceType.isPhoton)
          QwiWavelengthControl(
            sliderKey: const Key('sp_wavelength_slider'),
            wavelengthNm: scene.wavelengthNm,
            minNm: QwiConstants.photonWavelengthControlMinNm,
            maxNm: QwiConstants.photonWavelengthControlMaxNm,
            onChanged: controller.setWavelengthNm,
          )
        else
          QwiNumberControl(
            sliderKey: const Key('sp_speed_slider'),
            title: QwiStrings.speed,
            valueText: scene.particleSpeedMps.toStringAsExponential(2),
            value: scene.particleSpeedMps.clamp(scene.speedMinMps, scene.speedMaxMps),
            min: scene.speedMinMps,
            max: scene.speedMaxMps,
            onChanged: controller.setParticleSpeedMps,
          ),
      ],
    );
  }
}

class SpSlitControls extends StatelessWidget {
  const SpSlitControls({super.key, required this.controller});

  final SingleParticlesController controller;

  static const _labels = {
    SlitConfiguration.bothOpen: QwiStrings.bothSlitsOpen,
    SlitConfiguration.leftCovered: QwiStrings.topCovered,
    SlitConfiguration.rightCovered: QwiStrings.bottomCovered,
    SlitConfiguration.leftDetector: QwiStrings.detectorOnTop,
    SlitConfiguration.rightDetector: QwiStrings.detectorOnBottom,
    SlitConfiguration.bothDetectors: QwiStrings.detectorsBoth,
    SlitConfiguration.noBarrier: QwiStrings.noBarrier,
  };

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    final sep = scene.slitSeparationMm.clamp(scene.slitSeparationMinMm, scene.slitSeparationMaxMm);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(QwiStrings.configuration, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF888888)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SlitConfiguration>(
                    key: const Key('sp_slit_config'),
                    isExpanded: true,
                    isDense: true,
                    value: scene.slitConfiguration,
                    style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: Colors.black87),
                    items: SlitConfiguration.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(_labels[c]!)))
                        .toList(),
                    onChanged: (c) {
                      if (c != null) controller.setSlitConfiguration(c);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: QwiNumberControl(
            sliderKey: const Key('sp_slit_separation_slider'),
            title: QwiStrings.slitSeparation,
            valueText: '${(sep * 1000).toStringAsFixed(1)} µm',
            value: sep,
            min: scene.slitSeparationMinMm,
            max: scene.slitSeparationMaxMm,
            onChanged: controller.setSlitSeparationMm,
          ),
        ),
      ],
    );
  }
}

class SpWaveModeControls extends StatelessWidget {
  const SpWaveModeControls({super.key, required this.controller});

  final SingleParticlesController controller;

  @override
  Widget build(BuildContext context) {
    final photon = controller.scene.sourceType.isPhoton;
    final modes = photon
        ? const [WaveDisplayMode.electricField, WaveDisplayMode.amplitude]
        : const [WaveDisplayMode.realPart, WaveDisplayMode.amplitude];
    final labels = {
      WaveDisplayMode.electricField: QwiStrings.electricField,
      WaveDisplayMode.amplitude: QwiStrings.amplitude,
      WaveDisplayMode.realPart: QwiStrings.realPart,
    };
    return Container(
      key: const Key('sp_wave_mode'),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF888888)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WaveDisplayMode>(
          isExpanded: true,
          isDense: true,
          value: modes.contains(controller.scene.waveDisplayMode)
              ? controller.scene.waveDisplayMode
              : modes.first,
          style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: Colors.black87),
          items: modes
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(labels[m]!, key: Key('sp_mode_$m')),
                ),
              )
              .toList(),
          onChanged: (m) {
            if (m != null) controller.setWaveDisplayMode(m);
          },
        ),
      ),
    );
  }
}

class SpDetectorControls extends StatelessWidget {
  const SpDetectorControls({super.key, required this.controller});

  final SingleParticlesController controller;

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    final graph = controller.graphVisible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: QwiAbSwitch(
            key: const Key('sp_screen_graph_switch'),
            value: !graph,
            onChanged: (screenSelected) => controller.setGraphVisible(!screenSelected),
            leftLabel: QwiStrings.screen,
            rightLabel: QwiStrings.graph,
          ),
        ),
        const SizedBox(height: 6),
        Text(QwiStrings.detectorHits, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Text(QwiStrings.hitsCount(scene.hits.length), style: const TextStyle(fontSize: 10)),
        if (!graph) ...[
          Text(QwiStrings.screenBrightness, style: const TextStyle(fontFamily: 'Arial', fontSize: 11)),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              key: const Key('sp_brightness_slider'),
              value: scene.screenBrightness,
              min: 0,
              max: QwiConstants.screenBrightnessMax,
              onChanged: controller.setScreenBrightness,
            ),
          ),
        ],
        if (graph) ...[
          Text(QwiStrings.zoomLevel(controller.model.graphZoom.level), style: const TextStyle(fontSize: 10)),
          Slider(
            key: const Key('sp_zoom_slider'),
            value: controller.model.graphZoom.level.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            onChanged: (v) => controller.setGraphZoom(v.round()),
          ),
        ],
        if (scene.isProbeAvailable) ...[
          Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  key: const Key('sp_probe_checkbox'),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  value: scene.probeVisible,
                  onChanged: (v) => controller.setProbeVisible(v ?? false),
                ),
              ),
              Text(QwiStrings.probe, style: const TextStyle(fontSize: 11)),
            ],
          ),
          if (scene.probeVisible)
            Text(
              QwiStrings.probeState(scene.detectorProbe.state.name),
              style: const TextStyle(fontFamily: 'Arial', fontSize: 10),
            ),
        ],
      ],
    );
  }
}

class SpTimeControls extends StatelessWidget {
  const SpTimeControls({super.key, required this.controller});

  final SingleParticlesController controller;

  @override
  Widget build(BuildContext context) {
    final clock = controller.model.clock;
    return Column(
      key: const Key('sp_time_controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton(
              key: const Key('sp_play_pause'),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () => controller.setPlaying(!clock.isPlaying),
              child: Text(clock.isPlaying ? QwiStrings.pause : QwiStrings.play, style: const TextStyle(fontSize: 11)),
            ),
            TextButton(
              key: const Key('sp_step'),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: controller.stepOnce,
              child: Text(QwiStrings.step, style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        QwiAquaRadioGroup<TimeSpeed>(
          value: clock.speed,
          items: const {
            TimeSpeed.slow: QwiStrings.slow,
            TimeSpeed.normal: QwiStrings.normal,
            TimeSpeed.fast: QwiStrings.fast,
          },
          onChanged: controller.setTimeSpeed,
        ),
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 1,
            child: Row(
              children: [
                for (final e in [
                  (TimeSpeed.slow, 'sp_speed_slow'),
                  (TimeSpeed.normal, 'sp_speed_normal'),
                  (TimeSpeed.fast, 'sp_speed_fast'),
                ])
                  GestureDetector(
                    key: Key(e.$2),
                    onTap: () => controller.setTimeSpeed(e.$1),
                    child: const SizedBox(width: 1, height: 1),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
