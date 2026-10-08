import 'package:flutter/material.dart';

import '../../constants/qwi_constants.dart';
import '../../domain/detector_mode.dart';
import '../../domain/slit_configuration.dart';
import '../../domain/source_type.dart';
import '../../domain/time_speed.dart';
import '../../domain/wave_display_mode.dart';
import '../common/qwi_ab_switch.dart';
import '../common/qwi_number_control.dart';
import 'high_intensity_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

class HiSourceControls extends StatelessWidget {
  const HiSourceControls({super.key, required this.controller});

  final HighIntensityController controller;

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scene.sourceType.isPhoton)
          QwiWavelengthControl(
            sliderKey: const Key('hi_wavelength_slider'),
            wavelengthNm: scene.wavelengthNm,
            minNm: QwiConstants.photonWavelengthControlMinNm,
            maxNm: QwiConstants.photonWavelengthControlMaxNm,
            onChanged: controller.setWavelengthNm,
          )
        else
          QwiNumberControl(
            sliderKey: const Key('hi_speed_slider'),
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

class HiSlitControls extends StatelessWidget {
  const HiSlitControls({super.key, required this.controller});

  final HighIntensityController controller;

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
    // Original: Configuration | Slit Separation side-by-side under the wave.
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
                    key: const Key('hi_slit_config'),
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
            sliderKey: const Key('hi_slit_separation_slider'),
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

class HiWaveModeControls extends StatelessWidget {
  const HiWaveModeControls({super.key, required this.controller});

  final HighIntensityController controller;

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
      key: const Key('hi_wave_mode'),
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
                  child: Text(labels[m]!, key: Key('hi_mode_$m')),
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

class HiDetectorControls extends StatelessWidget {
  const HiDetectorControls({super.key, required this.controller});

  final HighIntensityController controller;

  @override
  Widget build(BuildContext context) {
    final scene = controller.scene;
    final graph = controller.graphVisible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: QwiAbSwitch(
            key: const Key('hi_screen_graph_switch'),
            value: !graph,
            onChanged: (screenSelected) => controller.setGraphVisible(!screenSelected),
            leftLabel: QwiStrings.screen,
            rightLabel: QwiStrings.graph,
          ),
        ),
        const SizedBox(height: 6),
        QwiAquaRadioGroup<DetectorMode>(
          value: scene.detectionMode,
          items: const {
            DetectorMode.intensity: QwiStrings.intensity,
            DetectorMode.hits: QwiStrings.hits,
          },
          onChanged: controller.setDetectionMode,
        ),
        // Legacy keys for widget tests.
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 1,
            child: Row(
              children: [
                GestureDetector(
                  key: const Key('hi_mode_intensity'),
                  onTap: () => controller.setDetectionMode(DetectorMode.intensity),
                  child: const SizedBox(width: 1, height: 1),
                ),
                GestureDetector(
                  key: const Key('hi_mode_hits'),
                  onTap: () => controller.setDetectionMode(DetectorMode.hits),
                  child: const SizedBox(width: 1, height: 1),
                ),
              ],
            ),
          ),
        ),
        if (!graph) ...[
          Text(QwiStrings.screenBrightness, style: const TextStyle(fontFamily: 'Arial', fontSize: 11)),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              key: const Key('hi_brightness_slider'),
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
            key: const Key('hi_zoom_slider'),
            value: controller.model.graphZoom.level.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            onChanged: (v) => controller.setGraphZoom(v.round()),
          ),
        ],
      ],
    );
  }
}

class HiTimeControls extends StatelessWidget {
  const HiTimeControls({super.key, required this.controller});

  final HighIntensityController controller;

  @override
  Widget build(BuildContext context) {
    final clock = controller.model.clock;
    return Column(
      key: const Key('hi_time_controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _RoundTimeButton(
              key: const Key('hi_play_pause'),
              color: const Color(0xFF337AB7),
              onPressed: () => controller.setPlaying(!clock.isPlaying),
              child: CustomPaint(
                size: const Size(12, 12),
                painter: clock.isPlaying ? const _PauseGlyphPainter() : const _PlayGlyphPainter(),
              ),
            ),
            const SizedBox(width: 6),
            _RoundTimeButton(
              key: const Key('hi_step'),
              color: const Color(0xFF9E9E9E),
              onPressed: controller.stepOnce,
              child: const CustomPaint(size: Size(12, 12), painter: _StepGlyphPainter()),
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
                  (TimeSpeed.slow, 'hi_speed_slow'),
                  (TimeSpeed.normal, 'hi_speed_normal'),
                  (TimeSpeed.fast, 'hi_speed_fast'),
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

class _RoundTimeButton extends StatelessWidget {
  const _RoundTimeButton({
    super.key,
    required this.color,
    required this.onPressed,
    required this.child,
  });

  final Color color;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(width: 28, height: 28, child: Center(child: child)),
      ),
    );
  }
}

class _PlayGlyphPainter extends CustomPainter {
  const _PlayGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.25, size.height * 0.85)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PauseGlyphPainter extends CustomPainter {
  const _PauseGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.18, size.width * 0.22, size.height * 0.64),
        const Radius.circular(1),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, size.height * 0.18, size.width * 0.22, size.height * 0.64),
        const Radius.circular(1),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StepGlyphPainter extends CustomPainter {
  const _StepGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..lineTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width * 0.15, size.height * 0.8)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.2, size.width * 0.18, size.height * 0.6),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
